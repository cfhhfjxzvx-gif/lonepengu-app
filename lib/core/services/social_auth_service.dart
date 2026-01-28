/// Social Authentication Service Abstraction
/// BRD Section 5: API Integrations
///
/// Supports:
/// - Meta Graph API (OAuth 2.0)
/// - LinkedIn API (OAuth 2.0)
/// - X API v2 (OAuth 2.0)

/// Supported OAuth providers
enum OAuthProvider { meta, linkedin, x }

extension OAuthProviderX on OAuthProvider {
  String get displayName {
    switch (this) {
      case OAuthProvider.meta:
        return 'Meta (Facebook/Instagram)';
      case OAuthProvider.linkedin:
        return 'LinkedIn';
      case OAuthProvider.x:
        return 'X (Twitter)';
    }
  }

  String get authUrl {
    switch (this) {
      case OAuthProvider.meta:
        return 'https://www.facebook.com/v18.0/dialog/oauth';
      case OAuthProvider.linkedin:
        return 'https://www.linkedin.com/oauth/v2/authorization';
      case OAuthProvider.x:
        return 'https://twitter.com/i/oauth2/authorize';
    }
  }

  List<String> get defaultScopes {
    switch (this) {
      case OAuthProvider.meta:
        return [
          'instagram_basic',
          'instagram_content_publish',
          'pages_read_engagement',
        ];
      case OAuthProvider.linkedin:
        return ['r_liteprofile', 'w_member_social'];
      case OAuthProvider.x:
        return ['tweet.read', 'tweet.write', 'users.read'];
    }
  }
}

/// OAuth token model
class OAuthToken {
  final String accessToken;
  final String? refreshToken;
  final DateTime expiresAt;
  final List<String> scopes;
  final OAuthProvider provider;

  const OAuthToken({
    required this.accessToken,
    this.refreshToken,
    required this.expiresAt,
    required this.scopes,
    required this.provider,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get needsRefresh =>
      DateTime.now().isAfter(expiresAt.subtract(const Duration(minutes: 5)));

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'expiresAt': expiresAt.toIso8601String(),
    'scopes': scopes,
    'provider': provider.name,
  };

  factory OAuthToken.fromJson(Map<String, dynamic> json) => OAuthToken(
    accessToken: json['accessToken'],
    refreshToken: json['refreshToken'],
    expiresAt: DateTime.parse(json['expiresAt']),
    scopes: List<String>.from(json['scopes'] ?? []),
    provider: OAuthProvider.values.firstWhere(
      (p) => p.name == json['provider'],
    ),
  );
}

/// OAuth result
class OAuthResult {
  final bool success;
  final OAuthToken? token;
  final String? error;
  final String? userId;
  final String? username;
  final String? profileImageUrl;

  const OAuthResult({
    required this.success,
    this.token,
    this.error,
    this.userId,
    this.username,
    this.profileImageUrl,
  });

  factory OAuthResult.success({
    required OAuthToken token,
    required String userId,
    required String username,
    String? profileImageUrl,
  }) => OAuthResult(
    success: true,
    token: token,
    userId: userId,
    username: username,
    profileImageUrl: profileImageUrl,
  );

  factory OAuthResult.failure(String error) =>
      OAuthResult(success: false, error: error);
}

/// Abstract Social Auth Service Interface
/// Replace MockSocialAuthService with real implementation later
abstract class SocialAuthService {
  /// Initiate OAuth flow for a provider
  Future<OAuthResult> authenticate(OAuthProvider provider);

  /// Refresh an expired token
  Future<OAuthResult> refreshToken(OAuthToken token);

  /// Revoke access for a provider
  Future<bool> revokeAccess(OAuthProvider provider, String accessToken);

  /// Get user profile from provider
  Future<Map<String, dynamic>?> getUserProfile(
    OAuthProvider provider,
    String accessToken,
  );

  /// Check if token is valid
  Future<bool> validateToken(OAuthToken token);
}

/// Mock implementation for MVP
class MockSocialAuthService implements SocialAuthService {
  static const int _mockDelay = 1500;

  @override
  Future<OAuthResult> authenticate(OAuthProvider provider) async {
    await Future.delayed(const Duration(milliseconds: _mockDelay));

    // Simulate successful OAuth
    final token = OAuthToken(
      accessToken:
          'mock_access_${provider.name}_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken:
          'mock_refresh_${provider.name}_${DateTime.now().millisecondsSinceEpoch}',
      expiresAt: DateTime.now().add(const Duration(days: 60)),
      scopes: provider.defaultScopes,
      provider: provider,
    );

    return OAuthResult.success(
      token: token,
      userId: 'user_${provider.name}_123',
      username: 'mockuser_${provider.name}',
      profileImageUrl: null,
    );
  }

  @override
  Future<OAuthResult> refreshToken(OAuthToken token) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final newToken = OAuthToken(
      accessToken:
          'refreshed_access_${token.provider.name}_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: token.refreshToken,
      expiresAt: DateTime.now().add(const Duration(days: 60)),
      scopes: token.scopes,
      provider: token.provider,
    );

    return OAuthResult.success(
      token: newToken,
      userId: 'user_${token.provider.name}_123',
      username: 'mockuser_${token.provider.name}',
    );
  }

  @override
  Future<bool> revokeAccess(OAuthProvider provider, String accessToken) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  @override
  Future<Map<String, dynamic>?> getUserProfile(
    OAuthProvider provider,
    String accessToken,
  ) async {
    await Future.delayed(const Duration(milliseconds: 600));

    return {
      'id': 'user_${provider.name}_123',
      'username': 'mockuser_${provider.name}',
      'name': 'Mock User',
      'email': 'mockuser@example.com',
      'profileImageUrl': null,
    };
  }

  @override
  Future<bool> validateToken(OAuthToken token) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return !token.isExpired;
  }
}
