import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ehisob/application/partner/partner_bloc.dart';
import 'package:ehisob/domain/common/constants.dart';
import 'package:ehisob/infrastructure/dto/models/partner/income_history_model.dart';
import 'package:ehisob/presentation/components/back_button.dart';
import 'package:ehisob/presentation/components/loading/loading.dart';
import 'package:collection/collection.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:ehisob/presentation/pages/client/widgets/edit_kirim_bottom_sheet.dart';
import 'package:ehisob/presentation/pages/client/widgets/filter_bottom_sheet.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ehisob/presentation/pages/client/components/history_filter_field.dart';
import 'package:ehisob/presentation/pages/client/components/history_transaction_card.dart';
import 'package:ehisob/presentation/pages/client/components/history_dialogs.dart';
import 'package:ehisob/infrastructure/services/permission_extension.dart';
import 'package:ehisob/domain/common/data/user_data.dart';
import 'package:ehisob/presentation/components/toast/toast.dart';

import '../../assets/asset_index.dart';

class HisobKitobTarixPage extends StatefulWidget {
  const HisobKitobTarixPage({super.key, this.id, this.initialType, this.initialCurrencyId, this.partnerPhone});

  final int? id;
  final String? initialType;
  final String? partnerPhone;
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
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading:  BackArrowButton(),
        title: const Text(
          "Hisob-kitob tarixlari",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 6, 16).copyWith(bottom: MediaQuery.of(context).padding.bottom),
        child: BlocConsumer<PartnerBloc, PartnerState>(
          listener: (context, state) {
            // // Success - listni yangilash

            if (state.statusKirimAdd == Status.success) {
              _loadData();
              // context.read<PartnerBloc>().add(IncomeHistoryEvent(id: widget.id ?? 0));
              context.read<PartnerBloc>().add(IncomeStatementEvent(id: widget.id ?? 0));
            }
          },
          builder: (context, state) {
            final bool isHistoryLoading = state.statusIncomeHistory == Status.loading;

            return Stack(
              children: [
                Column(
                  children: [
                    HistoryFilterField(
                      searchController: _searchController,
                      hasActiveFilters: _hasActiveFilters,
                      onFilterTap: _showFilterBottomSheet,
                      onSearchChanged: () {
                        setState(() {});
                        if (_searchController.text.isEmpty || _searchController.text.length >= 2) {
                          _loadData();
                        }
                      },
                      onClearSearch: () {
                        _searchController.clear();
                        setState(() {});
                        _loadData();
                      },
                      selectedType: _selectedType,
                      startDate: _startDate,
                      endDate: _endDate,
                      currencyId: _currencyId,
                      isCancelled: _isCancelled,
                      onRemoveType: () {
                        setState(() => _selectedType = null);
                        _updateActiveFilters();
                        _loadData();
                      },
                      onRemoveDate: () {
                        setState(() {
                          _startDate = null;
                          _endDate = null;
                        });
                        _updateActiveFilters();
                        _loadData();
                      },
                      onRemoveCurrency: () {
                        setState(() => _currencyId = null);
                        _updateActiveFilters();
                        _loadData();
                      },
                      onRemoveCancelled: () {
                        setState(() => _isCancelled = null);
                        _updateActiveFilters();
                        _loadData();
                      },
                    ),
                    const SizedBox(height: 10),
                    Expanded(child: isHistoryLoading ? _buildShimmerLoading() : _buildHistoryContent(state)),
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

  // 🔹 Action Handlers
  void _handleCardTap(Result item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.4,
        maxChildSize: 0.99,
        expand: false,
        builder: (context, scrollController) => TransactionDetailBottomSheet(transaction: item, scrollController: scrollController,partnerPhone: widget.partnerPhone,),
      ),
    );
  }

  Future<void> _showCancelDialog(Result item) async {
    final bool isDebt = item.type == 'debt';
    final String permissionKey = isDebt ? 'wallets_debt.cancel' : 'wallets_credit.cancel';

    if (!context.hasPermission(permissionKey)) {
      Toast.showWarningToast(message: 'Sizda bunday huquq yo\'q');
      return;
    }
    final reason = await HistoryDialogs.showCancelDialog(context);
    if (reason != null && reason.isNotEmpty && mounted) {
      context.read<PartnerBloc>().add(CancelIncome(walletId: item.id ?? 0, description: reason));
    }
  }

  Future<void> _showDeleteConfirmDialog(Result item) async {
    if (UserData.isWorkerMode) {
      Toast.showWarningToast(message: 'Sizda bunday huquq yo\'q');
      return;
    }
    final confirmed = await HistoryDialogs.showDeleteConfirmDialog(context);
    if (confirmed == true && mounted) {
      context.read<PartnerBloc>().add(DeleteIncome(walletId: item.id ?? 0));
    }
  }

  Future<void> _showForceDeleteConfirmDialog(Result item) async {
    if (!context.hasPermission('partners.delete')) {
      Toast.showWarningToast(message: 'Sizda bunday huquq yo\'q');
      return;
    }
    final confirmed = await HistoryDialogs.showForceDeleteConfirmDialog(context);
    if (confirmed == true && mounted) {
      context.read<PartnerBloc>().add(ForceDeleteIncomeEvent(walletId: item.id ?? 0));
    }
  }

  Future<void> _showRestoreConfirmDialog(Result item) async {
    if (UserData.isWorkerMode) {
      Toast.showWarningToast(message: 'Sizda bunday huquq yo\'q');
      return;
    }
    final confirmed = await HistoryDialogs.showRestoreConfirmDialog(context);
    if (confirmed == true && mounted) {
      context.read<PartnerBloc>().add(RestoreIncomeEvent(walletId: item.id ?? 0));
    }
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

  Widget _buildHistoryContent(PartnerState state) {
    final data = state.incomeHistoryModel?.result ?? [];

    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
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
      );
    }

    // Sanalar bo'yicha guruhlash
    final groupedData = groupBy<Result, DateTime>(data, (item) {
      final parsed = _tryParseDate(item.createdAt ?? '');
      if (parsed == null) return DateTime(1970);
      return _toDateOnly(parsed);
    });

    return CustomScrollView(
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
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: HistoryTransactionCard(
                  item: item,
                  timeText: _formatTimeOnly(item.createdAt ?? ''),
                  onTap: () => _handleCardTap(item),
                  onDelete: _showDeleteConfirmDialog,
                  onCancel: _showCancelDialog,
                  onRestore: _showRestoreConfirmDialog,
                  onForceDelete: _showForceDeleteConfirmDialog,
                ),
              );
            }, childCount: items.length),
          ),
        );
      }).toList(),
    );
  }
}
