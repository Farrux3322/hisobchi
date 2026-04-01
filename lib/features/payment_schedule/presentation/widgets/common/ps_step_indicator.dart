import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../presentation/assets/theme/app_theme.dart';

class PSStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const PSStepIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: List.generate(totalSteps, (index) {
          final isCompleted = index < currentStep;
          final isCurrent = index == currentStep;
          
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        height: 6.h,
                        decoration: BoxDecoration(
                          color: isCompleted || isCurrent
                              ? AppTheme.colors.primary 
                              : AppTheme.colors.divider.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(10.r),
                          boxShadow: isCurrent ? [
                            BoxShadow(
                              color: AppTheme.colors.primary.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ] : [],
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        _getStepLabel(index),
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: (isCurrent || isCompleted) ? FontWeight.w800 : FontWeight.w600,
                          color: (isCurrent || isCompleted) 
                              ? AppTheme.colors.primary 
                              : AppTheme.colors.gray,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                if (index < totalSteps - 1) SizedBox(width: 8.w),
              ],
            ),
          );
        }),
      ),
    );
  }

  String _getStepLabel(int index) {
    switch (index) {
      case 0:
        return "Ma'lumotlar";
      case 1:
        return 'Grafik turi';
      case 2:
        return 'Taqsimot';
      default:
        return 'Bosqich';
    }
  }
}
