import 'dart:math' as math;
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
        margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0.h),
        height: 72.h,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Shadow for the whole bar (Layered for iOS 26 depth)
            Positioned.fill(
              top: 12,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(36.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                      spreadRadius: -6,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                      spreadRadius: -2,
                    ),
                  ],
                ),
              ),
            ),

            // Frosted Glass Background
            ClipRRect(
              borderRadius: BorderRadius.circular(36.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(36.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.95),
                      width: 0.5,
                    ),
                    // gradient: LinearGradient(
                    //   begin: Alignment.topLeft,
                    //   end: Alignment.bottomRight,
                    //   colors: [
                    //     Colors.white.withValues(alpha: 0.45),
                    //     Colors.white.withValues(alpha: 0.15),
                    //   ],
                    // ),
                  ),
                  child: const Stack(
                    children: [
                       Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: _GrainPainter(opacity: 0.025, count: 700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Real-time Liquid Indicator (The Pill)
            Align(
              alignment: Alignment(
                -1.0 + (pageOffset * (2.0 / (items.length - 1))),
                0,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                width: (MediaQuery.of(context).size.width - 40.w) / items.length * 0.9,
                height: 58.h,
                margin: EdgeInsets.symmetric(horizontal: 5.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(36.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 1.0),
                      blurRadius: 2,
                      spreadRadius: 1,
                    ),
                  ],

                ),
                child: Stack(
                  children: [
                    // Specular dot for the pill
                    Positioned(
                      top: 6,
                      left: 10,
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white54,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.6),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Icons & Labels
            Row(
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;

                final double distance = (pageOffset - index).abs();
                final double t = (1.0 - distance).clamp(0.0, 1.0);

                final activeColor = AppTheme.colors.primary;
                final inactiveColor = const Color(0xFF1E293B);

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
                            height: 20.sp,
                            colorFilter: ColorFilter.mode(
                              Color.lerp(inactiveColor, activeColor, t)!,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          item.label,
                          style: TextStyle(
                            color: Color.lerp(inactiveColor.withValues(alpha: 0.7), activeColor, t),
                            fontSize: 10.sp,
                            fontWeight: t > 0.5 ? FontWeight.w700 : FontWeight.w600,
                            letterSpacing: 0.2,
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

class _GrainPainter extends CustomPainter {
  final double opacity;
  final int count;

  const _GrainPainter({this.opacity = 0.02, this.count = 600});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final paint = Paint()..style = PaintingStyle.fill;

    for (var i = 0; i < count; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final alpha = opacity * (0.6 + (random.nextDouble() * 0.4));
      final isLight = random.nextBool();
      paint.color = (isLight ? Colors.white : Colors.black).withValues(
        alpha: alpha,
      );
      canvas.drawRect(Rect.fromLTWH(x, y, 1, 1), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GrainPainter oldDelegate) => false;
}
