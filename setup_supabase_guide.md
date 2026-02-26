# 🚀 Guide de Configuration Supabase - StudiOff

## Étape 1: Créer un projet Supabase

1. Allez sur [https://supabase.com](https://supabase.com)
2. Connectez-vous ou créez un compte
3. Cliquez sur **"New Project"**
4. Remplissez:
   - **Name**: `studioff` (ou le nom de votre choix)
   - **Database Password**: Générez un mot de passe fort (gardez-le!)
   - **Region**: Choisissez la plus proche (ex: `eu-west-1` pour Europe)
5. Cliquez sur **"Create new project"**
6. Attendez ~2 minutes que le projet soit prêt

## Étape 2: Récupérer les clés API

1. Dans votre projet Supabase, allez dans **Settings** > **API**
2. Copiez ces valeurs:

```
SUPABASE_URL=https://xxxxxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

⚠️ **IMPORTANT**: Ne jamais exposer `SERVICE_ROLE_KEY` côté client!

## Étape 3: Exécuter la migration SQL

1. Dans Supabase, allez dans **SQL Editor**
2. Cliquez sur **"New query"**
3. Copiez le contenu de `supabase/migrations/001_initial_schema.sql`
4. Cliquez sur **"Run"**
5. Vérifiez que toutes les tables sont créées dans **Table Editor**

Tables attendues:
- ✅ profiles
- ✅ audio_projects
- ✅ subscriptions
- ✅ usage_logs

## Étape 4: Configurer l'authentification

1. Allez dans **Authentication** > **Providers**
2. Activez **Email** (déjà actif par défaut)
3. Optionnel - Activez **Google**:
   - Client ID: (depuis Google Cloud Console)
   - Client Secret: (depuis Google Cloud Console)

4. Allez dans **Authentication** > **URL Configuration**
5. Configurez:
   - Site URL: `http://localhost:3000` (dev) ou votre domaine
   - Redirect URLs: Ajoutez vos URLs de callback

## Étape 5: Configurer le Storage

1. Allez dans **Storage**
2. Cliquez sur **"New bucket"**
3. Créez un bucket nommé `audio`
4. Configurez comme **Private** (non public)
5. Ajoutez les politiques RLS (dans SQL Editor):

```sql
-- Politique: Les utilisateurs peuvent lire leurs propres fichiers
CREATE POLICY "Users can read own audio files"
ON storage.objects FOR SELECT
USING (bucket_id = 'audio' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Politique: Service role peut tout faire
CREATE POLICY "Service role can manage all audio files"
ON storage.objects FOR ALL
USING (bucket_id = 'audio')
WITH CHECK (bucket_id = 'audio');
```

## Étape 6: Déployer les Edge Functions

### Option A: Via Supabase CLI (recommandé)

```powershell
# Installer Supabase CLI si pas déjà fait
npm install -g supabase

# Se connecter
supabase login

# Lier au projet
supabase link --project-ref YOUR_PROJECT_REF

# Déployer les fonctions
supabase functions deploy generate-audio
supabase functions deploy stripe-webhook
supabase functions deploy create-checkout-session
supabase functions deploy create-portal-session
```

### Option B: Via Dashboard

1. Allez dans **Edge Functions**
2. Cliquez sur **"New function"**
3. Pour chaque fonction (`generate-audio`, `stripe-webhook`, etc.):
   - Copiez le code depuis `supabase/functions/[nom]/index.ts`
   - Déployez

## Étape 7: Configurer les secrets des Edge Functions

```powershell
# Via CLI
supabase secrets set ELEVENLABS_API_KEY=your_elevenlabs_key
supabase secrets set STRIPE_SECRET_KEY=sk_test_xxx
supabase secrets set STRIPE_WEBHOOK_SECRET=whsec_xxx
```

Ou via Dashboard: **Edge Functions** > **Manage Secrets**

## Étape 8: Mettre à jour le fichier .env

Créez/modifiez le fichier `.env` à la racine du projet:

```env
# Supabase
SUPABASE_URL=https://YOUR_PROJECT.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here

# Stripe (optionnel pour le moment)
STRIPE_PUBLISHABLE_KEY=pk_test_xxx

# Mode
DEMO_MODE=false
```

## Étape 9: Tester la connexion

Lancez l'application en mode production:

```powershell
flutter run -d chrome
```

Vérifiez:
1. ✅ Page de connexion s'affiche
2. ✅ Inscription fonctionne
3. ✅ Connexion fonctionne
4. ✅ Profil utilisateur créé dans Supabase

## 🔧 Dépannage

### Erreur "Invalid API key"
- Vérifiez que `SUPABASE_URL` et `SUPABASE_ANON_KEY` sont corrects
- Pas d'espaces en début/fin des clés

### Erreur "RLS policy violation"
- Vérifiez que les politiques RLS sont bien créées
- L'utilisateur doit être authentifié

### Edge Function ne répond pas
- Vérifiez les logs: **Edge Functions** > **Logs**
- Vérifiez que les secrets sont configurés

---

## ✅ Checklist finale

- [ ] Projet Supabase créé
- [ ] Clés API récupérées
- [ ] Migration SQL exécutée
- [ ] Bucket storage "audio" créé
- [ ] Edge Functions déployées
- [ ] Secrets configurés
- [ ] Fichier .env mis à jour
- [ ] Test de connexion réussi
