import 'package:flutter/material.dart';
import 'package:hisobchi/presentation/components/back_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/staff_report/staff_report_summary_bloc.dart';
import 'package:hisobchi/application/staff_report/staff_report_summary_event.dart';
import 'package:hisobchi/application/staff_report/staff_report_summary_state.dart';
import 'package:hisobchi/application/staff_report/staff_report_workers_bloc.dart';
import 'package:hisobchi/application/staff_report/staff_report_workers_event.dart';
import 'package:hisobchi/application/staff_report/staff_report_workers_state.dart';
import 'package:hisobchi/infrastructure/models/staff_worker_model.dart';
import 'package:hisobchi/infrastructure/repository/partner_report/partner_report_repository.dart';
import 'package:shimmer/shimmer.dart';

import '../../../assets/asset_index.dart';
import 'worker_report_page.dart';

class StaffReportPage extends StatelessWidget {
  const StaffReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => StaffReportSummaryBloc(repository: PartnerReportRepository())),
        BlocProvider(create: (_) => StaffReportWorkersBloc(repository: PartnerReportRepository())),
      ],
      child: const _StaffReportView(),
    );
  }
}

class _StaffReportView extends StatefulWidget {
  const _StaffReportView();

  @override
  State<_StaffReportView> createState() => _StaffReportViewState();
}

