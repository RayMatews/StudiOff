import 'dart:html' as html;
import '../models/subscription.dart';
import '../core/config/app_config.dart';
import 'supabase_service.dart';

class StripeService {
  // Create checkout session and redirect to Stripe
  Future<void> createCheckoutSession(SubscriptionPlan plan) async {
    final userId = SupabaseService.userId;
    if (userId == null) throw Exception('User not authenticated');

    final priceId = plan == SubscriptionPlan.starter
        ? AppConfig.starterPriceId
        : AppConfig.proPriceId;

    // Call edge function to create checkout session
    final response = await SupabaseService.functions.invoke(
      'create-checkout-session',
      body: {
        'price_id': priceId,
        'success_url': '${html.window.location.origin}/subscription/success',
        'cancel_url': '${html.window.location.origin}/subscription/cancel',
      },
    );

    if (response.status != 200) {
      throw Exception('Failed to create checkout session');
    }

    final data = response.data as Map<String, dynamic>;
    final checkoutUrl = data['url'] as String;

    // Redirect to Stripe Checkout
    html.window.location.href = checkoutUrl;
  }

  // Open customer portal
  Future<void> openCustomerPortal() async {
    final response = await SupabaseService.functions.invoke(
      'create-portal-session',
      body: {
        'return_url': '${html.window.location.origin}/settings',
      },
    );

    if (response.status != 200) {
      throw Exception('Failed to create portal session');
    }

    final data = response.data as Map<String, dynamic>;
    final portalUrl = data['url'] as String;

    html.window.location.href = portalUrl;
  }

  // Get current subscription
  Future<Subscription?> getCurrentSubscription() async {
    final userId = SupabaseService.userId;
    if (userId == null) return null;

    final response = await SupabaseService.from('subscriptions')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) return null;

    return Subscription.fromJson(_snakeToCamel(response));
  }

  // Check if user has active subscription
  Future<bool> hasActiveSubscription() async {
    final subscription = await getCurrentSubscription();
    return subscription != null &&
        (subscription.status == SubscriptionStatus.active ||
            subscription.status == SubscriptionStatus.trialing);
  }

  // Get available pricing plans (CAD - Canadian Dollars)
  List<PricingPlan> getPricingPlans() {
    return [
      const PricingPlan(
        id: 'starter',
        name: 'Starter',
        description: 'Pour démarrer avec l\'audio marketing',
        priceMonthly: 59,
        minutesIncluded: 30,
        features: [
          '30 minutes d\'audio / mois',
          'Voix FR & EN',
          'Musique libre de droits',
          'Export MP3',
          'Historique 30 jours',
        ],
      ),
      const PricingPlan(
        id: 'pro',
        name: 'Pro',
        description: 'Pour les équipes marketing actives',
        priceMonthly: 179,
        minutesIncluded: 120,
        features: [
          '120 minutes d\'audio / mois',
          'Voix FR & EN premium',
          'Musique libre de droits étendue',
          'Export MP3 & WAV',
          'Historique illimité',
          'Support prioritaire',
        ],
        isPopular: true,
      ),
    ];
  }

  Map<String, dynamic> _snakeToCamel(Map<String, dynamic> map) {
    return map.map((key, value) {
      final camelKey = key.replaceAllMapped(
        RegExp(r'_([a-z])'),
        (match) => match.group(1)!.toUpperCase(),
      );
      return MapEntry(camelKey, value);
    });
  }
}
