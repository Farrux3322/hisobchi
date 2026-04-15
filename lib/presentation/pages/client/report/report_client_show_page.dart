import 'package:flutter/cupertino.dart';
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
import 'package:hisobchi/presentation/components/back_button.dart';
import 'package:hisobchi/presentation/pages/client/client_xisob_kitob.dart';
import 'package:hisobchi/presentation/pages/client/report/models/dashboard_models.dart';
import 'package:hisobchi/presentation/pages/client/report/partner_installment_report_page.dart';
import 'package:hisobchi/presentation/pages/client/report/widgets/balance_card.dart';
import 'package:hisobchi/presentation/pages/client/report/widgets/balance_line_chart.dart';
import 'package:hisobchi/presentation/pages/client/report/widgets/debt_aging_grid.dart';
import 'package:hisobchi/presentation/pages/client/report/widgets/monthly_bar_chart.dart';
import 'package:hisobchi/presentation/pages/client/report/widgets/summary_grid.dart';
import 'package:hisobchi/presentation/pages/client/report/partner_debt_detail_page.dart';
import 'package:shimmer/shimmer.dart';

import 'package:hisobchi/application/partner_report/export_excel/export_single_partner_excel_bloc.dart';
import 'package:hisobchi/application/partner_report/export_excel/export_single_partner_excel_event.dart';
import 'package:hisobchi/application/partner_report/export_excel/export_single_partner_excel_state.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hisobchi/presentation/components/toast/toast.dart';

class ReportClientShowPage extends StatefulWidget {
  final PartnerModel partnerModel;

  /// 0 = "Hisob kitob" tab (default)
  /// 1 = "Muddatli to'lov" tab
  final int initialTabIndex;

  const ReportClientShowPage({
    super.key,
    required this.partnerModel,
    this.initialTabIndex = 0,
  });

  @override
  State<ReportClientShowPage> createState() => _ReportClientShowPageState();
}

