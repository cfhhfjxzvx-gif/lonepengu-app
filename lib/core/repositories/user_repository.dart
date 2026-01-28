import '../api/api_client.dart';
import '../api/api_config.dart';
import '../services/logger_service.dart';
import '../services/secure_storage_service.dart';

/// User Repository
/// Handles user data operations
class UserRepository {
  static UserRepository? _instance;
  static UserRepository get instance => _instance ??= UserRepository._();

  UserRepository._();

  final _apiClient = ApiClient();
  final _storage = SecureStorageService.instance;

  // ═══════════════════════════════════════════════════════════════
  // GET USER
  // ═══════════════════════════════════════════════════════════════

  /// Get current user from API
  Future<UserData?> fetchCurrentUser() async {
    LoggerService.debug('Fetching current user');

    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConfig.userMe,
      );

      if (response.success && response.data != null) {
        final userData = UserData.fromJson(response.data!);
        LoggerService.debug('User fetched', {'email': userData.email});
        return userData;
      }

      return null;
    } catch (e) {
      LoggerService.error('Failed to fetch user', e);
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // UPDATE USER
  // ═══════════════════════════════════════════════════════════════

  /// Update user profile
  Future<bool> updateProfile({
    String? name,
    String? avatarUrl,
    Map<String, dynamic>? metadata,
  }) async {
    LoggerService.debug('Updating user profile');

    try {
      final response = await _apiClient.put<Map<String, dynamic>>(
        ApiConfig.userUpdate,
        body: {
          if (name != null) 'name': name,
          if (avatarUrl != null) 'avatar_url': avatarUrl,
          if (metadata != null) 'metadata': metadata,
        },
      );

      if (response.success) {
        // Update local storage
        if (name != null) {
          final userId = await _storage.getUserId();
          final email = await _storage.getUserEmail();
          if (userId != null && email != null) {
            await _storage.saveUserData(
              userId: userId,
              email: email,
              name: name,
            );
          }
        }

        LoggerService.debug('Profile updated');
        return true;
      }

      return false;
    } catch (e) {
      LoggerService.error('Failed to update profile', e);
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // USER PREFERENCES
  // ═══════════════════════════════════════════════════════════════

  /// Get user preferences
  Future<UserPreferences?> getPreferences() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConfig.userPreferences,
      );

      if (response.success && response.data != null) {
        return UserPreferences.fromJson(response.data!);
      }

      return null;
    } catch (e) {
      LoggerService.error('Failed to get preferences', e);
      return null;
    }
  }

  /// Update user preferences
  Future<bool> updatePreferences(UserPreferences preferences) async {
    try {
      final response = await _apiClient.put(
        ApiConfig.userPreferences,
        body: preferences.toJson(),
      );

      return response.success;
    } catch (e) {
      LoggerService.error('Failed to update preferences', e);
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // APP STATE (for background recovery)
  // ═══════════════════════════════════════════════════════════════

  /// Save app state to server
  Future<bool> saveAppState({
    required String lastRoute,
    Map<String, dynamic>? appState,
  }) async {
    try {
      // Save locally first (always works)
      await _storage.saveLastRoute(lastRoute);
      if (appState != null) {
        await _storage.saveAppState(appState);
      }

      // Try to sync to server (optional, may fail offline)
      final response = await _apiClient.put(
        ApiConfig.userAppState,
        body: {'last_route': lastRoute, 'app_state': appState ?? {}},
      );

      return response.success;
    } catch (e) {
      // Local save already done, server sync failed
      LoggerService.warning('Failed to sync app state to server', e);
      return false;
    }
  }

  /// Get app state from server (fallback to local)
  Future<AppStateData?> getAppState() async {
    try {
      // Try server first
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConfig.userAppState,
      );

      if (response.success && response.data != null) {
        return AppStateData(
          lastRoute: response.data!['last_route'] as String?,
          appState: response.data!['app_state'] as Map<String, dynamic>?,
        );
      }
    } catch (e) {
      LoggerService.warning('Failed to get server app state', e);
    }

    // Fallback to local storage
    final lastRoute = await _storage.getLastRoute();
    final appState = await _storage.getAppState();

    if (lastRoute != null) {
      return AppStateData(lastRoute: lastRoute, appState: appState);
    }

    return null;
  }
}

// ═══════════════════════════════════════════════════════════════
// DATA CLASSES
// ═══════════════════════════════════════════════════════════════

class UserData {
  final String id;
  final String email;
  final String? name;
  final String? avatarUrl;
  final String authProvider;
  final DateTime? createdAt;
  final DateTime? lastLogin;
  final Map<String, dynamic>? metadata;

  const UserData({
    required this.id,
    required this.email,
    this.name,
    this.avatarUrl,
    required this.authProvider,
    this.createdAt,
    this.lastLogin,
    this.metadata,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      authProvider: json['auth_provider'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'avatar_url': avatarUrl,
    'auth_provider': authProvider,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    if (lastLogin != null) 'last_login': lastLogin!.toIso8601String(),
    if (metadata != null) 'metadata': metadata,
  };
}

class UserPreferences {
  final String themeMode;
  final bool notificationsEnabled;
  final bool emailNotifications;
  final String? lastActiveRoute;

  const UserPreferences({
    this.themeMode = 'system',
    this.notificationsEnabled = true,
    this.emailNotifications = true,
    this.lastActiveRoute,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      themeMode: json['theme_mode'] as String? ?? 'system',
      notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
      emailNotifications: json['email_notifications'] as bool? ?? true,
      lastActiveRoute: json['last_active_route'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'theme_mode': themeMode,
    'notifications_enabled': notificationsEnabled,
    'email_notifications': emailNotifications,
    'last_active_route': lastActiveRoute,
  };

  UserPreferences copyWith({
    String? themeMode,
    bool? notificationsEnabled,
    bool? emailNotifications,
    String? lastActiveRoute,
  }) {
    return UserPreferences(
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      lastActiveRoute: lastActiveRoute ?? this.lastActiveRoute,
    );
  }
}

class AppStateData {
  final String? lastRoute;
  final Map<String, dynamic>? appState;

  const AppStateData({this.lastRoute, this.appState});
}
