import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/app_config.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';
import '../models/user_profile.dart';

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// Auth state provider
final authStateProvider = StreamProvider<AuthState?>((ref) {
  if (AppConfig.demoMode) {
    // En mode démo, retourner un stream vide
    return const Stream.empty();
  }
  return SupabaseService.auth.onAuthStateChange;
});

// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  if (AppConfig.demoMode) return null;
  ref.watch(authStateProvider);
  return SupabaseService.currentUser;
});

// Is authenticated provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  if (AppConfig.demoMode) return true; // Toujours "connecté" en mode démo
  return ref.watch(currentUserProvider) != null;
});

// User profile provider
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  if (AppConfig.demoMode) {
    return _demoUserProfile;
  }
  
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final response = await SupabaseService.from('profiles')
      .select()
      .eq('id', user.id)
      .maybeSingle();

  if (response == null) return null;

  return UserProfile.fromJson(_snakeToCamel(response));
});

// User profile notifier for mutations
class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  final Ref ref;

  UserProfileNotifier(this.ref) : super(const AsyncLoading()) {
    _init();
  }

  Future<void> _init() async {
    if (AppConfig.demoMode) {
      state = AsyncData(_demoUserProfile);
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) {
      state = const AsyncData(null);
      return;
    }

    try {
      final response = await SupabaseService.from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) {
        state = const AsyncData(null);
        return;
      }

      state = AsyncData(UserProfile.fromJson(_snakeToCamel(response)));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    await _init();
  }

  Future<void> updateProfile({String? fullName}) async {
    if (AppConfig.demoMode) {
      // Simuler la mise à jour en mode démo
      await Future.delayed(const Duration(milliseconds: 500));
      state = AsyncData(_demoUserProfile.copyWith(fullName: fullName));
      return;
    }

    final user = SupabaseService.currentUser;
    if (user == null) return;

    await SupabaseService.from('profiles')
        .update({
          'full_name': fullName,
          'updated_at': DateTime.now().toIso8601String()
        })
        .eq('id', user.id);

    await refresh();
  }
}

final userProfileNotifierProvider =
    StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfile?>>((ref) {
  return UserProfileNotifier(ref);
});

Map<String, dynamic> _snakeToCamel(Map<String, dynamic> map) {
  return map.map((key, value) {
    final camelKey = key.replaceAllMapped(
      RegExp(r'_([a-z])'),
      (match) => match.group(1)!.toUpperCase(),
    );
    return MapEntry(camelKey, value);
  });
}

// Demo user profile for testing UI
final _demoUserProfile = UserProfile(
  id: 'demo-user-id',
  email: 'demo@studioff.com',
  fullName: 'Utilisateur Démo',
  creditsRemaining: 45,
  creditsUsedThisMonth: 15,
  subscriptionPlan: 'starter',
  subscriptionStatus: 'active',
  createdAt: DateTime.now().subtract(const Duration(days: 30)),
);
