import 'package:flutter/material.dart';
import '../../features/settings/data/settings_storage.dart';

class ThemeManager extends ChangeNotifier {
  static final ThemeManager instance = ThemeManager._();
  ThemeManager._();

  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  Future<void> init() async {
    final mode = await SettingsStorage.getThemeMode();
    _themeMode = _parseThemeMode(mode);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    await SettingsStorage.setThemeMode(_themeMode.name);
    notifyListeners();
  }

  ThemeMode _parseThemeMode(String mode) {
    switch (mode) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      case 'light':
      default:
        return ThemeMode.light;
    }
  }
}
