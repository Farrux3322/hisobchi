import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hisobchi/application/subscription/subscription_bloc.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/routes/entity/routes.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:hisobchi/infrastructure/dto/models/subscription/subscription_info_model.dart';

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
            const Gap(20),

            // Usage Progress Container
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 24, offset: const Offset(0, 8))],
                border: Border.all(color: AppTheme.colors.divider.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => setState(() => _isExpanded = !_isExpanded),
                      borderRadius: BorderRadius.circular(32),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: AppTheme.colors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                              child: Icon(Icons.bar_chart_rounded, color: AppTheme.colors.primary, size: 20),
                            ),
                            const Gap(12),
                            Expanded(
                              child: Text(
                                'Limitlar va Foydalanish',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.colors.black, letterSpacing: -0.5),
                              ),
                            ),
                            AnimatedRotation(
                              turns: _isExpanded ? 0.5 : 0,
                              duration: const Duration(milliseconds: 300),
                              child: Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.colors.gray.withValues(alpha: 0.5), size: 28),
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
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                            child: Column(
                              children: [
                                _UsageProgressItem(
                                  title: 'Hamkorlar',
                                  icon: AppIcons.clients,
                                  current: usage?.customers?.current ?? 0,
                                  max: usage?.customers?.max,
                                  color: const Color(0xFF6366F1), // Indigo
                                ),
                                const Gap(24),
                                _UsageProgressItem(
                                  title: 'Loyihalar',
                                  icon: AppIcons.project,
                                  current: usage?.projects?.current ?? 0,
                                  max: usage?.projects?.max,
                                  color: const Color(0xFF10B981), // Emerald
                                ),
                                const Gap(24),
                                _UsageProgressItem(
                                  title: 'SMS Xabarlar',
                                  icon: AppIcons.sms,
                                  current: usage?.sms?.current ?? 0,
                                  max: usage?.sms?.max,
                                  remaining: usage?.sms?.remaining ?? 0,
                                  color: const Color(0xFFF59E0B),
                                  // Amber
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

class _SubscriptionInfoCard extends StatelessWidget {
  final String planType;
  final String planExpiry;
  final String status;
  final String? statusLabel;
  final num? daysUntilDue;
  final num? daysPastDue;

  const _SubscriptionInfoCard({required this.planType, required this.planExpiry, required this.status, this.statusLabel, this.daysPastDue, this.daysUntilDue});

  @override
  Widget build(BuildContext context) {
    final int days = daysUntilDue?.round() ?? 0;
    final int dueDays = 4 - (daysPastDue?.round() ?? 0);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppTheme.colors.primary, AppTheme.colors.primary.withBlue(150)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppTheme.colors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Opacity(opacity: 0.1, child: SvgPicture.asset(AppIcons.crown, width: 120, height: 120, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn))),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: SvgPicture.asset(
                        AppIcons.crown,
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
                    ),
                    const Gap(16),
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
                                                fontSize: 15,
                                                color: Colors.white.withValues(alpha: 0.7),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            TextSpan(
                                              text: planType,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (statusLabel != null) ...[
                                      const Gap(8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          statusLabel!,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const Gap(8),
                              Material(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                child: InkWell(
                                  onTap: () => context.pushNamed(Routes.subscription.name),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    child: const Icon(
                                      Icons.add_rounded,
                                      color: Colors.black,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Gap(6),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_filled_rounded,
                                size: 14,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                              const Gap(4),
                              Expanded(
                                child: Text(
                                  'Amal qilish muddati: $planExpiry',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
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
                    const Gap(16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timer_outlined, color: Colors.white, size: 20),
                          const Gap(8),
                          Text(
                            status == 'GRACE_PERIOD' ? 'Imtiyozli davr tugashiga:' : 'Tarif tugashiga:',
                            style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w500),
                          ),
                          const Spacer(),
                          Text(
                            '${status == 'GRACE_PERIOD' ? dueDays : days} kun qoldi',
                            style: const TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ],
                ] else ...[
                  const Gap(16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
                        const Gap(8),
                        Expanded(
                          child: Text(
                            status == 'READ_ONLY'
                                ? 'Hisobingiz "Faqat ko\'rish" rejimida. Hamkorlar va loyihalar qo\'shish cheklangan.'
                                : status == 'ARCHIVED'
                                    ? 'Sizning hisobingiz arxivlangan.'
                                    : 'Sizning hisobingiz o\'chirilgan.',
                            style: TextStyle(
                              fontSize: 13,
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
  final int? remaining;
  final Color color;
  final VoidCallback? onAction;

  const _UsageProgressItem({required this.title, required this.icon, required this.current, required this.max, this.remaining, required this.color, this.onAction});

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
            SvgPicture.asset(icon, colorFilter: ColorFilter.mode(AppTheme.colors.primary, BlendMode.srcIn)),
            const Gap(8),
            Text(
              title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87),
            ),
            const Spacer(),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${remaining ?? current}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.colors.black, letterSpacing: -0.5),
                  ),
                  TextSpan(
                    text: isUnlimited ? ' / ∞' : ' / $maxValue',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.colors.black.withValues(alpha: 0.5)),
                  ),
                ],
              ),
            ),
            if (onAction != null) ...[
              const Gap(12),
              Material(
                color: AppTheme.colors.primary,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: onAction,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    child: Icon(Icons.add_rounded, color: AppTheme.colors.white, size: 22),
                  ),
                ),
              ),
            ],
          ],
        ),
        const Gap(12),
        Stack(
          children: [
            Container(
              height: 10,
              width: double.infinity,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(10)),
            ),
            if (!isUnlimited)
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))],
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
            height: 100,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
          ),
          const Gap(20),
          Container(
            height: 280,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32)),
          ),
        ],
      ),
    );
  }
}
