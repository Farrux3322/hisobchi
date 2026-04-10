import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hisobchi/application/installment_report/installment_sub_cubits.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/dto/models/installment_report/installment_report_models.dart';
import 'package:hisobchi/infrastructure/repository/installment_report/installment_report_repository.dart';
import 'package:hisobchi/presentation/assets/theme/app_theme.dart';
import 'package:hisobchi/presentation/components/back_button.dart';
import 'package:hisobchi/presentation/components/utils/price_extension.dart';
import 'package:hisobchi/presentation/pages/client/report/installment_sub_pages/installment_items_page.dart';
import 'package:shimmer/shimmer.dart';

class InstallmentRecoveryPage extends StatelessWidget {
  const InstallmentRecoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InstallmentRecoveryCubit(InstallmentReportRepository())..load(),
      child: const _RecoveryView(),
    );
  }
}

class _RecoveryView extends StatefulWidget {
  const _RecoveryView();

  @override
  State<_RecoveryView> createState() => _RecoveryViewState();
}

class _RecoveryViewState extends State<_RecoveryView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackArrowButton(),
        title: const Text('Undirish samaradorligi'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(66),
          child: _CurrencyTabBar(controller: _tabController),
        ),
      ),
      body: BlocBuilder<InstallmentRecoveryCubit, RecoveryState>(
        builder: (context, state) {
          return TabBarView(
            controller: _tabController,
            children: [
              _RecoveryTabContent(currencyTypeId: 1, currencyLabel: 'UZS', state: state),
              _RecoveryTabContent(currencyTypeId: 2, currencyLabel: 'USD', state: state),
            ],
          );
        },
      ),
    );
  }
}

class _RecoveryTabContent extends StatelessWidget {
  final int currencyTypeId;
  final String currencyLabel;
  final RecoveryState state;

  const _RecoveryTabContent({
    required this.currencyTypeId,
    required this.currencyLabel,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<InstallmentRecoveryCubit>().load();
        await Future.delayed(const Duration(milliseconds: 400));
      },
      color: AppTheme.colors.primary,
      child: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h + MediaQuery.of(context).padding.bottom),
        children: [
          _Section(
            icon: Icons.trending_up_rounded,
            iconColor: const Color(0xFF22C55E),
            child: state.status == Status.loading && state.data.isEmpty
                ? _SectionShimmer(height: 340.h)
                : state.forCurrency(currencyTypeId) == null
                    ? const _EmptySection()
                    : _RecoveryContent(
                        recovery: state.forCurrency(currencyTypeId)!,
                        currency: currencyLabel,
                      ),
          ),
        ],
      ),
    );
  }
}

// ─── Recovery Content ─────────────────────────────────────────────────────────

class _RecoveryContent extends StatelessWidget {
  final InstallmentRecoveryModel recovery;
  final String currency;

  const _RecoveryContent({required this.recovery, required this.currency});

