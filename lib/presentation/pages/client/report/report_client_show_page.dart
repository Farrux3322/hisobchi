import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hisobchi/application/partner/partner_bloc.dart';
import 'package:hisobchi/application/partner_details_report/partner_details_report_cubit.dart';
import 'package:hisobchi/infrastructure/dto/models/partner/partner_model.dart';
import 'package:hisobchi/infrastructure/models/partner_details_report_model.dart';
import 'package:hisobchi/infrastructure/repository/partner_report/partner_report_repository.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/pages/client/client_xisob_kitob.dart';
import 'package:hisobchi/presentation/pages/client/report/models/dashboard_models.dart';
import 'package:hisobchi/presentation/pages/client/report/widgets/balance_card.dart';
import 'package:hisobchi/presentation/pages/client/report/widgets/balance_line_chart.dart';
import 'package:hisobchi/presentation/pages/client/report/widgets/debt_aging_grid.dart';
import 'package:hisobchi/presentation/pages/client/report/widgets/monthly_bar_chart.dart';
import 'package:hisobchi/presentation/pages/client/report/widgets/summary_grid.dart';
import 'package:shimmer/shimmer.dart';

class ReportClientShowPage extends StatefulWidget {
  final PartnerModel partnerModel;
  const ReportClientShowPage({super.key, required this.partnerModel});

  @override
  State<ReportClientShowPage> createState() => _ReportClientShowPageState();
}

class _ReportClientShowPageState extends State<ReportClientShowPage> with SingleTickerProviderStateMixin {
  late TabController _currencyTabController;

  // Design Constants
  final Color primaryGradientStart = AppTheme.colors.primary;
  final Color primaryGradientEnd = AppTheme.colors.primary.withValues(alpha: 0.8);
  final Color backgroundColor = const Color(0xFFF8FAFC);
  final Color textPrimary = const Color(0xFF0F172A);
  final Color textSecondary = const Color(0xFF64748B);


  @override
  void initState() {
    super.initState();
    // main_currency_type_id: 1 = UZS (index 0), 2 = USD (index 1)
    final int initialIndex = (widget.partnerModel.mainCurrencyTypeId == 1) ? 0 : 1;
    _currencyTabController = TabController(length: 2, vsync: this, initialIndex: initialIndex);
    _currencyTabController.addListener(() {
      if (_currencyTabController.indexIsChanging) return;
      setState(() {
        _handleCurrencyChange();
      });
    });
  }

