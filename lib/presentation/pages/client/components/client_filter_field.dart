import 'package:flutter/material.dart';
import 'package:hisobchi/presentation/assets/theme/app_theme.dart';
import 'package:intl/intl.dart';

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
  final String? selectedStatusFilter;

  // Callbacks for removing filters
  final VoidCallback onRemoveDate;
  final VoidCallback onRemoveSort;
  final VoidCallback onRemoveStatusFilter;

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
    this.selectedStatusFilter,
    required this.onRemoveDate,
    required this.onRemoveSort,
    required this.onRemoveStatusFilter,
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

  String _getStatusLabel(String value) {
    switch (value) {
      case 'xaqdor':
        return 'Haqdor';
      case 'qarzdor':
        return 'Qarzdor';
      case 'muddati_otgan_qarzdor':
        return 'Muddati o\'tgan qarzdor';
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
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: searchController.text.isNotEmpty ? AppTheme.colors.primary : const Color(0xFFE0E0E0),
              width: searchController.text.isNotEmpty ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, size: 22, color: Color(0xFF64748B)),
              const SizedBox(width: 10),
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
                  style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w500),
                ),
              ),
              if (searchController.text.isNotEmpty)
                IconButton(
                  onPressed: onClearSearch,
                  icon: const Icon(Icons.close_rounded, size: 20),
                  color: const Color(0xFF64748B),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              const SizedBox(width: 8),
              Container(width: 1, height: 24, color: const Color(0xFFE2E8F0)),
              const SizedBox(width: 8),
              InkWell(
                onTap: onFilterTap,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: hasActiveFilters ? AppTheme.colors.primary.withValues(alpha: 0.1) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        Icons.filter_list_rounded,
                        size: 20,
                        color: hasActiveFilters ? AppTheme.colors.primary : const Color(0xFF64748B),
                      ),
                      if (hasActiveFilters)
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Active Filters Chips
        if (hasActiveFilters) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                if (startDate != null && endDate != null)
                  _buildFilterChip(
                    label: '${DateFormat('dd.MM').format(startDate!)} - ${DateFormat('dd.MM').format(endDate!)}',
                    icon: Icons.calendar_today_rounded,
                    color: AppTheme.colors.primary,
                    onRemove: onRemoveDate,
                  ),
                if (selectedStatusFilter != null)
                  _buildFilterChip(
                    label: _getStatusLabel(selectedStatusFilter!),
                    icon: Icons.person_outline_rounded,
                    color: const Color(0xFF10B981),
                    onRemove: onRemoveStatusFilter,
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
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, size: 14, color: color),
          if (icon != null) const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: onRemove,
            child: Icon(Icons.close_rounded, size: 16, color: color),
          ),
        ],
      ),
    );
  }
}
