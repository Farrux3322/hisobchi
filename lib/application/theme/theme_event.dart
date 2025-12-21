import 'package:flutter/material.dart';

abstract class ThemeEvent {
  const ThemeEvent();
}

/// Theme ni yuklash
class LoadThemeEvent extends ThemeEvent {
  const LoadThemeEvent();
}

/// Theme ni o'zgartirish
class ChangeThemeEvent extends ThemeEvent {
  final ThemeMode themeMode;

  const ChangeThemeEvent(this.themeMode);
}

/// Theme ni toggle qilish (light <-> dark)
class ToggleThemeEvent extends ThemeEvent {
  const ToggleThemeEvent();
}