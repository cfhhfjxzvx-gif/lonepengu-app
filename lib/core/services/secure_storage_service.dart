import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'logger_service.dart';

/// Secure Storage Service
/// Uses flutter_secure_storage for mobile, SharedPreferences for web
class SecureStorageService {
  static SecureStorageService? _instance;
  static SecureStorageService get instance =>
      _instance ??= SecureStorageService._();

  SecureStorageService._();

  // Storage instances
  FlutterSecureStorage? _secureStorage;
  SharedPreferences? _webStorage;

  // Storage keys
  static const String _keyAccessToken = 'lp_access_token';
  static const String _keyRefreshToken = 'lp_refresh_token';
  static const String _keyUserId = 'lp_user_id';
  static const String _keyUserEmail = 'lp_user_email';
  static const String _keyUserName = 'lp_user_name';
  static const String _keyUserData = 'lp_user_data';
  static const String _keyLastRoute = 'lp_last_route';
  static const String _keyAppState = 'lp_app_state';
  static const String _keySessionExpiry = 'lp_session_expiry';

  // ═══════════════════════════════════════════════════════════════
  // INITIALIZATION
  // ═══════════════════════════════════════════════════════════════

  Future<void> init() async {
    if (kIsWeb) {
      _webStorage = await SharedPreferences.getInstance();
    } else {
      _secureStorage = const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.first_unlock_this_device,
        ),
      );
    }
    LoggerService.debug('SecureStorageService initialized');
  }

  // ═══════════════════════════════════════════════════════════════
  // TOKEN MANAGEMENT
  // ═══════════════════════════════════════════════════════════════

  /// Save access token
  Future<void> saveAccessToken(String token) async {
    await _write(_keyAccessToken, token);
    LoggerService.auth('Access token saved');
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    return await _read(_keyAccessToken);
  }

  /// Save refresh token
  Future<void> saveRefreshToken(String token) async {
    await _write(_keyRefreshToken, token);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return await _read(_keyRefreshToken);
  }

  /// Save session expiry
  Future<void> saveSessionExpiry(DateTime expiry) async {
    await _write(_keySessionExpiry, expiry.toIso8601String());
  }

  /// Check if session is expired
  Future<bool> isSessionExpired() async {
    final expiryStr = await _read(_keySessionExpiry);
    if (expiryStr == null) return true;

    try {
      final expiry = DateTime.parse(expiryStr);
      return DateTime.now().isAfter(expiry);
    } catch (e) {
      return true;
    }
  }

  /// Clear all tokens
  Future<void> clearTokens() async {
    await _delete(_keyAccessToken);
    await _delete(_keyRefreshToken);
    await _delete(_keySessionExpiry);
    LoggerService.auth('Tokens cleared');
  }

  // ═══════════════════════════════════════════════════════════════
  // USER DATA
  // ═══════════════════════════════════════════════════════════════

  /// Save user data
  Future<void> saveUserData({
    required String userId,
    required String email,
    String? name,
    Map<String, dynamic>? additionalData,
  }) async {
    await _write(_keyUserId, userId);
    await _write(_keyUserEmail, email);
    if (name != null) await _write(_keyUserName, name);
    if (additionalData != null) {
      await _write(_keyUserData, jsonEncode(additionalData));
    }
    LoggerService.auth('User data saved', {'email': email});
  }

  /// Get user ID
  Future<String?> getUserId() async {
    return await _read(_keyUserId);
  }

  /// Get user email
  Future<String?> getUserEmail() async {
    return await _read(_keyUserEmail);
  }

  /// Get user name
  Future<String?> getUserName() async {
    return await _read(_keyUserName);
  }

  /// Get additional user data
  Future<Map<String, dynamic>?> getUserData() async {
    final data = await _read(_keyUserData);
    if (data == null) return null;
    try {
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Clear user data
  Future<void> clearUserData() async {
    await _delete(_keyUserId);
    await _delete(_keyUserEmail);
    await _delete(_keyUserName);
    await _delete(_keyUserData);
    LoggerService.auth('User data cleared');
  }

  // ═══════════════════════════════════════════════════════════════
  // APP STATE PERSISTENCE (Prevent restart issues)
  // ═══════════════════════════════════════════════════════════════

  /// Save last active route
  Future<void> saveLastRoute(String route) async {
    await _write(_keyLastRoute, route);
    LoggerService.navigation('Last route saved: $route');
  }

  /// Get last active route
  Future<String?> getLastRoute() async {
    return await _read(_keyLastRoute);
  }

  /// Save app state (for complex state restoration)
  Future<void> saveAppState(Map<String, dynamic> state) async {
    await _write(_keyAppState, jsonEncode(state));
  }

  /// Get app state
  Future<Map<String, dynamic>?> getAppState() async {
    final data = await _read(_keyAppState);
    if (data == null) return null;
    try {
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Clear app state
  Future<void> clearAppState() async {
    await _delete(_keyLastRoute);
    await _delete(_keyAppState);
  }

  // ═══════════════════════════════════════════════════════════════
  // COMPLETE LOGOUT
  // ═══════════════════════════════════════════════════════════════

  /// Clear all stored data (full logout)
  Future<void> clearAll() async {
    await clearTokens();
    await clearUserData();
    await clearAppState();
    LoggerService.auth('All secure storage cleared');
  }

  // ═══════════════════════════════════════════════════════════════
  // INTERNAL METHODS
  // ═══════════════════════════════════════════════════════════════

  Future<void> _write(String key, String value) async {
    if (kIsWeb) {
      await _webStorage?.setString(key, value);
    } else {
      await _secureStorage?.write(key: key, value: value);
    }
  }

  Future<String?> _read(String key) async {
    if (kIsWeb) {
      return _webStorage?.getString(key);
    } else {
      return await _secureStorage?.read(key: key);
    }
  }

  Future<void> _delete(String key) async {
    if (kIsWeb) {
      await _webStorage?.remove(key);
    } else {
      await _secureStorage?.delete(key: key);
    }
  }
}
