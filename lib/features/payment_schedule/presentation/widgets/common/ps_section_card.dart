import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../presentation/assets/theme/app_theme.dart';

class PSSectionCard extends StatelessWidget {
  final String? label;
  final Widget child;
  final bool highlighted;
  final Color? highlightColor;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const PSSectionCard({
    super.key,
    this.label,
    required this.child,
    this.highlighted = false,
    this.highlightColor,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Padding(
            padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
            child: Text(
              label!,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.colors.gray,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16.r),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: padding ?? EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: AppTheme.colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: highlighted
                      ? (highlightColor ?? AppTheme.colors.primary)
                      : AppTheme.colors.divider,
                  width: highlighted ? 1.5.w : 1.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}
