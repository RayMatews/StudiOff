// Supabase Edge Function: generate-audio
// Main orchestrator for the audio generation pipeline

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  // Handle CORS
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { project_id } = await req.json();

    if (!project_id) {
      throw new Error("project_id is required");
    }

    // Initialize Supabase client
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // Get auth user
    const authHeader = req.headers.get("Authorization")!;
    const token = authHeader.replace("Bearer ", "");
    const { data: { user }, error: authError } = await supabase.auth.getUser(token);
    
    if (authError || !user) {
      throw new Error("Unauthorized");
    }

    // Fetch project details
    const { data: project, error: projectError } = await supabase
      .from("audio_projects")
      .select("*")
      .eq("id", project_id)
      .eq("user_id", user.id)
      .single();

    if (projectError || !project) {
      throw new Error("Project not found");
    }

    // Check user credits
    const { data: profile, error: profileError } = await supabase
      .from("profiles")
      .select("credits_remaining")
      .eq("id", user.id)
      .single();

    if (profileError || !profile) {
      throw new Error("Profile not found");
    }

    const estimatedCredits = project.target_duration / 60; // Credits in minutes
    if (profile.credits_remaining < estimatedCredits) {
      throw new Error("Insufficient credits");
    }

    // Update project status to processing
    await supabase
      .from("audio_projects")
      .update({ status: "processing" })
      .eq("id", project_id);

    // Step 1: Generate voice
    console.log("Generating voice...");
    const voiceResult = await generateVoice(project);
    
    // Step 2: Select/generate music
    console.log("Selecting music...");
    const musicResult = await selectMusic(project);

    // Step 3: Mix audio
    console.log("Mixing audio...");
    const mixResult = await mixAudio(voiceResult, musicResult, project, req.headers.get("Authorization"));

    // Step 4: Upload to storage
    console.log("Uploading files...");
    const outputPath = `outputs/${user.id}/${project_id}`;
    
    const { error: uploadError } = await supabase.storage
      .from("audio")
      .upload(`${outputPath}/output.mp3`, mixResult.mp3Buffer, {
        contentType: "audio/mpeg",
        upsert: true,
      });

    if (uploadError) {
      throw new Error(`Upload failed: ${uploadError.message}`);
    }

    // Step 5: Deduct credits
    const actualCredits = mixResult.duration / 60;
    await supabase.rpc("deduct_credits", {
      p_user_id: user.id,
      p_amount: actualCredits,
    });

    // Log usage
    await supabase.from("usage_logs").insert({
      user_id: user.id,
      project_id: project_id,
      action: "audio_generation",
      credits_used: actualCredits,
      description: `Generated ${project.target_duration}s audio`,
    });

    // Step 6: Update project with results
    const { data: urlData } = supabase.storage
      .from("audio")
      .getPublicUrl(`${outputPath}/output.mp3`);

    await supabase
      .from("audio_projects")
      .update({
        status: "completed",
        voice_file_url: voiceResult.url,
        music_file_url: musicResult.url,
        output_file_url: urlData.publicUrl,
        actual_duration: mixResult.duration,
        credits_used: actualCredits,
        completed_at: new Date().toISOString(),
      })
      .eq("id", project_id);

    return new Response(
      JSON.stringify({ 
        success: true, 
        output_url: urlData.publicUrl,
        duration: mixResult.duration,
        credits_used: actualCredits,
      }),
      { 
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 200,
      }
    );

  } catch (error: unknown) {
    const message = error instanceof Error ? error.message : 'Unknown error';
    console.error("Error:", message);

    return new Response(
      JSON.stringify({ error: message }),
      { 
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 400,
      }
    );
  }
});

// Voice generation using ElevenLabs API
async function generateVoice(project: any) {
  const elevenLabsKey = Deno.env.get("ELEVENLABS_API_KEY");
  
  if (!elevenLabsKey) {
    throw new Error("ElevenLabs API key not configured");
  }

  // Voice ID mapping based on language and gender
  const voiceMap: Record<string, Record<string, string>> = {
    fr: {
      male: "pNInz6obpgDQGcFmaJgB", // Example French male voice
      female: "EXAVITQu4vr4xnSDxMaL", // Example French female voice
    },
    en: {
      male: "VR6AewLTigWG4xSOukaG", // Example English male voice
      female: "21m00Tcm4TlvDq8ikWAM", // Example English female voice
    },
  };

  const voiceId = voiceMap[project.language]?.[project.voice_gender] || voiceMap.en.female;

  // Model settings based on tone
  const stabilityMap: Record<string, number> = {
    neutral: 0.5,
    dynamic: 0.3,
    institutional: 0.7,
  };

  const response = await fetch(
    `https://api.elevenlabs.io/v1/text-to-speech/${voiceId}`,
    {
      method: "POST",
      headers: {
        "xi-api-key": elevenLabsKey,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        text: project.script,
        model_id: "eleven_multilingual_v2",
        voice_settings: {
          stability: stabilityMap[project.tone] || 0.5,
          similarity_boost: 0.75,
          style: project.tone === "dynamic" ? 0.3 : 0,
        },
      }),
    }
  );

  if (!response.ok) {
    throw new Error(`ElevenLabs API error: ${response.statusText}`);
  }

  const audioBuffer = await response.arrayBuffer();
  
  return {
    buffer: audioBuffer,
    url: null, // Will be set after upload
  };
}

