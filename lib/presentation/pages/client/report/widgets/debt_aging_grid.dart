import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DebtAgingGrid extends StatelessWidget {
  final int overdueCount;
  final int todayCount;
  final int upcomingCount;
  final VoidCallback? onOverdueTap;
  final VoidCallback? onTodayTap;
  final VoidCallback? onUpcomingTap;

  const DebtAgingGrid({
    super.key,
    required this.overdueCount,
    required this.todayCount,
    required this.upcomingCount,
    this.onOverdueTap,
    this.onTodayTap,
    this.onUpcomingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w).copyWith(bottom: 8.h,top: 4.h),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.access_time_rounded, color: const Color(0xFF64748B), size: 18.sp),
              ),
              SizedBox(width: 4.w),
              Text(
                'Qarzlar ro\'yxati',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              Expanded(
                child: _buildDeadlineCard(
                  title: "Muddati o'tgan",
                  count: overdueCount,
                  icon: Icons.error_outline_rounded,
                  color: const Color(0xFFEF4444),
                  onTap: onOverdueTap,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildDeadlineCard(
                  title: 'Bugun',
                  count: todayCount,
                  icon: Icons.warning_amber_rounded,
                  color: const Color(0xFFF59E0B),
                  onTap: onTodayTap,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildDeadlineCard(
                  title: 'Yaqinlashmoqda',
                  subtitle: '(3 kun)',
                  count: upcomingCount,
                  icon: Icons.schedule_rounded,
                  color: const Color(0xFF3B82F6),
                  onTap: onUpcomingTap,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeadlineCard({
    required String title,
    String? subtitle,
    required int count,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 8.sp,
                      color: const Color(0xFF94A3B8),
                    ),
                  )
                else
                  SizedBox(height: 10.sp), // Spacer to maintain height consistency
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 14.sp),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
