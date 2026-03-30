import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hisobchi/presentation/assets/theme/app_theme.dart';
import 'package:hisobchi/presentation/components/back_button.dart';

class StaffReportPage extends StatefulWidget {
  const StaffReportPage({super.key});

  @override
  State<StaffReportPage> createState() => _StaffReportPageState();
}

class _StaffReportPageState extends State<StaffReportPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Period filter
  int _selectedPeriod = 0; // 0: Barchasi, 1: Bugun, 2: Bu hafta, 3: Bu oy, 4: Boshqa
  final List<String> _periods = ['Barchasi', 'Bugun', 'Bu hafta', 'Bu oy', 'Boshqa'];

  // Date range (shown when "Boshqa" selected)
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _toDate = DateTime.now();

  // Mock data – replace with real model later
  final List<Map<String, dynamic>> _staffList = [
    {
      'name': 'Akbar Karimov',
      'role': 'Menejer',
      'initials': 'AK',
      'color': const Color(0xFF6366F1),
      'income': 1450000,
      'expense': 990000,
      'operations': 5,
    },
    {
      'name': 'Sarvinoz Nazarova',
      'role': 'Operator',
      'initials': 'SN',
      'color': const Color(0xFF10B981),
      'income': 1000000,
      'expense': 900000,
      'operations': 3,
    },
    {
      'name': 'Jasur Toshmatov',
      'role': 'Kassir',
      'initials': 'JT',
      'color': const Color(0xFFF59E0B),
      'income': 780000,
      'expense': 650000,
      'operations': 7,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int totalIncome = _staffList.fold(0, (sum, s) => sum + (s['income'] as int));
    final int totalExpense = _staffList.fold(0, (sum, s) => sum + (s['expense'] as int));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // UZS / USD tab bar
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildContent(totalIncome, totalExpense, 'UZS'),
                _buildContent(totalIncome ~/ 12, totalExpense ~/ 12, 'USD'),
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
      title: const Text(
        'Xodimlar hisoboti',
        style: TextStyle(color: Color(0xFF1E293B), fontSize: 18, fontWeight: FontWeight.w700),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Color(0xFF1E293B)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'excel', child: Row(children: [Icon(Icons.file_download_outlined, size: 18), SizedBox(width: 8), Text('Excel yuklash')])),
          ],
        ),
      ],
    );
  }

  // ─── Tab bar (UZS / USD) ──────────────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
      child: Container(
        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12.r)),
        child: TabBar(
          controller: _tabController,
          onTap: (_) => setState(() {}),
          indicator: BoxDecoration(color: AppTheme.colors.primary, borderRadius: BorderRadius.circular(12.r)),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey[700],
          labelStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
          tabs: const [Tab(text: 'UZS'), Tab(text: 'USD')],
        ),
      ),
    );
  }

  // ─── Main scroll content ──────────────────────────────────────────────────
  Widget _buildContent(int totalIncome, int totalExpense, String currency) {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        // Period filter chips
        _buildPeriodFilter(),
        SizedBox(height: 14.h),

        // Date range row (visible only when "Boshqa" selected)
        if (_selectedPeriod == 4) ...[
          _buildDateRangeRow(),
          SizedBox(height: 14.h),
        ],

        // Summary stat cards
        _buildStatCards(totalIncome, totalExpense, currency),
        SizedBox(height: 20.h),

        // Section header
        _buildSectionHeader(),
        SizedBox(height: 12.h),

        // Staff list
        ..._staffList.map((s) => _buildStaffCard(s, currency)),
        SizedBox(height: 16.h),
      ],
    );
  }

  // ─── Period filter chips ──────────────────────────────────────────────────
  Widget _buildPeriodFilter() {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: List.generate(_periods.length, (i) {
        final selected = _selectedPeriod == i;
        return GestureDetector(
          onTap: () => setState(() => _selectedPeriod = i),
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
        );
      }),
    );
  }

  // ─── Date range picker row ─────────────────────────────────────────────────
  Widget _buildDateRangeRow() {
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
          });
        }
      },
      child: Row(
        children: [
          Expanded(child: _buildDateChip(_fromDate)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: const Icon(Icons.arrow_forward, color: Color(0xFF94A3B8), size: 18),
          ),
          Expanded(child: _buildDateChip(_toDate)),
        ],
      ),
    );
  }

  Widget _buildDateChip(DateTime date) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_rounded, size: 15.r, color: AppTheme.colors.primary),
          SizedBox(width: 6.w),
          Text(
            '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}',
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
          ),
        ],
      ),
    );
  }

  // ─── Summary stat cards (Jami kirim / Jami chiqim) ───────────────────────
  Widget _buildStatCards(int income, int expense, String currency) {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Jami kirim', income, currency, const Color(0xFF16A34A), Icons.arrow_upward_rounded)),
        SizedBox(width: 12.w),
        Expanded(child: _buildStatCard('Jami chiqim', expense, currency, const Color(0xFFDC2626), Icons.arrow_downward_rounded)),
      ],
    );
  }

  Widget _buildStatCard(String label, int amount, String currency, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
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
                  _formatAmount(amount),
                  style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.3),
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
    );
  }

  // ─── Section header ───────────────────────────────────────────────────────
  Widget _buildSectionHeader() {
    return Row(
      children: [
        Text(
          "XODIMLAR BO'YICHA",
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF94A3B8),
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(child: Container(height: 1, color: const Color(0xFFE2E8F0))),
      ],
    );
  }

  // ─── Staff card ───────────────────────────────────────────────────────────
  Widget _buildStaffCard(Map<String, dynamic> staff, String currency) {
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
            // Keyinchalik — xodim tafsilotlariga o'tish
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
                      decoration: BoxDecoration(
                        color: (staff['color'] as Color).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          staff['initials'] as String,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: staff['color'] as Color,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            staff['name'] as String,
                            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            staff['role'] as String,
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
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    children: [
                      _buildMetric(
                        label: 'Kirim',
                        value: '+${_formatAmount(staff['income'] as int)} K',
                        color: const Color(0xFF16A34A),
                      ),
                      _buildVerticalDivider(),
                      _buildMetric(
                        label: 'Chiqim',
                        value: '-${_formatAmount(staff['expense'] as int)} K',
                        color: const Color(0xFFDC2626),
                      ),
                      _buildVerticalDivider(),
                      _buildMetric(
                        label: 'Operatsiya',
                        value: '${staff['operations']} ta',
                        color: AppTheme.colors.primary,
                      ),
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
          Text(value, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: color)),
          SizedBox(height: 3.h),
          Text(label, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w500, color: const Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(width: 1, height: 30.h, color: const Color(0xFFE2E8F0));
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ');
  }
}
