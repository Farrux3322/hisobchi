import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/components/basic_widgets.dart';
import 'package:intl/intl.dart';

class ClientFilterBottomSheet extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final String? initialSort;
  final String? initialStatusFilter;
  final Function(DateTime?, DateTime?, String?, String?) onApply;

  const ClientFilterBottomSheet({
    super.key, 
    this.initialStartDate, 
    this.initialEndDate, 
    this.initialSort, 
    this.initialStatusFilter, 
    required this.onApply
  });

  @override
  State<ClientFilterBottomSheet> createState() => _ClientFilterBottomSheetState();
}

class _ClientFilterBottomSheetState extends State<ClientFilterBottomSheet> {
  DateTime? startDate;
  DateTime? endDate;
  String? selectedSort;
  String? selectedStatusFilter;

  final List<Map<String, dynamic>> sortOptions = [
    {'value': 'xaqdor_usd', 'label': 'Haqdor (USD)', 'icon': Icons.trending_up_rounded},
    {'value': 'xaqdor_uzs', 'label': 'Haqdor (UZS)', 'icon': Icons.trending_up_rounded},
    {'value': 'qarzdor_usd', 'label': 'Qarzdor (USD)', 'icon': Icons.trending_down_rounded},
    {'value': 'qarzdor_uzs', 'label': 'Qarzdor (UZS)', 'icon': Icons.trending_down_rounded},
  ];

  final List<Map<String, dynamic>> statusFilterOptions = [
    {'value': 'xaqdor', 'label': 'Haqdor', 'icon': Icons.account_balance_wallet_outlined},
    {'value': 'qarzdor', 'label': 'Qarzdor', 'icon': Icons.money_off_csred_rounded},
    {'value': 'muddati_otgan_qarzdor', 'label': 'Muddati o\'tgan', 'icon': Icons.event_busy_rounded},
  ];

  @override
  void initState() {
    super.initState();
    startDate = widget.initialStartDate;
    endDate = widget.initialEndDate;
    selectedSort = widget.initialSort;
    selectedStatusFilter = widget.initialStatusFilter;
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: startDate != null && endDate != null ? DateTimeRange(start: startDate!, end: endDate!) : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.colors.primary, 
              onPrimary: Colors.white, 
              surface: Colors.white, 
              onSurface: const Color(0xFF1E293B)
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
    }
  }

  void _clearAll() {
    setState(() {
      startDate = null;
      endDate = null;
      selectedSort = null;
      selectedStatusFilter = null;
    });
  }

  bool get hasActiveFilters => startDate != null || endDate != null || selectedSort != null || selectedStatusFilter != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(32.r), topRight: Radius.circular(32.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle Bar
          const Gap(12),
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2.5)),
          ),
          
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtrlar',
                  style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                ),
                if (hasActiveFilters)
                  TextButton(
                    onPressed: _clearAll,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Tozalash',
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                    ),
                  )
                else
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Range Selector
                  _buildSectionTitle('Sana oralig\'i'),
                  const Gap(12),
                  _buildDateSelector(),
                  
                  const Gap(28),
                  
                  // Status Selector
                  _buildSectionTitle('Holat bo\'yicha'),
                  const Gap(12),
                  _buildOptionGrid(
                    options: statusFilterOptions, 
                    selectedValue: selectedStatusFilter,
                    onSelected: (val) => setState(() => selectedStatusFilter = (selectedStatusFilter == val ? null : val)),
                  ),

                  const Gap(28),

                  // Sort Selector
                  _buildSectionTitle('Tartiblash'),
                  const Gap(12),
                  _buildOptionGrid(
                    options: sortOptions, 
                    selectedValue: selectedSort,
                    onSelected: (val) => setState(() => selectedSort = (selectedSort == val ? null : val)),
                  ),

                  const Gap(32),

                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onApply(startDate, endDate, selectedSort, selectedStatusFilter);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.colors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Filtrlarni qo\'llash',
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                    ),
                  ),
                  Gap(MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF64748B),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildDateSelector() {
    final hasDate = startDate != null && endDate != null;
    return GestureDetector(
      onTap: _selectDateRange,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: hasDate ? AppTheme.colors.primary.withOpacity(0.05) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: hasDate ? AppTheme.colors.primary.withOpacity(0.3) : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: hasDate ? AppTheme.colors.primary.withOpacity(0.1) : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.calendar_month_rounded, 
                size: 20, 
                color: hasDate ? AppTheme.colors.primary : const Color(0xFF94A3B8)
              ),
            ),
            const Gap(16),
            Expanded(
              child: Text(
                hasDate 
                    ? '${DateFormat('dd.MM.yyyy').format(startDate!)} - ${DateFormat('dd.MM.yyyy').format(endDate!)}' 
                    : 'Barcha vaqt',
                style: TextStyle(
                  fontSize: 15.sp,
                  color: hasDate ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
                  fontWeight: hasDate ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: hasDate ? AppTheme.colors.primary : const Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionGrid({
    required List<Map<String, dynamic>> options,
    required String? selectedValue,
    required Function(String) onSelected,
  }) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: options.map((option) {
        final isSelected = selectedValue == option['value'];
        return GestureDetector(
          onTap: () => onSelected(option['value']),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.colors.primary : Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isSelected ? AppTheme.colors.primary : const Color(0xFFE2E8F0),
                width: 1.5,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: AppTheme.colors.primary.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ] : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  option['icon'], 
                  size: 18, 
                  color: isSelected ? Colors.white : const Color(0xFF64748B)
                ),
                const Gap(8),
                Text(
                  option['label'],
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
