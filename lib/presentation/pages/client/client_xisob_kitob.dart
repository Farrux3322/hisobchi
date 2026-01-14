import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hisobchi/application/currency/currency_bloc.dart';
import 'package:hisobchi/application/file_upload/file_upload_bloc.dart';
import 'package:hisobchi/application/partner/partner_bloc.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/dto/models/partner/income_history_model.dart';
import 'package:hisobchi/infrastructure/repository/file_upload/file_upload_repository.dart';
import 'package:hisobchi/presentation/components/loading/loading.dart';
import 'package:collection/collection.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:hisobchi/presentation/components/utils/price_extension.dart';
import 'package:hisobchi/presentation/pages/client/widgets/edit_kirim_bottom_sheet.dart';
import 'package:hisobchi/presentation/pages/client/widgets/filter_bottom_sheet.dart';
import 'package:shimmer/shimmer.dart';

import '../../assets/asset_index.dart';

class HisobKitobTarixPage extends StatefulWidget {
  const HisobKitobTarixPage({super.key, this.id, this.initialType, this.initialCurrencyId});

  final int? id;
  final String? initialType;
  final int? initialCurrencyId;

  @override
  State<HisobKitobTarixPage> createState() => _HisobKitobTarixPageState();
}

class _HisobKitobTarixPageState extends State<HisobKitobTarixPage> {
  final TextEditingController _searchController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedType;
  bool? _isCancelled;
  int? _currencyId;
  bool _hasActiveFilters = false;

  @override
  void initState() {
    _selectedType = widget.initialType;
    _currencyId = widget.initialCurrencyId;
    _updateActiveFilters();
    _loadData();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    context.read<PartnerBloc>().add(
      IncomeHistoryEvent(
        id: widget.id ?? 0,
        search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        type: _selectedType,
        isCancelled: _isCancelled ?? false,
        // Default false
        currencyId: _currencyId,
      ),
    );
  }

  void _updateActiveFilters() {
    setState(() {
      _hasActiveFilters = _startDate != null || _endDate != null || _selectedType != null || (_isCancelled != null && _isCancelled == true) || _currencyId != null;
    });
  }

