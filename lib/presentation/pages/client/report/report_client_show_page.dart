import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/pages/client/report/models/dashboard_models.dart';
import 'package:hisobchi/presentation/pages/client/report/widgets/balance_card.dart';
import 'package:hisobchi/presentation/pages/client/report/widgets/balance_line_chart.dart';
import 'package:hisobchi/presentation/pages/client/report/widgets/critical_alert_banner.dart';
import 'package:hisobchi/presentation/pages/client/report/widgets/deadline_warning_card.dart';
import 'package:hisobchi/presentation/pages/client/report/widgets/debt_card.dart';
import 'package:hisobchi/presentation/pages/client/report/widgets/monthly_bar_chart.dart';
import 'package:hisobchi/presentation/pages/client/report/widgets/summary_grid.dart';
import 'package:hisobchi/presentation/pages/client/report/widgets/transaction_item.dart';

class ReportClientShowPage extends StatefulWidget {
  const ReportClientShowPage({super.key});

  @override
  State<ReportClientShowPage> createState() => _ReportClientShowPageState();
}

class _ReportClientShowPageState extends State<ReportClientShowPage> with SingleTickerProviderStateMixin {
  late TabController _currencyTabController;
  String _transactionFilter = 'Barchasi';

  // Design Constants
  final Color primaryGradientStart = AppTheme.colors.primary;
  final Color primaryGradientEnd = AppTheme.colors.primary.withValues(alpha: .8);
  final Color backgroundColor = const Color(0xFFF8FAFC);
  final Color textPrimary = const Color(0xFF0F172A);
  final Color textSecondary = const Color(0xFF64748B);

  final List<DebtModel> _debts = [
    DebtModel(id: '1', title: 'Tovar uchun qarz olgan', date: DateTime.now().subtract(const Duration(days: 3)), amount: 388889, currency: 'UZS', delayDays: 3),
    DebtModel(id: '2', title: 'Xizmat haqi', date: DateTime.now().subtract(const Duration(days: 5)), amount: 150000, currency: 'UZS', delayDays: 5),
  ];

  final List<TransactionModel> _transactions = [
    TransactionModel(id: 't1', title: 'Kirim: Tovar sotuvi', date: DateTime.now(), amount: 500000, balanceAfter: 111111, isIncome: true, currency: 'UZS'),
    TransactionModel(id: 't2', title: 'Chiqim: Xom-ashyo', date: DateTime.now().subtract(const Duration(days: 1)), amount: 300000, balanceAfter: -388889, isIncome: false, currency: 'UZS'),
  ];

