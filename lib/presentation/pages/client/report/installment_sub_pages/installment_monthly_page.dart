import 'package:fl_chart/fl_chart.dart';
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

class InstallmentMonthlyPage extends StatelessWidget {
  const InstallmentMonthlyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InstallmentMonthlyCubit(InstallmentReportRepository())..load(),
      child: const _MonthlyView(),
    );
  }
}

class _MonthlyView extends StatefulWidget {
  const _MonthlyView();

  @override
  State<_MonthlyView> createState() => _MonthlyViewState();
}

class _MonthlyViewState extends State<_MonthlyView> with SingleTickerProviderStateMixin {
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
          'Oylik dinamika',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(66),
          child: _CurrencyTabBar(controller: _tabController),
        ),
      ),
      body: BlocBuilder<InstallmentMonthlyCubit, MonthlyState>(
        builder: (context, state) {
          return TabBarView(
            controller: _tabController,
            children: [
              _MonthlyTabContent(currencyTypeId: 1, currencyLabel: 'UZS', state: state),
              _MonthlyTabContent(currencyTypeId: 2, currencyLabel: 'USD', state: state),
            ],
          );
        },
      ),
    );
  }
}

class _MonthlyTabContent extends StatelessWidget {
  final int currencyTypeId;
  final String currencyLabel;
  final MonthlyState state;

  const _MonthlyTabContent({
    required this.currencyTypeId,
    required this.currencyLabel,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<InstallmentMonthlyCubit>();

    return RefreshIndicator(
      onRefresh: () async {
        cubit.load(year: state.selectedYear);
        await Future.delayed(const Duration(milliseconds: 400));
      },
      color: AppTheme.colors.primary,
      child: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
        children: [
          _Section(
            title: 'Oylik dinamika',
            icon: Icons.bar_chart_rounded,
            iconColor: const Color(0xFF3B82F6),
            trailing: _YearSelector(
              year: state.selectedYear,
              onChanged: (y) => cubit.changeYear(y),
            ),
            child: state.status == Status.loading && state.data.isEmpty
                ? _SectionShimmer(height: 200.h)
                : state.forCurrency(currencyTypeId) == null
                    ? const _EmptySection()
                    : _MonthlyChart(
                        monthly: state.forCurrency(currencyTypeId)!,
                        currency: currencyLabel,
                      ),
          ),
        ],
      ),
    );
  }
}

// ─── Monthly Chart ────────────────────────────────────────────────────────────

class _MonthlyChart extends StatefulWidget {
  final InstallmentMonthlyModel monthly;
  final String currency;

  const _MonthlyChart({required this.monthly, required this.currency});

  @override
  State<_MonthlyChart> createState() => _MonthlyChartState();
}

class _MonthlyChartState extends State<_MonthlyChart> {
  int? _touched;

  @override
  Widget build(BuildContext context) {
    final months = widget.monthly.months;
    final maxVal = widget.monthly.maxAmount;
    if (maxVal == 0 && months.every((m) => m.paymentsCount == 0)) {
      return const _EmptySection(message: "Bu yilda to'lovlar mavjud emas");
    }

    final barGroups = months.asMap().entries.map((e) {
      final i = e.key;
      final m = e.value;
      final isTouched = _touched == i;

      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: m.amount,
            width: 14.w,
            borderRadius: BorderRadius.circular(4.r),
            gradient: LinearGradient(
              colors: isTouched
                  ? [AppTheme.colors.primary, AppTheme.colors.primary.withValues(alpha: 0.7)]
                  : [AppTheme.colors.primary.withValues(alpha: 0.5), AppTheme.colors.primary.withValues(alpha: 0.3)],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ],
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 160.h,
          child: BarChart(
            BarChartData(
              maxY: maxVal * 1.25,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => const Color(0xFF1E293B),
                  getTooltipItem: (group, _, rod, __) {
                    final m = months[group.x];
                    return BarTooltipItem(
                      '${m.uzLabel}\n${PriceFormatter.priceFormat(m.totalAmount)} ${widget.currency}\n${m.paymentsCount} ta',
                      TextStyle(fontSize: 10.sp, color: Colors.white, fontWeight: FontWeight.w600, height: 1.5),
                    );
                  },
                ),
                touchCallback: (event, resp) {
                  if (resp?.spot == null || event is FlPointerExitEvent || event is FlTapUpEvent) {
                    setState(() => _touched = null);
                  } else {
                    setState(() => _touched = resp!.spot!.touchedBarGroupIndex);
                  }
                },
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 20.h,
                    getTitlesWidget: (v, _) => Text(
                      months[v.toInt()].uzLabel,
                      style: TextStyle(fontSize: 8.sp, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => FlLine(color: const Color(0xFFF1F5F9), strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              barGroups: barGroups,
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Divider(height: 1, color: const Color(0xFFE2E8F0)),
        SizedBox(height: 8.h),
        Row(
          children: [
            Icon(Icons.info_outline_rounded, size: 12.sp, color: const Color(0xFF94A3B8)),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                "Jami: ${PriceFormatter.priceFormat(months.fold(0.0, (acc, m) => acc + m.amount).toStringAsFixed(0))} ${widget.currency} · ${months.fold(0, (s, m) => s + m.paymentsCount)} ta to'lov",
                style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _YearSelector extends StatelessWidget {
  final int year;
  final ValueChanged<int> onChanged;

  const _YearSelector({required this.year, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final current = DateTime.now().year;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => onChanged(year - 1),
          child: Icon(Icons.chevron_left_rounded, size: 18.sp, color: const Color(0xFF64748B)),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            '$year',
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
          ),
        ),
        GestureDetector(
          onTap: year < current ? () => onChanged(year + 1) : null,
          child: Icon(
            Icons.chevron_right_rounded,
            size: 18.sp,
            color: year < current ? const Color(0xFF64748B) : const Color(0xFFCBD5E1),
          ),
        ),
      ],
    );
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
