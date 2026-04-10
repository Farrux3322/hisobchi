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

class InstallmentForecastPage extends StatelessWidget {
  const InstallmentForecastPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InstallmentForecastCubit(InstallmentReportRepository())..load(),
      child: const _ForecastView(),
    );
  }
}

class _ForecastView extends StatefulWidget {
  const _ForecastView();

  @override
  State<_ForecastView> createState() => _ForecastViewState();
}

class _ForecastViewState extends State<_ForecastView> with SingleTickerProviderStateMixin {
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
          "Kutilayotgan to'lovlar",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(66),
          child: _CurrencyTabBar(controller: _tabController),
        ),
      ),
      body: BlocBuilder<InstallmentForecastCubit, ForecastState>(
        builder: (context, state) {
          return TabBarView(
            controller: _tabController,
            children: [
              _ForecastTabContent(currencyTypeId: 1, currencyLabel: 'UZS', state: state),
              _ForecastTabContent(currencyTypeId: 2, currencyLabel: 'USD', state: state),
            ],
          );
        },
      ),
    );
  }
}

// ─── Tab Content ──────────────────────────────────────────────────────────────

class _ForecastTabContent extends StatelessWidget {
  final int currencyTypeId;
  final String currencyLabel;
  final ForecastState state;

  const _ForecastTabContent({
    required this.currencyTypeId,
    required this.currencyLabel,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<InstallmentForecastCubit>();

    return RefreshIndicator(
      onRefresh: () async {
        cubit.load(period: state.period);
        await Future.delayed(const Duration(milliseconds: 400));
      },
      color: AppTheme.colors.primary,
      child: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
        children: [
          // ── Period Selector ──
          _PeriodSelector(
            period: state.period,
            isLoading: state.status == Status.loading,
            onChanged: (p) => cubit.changePeriod(p),
          ),
          SizedBox(height: 14.h),

          // ── Content ──
          if (state.status == Status.loading)
            _ForecastShimmer()
          else if (state.forCurrency(currencyTypeId) == null)
            _EmptyCard()
          else
            _ForecastContent(
              forecast: state.forCurrency(currencyTypeId)!,
              currency: currencyLabel,
            ),
        ],
      ),
    );
  }
}

// ─── Period Selector ──────────────────────────────────────────────────────────

class _PeriodSelector extends StatelessWidget {
  final int period;
  final bool isLoading;
  final ValueChanged<int> onChanged;

  const _PeriodSelector({
    required this.period,
    required this.isLoading,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [30, 60, 90].map((p) {
          final selected = period == p;
          return Expanded(
            child: GestureDetector(
              onTap: isLoading ? null : () => onChanged(p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                margin: EdgeInsets.all(2.r),
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: selected ? AppTheme.colors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10.r),
                  boxShadow: selected
                      ? [BoxShadow(color: AppTheme.colors.primary.withValues(alpha: 0.30), blurRadius: 8, offset: const Offset(0, 3))]
                      : [],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$p',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: selected ? Colors.white : const Color(0xFF64748B),
                        height: 1.0,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'kun',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white.withValues(alpha: 0.85) : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Forecast Content ─────────────────────────────────────────────────────────

class _ForecastContent extends StatelessWidget {
  final InstallmentForecastModel forecast;
  final String currency;

  const _ForecastContent({required this.forecast, required this.currency});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Hero Card ──
        _HeroAmountCard(forecast: forecast, currency: currency),
        SizedBox(height: 12.h),

        // ── 3 Stat Tiles ──
        Row(
          children: [
            Expanded(
              child: _StatTile(
                icon: Icons.receipt_long_rounded,
                label: 'Jami qismlar',
                value: '${forecast.itemsCount}',
                unit: 'ta',
                color: const Color(0xFF3B82F6),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _StatTile(
                icon: Icons.today_rounded,
                label: 'Bugun muddati',
                value: '${forecast.dueTodayCount}',
                unit: 'ta',
                color: const Color(0xFFEF4444),
                urgent: forecast.dueTodayCount > 0,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _StatTile(
                icon: Icons.hourglass_bottom_rounded,
                label: '3 kunda',
                value: '${forecast.due3daysCount}',
                unit: 'ta',
                color: const Color(0xFFF59E0B),
                urgent: forecast.due3daysCount > 0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Hero Amount Card ─────────────────────────────────────────────────────────

class _HeroAmountCard extends StatelessWidget {
  final InstallmentForecastModel forecast;
  final String currency;

  const _HeroAmountCard({required this.forecast, required this.currency});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    "${forecast.periodDays} kunlik prognoz",
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                  ),
                ),
                SizedBox(height: 14.h),
                Text(
                  "Kutilayotgan summa",
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.white.withValues(alpha: 0.70),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  PriceFormatter.priceFormat(forecast.expectedAmount),
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 6.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    currency,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              Icons.calendar_month_rounded,
              size: 32.sp,
              color: Colors.white.withValues(alpha: 0.90),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stat Tile ────────────────────────────────────────────────────────────────

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;
  final bool urgent;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    this.urgent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: urgent ? color.withValues(alpha: 0.4) : color.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: urgent ? color.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 13.sp, color: color),
          ),
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w900,
                  color: color,
                  height: 1.0,
                ),
              ),
              SizedBox(width: 2.w),
              Padding(
                padding: EdgeInsets.only(bottom: 1.h),
                child: Text(
                  unit,
                  style: TextStyle(fontSize: 10.sp, color: color.withValues(alpha: 0.7), fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Text(
            label,
            style: TextStyle(fontSize: 9.sp, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (urgent) ...[
            SizedBox(height: 5.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                'Diqqat!',
                style: TextStyle(fontSize: 8.sp, color: color, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Shimmer Skeleton ─────────────────────────────────────────────────────────

class _ForecastShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      child: Column(
        children: [
          // Hero card skeleton
          Container(
            height: 130.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
          SizedBox(height: 12.h),
          // 3 stat tiles skeleton
          Row(
            children: List.generate(3, (i) => i).expand((i) => [
              if (i > 0) SizedBox(width: 10.w),
              Expanded(
                child: Container(
                  height: 100.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
              ),
            ]).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Empty Card ───────────────────────────────────────────────────────────────

class _EmptyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_rounded, size: 36.sp, color: const Color(0xFFCBD5E1)),
          SizedBox(height: 10.h),
          Text(
            "Ma'lumot topilmadi",
            style: TextStyle(fontSize: 13.sp, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500),
          ),
        ],
      ),
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
