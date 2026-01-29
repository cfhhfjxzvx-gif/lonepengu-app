import '../services/secure_storage_service.dart';
import '../services/logger_service.dart';

/// Authentication Repository
/// Handles login, logout, session validation
class AuthRepository {
  static AuthRepository? _instance;
  static AuthRepository get instance => _instance ??= AuthRepository._();

  AuthRepository._();

  // final _apiClient = ApiClient(); // REMOVED FOR OFFLINE MODE
  final _storage = SecureStorageService.instance;

  // ═══════════════════════════════════════════════════════════════
  // LOGIN / REGISTER (OFFLINE MODE)
  // ═══════════════════════════════════════════════════════════════

  /// Login or Register locally
  Future<AuthResult> login({
    required String email,
    required String provider, // Ignored in offline
    String? password,
    String? name,
    String? providerId,
    String? avatarUrl,
    String? deviceInfo,
  }) async {
    LoggerService.auth('Local Auth attempt', {
      'email': email,
      'hasName': name != null,
    });

    // Simulate network delay for realism (but fast)
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      // DECIDE: Register vs Login
      // If name is provided, we assume it's a Registration (Create Account)
      // If name is NOT provided, it's a Login (Sign In)

      if (name != null) {
        // --- REGISTRATION FLOW ---
        LoggerService.auth('Creating local account');

        // Save credentials (mock password - in real app, ask for it properly)
        // For this demo, we'll assume a default password or just store the email as identity
        await _storage.saveLocalCredentials(
          email: email,
          password: password ?? 'password123',
          name: name,
        );

        return _createSession(email, name, true);
      } else {
        // --- LOGIN FLOW ---
        LoggerService.auth('Verifying local credentials');

        // Verify email AND password
        final isValid = await _storage.verifyLocalCredentials(
          email,
          password ?? '',
        );

        if (isValid) {
          final localUser = await _storage.getLocalUserDetails();
          return _createSession(email, localUser['name'], false);
        } else {
          return AuthResult.failure(
            'Invalid credentials or account not found.',
          );
        }
      }
    } catch (e, stack) {
      LoggerService.error('Local Auth Error', e, stack);
      return AuthResult.failure('Authentication failed');
    }
  }

  Future<AuthResult> _createSession(
    String email,
    String? name,
    bool isNew,
  ) async {
    final userId = 'local_user_id';
    final token = 'local_access_token_${DateTime.now().millisecondsSinceEpoch}';

    // Save Session
    await _storage.saveAccessToken(token);
    await _storage.saveUserData(userId: userId, email: email, name: name);

    // We don't use ApiClient in offline mode, so no setToken needed really,
    // but good to keep state consistent
    // _apiClient.setToken(token);

    LoggerService.auth('Local session created');

    return AuthResult.success(
      userId: userId,
      email: email,
      name: name,
      isNewUser: isNew,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // LOGOUT
  // ═══════════════════════════════════════════════════════════════

  Future<bool> logout() async {
    LoggerService.auth('Logout');
    await _storage.clearTokens();
    // We don't clear local credentials (so they can log back in)
    // await _storage.clearAll();
    return true;
  }

  // ═══════════════════════════════════════════════════════════════
  // SESSION VALIDATION
  // ═══════════════════════════════════════════════════════════════

  Future<bool> validateSession() async {
    final token = await _storage.getAccessToken();
    return token != null;
  }

  // ═══════════════════════════════════════════════════════════════
  // CURRENT USER
  // ═══════════════════════════════════════════════════════════════

  Future<AuthUser?> getCurrentUser() async {
    final userId = await _storage.getUserId();
    final email = await _storage.getUserEmail();
    final name = await _storage.getUserName();

    if (userId == null || email == null) return null;
    return AuthUser(id: userId, email: email, name: name);
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.getAccessToken();
    return token != null;
  }

  // ═══════════════════════════════════════════════════════════════
  // RESTORE SESSION
  // ═══════════════════════════════════════════════════════════════

  Future<SessionRestoreResult> restoreSession() async {
    final isValid = await isLoggedIn();
    if (!isValid) {
      return SessionRestoreResult(isAuthenticated: false);
    }
    final user = await getCurrentUser();
    return SessionRestoreResult(isAuthenticated: true, user: user);
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
