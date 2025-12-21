import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeRepository {
  static const String _themeKey = 'app_theme_mode';

  /// Saqlangan theme mode ni olish
  Future<ThemeMode> getSavedThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeString = prefs.getString(_themeKey);

      if (themeModeString == null) {
        return ThemeMode.light; // Default qiymat
      }

      return ThemeMode.values.firstWhere(
        (mode) => mode.toString() == themeModeString,
        orElse: () => ThemeMode.light,
      );
    } catch (e) {
      return ThemeMode.light;
    }
  }

  /// Theme mode ni saqlash
  Future<bool> saveThemeMode(ThemeMode themeMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_themeKey, themeMode.toString());
    } catch (e) {
      return false;
    }
  }

  /// Theme mode ni o'chirish
  Future<bool> clearThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_themeKey);
    } catch (e) {
      return false;
    }
  }

  /// Theme mode ni toggle qilish (light <-> dark)
  Future<ThemeMode> toggleThemeMode() async {
    final currentMode = await getSavedThemeMode();
    final newMode = currentMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await saveThemeMode(newMode);
    return newMode;
  }
}