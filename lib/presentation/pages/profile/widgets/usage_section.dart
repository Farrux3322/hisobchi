import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ehisob/application/subscription/subscription_bloc.dart';
import 'package:ehisob/domain/common/constants.dart';
import 'package:ehisob/presentation/assets/asset_index.dart';
import 'package:ehisob/presentation/routes/entity/routes.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:ui' as ui;
import 'package:ehisob/infrastructure/services/permission_extension.dart';

class UsageSection extends StatefulWidget {
  const UsageSection({super.key});

  @override
  State<UsageSection> createState() => _UsageSectionState();
}

class _UsageSectionState extends State<UsageSection> with SingleTickerProviderStateMixin {
  bool _isExpanded = true;

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
            // Premium Subscription Card
            _SubscriptionInfoCard(
              planType: planType,
              planExpiry: planExpiry,
              statusLabel: subscription?.statusLabel,
              status: subscription?.status ?? '',
              daysUntilDue: subscription?.daysUntilDue,
              daysPastDue: subscription?.daysPastDue,
            ),
            SizedBox(height: 14.h),

            // Usage Progress Container
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _isExpanded = !_isExpanded);
                      },
                      borderRadius: BorderRadius.circular(20.r),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                color: AppTheme.colors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Icon(CupertinoIcons.chart_bar_fill, color: AppTheme.colors.primary, size: 16.sp),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(
                                'Limitlar va Foydalanish',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1E293B),
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ),
                            AnimatedRotation(
                              turns: _isExpanded ? 0.5 : 0,
                              duration: const Duration(milliseconds: 300),
                              child: Icon(
                                CupertinoIcons.chevron_down,
                                color: const Color(0xFF94A3B8),
                                size: 16.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: _isExpanded
                        ? Padding(
                            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                            child: Column(
                              children: [
                                _UsageProgressItem(
                                  title: 'Mijozlar',
                                  icon: AppIcons.clients,
                                  current: usage?.customers?.current ?? 0,
                                  max: usage?.customers?.max,
                                  color: const Color(0xFF6366F1), // Indigo
                                ),
                                SizedBox(height: 14.h),
                                _UsageProgressItem(
                                  title: 'Loyihalar',
                                  icon: AppIcons.project,
                                  current: usage?.projects?.current ?? 0,
                                  max: usage?.projects?.max,
                                  color: const Color(0xFF10B981), // Emerald
                                ),
                                SizedBox(height: 14.h),
                                _UsageProgressItem(
                                  title: 'Xodimlar',
                                  icon: AppIcons.clients,
                                  current: usage?.users?.current ?? 0,
                                  max: usage?.users?.max,
                                  color: const Color(0xFF8B5CF6), // Violet
                                ),
                                SizedBox(height: 14.h),
                                _UsageProgressItem(
                                  title: 'SMS Xabarlar',
                                  icon: AppIcons.sms,
                                  current: usage?.sms?.current ?? 0,
                                  max: usage?.sms?.max,
                                  color: const Color(0xFFF59E0B), // Amber
                                  onAction: () => context.pushNamed(Routes.smsBuyPage.name),
                                ),
                              ],
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

class _PermissionBlurredWidget extends StatelessWidget {
  final Widget child;
  final bool hasPermission;

  const _PermissionBlurredWidget({required this.child, required this.hasPermission});

  @override
  Widget build(BuildContext context) {
    if (hasPermission) return child;
    return ClipRect(
      child: ImageFiltered(imageFilter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5), child: child),
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

  const _SubscriptionInfoCard({
    required this.planType,
    required this.planExpiry,
    required this.status,
    this.statusLabel,
    this.daysPastDue,
    this.daysUntilDue,
  });

  @override
  Widget build(BuildContext context) {
    final int days = daysUntilDue?.round() ?? 0;
    final int dueDays = 4 - (daysPastDue?.round() ?? 0);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.colors.primary, const Color(0xFF0D9488)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.colors.primary.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -15,
            top: -15,
            child: Opacity(
              opacity: 0.08,
              child: SvgPicture.asset(
                AppIcons.crown,
                width: 110.r,
                height: 110.r,
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 48.r,
                      height: 48.r,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      padding: EdgeInsets.all(12.r),
                      child: SvgPicture.asset(
                        AppIcons.crown,
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: RichText(
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: 'Tarif: ',
                                              style: TextStyle(
                                                fontSize: 13.5.sp,
                                                color: Colors.white.withValues(alpha: 0.8),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            TextSpan(
                                              text: planType,
                                              style: TextStyle(
                                                fontSize: 16.sp,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (statusLabel != null) ...[
                                      SizedBox(width: 6.w),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(6.r),
                                        ),
                                        child: Text(
                                          statusLabel!,
                                          style: TextStyle(
                                            fontSize: 9.5.sp,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Material(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.r),
                                child: InkWell(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    context.pushNamed(Routes.subscription.name);
                                  },
                                  borderRadius: BorderRadius.circular(10.r),
                                  child: Container(
                                    padding: EdgeInsets.all(5.r),
                                    child: Icon(
                                      CupertinoIcons.add,
                                      color: AppTheme.colors.primary,
                                      size: 18.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Icon(
                                CupertinoIcons.clock_fill,
                                size: 12.sp,
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: _PermissionBlurredWidget(
                                  hasPermission: context.hasPermission('plan_about.view'),
                                  child: Text(
                                    'Amal qilish muddati: $planExpiry',
                                    style: TextStyle(
                                      fontSize: 11.5.sp,
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (status == 'ACTIVE' || status == 'GRACE_PERIOD') ...[
                  if (daysUntilDue != null && daysPastDue != null) ...[
                    SizedBox(height: 12.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.hourglass, color: Colors.white, size: 15.sp),
                          SizedBox(width: 6.w),
                          Text(
                            status == 'GRACE_PERIOD' ? 'Imtiyozli davr:' : 'Tarif tugashiga:',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.white.withValues(alpha: 0.95),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          _PermissionBlurredWidget(
                            hasPermission: context.hasPermission('plan_about.view'),
                            child: Text(
                              '${status == 'GRACE_PERIOD' ? dueDays : days} kun qoldi',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ] else ...[
                  SizedBox(height: 12.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.info_circle_fill, color: Colors.white, size: 15.sp),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            status == 'READ_ONLY'
                                ? 'Hisobingiz "Faqat ko\'rish" rejimida.'
                                : status == 'ARCHIVED'
                                    ? 'Sizning hisobingiz arxivlangan.'
                                    : 'Sizning hisobingiz o\'chirilgan.',
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              color: Colors.white.withValues(alpha: 0.95),
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UsageProgressItem extends StatelessWidget {
  final String title;
  final String icon;
  final int current;
  final dynamic max;
  final Color color;
  final VoidCallback? onAction;

  const _UsageProgressItem({
    required this.title,
    required this.icon,
    required this.current,
    required this.max,
    required this.color,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUnlimited = (max is String && (max.toLowerCase() == 'unlimited' || max == '-1')) || (max is num && max == -1);
    final int maxValue = isUnlimited ? 0 : (max is int ? max : int.tryParse(max.toString()) ?? 0);
    final double progress = isUnlimited ? 0.0 : (maxValue > 0 ? (current / maxValue).clamp(0.0, 1.0) : 0.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              icon,
              width: 16.sp,
              height: 16.sp,
              colorFilter: ColorFilter.mode(AppTheme.colors.primary, BlendMode.srcIn),
            ),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF334155),
              ),
            ),
            const Spacer(),
            _PermissionBlurredWidget(
              hasPermission: context.hasPermission('plan_limit.view'),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$current',
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    TextSpan(
                      text: isUnlimited ? ' / ∞' : ' / $maxValue',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (onAction != null) ...[
              SizedBox(width: 8.w),
              Material(
                color: AppTheme.colors.primary,
                borderRadius: BorderRadius.circular(8.r),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onAction!();
                  },
                  borderRadius: BorderRadius.circular(8.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.add, color: Colors.white, size: 12.sp),
                        SizedBox(width: 2.w),
                        Text(
                          'Xarid',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.5.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 8.h),
        Stack(
          children: [
            Container(
              height: 7.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            if (!isUnlimited)
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 7.h,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _UsageSkeleton extends StatelessWidget {
  const _UsageSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: Column(
        children: [
          Container(
            height: 90.h,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r)),
          ),
          SizedBox(height: 14.h),
          Container(
            height: 220.h,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r)),
          ),
        ],
      ),
    );
  }
}
