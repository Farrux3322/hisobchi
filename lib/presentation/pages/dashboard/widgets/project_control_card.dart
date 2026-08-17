import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ehisob/presentation/assets/asset_index.dart';
import 'animated_counter.dart';

class ProjectControlCard extends StatelessWidget {
  final int totalCount;
  final int inProgressCount;
  final int frozenCount;
  final int completedCount;
  final VoidCallback onInProgressTap;
  final VoidCallback onFrozenTap;
  final VoidCallback onCompletedTap;
  final VoidCallback onAllTap;

  const ProjectControlCard({
    super.key,
    required this.totalCount,
    required this.inProgressCount,
    required this.frozenCount,
    required this.completedCount,
    required this.onInProgressTap,
    required this.onFrozenTap,
    required this.onCompletedTap,
    required this.onAllTap,
  });

  @override
  Widget build(BuildContext context) {
    final sum = inProgressCount + frozenCount + completedCount;

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
                      color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.folder_copy_rounded,
                      color: const Color(0xFF6366F1),
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Loyihalar nazorati',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.colors.black,
                          letterSpacing: -0.2,
                        ),
                      ),
                      Text(
                        'Jarayon va holat tahlili',
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
                    onAllTap();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Barchasi ($totalCount)',
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF6366F1),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 10.sp,
                          color: const Color(0xFF6366F1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          if (sum > 0) ...[
            SizedBox(height: 16.h),
            _buildProportionBar(sum),
          ],

          SizedBox(height: 14.h),

          // 3 Side-by-side Metric Cards
          Row(
            children: [
              Expanded(
                child: _buildProjectStatusCard(
                  label: 'Faol',
                  count: inProgressCount,
                  color: const Color(0xFF3B82F6),
                  bgColor: const Color(0xFFEFF6FF),
                  borderColor: const Color(0xFFDBEAFE),
                  icon: Icons.play_arrow_rounded,
                  onTap: onInProgressTap,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildProjectStatusCard(
                  label: 'Muzlatilgan',
                  count: frozenCount,
                  color: const Color(0xFFF59E0B),
                  bgColor: const Color(0xFFFFFBEB),
                  borderColor: const Color(0xFFFEF3C7),
                  icon: Icons.pause_rounded,
                  onTap: onFrozenTap,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildProjectStatusCard(
                  label: 'Tugallangan',
                  count: completedCount,
                  color: const Color(0xFF10B981),
                  bgColor: const Color(0xFFECFDF5),
                  borderColor: const Color(0xFFD1FAE5),
                  icon: Icons.check_rounded,
                  onTap: onCompletedTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProportionBar(int sum) {
    final progRatio = sum > 0 ? (inProgressCount / sum) : 0.0;
    final frozenRatio = sum > 0 ? (frozenCount / sum) : 0.0;
    final compRatio = sum > 0 ? (completedCount / sum) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6.r),
          child: SizedBox(
            height: 8.h,
            child: Row(
              children: [
                if (progRatio > 0)
                  Expanded(
                    flex: (progRatio * 1000).toInt(),
                    child: Container(color: const Color(0xFF3B82F6)),
                  ),
                if (frozenRatio > 0)
                  Expanded(
                    flex: (frozenRatio * 1000).toInt(),
                    child: Container(color: const Color(0xFFF59E0B)),
                  ),
                if (compRatio > 0)
                  Expanded(
                    flex: (compRatio * 1000).toInt(),
                    child: Container(color: const Color(0xFF10B981)),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProjectStatusCard({
    required String label,
    required int count,
    required Color color,
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
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(5.r),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 16.sp),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 10.sp,
                    color: color.withValues(alpha: 0.6),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.colors.textSecondary,
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              AnimatedCounter(
                value: count,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
