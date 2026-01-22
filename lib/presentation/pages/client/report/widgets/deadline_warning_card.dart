import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DeadlineWarningCard extends StatelessWidget {
  final DateTime deadline;
  final int daysLeft;

  const DeadlineWarningCard({
    super.key,
    required this.deadline,
    required this.daysLeft,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCritical = daysLeft <= 3;
    final Color mainColor = isCritical ? const Color(0xFFEF4444) : const Color(0xFFF59E0B);
    final Color bgColor = mainColor.withOpacity(0.08);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: mainColor.withOpacity(0.2), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: mainColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.schedule_rounded,
              color: mainColor,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Yaqinlashmoqda',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: mainColor,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Muddat: ${_formatDate(deadline)}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: mainColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: mainColor,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              '$daysLeft kun qoldi',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
