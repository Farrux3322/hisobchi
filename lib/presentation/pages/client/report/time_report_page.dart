import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/time_report/time_report_operations_bloc.dart';
import 'package:hisobchi/application/time_report/time_report_operations_event.dart';
import 'package:hisobchi/application/time_report/time_report_operations_state.dart';
import 'package:hisobchi/application/time_report/time_report_summary_bloc.dart';
import 'package:hisobchi/application/time_report/time_report_summary_event.dart';
import 'package:hisobchi/application/time_report/time_report_summary_state.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/models/partner_operations_detail_model.dart';
import 'package:hisobchi/infrastructure/repository/partner_report/partner_report_repository.dart';
import 'package:hisobchi/presentation/components/back_button.dart';
import 'package:hisobchi/presentation/pages/client/report/widgets/partner_operation_detail_sheet.dart';
import 'package:shimmer/shimmer.dart';

import '../../../assets/asset_index.dart';

class TimeReportPage extends StatelessWidget {
  const TimeReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => TimeReportSummaryBloc(repository: PartnerReportRepository())
            ..add(const LoadTimeReportSummaryEvent()),
        ),
        BlocProvider(
          create: (_) => TimeReportOperationsBloc(repository: PartnerReportRepository())
            ..add(const LoadTimeReportOperationsEvent(currencyTypeId: 1)),
        ),
      ],
      child: const _TimeReportView(),
    );
  }
}

class _TimeReportView extends StatefulWidget {
  const _TimeReportView();

  @override
  State<_TimeReportView> createState() => _TimeReportViewState();
}

