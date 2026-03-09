import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'base_colors.dart';
import 'dark_mode_colors.dart';
import 'light_mode_colors.dart';

class AppTheme {
  /// App theme colors
  static late BaseColors colors;

  /// Current app theme mode
  static late ThemeMode themeMode;

  /// App theme data for light mode
  static late ThemeData data;

  /// App theme data for dark mode
  static late ThemeData darkData;

  static void init({ThemeMode mode = ThemeMode.light}) {
    themeMode = mode;
    colors = _getThemeColors(mode);

    final lightTextTheme = _buildTextTheme(const LightModeColors());
    final darkTextTheme = _buildTextTheme(const DarkModeColors());

    data = _buildThemeData(lightTextTheme, const LightModeColors(), ThemeMode.light);
    darkData = _buildThemeData(darkTextTheme, const DarkModeColors(), ThemeMode.dark);
  }

  static void updateTheme(ThemeMode mode) {
    themeMode = mode;
    colors = _getThemeColors(mode);
  }

  static TextTheme _buildTextTheme(BaseColors themeColors) {
    return GoogleFonts.montserratTextTheme(
      TextTheme(
        ///display
        displayLarge: TextStyle(fontWeight: FontWeight.w700, fontSize: 24.sp, color: themeColors.black),
        displayMedium: TextStyle(fontWeight: FontWeight.w500, fontSize: 24.sp, color: themeColors.black),
        displaySmall: TextStyle(fontWeight: FontWeight.w400, fontSize: 24.sp, color: themeColors.black),

        ///headline
        headlineLarge: TextStyle(fontWeight: FontWeight.w700, fontSize: 20.sp, color: themeColors.black),
        headlineMedium: TextStyle(fontWeight: FontWeight.w500, fontSize: 20.sp, color: themeColors.black),
        headlineSmall: TextStyle(fontWeight: FontWeight.w400, fontSize: 20.sp, color: themeColors.black),

        ///title
        titleLarge: TextStyle(fontWeight: FontWeight.w700, fontSize: 16.sp, color: themeColors.black),
        titleMedium: TextStyle(fontWeight: FontWeight.w500, fontSize: 16.sp, color: themeColors.black),
        titleSmall: TextStyle(fontWeight: FontWeight.w400, fontSize: 16.sp, color: themeColors.black),

        ///body
        bodyLarge: TextStyle(fontWeight: FontWeight.w500, fontSize: 11.sp, color: themeColors.black),
        bodyMedium: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.sp, color: themeColors.black),
        bodySmall: TextStyle(fontWeight: FontWeight.w400, fontSize: 14.sp, color: themeColors.black),

        ///label
        labelLarge: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.sp, color: themeColors.black),
        labelMedium: TextStyle(fontWeight: FontWeight.w500, fontSize: 12.sp, color: themeColors.black),
        labelSmall: TextStyle(fontWeight: FontWeight.w500, fontSize: 10.sp, color: themeColors.black),
      ),
    );
  }

  static ThemeData _buildThemeData(TextTheme textTheme, BaseColors themeColors, ThemeMode mode) {
    final brightness = mode == ThemeMode.light ? Brightness.light : Brightness.dark;

    return ThemeData(
      useMaterial3: false,
      fontFamily: GoogleFonts.montserrat().fontFamily,
      colorScheme: mode == ThemeMode.light ? ColorScheme.light(primary: themeColors.primary, surface: themeColors.white) : ColorScheme.dark(primary: themeColors.primary, surface: themeColors.white),
      textTheme: textTheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      scaffoldBackgroundColor: themeColors.background,
      dividerColor: themeColors.divider,
      brightness: brightness,
      appBarTheme: AppBarTheme(
        titleTextStyle: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black, letterSpacing: 0.5),
        backgroundColor: themeColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      textSelectionTheme: TextSelectionThemeData(cursorColor: themeColors.primaryText),
      toggleButtonsTheme: ToggleButtonsThemeData(selectedColor: themeColors.primary, selectedBorderColor: themeColors.primary, fillColor: themeColors.primary),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
        side: BorderSide(color: themeColors.gray),
      ),
      bottomSheetTheme: BottomSheetThemeData(backgroundColor: themeColors.background),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: themeColors.white,
        selectedItemColor: themeColors.primary,
        unselectedItemColor: themeColors.gray,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: themeColors.black,
        unselectedLabelColor: themeColors.black,
        labelStyle: textTheme.labelLarge?.copyWith(fontSize: 12.sp),
        unselectedLabelStyle: textTheme.labelMedium?.copyWith(fontSize: 12.sp),
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: const [
            BoxShadow(offset: Offset(0, 3), blurRadius: 1, color: Color.fromRGBO(0, 0, 0, 0.04)),
            BoxShadow(offset: Offset(0, 3), blurRadius: 8, color: Color.fromRGBO(0, 0, 0, 0.12)),
          ],
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          fixedSize: Size(1.sw, 0.06.sh),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          backgroundColor: themeColors.primary,
          disabledBackgroundColor: themeColors.gray,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        isDense: true,
        fillColor: const Color(0xFFF8FAFC),
        focusColor: themeColors.primaryText,
        floatingLabelStyle: textTheme.labelSmall?.copyWith(color: themeColors.primaryText),
        counterStyle: textTheme.bodySmall?.copyWith(color: themeColors.primaryText),
        prefixIconConstraints: BoxConstraints(minHeight: 24, minWidth: 24),
        suffixIconConstraints: BoxConstraints(minHeight: 24, minWidth: 24),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: themeColors.primary30),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: themeColors.primaryText),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: themeColors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: themeColors.red),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: themeColors.gray),
        ),
        helperStyle: textTheme.labelSmall,
        hintStyle: textTheme.labelSmall?.copyWith(color: themeColors.primary30, fontWeight: FontWeight.w700),
        errorStyle: textTheme.labelSmall?.copyWith(color: themeColors.red, fontSize: 10.sp, height: 0.3),
        contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      ),
    );
  }

  static BaseColors _getThemeColors(ThemeMode mode) {
    return mode == ThemeMode.dark ? const DarkModeColors() : const LightModeColors();
  }
}