  Color get _ratingColor {
    final rate = double.tryParse(recovery.recoveryRate) ?? 0;
    if (rate >= 80) return const Color(0xFF22C55E);
    if (rate >= 60) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    final rate = double.tryParse(recovery.recoveryRate) ?? 0;
    final overdueRate = double.tryParse(recovery.overdueRate) ?? 0;
    final by = recovery.byItems;
    final total = by.total;

    return Column(
      children: [
        // ── Big Donut Chart ──
        Center(
          child: SizedBox(
            width: 140.w,
            height: 140.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glow shadow behind the ring
                Container(
                  width: 140.w,
                  height: 140.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _ratingColor.withValues(alpha: 0.15),
                        blurRadius: 22,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                ),
                // Background track ring
                SizedBox(
                  width: 140.w,
                  height: 140.w,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 13.w,
                    color: const Color(0xFFF1F5F9),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                // Foreground progress ring
                SizedBox(
                  width: 140.w,
                  height: 140.w,
                  child: CircularProgressIndicator(
                    value: (rate / 100).clamp(0.0, 1.0),
                    strokeWidth: 13.w,
                    backgroundColor: Colors.transparent,
                    color: _ratingColor,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                // Center content
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${rate.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w900,
                        color: _ratingColor,
                        height: 1.0,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: _ratingColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: _ratingColor.withValues(alpha: 0.25)),
                      ),
                      child: Text(
                        recovery.ratingLabel,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: _ratingColor,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 20.h),

        // ── Berilgan (full-width) ──
        _WideAmountCard(
          label: 'Berilgan',
          amount: recovery.totalGiven,
          currency: currency,
          color: const Color(0xFF6366F1),
          icon: Icons.account_balance_wallet_outlined,
        ),
        SizedBox(height: 8.h),

        // ── To'langan + Qolgan ──
        Row(
          children: [
            Expanded(
              child: _AmountCard(
                label: "To'langan",
                amount: recovery.totalCollected,
                currency: currency,
                color: const Color(0xFF22C55E),
                icon: Icons.check_circle_outline_rounded,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _AmountCard(
                label: 'Qolgan',
                amount: recovery.totalRemaining,
                currency: currency,
                color: const Color(0xFF3B82F6),
                icon: Icons.hourglass_bottom_rounded,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),

        // ── Overdue Rate Banner ──
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFFECDD3)),
            boxShadow: [
              BoxShadow(color: const Color(0xFFEF4444).withValues(alpha: 0.07), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11.r),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                Container(width: 4, color: const Color(0xFFEF4444)),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFEF2F2), Color(0xFFFFF5F5)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(7.r),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(9.r),
                          ),
                          child: Icon(Icons.timer_off_outlined, size: 15.sp, color: const Color(0xFFEF4444)),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Muddati o'tgan foiz",
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: const Color(0xFFB91C1C).withValues(alpha: 0.65),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                "Jami to'lovlardan ${overdueRate.toStringAsFixed(1)}% kechiktirilgan",
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFB91C1C),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '${overdueRate.toStringAsFixed(1)}%',
                          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: const Color(0xFFEF4444)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          ),
        ),

        // ── Status chips + stacked bar ──
        if (total > 0) ...[
          SizedBox(height: 16.h),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFFE2E8F0), const Color(0xFFE2E8F0).withValues(alpha: 0)],
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Builder(
            builder: (context) {
              void openItems(String status, String label, Color color) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InstallmentItemsPage(
                      status: status,
                      statusLabel: label,
                      currencyTypeId: recovery.currencyTypeId,
                      currencyLabel: currency,
                      statusColor: color,
                    ),
                  ),
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: _ByItemChip(
                      label: "To'langan",
                      count: by.paid,
                      color: const Color(0xFF22C55E),
                      onTap: () => openItems('paid', "To'langan", const Color(0xFF22C55E)),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: _ByItemChip(
                      label: 'Qisman',
                      count: by.partial,
                      color: const Color(0xFF3B82F6),
                      onTap: () => openItems('partial', 'Qisman', const Color(0xFF3B82F6)),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: _ByItemChip(
                      label: "Muddati o't.",
                      count: by.overdue,
                      color: const Color(0xFFEF4444),
                      onTap: () => openItems('overdue', "Muddati o'tgan", const Color(0xFFEF4444)),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: _ByItemChip(
                      label: 'Kutilmoqda',
                      count: by.pending,
                      color: const Color(0xFF94A3B8),
                      onTap: () => openItems('pending', 'Kutilmoqda', const Color(0xFF94A3B8)),
                    ),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 10.h),
          _StackedBar(by: by),
        ],
      ],
    );
  }
}

// ─── Wide Amount Card (Berilgan) ──────────────────────────────────────────────

class _WideAmountCard extends StatelessWidget {
  final String label;
  final String amount;
  final String currency;
  final Color color;
  final IconData icon;

  const _WideAmountCard({
    required this.label,
    required this.amount,
    required this.currency,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: color.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.10), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13.r),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 5, color: color),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withValues(alpha: 0.08), color.withValues(alpha: 0.03)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(9.r),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(icon, size: 16.sp, color: color),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: color.withValues(alpha: 0.70),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              PriceFormatter.priceFormat(amount),
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w900,
                                color: color,
                                height: 1.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          currency,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: color,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Amount Card ──────────────────────────────────────────────────────────────

class _AmountCard extends StatelessWidget {
  final String label;
  final String amount;
  final String currency;
  final Color color;
  final IconData icon;

  const _AmountCard({
    required this.label,
    required this.amount,
    required this.currency,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.07), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11.r),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            Container(width: 3, color: color),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 11.h),
                color: color.withValues(alpha: 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(5.r),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.13),
                        borderRadius: BorderRadius.circular(7.r),
                      ),
                      child: Icon(icon, size: 11.sp, color: color),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      PriceFormatter.priceFormat(amount),
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: color, height: 1.1),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      label,
                      style: TextStyle(fontSize: 12.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 3.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        currency,
                        style: TextStyle(fontSize: 9.sp, color: color, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

// ─── By Item Chip ─────────────────────────────────────────────────────────────

class _ByItemChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final VoidCallback? onTap;

  const _ByItemChip({
    required this.label,
    required this.count,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.10), color.withValues(alpha: 0.04)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: color.withValues(alpha: 0.22)),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.07), blurRadius: 5, offset: const Offset(0, 2)),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 9.h),
            child: Column(
              children: [
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w900,
                    color: color,
                    height: 1.0,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: const Color(0xFF475569),
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (onTap != null) ...[
                  SizedBox(height: 3.h),
                  Icon(Icons.arrow_forward_ios_rounded, size: 8.sp, color: color.withValues(alpha: 0.50)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Stacked Bar ─────────────────────────────────────────────────────────────

class _StackedBar extends StatelessWidget {
  final RecoveryByItems by;
  const _StackedBar({required this.by});

  @override
  Widget build(BuildContext context) {
    final total = by.total;
    if (total == 0) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(7.r),
      child: SizedBox(
        height: 11.h,
        child: Row(
          children: [
            _BarSegment(ratio: by.paid / total, color: const Color(0xFF22C55E)),
            _BarSegment(ratio: by.partial / total, color: const Color(0xFF3B82F6)),
            _BarSegment(ratio: by.overdue / total, color: const Color(0xFFEF4444)),
            _BarSegment(ratio: by.pending / total, color: const Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }
}

class _BarSegment extends StatelessWidget {
  final double ratio;
  final Color color;
  const _BarSegment({required this.ratio, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(flex: (ratio * 1000).toInt().clamp(0, 1000000), child: Container(color: color));
  }
}

// ─── Shared Helpers ───────────────────────────────────────────────────────────

class _CurrencyTabBar extends StatelessWidget {
  final TabController controller;
  const _CurrencyTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _TabItem(label: 'UZS Hisob', selected: controller.index == 0, onTap: () => controller.animateTo(0)),
              _TabDivider(),
              _TabItem(label: 'USD Hisob', selected: controller.index == 1, onTap: () => controller.animateTo(1)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabItem({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              color: selected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 2, height: 12, decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 2),
          Container(width: 2, height: 12, decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2))),
        ],
      );
}

class _Section extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final Widget child;
  final Widget? trailing;

  const _Section({
    required this.icon,
    this.iconColor,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 3)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 1)),
        ],
      ),
      child: child,
    );
  }
}

class _SectionShimmer extends StatelessWidget {
  final double height;
  const _SectionShimmer({required this.height});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: Container(
        height: height,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10.r)),
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  final String message;
  const _EmptySection({this.message = "Ma'lumot topilmadi"});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Text(message, style: TextStyle(fontSize: 13.sp, color: const Color(0xFF94A3B8))),
      ),
    );
  }
}
