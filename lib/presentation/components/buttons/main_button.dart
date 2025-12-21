import 'package:flutter/material.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
class MainButton extends StatelessWidget {
  const MainButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.radius,
    this.showLoading = false,
    this.margin,
    this.backgroundColor,
    this.textColor,
    this.withShadow = true,
    this.useHeight = true,
    this.disabled = false,
  });

  final String text;
  final double? radius;
  final VoidCallback onPressed;
  final bool showLoading;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final Color? textColor;
  final bool withShadow;
  final bool useHeight;
  final bool? disabled;

  @override
  Widget build(BuildContext context) {
    return Bounce(
      onPressed: onPressed,
      duration: const Duration(milliseconds: 200),
      child: Container(
        width: double.infinity,
        height: useHeight ? 48.h : null,
        alignment: Alignment.center,
        padding: useHeight ? EdgeInsets.zero : EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius ?? 8.r),
          border: Border.all(
            color: AppTheme.colors.primary
          ),
          color: disabled! ? Colors.grey.shade600 : (backgroundColor ?? AppTheme.colors.primary),
          boxShadow: withShadow
              ? const [
                  BoxShadow(
                    color: Color.fromRGBO(97, 169, 253, 0.2),
                    offset: Offset(0, 2.47),
                    blurRadius: 7.41,
                  )
                ]
              : null,
        ),
        margin: margin,
        child: showLoading
            ? LoadingAnimationWidget.fallingDot(
                color: Colors.white,
                size: ScreenSize.h36,
              )
            : Text(
                text,
                style: AppTheme.data.textTheme.titleMedium?.copyWith(
                  color: disabled! ? Colors.grey.shade700 : (textColor ?? Colors.black),
                ),
                textAlign: TextAlign.center,
              ),
      ),
    );
  }
}
