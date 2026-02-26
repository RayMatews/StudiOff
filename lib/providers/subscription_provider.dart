import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/app_config.dart';
import '../services/stripe_service.dart';
import '../models/subscription.dart';

// Stripe service provider
final stripeServiceProvider = Provider<StripeService>((ref) => StripeService());

// Demo subscription for testing
final _demoSubscription = Subscription(
  id: 'sub_demo',
  userId: 'demo-user',
  stripeSubscriptionId: 'sub_stripe_demo',
  stripeCustomerId: 'cus_demo',
  plan: SubscriptionPlan.starter,
  status: SubscriptionStatus.active,
  monthlyMinutes: 30,
  currentPeriodStart: DateTime.now().subtract(const Duration(days: 15)),
  currentPeriodEnd: DateTime.now().add(const Duration(days: 15)),
  createdAt: DateTime.now().subtract(const Duration(days: 45)),
);

// Current subscription provider
class SubscriptionNotifier extends StateNotifier<AsyncValue<Subscription?>> {
  final Ref ref;

  SubscriptionNotifier(this.ref) : super(const AsyncLoading()) {
    _init();
  }

  Future<void> _init() async {
    if (AppConfig.demoMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      state = AsyncData(_demoSubscription);
      return;
    }

    try {
      final stripeService = ref.read(stripeServiceProvider);
      final subscription = await stripeService.getCurrentSubscription();
      state = AsyncData(subscription);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    await _init();
  }

  Future<void> subscribe(SubscriptionPlan plan) async {
    if (AppConfig.demoMode) {
      // En mode démo, simuler un changement de plan
      await Future.delayed(const Duration(seconds: 1));
      state = AsyncData(_demoSubscription.copyWith(plan: plan));
      return;
    }

    final stripeService = ref.read(stripeServiceProvider);
    await stripeService.createCheckoutSession(plan);
  }

  Future<void> manageSubscription() async {
    if (AppConfig.demoMode) {
      // En mode démo, juste afficher un message
      return;
    }

    final stripeService = ref.read(stripeServiceProvider);
    await stripeService.openCustomerPortal();
  }
}

final subscriptionNotifierProvider =
    StateNotifierProvider<SubscriptionNotifier, AsyncValue<Subscription?>>((ref) {
  return SubscriptionNotifier(ref);
});

// Has active subscription provider
final hasActiveSubscriptionProvider = FutureProvider<bool>((ref) async {
  final subscriptionState = ref.watch(subscriptionNotifierProvider);
  return subscriptionState.maybeWhen(
    data: (subscription) =>
        subscription != null &&
        (subscription.status == SubscriptionStatus.active ||
            subscription.status == SubscriptionStatus.trialing),
    orElse: () => false,
  );
});

// Pricing plans provider
final pricingPlansProvider = Provider<List<PricingPlan>>((ref) {
  final stripeService = ref.read(stripeServiceProvider);
  return stripeService.getPricingPlans();
});
