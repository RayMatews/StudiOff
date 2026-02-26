import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../features/auth/pages/login_page.dart';
import '../features/auth/pages/signup_page.dart';
import '../features/auth/pages/forgot_password_page.dart';
import '../features/dashboard/pages/dashboard_page.dart';
import '../features/audio_generator/pages/audio_generator_page.dart';
import '../features/history/pages/history_page.dart';
import '../features/history/pages/audio_detail_page.dart';
import '../features/subscription/pages/pricing_page.dart';
import '../features/subscription/pages/subscription_success_page.dart';
import '../features/settings/pages/settings_page.dart';
import '../features/landing/pages/landing_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final path = state.uri.path;
      final publicRoutes = ['/', '/login', '/signup', '/forgot-password', '/pricing'];
      
      // Allow public routes
      if (publicRoutes.contains(path)) {
        // Redirect to dashboard if already authenticated and trying to access auth pages
        if (isAuthenticated && ['/login', '/signup'].contains(path)) {
          return '/dashboard';
        }
        return null;
      }

      // Require authentication for protected routes
      if (!isAuthenticated) {
        return '/login';
      }

      return null;
    },
    routes: [
      // Public routes
      GoRoute(
        path: '/',
        name: 'landing',
        builder: (context, state) => const LandingPage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/pricing',
        name: 'pricing',
        builder: (context, state) => const PricingPage(),
      ),

      // Protected routes
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/generate',
        name: 'generate',
        builder: (context, state) => const AudioGeneratorPage(),
      ),
      GoRoute(
        path: '/history',
        name: 'history',
        builder: (context, state) => const HistoryPage(),
      ),
      GoRoute(
        path: '/audio/:id',
        name: 'audioDetail',
        builder: (context, state) {
          final projectId = state.pathParameters['id']!;
          return AudioDetailPage(projectId: projectId);
        },
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/subscription/success',
        name: 'subscriptionSuccess',
        builder: (context, state) => const SubscriptionSuccessPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page non trouvée',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.path,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    ),
  );
});
