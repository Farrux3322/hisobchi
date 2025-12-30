
import 'package:flutter/cupertino.dart';

abstract class BaseColors {
  const BaseColors();

  Color get primaryText => const Color.fromRGBO(0, 111, 229, 1);
  ///////////////////////////////////////////////
  Color get primary => const Color(0xFF4A3AFF);
  Color get white => const Color(0xFFFFFFFF);
  Color get black => const Color(0xFF202020);
  Color get color9E97FF => const Color(0xFF9E97FF);
  Color get colorB007FF => const Color(0xFFB007FF);
  Color get colorDE5050 => const Color(0xFFDE5050);
  Color get color3CC293 => const Color(0xFF3CC293);
  Color get colorEDECF8 => const Color(0xFFEDECF8);
  Color get colorF9F9FD => const Color(0xFFF9F9FD);
  Color get colorA3A2AE => const Color(0xFFA3A2AE);
  Color get colorE1EOEE => const Color(0xFFE1E0EE);
  Color get color87859F => const Color(0xFF87859F);
  ///////////////////////////////////////////////////
  Color get secondary => const Color.fromRGBO(107, 61, 237, 0.5);
  Color get primary30 => const Color(0xFFC9D6DF);
  Color get disable => const Color.fromRGBO(226, 230, 238, 1);
  Color get accent => const Color.fromRGBO(240, 244, 248, 1);
  Color get red => const Color.fromRGBO(235, 87, 87, 1);
  Color get divider => const Color.fromRGBO(101, 122, 147, 0.18);
  Color get gray => const Color.fromRGBO(177, 184, 200, 1);
  Color get green => const Color.fromRGBO(0, 216, 86, 1);

  Color get background;

  // Qo'shimcha dynamic ranglar
  Color get searchBackground => const Color(0xFFF1F5F9);
  Color get cardBackground => const Color(0xFFFFFFFF);
  Color get textSecondary => const Color(0xFF64748B);
  Color get iconColor => const Color(0xFF94A3B8);
}
