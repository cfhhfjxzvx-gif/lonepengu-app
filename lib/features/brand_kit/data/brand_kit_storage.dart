import 'package:shared_preferences/shared_preferences.dart';
import '../domain/brand_kit_model.dart';

/// Storage service for Brand Kit using SharedPreferences
class BrandKitStorage {
  static const String _key = 'brand_kit_data';
  static SharedPreferences? _prefs;

  /// Initialize SharedPreferences
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Get SharedPreferences instance
  static Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Save Brand Kit to local storage
  static Future<bool> saveBrandKit(BrandKit brandKit) async {
    try {
      final prefs = await _preferences;
      final updatedKit = brandKit.copyWith(updatedAt: DateTime.now());
      return await prefs.setString(_key, updatedKit.toJsonString());
    } catch (e) {
      return false;
    }
  }

  /// Load Brand Kit from local storage
  static Future<BrandKit?> loadBrandKit() async {
    try {
      final prefs = await _preferences;
      final jsonString = prefs.getString(_key);
      if (jsonString == null || jsonString.isEmpty) return null;
      return BrandKit.fromJsonString(jsonString);
    } catch (e) {
      return null;
    }
  }

  /// Check if Brand Kit exists
  static Future<bool> hasBrandKit() async {
    try {
      final prefs = await _preferences;
      return prefs.containsKey(_key) &&
          prefs.getString(_key)?.isNotEmpty == true;
    } catch (e) {
      return false;
    }
  }

  /// Delete Brand Kit from storage
  static Future<bool> deleteBrandKit() async {
    try {
      final prefs = await _preferences;
      return await prefs.remove(_key);
    } catch (e) {
      return false;
    }
  }
}
