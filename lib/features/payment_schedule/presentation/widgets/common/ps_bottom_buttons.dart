import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../presentation/assets/theme/app_theme.dart';

class PSBottomButtons extends StatelessWidget {
  final bool showBack;
  final VoidCallback? onBack;
  final VoidCallback? onContinue;
  final String continueLabel;
  final Color? continueColor;
  final bool isLoading;

  const PSBottomButtons({
    super.key,
    this.showBack = true,
    this.onBack,
    this.onContinue,
    this.continueLabel = 'Davom etish',
    this.continueColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, (24.h + MediaQuery.of(context).padding.bottom)),
      decoration: BoxDecoration(
        color: AppTheme.colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (showBack) ...[
            Expanded(
              flex: 2,
              child: OutlinedButton(
                onPressed: onBack,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  side: BorderSide(color: AppTheme.colors.divider),
                ),
                child: Text(
                  'Orqaga',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.colors.gray,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
          ],
          Expanded(
            flex: 3,
            child: ElevatedButton(
              onPressed: isLoading ? null : onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: continueColor ?? AppTheme.colors.primary,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                elevation: 0,
              ),
              child: isLoading
                  ? SizedBox(
                      height: 20.r,
                      width: 20.r,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.colors.white),
                      ),
                    )
                  : Text(
                      continueLabel,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
