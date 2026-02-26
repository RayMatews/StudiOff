// Audio service for managing audio projects
import '../models/audio_project.dart';
import 'supabase_service.dart';

class AudioService {
  // Create a new audio project
  Future<AudioProject> createProject(AudioGenerationRequest request) async {
    final userId = SupabaseService.userId;
    if (userId == null) throw Exception('User not authenticated');

    final response = await SupabaseService.from('audio_projects')
        .insert({
          'user_id': userId,
          'title': request.title ?? 'Audio ${DateTime.now().toIso8601String()}',
          'script': request.script,
          'language': request.language,
          'voice_gender': request.voiceGender,
          'tone': request.tone,
          'target_duration': request.targetDuration,
          'music_style': request.musicStyle,
          'status': 'draft',
        })
        .select()
        .single();

    return AudioProject.fromJson(_snakeToCamel(response));
  }

  // Start audio generation pipeline
  Future<AudioProject> generateAudio(String projectId) async {
    // Update status to processing
    await SupabaseService.from('audio_projects')
        .update({'status': 'processing'})
        .eq('id', projectId);

    try {
      // Call edge function to start generation
      final response = await SupabaseService.functions.invoke(
        'generate-audio',
        body: {'project_id': projectId},
      );

      if (response.status != 200) {
        throw Exception('Audio generation failed: ${response.data}');
      }

      // Fetch updated project
      return await getProject(projectId);
    } catch (e) {
      // Update status to failed
      await SupabaseService.from('audio_projects')
          .update({
            'status': 'failed',
            'error_message': e.toString(),
          })
          .eq('id', projectId);
      rethrow;
    }
  }

  // Get single project
  Future<AudioProject> getProject(String projectId) async {
    final response = await SupabaseService.from('audio_projects')
        .select()
        .eq('id', projectId)
        .single();

    return AudioProject.fromJson(_snakeToCamel(response));
  }

  // Get user's projects
  Future<List<AudioProject>> getUserProjects({
    int limit = 20,
    int offset = 0,
  }) async {
    final userId = SupabaseService.userId;
    if (userId == null) throw Exception('User not authenticated');

    final response = await SupabaseService.from('audio_projects')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List)
        .map((json) => AudioProject.fromJson(_snakeToCamel(json)))
        .toList();
  }

  // Delete project
  Future<void> deleteProject(String projectId) async {
    await SupabaseService.from('audio_projects')
        .delete()
        .eq('id', projectId);
  }

  // Get download URL for output file
  Future<String> getDownloadUrl(String projectId, {bool wav = false}) async {
    final project = await getProject(projectId);
    final fileUrl = wav ? project.outputFileUrlWav : project.outputFileUrl;
    
    if (fileUrl == null) {
      throw Exception('Output file not available');
    }

    // If it's a storage path, get signed URL
    if (fileUrl.startsWith('outputs/')) {
      final signedUrl = await SupabaseService.storage
          .from('audio')
          .createSignedUrl(fileUrl, 3600); // 1 hour expiry
      return signedUrl;
    }

    return fileUrl;
  }

  // Stream project status updates
  Stream<AudioProject> watchProject(String projectId) {
    return SupabaseService.client
        .from('audio_projects')
        .stream(primaryKey: ['id'])
        .eq('id', projectId)
        .map((data) => AudioProject.fromJson(_snakeToCamel(data.first)));
  }

  // Helper to convert snake_case to camelCase
  Map<String, dynamic> _snakeToCamel(Map<String, dynamic> map) {
    return map.map((key, value) {
      final camelKey = key.replaceAllMapped(
        RegExp(r'_([a-z])'),
        (match) => match.group(1)!.toUpperCase(),
      );
      return MapEntry(camelKey, value);
    });
  }
}
