import 'dart:convert';

/// Supported social platforms
enum SocialPlatform { instagram, facebook, linkedin, x }

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
        return 'X (Twitter)';
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
    }
  }

  String get authUrl {
    switch (this) {
      case SocialPlatform.instagram:
        return 'instagram.com';
      case SocialPlatform.facebook:
        return 'facebook.com';
      case SocialPlatform.linkedin:
        return 'linkedin.com';
      case SocialPlatform.x:
        return 'x.com';
    }
  }

  /// Generate mock username for connected account
  String get mockUsername {
    switch (this) {
      case SocialPlatform.instagram:
        return 'yourbusiness';
      case SocialPlatform.facebook:
        return 'YourBusinessPage';
      case SocialPlatform.linkedin:
        return 'your-business';
      case SocialPlatform.x:
        return 'yourbusiness';
    }
  }
}

/// Connected social account model
class ConnectedAccount {
  final SocialPlatform platform;
  final String username;
  final DateTime connectedAt;
  final bool isConnected;
  final String? accessToken; // For future OAuth implementation
  final String? refreshToken; // For future OAuth implementation
  final DateTime? tokenExpiresAt; // For future OAuth implementation

  const ConnectedAccount({
    required this.platform,
    required this.username,
    required this.connectedAt,
    this.isConnected = true,
    this.accessToken,
    this.refreshToken,
    this.tokenExpiresAt,
  });

  /// Create a mock connected account
  factory ConnectedAccount.mock(SocialPlatform platform) {
    return ConnectedAccount(
      platform: platform,
      username: platform.mockUsername,
      connectedAt: DateTime.now(),
      isConnected: true,
      accessToken: 'mock_access_token_${platform.name}',
      refreshToken: 'mock_refresh_token_${platform.name}',
      tokenExpiresAt: DateTime.now().add(const Duration(days: 60)),
    );
  }

  /// Create from JSON
  factory ConnectedAccount.fromJson(Map<String, dynamic> json) {
    return ConnectedAccount(
      platform: SocialPlatform.values.firstWhere(
        (p) => p.name == json['platform'],
        orElse: () => SocialPlatform.instagram,
      ),
      username: json['username'] ?? '',
      connectedAt:
          DateTime.tryParse(json['connectedAt'] ?? '') ?? DateTime.now(),
      isConnected: json['isConnected'] ?? true,
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      tokenExpiresAt: json['tokenExpiresAt'] != null
          ? DateTime.tryParse(json['tokenExpiresAt'])
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'platform': platform.name,
      'username': username,
      'connectedAt': connectedAt.toIso8601String(),
      'isConnected': isConnected,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'tokenExpiresAt': tokenExpiresAt?.toIso8601String(),
    };
  }

  /// Copy with modifications
  ConnectedAccount copyWith({
    SocialPlatform? platform,
    String? username,
    DateTime? connectedAt,
    bool? isConnected,
    String? accessToken,
    String? refreshToken,
    DateTime? tokenExpiresAt,
  }) {
    return ConnectedAccount(
      platform: platform ?? this.platform,
      username: username ?? this.username,
      connectedAt: connectedAt ?? this.connectedAt,
      isConnected: isConnected ?? this.isConnected,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenExpiresAt: tokenExpiresAt ?? this.tokenExpiresAt,
    );
  }

  /// Formatted connection date
  String get formattedConnectedDate {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[connectedAt.month - 1]} ${connectedAt.day}, ${connectedAt.year}';
  }

  /// Serialize list to JSON string
  static String listToJson(List<ConnectedAccount> accounts) {
    return jsonEncode(accounts.map((a) => a.toJson()).toList());
  }

  /// Deserialize list from JSON string
  static List<ConnectedAccount> listFromJson(String jsonString) {
    try {
      final List<dynamic> list = jsonDecode(jsonString);
      return list.map((json) => ConnectedAccount.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
}
