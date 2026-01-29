import 'package:flutter/foundation.dart';
import '../repositories/auth_repository.dart';
import '../services/logger_service.dart';
import '../services/secure_storage_service.dart';

/// Auth Provider for state management
/// Provides reactive auth state across the app
class AuthProvider extends ChangeNotifier {
  // Singleton
  static AuthProvider? _instance;
  static AuthProvider get instance => _instance ??= AuthProvider._();

  AuthProvider._();

  // State
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  AuthState _state = AuthState.initial;
  AuthState get state => _state;

  AuthUser? _user;
  AuthUser? get user => _user;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;
  bool get isUnauthenticated => _state == AuthState.unauthenticated;

  // ═══════════════════════════════════════════════════════════════
  // INITIALIZATION
  // ═══════════════════════════════════════════════════════════════

  /// Initialize AuthProvider and check current status
  Future<void> initialize() async {
    if (_isInitialized) return;

    LoggerService.auth('AuthProvider initializing');
    await SecureStorageService.instance.init();

    // Non-blocking auth check to prevent app freeze on launch
    // The AppRouter will handle the buffering state provided by isLoading
    checkAuthStatus();

    _isInitialized = true;
  }

  /// Check current auth status
  Future<void> checkAuthStatus() async {
    _setState(AuthState.loading);

    try {
      final result = await AuthRepository.instance.restoreSession();

      if (result.isAuthenticated && result.user != null) {
        _user = result.user;
        _setState(AuthState.authenticated);
        LoggerService.auth('Session restored', {'email': _user?.email});
      } else {
        _user = null;
        _setState(AuthState.unauthenticated);
        LoggerService.auth('No valid session');
      }
    } catch (e) {
      LoggerService.error('Auth check failed', e);
      _user = null;
      _setState(AuthState.unauthenticated);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // LOGIN
  // ═══════════════════════════════════════════════════════════════

  /// Login with email
  Future<bool> loginWithEmail(
    String email, {
    String? name,
    String? password,
  }) async {
    return _login(
      email: email,
      provider: 'email',
      name: name,
      password: password,
    );
  }

  /// Login with Google
  Future<bool> loginWithGoogle({
    required String email,
    String? name,
    String? providerId,
    String? avatarUrl,
  }) async {
    return _login(
      email: email,
      provider: 'google',
      name: name,
      providerId: providerId,
      avatarUrl: avatarUrl,
    );
  }

  /// Login with Apple
  Future<bool> loginWithApple({
    required String email,
    String? name,
    String? providerId,
  }) async {
    return _login(
      email: email,
      provider: 'apple',
      name: name,
      providerId: providerId,
    );
  }

  Future<bool> _login({
    required String email,
    required String provider,
    String? name,
    String? providerId,
    String? avatarUrl,
    String? password,
  }) async {
    _setState(AuthState.loading);
    _errorMessage = null;

    try {
      final result = await AuthRepository.instance.login(
        email: email,
        provider: provider,
        name: name,
        password: password,
        providerId: providerId,
        avatarUrl: avatarUrl,
      );

      if (result.success) {
        _user = AuthUser(
          id: result.userId!,
          email: result.email!,
          name: result.name,
        );
        _setState(AuthState.authenticated);
        LoggerService.auth('Login successful', {'email': email});
        return true;
      } else {
        _errorMessage = result.errorMessage;
        _setState(AuthState.unauthenticated);
        LoggerService.auth('Login failed', {'error': result.errorMessage});
        return false;
      }
    } catch (e) {
      LoggerService.error('Login error', e);
      _errorMessage = 'Login failed. Please try again.';
      _setState(AuthState.unauthenticated);
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // LOGOUT
  // ═══════════════════════════════════════════════════════════════

  /// Logout current user
  Future<void> logout() async {
    _setState(AuthState.loading);

    try {
      await AuthRepository.instance.logout();
    } catch (e) {
      LoggerService.error('Logout error', e);
    }

    _user = null;
    _errorMessage = null;
    _setState(AuthState.unauthenticated);
    LoggerService.auth('User logged out');
  }

  // ═══════════════════════════════════════════════════════════════
  // SESSION MANAGEMENT
  // ═══════════════════════════════════════════════════════════════

  /// Refresh session
  Future<bool> refreshSession() async {
    final isValid = await AuthRepository.instance.validateSession();
    if (!isValid) {
      _user = null;
      _setState(AuthState.unauthenticated);
      return false;
    }
    return true;
  }

  // ═══════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════

  void _setState(AuthState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  /// Clear any error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

/// Auth states
enum AuthState { initial, loading, authenticated, unauthenticated }
