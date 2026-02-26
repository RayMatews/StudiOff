import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/app_config.dart';
import 'supabase_service.dart';

class AuthService {
  GoTrueClient get _auth {
    if (AppConfig.demoMode) {
      throw Exception('AuthService not available in demo mode');
    }
    return SupabaseService.auth;
  }

  // Sign up with email
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    final response = await _auth.signUp(
      email: email,
      password: password,
      data: fullName != null ? {'full_name': fullName} : null,
    );
    return response;
  }

  // Sign in with email
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  // Sign in with magic link
  Future<void> signInWithMagicLink({required String email}) async {
    await _auth.signInWithOtp(
      email: email,
      emailRedirectTo: null, // Will use default redirect
    );
  }

  // Sign in with OAuth (Google)
  Future<bool> signInWithGoogle() async {
    final response = await _auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: null,
    );
    return response;
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Password reset
  Future<void> resetPassword({required String email}) async {
    await _auth.resetPasswordForEmail(email);
  }

  // Update password
  Future<UserResponse> updatePassword({required String newPassword}) async {
    return await _auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  // Update user profile
  Future<UserResponse> updateProfile({
    String? email,
    String? fullName,
  }) async {
    return await _auth.updateUser(
      UserAttributes(
        email: email,
        data: fullName != null ? {'full_name': fullName} : null,
      ),
    );
  }

  // Get current session
  Session? get currentSession => _auth.currentSession;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream auth state changes
  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;
}
