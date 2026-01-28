/// User Model - BRD Section 6: Database Entities
///
/// Represents the user entity from the database schema

import 'dart:convert';

/// User subscription tiers
enum SubscriptionTier { free, starter, pro, business }

extension SubscriptionTierX on SubscriptionTier {
  String get displayName {
    switch (this) {
      case SubscriptionTier.free:
        return 'Free';
      case SubscriptionTier.starter:
        return 'Starter';
      case SubscriptionTier.pro:
        return 'Pro';
      case SubscriptionTier.business:
        return 'Business';
    }
  }

  int get monthlyCredits {
    switch (this) {
      case SubscriptionTier.free:
        return 50;
      case SubscriptionTier.starter:
        return 200;
      case SubscriptionTier.pro:
        return 500;
      case SubscriptionTier.business:
        return 2000;
    }
  }

  int get maxBrandKits {
    switch (this) {
      case SubscriptionTier.free:
        return 1;
      case SubscriptionTier.starter:
        return 3;
      case SubscriptionTier.pro:
        return 10;
      case SubscriptionTier.business:
        return -1; // Unlimited
    }
  }

  int get maxSocialAccounts {
    switch (this) {
      case SubscriptionTier.free:
        return 2;
      case SubscriptionTier.starter:
        return 5;
      case SubscriptionTier.pro:
        return 15;
      case SubscriptionTier.business:
        return -1; // Unlimited
    }
  }
}

/// User status
enum UserStatus { active, suspended, deleted }

/// User model
class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? avatarUrl;
  final SubscriptionTier tier;
  final UserStatus status;
  final int creditsRemaining;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final Map<String, dynamic>? preferences;

  const UserModel({
    required this.id,
    required this.email,
    this.name,
    this.avatarUrl,
    this.tier = SubscriptionTier.free,
    this.status = UserStatus.active,
    this.creditsRemaining = 50,
    required this.createdAt,
    this.lastLoginAt,
    this.preferences,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'],
      avatarUrl: json['avatarUrl'],
      tier: SubscriptionTier.values.firstWhere(
        (t) => t.name == json['tier'],
        orElse: () => SubscriptionTier.free,
      ),
      status: UserStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => UserStatus.active,
      ),
      creditsRemaining: json['creditsRemaining'] ?? 50,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.tryParse(json['lastLoginAt'])
          : null,
      preferences: json['preferences'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'avatarUrl': avatarUrl,
    'tier': tier.name,
    'status': status.name,
    'creditsRemaining': creditsRemaining,
    'createdAt': createdAt.toIso8601String(),
    'lastLoginAt': lastLoginAt?.toIso8601String(),
    'preferences': preferences,
  };

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    SubscriptionTier? tier,
    UserStatus? status,
    int? creditsRemaining,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    Map<String, dynamic>? preferences,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      tier: tier ?? this.tier,
      status: status ?? this.status,
      creditsRemaining: creditsRemaining ?? this.creditsRemaining,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      preferences: preferences ?? this.preferences,
    );
  }

  /// Check if user has enough credits
  bool hasCredits(int amount) => creditsRemaining >= amount;

  /// Check if user can add more brand kits
  bool get canAddBrandKit => tier.maxBrandKits == -1 || tier.maxBrandKits > 0;

  /// Check if user can add more social accounts
  bool get canAddSocialAccount =>
      tier.maxSocialAccounts == -1 || tier.maxSocialAccounts > 0;

  /// Serialize to JSON string
  String toJsonString() => jsonEncode(toJson());

  /// Deserialize from JSON string
  factory UserModel.fromJsonString(String json) =>
      UserModel.fromJson(jsonDecode(json));

  /// Create a mock user for MVP
  factory UserModel.mock() => UserModel(
    id: 'mock_user_001',
    email: 'user@lonepengu.com',
    name: 'LonePengu User',
    tier: SubscriptionTier.pro,
    creditsRemaining: 500,
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    lastLoginAt: DateTime.now(),
  );
}