  @override
  void initState() {
    super.initState();
    _currencyTabController = TabController(length: 2, vsync: this);
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
    return Scaffold(
      backgroundColor: backgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: _buildCurrencyTabBar(),
            ),
          ];
        },
        body: TabBarView(
          controller: _currencyTabController,
          children: [
            _buildDashboardContent('UZS'),
            _buildDashboardContent('USD'),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent(String currency) {
    return CustomScrollView(
      key: PageStorageKey<String>(currency),
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              _buildAnimatedItem(index: 0, child: BalanceCard(balance: 111111, currency: currency)),
              _buildAnimatedItem(index: 1, child: DeadlineWarningCard(deadline: DateTime.now().add(const Duration(days: 7)), daysLeft: 7)),
              _buildAnimatedItem(index: 2, child: SummaryGrid(totalIncome: 1227777, totalExpense: 750000, operationsCount: 5, currency: currency)),
              _buildAnimatedItem(
                index: 3,
                child: const CriticalAlertBanner(message: '1 ta qarz muddati o\'tib ketgan', color: Color(0xFFEF4444), icon: Icons.error_outline_rounded),
              ),
              _buildAnimatedItem(
                index: 4,
                child: const CriticalAlertBanner(message: '1 ta qarz 3 kun ichida to\'lanishi kerak', color: Color(0xFFF59E0B), icon: Icons.warning_amber_rounded),
              ),
              _buildAnimatedItem(
                index: 5,
                child: MonthlyBarChart(
                  stats: const [
                    MonthlyStat(month: 'Avg', income: 1000000, expense: 800000),
                    MonthlyStat(month: 'Sen', income: 1200000, expense: 900000),
                    MonthlyStat(month: 'Okt', income: 900000, expense: 1100000),
                    MonthlyStat(month: 'Noy', income: 1500000, expense: 700000),
                    MonthlyStat(month: 'Dek', income: 1300000, expense: 1000000),
                    MonthlyStat(month: 'Yan', income: 1227777, expense: 750000),
                  ],
                  currency: currency,
                ),
              ),
              _buildAnimatedItem(
                index: 6,
                child: BalanceLineChart(
                  spots: const [FlSpot(0, 500000), FlSpot(1, 800000), FlSpot(2, 600000), FlSpot(3, 1200000), FlSpot(4, 1100000), FlSpot(5, 1227777)],
                  currency: currency,
                ),
              ),

              // Debt List Section
              _buildSectionHeader('Qarzlar ro\'yxati', '${_debts.length} ta qarz ($currency)'),
              ..._debts.asMap().entries.map((entry) {
                final index = entry.key;
                final debt = entry.value;
                return _buildAnimatedItem(
                  index: 7 + index,
                  child: Slidable(
                    key: ValueKey(debt.id),
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (_) => _handlePayDebt(debt),
                          backgroundColor: const Color(0xFF22C55E),
                          foregroundColor: Colors.white,
                          icon: Icons.payments_rounded,
                          label: 'To\'lash',
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ],
                    ),
                    child: DebtCard(debt: debt, onTap: () {}),
                  ),
                );
              }),

              SizedBox(height: 24.h),

              // Transaction History Section
              _buildSectionHeader('Tranzaksiyalar tarixi', ''),
              _buildTransactionFilters(),
              SizedBox(height: 8.h),
              ..._transactions.asMap().entries.map((entry) {
                final index = entry.key;
                final t = entry.value;
                return _buildAnimatedItem(
                  index: 10 + index,
                  child: TransactionItem(transaction: t.copyWith(currency: currency)),
                );
              }),

              SizedBox(height: 48.h),
            ],
          ),
        ),
        SliverToBoxAdapter(child: Gap(MediaQuery.of(context).padding.bottom)),
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

  Widget _buildSectionHeader(String title, String subtitle) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: textPrimary),
              ),
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12.sp, color: textSecondary),
                ),
            ],
          ),
          Text(
            'Barchasi',
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: primaryGradientStart),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionFilters() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      height: 36.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: ['Barchasi', 'Bu oy', 'Bu hafta'].map((filter) {
          final isSelected = _transactionFilter == filter;
          return GestureDetector(
            onTap: () {
              setState(() {
                _transactionFilter = filter;
              });
              HapticFeedback.lightImpact();
            },
            child: Container(
              margin: EdgeInsets.only(right: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: isSelected ? primaryGradientStart : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: isSelected ? primaryGradientStart : const Color(0xFFE2E8F0)),
              ),
              child: Center(
                child: Text(
                  filter,
                  style: TextStyle(fontSize: 13.sp, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? Colors.white : textSecondary),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _handlePayDebt(DebtModel debt) {
    // Show payment dialog logic
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${debt.title} uchun to\'lov qabul qilindi')));
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120.h,
      pinned: true,
      elevation: 0,
      backgroundColor: primaryGradientStart,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [primaryGradientStart, primaryGradientEnd]),
          ),
          child: Stack(
            children: [
              // Decorative circles for premium feel
              Positioned(
                top: -20.h,
                right: -20.w,
                child: CircleAvatar(radius: 60.r, backgroundColor: Colors.white.withValues(alpha: 0.1)),
              ),
              Positioned(
                bottom: 20.h,
                left: -10.w,
                child: CircleAvatar(radius: 30.r, backgroundColor: Colors.white.withValues(alpha: 0.05)),
              ),
            ],
          ),
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test Hamkor',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              '+998 90 123 45 67',
              style: TextStyle(fontSize: 11.sp, color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    );
  }

  void _handleCurrencyChange() {
    // Logic to recalculate or reload data based on currency
    HapticFeedback.selectionClick();
  }
}
