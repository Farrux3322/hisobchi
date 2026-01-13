import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';

class LiquidBottomBar extends StatelessWidget {
  final double pageOffset;
  final Function(int) onItemSelected;
  final List<LiquidTabItem> items;
  final Function(DragUpdateDetails)? onHorizontalDragUpdate;
  final Function(DragEndDetails)? onHorizontalDragEnd;
  final Function(DragStartDetails)? onHorizontalDragStart;

  const LiquidBottomBar({
    super.key,
    required this.pageOffset,
    required this.onItemSelected,
    required this.items,
    this.onHorizontalDragUpdate,
    this.onHorizontalDragEnd,
    this.onHorizontalDragStart,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: onHorizontalDragStart,
      onHorizontalDragUpdate: onHorizontalDragUpdate,
      onHorizontalDragEnd: onHorizontalDragEnd,
      child: Container(
        margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
        height: 72.h,
        child: Stack(
          children: [
            // Frosted Glass Background
            ClipRRect(
              borderRadius: BorderRadius.circular(36.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(36.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 0.8,
                  ),
                  ),
                ),
              ),
            ),
            
            // Real-time Liquid Indicator
            Align(
              alignment: Alignment(
                -1.0 + (pageOffset * (2.0 / (items.length - 1))),
                0,
              ),
              child: Container(
                width: (MediaQuery.of(context).size.width - 40.w) / items.length * 0.82,
                height: 54.h,
                margin: EdgeInsets.symmetric(horizontal: 10.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.colors.primary,
                      AppTheme.colors.primary.withValues(alpha: 0.85),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.colors.primary.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
              ),
            ),
            
            // Icons
            Row(
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                
                // Calculate scale/opacity based on proximity to this tab
                final double distance = (pageOffset - index).abs();
                final double t = (1.0 - distance).clamp(0.0, 1.0);
                
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onItemSelected(index),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Transform.scale(
                          scale: 1.0 + (0.15 * t),
                          child: SvgPicture.asset(
                            item.icon,
                            height: 22.sp,
                            colorFilter: ColorFilter.mode(
                              Color.lerp(const Color(0xFF94A3B8), Colors.white, t)!,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          item.label,
                          style: TextStyle(
                            color: Color.lerp(const Color(0xFF94A3B8), Colors.white, t),
                            fontSize: 10.sp,
                            fontWeight: t > 0.5 ? FontWeight.w700 : FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class LiquidTabItem {
  final String icon;
  final String label;

  LiquidTabItem({required this.icon, required this.label});
}
