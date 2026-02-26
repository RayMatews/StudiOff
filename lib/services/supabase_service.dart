import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/app_config.dart';

class SupabaseService {
  static SupabaseClient? _client;

  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return _client!;
  }

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }

  // Auth shortcuts
  static GoTrueClient get auth => client.auth;
  static User? get currentUser => auth.currentUser;
  static bool get isAuthenticated => currentUser != null;
  static String? get userId => currentUser?.id;

  // Database shortcuts
  static SupabaseQueryBuilder from(String table) => client.from(table);

  // Storage shortcuts
  static SupabaseStorageClient get storage => client.storage;

  // Functions shortcuts
  static FunctionsClient get functions => client.functions;
}
