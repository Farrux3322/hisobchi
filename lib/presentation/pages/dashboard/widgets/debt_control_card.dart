import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ehisob/infrastructure/services/permission_extension.dart';
import 'package:ehisob/presentation/assets/asset_index.dart';
import 'package:ehisob/presentation/components/toast/toast.dart';
import '../../client/report/report_client_main_page.dart';
import '../due_dates/due_dates_page.dart';
import 'animated_counter.dart';

class DebtControlCard extends StatelessWidget {
  final int totalCount;
  final int expiredCount;
  final int todayCount;
  final int soonCount;
  final int qarzExpired;
  final int installmentExpired;
  final int qarzToday;
  final int installmentToday;
  final int qarz3Days;
  final int installment3Days;

  const DebtControlCard({
    super.key,
    required this.totalCount,
    required this.expiredCount,
    required this.todayCount,
    required this.soonCount,
    required this.qarzExpired,
    required this.installmentExpired,
    required this.qarzToday,
    required this.installmentToday,
    required this.qarz3Days,
    required this.installment3Days,
  });

  void _openDueDates(
    BuildContext context, {
    required String title,
    required String qarzType,
    required String installmentType,
    int initialTab = 0,
    required int qarzCount,
    required int instCount,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DueDatesPage(
          title: title,
          qarzType: qarzType,
          installmentType: installmentType,
          initialTabIndex: initialTab,
          qarzCount: qarzCount,
          installmentCount: instCount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sumDue = expiredCount + todayCount + soonCount;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppTheme.colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.colors.primary.withValues(alpha: 0.06),
            blurRadius: 24,
            spreadRadius: -2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: AppTheme.colors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      color: AppTheme.colors.primary,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Qarzdorlik nazorati',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.colors.black,
                          letterSpacing: -0.2,
                        ),
                      ),
                      Text(
                        'Muddatlar bo\'yicha tahlil',
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: AppTheme.colors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10.r),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    if (!context.hasPermission('report_partners.view')) {
                      Toast.showWarningToast(message: 'Sizda bunday huquq yo\'q');
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReportClientMainPage()),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppTheme.colors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Hisobot',
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.colors.primary,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 10.sp,
                          color: AppTheme.colors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          if (sumDue > 0) ...[
            SizedBox(height: 16.h),
            _buildProportionBar(sumDue),
          ],

          SizedBox(height: 14.h),

          // 3 Modern Status Cards
          _buildStatusTile(
            context: context,
            label: 'Muddati o\'tgan to\'lovlar',
            subtitle: 'Kechiktirilgan qarzlar',
            count: expiredCount,
            themeColor: const Color(0xFFEF4444),
            bgColor: const Color(0xFFFEF2F2),
            borderColor: const Color(0xFFFEE2E2),
            icon: Icons.warning_amber_rounded,
            onTap: () => _openDueDates(
              context,
              title: "Kechiktirilgan",
              qarzType: 'qarz_expired',
              installmentType: 'installment_expired',
              qarzCount: qarzExpired,
              instCount: installmentExpired,
            ),
          ),
          SizedBox(height: 8.h),
          _buildStatusTile(
            context: context,
            label: 'Bugun to\'lanishi kerak',
            subtitle: 'Bugungi muddatli to\'lovlar',
            count: todayCount,
            themeColor: const Color(0xFFF59E0B),
            bgColor: const Color(0xFFFFFBEB),
            borderColor: const Color(0xFFFEF3C7),
            icon: Icons.today_rounded,
            onTap: () => _openDueDates(
              context,
              title: 'Bugun muddati',
              qarzType: 'qarz_today',
              installmentType: 'installment_today',
              qarzCount: qarzToday,
              instCount: installmentToday,
            ),
          ),
          SizedBox(height: 8.h),
          _buildStatusTile(
            context: context,
            label: '3 kun ichida kutilmoqda',
            subtitle: 'Yaqinlashayotgan muddatlar',
            count: soonCount,
            themeColor: const Color(0xFF3B82F6),
            bgColor: const Color(0xFFEFF6FF),
            borderColor: const Color(0xFFDBEAFE),
            icon: Icons.schedule_rounded,
            onTap: () => _openDueDates(
              context,
              title: '3 kun ichida',
              qarzType: 'qarz_3_days',
              installmentType: 'installment_3_days',
              qarzCount: qarz3Days,
              instCount: installment3Days,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProportionBar(int sumDue) {
    final expRatio = sumDue > 0 ? (expiredCount / sumDue) : 0.0;
    final todayRatio = sumDue > 0 ? (todayCount / sumDue) : 0.0;
    final soonRatio = sumDue > 0 ? (soonCount / sumDue) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6.r),
          child: SizedBox(
            height: 8.h,
            child: Row(
              children: [
                if (expRatio > 0)
                  Expanded(
                    flex: (expRatio * 1000).toInt(),
                    child: Container(color: const Color(0xFFEF4444)),
                  ),
                if (todayRatio > 0)
                  Expanded(
                    flex: (todayRatio * 1000).toInt(),
                    child: Container(color: const Color(0xFFF59E0B)),
                  ),
                if (soonRatio > 0)
                  Expanded(
                    flex: (soonRatio * 1000).toInt(),
                    child: Container(color: const Color(0xFF3B82F6)),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusTile({
    required BuildContext context,
    required String label,
    required String subtitle,
    required int count,
    required Color themeColor,
    required Color bgColor,
    required Color borderColor,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(7.r),
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: themeColor, size: 18.sp),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              AnimatedCounter(
                value: count,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: themeColor,
                ),
              ),
              SizedBox(width: 4.w),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12.sp,
                color: themeColor.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
