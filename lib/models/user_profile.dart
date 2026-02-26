class UserProfile {
  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final int creditsRemaining;
  final int creditsUsedThisMonth;
  final String? subscriptionId;
  final String? subscriptionStatus;
  final String? subscriptionPlan;
  final DateTime? subscriptionEndDate;
  final String preferredLanguage;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.creditsRemaining = 0,
    this.creditsUsedThisMonth = 0,
    this.subscriptionId,
    this.subscriptionStatus,
    this.subscriptionPlan,
    this.subscriptionEndDate,
    this.preferredLanguage = 'fr',
    required this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      creditsRemaining: json['creditsRemaining'] as int? ?? 0,
      creditsUsedThisMonth: json['creditsUsedThisMonth'] as int? ?? 0,
      subscriptionId: json['subscriptionId'] as String?,
      subscriptionStatus: json['subscriptionStatus'] as String?,
      subscriptionPlan: json['subscriptionPlan'] as String?,
      subscriptionEndDate: json['subscriptionEndDate'] != null
          ? DateTime.parse(json['subscriptionEndDate'] as String)
          : null,
      preferredLanguage: json['preferredLanguage'] as String? ?? 'fr',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'avatarUrl': avatarUrl,
      'creditsRemaining': creditsRemaining,
      'creditsUsedThisMonth': creditsUsedThisMonth,
      'subscriptionId': subscriptionId,
      'subscriptionStatus': subscriptionStatus,
      'subscriptionPlan': subscriptionPlan,
      'subscriptionEndDate': subscriptionEndDate?.toIso8601String(),
      'preferredLanguage': preferredLanguage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    int? creditsRemaining,
    int? creditsUsedThisMonth,
    String? subscriptionId,
    String? subscriptionStatus,
    String? subscriptionPlan,
    DateTime? subscriptionEndDate,
    String? preferredLanguage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      creditsRemaining: creditsRemaining ?? this.creditsRemaining,
      creditsUsedThisMonth: creditsUsedThisMonth ?? this.creditsUsedThisMonth,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      subscriptionEndDate: subscriptionEndDate ?? this.subscriptionEndDate,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
