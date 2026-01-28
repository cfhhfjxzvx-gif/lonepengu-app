import 'connected_account_model.dart';
import 'account_storage.dart';

/// OAuth result model
class OAuthResult {
  final bool success;
  final ConnectedAccount? account;
  final String? error;

  const OAuthResult({required this.success, this.account, this.error});

  factory OAuthResult.success(ConnectedAccount account) {
    return OAuthResult(success: true, account: account);
  }

  factory OAuthResult.failure(String error) {
    return OAuthResult(success: false, error: error);
  }
}

/// Abstract social auth service interface
/// This allows easy replacement of mock implementation with real OAuth later
abstract class SocialAuthService {
  /// Connect to a social platform
  Future<OAuthResult> connect(SocialPlatform platform);

  /// Disconnect from a social platform
  Future<bool> disconnect(SocialPlatform platform);

  /// Reconnect to a social platform (refresh tokens, etc.)
  Future<OAuthResult> reconnect(SocialPlatform platform);

  /// Get connection status for a platform
  Future<ConnectedAccount?> getConnectionStatus(SocialPlatform platform);

  /// Get all connected accounts
  Future<List<ConnectedAccount>> getAllConnections();
}

/// Mock implementation of SocialAuthService for MVP
/// Replace with real OAuth implementation later
class MockSocialAuthService implements SocialAuthService {
  /// Simulated network delay (ms)
  static const int _simulatedDelay = 1500;

  @override
  Future<OAuthResult> connect(SocialPlatform platform) async {
    // Simulate OAuth redirect and callback delay
    await Future.delayed(const Duration(milliseconds: _simulatedDelay));

    try {
      // Create mock connected account
      final account = ConnectedAccount.mock(platform);

      // Save to storage
      await AccountStorage.saveConnectedAccount(account);

      return OAuthResult.success(account);
    } catch (e) {
      return OAuthResult.failure(
        'Failed to connect to ${platform.displayName}',
      );
    }
  }

  @override
  Future<bool> disconnect(SocialPlatform platform) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      await AccountStorage.removeConnectedAccount(platform);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<OAuthResult> reconnect(SocialPlatform platform) async {
    // Simulate token refresh delay
    await Future.delayed(const Duration(milliseconds: _simulatedDelay));

    try {
      final existingAccount = await AccountStorage.getConnectedAccount(
        platform,
      );

      if (existingAccount == null) {
        return OAuthResult.failure('No existing connection found');
      }

      // Create updated account with new tokens
      final updatedAccount = existingAccount.copyWith(
        connectedAt: DateTime.now(),
        accessToken: 'refreshed_access_token_${platform.name}',
        tokenExpiresAt: DateTime.now().add(const Duration(days: 60)),
      );

      await AccountStorage.updateConnectedAccount(updatedAccount);

      return OAuthResult.success(updatedAccount);
    } catch (e) {
      return OAuthResult.failure(
        'Failed to reconnect to ${platform.displayName}',
      );
    }
  }

  @override
  Future<ConnectedAccount?> getConnectionStatus(SocialPlatform platform) async {
    return AccountStorage.getConnectedAccount(platform);
  }

  @override
  Future<List<ConnectedAccount>> getAllConnections() async {
    return AccountStorage.loadConnectedAccounts();
  }
}

/// Singleton instance of the auth service
/// In production, this could be replaced with a real OAuth service
class SocialAuthServiceProvider {
  static SocialAuthService? _instance;

  static SocialAuthService get instance {
    _instance ??= MockSocialAuthService();
    return _instance!;
  }

  /// For testing or switching implementations
  static void setInstance(SocialAuthService service) {
    _instance = service;
  }
}
