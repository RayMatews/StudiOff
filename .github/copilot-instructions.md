# StudiOff - Audio Marketing SaaS MVP

## Project Overview
B2B SaaS platform that transforms marketing text into professional audio spots in < 5 minutes.

## Tech Stack
- **Frontend**: Flutter Web
- **Backend**: Supabase (Auth, Database, Edge Functions, Storage)
- **TTS**: ElevenLabs API (or alternative)
- **Music**: AI-generated or licensed catalog
- **Payments**: Stripe (subscriptions + credits)

## Architecture

### Frontend Structure
```
lib/
├── main.dart                 # App entry point
├── app/
│   ├── app.dart             # Main app widget
│   └── router.dart          # GoRouter configuration
├── core/
│   ├── config/              # App configuration
│   ├── constants/           # App constants
│   ├── theme/               # Theme data
│   └── utils/               # Utilities
├── features/
│   ├── auth/                # Authentication
│   ├── dashboard/           # User dashboard
│   ├── audio_generator/     # Audio creation
│   ├── history/             # Audio history
│   ├── subscription/        # Stripe payments
│   └── settings/            # User settings
├── models/                  # Data models
├── providers/               # Riverpod providers
└── services/                # API services
```

### Database Schema (Supabase)
- `profiles` - User profiles with credits
- `audio_projects` - Generated audio projects
- `subscriptions` - Stripe subscription data
- `usage_logs` - Credit usage tracking

### Edge Functions
- `generate-voice` - TTS generation
- `generate-music` - Background music
- `mix-audio` - Final audio mixing
- `stripe-webhook` - Payment webhooks

## Key Features
1. Text input with voice/music options
2. AI voice generation (FR/EN)
3. Background music selection
4. Automatic audio mixing
5. MP3/WAV download
6. Credit-based billing

## Commands
- `flutter run -d chrome` - Run web app
- `flutter build web` - Build for production
- `supabase start` - Start local Supabase
- `supabase functions serve` - Test Edge Functions

## Environment Variables
Create `.env` file:
```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
STRIPE_PUBLISHABLE_KEY=your_stripe_key
ELEVENLABS_API_KEY=your_elevenlabs_key
```
