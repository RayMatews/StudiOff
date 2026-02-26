import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/audio_provider.dart';
import '../../../providers/subscription_provider.dart';
import '../widgets/stats_card.dart';
import '../widgets/recent_audio_card.dart';
import '../widgets/quick_actions.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileNotifierProvider);
    final projects = ref.watch(audioProjectsProvider);
    final subscription = ref.watch(subscriptionNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.graphic_eq, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
            const Text('StudiOff'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.push('/history'),
            tooltip: 'Historique',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
            tooltip: 'Paramètres',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome header
                userProfile.when(
                  data: (profile) => Text(
                    'Bonjour${profile?.fullName != null ? ", ${profile!.fullName}" : ""} 👋',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 8),
                Text(
                  'Créez des spots audio professionnels en quelques clics.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 32),

                // Stats cards
                subscription.when(
                  data: (sub) => Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      StatsCard(
                        title: 'Crédits restants',
                        value: userProfile.maybeWhen(
                          data: (p) => '${p?.creditsRemaining ?? 0} min',
                          orElse: () => '- min',
                        ),
                        icon: Icons.timer,
                        color: AppTheme.primaryColor,
                      ),
                      StatsCard(
                        title: 'Audios ce mois',
                        value: projects.maybeWhen(
                          data: (p) => '${p.length}',
                          orElse: () => '-',
                        ),
                        icon: Icons.graphic_eq,
                        color: AppTheme.secondaryColor,
                      ),
                      StatsCard(
                        title: 'Abonnement',
                        value: sub?.plan.name ?? 'Aucun',
                        icon: Icons.card_membership,
                        color: AppTheme.accentColor,
                        onTap: () => context.push('/pricing'),
                      ),
                    ],
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 32),

                // Quick actions
                const QuickActions(),
                const SizedBox(height: 32),

                // Recent audio section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Derniers audios',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    TextButton.icon(
                      onPressed: () => context.push('/history'),
                      icon: const Icon(Icons.arrow_forward, size: 18),
                      label: const Text('Voir tout'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                projects.when(
                  data: (projectList) {
                    if (projectList.isEmpty) {
                      return _buildEmptyState(context);
                    }
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: projectList
                          .take(6)
                          .map((project) => RecentAudioCard(project: project))
                          .toList(),
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (error, _) => Center(
                    child: Text('Erreur: $error'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/generate'),
        icon: const Icon(Icons.add),
        label: const Text('Nouvel audio'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(
              Icons.music_note,
              size: 64,
              color: AppTheme.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun audio pour le moment',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Créez votre premier spot audio marketing en quelques clics !',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textMuted,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/generate'),
              icon: const Icon(Icons.add),
              label: const Text('Créer mon premier audio'),
            ),
          ],
        ),
      ),
    );
  }
}
