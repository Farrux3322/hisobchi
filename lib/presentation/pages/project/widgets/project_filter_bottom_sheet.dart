import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/project/project_bloc.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';

class ProjectFilterBottomSheet extends StatefulWidget {
  const ProjectFilterBottomSheet({super.key});

  @override
  State<ProjectFilterBottomSheet> createState() => _ProjectFilterBottomSheetState();
}

class _ProjectFilterBottomSheetState extends State<ProjectFilterBottomSheet> {
  String? _selectedStatus;
  DateTimeRange? _selectedDateRange;

  final List<Map<String, String>> _statuses = [
    {'key': 'in_progress', 'label': 'Jarayonda'},
    {'key': 'completed', 'label': 'Yakunlangan'},
    {'key': 'frozen', 'label': 'Muzlatilgan'},
  ];

  @override
  void initState() {
    super.initState();
    final state = context.read<ProjectBloc>().state;
    _selectedStatus = state.statusFilter;
    if (state.date != null && state.date!.length == 2) {
      try {
        final start = DateFormat('dd.MM.yyyy').parse(state.date![0]);
        final end = DateFormat('dd.MM.yyyy').parse(state.date![1]);
        _selectedDateRange = DateTimeRange(start: start, end: end);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Gap(24),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filtrlash',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
              ),
              TextButton(
                onPressed: _clearFilters,
                child: Text(
                  'Tozalash',
                  style: TextStyle(color: AppTheme.colors.primary, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const Gap(24),

          // Date Range Section
          _buildSectionTitle('Sana bo\'yicha'),
          const Gap(12),
          InkWell(
            onTap: _selectDateRange,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                   Icon(Icons.calendar_today_rounded, size: 20, color: AppTheme.colors.primary),
                  const Gap(12),
                  Text(
                    _selectedDateRange == null
                        ? 'Sana oralig\'ini tanlang'
                        : '${DateFormat('dd.MM.yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd.MM.yyyy').format(_selectedDateRange!.end)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: _selectedDateRange == null ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
                      fontWeight: _selectedDateRange == null ? FontWeight.w500 : FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF94A3B8)),
                ],
              ),
            ),
          ),
          const Gap(12),

          // Status Section
          _buildSectionTitle('Status bo\'yicha'),
          const Gap(12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _statuses.map((status) {
              final isSelected = _selectedStatus == status['key'];
              return InkWell(
                onTap: () => setState(() => _selectedStatus = isSelected ? null : status['key']),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.colors.primary : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppTheme.colors.primary : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    status['label']!,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const Gap(32),

          // Apply Button
          ElevatedButton(
            onPressed: _applyFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.colors.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: AppTheme.colors.primary.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              minimumSize: const Size(double.infinity, 54),
            ),
            child: const Text(
              'Filtrlarni qo\'llash',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
    );
  }

  Future<void> _selectDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.colors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: const Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );

    if (range != null) {
      setState(() => _selectedDateRange = range);
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedDateRange = null;
    });
  }

  void _applyFilters() {
    List<String>? dateStrings;
    if (_selectedDateRange != null) {
      dateStrings = [
        DateFormat('dd.MM.yyyy').format(_selectedDateRange!.start),
        DateFormat('dd.MM.yyyy').format(_selectedDateRange!.end),
      ];
    }

    context.read<ProjectBloc>().add(GetAllProjectEvent(
          status: _selectedStatus,
          date: dateStrings,
          updateFilters: true,
        ));

    Navigator.pop(context);
  }
}
