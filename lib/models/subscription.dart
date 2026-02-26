enum SubscriptionPlan {
  starter,
  pro,
}

enum SubscriptionStatus {
  active,
  canceled,
  pastDue,
  trialing,
  incomplete,
}

class Subscription {
  final String id;
  final String userId;
  final String stripeCustomerId;
  final String stripeSubscriptionId;
  final SubscriptionPlan plan;
  final SubscriptionStatus status;
  final int monthlyMinutes;
  final DateTime currentPeriodStart;
  final DateTime currentPeriodEnd;
  final DateTime? canceledAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Subscription({
    required this.id,
    required this.userId,
    required this.stripeCustomerId,
    required this.stripeSubscriptionId,
    required this.plan,
    required this.status,
    required this.monthlyMinutes,
    required this.currentPeriodStart,
    required this.currentPeriodEnd,
    this.canceledAt,
    required this.createdAt,
    this.updatedAt,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as String,
      userId: json['userId'] as String,
      stripeCustomerId: json['stripeCustomerId'] as String,
      stripeSubscriptionId: json['stripeSubscriptionId'] as String,
      plan: _parsePlan(json['plan'] as String),
      status: _parseStatus(json['status'] as String),
      monthlyMinutes: json['monthlyMinutes'] as int,
      currentPeriodStart: DateTime.parse(json['currentPeriodStart'] as String),
      currentPeriodEnd: DateTime.parse(json['currentPeriodEnd'] as String),
      canceledAt: json['canceledAt'] != null
          ? DateTime.parse(json['canceledAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'stripeCustomerId': stripeCustomerId,
      'stripeSubscriptionId': stripeSubscriptionId,
      'plan': plan.name,
      'status': status.name,
      'monthlyMinutes': monthlyMinutes,
      'currentPeriodStart': currentPeriodStart.toIso8601String(),
      'currentPeriodEnd': currentPeriodEnd.toIso8601String(),
      'canceledAt': canceledAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  static SubscriptionPlan _parsePlan(String plan) {
    switch (plan) {
      case 'pro':
        return SubscriptionPlan.pro;
      default:
        return SubscriptionPlan.starter;
    }
  }

  static SubscriptionStatus _parseStatus(String status) {
    switch (status) {
      case 'active':
        return SubscriptionStatus.active;
      case 'canceled':
        return SubscriptionStatus.canceled;
      case 'past_due':
        return SubscriptionStatus.pastDue;
      case 'trialing':
        return SubscriptionStatus.trialing;
      case 'incomplete':
        return SubscriptionStatus.incomplete;
      default:
        return SubscriptionStatus.incomplete;
    }
  }

  Subscription copyWith({
    String? id,
    String? userId,
    String? stripeCustomerId,
    String? stripeSubscriptionId,
    SubscriptionPlan? plan,
    SubscriptionStatus? status,
    int? monthlyMinutes,
    DateTime? currentPeriodStart,
    DateTime? currentPeriodEnd,
    DateTime? canceledAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Subscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      stripeCustomerId: stripeCustomerId ?? this.stripeCustomerId,
      stripeSubscriptionId: stripeSubscriptionId ?? this.stripeSubscriptionId,
      plan: plan ?? this.plan,
      status: status ?? this.status,
      monthlyMinutes: monthlyMinutes ?? this.monthlyMinutes,
      currentPeriodStart: currentPeriodStart ?? this.currentPeriodStart,
      currentPeriodEnd: currentPeriodEnd ?? this.currentPeriodEnd,
      canceledAt: canceledAt ?? this.canceledAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PricingPlan {
  final String id;
  final String name;
  final String description;
  final double priceMonthly;
  final int minutesIncluded;
  final List<String> features;
  final bool isPopular;

  const PricingPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.priceMonthly,
    required this.minutesIncluded,
    required this.features,
    this.isPopular = false,
  });

  factory PricingPlan.fromJson(Map<String, dynamic> json) {
    return PricingPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      priceMonthly: (json['priceMonthly'] as num).toDouble(),
      minutesIncluded: json['minutesIncluded'] as int,
      features: (json['features'] as List).cast<String>(),
      isPopular: json['isPopular'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'priceMonthly': priceMonthly,
      'minutesIncluded': minutesIncluded,
      'features': features,
      'isPopular': isPopular,
    };
  }

  PricingPlan copyWith({
    String? id,
    String? name,
    String? description,
    double? priceMonthly,
    int? minutesIncluded,
    List<String>? features,
    bool? isPopular,
  }) {
    return PricingPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      priceMonthly: priceMonthly ?? this.priceMonthly,
      minutesIncluded: minutesIncluded ?? this.minutesIncluded,
      features: features ?? this.features,
      isPopular: isPopular ?? this.isPopular,
    );
  }
}
