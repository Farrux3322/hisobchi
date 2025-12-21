import 'package:flutter/material.dart';

class ThemeState {
  final ThemeMode themeMode;
  final bool isLoading;
  final String? errorMessage;

  const ThemeState({
    this.themeMode = ThemeMode.light,
    this.isLoading = false,
    this.errorMessage,
  });

  /// Theme light modedami?
  bool get isLightMode => themeMode == ThemeMode.light;

  /// Theme dark modedami?
  bool get isDarkMode => themeMode == ThemeMode.dark;

  /// Theme modeining nomi
  String get themeModeName {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Yorqin';
      case ThemeMode.dark:
        return 'Qorong\'i';
      case ThemeMode.system:
        return 'Tizim';
    }
  }

  ThemeState copyWith({
    ThemeMode? themeMode,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}