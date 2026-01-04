import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

class ShowcaseService {
  static const String _showcaseKey = 'showcase_completed';

  static Future<bool> isShowcaseCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    // return  false;
    return prefs.getBool(_showcaseKey) ?? false;
  }

  static Future<void> setShowcaseCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showcaseKey, true);
  }

  static Future<void> resetShowcase() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_showcaseKey);
  }

  /// Check and start showcase for a specific page
  ///
  /// [showcaseKey] - Unique key for the page (e.g., 'dashboard_showcase_completed')
  /// [showcaseContext] - Context from ShowCaseWidget builder
  /// [globalKeys] - List of GlobalKeys for showcase targets
  /// [delay] - Delay before starting showcase (default: 500ms)
  static Future<void> checkAndStartShowcase({
    required String showcaseKey,
    required BuildContext showcaseContext,
    required List<GlobalKey> globalKeys,
    Duration delay = const Duration(milliseconds: 500),
  }) async {
    final prefs = await SharedPreferences.getInstance();
    // final isCompleted = false;
    final isCompleted = prefs.getBool(showcaseKey) ?? false;

    if (!isCompleted) {
      await Future.delayed(delay);
      // ignore: deprecated_member_use
      ShowCaseWidget.of(showcaseContext).startShowCase(globalKeys);
    }
  }

  /// Mark showcase as completed for a specific page
  static Future<void> markShowcaseCompleted(String showcaseKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(showcaseKey, true);
  }

  /// Check if showcase is completed for a specific page
  static Future<bool> isPageShowcaseCompleted(String showcaseKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(showcaseKey) ?? false;
  }

  /// Reset showcase for a specific page
  static Future<void> resetPageShowcase(String showcaseKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(showcaseKey);
  }
}