# StudiOff - Guide de Déploiement Vercel

## Prérequis

1. **Compte GitHub** - Créez un compte sur [github.com](https://github.com)
2. **Compte Vercel** - Créez un compte sur [vercel.com](https://vercel.com)
3. **GitHub CLI** (optionnel) - Pour pousser le code depuis le terminal

## Architecture

```
┌─────────────────────────────────────────────────┐
│                   Vercel                        │
│              (Fichiers statiques)               │
│            https://studioff.vercel.app         │
└─────────────────────┬───────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────┐
│              Supabase Cloud                    │
│  ┌─────────────┐  ┌──────────────────────────┐ │
│  │  Database   │  │    Edge Functions        │ │
│  │  PostgreSQL │  │  - generate-audio        │ │
│  │             │  │  - create-checkout       │ │
│  └─────────────┘  │  - stripe-webhook        │ │
│                   └──────────────────────────┘ │
└─────────────────────┬───────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────┐
│                   Stripe                        │
│              (Paiements)                        │
└─────────────────────────────────────────────────┘
```

## Options de Déploiement

### Option 1: GitHub + Vercel (Automatique) - RECOMMANDÉ

1. **Poussez le code vers GitHub** (incluant le dossier `build/web`)
   
```
bash
git add .
git commit -m "Add Vercel config and build"
git push origin main
```

2. **Connectez Vercel à GitHub**
   - Allez sur [vercel.com](https://vercel.com)
   - Cliquez sur "Add New..." → "Project"
   - Importez votre dépôt GitHub

3. **Configuration Project Settings:**
   - Framework Preset: **Other** (ou Static)
   - Output Directory: `build/web`
   - Build Command: (laisser vide)

4. **Déployez**
   - Cliquez "Deploy"
   - ✅ Terminé!

### Option 2: Vercel CLI (Manuel)

1. **Installez Vercel CLI**
```
bash
npm install -g vercel
```

2. **Connectez-vous**
```
bash
vercel login
```

3. **Déployez depuis le dossier du projet**
```
bash
vercel --prod
```

### Option 3: GitHub Actions (CI/CD Automatique)

Le fichier `.github/workflows/deploy.yml` est déjà configuré!

1. **Configurer les secrets GitHub:**
   - `VERCEL_TOKEN` - Token Vercel
   - `VERCEL_ORG_ID` - Organisation ID
   - `VERCEL_PROJECT_ID` - Project ID

2. **Poussez vers main** - Le déploiement se fait automatiquement!

## Déploiement des Edge Functions Supabase

Les Edge Functions doivent être déployées séparément:

```
bash
# Installez Supabase CLI
npm install -g supabase

# Connectez-vous
supabase login

# Linkez votre projet
supabase link --project-ref ikitxfscycfmocuqjczt

# Déployez les fonctions
supabase functions deploy generate-audio
supabase functions deploy create-checkout-session
supabase functions deploy create-portal-session
supabase functions deploy stripe-webhook
```

## Vérification du Déploiement

1. **Frontend**: Ouvrez votre URL Vercel
2. **Testez**: L'application devrait charger avec:
   - Login/Inscription
   - Dashboard
   - Génération audio
   - Abonnements Stripe

## Configuration Actuelle

L'application est pré-configurée avec:

| Service | URL/Clé |
|---------|---------|
| Supabase URL | `https://ikitxfscycfmocuqjczt.supabase.co` |
| Supabase Key | Configurée dans le code |
| Stripe Key | Configurée dans le code |

## Dépannage

### Erreur 404
- Vérifiez que `outputDirectory` est `build/web`
- Le fichier `vercel.json` gère le routage SPA

### Erreur CORS
- Configurez les headers CORS dans Supabase Dashboard

### Build non trouvé
- Assurez-vous que `build/web` existe et contient `index.html`

## Ressources

- [Documentation Vercel](https://vercel.com/docs)
- [Supabase Edge Functions](https://supabase.com/docs/guides/functions)
- [Stripe Webhooks](https://dashboard.stripe.com/webhooks)
