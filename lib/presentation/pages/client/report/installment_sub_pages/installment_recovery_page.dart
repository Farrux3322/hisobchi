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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackArrowButton(),
        title: const Text(
          'Undirish samaradorligi',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
        ),
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
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
        children: [
          _Section(
            title: 'Undirish samaradorligi',
            icon: Icons.trending_up_rounded,
            iconColor: const Color(0xFF22C55E),
            child: state.status == Status.loading && state.data.isEmpty
                ? _SectionShimmer(height: 200.h)
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
        Row(
          children: [
            SizedBox(
              width: 90.w,
              height: 90.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: (rate / 100).clamp(0.0, 1.0),
                    strokeWidth: 8.w,
                    backgroundColor: const Color(0xFFE2E8F0),
                    color: _ratingColor,
                    strokeCap: StrokeCap.round,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${rate.toStringAsFixed(0)}%',
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: _ratingColor),
                      ),
                      Text(
                        recovery.ratingLabel,
                        style: TextStyle(fontSize: 9.sp, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RecoveryRow(label: 'Berilgan', amount: recovery.totalGiven, currency: currency, color: const Color(0xFF475569)),
                  SizedBox(height: 5.h),
                  _RecoveryRow(label: "To'langan", amount: recovery.totalCollected, currency: currency, color: const Color(0xFF22C55E)),
                  SizedBox(height: 5.h),
                  _RecoveryRow(label: 'Qolgan', amount: recovery.totalRemaining, currency: currency, color: const Color(0xFF3B82F6)),
                  SizedBox(height: 5.h),
                  Row(
                    children: [
                      Expanded(child: Text("Muddati o'tgan:", style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B)))),
                      Text(
                        '${overdueRate.toStringAsFixed(1)}%',
                        style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: const Color(0xFFEF4444)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        if (total > 0) ...[
          Divider(height: 1, color: const Color(0xFFE2E8F0)),
          SizedBox(height: 10.h),
          Row(
            children: [
              _ByItemChip(label: "To'langan", count: by.paid, color: const Color(0xFF22C55E)),
              SizedBox(width: 6.w),
              _ByItemChip(label: 'Qisman', count: by.partial, color: const Color(0xFF3B82F6)),
              SizedBox(width: 6.w),
              _ByItemChip(label: "Muddati o't.", count: by.overdue, color: const Color(0xFFEF4444)),
              SizedBox(width: 6.w),
              _ByItemChip(label: 'Kutilmoqda', count: by.pending, color: const Color(0xFF94A3B8)),
            ],
          ),
          SizedBox(height: 8.h),
          _StackedBar(by: by),
        ],
      ],
    );
  }
}

class _RecoveryRow extends StatelessWidget {
  final String label;
  final String amount;
  final String currency;
  final Color color;

  const _RecoveryRow({required this.label, required this.amount, required this.currency, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B)))),
        Text(
          '${PriceFormatter.priceFormat(amount)} $currency',
          style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: color),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _ByItemChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _ByItemChip({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text('$count', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: color)),
            Text(label, style: TextStyle(fontSize: 9.sp, color: color.withValues(alpha: 0.8), fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _StackedBar extends StatelessWidget {
  final RecoveryByItems by;
  const _StackedBar({required this.by});

  @override
  Widget build(BuildContext context) {
    final total = by.total;
    if (total == 0) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(4.r),
      child: SizedBox(
        height: 6.h,
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
    return Expanded(flex: (ratio * 1000).toInt(), child: Container(color: color));
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
  final String title;
  final IconData icon;
  final Color? iconColor;
  final Widget child;
  final Widget? trailing;

  const _Section({
    required this.title,
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
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14.sp, color: iconColor ?? AppTheme.colors.primary),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(title, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B))),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
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
      child: Container(height: height, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10.r))),
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