class _ReportClientShowPageState extends State<ReportClientShowPage>
    with TickerProviderStateMixin {
  // ─── Tab controllers ───────────────────────────────────────────────────────
  late TabController _mainTabController;     // Hisob kitob | Muddatli to'lov
  late TabController _currencyTabController; // UZS | USD (faqat Tab 1 ichida)

  // ─── Design constants ──────────────────────────────────────────────────────
  final Color backgroundColor = AppTheme.colors.background;
  final Color textSecondary = const Color(0xFF64748B);

  @override
  void initState() {
    super.initState();

    _mainTabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 1),
    );
    _mainTabController.addListener(() {
      if (!_mainTabController.indexIsChanging) setState(() {});
    });


    _currencyTabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: 0,
    );
    _currencyTabController.addListener(() {
      if (_currencyTabController.indexIsChanging) return;
      setState(() => HapticFeedback.selectionClick());
    });
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    _currencyTabController.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => PartnerDetailsReportCubit(PartnerReportRepository())
            ..getPartnerDetailsReport(widget.partnerModel.id ?? 0),
        ),
        BlocProvider(
          create: (context) =>
              ExportSinglePartnerExcelBloc(repository: PartnerReportRepository()),
        ),
      ],
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            widget.partnerModel.name ?? 'Hisob-kitob',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          leading: BackArrowButton(),
          actions: [
            // Excel export faqat "Hisob kitob" tabida ko'rinadi
            if (_mainTabController.index == 0) _ExcelExportAction(
              partnerId: widget.partnerModel.id ?? 0,
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(54.h),
            child: _buildMainTabBar(),
          ),
        ),
        body: TabBarView(
          controller: _mainTabController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            // ── Tab 1: Hisob kitob ────────────────────────────────────────
            _buildHisobKitobTab(),

            // ── Tab 2: Muddatli to'lov hisobot ────────────────────────────
            PartnerInstallmentReportBody(partnerModel: widget.partnerModel),
          ],
        ),
      ),
    );
  }

  // ─── Asosiy tab paneli ─────────────────────────────────────────────────────

  Widget _buildMainTabBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 8.h),
      child: Container(
        height: 40.h,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10.r),
        ),
        padding: const EdgeInsets.all(3),
        child: TabBar(
          controller: _mainTabController,
          indicator: BoxDecoration(
            color: AppTheme.colors.primary,
            borderRadius: BorderRadius.circular(8.r),
            boxShadow: [
              BoxShadow(
                color: AppTheme.colors.primary.withValues(alpha: 0.25),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          labelColor: Colors.white,
          unselectedLabelColor: textSecondary,
          labelStyle:
              TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
          unselectedLabelStyle:
              TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
          dividerColor: Colors.transparent,
          indicatorPadding: EdgeInsets.zero,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(text: 'Hisob kitob'),
            Tab(text: "Muddatli to'lov"),
          ],
        ),
      ),
    );
  }

  // ─── Tab 1 kontent ─────────────────────────────────────────────────────────

  Widget _buildHisobKitobTab() {
    return BlocBuilder<PartnerDetailsReportCubit, PartnerDetailsReportState>(
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
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverTabBarDelegate(
                  child: Container(
                    color: backgroundColor,
                    margin: EdgeInsets.only(bottom: 8.h),
                    child: _buildCurrencyTabBar(),
                  ),
                  height: 62.h,
                ),
              ),
            ],
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
    );
  }

  // ─── UZS/USD tab paneli ────────────────────────────────────────────────────

  Widget _buildCurrencyTabBar() {
    return AnimatedBuilder(
      animation: _currencyTabController,
      builder: (context, _) => Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _CurrencyTabItem(
                label: 'UZS Hisob',
                selected: _currencyTabController.index == 0,
                onTap: () => _currencyTabController.animateTo(0),
              ),
              _CurrencyTabDivider(),
              _CurrencyTabItem(
                label: 'USD Hisob',
                selected: _currencyTabController.index == 1,
                onTap: () => _currencyTabController.animateTo(1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Dashboard kontent ─────────────────────────────────────────────────────

  Widget _buildDashboardContent(
      String currency, PartnerDetailsCurrencyReport report) {
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
                  onIncomeTap: () =>
                      _navigateToHistory(type: 'debt', currency: currency),
                  onExpenseTap: () =>
                      _navigateToHistory(type: 'credit', currency: currency),
                ),
              ),
              _buildAnimatedItem(
                index: 3,
                child: DebtAgingGrid(
                  overdueCount: report.qarzExpired.count,
                  todayCount: report.qarzToday.count,
                  upcomingCount: report.qarz3Days.count,
                  onOverdueTap: () =>
                      _handleDebtAgingTap("Muddati o'tgan", currency),
                  onTodayTap: () => _handleDebtAgingTap("Bugun", currency),
                  onUpcomingTap: () =>
                      _handleDebtAgingTap("Yaqinlashmoqda", currency),
                ),
              ),
              _buildAnimatedItem(
                index: 5,
                child: MonthlyBarChart(
                  stats: report.monthlyStatistics
                      .map((e) => MonthlyStat(
                          month: e.month,
                          income: e.income,
                          expense: e.expense))
                      .toList(),
                  currency: currency,
                ),
              ),
              _buildAnimatedItem(
                index: 6,
                child: BalanceLineChart(
                  spots: report.balanceDynamics
                      .asMap()
                      .entries
                      .map((e) => FlSpot(e.key.toDouble(), e.value.balance))
                      .toList(),
                  labels:
                      report.balanceDynamics.map((e) => e.date).toList(),
                  currency: currency,
                ),
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
              height: MediaQuery.of(context).padding.bottom + 90),
        ),
      ],
    );
  }

  // ─── Animated wrapper ──────────────────────────────────────────────────────

  Widget _buildAnimatedItem({required int index, required Widget child}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child:
            Transform.translate(offset: Offset(0, 30 * (1 - value)), child: child),
      ),
      child: child,
    );
  }

  // ─── Navigation helpers ────────────────────────────────────────────────────

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
            partnerPhone: widget.partnerModel.phone,
          ),
        ),
      ),
    );
  }

  void _handleDebtAgingTap(String title, String currency) {
    final type = switch (title) {
      "Muddati o'tgan" => 'qarz_expired',
      "Bugun" => 'qarz_today',
      "Yaqinlashmoqda" => 'qarz_3_days',
      _ => '',
    };
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PartnerDebtDetailPage(
          type: type,
          currencyTypeId: currency == 'UZS' ? 1 : 2,
          title: title,
          partnerId: widget.partnerModel.id!,
        ),
      ),
    );
  }

  // ─── Shimmer ───────────────────────────────────────────────────────────────

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
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            SizedBox(height: 16.h),
            ...List.generate(
              3,
              (i) => Container(
                margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                height: i == 0 ? 120.h : 140.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Excel export action widget ────────────────────────────────────────────────

class _ExcelExportAction extends StatelessWidget {
  const _ExcelExportAction({required this.partnerId});
  final int partnerId;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ExportSinglePartnerExcelBloc,
        ExportSinglePartnerExcelState>(
      listener: (context, state) {
        if (state is ExportSinglePartnerExcelSuccess) {
          SharePlus.instance.share(
            ShareParams(files: [XFile(state.filePath)], text: 'Mijoz Hisoboti'),
          );
        } else if (state is ExportSinglePartnerExcelFailure) {
          Toast.showErrorToast(message: state.error);
        }
      },
      builder: (context, state) {
        final isLoading = state is ExportSinglePartnerExcelLoading;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: PopupMenuButton<int>(
            offset: const Offset(0, 48),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            elevation: 8,
            color: Colors.white,
            icon: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CupertinoActivityIndicator(
                        color: AppTheme.colors.primary, radius: 10),
                  )
                : const Icon(CupertinoIcons.ellipsis_vertical,
                    color: Colors.black),
            onSelected: (value) {
              if (value == 1 && !isLoading) {
                context
                    .read<ExportSinglePartnerExcelBloc>()
                    .add(DownloadSinglePartnerExcelRequested(partnerId));
              }
            },
            constraints: const BoxConstraints(minWidth: 10, maxWidth: 180),
            itemBuilder: (context) => [
              PopupMenuItem<int>(
                value: 1,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 40,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.file_download_outlined,
                        color: AppTheme.colors.primary, size: 22),
                    const SizedBox(width: 8),
                    const Text(
                      'Excel Hisobot',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Currency tab item ────────────────────────────────────────────────────────

class _CurrencyTabItem extends StatelessWidget {
  const _CurrencyTabItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

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
              fontSize: 14,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              color: selected
                  ? const Color(0xFF0F172A)
                  : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }
}

class _CurrencyTabDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 2,
            height: 12,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 2),
          Container(
            width: 2,
            height: 12,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      );
}

// ─── Sliver tab bar delegate ───────────────────────────────────────────────────

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _SliverTabBarDelegate({required this.child, required double height})
      : height = height.roundToDouble();

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
          BuildContext context, double shrinkOffset, bool overlapsContent) =>
      SizedBox.expand(child: child);

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) =>
      oldDelegate.child != child || oldDelegate.height != height;
}
