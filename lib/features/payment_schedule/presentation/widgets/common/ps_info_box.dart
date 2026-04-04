import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../presentation/assets/theme/app_theme.dart';

enum InfoBoxType { info, success, warning, error }

class PSInfoBox extends StatelessWidget {
  final InfoBoxType type;
  final String title;
  final String description;

  const PSInfoBox({
    super.key,
    required this.type,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: colors.border,
          width: 1.w,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: colors.iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIcon(),
              color: colors.icon,
              size: 20.r,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: colors.text,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: colors.text.withValues(alpha: 0.8),
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _InfoBoxColors _getColors() {
    switch (type) {
      case InfoBoxType.info:
        return _InfoBoxColors(
          background: AppTheme.colors.primary.withValues(alpha: 0.05),
          border: AppTheme.colors.primary.withValues(alpha: 0.1),
          icon: AppTheme.colors.primary,
          iconBackground: AppTheme.colors.primary.withValues(alpha: 0.1),
          text: AppTheme.colors.primary,
        );
      case InfoBoxType.success:
        return _InfoBoxColors(
          background: AppTheme.colors.green.withValues(alpha: 0.05),
          border: AppTheme.colors.green.withValues(alpha: 0.1),
          icon: AppTheme.colors.green,
          iconBackground: AppTheme.colors.green.withValues(alpha: 0.1),
          text: const Color(0xFF166534), // Darker green for text readability
        );
      case InfoBoxType.warning:
        return _InfoBoxColors(
          background: const Color(0xFFFFF7ED),
          border: const Color(0xFFFFEDD5),
          icon: const Color(0xFFF97316),
          iconBackground: const Color(0xFFFFEDD5),
          text: const Color(0xFF9A3412),
        );
      case InfoBoxType.error:
        return _InfoBoxColors(
          background: const Color(0xFFFFF1F2),
          border: const Color(0xFFFFCDD2),
          icon: AppTheme.colors.red,
          iconBackground: AppTheme.colors.red.withValues(alpha: 0.12),
          text: const Color(0xFF9B1C1C),
        );
    }
  }

  IconData _getIcon() {
    switch (type) {
      case InfoBoxType.info:
        return Icons.info_rounded;
      case InfoBoxType.success:
        return Icons.check_circle_rounded;
      case InfoBoxType.warning:
        return Icons.warning_rounded;
      case InfoBoxType.error:
        return Icons.error_rounded;
    }
  }
}

class _InfoBoxColors {
  final Color background;
  final Color border;
  final Color icon;
  final Color iconBackground;
  final Color text;

  const _InfoBoxColors({
    required this.background,
    required this.border,
    required this.icon,
    required this.iconBackground,
    required this.text,
  });
}