  @override
  void dispose() {
    _currencyTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PartnerDetailsReportCubit(PartnerReportRepository())
        ..getPartnerDetailsReport(widget.partnerModel.id ?? 0),
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: Text(widget.partnerModel.name ?? 'Hisob-kitob'),
          leading: InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(color: Color.fromRGBO(255, 255, 255, 0.1), blurRadius: 1, spreadRadius: 0, offset: Offset(0, 1)),
                  BoxShadow(color: Color.fromRGBO(50, 50, 93, 0.25), blurRadius: 100, spreadRadius: -20, offset: Offset(0, 50)),
                  BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.3), blurRadius: 60, spreadRadius: -30, offset: Offset(0, 30)),
                ],
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.black),
            ),
          ),
        ),
        body: BlocBuilder<PartnerDetailsReportCubit, PartnerDetailsReportState>(
          builder: (context, state) {
            if (state is PartnerDetailsReportLoading) {
              return _buildShimmerLoading();
            }
            if (state is PartnerDetailsReportError) {
              return Center(child: Text(state.message));
            }
            if (state is PartnerDetailsReportLoaded) {
              final result = state.result;
              return NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverTabBarDelegate(
                        child: Container(
                          color: backgroundColor,
                          child: _buildCurrencyTabBar(),
                        ),
                        height: 70.h,
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  controller: _currencyTabController,
                  children: [
                    _buildDashboardContent('UZS', result.uzs),
                    _buildDashboardContent('USD', result.usd),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildDashboardContent(String currency, PartnerDetailsCurrencyReport report) {
    return CustomScrollView(
      key: PageStorageKey<String>(currency),
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              _buildAnimatedItem(
                index: 0,
                child: BalanceCard(
                  balance: report.balanceAmount,
                  currency: currency,
                  operationsCount: report.operationsCount,
                ),
              ),
              _buildAnimatedItem(
                index: 2,
                child: SummaryGrid(
                  totalIncome: report.incomeAmount,
                  totalExpense: report.expenseAmount,
                  operationsCount: report.operationsCount,
                  currency: currency,
                  onIncomeTap: () => _navigateToHistory(type: 'debt', currency: currency),
                  onExpenseTap: () => _navigateToHistory(type: 'credit', currency: currency),
                ),
              ),
              _buildAnimatedItem(
                index: 3,
                child: DebtAgingGrid(
                  overdueCount: report.qarzExpired.count,
                  todayCount: report.qarzToday.count,
                  upcomingCount: report.qarz3Days.count,
                  onOverdueTap: () => _handleDebtAgingTap("Muddati o'tgan"),
                  onTodayTap: () => _handleDebtAgingTap("Bugun"),
                  onUpcomingTap: () => _handleDebtAgingTap("Yaqinlashmoqda"),
                ),
              ),
              _buildAnimatedItem(
                index: 5,
                child: MonthlyBarChart(
                  stats: report.monthlyStatistics
                      .map((e) => MonthlyStat(month: e.month, income: e.income, expense: e.expense))
                      .toList(),
                  currency: currency,
                ),
              ),
              _buildAnimatedItem(
                index: 6,
                child: BalanceLineChart(
                  spots: report.balanceDynamics.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.balance)).toList(),
                  labels: report.balanceDynamics.map((e) => e.date).toList(),
                  currency: currency,
                ),
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: MediaQuery.of(context).padding.bottom)),
      ],
    );
  }

  Widget _buildCurrencyTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      height: 46.h,
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12.r)),
      padding: EdgeInsets.all(4.w),
      child: TabBar(
        controller: _currencyTabController,
        indicator: BoxDecoration(
          color: AppTheme.colors.primary,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: textSecondary,
        labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
        dividerColor: Colors.transparent,
        indicatorPadding: EdgeInsets.zero,
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: const [
          Tab(text: 'UZS Hisob'),
          Tab(text: 'USD Hisob'),
        ],
      ),
    );
  }

  Widget _buildAnimatedItem({required int index, required Widget child}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(offset: Offset(0, 30 * (1 - value)), child: child),
        );
      },
      child: child,
    );
  }

  // Widget _buildSectionHeader(String title, String subtitle) {
  //   return Padding(
  //     padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 12.h),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               title,
  //               style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: textPrimary),
  //             ),
  //             if (subtitle.isNotEmpty)
  //               Text(
  //                 subtitle,
  //                 style: TextStyle(fontSize: 12.sp, color: textSecondary),
  //               ),
  //           ],
  //         ),
  //         Text(
  //           'Barchasi',
  //           style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: primaryGradientStart),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  //
  // Widget _buildTransactionFilters() {
  //   return Container(
  //     margin: EdgeInsets.symmetric(horizontal: 16.w),
  //     height: 36.h,
  //     child: ListView(
  //       scrollDirection: Axis.horizontal,
  //       children: ['Barchasi', 'Bu oy', 'Bu hafta'].map((filter) {
  //         final isSelected = _transactionFilter == filter;
  //         return GestureDetector(
  //           onTap: () {
  //             setState(() {
  //               _transactionFilter = filter;
  //             });
  //             HapticFeedback.lightImpact();
  //           },
  //           child: Container(
  //             margin: EdgeInsets.only(right: 8.w),
  //             padding: EdgeInsets.symmetric(horizontal: 16.w),
  //             decoration: BoxDecoration(
  //               color: isSelected ? primaryGradientStart : Colors.white,
  //               borderRadius: BorderRadius.circular(20.r),
  //               border: Border.all(color: isSelected ? primaryGradientStart : const Color(0xFFE2E8F0)),
  //             ),
  //             child: Center(
  //               child: Text(
  //                 filter,
  //                 style: TextStyle(fontSize: 13.sp, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? Colors.white : textSecondary),
  //               ),
  //             ),
  //           ),
  //         );
  //       }).toList(),
  //     ),
  //   );
  // }

  void _navigateToHistory({required String type, required String currency}) {
    final currencyId = currency == 'UZS' ? 1 : 2;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<PartnerBloc>(),
          child: HisobKitobTarixPage(
            id: widget.partnerModel.id ?? 0,
            initialType: type,
            initialCurrencyId: currencyId,
          ),
        ),
      ),
    );
  }

  void _handleDebtAgingTap(String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$type qarzlar bo\'yicha batafsil ma\'lumot')),
    );
  }
  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              height: 46.h,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
            ),
            SizedBox(height: 16.h),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              height: 120.h,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
            ),
            SizedBox(height: 16.h),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              height: 140.h,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
            ),
            SizedBox(height: 16.h),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              height: 260.h,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
            ),
          ],
        ),
      ),
    );
  }

  void _handleCurrencyChange() {
    // Logic to recalculate or reload data based on currency
    HapticFeedback.selectionClick();
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _SliverTabBarDelegate({required this.child, required this.height});

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.height != height;
  }
}
