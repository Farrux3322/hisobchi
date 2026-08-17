import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:ehisob/presentation/assets/asset_index.dart';
import 'package:ehisob/presentation/assets/res/screen_size.dart';
import 'package:ehisob/presentation/assets/theme/app_theme.dart';

class TextFieldX extends StatelessWidget {
  const TextFieldX({
    super.key,
    this.title,
    this.initValue,
    this.hint,
    this.controller,
    this.validator,
    this.inputType = TextInputType.text,
    this.onTap,
    this.inputFormatters,
    this.suffix,
    this.maxLine = 1,
    this.suffixWidth,
    this.obscureText = false,
    this.onChanged,
    this.titleInside = false,
    this.readOnly = false,
  });

  final String? title;
  final String? initValue;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType inputType;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffix;
  final int? maxLine;
  final double? suffixWidth;
  final bool obscureText;
  final bool titleInside;
  final bool readOnly;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    Widget current = TextFormField(
      obscureText: obscureText,
      controller: controller,
      initialValue: initValue,
      textCapitalization: TextCapitalization.sentences,
      style: AppTheme.data.textTheme.titleMedium,
      validator: validator,
      keyboardType: inputType,
      readOnly: onTap != null || readOnly,
      onTap: onTap,
      maxLines: maxLine,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: suffix != null
            ? SizedBox(
                width: suffixWidth ?? ScreenSize.w24,
                height: ScreenSize.w24,
                child: Center(child: suffix),
              )
            : null,
      ),
    );

    if (title != null) {
      if (titleInside) {
        current = Container(
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppTheme.colors.white),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap(8.h),
              Text(
                title!,
                style: AppTheme.data.textTheme.titleMedium?.copyWith(
                  color: AppTheme.colors.gray,
                ),
              ),
              Gap(6.h),
              Theme(
                data: AppTheme.data.copyWith(
                  inputDecorationTheme: const InputDecorationTheme(
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
                child: SizedBox(
                  height: 28.h,
                  child: current,
                ),
              ),
            ],
          ),
        );
      } else {
        current = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title!,
              style: AppTheme.data.textTheme.titleMedium,
            ),
            Gap(6.h),
            current
          ],
        );
      }
    }

    return current;
  }
}
