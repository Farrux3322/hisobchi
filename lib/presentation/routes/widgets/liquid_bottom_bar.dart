import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ehisob/presentation/assets/asset_index.dart';

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
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final double bottomMargin = bottomInset > 0 ? (bottomInset + 4.h) : 14.h;
    final double totalWidth = MediaQuery.of(context).size.width - 36.w;
    final double tabWidth = totalWidth / items.length;

    // Fluid liquid stretching: when dragging, the capsule expands slightly
    final double basePillWidth = 54.w;
    final double pillWidth = isDragging ? (basePillWidth + 10.w) : basePillWidth;
    final double pillHeight = 44.h;

    // Calculate dynamic left offset for the active liquid capsule
    final double clampedOffset = pageOffset.clamp(0.0, items.length - 1.0);
    final double pillLeft = clampedOffset * tabWidth + (tabWidth - pillWidth) / 2;

    return GestureDetector(
      onHorizontalDragStart: onHorizontalDragStart,
      onHorizontalDragUpdate: onHorizontalDragUpdate,
      onHorizontalDragEnd: onHorizontalDragEnd,
      child: Container(
        margin: EdgeInsets.fromLTRB(18.w, 0, 18.w, bottomMargin),
        height: 64.h,
        child: Stack(
          alignment: Alignment.centerLeft,
          clipBehavior: Clip.none,
          children: [
            // Layered Deep Ambient Shadow
            Positioned.fill(
              top: 6,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.colors.primary.withValues(alpha: 0.16),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                      spreadRadius: -2,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                      spreadRadius: -2,
                    ),
                  ],
                ),
              ),
            ),

            // Frosted Acrylic Liquid Glass Shell
            ClipRRect(
              borderRadius: BorderRadius.circular(32.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.colors.white.withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(32.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.85),
                      width: 1.2,
                    ),
                  ),
                ),
              ),
            ),

            // Animated Liquid Morphing Capsule (Active Indicator)
            AnimatedPositioned(
              duration: isDragging ? Duration.zero : const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              left: pillLeft,
              top: (64.h - pillHeight) / 2,
              width: pillWidth,
              height: pillHeight,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.colors.primary,
                      const Color(0xFF6366F1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.colors.primary.withValues(alpha: 0.38),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
              ),
            ),

            // Tab Items with Cupertino Icons
            Row(
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;

                final double distance = (clampedOffset - index).abs();
                final double t = (1.0 - distance).clamp(0.0, 1.0);
                final bool isSelected = t > 0.45;

                return Expanded(
                  child: Tooltip(
                    message: item.label,
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onItemSelected(index);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        height: 64.h,
                        alignment: Alignment.center,
                        child: AnimatedScale(
                          duration: const Duration(milliseconds: 200),
                          scale: isSelected ? 1.12 : 1.0,
                          curve: Curves.easeOutBack,
                          child: Icon(
                            isSelected ? item.activeIcon : item.inactiveIcon,
                            size: isSelected ? 24.sp : 23.sp,
                            color: isSelected
                                ? Colors.white
                                : AppTheme.colors.textSecondary,
                          ),
                        ),
                      ),
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
  final IconData inactiveIcon;
  final IconData activeIcon;
  final String label;

  const LiquidTabItem({
    required this.inactiveIcon,
    required this.activeIcon,
    required this.label,
  });

  factory LiquidTabItem.single({
    required IconData icon,
    required String label,
  }) {
    return LiquidTabItem(
      inactiveIcon: icon,
      activeIcon: icon,
      label: label,
    );
  }
}
