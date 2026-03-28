import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';

class ClientFilterBottomSheet extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final String? initialSort;
  final Function(DateTime?, DateTime?, String?) onApply;

  const ClientFilterBottomSheet({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
    this.initialSort,
    required this.onApply,
  });

  @override
  State<ClientFilterBottomSheet> createState() => _ClientFilterBottomSheetState();
}

class _ClientFilterBottomSheetState extends State<ClientFilterBottomSheet> {
  DateTime? startDate;
  DateTime? endDate;
  String? selectedSort;

  final List<Map<String, dynamic>> sortOptions = [
    {'value': 'xaqdor_usd', 'label': 'Haqdor (USD)', 'icon': Icons.trending_up_rounded},
    {'value': 'xaqdor_uzs', 'label': 'Haqdor (UZS)', 'icon': Icons.trending_up_rounded},
    {'value': 'qarzdor_usd', 'label': 'Qarzdor (USD)', 'icon': Icons.trending_down_rounded},
    {'value': 'qarzdor_uzs', 'label': 'Qarzdor (UZS)', 'icon': Icons.trending_down_rounded},
  ];

  @override
  void initState() {
    super.initState();
    startDate = widget.initialStartDate;
    endDate = widget.initialEndDate;
    selectedSort = widget.initialSort;
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
              onSurface: const Color(0xFF0F172A),
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
    });
  }

  bool get hasActiveFilters => startDate != null || endDate != null || selectedSort != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28.r),
          topRight: Radius.circular(28.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Gap(8),
          Container(
            width: 32.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtrlar',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                if (hasActiveFilters)
                  TextButton(
                    onPressed: _clearAll,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Tozalash',
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Sana oralig\'i'),
                  const Gap(8),
                  _buildDateSelector(),
                  const Gap(24),
                  _buildSectionTitle('Tartiblash'),
                  const Gap(8),
                  _buildSortSlidingSegments(),
                  const Gap(32),
                  _buildApplyButton(),
                  Gap(MediaQuery.of(context).padding.bottom + 8.h),
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
        fontSize: 12.sp,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF94A3B8),
        letterSpacing: 0.1,
      ),
    );
  }

  Widget _buildDateSelector() {
    final hasDate = startDate != null && endDate != null;
    return Bounce(
      duration: const Duration(milliseconds: 110),
      onPressed: _selectDateRange,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: hasDate ? AppTheme.colors.primary.withValues(alpha: 0.2) : const Color(0xFFF1F5F9),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 18.sp,
              color: hasDate ? AppTheme.colors.primary : const Color(0xFF94A3B8),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                hasDate
                    ? '${DateFormat('dd.MM.yyyy').format(startDate!)} - ${DateFormat('dd.MM.yyyy').format(endDate!)}'
                    : 'Barcha vaqt',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: hasDate ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                  fontWeight: hasDate ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded, size: 18.sp, color: const Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  Widget _buildSortSlidingSegments() {
    final int selectedIndex = sortOptions.indexWhere((opt) => opt['value'] == selectedSort);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double tileWidth = (width - 6) / 2;
        final double tileHeight = 44.h;

        return Container(
          height: (tileHeight * 2) + 8,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: AppTheme.colors.background,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Stack(
            children: [
              // Sliding Indicator
              if (selectedIndex != -1)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOutCubic,
                  left: (selectedIndex % 2) * tileWidth,
                  top: (selectedIndex ~/ 2) * tileHeight,
                  width: tileWidth,
                  height: tileHeight,
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),

              // Interaction Layer (Buttons)
              Column(
                children: [
                  for (int row = 0; row < 2; row++)
                    Row(
                      children: [
                        for (int col = 0; col < 2; col++)
                          _buildSlidingTile(
                            index: row * 2 + col,
                            width: tileWidth,
                            height: tileHeight,
                          ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSlidingTile({required int index, required double width, required double height}) {
    final option = sortOptions[index];
    final isSelected = selectedSort == option['value'];
    final isHaqdor = option['value'].toString().contains('xaqdor');

    return GestureDetector(
      onTap: () => setState(() => selectedSort = (isSelected ? null : option['value'])),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              option['icon'],
              size: 15.sp,
              color: isSelected 
                  ? (isHaqdor ? Colors.green : Colors.orange) 
                  : const Color(0xFF94A3B8),
            ),
            SizedBox(width: 8.w),
            Flexible(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                ),
                child: Text(option['label'], maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplyButton() {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: Bounce(
        duration: const Duration(milliseconds: 110),
        onPressed: () {
          widget.onApply(startDate, endDate, selectedSort);
          Navigator.pop(context);
        },
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.colors.primary,
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(
                color: AppTheme.colors.primary.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            'Filtrlarni qo\'llash',
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
