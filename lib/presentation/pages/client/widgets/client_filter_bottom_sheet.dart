import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/components/basic_widgets.dart';
import 'package:intl/intl.dart';

class ClientFilterBottomSheet extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final String? initialSort;
  final String? initialStatusFilter;
  final Function(DateTime?, DateTime?, String?, String?) onApply;

  const ClientFilterBottomSheet({super.key, this.initialStartDate, this.initialEndDate, this.initialSort, this.initialStatusFilter, required this.onApply});

  @override
  State<ClientFilterBottomSheet> createState() => _ClientFilterBottomSheetState();
}

class _ClientFilterBottomSheetState extends State<ClientFilterBottomSheet> {
  DateTime? startDate;
  DateTime? endDate;
  String? selectedSort;
  String? selectedStatusFilter;

  final List<Map<String, String>> sortOptions = [
    {'value': 'xaqdor_usd', 'label': 'Haqdor (USD)'},
    {'value': 'xaqdor_uzs', 'label': 'Haqdor (UZS)'},
    {'value': 'qarzdor_usd', 'label': 'Qarzdor (USD)'},
    {'value': 'qarzdor_uzs', 'label': 'Qarzdor (UZS)'},
  ];

  final List<Map<String, String>> statusFilterOptions = [
    {'value': 'xaqdor', 'label': 'Haqdor'},
    {'value': 'qarzdor', 'label': 'Qarzdor'},
    {'value': 'muddati_otgan_qarzdor', 'label': 'Muddati o\'tgan qarzdor'},
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
            colorScheme: ColorScheme.light(primary: AppTheme.colors.primary, onPrimary: Colors.white, surface: Colors.white, onSurface: const Color(0xFF1E293B)),
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

  void _clearDateRange() {
    setState(() {
      startDate = null;
      endDate = null;
    });
  }

  void _clearSort() {
    setState(() {
      selectedSort = null;
    });
  }

  void _clearStatusFilter() {
    setState(() {
      selectedStatusFilter = null;
    });
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
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24.r), topRight: Radius.circular(24.r)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.colors.colorE1EOEE, width: 1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter',
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: AppTheme.colors.black),
                  ),
                  if (hasActiveFilters)
                    TextButton(
                      onPressed: _clearAll,
                      child: Text(
                        'Tozalash',
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: AppTheme.colors.primary),
                      ),
                    )
                  else
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: AppTheme.colors.color3CC293),
                    ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Range Section
                  Text(
                    'Sana oralig\'i',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppTheme.colors.black),
                  ),
                  SizedBox(height: 15.h),
                  GestureDetector(
                    onTap: _selectDateRange,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: startDate != null ? AppTheme.colors.primary : AppTheme.colors.colorE1EOEE),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, size: 20.sp, color: startDate != null ? AppTheme.colors.primary : AppTheme.colors.color3CC293),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              startDate != null && endDate != null ? '${DateFormat('dd.MM.yyyy').format(startDate!)} - ${DateFormat('dd.MM.yyyy').format(endDate!)}' : 'Sana tanlang',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: startDate != null ? AppTheme.colors.black : AppTheme.colors.color3CC293,
                                fontWeight: startDate != null ? FontWeight.w500 : FontWeight.w400,
                              ),
                            ),
                          ),
                          if (startDate != null)
                            GestureDetector(
                              onTap: _clearDateRange,
                              child: Icon(Icons.close, size: 20.sp, color: AppTheme.colors.color3CC293),
                            ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 15.h),
                  // Status Filter Section
                  Text(
                    'Hamkor holati bo\'yicha',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppTheme.colors.black),
                  ),
                  SizedBox(height: 15.h),

                  // Status Filter Dropdown
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: selectedStatusFilter != null ? AppTheme.colors.primary : AppTheme.colors.colorE1EOEE),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        borderRadius: BorderRadius.circular(12.r),
                        isExpanded: true,
                        value: selectedStatusFilter,
                        hint: Text(
                          'Tanlang',
                          style: TextStyle(fontSize: 14.sp, color: const Color(0xFF94A3B8)),
                        ),
                        icon: Icon(Icons.keyboard_arrow_down, color: selectedStatusFilter != null ? AppTheme.colors.primary : const Color(0xFF94A3B8)),
                        style: TextStyle(fontSize: 14.sp, color: AppTheme.colors.black, fontWeight: FontWeight.w500),
                        dropdownColor: Colors.white,
                        items: [
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text(
                              'Tanlanmagan',
                              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF94A3B8)),
                            ),
                          ),
                          ...statusFilterOptions.map((option) {
                            return DropdownMenuItem<String>(value: option['value'], child: Text(option['label']!));
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedStatusFilter = value;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 15.h),
                  // Sort Section
                  Text(
                    'Tartiblash',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppTheme.colors.black),
                  ),
                  SizedBox(height: 15.h),

                  // Sort Dropdown
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: selectedSort != null ? AppTheme.colors.primary : AppTheme.colors.colorE1EOEE),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedSort,
                        hint: Text(
                          'Tanlang',
                          style: TextStyle(fontSize: 14.sp, color: const Color(0xFF94A3B8)),
                        ),
                        icon: Icon(Icons.keyboard_arrow_down, color: selectedSort != null ? AppTheme.colors.primary : const Color(0xFF94A3B8)),
                        style: TextStyle(fontSize: 14.sp, color: AppTheme.colors.black, fontWeight: FontWeight.w500),

                        borderRadius: BorderRadius.circular(12.r),
                        dropdownColor: Colors.white,
                        items: [
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text(
                              'Tanlanmagan',
                              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF94A3B8)),
                            ),
                          ),
                          ...sortOptions.map((option) {
                            return DropdownMenuItem<String>(value: option['value'], child: Text(option['label']!));
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedSort = value;
                          });
                        },
                      ),
                    ),
                  ),




                  SizedBox(height: MediaQuery.of(context).padding.bottom+60),
                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onApply(startDate, endDate, selectedSort, selectedStatusFilter);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.colors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Qo\'llash',
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
