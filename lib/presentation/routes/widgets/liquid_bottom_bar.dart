import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';

class LiquidBottomBar extends StatelessWidget {
  final double pageOffset;
  final Function(int) onItemSelected;
  final List<LiquidTabItem> items;
  final bool isDragging;
  final Function(DragUpdateDetails)? onHorizontalDragUpdate;
  final Function(DragEndDetails)? onHorizontalDragEnd;
  final Function(DragStartDetails)? onHorizontalDragStart;

  const LiquidBottomBar({
    super.key,
    required this.pageOffset,
    required this.onItemSelected,
    required this.items,
    this.isDragging = false,
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
        margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 5.h),
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
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 200),
                builder: (context, value, child) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    transform: Matrix4.identity()
                      ..scaleByDouble(isDragging ? 1.08 : 1.0, isDragging ? 1.08 : 1.0, 1.0, 1.0), // Scale up only when dragging
                    transformAlignment: Alignment.center,
                    child: Transform.scale(
                      // Subtle liquid grow effect during move
                      scale: 1.0 + (0.04 * (1.0 - (pageOffset - pageOffset.round()).abs() * 2).clamp(0.0, 1.0)),
                      child: Container(
                        width: (MediaQuery.of(context).size.width - 40.w) / items.length * 0.84,
                        height: 54.h,
                        margin: EdgeInsets.symmetric(horizontal: 10.w),
                        decoration: BoxDecoration(
                          color: AppTheme.colors.primary,
                          borderRadius: BorderRadius.circular(22.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.colors.primary.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
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
                        Transform.translate(
                          offset: Offset(0, -4.h * t), // Pop up effect
                          child: Transform.scale(
                            scale: 1.0 + (0.22 * t), // Intensified scale
                            child: SvgPicture.asset(
                              item.icon,
                              height: 20.sp,
                              colorFilter: ColorFilter.mode(
                                Color.lerp(const Color(0xFF94A3B8), Colors.white, t)!,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 2.h),
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
