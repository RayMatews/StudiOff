/// Application constants
class AppConstants {
  // App info
  static const String appName = 'StudiOff';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Transform your marketing text into professional audio spots';

  // Languages
  static const List<String> supportedLanguages = ['fr', 'en'];
  static const Map<String, String> languageNames = {
    'fr': 'Français',
    'en': 'English',
  };

  // Voice types
  static const List<String> voiceGenders = ['male', 'female'];
  static const Map<String, String> voiceGenderNames = {
    'male': 'Homme',
    'female': 'Femme',
  };

  // Tones
  static const List<String> tones = ['neutral', 'dynamic', 'institutional'];
  static const Map<String, String> toneNames = {
    'neutral': 'Neutre',
    'dynamic': 'Dynamique',
    'institutional': 'Institutionnel',
  };

  // Music styles
  static const List<String> musicStyles = ['corporate', 'modern', 'calm', 'energetic'];
  static const Map<String, String> musicStyleNames = {
    'corporate': 'Corporate',
    'modern': 'Moderne',
    'calm': 'Calme',
    'energetic': 'Énergique',
  };

  // Duration options (in seconds)
  static const List<int> durations = [15, 30, 60];
  static const Map<int, String> durationNames = {
    15: '15 secondes',
    30: '30 secondes',
    60: '60 secondes',
  };

  // Audio formats
  static const List<String> outputFormats = ['mp3', 'wav'];

  // Storage paths
  static const String voiceStoragePath = 'voices';
  static const String musicStoragePath = 'music';
  static const String outputStoragePath = 'outputs';
  
  // Script limits
  static const int maxScriptLength = 5000;
  static const int minScriptLength = 10;
}