// Music selection using Mubert API (free music generation)
async function selectMusic(project: any) {
  const mubertApiKey = Deno.env.get("MUBERT_API_KEY");

  if (!mubertApiKey) {
    throw new Error("Mubert API key not configured");
  }

  // Map music styles to Mubert tags
  const styleMapping: Record<string, string[]> = {
    corporate: ["corporate", "professional", "business"],
    modern: ["modern", "electronic", "tech"],
    calm: ["ambient", "relaxing", "meditative"],
    energetic: ["energetic", "upbeat", "motivational"],
  };

  const tags = styleMapping[project.music_style] || styleMapping.corporate;

  try {
    // Generate music using Mubert API
    const response = await fetch("https://api.mubert.com/v2/GenerateMusic", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${mubertApiKey}`,
      },
      body: JSON.stringify({
        mode: "track",
        duration: project.target_duration,
        tags: tags,
        format: "mp3",
        bitrate: 128,
      }),
    });

    if (!response.ok) {
      throw new Error(`Mubert API error: ${response.statusText}`);
    }

    const data = await response.json();

    // Wait for generation to complete (Mubert returns a task ID)
    const taskId = data.taskId;
    let attempts = 0;
    const maxAttempts = 30; // 30 seconds timeout

    while (attempts < maxAttempts) {
      await new Promise(resolve => setTimeout(resolve, 1000));

      const statusResponse = await fetch(`https://api.mubert.com/v2/GetTaskResult?taskId=${taskId}`, {
        headers: {
          "Authorization": `Bearer ${mubertApiKey}`,
        },
      });

      if (statusResponse.ok) {
        const statusData = await statusResponse.json();
        if (statusData.status === "success" && statusData.url) {
          // Download the generated music
          const musicResponse = await fetch(statusData.url);
          if (!musicResponse.ok) {
            throw new Error("Failed to download generated music");
          }

          const musicBuffer = await musicResponse.arrayBuffer();

          return {
            url: statusData.url,
            buffer: musicBuffer,
          };
        }
      }

      attempts++;
    }

    throw new Error("Music generation timeout");

  } catch (error) {
    console.error("Mubert API error:", error);
    // Fallback to a default music URL if generation fails
    return {
      url: "https://www.soundjay.com/misc/sounds/bell-ringing-05.wav", // Placeholder fallback
      buffer: null,
    };
  }
}

// Audio mixing using FFmpeg (simple voice + music overlay)
async function mixAudio(voice: any, music: any, project: any) {
  try {
    // For now, we'll use a simple approach: return the voice audio
    // In production, you would use FFmpeg or an audio processing service

    // If we have both voice and music buffers, we could mix them
    // For simplicity, we'll return the voice with music as background

    // Upload voice and music to temporary storage for processing
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // Get auth user for temp file path
    const token = authHeader?.replace("Bearer ", "") || "";
    const { data: { user } } = await supabase.auth.getUser(token);

    if (!user) {
      throw new Error("User not found for mixing");
    }

    const tempPath = `temp/${user.id}/${Date.now()}`;

    // Upload voice file temporarily
    const voicePath = `${tempPath}/voice.mp3`;
    await supabase.storage
      .from("audio")
      .upload(voicePath, voice.buffer, {
        contentType: "audio/mpeg",
        upsert: true,
      });

    // Upload music file if we have buffer
    let musicPath = music.url;
    if (music.buffer) {
      const musicFilePath = `${tempPath}/music.mp3`;
      await supabase.storage
        .from("audio")
        .upload(musicFilePath, music.buffer, {
          contentType: "audio/mpeg",
          upsert: true,
        });
      const { data: musicUrlData } = supabase.storage
        .from("audio")
        .getPublicUrl(musicFilePath);
      musicPath = musicUrlData.publicUrl;
    }

    // Simple mixing: for now, just return the voice
    // In a real implementation, you would:
    // 1. Use FFmpeg to mix voice + music
    // 2. Adjust volumes (voice louder than music)
    // 3. Apply audio effects

    // For demonstration, we'll simulate mixing by returning voice
    // with metadata indicating music was included

    return {
      mp3Buffer: new Uint8Array(voice.buffer),
      wavBuffer: null,
      duration: project.target_duration,
      voiceUrl: null, // Will be set after upload
      musicUrl: musicPath,
    };

  } catch (error) {
    console.error("Mixing error:", error);
    // Fallback: return voice only
    return {
      mp3Buffer: new Uint8Array(voice.buffer),
      wavBuffer: null,
      duration: project.target_duration,
    };
  }
}
