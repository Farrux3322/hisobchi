import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/currency/currency_bloc.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

class HistoryFilterField extends StatelessWidget {
  final TextEditingController searchController;
  final bool hasActiveFilters;
  final VoidCallback onFilterTap;
  final VoidCallback onSearchChanged;
  final VoidCallback onClearSearch;
  
  // Filters for chips
  final String? selectedType;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? currencyId;
  final bool? isCancelled;
  
  // Callbacks for removing filters
  final VoidCallback onRemoveType;
  final VoidCallback onRemoveDate;
  final VoidCallback onRemoveCurrency;
  final VoidCallback onRemoveCancelled;

  const HistoryFilterField({
    super.key,
    required this.searchController,
    required this.hasActiveFilters,
    required this.onFilterTap,
    required this.onSearchChanged,
    required this.onClearSearch,
    this.selectedType,
    this.startDate,
    this.endDate,
    this.currencyId,
    this.isCancelled,
    required this.onRemoveType,
    required this.onRemoveDate,
    required this.onRemoveCurrency,
    required this.onRemoveCancelled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Field
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: searchController.text.isNotEmpty ? const Color(0xFF4F46E5) : const Color(0xFFE0E0E0),
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
                    hintText: "Qidirish...",
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
                    color: hasActiveFilters ? const Color(0xFF4F46E5).withValues(alpha: 0.1) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        Icons.filter_list_rounded,
                        size: 20,
                        color: hasActiveFilters ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
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
          Container(
            height: 36,
            margin: const EdgeInsets.only(right: 10),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                if (selectedType != null)
                  _buildFilterChip(
                    label: selectedType == 'debt' ? 'Kirim' : 'Chiqim',
                    icon: selectedType == 'debt' ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                    color: selectedType == 'debt' ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    onRemove: onRemoveType,
                  ),
                if (startDate != null && endDate != null)
                  _buildFilterChip(
                    label: '${DateFormat('dd.MM').format(startDate!)} - ${DateFormat('dd.MM').format(endDate!)}',
                    icon: Icons.calendar_today_rounded,
                    color: const Color(0xFF4F46E5),
                    onRemove: onRemoveDate,
                  ),
                if (currencyId != null)
                  Builder(
                    builder: (context) {
                      final currencyState = context.watch<CurrencyBloc>().state;
                      final currencies = currencyState.currencyModel?.result ?? [];
                      final currency = currencies.firstWhereOrNull((c) => c.id == currencyId);
                      return _buildFilterChip(
                        label: currency?.name ?? 'Valyuta',
                        color: const Color(0xFFFBBF24),
                        onRemove: onRemoveCurrency,
                      );
                    },
                  ),
                if (isCancelled == true)
                  _buildFilterChip(
                    label: 'Bekor qilingan',
                    icon: Icons.cancel_outlined,
                    color: const Color(0xFFE11D48),
                    onRemove: onRemoveCancelled,
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
