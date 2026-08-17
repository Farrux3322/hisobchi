import 'dart:ui';

import 'base_colors.dart';

class LightModeColors extends BaseColors {
  const LightModeColors();

  @override
  Color get background => const Color(0xFFF8FAFC);

  // Qo'shimcha ranglar
  Color get searchBackground => const Color(0xFFF1F5F9);
  Color get cardBackground => const Color(0xFFFFFFFF);
  Color get textSecondary => const Color(0xFF64748B);
  Color get iconColor => const Color(0xFF94A3B8);
}
