import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/currency/currency_bloc.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';

class FilterBottomSheet extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final String? initialType;
  final bool? initialIsCancelled;
  final int? initialCurrencyId;

  const FilterBottomSheet({super.key, this.initialStartDate, this.initialEndDate, this.initialType, this.initialIsCancelled, this.initialCurrencyId});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  DateTime? startDate;
  DateTime? endDate;
  String? selectedType;
  bool? isCancelled;
  int? selectedCurrencyId;

  @override
  void initState() {
    super.initState();
    startDate = widget.initialStartDate;
    endDate = widget.initialEndDate;
    selectedType = widget.initialType;
    isCancelled = widget.initialIsCancelled;
    selectedCurrencyId = widget.initialCurrencyId;
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: startDate != null && endDate != null ? DateTimeRange(start: startDate!, end: endDate!) : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppTheme.colors.primary, onPrimary: Colors.white, surface: Colors.white, onSurface: Colors.black),
            textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: AppTheme.colors.primary)),
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

  Future<void> _showCurrencyPicker() async {
    final currencyState = context.read<CurrencyBloc>().state;
    final currencies = currencyState.currencyModel?.result ?? [];

    if (currencies.isEmpty) return;

    final int? selected = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _CurrencySelectionSheet(currencies: currencies, selectedId: selectedCurrencyId),
    );

    if (selected != null && mounted) {
      setState(() {
        selectedCurrencyId = selected == -1 ? null : selected;
      });
    }
  }

  // void _clearCurrency() {
  //   setState(() {
  //     selectedCurrencyId = null;
  //   });
  // }

  void _applyFilters() {
    Navigator.pop(context, {'startDate': startDate, 'endDate': endDate, 'type': selectedType, 'is_cancelled': isCancelled ?? false, 'currency_id': selectedCurrencyId});
  }

  void _resetFilters() {
    setState(() {
      startDate = null;
      endDate = null;
      selectedType = null;
      isCancelled = null;
      selectedCurrencyId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters = startDate != null || endDate != null || selectedType != null || isCancelled != null || selectedCurrencyId != null;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppTheme.colors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.filter_list_rounded, color: AppTheme.colors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Filterlar',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                  ),
                ),
                if (hasActiveFilters)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, size: 12, color: Color(0xFF10B981)),
                        SizedBox(width: 4),
                        Text(
                          'Faol',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF10B981)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Currency and Date Row
                  _buildSectionTitle('Valyuta va sana', Icons.monetization_on_outlined),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(flex: 2, child: _buildCompactDateRange()),
                      const SizedBox(width: 8),
                      Expanded(child: _buildCompactCurrencyFilter()),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Type Section - Compact
                  _buildSectionTitle('Tranzaksiya turi', Icons.swap_horiz_rounded),
                  const SizedBox(height: 8),
                  _buildCompactTypeSelector(),
                  const SizedBox(height: 16),

                  // Cancelled Status - Compact
                  _buildSectionTitle('Holati', Icons.cancel_outlined),
                  const SizedBox(height: 8),
                  _buildCompactCancelledToggle(),
                ],
              ),
            ),
          ),

          // Bottom Actions
          Container(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
            ),
            child: Row(
              children: [
                if (hasActiveFilters)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _resetFilters,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFEF4444),
                        side: const BorderSide(color: Color(0xFFEF4444)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Tozalash', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  ),
                if (hasActiveFilters) const SizedBox(width: 10),
                Expanded(
                  flex: hasActiveFilters ? 2 : 1,
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.colors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Qo\'llash', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF64748B)),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
        ),
      ],
    );
  }

  // Compact Currency Filter
  Widget _buildCompactCurrencyFilter() {
    final currencyState = context.watch<CurrencyBloc>().state;
    final currencies = currencyState.currencyModel?.result ?? [];
    final selectedCurrency = currencies.where((c) => c.id == selectedCurrencyId).firstOrNull;
    final hasCurrency = selectedCurrencyId != null;

    return InkWell(
      onTap: _showCurrencyPicker,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: hasCurrency ? const Color(0xFFFBBF24).withValues(alpha: 0.1) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: hasCurrency ? const Color(0xFFFBBF24).withValues(alpha: 0.4) : const Color(0xFFE2E8F0), width: 1.5),
        ),
        child: Column(
          children: [
            if (hasCurrency && selectedCurrency != null) ...[
              Text(
                selectedCurrency.name ?? '',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFFBBF24)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ] else
              const Text(
                'Barchasi',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
              ),
          ],
        ),
      ),
    );
  }

  // Compact Date Range
  Widget _buildCompactDateRange() {
    final bool hasDateRange = startDate != null && endDate != null;

    return InkWell(
      onTap: _selectDateRange,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: hasDateRange ? AppTheme.colors.primary.withValues(alpha: 0.05) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: hasDateRange ? AppTheme.colors.primary.withValues(alpha: 0.3) : const Color(0xFFE2E8F0), width: 1.5),
        ),
        child: Row(
          children: [
            Icon(Icons.date_range_rounded, color: hasDateRange ? AppTheme.colors.primary : const Color(0xFF94A3B8), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                hasDateRange ? '${DateFormat('dd.MM.yyyy').format(startDate!)} - ${DateFormat('dd.MM.yyyy').format(endDate!)}' : 'Sana oralig\'i',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: hasDateRange ? AppTheme.colors.primary : const Color(0xFF64748B)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasDateRange)
              IconButton(onPressed: _clearDateRange, icon: const Icon(Icons.close_rounded, size: 16), color: const Color(0xFF64748B), padding: EdgeInsets.zero, constraints: const BoxConstraints())
            else
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 16),
          ],
        ),
      ),
    );
  }

  // Compact Type Selector
  Widget _buildCompactTypeSelector() {
    return Row(
      children: [
        _buildCompactTypeChip(null, 'Barchasi', Icons.all_inclusive_rounded),
        const SizedBox(width: 8),
        _buildCompactTypeChip('debt', 'Kirim', Icons.arrow_downward_rounded),
        const SizedBox(width: 8),
        _buildCompactTypeChip('credit', 'Chiqim', Icons.arrow_upward_rounded),
      ],
    );
  }

  Widget _buildCompactTypeChip(String? value, String label, IconData icon) {
    final bool isSelected = selectedType == value;
    final Color color = value == null
        ? AppTheme.colors.primary
        : value == 'debt'
        ? const Color(0xFF10B981)
        : const Color(0xFFEF4444);

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => selectedType = value),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.1) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? color : const Color(0xFFE2E8F0), width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: isSelected ? color : const Color(0xFF94A3B8)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? color : const Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Compact Cancelled Toggle
  Widget _buildCompactCancelledToggle() {
    final bool isSelected = isCancelled ?? false;

    return InkWell(
      onTap: () => setState(() => isCancelled = !(isCancelled ?? false)),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEF4444).withValues(alpha: 0.08) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? const Color(0xFFEF4444).withValues(alpha: 0.4) : const Color(0xFFE2E8F0), width: 1.5),
        ),
        child: Row(
          children: [
            Icon(Icons.cancel_outlined, color: isSelected ? const Color(0xFFEF4444) : const Color(0xFF94A3B8), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Bekor qilingan tranzaksiyalar',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? const Color(0xFFEF4444) : const Color(0xFF0F172A)),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFEF4444) : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? const Color(0xFFEF4444) : const Color(0xFFCBD5E1), width: 2),
              ),
              child: isSelected ? const Icon(Icons.check_rounded, color: Colors.white, size: 12) : null,
            ),
          ],
        ),
      ),
    );
  }
}

