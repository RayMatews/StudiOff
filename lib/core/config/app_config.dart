/// Application configuration
class AppConfig {
  // Mode démo (pour tester l'UI sans backend)
  // Changez defaultValue à true pour tester sans Supabase
  static const bool demoMode = bool.fromEnvironment(
    'DEMO_MODE',
    defaultValue: false, // <- Désactivé pour utiliser Supabase
  );

  // Supabase
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://ikitxfscycfmocuqjczt.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlraXR4ZnNjeWZtb2N1amN6dCIsInJvbGUiOiJhbm9uIiwiaWF0IjoxNjQ1MTkyMDAwLCJleHAiOjE5NjA3NjgwMDB9.pEUn0RqNqakjT6dT_po9_7NqN9rQqoG8G2zQwGqFkjI',
  );

  // Validate configuration
  static bool get isConfigured =>
      demoMode ||
      (supabaseUrl.isNotEmpty &&
          supabaseAnonKey.isNotEmpty &&
          !supabaseUrl.contains('your-project') &&
          !supabaseUrl.contains('YOUR_PROJECT'));

  static void validateConfig() {
    if (!isConfigured) {
      throw Exception(
        'Configuration manquante!\n\n'
        'Option 1 - Mode démo (sans backend):\n'
        '  flutter run -d chrome --dart-define=DEMO_MODE=true\n\n'
        'Option 2 - Avec Supabase:\n'
        '  Créez un fichier .env et lancez avec:\n'
        '  .\\run_dev.ps1',
      );
    }
  }

  // Stripe
  static const String stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue:
        'pk_live_51SucjKFTUhehIsQTEWA4MTHvJHuojvU1wXqN8rgADy1lkJCgQ5WdscwbZNTJGW2RtJy7MinNmkqAvBFNhZQAGrXX0098SnBlOj',
  );

  // Pricing IDs (Stripe)
  static const String starterPriceId = 'price_1SxYzVFTUhehIsQTXN9A5ack';
  static const String proPriceId = 'price_1SxZ5QFTUhehIsQTjC2qbUBH';

  // Credits
  static const int starterMonthlyMinutes = 30;
  static const int proMonthlyMinutes = 120;
  static const double overageRatePerMinute = 2.0; // $2 per extra minute

  // Audio limits
  static const int maxScriptLength = 5000;
  static const List<int> allowedDurations = [15, 30, 60];

  // API URLs
  static String get generateVoiceUrl =>
      '$supabaseUrl/functions/v1/generate-voice';
  static String get generateMusicUrl =>
      '$supabaseUrl/functions/v1/generate-music';
  static String get mixAudioUrl => '$supabaseUrl/functions/v1/mix-audio';
  static String get stripeWebhookUrl =>
      '$supabaseUrl/functions/v1/stripe-webhook';
}
