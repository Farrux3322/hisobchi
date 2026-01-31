import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hisobchi/application/subscription/subscription_bloc.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/routes/entity/routes.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

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
            _SubscriptionInfoCard(planType: planType, planExpiry: planExpiry),
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

  const _SubscriptionInfoCard({required this.planType, required this.planExpiry});

  @override
  Widget build(BuildContext context) {
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
            child: Opacity(opacity: 0.1, child: SvgPicture.asset(AppIcons.crown, width: 120, height: 120, colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn))),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.all(14),
                  child: SvgPicture.asset(AppIcons.crown, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
                ),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        planType,
                        style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w800),
                      ),
                      const Gap(4),
                      Text(
                        'Amal qilish muddati: $planExpiry',
                        style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    onTap: () => context.pushNamed(Routes.subscription.name),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Text(
                        'Yangilash',
                        style: TextStyle(color: AppTheme.colors.primary, fontWeight: FontWeight.bold, fontSize: 14),
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
    final bool isUnlimited = max is String && max.toLowerCase() == 'unlimited';
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