class _TimeReportViewState extends State<_TimeReportView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  int _selectedPeriod = 0; // -1 means custom date range
  final List<String> _periods = ['Barchasi', 'Bugun', 'Bu hafta', 'Bu oy'];

  int _selectedOperationType = 0;

  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _toDate = DateTime.now();

  final _fmt = DateFormat('dd.MM.yyyy');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {}); // to rebuild UZS/USD view
        _loadSummary();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification) {
      if (notification.metrics.pixels >= notification.metrics.maxScrollExtent * 0.9) {
        context.read<TimeReportOperationsBloc>().add(const LoadMoreTimeReportOperationsEvent());
      }
    }
    return false;
  }

  // ─── Called every time a filter changes ──────────────────────────────────
  void _loadSummary() {
    List<String>? dateRange;

    switch (_selectedPeriod) {
      case 0: // Barchasi – null yuboramiz
        dateRange = null;
        break;
      case 1: // Bugun
        final today = _fmt.format(DateTime.now());
        dateRange = [today, today];
        break;
      case 2: // Bu hafta
        final now = DateTime.now();
        final start = now.subtract(Duration(days: now.weekday - 1));
        dateRange = [_fmt.format(start), _fmt.format(now)];
        break;
      case 3: // Bu oy
        final now = DateTime.now();
        final start = DateTime(now.year, now.month, 1);
        dateRange = [_fmt.format(start), _fmt.format(now)];
        break;
      case -1: // Custom range
        dateRange = [_fmt.format(_fromDate), _fmt.format(_toDate)];
        break;
    }

    // 1. Load Summary Data
    context.read<TimeReportSummaryBloc>().add(LoadTimeReportSummaryEvent(date: dateRange));

    // 2. Load Operations History
    final currentCurrency = _tabController.index == 0 ? 1 : 2; // 1 = UZS, 2 = USD
    String? opType;
    if (_selectedOperationType == 1) opType = 'debt'; // Kirim
    if (_selectedOperationType == 2) opType = 'credit'; // Chiqim

    context.read<TimeReportOperationsBloc>().add(LoadTimeReportOperationsEvent(
      date: dateRange,
      currencyTypeId: currentCurrency,
      type: opType,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildContent(isUZS: true),
                _buildContent(isUZS: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── AppBar ───────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: const BackArrowButton(),
      centerTitle: true,
      title: const Text('Muddat hisoboti', style: TextStyle(color: Color(0xFF1E293B), fontSize: 18, fontWeight: FontWeight.w700)),
    );
  }

  // ─── Tab bar ──────────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9), 
          borderRadius: BorderRadius.circular(16.r)
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _tabController.animateTo(0),
                child: Container(
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  child: Text(
                    'UZS Hisob',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: _tabController.index == 0 ? FontWeight.w700 : FontWeight.w600,
                      color: _tabController.index == 0 ? const Color(0xFF1E293B) : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ),
            Text(
              '||',
              style: TextStyle(
                color: const Color(0xFFCBD5E1), // Light grayish-blue for separator
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => _tabController.animateTo(1),
                child: Container(
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  child: Text(
                    'USD Hisob',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: _tabController.index == 1 ? FontWeight.w700 : FontWeight.w600,
                      color: _tabController.index == 1 ? const Color(0xFF1E293B) : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Content ──────────────────────────────────────────────────────────────
  Widget _buildContent({required bool isUZS}) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPeriodFilter(),
              SizedBox(height: 14.h),
              _buildDateRangeRow(),
              SizedBox(height: 14.h),

              // Jami Kirim va Chiqim — BlocBuilder bilan
              BlocBuilder<TimeReportSummaryBloc, TimeReportSummaryState>(
                builder: (context, state) {
                  if (state.isLoading || state.isInitial) {
                    return _buildStatCardsShimmer();
                  }
                  if (state.isError) {
                    return _buildStatCardsError(state.errorMessage ?? 'Xatolik yuz berdi');
                  }
                  final currency = isUZS ? state.uzs : state.usd;
                  final debt = currency?.debtAmount ?? 0.0;
                  final credit = currency?.creditAmount ?? 0.0;
                  final label = isUZS ? 'UZS' : 'USD';
                  return _buildStatCards(debt, credit, label);
                },
              ),

              SizedBox(height: 20.h),
              _buildSectionHeader(),
              SizedBox(height: 12.h),
            ],
          ),
        ),
        
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: _onScrollNotification,
            child: BlocBuilder<TimeReportOperationsBloc, TimeReportOperationsState>(
              builder: (context, state) {
                if (state.isLoading && state.operations.isEmpty) {
                  return ListView(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    children: [
                       _buildOperationsShimmer(),
                    ],
                  );
                }
                if (state.operations.isEmpty) {
                  return Center(
                    child: Text(
                      'Ma\'lumot topilmadi',
                      style: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h + MediaQuery.of(context).padding.bottom),
                  itemCount: state.operations.length + (state.statusMore == Status.loading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == state.operations.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return _buildOperationCard(state.operations[index], isUZS ? 'UZS' : 'USD');
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // ─── Period filter chips ──────────────────────────────────────────────────
  Widget _buildPeriodFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_periods.length, (i) {
          final selected = _selectedPeriod == i;
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedPeriod = i);
                _loadSummary();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
                decoration: BoxDecoration(
                  color: selected ? AppTheme.colors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: selected ? AppTheme.colors.primary : const Color(0xFFE2E8F0)),
                  boxShadow: selected
                      ? [BoxShadow(color: AppTheme.colors.primary.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3))]
                      : [],
                ),
                child: Text(
                  _periods[i],
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─── Date range picker row ────────────────────────────────────────────────
  Widget _buildDateRangeRow() {
    final bool isSelected = _selectedPeriod == -1;
    return GestureDetector(
      onTap: () async {
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          initialDateRange: DateTimeRange(start: _fromDate, end: _toDate),
          builder: (ctx, child) => Theme(
            data: ThemeData.light().copyWith(colorScheme: ColorScheme.light(primary: AppTheme.colors.primary)),
            child: child!,
          ),
        );
        if (picked != null) {
          setState(() {
            _fromDate = picked.start;
            _toDate = picked.end;
            _selectedPeriod = -1; // Deselect predefined periods
          });
          _loadSummary(); // Range tanlanganida so'rov yuboramiz
        } else {
          // You could also decide to just set _selectedPeriod = -1 here if user tapped and dismissed, 
          // but typically if they dismiss and there's a valid date, we can just make it active.
          setState(() {
            _selectedPeriod = -1;
          });
          _loadSummary();
        }
      },
      child: Row(
        children: [
          Expanded(child: _buildDateChip(_fromDate, isSelected)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Icon(Icons.arrow_forward, color: isSelected ? AppTheme.colors.primary : const Color(0xFF94A3B8), size: 18),
          ),
          Expanded(child: _buildDateChip(_toDate, isSelected)),
        ],
      ),
    );
  }

  Widget _buildDateChip(DateTime date, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.colors.primary.withValues(alpha: 0.1) : Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: isSelected ? AppTheme.colors.primary : const Color(0xFFE2E8F0)),
        boxShadow: isSelected
            ? [BoxShadow(color: AppTheme.colors.primary.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))]
            : [],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_rounded, size: 15.r, color: isSelected ? AppTheme.colors.primary : const Color(0xFF94A3B8)),
          SizedBox(width: 6.w),
          Text(
            '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}',
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: isSelected ? AppTheme.colors.primary : const Color(0xFF1E293B)),
          ),
        ],
      ),
    );
  }


  // ─── Stat Cards ──────────────────────────────────────────────────────────
  Widget _buildStatCards(double income, double expense, String currency) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: 'Jami kirim',
            amount: income,
            currency: currency,
            color: const Color(0xFF16A34A),
            icon: Icons.south_west_rounded,
            isSelected: _selectedOperationType == 1,
            isOtherSelected: _selectedOperationType == 2,
            onTap: () {
              setState(() {
                _selectedOperationType = _selectedOperationType == 1 ? 0 : 1;
              });
              _loadSummary();
            },
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard(
            label: 'Jami chiqim',
            amount: expense,
            currency: currency,
            color: const Color(0xFFDC2626),
            icon: Icons.north_east_rounded,
            isSelected: _selectedOperationType == 2,
            isOtherSelected: _selectedOperationType == 1,
            onTap: () {
              setState(() {
                _selectedOperationType = _selectedOperationType == 2 ? 0 : 2;
              });
              _loadSummary();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required double amount,
    required String currency,
    required Color color,
    required IconData icon,
    required bool isSelected,
    required bool isOtherSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isOtherSelected ? 0.5 : 1.0,
        child: Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16.r),
            border: isSelected ? Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2) : null,
            boxShadow: [
              if (!isOtherSelected)
                BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.white.withValues(alpha: 0.85), size: 16.r),
                  SizedBox(width: 6.w),
                  Text(label, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.9))),
                ],
              ),
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      _formatDouble(amount),
                      style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.3),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Padding(
                    padding: EdgeInsets.only(bottom: 2.h),
                    child: Text(currency, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.75))),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Shimmer placeholder ──────────────────────────────────────────────────
  Widget _buildStatCardsShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 90.h,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Container(
              height: 90.h,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Error state ──────────────────────────────────────────────────────────
  Widget _buildStatCardsError(String message) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFDC2626)),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(message, style: TextStyle(fontSize: 13.sp, color: const Color(0xFFDC2626))),
          ),
          GestureDetector(
            onTap: _loadSummary,
            child: Icon(Icons.refresh_rounded, color: const Color(0xFFDC2626), size: 20.r),
          ),
        ],
      ),
    );
  }

  // ─── Section Header ───────────────────────────────────────────────────────
  Widget _buildSectionHeader() {
    return Row(
      children: [
        Text(
          "Operatsiyalar",
          style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: const Color(0xFF94A3B8), letterSpacing: 1.2),
        ),
        SizedBox(width: 10.w),
        Expanded(child: Container(height: 1, color: const Color(0xFFE2E8F0))),
      ],
    );
  }

  // ─── Operations Shimmer ──────────────────────────────────────────────────
  Widget _buildOperationsShimmer() {
    return Column(
      children: List.generate(
        6,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Shimmer.fromColors(
            baseColor: const Color(0xFFE2E8F0),
            highlightColor: const Color(0xFFF8FAFC),
            child: Container(
              height: 80.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Operation Card ────────────────────────────────────────────────────────
  Widget _buildOperationCard(PartnerOperation op, String currency) {
    final isDebt = op.isDebt; // Kirim -> green, Chiqim -> red
    final color = isDebt ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
    final icon = isDebt ? Icons.south_west_rounded : Icons.north_east_rounded;
    final prefix = isDebt ? '+' : '-';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => PartnerOperationDetailSheet(operation: op),
            );
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(icon, color: color, size: 22.r),
                ),
                SizedBox(width: 14.w),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        op.partnerName,
                        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${op.createdAt} • ${op.typeDisplay}',
                        style: TextStyle(fontSize: 12.sp, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10.w),
                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                     Text(
                      '$prefix${_formatDouble(op.amount)}',
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: color),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      currency,
                      style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
  String _formatDouble(double amount) {
    if (amount == 0) return '0';
    final formatter = NumberFormat('#,###.##', 'en_US');
    return formatter.format(amount.abs()).replaceAll(',', ' ');
  }

}
