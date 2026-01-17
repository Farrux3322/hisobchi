import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hisobchi/infrastructure/models/cost_type_model.dart';
import 'package:hisobchi/presentation/assets/theme/app_theme.dart';

class ProjectCostTypeSelector extends StatelessWidget {
  final CostTypeModel? selectedCostType;
  final VoidCallback onTap;

  const ProjectCostTypeSelector({
    super.key,
    required this.selectedCostType,
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
              'Chiqim turi',
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
                  color:  AppTheme.colors.gray,
                  width: 1
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.category_outlined, color: AppTheme.colors.primary, size: 20.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      selectedCostType?.name ?? 'Chiqim turini tanlang',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: selectedCostType != null ? FontWeight.w500 : FontWeight.w400,
                        color: selectedCostType == null ? const Color(0xFF94A3B8) : AppTheme.colors.black,
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
