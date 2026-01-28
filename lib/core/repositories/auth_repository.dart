import '../api/api_client.dart';
import '../api/api_config.dart';
import '../services/secure_storage_service.dart';
import '../services/logger_service.dart';

/// Authentication Repository
/// Handles login, logout, session validation
class AuthRepository {
  static AuthRepository? _instance;
  static AuthRepository get instance => _instance ??= AuthRepository._();

  AuthRepository._();

  final _apiClient = ApiClient();
  final _storage = SecureStorageService.instance;

  // ═══════════════════════════════════════════════════════════════
  // LOGIN
  // ═══════════════════════════════════════════════════════════════

  /// Login with email and provider
  /// Returns the authenticated user or null on failure
  Future<AuthResult> login({
    required String email,
    required String provider,
    String? name,
    String? providerId,
    String? avatarUrl,
    String? deviceInfo,
  }) async {
    LoggerService.auth('Login attempt', {'email': email, 'provider': provider});

    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConfig.authLogin,
        body: {
          'email': email,
          'name': name,
          'auth_provider': provider,
          'provider_id': providerId,
          'avatar_url': avatarUrl,
          'device_info': deviceInfo,
        },
      );

      if (response.success && response.data != null) {
        final data = response.data!;

        // Extract tokens
        final accessToken = data['access_token'] as String?;
        final refreshToken = data['refresh_token'] as String?;
        final userId = data['user_id'] as String?;
        final expiresAt = data['expires_at'] as String?;

        if (accessToken == null || userId == null) {
          return AuthResult.failure('Invalid response from server');
        }

        // Save tokens
        await _storage.saveAccessToken(accessToken);
        if (refreshToken != null) {
          await _storage.saveRefreshToken(refreshToken);
        }
        if (expiresAt != null) {
          await _storage.saveSessionExpiry(DateTime.parse(expiresAt));
        }

        // Save user data
        await _storage.saveUserData(
          userId: userId,
          email: email,
          name: name,
          additionalData: data['user'] as Map<String, dynamic>?,
        );

        // Set token in API client for subsequent requests
        _apiClient.setToken(accessToken);

        LoggerService.auth('Login successful', {'userId': userId});

        return AuthResult.success(
          userId: userId,
          email: email,
          name: name,
          isNewUser: data['is_new_user'] == true,
        );
      }

      return AuthResult.failure(response.message ?? 'Login failed');
    } catch (e, stack) {
      LoggerService.error('Login error', e, stack);
      return AuthResult.failure('Login failed: ${e.toString()}');
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // LOGOUT
  // ═══════════════════════════════════════════════════════════════

  /// Logout and clear all session data
  Future<bool> logout() async {
    LoggerService.auth('Logout');

    try {
      final token = await _storage.getAccessToken();

      if (token != null) {
        // Notify backend
        await _apiClient.post(ApiConfig.authLogout);
      }
    } catch (e) {
      LoggerService.error('Backend logout failed', e);
      // Continue with local logout even if backend fails
    }

    // Clear local data
    await _storage.clearAll();
    _apiClient.clearToken();

    LoggerService.auth('Logout complete');
    return true;
  }

  // ═══════════════════════════════════════════════════════════════
  // SESSION VALIDATION
  // ═══════════════════════════════════════════════════════════════

  /// Validate current session
  /// Returns true if session is valid
  Future<bool> validateSession() async {
    LoggerService.auth('Validating session');

    // Check if we have a token
    final token = await _storage.getAccessToken();
    if (token == null) {
      LoggerService.auth('No token found');
      return false;
    }

    // Check if session is expired locally
    if (await _storage.isSessionExpired()) {
      LoggerService.auth('Session expired locally');
      return await _tryRefreshSession();
    }

    // Set token in API client
    _apiClient.setToken(token);

    // Validate with backend
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConfig.authValidate,
      );

      if (response.success && response.data?['valid'] == true) {
        LoggerService.auth('Session valid');
        return true;
      }
    } catch (e) {
      LoggerService.error('Session validation failed', e);
    }

    // Try to refresh if validation failed
    return await _tryRefreshSession();
  }

  /// Try to refresh the session using refresh token
  Future<bool> _tryRefreshSession() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null) {
      return false;
    }

    LoggerService.auth('Attempting token refresh');

    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConfig.authRefresh,
        body: {'refresh_token': refreshToken},
      );

      if (response.success && response.data != null) {
        final newAccessToken = response.data!['access_token'] as String?;
        final expiresAt = response.data!['expires_at'] as String?;

        if (newAccessToken != null) {
          await _storage.saveAccessToken(newAccessToken);
          if (expiresAt != null) {
            await _storage.saveSessionExpiry(DateTime.parse(expiresAt));
          }
          _apiClient.setToken(newAccessToken);
          LoggerService.auth('Token refreshed');
          return true;
        }
      }
    } catch (e) {
      LoggerService.error('Token refresh failed', e);
    }

    // Refresh failed, clear everything
    await _storage.clearTokens();
    _apiClient.clearToken();
    return false;
  }

  // ═══════════════════════════════════════════════════════════════
  // CURRENT USER
  // ═══════════════════════════════════════════════════════════════

  /// Get current user from storage
  Future<AuthUser?> getCurrentUser() async {
    final userId = await _storage.getUserId();
    final email = await _storage.getUserEmail();
    final name = await _storage.getUserName();

    if (userId == null || email == null) {
      return null;
    }

    return AuthUser(id: userId, email: email, name: name);
  }

  /// Check if user is logged in (without validation)
  Future<bool> isLoggedIn() async {
    final token = await _storage.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // ═══════════════════════════════════════════════════════════════
  // RESTORE SESSION
  // ═══════════════════════════════════════════════════════════════

  /// Restore session on app start
  /// Returns the last route if session is valid
  Future<SessionRestoreResult> restoreSession() async {
    LoggerService.auth('Restoring session');

    final isValid = await validateSession();

    if (!isValid) {
      return SessionRestoreResult(
        isAuthenticated: false,
        lastRoute: null,
        user: null,
      );
    }

    final user = await getCurrentUser();
    final lastRoute = await _storage.getLastRoute();

    return SessionRestoreResult(
      isAuthenticated: true,
      lastRoute: lastRoute,
      user: user,
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// RESULT CLASSES
// ═══════════════════════════════════════════════════════════════

class AuthResult {
  final bool success;
  final String? userId;
  final String? email;
  final String? name;
  final bool isNewUser;
  final String? errorMessage;

  const AuthResult._({
    required this.success,
    this.userId,
    this.email,
    this.name,
    this.isNewUser = false,
    this.errorMessage,
  });

  factory AuthResult.success({
    required String userId,
    required String email,
    String? name,
    bool isNewUser = false,
  }) {
    return AuthResult._(
      success: true,
      userId: userId,
      email: email,
      name: name,
      isNewUser: isNewUser,
    );
  }

  factory AuthResult.failure(String message) {
    return AuthResult._(success: false, errorMessage: message);
  }
}

class AuthUser {
  final String id;
  final String email;
  final String? name;
  final String? avatarUrl;

  const AuthUser({
    required this.id,
    required this.email,
    this.name,
    this.avatarUrl,
  });
}

class SessionRestoreResult {
  final bool isAuthenticated;
  final String? lastRoute;
  final AuthUser? user;

  const SessionRestoreResult({
    required this.isAuthenticated,
    this.lastRoute,
    this.user,
  });
}
