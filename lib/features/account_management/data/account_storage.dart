import 'package:shared_preferences/shared_preferences.dart';
import 'connected_account_model.dart';

/// Storage service for connected social accounts
/// Uses SharedPreferences for cross-platform persistence (Web, Android, iOS)
class AccountStorage {
  static SharedPreferences? _prefs;
  static const String _key = 'connected_accounts';

  /// Initialize storage
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Ensure prefs is initialized
  static Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Load all connected accounts
  static Future<List<ConnectedAccount>> loadConnectedAccounts() async {
    final prefs = await _getPrefs();
    final jsonString = prefs.getString(_key);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    return ConnectedAccount.listFromJson(jsonString);
  }

  /// Save connected account
  static Future<void> saveConnectedAccount(ConnectedAccount account) async {
    final prefs = await _getPrefs();
    final accounts = await loadConnectedAccounts();

    // Remove existing account for this platform if any
    accounts.removeWhere((a) => a.platform == account.platform);

    // Add new account
    accounts.add(account);

    // Save
    await prefs.setString(_key, ConnectedAccount.listToJson(accounts));
  }

  /// Remove connected account
  static Future<void> removeConnectedAccount(SocialPlatform platform) async {
    final prefs = await _getPrefs();
    final accounts = await loadConnectedAccounts();

    accounts.removeWhere((a) => a.platform == platform);

    await prefs.setString(_key, ConnectedAccount.listToJson(accounts));
  }

  /// Get connected account by platform
  static Future<ConnectedAccount?> getConnectedAccount(
    SocialPlatform platform,
  ) async {
    final accounts = await loadConnectedAccounts();
    try {
      return accounts.firstWhere((a) => a.platform == platform);
    } catch (e) {
      return null;
    }
  }

  /// Check if platform is connected
  static Future<bool> isConnected(SocialPlatform platform) async {
    final account = await getConnectedAccount(platform);
    return account != null && account.isConnected;
  }

  /// Clear all connected accounts
  static Future<void> clearAll() async {
    final prefs = await _getPrefs();
    await prefs.remove(_key);
  }

  /// Update connected account
  static Future<void> updateConnectedAccount(ConnectedAccount account) async {
    await saveConnectedAccount(account);
  }
}
