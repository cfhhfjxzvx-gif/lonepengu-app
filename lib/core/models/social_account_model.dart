/// Social Account Model - BRD Section 6: Database Entities
///
/// Represents connected social media accounts from the database schema

import 'dart:convert';

/// Supported social platforms
enum SocialPlatform { instagram, facebook, linkedin, x, tiktok, youtube }

extension SocialPlatformX on SocialPlatform {
  String get displayName {
    switch (this) {
      case SocialPlatform.instagram:
        return 'Instagram';
      case SocialPlatform.facebook:
        return 'Facebook';
      case SocialPlatform.linkedin:
        return 'LinkedIn';
      case SocialPlatform.x:
        return 'X';
      case SocialPlatform.tiktok:
        return 'TikTok';
      case SocialPlatform.youtube:
        return 'YouTube';
    }
  }

  String get icon {
    switch (this) {
      case SocialPlatform.instagram:
        return '📷';
      case SocialPlatform.facebook:
        return '📘';
      case SocialPlatform.linkedin:
        return '💼';
      case SocialPlatform.x:
        return '𝕏';
      case SocialPlatform.tiktok:
        return '🎵';
      case SocialPlatform.youtube:
        return '📺';
    }
  }

  int get colorValue {
    switch (this) {
      case SocialPlatform.instagram:
        return 0xFFE4405F;
      case SocialPlatform.facebook:
        return 0xFF1877F2;
      case SocialPlatform.linkedin:
        return 0xFF0A66C2;
      case SocialPlatform.x:
        return 0xFF1A1A2E;
      case SocialPlatform.tiktok:
        return 0xFF010101;
      case SocialPlatform.youtube:
        return 0xFFFF0000;
    }
  }

  int get maxCaptionLength {
    switch (this) {
      case SocialPlatform.instagram:
        return 2200;
      case SocialPlatform.facebook:
        return 63206;
      case SocialPlatform.linkedin:
        return 3000;
      case SocialPlatform.x:
        return 280;
      case SocialPlatform.tiktok:
        return 4000;
      case SocialPlatform.youtube:
        return 5000;
    }
  }

  List<String> get supportedMediaTypes {
    switch (this) {
      case SocialPlatform.instagram:
        return ['image', 'video', 'carousel', 'reel', 'story'];
      case SocialPlatform.facebook:
        return ['image', 'video', 'carousel', 'story', 'reel'];
      case SocialPlatform.linkedin:
        return ['image', 'video', 'carousel', 'article'];
      case SocialPlatform.x:
        return ['image', 'video', 'gif'];
      case SocialPlatform.tiktok:
        return ['video'];
      case SocialPlatform.youtube:
        return ['video', 'short'];
    }
  }
}

/// Account connection status
enum ConnectionStatus { connected, expired, revoked, error }

extension ConnectionStatusX on ConnectionStatus {
  String get displayName {
    switch (this) {
      case ConnectionStatus.connected:
        return 'Connected';
      case ConnectionStatus.expired:
        return 'Token Expired';
      case ConnectionStatus.revoked:
        return 'Access Revoked';
      case ConnectionStatus.error:
        return 'Connection Error';
    }
  }

  bool get isActive => this == ConnectionStatus.connected;
}

/// Social account model
class SocialAccountModel {
  final String id;
  final String userId;
  final SocialPlatform platform;
  final String platformUserId;
  final String username;
  final String? displayName;
  final String? profileImageUrl;
  final ConnectionStatus status;
  final String? accessToken;
  final String? refreshToken;
  final DateTime? tokenExpiresAt;
  final List<String> permissions;
  final DateTime connectedAt;
  final DateTime? lastSyncAt;
  final Map<String, dynamic>? metadata;

  const SocialAccountModel({
    required this.id,
    required this.userId,
    required this.platform,
    required this.platformUserId,
    required this.username,
    this.displayName,
    this.profileImageUrl,
    this.status = ConnectionStatus.connected,
    this.accessToken,
    this.refreshToken,
    this.tokenExpiresAt,
    this.permissions = const [],
    required this.connectedAt,
    this.lastSyncAt,
    this.metadata,
  });

  factory SocialAccountModel.fromJson(Map<String, dynamic> json) {
    return SocialAccountModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      platform: SocialPlatform.values.firstWhere(
        (p) => p.name == json['platform'],
        orElse: () => SocialPlatform.instagram,
      ),
      platformUserId: json['platformUserId'] ?? '',
      username: json['username'] ?? '',
      displayName: json['displayName'],
      profileImageUrl: json['profileImageUrl'],
      status: ConnectionStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => ConnectionStatus.connected,
      ),
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      tokenExpiresAt: json['tokenExpiresAt'] != null
          ? DateTime.tryParse(json['tokenExpiresAt'])
          : null,
      permissions: List<String>.from(json['permissions'] ?? []),
      connectedAt:
          DateTime.tryParse(json['connectedAt'] ?? '') ?? DateTime.now(),
      lastSyncAt: json['lastSyncAt'] != null
          ? DateTime.tryParse(json['lastSyncAt'])
          : null,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'platform': platform.name,
    'platformUserId': platformUserId,
    'username': username,
    'displayName': displayName,
    'profileImageUrl': profileImageUrl,
    'status': status.name,
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'tokenExpiresAt': tokenExpiresAt?.toIso8601String(),
    'permissions': permissions,
    'connectedAt': connectedAt.toIso8601String(),
    'lastSyncAt': lastSyncAt?.toIso8601String(),
    'metadata': metadata,
  };

  SocialAccountModel copyWith({
    String? id,
    String? userId,
    SocialPlatform? platform,
    String? platformUserId,
    String? username,
    String? displayName,
    String? profileImageUrl,
    ConnectionStatus? status,
    String? accessToken,
    String? refreshToken,
    DateTime? tokenExpiresAt,
    List<String>? permissions,
    DateTime? connectedAt,
    DateTime? lastSyncAt,
    Map<String, dynamic>? metadata,
  }) {
    return SocialAccountModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      platform: platform ?? this.platform,
      platformUserId: platformUserId ?? this.platformUserId,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      status: status ?? this.status,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenExpiresAt: tokenExpiresAt ?? this.tokenExpiresAt,
      permissions: permissions ?? this.permissions,
      connectedAt: connectedAt ?? this.connectedAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Check if token needs refresh
  bool get needsTokenRefresh {
    if (tokenExpiresAt == null) return false;
    return DateTime.now().isAfter(
      tokenExpiresAt!.subtract(const Duration(days: 5)),
    );
  }

  /// Check if token is expired
  bool get isTokenExpired {
    if (tokenExpiresAt == null) return false;
    return DateTime.now().isAfter(tokenExpiresAt!);
  }

  /// Serialize list to JSON string
  static String listToJson(List<SocialAccountModel> accounts) {
    return jsonEncode(accounts.map((a) => a.toJson()).toList());
  }

  /// Deserialize list from JSON string
  static List<SocialAccountModel> listFromJson(String jsonString) {
    try {
      final List<dynamic> list = jsonDecode(jsonString);
      return list.map((json) => SocialAccountModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
}