// Currency Selection Bottom Sheet
class _CurrencySelectionSheet extends StatelessWidget {
  final List currencies;
  final int? selectedId;

  const _CurrencySelectionSheet({required this.currencies, this.selectedId});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFFFBBF24).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.attach_money_rounded, color: Color(0xFFFBBF24), size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Valyutani tanlang',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Currency List
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.all(16),
              itemCount: currencies.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                // First item - "Clear selection"
                if (index == 0) {
                  final isSelected = selectedId == null;
                  return InkWell(
                    onTap: () => Navigator.pop(context, -1), // -1 means clear
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.colors.primary.withValues(alpha: 0.1) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isSelected ? AppTheme.colors.primary : const Color(0xFFE2E8F0), width: isSelected ? 2 : 1.5),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.clear_all_rounded, color: isSelected ? AppTheme.colors.primary : const Color(0xFF94A3B8), size: 24),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Barchasi',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                            ),
                          ),
                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(color: AppTheme.colors.primary, shape: BoxShape.circle),
                              child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                            ),
                        ],
                      ),
                    ),
                  );
                }

                final currency = currencies[index - 1];
                final isSelected = currency.id == selectedId;

                return InkWell(
                  onTap: () => Navigator.pop(context, currency.id),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFBBF24).withValues(alpha: 0.1) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? const Color(0xFFFBBF24) : const Color(0xFFE2E8F0), width: isSelected ? 2 : 1.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(color: isSelected ? const Color(0xFFFBBF24).withValues(alpha: 0.2) : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
                          child: Center(
                            child: Text(
                              currency.name?.substring(0, 1).toUpperCase() ?? '',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isSelected ? const Color(0xFFFBBF24) : const Color(0xFF64748B)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            currency.name ?? '',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isSelected ? const Color(0xFFFBBF24) : const Color(0xFF0F172A)),
                          ),
                        ),
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Color(0xFFFBBF24), shape: BoxShape.circle),
                            child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}
