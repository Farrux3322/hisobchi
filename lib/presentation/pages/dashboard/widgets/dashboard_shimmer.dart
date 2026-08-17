import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ehisob/presentation/assets/asset_index.dart';

class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Column(
        children: [
          // Quick actions shimmer
          _buildCard(
            height: 100.h,
            child: Row(
              children: List.generate(
                4,
                (index) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Container(
                      height: 70.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 14.h),

          // Debt card shimmer
          _buildCard(
            height: 240.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(width: 140.w, height: 20.h, color: Colors.white),
                    Container(width: 60.w, height: 20.h, color: Colors.white),
                  ],
                ),
                SizedBox(height: 16.h),
                Container(width: double.infinity, height: 8.h, color: Colors.white),
                SizedBox(height: 16.h),
                Container(width: double.infinity, height: 42.h, color: Colors.white),
                SizedBox(height: 8.h),
                Container(width: double.infinity, height: 42.h, color: Colors.white),
                SizedBox(height: 8.h),
                Container(width: double.infinity, height: 42.h, color: Colors.white),
              ],
            ),
          ),
          SizedBox(height: 14.h),

          // Project card shimmer
          _buildCard(
            height: 170.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(width: 140.w, height: 20.h, color: Colors.white),
                    Container(width: 80.w, height: 20.h, color: Colors.white),
                  ],
                ),
                SizedBox(height: 16.h),
                Container(width: double.infinity, height: 8.h, color: Colors.white),
                SizedBox(height: 16.h),
                Row(
                  children: List.generate(
                    3,
                    (index) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Container(
                          height: 65.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required double height, required Widget child}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: Container(
        width: double.infinity,
        height: height,
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: AppTheme.colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: child,
      ),
    );
  }
}
