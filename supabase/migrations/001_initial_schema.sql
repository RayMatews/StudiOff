-- StudiOff Database Schema for Supabase
-- Run this in your Supabase SQL Editor

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================
-- PROFILES TABLE
-- =====================
-- Note: Les champs subscription_* sont dupliqués depuis la table subscriptions
-- pour éviter les JOINs fréquents (cache denormalisé pour performance).
-- Ces champs sont synchronisés automatiquement via trigger.
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  credits_remaining INTEGER DEFAULT 30 NOT NULL,
  credits_used_this_month INTEGER DEFAULT 0 NOT NULL,
  -- Champs denormalisés (source de vérité: table subscriptions)
  subscription_id TEXT,
  subscription_status TEXT,
  subscription_plan TEXT,
  subscription_end_date TIMESTAMPTZ,
  preferred_language TEXT DEFAULT 'fr',
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ
);

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Policies for profiles
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

-- Trigger to create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name)
  VALUES (
    NEW.id,
    NEW.email,
    NEW.raw_user_meta_data->>'full_name'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- =====================
-- AUDIO_PROJECTS TABLE
-- =====================
-- target_duration: durée cible en secondes (15s, 30s, 60s)
-- actual_duration: durée réelle du fichier audio final en secondes
-- credits_used: nombre de crédits consommés pour ce projet
CREATE TABLE IF NOT EXISTS audio_projects (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  script TEXT NOT NULL,
  language TEXT NOT NULL CHECK (language IN ('fr', 'en')),
  voice_gender TEXT NOT NULL CHECK (voice_gender IN ('male', 'female')),
  voice_id TEXT,
  tone TEXT NOT NULL CHECK (tone IN ('neutral', 'dynamic', 'institutional')),
  target_duration INTEGER NOT NULL CHECK (target_duration IN (15, 30, 60)),  -- en secondes
  music_style TEXT NOT NULL CHECK (music_style IN ('corporate', 'modern', 'calm', 'energetic')),
  music_track_id TEXT,
  status TEXT DEFAULT 'draft' CHECK (status IN ('draft', 'processing', 'completed', 'failed')),
  voice_file_url TEXT,
  music_file_url TEXT,
  output_file_url TEXT,
  output_file_url_wav TEXT,
  actual_duration INTEGER,  -- en secondes
  credits_used DECIMAL(10, 2),
  error_message TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  completed_at TIMESTAMPTZ
);

-- Enable RLS
ALTER TABLE audio_projects ENABLE ROW LEVEL SECURITY;

-- Policies for audio_projects
CREATE POLICY "Users can view own projects" ON audio_projects
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own projects" ON audio_projects
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own projects" ON audio_projects
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own projects" ON audio_projects
  FOR DELETE USING (auth.uid() = user_id);

-- Index for faster queries
CREATE INDEX idx_audio_projects_user_id ON audio_projects(user_id);
CREATE INDEX idx_audio_projects_status ON audio_projects(status);
CREATE INDEX idx_audio_projects_created_at ON audio_projects(created_at DESC);

-- =====================
-- SUBSCRIPTIONS TABLE
-- =====================
CREATE TABLE IF NOT EXISTS subscriptions (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL UNIQUE,
  stripe_customer_id TEXT NOT NULL,
  stripe_subscription_id TEXT NOT NULL UNIQUE,
  plan TEXT NOT NULL CHECK (plan IN ('starter', 'pro')),
  status TEXT NOT NULL CHECK (status IN ('active', 'canceled', 'past_due', 'trialing', 'incomplete')),
  monthly_minutes INTEGER NOT NULL,
  current_period_start TIMESTAMPTZ NOT NULL,
  current_period_end TIMESTAMPTZ NOT NULL,
  canceled_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ
);

-- Enable RLS
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

-- Policies for subscriptions
CREATE POLICY "Users can view own subscription" ON subscriptions
  FOR SELECT USING (auth.uid() = user_id);

-- Index
CREATE INDEX idx_subscriptions_user_id ON subscriptions(user_id);
CREATE INDEX idx_subscriptions_stripe_customer_id ON subscriptions(stripe_customer_id);

-- Trigger to sync subscription data to profiles (denormalization)
CREATE OR REPLACE FUNCTION sync_subscription_to_profile()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE profiles
  SET 
    subscription_id = NEW.stripe_subscription_id,
    subscription_status = NEW.status,
    subscription_plan = NEW.plan,
    subscription_end_date = NEW.current_period_end,
    updated_at = NOW()
  WHERE id = NEW.user_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_subscription_change
  AFTER INSERT OR UPDATE ON subscriptions
  FOR EACH ROW EXECUTE FUNCTION sync_subscription_to_profile();

-- =====================
-- USAGE_LOGS TABLE
-- =====================
CREATE TABLE IF NOT EXISTS usage_logs (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  project_id UUID REFERENCES audio_projects(id) ON DELETE SET NULL,
  action TEXT NOT NULL,
  credits_used DECIMAL(10, 2) NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Enable RLS
ALTER TABLE usage_logs ENABLE ROW LEVEL SECURITY;

-- Policies for usage_logs
CREATE POLICY "Users can view own logs" ON usage_logs
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own logs" ON usage_logs
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Index
CREATE INDEX idx_usage_logs_user_id ON usage_logs(user_id);
CREATE INDEX idx_usage_logs_created_at ON usage_logs(created_at DESC);

-- =====================
-- STORAGE BUCKETS
-- =====================
-- Run these in the Supabase dashboard > Storage

-- Create 'audio' bucket for storing generated audio files
-- INSERT INTO storage.buckets (id, name, public) VALUES ('audio', 'audio', false);

-- Policies for audio bucket (to be set in dashboard):
-- - Users can read their own files
-- - Only service role can write

-- =====================
-- HELPER FUNCTIONS
-- =====================

-- Function to deduct credits
-- p_amount is in credits (DECIMAL for partial credits support)
CREATE OR REPLACE FUNCTION deduct_credits(
  p_user_id UUID,
  p_amount DECIMAL
)
RETURNS BOOLEAN AS $$
DECLARE
  v_current_credits DECIMAL;
BEGIN
  SELECT credits_remaining::DECIMAL INTO v_current_credits
  FROM profiles
  WHERE id = p_user_id;
  
  IF v_current_credits >= p_amount THEN
    UPDATE profiles
    SET 
      credits_remaining = credits_remaining - p_amount,
      credits_used_this_month = credits_used_this_month + p_amount,
      updated_at = NOW()
    WHERE id = p_user_id;
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to reset monthly usage (call via cron)
CREATE OR REPLACE FUNCTION reset_monthly_credits()
RETURNS void AS $$
BEGIN
  UPDATE profiles
  SET 
    credits_used_this_month = 0,
    credits_remaining = CASE 
      WHEN subscription_plan = 'pro' THEN 120
      WHEN subscription_plan = 'starter' THEN 30
      ELSE credits_remaining
    END,
    updated_at = NOW()
  WHERE subscription_status = 'active';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
