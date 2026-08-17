import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ehisob/infrastructure/models/worker_model.dart';
import 'package:ehisob/presentation/assets/theme/app_theme.dart';

class ProjectCostWorkerSelector extends StatelessWidget {
  final WorkerModel? selectedWorker;
  final VoidCallback onTap;

  const ProjectCostWorkerSelector({
    super.key,
    required this.selectedWorker,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Ishchi',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.colors.black,
              ),
            ),
            Text(
              ' *',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFEF4444),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: selectedWorker != null ? AppTheme.colors.primary : const Color(0xFFE2E8F0),
                  width: selectedWorker != null ? 2 : 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.person_outline, color: AppTheme.colors.primary, size: 20.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      selectedWorker?.name ?? 'Ishchini tanlang',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: selectedWorker != null ? FontWeight.w500 : FontWeight.w400,
                        color: selectedWorker == null ? const Color(0xFF94A3B8) : AppTheme.colors.black,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 18.sp, color: const Color(0xFF94A3B8)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
