import 'package:flutter/material.dart';
import 'package:hisobchi/presentation/assets/theme/app_theme.dart';

import '../../../assets/asset_index.dart' show DateFormat, SizeExtension;

class ClientFilterField extends StatelessWidget {
  final TextEditingController searchController;
  final bool hasActiveFilters;
  final VoidCallback onFilterTap;
  final VoidCallback onSearchChanged;
  final VoidCallback onClearSearch;

  // Filters for chips
  final DateTime? startDate;
  final DateTime? endDate;
  final String? selectedSort;

  // Callbacks for removing filters
  final VoidCallback onRemoveDate;
  final VoidCallback onRemoveSort;

  const ClientFilterField({
    super.key,
    required this.searchController,
    required this.hasActiveFilters,
    required this.onFilterTap,
    required this.onSearchChanged,
    required this.onClearSearch,
    this.startDate,
    this.endDate,
    this.selectedSort,
    required this.onRemoveDate,
    required this.onRemoveSort,
  });

  String _getSortLabel(String value) {
    switch (value) {
      case 'xaqdor_usd':
        return 'Haqdor (USD)';
      case 'xaqdor_uzs':
        return 'Haqdor (UZS)';
      case 'qarzdor_usd':
        return 'Qarzdor (USD)';
      case 'qarzdor_uzs':
        return 'Qarzdor (UZS)';
      default:
        return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Field & Filter Button
        Container(
          height: 54.h,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.1),
                blurRadius: 15,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, size: 22, color: Color(0xFF94A3B8)),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: searchController,
                  onChanged: (value) => onSearchChanged(),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    hintText: "Mijozni qidirish...",
                    hintStyle: TextStyle(fontSize: 15, color: Color(0xFF94A3B8), fontWeight: FontWeight.w400),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(
                    fontSize: 15, 
                    color: Color(0xFF1E293B), 
                    fontWeight: FontWeight.w600
                  ),
                ),
              ),
              if (searchController.text.isNotEmpty)
                IconButton(
                  onPressed: onClearSearch,
                  icon: const Icon(Icons.cancel_rounded, size: 20),
                  color: const Color(0xFFCBD5E1),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              const SizedBox(width: 10),
              Container(width: 1.5, height: 24, color: const Color(0xFFF1F5F9)),
              const SizedBox(width: 10),
              InkWell(
                onTap: onFilterTap,
                borderRadius: BorderRadius.circular(12.r),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: hasActiveFilters ? AppTheme.colors.primary.withValues(alpha: 0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.filter_list_rounded,
                        size: 22.sp,
                        color: hasActiveFilters ? AppTheme.colors.primary : const Color(0xFF64748B),
                      ),
                    ),
                    if (hasActiveFilters)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppTheme.colors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Active Filters Chips
        if (hasActiveFilters) ...[
          SizedBox(height: 12.h),
          SizedBox(
            height: 32.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              children: [
                if (startDate != null && endDate != null)
                  _buildFilterChip(
                    label: '${DateFormat('dd.MM').format(startDate!)} - ${DateFormat('dd.MM').format(endDate!)}',
                    icon: Icons.calendar_today_rounded,
                    color: AppTheme.colors.primary,
                    onRemove: onRemoveDate,
                  ),
                if (selectedSort != null)
                  _buildFilterChip(
                    label: _getSortLabel(selectedSort!),
                    icon: Icons.sort_rounded,
                    color: const Color(0xFFFBBF24),
                    onRemove: onRemoveSort,
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFilterChip({required String label, IconData? icon, required Color color, required VoidCallback onRemove}) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, size: 14.sp, color: color),
          if (icon != null) const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp, 
              fontWeight: FontWeight.w700, 
              color: color,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close_rounded, size: 12.sp, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
