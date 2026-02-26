-- StudiOff - Script de mise à jour (gère les objets existants)
-- Exécutez ce script si 001 a échoué car des objets existent déjà

-- =====================
-- DROP EXISTING POLICIES
-- =====================
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Users can view own projects" ON audio_projects;
DROP POLICY IF EXISTS "Users can insert own projects" ON audio_projects;
DROP POLICY IF EXISTS "Users can update own projects" ON audio_projects;
DROP POLICY IF EXISTS "Users can delete own projects" ON audio_projects;
DROP POLICY IF EXISTS "Users can view own subscription" ON subscriptions;
DROP POLICY IF EXISTS "Users can view own logs" ON usage_logs;
DROP POLICY IF EXISTS "Users can insert own logs" ON usage_logs;

-- =====================
-- RECREATE POLICIES - PROFILES
-- =====================
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

-- =====================
-- RECREATE POLICIES - AUDIO_PROJECTS
-- =====================
CREATE POLICY "Users can view own projects" ON audio_projects
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own projects" ON audio_projects
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own projects" ON audio_projects
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own projects" ON audio_projects
  FOR DELETE USING (auth.uid() = user_id);

-- =====================
-- RECREATE POLICIES - SUBSCRIPTIONS
-- =====================
CREATE POLICY "Users can view own subscription" ON subscriptions
  FOR SELECT USING (auth.uid() = user_id);

-- =====================
-- RECREATE POLICIES - USAGE_LOGS
-- =====================
CREATE POLICY "Users can view own logs" ON usage_logs
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own logs" ON usage_logs
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- =====================
-- RECREATE FUNCTIONS (OR REPLACE handles existing)
-- =====================
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

-- =====================
-- RECREATE TRIGGERS
-- =====================
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

DROP TRIGGER IF EXISTS on_subscription_change ON subscriptions;
CREATE TRIGGER on_subscription_change
  AFTER INSERT OR UPDATE ON subscriptions
  FOR EACH ROW EXECUTE FUNCTION sync_subscription_to_profile();

-- =====================
-- INDEXES (IF NOT EXISTS)
-- =====================
CREATE INDEX IF NOT EXISTS idx_audio_projects_user_id ON audio_projects(user_id);
CREATE INDEX IF NOT EXISTS idx_audio_projects_status ON audio_projects(status);
CREATE INDEX IF NOT EXISTS idx_audio_projects_created_at ON audio_projects(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_subscriptions_user_id ON subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_stripe_customer_id ON subscriptions(stripe_customer_id);
CREATE INDEX IF NOT EXISTS idx_usage_logs_user_id ON usage_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_usage_logs_created_at ON usage_logs(created_at DESC);

-- Done!
SELECT 'Migration completed successfully!' as result;
