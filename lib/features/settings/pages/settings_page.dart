import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/subscription_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../models/subscription.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileNotifierProvider);
    final subscription = ref.watch(subscriptionNotifierProvider);
    final themeMode = ref.watch(themeModeProvider);
    final language = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text('Paramètres'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile section
                _buildSectionTitle(context, 'Profil'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: userProfile.when(
                      data: (profile) => Column(
                        children: [
                          _buildProfileRow(
                            context,
                            icon: Icons.person,
                            label: 'Nom',
                            value: profile?.fullName ?? 'Non renseigné',
                            onEdit: () => _showEditDialog(
                              context,
                              ref,
                              'Modifier le nom',
                              profile?.fullName ?? '',
                              (value) async {
                                await ref
                                    .read(userProfileNotifierProvider.notifier)
                                    .updateProfile(fullName: value);
                              },
                            ),
                          ),
                          const Divider(),
                          _buildProfileRow(
                            context,
                            icon: Icons.email,
                            label: 'Email',
                            value: profile?.email ?? '-',
                          ),
                          const Divider(),
                          _buildProfileRow(
                            context,
                            icon: Icons.toll,
                            label: 'Crédits restants',
                            value: '${profile?.creditsRemaining ?? 0} minutes',
                          ),
                        ],
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (_, _) => const Text('Erreur de chargement'),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Subscription section
                _buildSectionTitle(context, 'Abonnement'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: subscription.when(
                      data: (sub) => Column(
                        children: [
                          _buildProfileRow(
                            context,
                            icon: Icons.card_membership,
                            label: 'Forfait',
                            value: sub?.plan.name ?? 'Aucun abonnement',
                          ),
                          if (sub != null) ...[
                            const Divider(),
                            _buildProfileRow(
                              context,
                              icon: Icons.event,
                              label: 'Prochaine facturation',
                              value: _formatDate(sub.currentPeriodEnd),
                            ),
                            const Divider(),
                            _buildProfileRow(
                              context,
                              icon: Icons.check_circle,
                              label: 'Statut',
                              value: _getStatusText(sub.status),
                              valueColor: _getStatusColor(sub.status),
                            ),
                          ],
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: sub != null
                                ? OutlinedButton.icon(
                                    onPressed: () async {
                                      await ref
                                          .read(
                                            subscriptionNotifierProvider
                                                .notifier,
                                          )
                                          .manageSubscription();
                                    },
                                    icon: const Icon(Icons.settings),
                                    label: const Text('Gérer mon abonnement'),
                                  )
                                : ElevatedButton.icon(
                                    onPressed: () => context.push('/pricing'),
                                    icon: const Icon(Icons.star),
                                    label: const Text('Choisir un forfait'),
                                  ),
                          ),
                        ],
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (_, _) => const Text('Erreur de chargement'),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Preferences section
                _buildSectionTitle(context, 'Préférences'),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.language),
                        title: const Text('Langue par défaut'),
                        subtitle: Text(
                          language == 'fr' ? 'Français' : 'English',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showLanguageDialog(context, ref),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.dark_mode),
                        title: const Text('Thème'),
                        subtitle: Text(_getThemeText(themeMode)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showThemeDialog(context, ref),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Danger zone
                _buildSectionTitle(context, 'Zone de danger'),
                Card(
                  color: AppTheme.errorColor.withValues(alpha: 0.05),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.logout, color: AppTheme.errorColor),
                        title: Text(
                          'Se déconnecter',
                          style: TextStyle(color: AppTheme.errorColor),
                        ),
                        onTap: () => _showLogoutConfirmation(context, ref),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // App info
                Center(
                  child: Column(
                    children: [
                      Text(
                        'StudiOff v1.0.0',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '© 2026 StudiOff. Tous droits réservés.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildProfileRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    VoidCallback? onEdit,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textMuted, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppTheme.textMuted),
                ),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: valueColor),
                ),
              ],
            ),
          ),
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit, size: 18),
              onPressed: onEdit,
              color: AppTheme.primaryColor,
            ),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    String title,
    String initialValue,
    Future<void> Function(String) onSave,
  ) {
    final controller = TextEditingController(text: initialValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nouveau nom'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              await onSave(controller.text);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Se déconnecter ?'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!AppConfig.demoMode) {
                final authService = ref.read(authServiceProvider);
                await authService.signOut();
              }
              if (context.mounted) {
                Navigator.pop(context);
                context.go('/');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getStatusText(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.active:
        return 'Actif';
      case SubscriptionStatus.canceled:
        return 'Annulé';
      case SubscriptionStatus.pastDue:
        return 'Paiement en retard';
      case SubscriptionStatus.trialing:
        return 'Période d\'essai';
      case SubscriptionStatus.incomplete:
        return 'Incomplet';
    }
  }

  Color _getStatusColor(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.active:
      case SubscriptionStatus.trialing:
        return AppTheme.successColor;
      case SubscriptionStatus.canceled:
        return AppTheme.textMuted;
      case SubscriptionStatus.pastDue:
      case SubscriptionStatus.incomplete:
        return AppTheme.errorColor;
    }
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir la langue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Français'),
              leading: const Icon(Icons.language),
              onTap: () async {
                await ref.read(languageProvider.notifier).setLanguage('fr');
                if (context.mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('English'),
              leading: const Icon(Icons.language),
              onTap: () async {
                await ref.read(languageProvider.notifier).setLanguage('en');
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir le thème'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Clair'),
              leading: const Icon(Icons.light_mode),
              onTap: () async {
                await ref
                    .read(themeModeProvider.notifier)
                    .setThemeMode(ThemeMode.light);
                if (context.mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Sombre'),
              leading: const Icon(Icons.dark_mode),
              onTap: () async {
                await ref
                    .read(themeModeProvider.notifier)
                    .setThemeMode(ThemeMode.dark);
                if (context.mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Système'),
              leading: const Icon(Icons.settings_system_daydream),
              onTap: () async {
                await ref
                    .read(themeModeProvider.notifier)
                    .setThemeMode(ThemeMode.system);
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getThemeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Clair';
      case ThemeMode.dark:
        return 'Sombre';
      case ThemeMode.system:
        return 'Système';
    }
  }
}
