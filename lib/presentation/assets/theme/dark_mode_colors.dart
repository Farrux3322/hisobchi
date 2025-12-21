import 'dart:ui';

import 'base_colors.dart';

class DarkModeColors extends BaseColors {
  const DarkModeColors();

  @override
  Color get background => const Color(0xFF121212);

  @override
  Color get white => const Color(0xFF1E1E1E);

  @override
  Color get black => const Color(0xFFE5E5E5);

  @override
  Color get primaryText => const Color(0xFF64B5F6);

  @override
  Color get primary30 => const Color(0xFF424242);

  @override
  Color get gray => const Color(0xFF9E9E9E);

  @override
  Color get divider => const Color.fromRGBO(255, 255, 255, 0.12);

  // Qo'shimcha ranglar
  Color get searchBackground => const Color(0xFF2C2C2C);
  Color get cardBackground => const Color(0xFF1E1E1E);
  Color get textSecondary => const Color(0xFFB0B0B0);
  Color get iconColor => const Color(0xFF9E9E9E);
}