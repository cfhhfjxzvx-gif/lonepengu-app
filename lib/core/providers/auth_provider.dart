import 'package:flutter/foundation.dart';
import '../repositories/auth_repository.dart';
import '../services/logger_service.dart';
import '../services/secure_storage_service.dart';
import '../../features/settings/data/settings_storage.dart';

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

  bool _onboardingCompleted = false;
  bool get onboardingCompleted => _onboardingCompleted;

  bool _brandKitCompleted = false;
  bool get brandKitCompleted => _brandKitCompleted;

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

    // Check auth status BEFORE marking as initialized
    await checkAuthStatus();

    // Load persisted flags
    _onboardingCompleted = await SettingsStorage.isOnboardingCompleted();
    _brandKitCompleted = await SettingsStorage.isBrandKitCompleted();

    _isInitialized = true;
    notifyListeners();
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
        LoggerService.auth('No valid session found');
      }
    } catch (e) {
      LoggerService.error('Auth verification failed', e);
      _user = null;
      _setState(AuthState.unauthenticated);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // LOGIN / AUTH ACTIONS
  // ═══════════════════════════════════════════════════════════════

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
      LoggerService.error('Login process error', e);
      _errorMessage = 'Login failed. Please check your connection.';
      _setState(AuthState.unauthenticated);
      return false;
    }
  }

  Future<void> logout() async {
    _setState(AuthState.loading);
    try {
      await AuthRepository.instance.logout();
      await SettingsStorage.clearUserData(); // Optional: Clear some local cache
    } catch (e) {
      LoggerService.error('Logout error', e);
    }
    _user = null;
    _errorMessage = null;
    _setState(AuthState.unauthenticated);
    LoggerService.auth('User logged out');
  }

  /// Check if there's a valid session stored without trigger loading states
  Future<bool> validateStoredSession() async {
    return await AuthRepository.instance.isLoggedIn();
  }

  // ═══════════════════════════════════════════════════════════════
  // REPEAT LOGIN FIX & PERSISTENCE
  // ═══════════════════════════════════════════════════════════════

  /// Complete onboarding and persist
  Future<void> completeOnboarding() async {
    _onboardingCompleted = true;
    await SettingsStorage.setOnboardingCompleted(true);
    notifyListeners();
    LoggerService.auth('Onboarding marked as complete');
  }

  /// Complete brand kit and persist
  Future<void> completeBrandKit() async {
    _brandKitCompleted = true;
    await SettingsStorage.setBrandKitCompleted(true);
    notifyListeners();
    LoggerService.auth('Brand Kit marked as complete');
  }

  void _setState(AuthState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

/// Auth states single source of truth
enum AuthState { initial, loading, authenticated, unauthenticated }