class _StaffReportViewState extends State<_StaffReportView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Period filter
  int _selectedPeriod = 0; // -1 means custom date range
  final List<String> _periods = ['Barchasi', 'Bugun', 'Bu hafta', 'Bu oy'];

  // Operation Type filter
  int _selectedOperationType = 0; // 0: All, 1: Income, 2: Expense

  // Date range (shown when custom corresponds to -1)
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _toDate = DateTime.now();

  final _fmt = DateFormat('dd.MM.yyyy');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {}); // Tab o'zgarganda UZS/USD ko'rinishni yangilash
        _loadSummary();
      }
    });

    // Initial fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSummary();
    });
  }

  void _loadSummary() {
    List<String>? dateRange;

    switch (_selectedPeriod) {
      case 0: // Barchasi
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

    final currentCurrency = _tabController.index == 0 ? 1 : 2;

    context.read<StaffReportSummaryBloc>().add(LoadStaffReportSummaryEvent(date: dateRange));
    context.read<StaffReportWorkersBloc>().add(LoadStaffReportWorkersEvent(date: dateRange, currencyTypeId: currentCurrency));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // UZS / USD tab bar
          _buildTabBar(),
          Expanded(child: _buildContent(isUZS: _tabController.index == 0)),
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
      title: const Text(
        'Xodimlar hisoboti',
        style: TextStyle(color: Color(0xFF1E293B), fontSize: 18, fontWeight: FontWeight.w700),
      ),
    );
  }

  // ─── Tab bar (UZS / USD) ──────────────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16.r)),
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
              style: TextStyle(color: const Color(0xFFCBD5E1), fontSize: 12.sp, fontWeight: FontWeight.w800, letterSpacing: 1.5),
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

  // ─── Main scroll content ──────────────────────────────────────────────────
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

              // Summary stat cards linked via BLoC
              BlocBuilder<StaffReportSummaryBloc, StaffReportSummaryState>(
                builder: (context, state) {
                  if (state.isLoading || state.isInitial) {
                    return _buildStatCardsShimmer();
                  }
                  if (state.isError) {
                    return _buildStatCardsError(state.errorMessage ?? 'Xatolik yuz berdi');
                  }
                  final currency = isUZS ? state.uzs : state.usd;
                  // Parse from string (API returns string)
                  final debt = double.tryParse(currency?.debt ?? '0') ?? 0.0;
                  final credit = double.tryParse(currency?.credit ?? '0') ?? 0.0;
                  final label = isUZS ? 'UZS' : 'USD';

                  return _buildStatCards(debt, credit, label);
                },
              ),
              SizedBox(height: 20.h),

              // Section header
              _buildSectionHeader(),
              SizedBox(height: 12.h),
            ],
          ),
        ),

        Expanded(
          child: BlocBuilder<StaffReportWorkersBloc, StaffReportWorkersState>(
            builder: (context, state) {
              if (state.isLoading || state.isInitial) {
                return ListView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  children: List.generate(3, (index) => _buildStaffCardShimmer()),
                );
              }

              if (state.isError) {
                return Center(
                  child: Text(
                    state.errorMessage ?? 'Internet xatosi yuz berdi',
                    style: TextStyle(color: Colors.red[400], fontSize: 13.sp),
                  ),
                );
              }

              if (state.workers.isEmpty) {
                return Center(
                  child: Text(
                    'Xodimlar topilmadi',
                    style: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h + MediaQuery.of(context).padding.bottom),
                itemCount: state.workers.length,
                itemBuilder: (context, index) {
                  return _buildStaffCard(state.workers[index], isUZS ? 'UZS' : 'USD');
                },
              );
            },
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
                _loadSummary(); // Call API on filter change
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
                decoration: BoxDecoration(
                  color: selected ? AppTheme.colors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: selected ? AppTheme.colors.primary : const Color(0xFFE2E8F0)),
                  boxShadow: selected ? [BoxShadow(color: AppTheme.colors.primary.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3))] : [],
                ),
                child: Text(
                  _periods[i],
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: selected ? Colors.white : const Color(0xFF64748B)),
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
    String fromStr = '${_fromDate.day.toString().padLeft(2, '0')}.${_fromDate.month.toString().padLeft(2, '0')}.${_fromDate.year}';
    String toStr = '${_toDate.day.toString().padLeft(2, '0')}.${_toDate.month.toString().padLeft(2, '0')}.${_toDate.year}';

    return GestureDetector(
      onTap: () async {
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          initialDateRange: DateTimeRange(start: _fromDate, end: _toDate),
        );
        if (picked != null) {
          setState(() {
            _fromDate = picked.start;
            _toDate = picked.end;
            _selectedPeriod = -1; // Deselect predefined periods
          });
          _loadSummary();
        } else {}
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.colors.primary.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: isSelected ? AppTheme.colors.primary : const Color(0xFFE2E8F0)),
          boxShadow: isSelected ? [BoxShadow(color: AppTheme.colors.primary.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))] : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_month_rounded, size: 20.r, color: isSelected ? AppTheme.colors.primary : const Color(0xFF94A3B8)),
            SizedBox(width: 10.w),
            Text(
              '$fromStr — $toStr',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: isSelected ? AppTheme.colors.primary : const Color(0xFF1E293B)),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, size: 14.r, color: const Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  // ─── Summary stat cards (Jami kirim / Jami chiqim) ───────────────────────
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
            boxShadow: [if (!isOtherSelected) BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.white.withValues(alpha: 0.85), size: 16.r),
                  SizedBox(width: 6.w),
                  Text(
                    label,
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.9)),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      _formatAmount(amount),
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.3),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  // Padding(
                  //   padding: EdgeInsets.only(bottom: 2.h),
                  //   child: Text(currency, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.75))),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Shimmers and Errors ─────────────────────────────────────────────────
  Widget _buildStatCardsShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 104.h,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Container(
              height: 104.h,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCardsError(String message) {
    return Container(
      width: double.infinity,
      height: 104.h,
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFFECDD3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, color: const Color(0xFFEF4444), size: 24.sp),
          SizedBox(height: 8.h),
          Text(
            'Xatolik yuz berdi',
            style: TextStyle(color: const Color(0xFF991B1B), fontSize: 13.sp, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffCardShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        height: 140.h,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
      ),
    );
  }

  // ─── Section header ───────────────────────────────────────────────────────
  Widget _buildSectionHeader() {
    return Row(
      children: [
        Text(
          "Xodimlar bo'yicha",
          style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: const Color(0xFF94A3B8), letterSpacing: 1.2),
        ),
        SizedBox(width: 10.w),
        Expanded(child: Container(height: 1, color: const Color(0xFFE2E8F0))),
      ],
    );
  }

  // ─── Staff card ───────────────────────────────────────────────────────────
  Widget _buildStaffCard(StaffWorkerModel staff, String currency) {
    // Generate simple initials and deterministic color based on ID
    final initials = staff.name.isNotEmpty ? staff.name.substring(0, 1).toUpperCase() : '?';
    final colors = [const Color(0xFF6366F1), const Color(0xFF10B981), const Color(0xFFF59E0B), const Color(0xFFEC4899), const Color(0xFF3B82F6)];
    final color = colors[staff.id % colors.length];

    final debtValue = double.tryParse(staff.debt) ?? 0.0;
    final creditValue = double.tryParse(staff.credit) ?? 0.0;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => WorkerReportPage(worker: staff)));
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              children: [
                // Name + role row
                Row(
                  children: [
                    // Avatar
                    Container(
                      width: 44.r,
                      height: 44.r,
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
                      child: Center(
                        child: Text(
                          initials,
                          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: color),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            staff.name,
                            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
                          ),
                          if (staff.role == 'staff') SizedBox(height: 2.h),
                          if (staff.role == 'staff')
                            Text(
                              staff.role == 'staff' ? 'Xodim' : '',
                              style: TextStyle(fontSize: 12.sp, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                            ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey[300], size: 20.r),
                  ],
                ),

                SizedBox(height: 14.h),

                // Metrics row
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10.r)),
                  child: Row(
                    children: [
                      _buildMetric(label: 'Kirim', value: '+${_formatAmount(debtValue)}', color: const Color(0xFF16A34A)),
                      _buildVerticalDivider(),
                      _buildMetric(label: 'Chiqim', value: '-${_formatAmount(creditValue)}', color: const Color(0xFFDC2626)),
                      _buildVerticalDivider(),
                      _buildMetric(label: 'Operatsiya', value: '${staff.operationsCount} ta', color: AppTheme.colors.primary),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetric({required String label, required String value, required Color color}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: color),
          ),
          SizedBox(height: 3.h),
          Text(
            label,
            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w500, color: const Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(width: 1, height: 30.h, color: const Color(0xFFE2E8F0));
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
  String _formatAmount(dynamic amount) {
    if (amount == null) return "0";
    if (amount is double) {
      if (amount == 0) return '0';
      final formatter = NumberFormat('#,###', 'en_US');
      return formatter.format(amount.abs()).replaceAll(',', ' ');
    } else if (amount is int) {
      return amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ');
    }
    return '0';
  }
}
