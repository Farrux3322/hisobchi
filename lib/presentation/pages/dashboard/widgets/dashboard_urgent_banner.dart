import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ehisob/presentation/assets/asset_index.dart';
import '../due_dates/due_dates_page.dart';

class DashboardUrgentBanner extends StatelessWidget {
  final int expiredCount;
  final int todayCount;
  final int qarzExpired;
  final int installmentExpired;
  final int qarzToday;
  final int installmentToday;

  const DashboardUrgentBanner({
    super.key,
    required this.expiredCount,
    required this.todayCount,
    required this.qarzExpired,
    required this.installmentExpired,
    required this.qarzToday,
    required this.installmentToday,
  });

  @override
  Widget build(BuildContext context) {
    if (expiredCount == 0 && todayCount == 0) {
      return const SizedBox.shrink();
    }

    final isExpired = expiredCount > 0;
    final count = isExpired ? expiredCount : todayCount;
    final primaryColor =
        isExpired ? const Color(0xFFEF4444) : const Color(0xFFF59E0B);
    final bgColor =
        isExpired ? const Color(0xFFFEF2F2) : const Color(0xFFFFFBEB);
    final borderColor =
        isExpired ? const Color(0xFFFEE2E2) : const Color(0xFFFEF3C7);
    final icon = isExpired
        ? Icons.warning_amber_rounded
        : Icons.notifications_active_rounded;
    final title = isExpired
        ? '$count ta to\'lov muddati o\'tgan!'
        : '$count ta to\'lov bugun kutilmoqda!';
    final subtitle = isExpired
        ? 'Qarzdorlikni tezroq undirish chorasini ko\'ring'
        : 'Bugungi rejalashtirilgan to\'lovlar jadvali';

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: primaryColor, size: 22.sp),
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
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14.r),
              onTap: () {
                HapticFeedback.lightImpact();
                if (isExpired) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DueDatesPage(
                        title: "Kechiktirilgan",
                        qarzType: 'qarz_expired',
                        installmentType: 'installment_expired',
                        initialTabIndex: 0,
                        qarzCount: qarzExpired,
                        installmentCount: installmentExpired,
                      ),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DueDatesPage(
                        title: 'Bugun muddati',
                        qarzType: 'qarz_today',
                        installmentType: 'installment_today',
                        initialTabIndex: 0,
                        qarzCount: qarzToday,
                        installmentCount: installmentToday,
                      ),
                    ),
                  );
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Ko\'rish',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 10.sp,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
