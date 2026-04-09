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
          _Section(
            title: "Kutilayotgan to'lovlar",
            icon: Icons.calendar_month_rounded,
            iconColor: const Color(0xFF6366F1),
            trailing: _PeriodSelector(
              period: state.period,
              onChanged: (p) => cubit.changePeriod(p),
            ),
            child: state.status == Status.loading && state.data.isEmpty
                ? _SectionShimmer(height: 120.h)
                : state.forCurrency(currencyTypeId) == null
                    ? const _EmptySection()
                    : _ForecastContent(
                        forecast: state.forCurrency(currencyTypeId)!,
                        currency: currencyLabel,
                      ),
          ),
        ],
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
        Row(
          children: [
            Expanded(
              child: _ForecastTile(
                label: '${forecast.periodDays} kun ichida',
                value: PriceFormatter.priceFormat(forecast.expectedAmount),
                subValue: currency,
                icon: Icons.account_balance_wallet_rounded,
                color: const Color(0xFF6366F1),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _ForecastTile(
                label: 'Qismlar soni',
                value: '${forecast.itemsCount}',
                subValue: 'ta',
                icon: Icons.receipt_long_rounded,
                color: const Color(0xFF3B82F6),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: _ForecastTile(
                label: 'Bugun muddati',
                value: '${forecast.dueTodayCount}',
                subValue: 'ta',
                icon: Icons.today_rounded,
                color: const Color(0xFFEF4444),
                urgent: forecast.dueTodayCount > 0,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _ForecastTile(
                label: '3 kunda muddati',
                value: '${forecast.due3daysCount}',
                subValue: 'ta',
                icon: Icons.hourglass_bottom_rounded,
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

class _ForecastTile extends StatelessWidget {
  final String label;
  final String value;
  final String subValue;
  final IconData icon;
  final Color color;
  final bool urgent;

  const _ForecastTile({
    required this.label,
    required this.value,
    required this.subValue,
    required this.icon,
    required this.color,
    this.urgent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withValues(alpha: urgent ? 0.4 : 0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(icon, size: 14.sp, color: color),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 10.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.w500)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(value, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: color), overflow: TextOverflow.ellipsis),
                    ),
                    SizedBox(width: 3.w),
                    Padding(
                      padding: EdgeInsets.only(bottom: 1.h),
                      child: Text(subValue, style: TextStyle(fontSize: 10.sp, color: color.withValues(alpha: 0.7), fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  final int period;
  final ValueChanged<int> onChanged;

  const _PeriodSelector({required this.period, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [30, 60, 90].map((p) {
        final selected = period == p;
        return GestureDetector(
          onTap: () => onChanged(p),
          child: Container(
            margin: EdgeInsets.only(left: 4.w),
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: selected ? AppTheme.colors.primary : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              '${p}k',
              style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: selected ? Colors.white : const Color(0xFF64748B)),
            ),
          ),
        );
      }).toList(),
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
