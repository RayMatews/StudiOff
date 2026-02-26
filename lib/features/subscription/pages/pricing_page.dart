import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/subscription_provider.dart';
import '../../../models/subscription.dart';

class PricingPage extends ConsumerWidget {
  const PricingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(pricingPlansProvider);
    final currentSubscription = ref.watch(subscriptionNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: const Text('Tarifs'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              children: [
                // Header
                Text(
                  'Choisissez votre forfait',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tarifs simples et transparents. Sans engagement.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Pricing cards
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: plans.map((plan) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: _PricingCard(
                          plan: plan,
                          currentSubscription: currentSubscription.valueOrNull,
                          onSubscribe: () async {
                            try {
                              await ref
                                  .read(subscriptionNotifierProvider.notifier)
                                  .subscribe(
                                    plan.id == 'starter'
                                        ? SubscriptionPlan.starter
                                        : SubscriptionPlan.pro,
                                  );
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Erreur: $e'),
                                    backgroundColor: AppTheme.errorColor,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 48),

                // Features comparison
                _buildFeaturesComparison(context),
                const SizedBox(height: 48),

                // FAQ
                _buildFAQ(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesComparison(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Toutes les fonctionnalités incluses',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 32,
              runSpacing: 16,
              children: [
                _buildFeatureItem(context, Icons.record_voice_over, 'Voix IA FR & EN'),
                _buildFeatureItem(context, Icons.library_music, 'Musique libre de droits'),
                _buildFeatureItem(context, Icons.auto_fix_high, 'Mix automatique'),
                _buildFeatureItem(context, Icons.download, 'Export MP3 & WAV'),
                _buildFeatureItem(context, Icons.history, 'Historique complet'),
                _buildFeatureItem(context, Icons.speed, 'Génération < 5 min'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String text) {
    return SizedBox(
      width: 200,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.successColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQ(BuildContext context) {
    final faqs = [
      {
        'question': 'Puis-je annuler à tout moment ?',
        'answer': 'Oui, vous pouvez annuler votre abonnement à tout moment. Vous conservez l\'accès jusqu\'à la fin de votre période de facturation.',
      },
      {
        'question': 'Que se passe-t-il si je dépasse mon quota ?',
        'answer': 'Vous pouvez acheter des crédits supplémentaires à 3\$/minute (CAD) ou passer au forfait supérieur.',
      },
      {
        'question': 'Les musiques sont-elles libres de droits ?',
        'answer': 'Oui, toutes les musiques sont licenciées pour un usage marketing et publicitaire. Vous pouvez diffuser vos spots partout.',
      },
      {
        'question': 'Puis-je utiliser les audios à des fins commerciales ?',
        'answer': 'Absolument ! Tous les audios générés sont destinés à un usage marketing et commercial.',
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Questions fréquentes',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...faqs.map((faq) => ExpansionTile(
                  title: Text(
                    faq['question']!,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        faq['answer']!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}

class _PricingCard extends StatelessWidget {
  final PricingPlan plan;
  final Subscription? currentSubscription;
  final VoidCallback onSubscribe;

  const _PricingCard({
    required this.plan,
    required this.currentSubscription,
    required this.onSubscribe,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrentPlan = currentSubscription?.plan.name.toLowerCase() == plan.id;

    return Card(
      color: plan.isPopular ? AppTheme.primaryColor.withValues(alpha: 0.05) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: plan.isPopular ? AppTheme.primaryColor : AppTheme.borderColor,
          width: plan.isPopular ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Popular badge
            if (plan.isPopular) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Le plus populaire',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Plan name
            Text(
              plan.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              plan.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 24),

            // Price (CAD)
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${plan.priceMonthly.toInt()}\$ CAD',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, left: 4),
                  child: Text(
                    '/mois',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textMuted,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Features list
            ...plan.features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppTheme.successColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          feature,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 24),

            // CTA button
            SizedBox(
              width: double.infinity,
              child: isCurrentPlan
                  ? OutlinedButton(
                      onPressed: null,
                      child: const Text('Forfait actuel'),
                    )
                  : ElevatedButton(
                      onPressed: onSubscribe,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: plan.isPopular ? AppTheme.primaryColor : null,
                      ),
                      child: Text(
                        currentSubscription != null ? 'Changer de forfait' : 'Commencer',
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
