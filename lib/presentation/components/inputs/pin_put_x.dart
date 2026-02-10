import 'package:flutter/material.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:pinput/pinput.dart';

class PintPutX extends StatelessWidget {
  const PintPutX({
    super.key,
    this.onComplete,
    this.controller,
  });

  final Function(String)? onComplete;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
        width: 0.15.sw,
        height: 0.15.sw,

        textStyle: AppTheme.data.textTheme.titleMedium?.copyWith(color: AppTheme.colors.primary),
        decoration: BoxDecoration(border: Border.all(width: 2, color: AppTheme.colors.primary), borderRadius: BorderRadius.circular(16.r)));

    return Pinput(
      length: 4,
      autofocus: true,
      controller: controller,
      cursor: ColoredBox(color: AppTheme.colors.primary, child: SizedBox(width: 1.5, height: 20.h)),
      androidSmsAutofillMethod: AndroidSmsAutofillMethod.smsUserConsentApi,
      listenForMultipleSmsOnAndroid: true,
      defaultPinTheme: defaultPinTheme,
      hapticFeedbackType: HapticFeedbackType.lightImpact,
      focusedPinTheme: defaultPinTheme,
      submittedPinTheme: defaultPinTheme,
      errorPinTheme: defaultPinTheme.copyWith(decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.r), border: Border.all(color: AppTheme.colors.red))),
      onCompleted: onComplete,
    );
  }
}