  Future<void> _showFilterBottomSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(initialStartDate: _startDate, initialEndDate: _endDate, initialType: _selectedType, initialIsCancelled: _isCancelled, initialCurrencyId: _currencyId),
    );

    if (result != null && mounted) {
      setState(() {
        _startDate = result['startDate'];
        _endDate = result['endDate'];
        _selectedType = result['type'];
        _isCancelled = result['is_cancelled'];
        _currencyId = result['currency_id'];
      });
      _updateActiveFilters();
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        leading: InkWell(
          onTap: () => Navigator.of(context).maybePop(),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.all(8),

            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(color: Color.fromRGBO(255, 255, 255, 0.1), blurRadius: 1, spreadRadius: 0, offset: Offset(0, 1)),
                BoxShadow(color: Color.fromRGBO(50, 50, 93, 0.25), blurRadius: 100, spreadRadius: -20, offset: Offset(0, 50)),
                BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.3), blurRadius: 60, spreadRadius: -30, offset: Offset(0, 30)),
              ],
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black),
          ),
        ),
        title: const Text(
          "Hisob-kitob tarixlari",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 6, 16).copyWith(bottom: MediaQuery.of(context).padding.bottom),
        child: BlocConsumer<PartnerBloc, PartnerState>(
          listener: (context, state) {
            // // Success - listni yangilash
            if (state.statusKirimAdd == Status.success) {
              context.read<PartnerBloc>().add(IncomeHistoryEvent(id: widget.id ?? 0));
              context.read<PartnerBloc>().add(IncomeStatementEvent(id: widget.id ?? 0));
            }
          },
          builder: (context, state) {
            if (state.statusIncomeHistory == Status.loading) {
              return Column(
                children: [
                  _buildFilterField(),
                  const SizedBox(height: 10),
                  Expanded(child: _buildShimmerLoading()),
                ],
              );
            }

            final data = state.incomeHistoryModel?.result ?? [];

            // Sanalar bo'yicha guruhlash (DateTime bo'yicha aniq)
            final groupedData = data.isNotEmpty
                ? groupBy<Result, DateTime>(data, (item) {
                    final parsed = _tryParseDate(item.createdAt ?? '');
                    if (parsed == null) {
                      return DateTime(1970);
                    }
                    return _toDateOnly(parsed);
                  })
                : <DateTime, List<Result>>{};

            return Stack(
              children: [
                Column(
                  children: [
                    _buildFilterField(),
                    Expanded(
                      child: data.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), shape: BoxShape.circle),
                                    child: const Icon(Icons.search_off_rounded, size: 64, color: Color(0xFF94A3B8)),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    "Ma'lumot topilmadi",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text("Filter yoki qidiruv shartlarini o'zgartiring", style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8))),
                                ],
                              ),
                            )
                          : CustomScrollView(
                              slivers: groupedData.entries.map((entry) {
                                final dateKey = entry.key;
                                final items = entry.value;

                                return SliverStickyHeader(
                                  header: Container(
                                    height: 40,
                                    color: AppTheme.colors.background,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      DateFormat('dd.MM.yyyy').format(dateKey),
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF212529)),
                                    ),
                                  ),
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate((context, index) {
                                      final item = items[index];
                                      return Padding(padding: const EdgeInsets.only(bottom: 10), child: _buildTransactionCard(item));
                                    }, childCount: items.length),
                                  ),
                                );
                              }).toList(),
                            ),
                    ),
                  ],
                ),
                if (state.statusKirimAdd == Status.loading) Loading(),
              ],
            );
          },
        ),
      ),
    );
  }

  // 🔹 Search & Filter Section
  Widget _buildFilterField() {
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
            border: Border.all(color: _searchController.text.isNotEmpty ? const Color(0xFF4F46E5) : const Color(0xFFE0E0E0), width: _searchController.text.isNotEmpty ? 2 : 1),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, size: 22, color: Color(0xFF64748B)),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {});
                    if (value.isEmpty || value.length >= 2) {
                      _loadData();
                    }
                  },
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
              if (_searchController.text.isNotEmpty)
                IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                    _loadData();
                  },
                  icon: const Icon(Icons.close_rounded, size: 20),
                  color: const Color(0xFF64748B),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              const SizedBox(width: 8),
              Container(width: 1, height: 24, color: const Color(0xFFE2E8F0)),
              const SizedBox(width: 8),
              InkWell(
                onTap: _showFilterBottomSheet,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: _hasActiveFilters ? const Color(0xFF4F46E5).withValues(alpha: 0.1) : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(Icons.filter_list_rounded, size: 20, color: _hasActiveFilters ? const Color(0xFF4F46E5) : const Color(0xFF64748B)),
                      if (_hasActiveFilters)
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
        if (_hasActiveFilters) ...[
          const SizedBox(height: 10),
          Container(
            height: 36,
            margin: const EdgeInsets.only(right: 10),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                if (_selectedType != null)
                  _buildFilterChip(
                    label: _selectedType == 'debt' ? 'Kirim' : 'Chiqim',
                    icon: _selectedType == 'debt' ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                    color: _selectedType == 'debt' ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    onRemove: () {
                      setState(() => _selectedType = null);
                      _updateActiveFilters();
                      _loadData();
                    },
                  ),
                if (_startDate != null && _endDate != null)
                  _buildFilterChip(
                    label: '${DateFormat('dd.MM').format(_startDate!)} - ${DateFormat('dd.MM').format(_endDate!)}',
                    icon: Icons.calendar_today_rounded,
                    color: const Color(0xFF4F46E5),
                    onRemove: () {
                      setState(() {
                        _startDate = null;
                        _endDate = null;
                      });
                      _updateActiveFilters();
                      _loadData();
                    },
                  ),
                if (_currencyId != null)
                  Builder(
                    builder: (context) {
                      final currencyState = context.watch<CurrencyBloc>().state;
                      final currencies = currencyState.currencyModel?.result ?? [];
                      final currency = currencies.firstWhereOrNull((c) => c.id == _currencyId);
                      return _buildFilterChip(
                        label: currency?.name ?? 'Valyuta',
                        icon: Icons.monetization_on_outlined,
                        color: const Color(0xFFFBBF24),
                        onRemove: () {
                          setState(() => _currencyId = null);
                          _updateActiveFilters();
                          _loadData();
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFilterChip({required String label, required IconData icon, required Color color, required VoidCallback onRemove}) {
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
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
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

  // 🔹 Show Cancel Dialog with Reason Input
  Future<void> _showCancelDialog(Result item) async {
    final String? reason = await showDialog<String>(context: context, barrierDismissible: false, builder: (dialogContext) => _CancelDialogWidget());

    // Agar sabab kiritilgan bo'lsa, eventni ishga tushirish
    if (reason != null && reason.isNotEmpty && mounted) {
      context.read<PartnerBloc>().add(CancelIncome(walletId: item.id ?? 0, description: reason));
    }
  }

  // 🔹 Show Delete Confirmation Dialog
  Future<void> _showDeleteConfirmDialog(Result item) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.delete_outline, color: Colors.red, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('O\'chirish', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        content: const Text('Ushbu tranzaksiyani o\'chirmoqchimisiz? Keyinchalik tiklash mumkin.', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
        actions: [

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.colors.background,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text('Qaytish',style: TextStyle(color: Colors.black),),
                ),
              ),
              Gap(10.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.colors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text('Ha, o\'chirish'),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<PartnerBloc>().add(DeleteIncome(walletId: item.id ?? 0));
    }
  }

  // 🔹 Show Force Delete Confirmation Dialog
  Future<void> _showForceDeleteConfirmDialog(Result item) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.delete_forever, color: Colors.red, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Butunlay o\'chirish',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.red),
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DIQQAT!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.red),
            ),
            SizedBox(height: 8),
            Text('Ushbu tranzaksiya butunlay o\'chiriladi va uni qayta tiklab bo\'lmaydi. Ishonchingiz komilmi?', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
          ],
        ),
        actions: [

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.colors.background,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text('Qaytish',style: TextStyle(color: Colors.black),),
                ),
              ),
              Gap(10.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.colors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text('Ha, butunlay o\'chirish',textAlign: TextAlign.center,),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<PartnerBloc>().add(ForceDeleteIncomeEvent(walletId: item.id ?? 0));
    }
  }

  // 🔹 Show Restore Confirmation Dialog
  Future<void> _showRestoreConfirmDialog(Result item) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.restore, color: Colors.green, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Tiklash', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        content: const Text('Ushbu tranzaksiyani tiklashni xohlaysizmi?', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
        actions: [

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.colors.background,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text('Qaytish',style: TextStyle(color: Colors.black),),
                ),
              ),
              Gap(10.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.colors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text('Ha, tiklash'),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<PartnerBloc>().add(RestoreIncomeEvent(walletId: item.id ?? 0));
    }
  }

  // 🔹 Transaction Card
  Widget _buildTransactionCard(Result item) {
    final bool isKirim = item.type == 'debt';
    final bool isCanceled = item.isCancelled == 1;
    final bool isDeleted = item.deletedAt != null && item.deletedAt!.isNotEmpty;
    final Color amountColor = isKirim ? Colors.green : Colors.red;
    final Color iconBg = isKirim ? Colors.green.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3);
    final String timeText = _formatTimeOnly(item.createdAt ?? '');

    return GestureDetector(
      onTap: () {
        // showEditKirimBottomSheet(context, item).then((v) {
        //
        // });
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) => BlocProvider(
              create: (context) => FileUploadBloc(repository: FileUploadRepository()),
              child: EditKirimBottomSheetContent(transaction: item, scrollController: scrollController),
            ),
          ),
        ).then((v) {
          if (v == true && mounted) {
            context.read<PartnerBloc>().add(IncomeHistoryEvent(id: widget.id ?? 0));
          }
        });
      },
      child: Slidable(
        key: ValueKey(item.id),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: isDeleted ? 0.9 : 0.7,
          children: isDeleted
              ? [
                  // Agar o'chirilgan bo'lsa - Restore va Force Delete
                  SlidableAction(
                    onPressed: (context) => _showRestoreConfirmDialog(item),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    icon: Icons.restore,
                    label: "Tiklash",
                    borderRadius: BorderRadius.circular(12),
                  ),
                  SlidableAction(
                    onPressed: (context) => _showForceDeleteConfirmDialog(item),
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    icon: Icons.delete_forever,
                    label: "Butunlay o'chirish",
                    borderRadius: BorderRadius.circular(12),
                  ),
                ]
              : [
                  // Agar o'chirilmagan bo'lsa - Delete va Cancel
                  SlidableAction(
                    onPressed: (context) => _showDeleteConfirmDialog(item),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.delete_outline,
                    label: "O'chirish",
                    borderRadius: BorderRadius.circular(12),
                  ),
                  if (!isCanceled)
                    SlidableAction(
                      onPressed: (context) => _showCancelDialog(item),
                      backgroundColor: AppTheme.colors.primary,
                      foregroundColor: Colors.white,
                      icon: Icons.cancel_outlined,
                      label: 'Bekor qilish',
                      borderRadius: BorderRadius.circular(12),
                    ),
                ],
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: isDeleted ? Colors.red.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: isDeleted ? Border.all(color: Colors.red.shade300, width: 2) : null,
            boxShadow: [BoxShadow(color: isDeleted ? Colors.red.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
                child: SvgPicture.asset(isKirim ? AppIcons.income : AppIcons.chiqim),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.type == 'debt' ? 'Kirim' : 'Chiqim', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(timeText, style: const TextStyle(color: Colors.black54, fontSize: 13)),
                  ],
                ),
              ),
              Text(
                "${PriceFormatter.priceFormat('${item.summa ?? 0}')} ${item.currencyTypeName ?? ''}",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: amountColor, decoration: isCanceled ? TextDecoration.lineThrough : null, decorationColor: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Safe parse — bir nechta date formatlarini sinaydi.
  DateTime? _tryParseDate(String? input) {
    if (input == null || input.trim().isEmpty) return null;

    // 1) Har doim ISO formatini sinab koʻramiz birinchi (hozirgi koddan kelayotganlar uchun)
    try {
      return DateTime.parse(input);
    } catch (_) {}

    // 2) Keyin sizning ko'proq uchraydigan formatlarni sinaymiz
    final formats = [DateFormat('dd.MM.yyyy HH:mm:ss'), DateFormat('dd.MM.yyyy HH:mm'), DateFormat('dd.MM.yyyy'), DateFormat('yyyy-MM-dd HH:mm:ss'), DateFormat("yyyy-MM-dd'T'HH:mm:ss")];

    for (final fmt in formats) {
      try {
        return fmt.parse(input);
      } catch (_) {}
    }

    // Agar hech biri mos kelmasa null qaytaramiz
    return null;
  }

  // Grouping uchun sana (soat, minutni kesib tashlab)
  DateTime _toDateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  String _formatTimeOnly(String dateStr) {
    final dt = _tryParseDate(dateStr);
    if (dt == null) return dateStr;
    return DateFormat('HH:mm').format(dt);
  }

  /// Shimmer loading widget for transaction history
  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16, right: 10),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              // Icon shimmer
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(width: 12),
              // Text shimmer
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 14,
                        width: 80,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 12,
                        width: 50,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                  ],
                ),
              ),
              // Amount shimmer
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 16,
                  width: 100,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// 🔹 Stateless Dialog Widget - Alohida widget sifatida
class _CancelDialogWidget extends StatefulWidget {
  const _CancelDialogWidget();

  @override
  State<_CancelDialogWidget> createState() => _CancelDialogWidgetState();
}

class _CancelDialogWidgetState extends State<_CancelDialogWidget> {
  final TextEditingController _reasonController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.cancel_outlined, color: Colors.orange, size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Bekor qilish', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bekor qilish sababini kiriting:', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
            const SizedBox(height: 12),
            TextFormField(
              controller: _reasonController,
              maxLines: 3,
              autofocus: true,
              cursorColor: AppTheme.colors.primary,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: 'Sabab...',
                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.colors.primary, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Iltimos, sababni kiriting';
                }
                if (value.trim().length < 3) {
                  return 'Sabab kamida 3 ta belgidan iborat bo\'lishi kerak';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.colors.background,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: Text('Qaytish', style: TextStyle(color: Colors.black)),
              ),
            ),
            Gap(10.w),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final reason = _reasonController.text.trim();
                    Navigator.pop(context, reason); // Sababni qaytarish
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.colors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: const Text('Tasdiqlash'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
