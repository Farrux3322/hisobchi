import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../presentation/assets/theme/app_theme.dart';

class PSAdvanceToggle extends StatelessWidget {
  final bool isEnabled;
  final ValueChanged<bool> onToggled;

  const PSAdvanceToggle({
    super.key,
    required this.isEnabled,
    required this.onToggled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onToggled(!isEnabled),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppTheme.colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isEnabled
                ? const Color(0xFFF97316)
                : AppTheme.colors.divider,
            width: isEnabled ? 1.5.w : 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44.r,
              height: 44.r,
              decoration: BoxDecoration(
                color: (isEnabled ? const Color(0xFFF97316) : AppTheme.colors.divider).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isEnabled ? Icons.payments_rounded : Icons.money_off_rounded,
                color: isEnabled ? const Color(0xFFF97316) : AppTheme.colors.iconColor,
                size: 24.r,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Avans to\'lovi',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: isEnabled ? const Color(0xFFF97316) : AppTheme.colors.black,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Dastlabki to\'lov miqdorini belgilash',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppTheme.colors.gray,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52.r,
              height: 30.r,
              decoration: BoxDecoration(
                color: isEnabled ? const Color(0xFFF97316) : AppTheme.colors.divider,
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: isEnabled ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 24.r,
                  height: 24.r,
                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                  decoration: BoxDecoration(
                    color: AppTheme.colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
