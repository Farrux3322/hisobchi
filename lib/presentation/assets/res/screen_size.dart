import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

@immutable
class ScreenSize {

  const ScreenSize._();

  static late double w4;
  static late double w6;
  static late double w8;
  static late double w10;
  static late double w12;
  static late double w14;
  static late double w16;
  static late double w20;
  static late double w24;

  static late double h4;
  static late double h8;
  static late double h10;
  static late double h12;
  static late double h14;
  static late double h16;
  static late double h18;
  static late double h20;
  static late double h24;
  static late double h32;
  static late double h36;

  static double adaptiveViewPadding(BuildContext context) {
    if (MediaQuery.of(context).viewPadding.bottom == 0) {
      return h16;
    } else {
      return MediaQuery.of(context).viewPadding.bottom;
    }
  }

  static double adaptiveViewInsets(BuildContext context) {
    if (MediaQuery.of(context).viewInsets.bottom == 0) {
      return h16;
    } else {
      return MediaQuery.of(context).viewInsets.bottom;
    }
  }

  static Future<void> setSizes() async {
    w4 = 4.w;
    w6 = 6.w;
    w8 = 8.w;
    w10 = 10.w;
    w12 = 12.w;
    w14 = 14.w;
    w16 = 16.w;
    w20 = 20.w;
    w24 = 24.w;

    h4 = 4.h;
    h8 = 8.h;
    h10 = 10.h;
    h12 = 12.h;
    h14 = 14.h;
    h16 = 16.h;
    h18 = 18.h;
    h20 = 20.h;
    h24 = 24.h;
    h32 = 32.h;
    h36 = 36.h;
  }
}
