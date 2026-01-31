import 'package:shared_preferences/shared_preferences.dart';

/// Settings storage service for persisting user preferences
/// Works on Web, Android, and iOS
class SettingsStorage {
  static SharedPreferences? _prefs;

  // Keys
  static const String _keyPostReminders = 'settings_post_reminders';
  static const String _keyScheduledAlerts = 'settings_scheduled_alerts';
  static const String _keyWeeklySummary = 'settings_weekly_summary';
  static const String _keyThemeMode = 'settings_theme_mode';
  static const String _keyOnboardingCompleted = 'settings_onboarding_completed';
  static const String _keyBrandKitCompleted = 'settings_brand_kit_completed';

  /// Initialize storage
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Ensure prefs is initialized
  static Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ============================================
  // NOTIFICATION PREFERENCES
  // ============================================

  /// Get post reminders preference (default: true)
  static Future<bool> getPostReminders() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_keyPostReminders) ?? true;
  }

  /// Set post reminders preference
  static Future<void> setPostReminders(bool value) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_keyPostReminders, value);
  }

  /// Get scheduled alerts preference (default: true)
  static Future<bool> getScheduledAlerts() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_keyScheduledAlerts) ?? true;
  }

  /// Set scheduled alerts preference
  static Future<void> setScheduledAlerts(bool value) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_keyScheduledAlerts, value);
  }

  /// Get weekly summary preference (default: true)
  static Future<bool> getWeeklySummary() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_keyWeeklySummary) ?? true;
  }

  /// Set weekly summary preference
  static Future<void> setWeeklySummary(bool value) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_keyWeeklySummary, value);
  }

  // ============================================
  // THEME PREFERENCES
  // ============================================

  /// Get theme mode preference (default: 'light')
  /// Values: 'light', 'dark', 'system'
  static Future<String> getThemeMode() async {
    final prefs = await _getPrefs();
    return prefs.getString(_keyThemeMode) ?? 'light';
  }

  /// Set theme mode preference
  static Future<void> setThemeMode(String value) async {
    final prefs = await _getPrefs();
    await prefs.setString(_keyThemeMode, value);
  }

  // ============================================
  // ONBOARDING PREFERENCES
  // ============================================

  /// Check if onboarding is completed
  static Future<bool> isOnboardingCompleted() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_keyOnboardingCompleted) ?? false;
  }

  /// Set onboarding completed
  static Future<void> setOnboardingCompleted(bool value) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_keyOnboardingCompleted, value);
  }

  /// Check if Brand Kit is completed
  static Future<bool> isBrandKitCompleted() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_keyBrandKitCompleted) ?? false;
  }

  /// Set Brand Kit completed
  static Future<void> setBrandKitCompleted(bool value) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_keyBrandKitCompleted, value);
  }

  // ============================================
  // ACCOUNT ACTIONS
  // ============================================

  /// Clear all settings and app data (for logout)
  static Future<void> clearAllData() async {
    final prefs = await _getPrefs();
    await prefs.clear();
  }

  /// Clear only user-specific data (keeps app preferences)
  static Future<void> clearUserData() async {
    final prefs = await _getPrefs();
    // Clear specific keys related to user data
    // Keep notification and theme preferences
    final keysToRemove = <String>[
      'content_drafts', // From DraftStorage
      'scheduled_posts', // From SchedulerStorage
      'queue_items',
      'queue_paused',
    ];

    for (final key in keysToRemove) {
      await prefs.remove(key);
    }
  }
}

/// Connected social account status
enum AccountConnectionStatus { connected, notConnected }

extension AccountConnectionStatusX on AccountConnectionStatus {
  String get displayName {
    switch (this) {
      case AccountConnectionStatus.connected:
        return 'Connected';
      case AccountConnectionStatus.notConnected:
        return 'Not Connected';
    }
  }

  bool get isConnected => this == AccountConnectionStatus.connected;
}

/// Social platform connection model
class SocialAccountConnection {
  final String platform;
  final String icon;
  final AccountConnectionStatus status;
  final int colorValue;

  const SocialAccountConnection({
    required this.platform,
    required this.icon,
    required this.status,
    required this.colorValue,
  });

  /// Mock connected accounts for MVP
  static List<SocialAccountConnection> getMockConnections() {
    return [
      const SocialAccountConnection(
        platform: 'Instagram',
        icon: '📷',
        status: AccountConnectionStatus.connected,
        colorValue: 0xFFE4405F,
      ),
      const SocialAccountConnection(
        platform: 'Facebook',
        icon: '📘',
        status: AccountConnectionStatus.connected,
        colorValue: 0xFF1877F2,
      ),
      const SocialAccountConnection(
        platform: 'LinkedIn',
        icon: '💼',
        status: AccountConnectionStatus.notConnected,
        colorValue: 0xFF0A66C2,
      ),
      const SocialAccountConnection(
        platform: 'X',
        icon: '𝕏',
        status: AccountConnectionStatus.notConnected,
        colorValue: 0xFF1A1A2E,
      ),
    ];
  }
}
