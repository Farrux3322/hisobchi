import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:hisobchi/application/subscription/subscription_bloc.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/routes/entity/routes.dart';
import 'package:hisobchi/infrastructure/services/permission_extension.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class UsageSection extends StatefulWidget {
  const UsageSection({super.key});

  @override
  State<UsageSection> createState() => _UsageSectionState();
}

class _UsageSectionState extends State<UsageSection> with SingleTickerProviderStateMixin {
  bool _isExpanded = true;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, state) {
        if (state.infoStatus == Status.loading) {
          return const _UsageSkeleton();
        }

        final subscription = state.subscriptionInfo?.subscription;
        final planType = subscription?.plan?.displayName ?? 'Free';
        final planExpiry = subscription?.currentPeriod?.end ?? '-';
        final usage = subscription?.usage;

        return Column(
          children: [
            _SubscriptionInfoCard(
              planType: planType,
              planExpiry: planExpiry,
              statusLabel: subscription?.statusLabel,
              status: subscription?.status ?? '',
              daysUntilDue: subscription?.daysUntilDue,
              daysPastDue: subscription?.daysPastDue,
              waveController: _waveController,
            ),
            Gap(20.h),

            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(32.r),
                border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1.5.w),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 24.r,
                    offset: Offset(0, 8.h),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _isExpanded = !_isExpanded),
                    child: Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: AppTheme.colors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(Icons.bar_chart_rounded, color: AppTheme.colors.primary, size: 20.sp),
                          ),
                          Gap(12.w),
                          Expanded(
                            child: Text(
                              'Limitlar va Foydalanish',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.colors.black,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          AnimatedRotation(
                            turns: _isExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 300),
                            child: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.withValues(alpha: 0.5), size: 28.sp),
                          ),
                        ],
                      ),
                    ),
                  ),

                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: _isExpanded
                        ? Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final double itemWidth = (constraints.maxWidth - 12.w) / 2;
                          return Wrap(
                            spacing: 12.w,
                            runSpacing: 12.h,
                            children: [
                              _UsageProgressItem(
                                title: 'Loyihalar',
                                icon: AppIcons.project,
                                current: usage?.projects?.current ?? 0,
                                max: usage?.projects?.max,
                                color: const Color(0xFF006D77),
                                width: itemWidth,
                              ),
                              _UsageProgressItem(
                                title: 'Mijozlar',
                                icon: AppIcons.clients,
                                current: usage?.customers?.current ?? 0,
                                max: usage?.customers?.max,
                                color: const Color(0xFF6366F1),
                                width: itemWidth,
                              ),
                              _UsageProgressItem(
                                title: 'Xodimlar',
                                icon: AppIcons.clients,
                                current: usage?.users?.current ?? 0,
                                max: usage?.users?.max,
                                color: const Color(0xFFA855F7),
                                width: itemWidth,
                              ),
                              _UsageProgressItem(
                                title: 'SMS',
                                icon: AppIcons.sms,
                                current: usage?.sms?.current ?? 0,
                                max: usage?.sms?.max,
                                color: Colors.orangeAccent,
                                width: itemWidth,
                                onAction: () => context.pushNamed(Routes.smsBuyPage.name),
                              ),
                            ],
                          );
                        },
                      ),
                    )
                        : const SizedBox(width: double.infinity),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SubscriptionInfoCard extends StatelessWidget {
  final String planType;
  final String planExpiry;
  final String status;
  final String? statusLabel;
  final num? daysUntilDue;
  final num? daysPastDue;
  final AnimationController waveController;

  const _SubscriptionInfoCard({
    required this.planType,
    required this.planExpiry,
    required this.status,
    this.statusLabel,
    this.daysPastDue,
    this.daysUntilDue,
    required this.waveController,
  });

  @override
  Widget build(BuildContext context) {
    final int days = daysUntilDue?.round() ?? 0;
    final int dueDays = 4 - (daysPastDue?.round() ?? 0);
    final int displayDays = status == 'GRACE_PERIOD' ? dueDays : days;
    // final int displayDays = status == 'GRACE_PERIOD' ? dueDays : 3;
    double progress = (displayDays / 365).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.colors.primary, AppTheme.colors.primary.withBlue(180)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.colors.primary.withValues(alpha: 0.3),
            blurRadius: 20.r,
            offset: Offset(0, 10.h),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30.r),
        child: Stack(
          children: [
            Positioned(
              right: -15.w, bottom: -15.h,
              child: Opacity(
                opacity: 0.1,
                child: SvgPicture.asset(AppIcons.crown, width: 130.w, height: 130.w, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
              ),
            ),
            Positioned(
              left: 0, top: -10.h,
              child: Opacity(
                opacity: 0.08,
                child: SvgPicture.asset(AppIcons.crown, width: 80.w, height: 80.w, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(22.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (statusLabel != null) _buildStatusBadge(statusLabel!),
                            Gap(4.h),
                            _buildPlanTitle(planType),
                          ],
                        ),
                      ),
                      _PermissionBlurredWidget(hasPermission: context.hasPermission('plan_about.view'),
                      child: _buildProgressIndicator(displayDays, progress)),
                    ],
                  ),
                  Gap(8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Amal qilish muddati:',
                            style: TextStyle(fontSize: 12.sp, color: Colors.white.withValues(alpha: 0.7), fontWeight: FontWeight.w500),
                          ),
                          Gap(4.h),
                          _PermissionBlurredWidget(
                            hasPermission: context.hasPermission('plan_about.view'),
                            child: Text(
                              planExpiry,
                              style: TextStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                      _buildUpgradeButton(context),
                    ],
                  ),
                  if (status != 'ACTIVE' && status != 'GRACE_PERIOD') ...[
                    Gap(16.h),
                    _buildStatusNotice(status),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String label) {
    return Container(
      margin: EdgeInsets.only(bottom: 6.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(fontSize: 9.sp, color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 0.8),
      ),
    );
  }

  Widget _buildPlanTitle(String title) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: 'Tarif: ', style: TextStyle(fontSize: 18.sp, color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.w500)),
          TextSpan(text: title, style: TextStyle(fontSize: 26.sp, color: Colors.white, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(int days, double progress) {
    final Color activeColor = _getDynamicColor(days);

    return Container(
      width: 78.w,
      height: 78.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withValues(alpha: 0.15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 5),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(120.w, 120.w),
            painter: CleanProgressPainter(
              progress: progress,
              color: activeColor,
            ),
          ),

          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$days',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'KUN',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 8.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }



  Widget _buildUpgradeButton(BuildContext context) {
    return ZoomTapAnimation(
      onTap: () => context.pushNamed(Routes.subscription.name),
      child: Container(
        height: 28.h,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFDE08D), Color(0xFFF9C449), Color(0xFFB8860B)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [BoxShadow(color: const Color(0xFFB8860B).withValues(alpha: 0.4), blurRadius: 10.r, offset: Offset(0, 4.h))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14.r),
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: waveController,
                builder: (context, child) {
                  return Stack(
                    children: [
                      CustomPaint(size: Size(120.w, 44.h), painter: WavePainter(animationValue: waveController.value, color: Colors.white)),
                      Transform.scale(
                        scaleX: -1,
                        child: CustomPaint(size: Size(120.w, 44.h), painter: WavePainter(animationValue: waveController.value * 1.5, color: const Color(0xFFFFD700))),
                      ),
                    ],
                  );
                },
              ),
              Material(
                color: Colors.transparent,
                child: Center(
                  child: Text(
                    'YANGILASH',
                    style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w900, letterSpacing: 1, shadows: const [Shadow(color: Colors.black26, blurRadius: 4)]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusNotice(String status) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12.r)),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.white, size: 18.sp),
          Gap(10.w),
          Expanded(child: Text(status == 'READ_ONLY' ? "Hisobingiz cheklangan rejimda." : "Hisobingiz faol emas.", style: TextStyle(color: Colors.white, fontSize: 12.sp))),
        ],
      ),
    );
  }

  Color _getDynamicColor(int days) {
    if (days <= 3) return Colors.redAccent;
    if (days <= 20) return Colors.orangeAccent;
    return Colors.white.withValues(alpha: ((days - 20) / 345).clamp(0.4, 1.0));
  }
}

class _UsageProgressItem extends StatefulWidget {
  final String title;
  final String icon;
  final int current;
  final dynamic max;
  final Color color;
  final double width;
  final VoidCallback? onAction;

  const _UsageProgressItem({super.key, required this.title, required this.icon, required this.current, required this.max, required this.color, required this.width, this.onAction});

  @override
  State<_UsageProgressItem> createState() => _UsageProgressItemState();
}

class _UsageProgressItemState extends State<_UsageProgressItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this)..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isUnlimited = (widget.max is String && (widget.max.toLowerCase() == 'unlimited' || widget.max == '-1')) || (widget.max is num && widget.max == -1);
    final int maxValue = isUnlimited ? 0 : (widget.max is int ? widget.max : int.tryParse(widget.max.toString()) ?? 0);
    final double targetProgress = isUnlimited ? (widget.current > 0 ? 1.0 : 0.0) : (maxValue > 0 ? (widget.current / maxValue).clamp(0.0, 1.0) : 0.0);

    return Container(
      width: widget.width,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5.w),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15.r, offset: Offset(0, 8.h))],
      ),
      child: Stack(
        children: [
          if (widget.onAction != null)
            Positioned(
              top: 0, right: 0,
              child: Material(
                color: widget.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(18.r), topRight: Radius.circular(28.r)),
                child: InkWell(
                  onTap: widget.onAction,
                  child: Padding(padding: EdgeInsets.all(10.w), child: Icon(Icons.add_rounded, color: widget.color, size: 22.sp)),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44.w, height: 44.w, padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(color: widget.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14.r)),
                  child: SvgPicture.asset(widget.icon, colorFilter: ColorFilter.mode(widget.color, BlendMode.srcIn)),
                ),
                Gap(16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(child: Text(widget.title, maxLines: 1, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFF4B5563)))),
                    _PermissionBlurredWidget(
                      hasPermission: context.hasPermission('usage.view'),
                      child: RichText(
                        text: TextSpan(children: [
                          TextSpan(text: '${widget.current}', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: const Color(0xFF111827))),
                          TextSpan(text: isUnlimited ? ' / ∞' : ' / $maxValue', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.grey.withValues(alpha: 0.6))),
                        ]),
                      ),
                    ),
                  ],
                ),
                Gap(10.h),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Stack(
                      children: [
                        Container(height: 8.h, width: double.infinity, decoration: BoxDecoration(color: widget.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(22.r))),
                        FractionallySizedBox(
                          widthFactor: _controller.value * targetProgress,
                          child: Container(height: 8.h, decoration: BoxDecoration(color: widget.color, borderRadius: BorderRadius.circular(22.r), boxShadow: [BoxShadow(color: widget.color.withValues(alpha: 0.2), blurRadius: 8.r)])),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final double animationValue;
  final Color color;
  WavePainter({required this.animationValue, required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: 0.3)..style = PaintingStyle.fill;
    final path = Path();
    final yOffset = size.height * 0.5;
    path.moveTo(0, yOffset);
    for (double i = 0; i <= size.width; i++) {
      path.lineTo(i, yOffset + math.sin((i / size.width * 2 * math.pi) + (animationValue * 2 * math.pi)) * 5);
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class GradientProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  GradientProgressPainter({required this.progress, required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    canvas.drawCircle(center, radius, Paint()..color = Colors.white.withValues(alpha: 0.15)..style = PaintingStyle.stroke..strokeWidth = 8.w);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -1.57, 6.28 * progress, false, Paint()..shader = SweepGradient(colors: [color.withValues(alpha: 0.3), color]).createShader(Rect.fromCircle(center: center, radius: radius))..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeWidth = 8.w);
  }
  @override bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class _PermissionBlurredWidget extends StatelessWidget {
  final Widget child;
  final bool hasPermission;
  const _PermissionBlurredWidget({required this.child, required this.hasPermission});
  @override
  Widget build(BuildContext context) {
    if (hasPermission) return child;
    return ImageFiltered(imageFilter: ui.ImageFilter.blur(sigmaX: 5.w, sigmaY: 5.w), child: child);
  }
}

class _UsageSkeleton extends StatelessWidget {
  const _UsageSkeleton();
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!,
      child: Column(children: [Container(height: 150.h, margin: EdgeInsets.only(bottom: 20.h), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30.r))), Container(height: 300.h, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32.r)))]),
    );
  }
}


class CleanProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  CleanProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2);
    final strokeWidth = 10.w;

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 1.5
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6.r)
      ..color = color.withValues(alpha: 0.3);

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        colors: [
          color.withValues(alpha: 0.7),
          color,
          color.withValues(alpha: 0.9),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    final double sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      glowPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CleanProgressPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}