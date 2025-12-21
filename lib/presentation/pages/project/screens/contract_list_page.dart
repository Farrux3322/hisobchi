import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/contract/contract_bloc.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/models/contract_model.dart';
import 'package:hisobchi/presentation/components/loading/loading.dart';
import 'package:hisobchi/presentation/components/toast/toast.dart';
import 'package:hisobchi/presentation/pages/project/screens/contract_add_page.dart';
import 'package:hisobchi/presentation/pages/project/screens/contract_edit_page.dart';
import 'package:collection/collection.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ContractListPage extends StatefulWidget {
  final int projectId;

  const ContractListPage({super.key, required this.projectId});

  @override
  State<ContractListPage> createState() => _ContractListPageState();
}

class _ContractListPageState extends State<ContractListPage> {
  final TextEditingController _searchController = TextEditingController();
  List<ContractModel> _filteredContracts = [];
  List<ContractModel> _allContracts = [];

  @override
  void initState() {
    super.initState();
    _loadContracts();
    _searchController.addListener(_filterContracts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadContracts() {
    context.read<ContractBloc>().add(GetContractsEvent(projectId: widget.projectId));
  }

  void _filterContracts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredContracts = _allContracts;
      } else {
        _filteredContracts = _allContracts.where((contract) => contract.workTypeName!.toLowerCase().contains(query) || (contract.description?.toLowerCase().contains(query) ?? false)).toList();
      }
    });
  }

  DateTime? _tryParseDate(String? input) {
    if (input == null || input.trim().isEmpty) return null;

    try {
      return DateTime.parse(input);
    } catch (_) {}

    final formats = [
      DateFormat('dd.MM.yyyy HH:mm:ss'),
      DateFormat('dd.MM.yyyy HH:mm'),
      DateFormat('dd.MM.yyyy'),
      DateFormat('yyyy-MM-dd HH:mm:ss'),
      DateFormat("yyyy-MM-dd'T'HH:mm:ss")
    ];

    for (final fmt in formats) {
      try {
        return fmt.parse(input);
      } catch (_) {}
    }

    return null;
  }

  DateTime _toDateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  String _formatTimeOnly(String? dateStr) {
    final dt = _tryParseDate(dateStr);
    if (dt == null) return dateStr ?? '';
    return DateFormat('HH:mm').format(dt);
  }

  Future<void> _navigateToAddContract() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => ContractAddPage(projectId: widget.projectId)));

    if (result != null && mounted) {
      _loadContracts();
    }
  }

  Future<void> _navigateToEditContract(ContractModel contract) async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => ContractEditPage(contract: contract)));

    if (result != null && mounted) {
      _loadContracts();
    }
  }

  Future<void> _showDeleteDialog(ContractModel contract) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Ishonchingiz komilmi?'),
        content: Text(contract.isDeleted ? 'Ushbu shartnomani butunlay o\'chirmoqchimisiz?' : 'Ushbu shartnomani o\'chirmoqchimisiz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Bekor qilish')),
          if (contract.isDeleted) ...[
            TextButton(
              onPressed: () => Navigator.pop(context, 'restore'),
              child: const Text('Tiklash', style: TextStyle(color: Colors.green)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'force_delete'),
              child: const Text('Butunlay o\'chirish', style: TextStyle(color: Colors.red)),
            ),
          ] else
            TextButton(
              onPressed: () => Navigator.pop(context, 'delete'),
              child: const Text('O\'chirish', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
    );

    if (result != null && mounted) {
      if (result == 'delete') {
        context.read<ContractBloc>().add(DeleteContractEvent(id: contract.id!));
      } else if (result == 'restore') {
        context.read<ContractBloc>().add(RestoreContractEvent(id: contract.id!));
      } else if (result == 'force_delete') {
        context.read<ContractBloc>().add(ForceDeleteContractEvent(id: contract.id!));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Shartnomalar',
          style: TextStyle(color: Color(0xFF1E293B), fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF5B4FFF), Color(0xFF7C3AED)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: const Color(0xFF5B4FFF).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
            onPressed: _navigateToAddContract,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: BlocConsumer<ContractBloc, ContractState>(
        listener: (context, state) {
          if (state.status == Status.success) {
            _allContracts = state.contracts;
            _filterContracts();
          }
          if (state.status == Status.error) {
            Toast.showErrorToast(message: state.errorMessage ?? 'Xatolik yuz berdi');
          }
          if (state.statusAction == Status.success) {
            Toast.showSuccessToast(message: 'Muvaffaqiyatli bajarildi');
            _loadContracts();
          }
          if (state.statusAction == Status.error) {
            Toast.showErrorToast(message: state.errorMessage ?? 'Xatolik yuz berdi');
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Column(
              children: [
                // Search Bar
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Qidirish...',
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B), size: 20),
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
                        borderSide: const BorderSide(color: Color(0xFF5B4FFF), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),

                // Contracts List
                Expanded(
                  child: state.status == Status.loading && _allContracts.isEmpty
                      ? const Center(child: Loading())
                      : _filteredContracts.isEmpty
                      ? _buildEmptyState()
                      : Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 6, 16),
                              child: CustomScrollView(
                                slivers: _buildGroupedContracts(),
                              ),
                            ),
                            if (state.statusAction == Status.loading)
                              Container(
                                color: Colors.black.withValues(alpha: 0.3),
                                child: const Center(child: Loading()),
                              ),
                          ],
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildGroupedContracts() {
    final groupedData = groupBy<ContractModel, DateTime>(_filteredContracts, (contract) {
      final parsed = _tryParseDate(contract.createdAt);
      if (parsed == null) {
        return DateTime(1970);
      }
      return _toDateOnly(parsed);
    });

    return groupedData.entries.map((entry) {
      final dateKey = entry.key;
      final items = entry.value;

      return SliverStickyHeader(
        header: Container(
          height: 50,
          color: const Color(0xFFF5F5F5),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          alignment: Alignment.centerLeft,
          child: Text(
            DateFormat('dd.MM.yyyy').format(dateKey),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF212529)),
          ),
        ),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final contract = items[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildContractCard(contract),
              );
            },
            childCount: items.length,
          ),
        ),
      );
    }).toList();
  }

  Widget _buildContractCard(ContractModel contract) {
    final bool isDeleted = contract.isDeleted;
    final String timeText = _formatTimeOnly(contract.createdAt);

    return GestureDetector(
      onTap: isDeleted ? null : () => _navigateToEditContract(contract),
      child: Slidable(
        key: ValueKey(contract.id),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: isDeleted ? 0.6 : 0.35,
          children: isDeleted
              ? [
                  SlidableAction(
                    onPressed: (context) async {
                      final result = await showDialog<String>(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          title: const Text('Tiklash'),
                          content: const Text('Ushbu shartnomani tiklashni xohlaysizmi?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Yo\'q')),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, 'restore'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              child: const Text('Ha, tiklash'),
                            ),
                          ],
                        ),
                      );
                      if (result == 'restore' && mounted) {
                        this.context.read<ContractBloc>().add(RestoreContractEvent(id: contract.id!));
                      }
                    },
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    icon: Icons.restore,
                    label: "Tiklash",
                    borderRadius: BorderRadius.circular(12),
                  ),
                  SlidableAction(
                    onPressed: (context) async {
                      final result = await showDialog<String>(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          title: const Text('Butunlay o\'chirish', style: TextStyle(color: Colors.red)),
                          content: const Text('DIQQAT! Ushbu shartnoma butunlay o\'chiriladi va uni qayta tiklab bo\'lmaydi.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Yo\'q')),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, 'force_delete'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
                              child: const Text('Ha, butunlay o\'chirish'),
                            ),
                          ],
                        ),
                      );
                      if (result == 'force_delete' && mounted) {
                        this.context.read<ContractBloc>().add(ForceDeleteContractEvent(id: contract.id!));
                      }
                    },
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    icon: Icons.delete_forever,
                    label: "Butunlay o'chirish",
                    borderRadius: BorderRadius.circular(12),
                  ),
                ]
              : [
                  SlidableAction(
                    onPressed: (context) => _showDeleteDialog(contract),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.delete_outline,
                    label: "O'chirish",
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
            boxShadow: [
              BoxShadow(
                color: isDeleted ? Colors.red.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF5B4FFF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.description_outlined, color: Color(0xFF5B4FFF), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contract.workTypeName ?? '',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        decoration: isDeleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeText,
                      style: const TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${contract.formattedSumma}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF10B981),
                    ),
                  ),
                  if (contract.files != null && contract.files!.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5B4FFF).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${contract.files!.length}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5B4FFF)),
                          ),
                          const SizedBox(width: 2),
                          const Icon(Icons.image_outlined, size: 14, color: Color(0xFF5B4FFF)),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: const Color(0xFF5B4FFF).withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.description_outlined, size: 64, color: Color(0xFF5B4FFF)),
          ),
          const SizedBox(height: 24),
          Text(
            _searchController.text.isEmpty ? 'Shartnomalar mavjud emas' : 'Hech narsa topilmadi',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isEmpty ? 'Yangi shartnoma qo\'shish uchun + tugmasini bosing' : 'Boshqa kalit so\'z bilan qidirib ko\'ring',
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
