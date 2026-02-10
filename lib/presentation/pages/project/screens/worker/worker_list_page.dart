import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hisobchi/application/worker/worker_bloc.dart';
import 'package:hisobchi/application/worker/worker_event.dart';
import 'package:hisobchi/application/worker/worker_state.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/models/worker_model.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/components/back_button.dart';
import 'package:hisobchi/presentation/components/loading/loading.dart';
import 'package:hisobchi/presentation/components/toast/toast.dart';
import 'package:hisobchi/presentation/pages/project/screens/worker/worker_add_edit_page.dart';
import 'package:hisobchi/presentation/pages/project/screens/worker/worker_selection_bottom_sheet.dart';
import 'package:hisobchi/presentation/components/subscription/subscription_guard.dart';
import 'package:collection/collection.dart';
import 'package:shimmer/shimmer.dart';

class WorkerListPage extends StatefulWidget {
  final int projectId;

  const WorkerListPage({super.key, required this.projectId});

  @override
  State<WorkerListPage> createState() => _WorkerListPageState();
}

class _WorkerListPageState extends State<WorkerListPage> {
  final TextEditingController _searchController = TextEditingController();
  List<WorkerModel> _filteredWorkers = [];
  List<WorkerModel> _allWorkers = [];

  @override
  void initState() {
    super.initState();
    _loadWorkers();
    _searchController.addListener(_filterWorkers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadWorkers() {
    context.read<WorkerBloc>().add(GetProjectWorkersEvent(projectId: widget.projectId));
  }

  void _filterWorkers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredWorkers = _allWorkers;
      } else {
        _filteredWorkers = _allWorkers
            .where(
              (worker) =>
                  (worker.name?.toLowerCase().contains(query) ?? false) ||
                  (worker.phone?.toLowerCase().contains(query) ?? false) ||
                  (worker.workerPositionName?.toLowerCase().contains(query) ?? false),
            )
            .toList();
      }
    });
  }

  DateTime? _tryParseDate(String? input) {
    if (input == null || input.trim().isEmpty) return null;

    try {
      return DateTime.parse(input);
    } catch (_) {}

    final formats = [DateFormat('dd.MM.yyyy HH:mm:ss'), DateFormat('dd.MM.yyyy HH:mm'), DateFormat('dd.MM.yyyy'), DateFormat('yyyy-MM-dd HH:mm:ss'), DateFormat("yyyy-MM-dd'T'HH:mm:ss")];

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

  String _formatPhone(String? phone) {
    if (phone == null || phone.isEmpty) return '';

    // Remove all non-digit characters
    String digits = phone.replaceAll(RegExp(r'\D'), '');

    // If starts with 998, use it; otherwise assume it's local number
    if (digits.startsWith('998')) {
      digits = digits.substring(3); // Remove country code
    }

    // Format: +998 (XX) XXX XX XX
    if (digits.length >= 9) {
      return '+998 (${digits.substring(0, 2)}) ${digits.substring(2, 5)} ${digits.substring(5, 7)} ${digits.substring(7, 9)}';
    }

    // Return original if can't format
    return phone;
  }

  Future<void> _showAddWorkerSelection() async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WorkerSelectionBottomSheet(projectId: widget.projectId),
    );

    if (result == true && mounted) {
      _loadWorkers();
    }
  }

  Future<void> _navigateToEditWorker(WorkerModel worker) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<WorkerBloc>(),
          child: WorkerAddEditPage(worker: worker),
        ),
      ),
    );

    if (result == true && mounted) {
      _loadWorkers();
    }
  }

  Future<void> _showDeleteDialog(WorkerModel worker) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Loyihadan o\'chirish', textAlign: TextAlign.center),
        content: Text('${worker.name} ishchini loyihadan o\'chirmoqchimisiz?', textAlign: TextAlign.center),
        actions: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.colors.gray),
                  child: const Text('Qaytish'),
                ),
              ),
              Gap(8.2),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, 'remove'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('O\'chirish'),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (result == 'remove' && mounted) {
      context.read<WorkerBloc>().add(RemoveWorkerFromProjectEvent(workerId: worker.id!, projectId: widget.projectId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: BackArrowButton(),
        title: const Text(
          'Ishchilar',
        ),
        centerTitle: true,
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: SubscriptionGuard(
          child: FloatingActionButton(
            heroTag: 'worker_fab',
            onPressed: _showAddWorkerSelection,
            backgroundColor: AppTheme.colors.primary,
            child: SvgPicture.asset(AppIcons.clientAdd),
          ),
        ),
      ),

      body: BlocConsumer<WorkerBloc, WorkerState>(
        listener: (context, state) {
          // statusAction - delete/restore uchun (bir marta ishlatiladi)
          if (state.statusAction == Status.success) {
            Toast.showSuccessToast(message: 'Muvaffaqiyatli bajarildi');
            _loadWorkers();
          } else if (state.statusAction == Status.error) {
            Toast.showErrorToast(message: state.errorMessage ?? 'Xatolik yuz berdi');
          }

          // status - get workers uchun
          if (state.status == Status.success) {
            setState(() {
              _allWorkers = state.projectWorkers;
              _filterWorkers();
            });
          } else if (state.status == Status.error) {
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
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Qidirish...',
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(left: 8.0, right: 4),
                        child: Icon(Icons.search, color: Color(0xFF64748B), size: 20),
                      ),
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

                // Workers List
                Expanded(
                  child: state.status == Status.loading && _allWorkers.isEmpty
                      ? _buildShimmerLoading()
                      : _filteredWorkers.isEmpty
                      ? _buildEmptyState()
                      : Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 6, 16),
                              child: CustomScrollView(slivers: _buildGroupedWorkers()),
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

  List<Widget> _buildGroupedWorkers() {
    final groupedData = groupBy<WorkerModel, DateTime>(_filteredWorkers, (worker) {
      final parsed = _tryParseDate(worker.createdAt);
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
            final worker = items[index];
            return Padding(padding: const EdgeInsets.only(bottom: 10), child: _buildWorkerCard(worker));
          }, childCount: items.length),
        ),
      );
    }).toList();
  }

  Widget _buildWorkerCard(WorkerModel worker) {
    final String timeText = _formatTimeOnly(worker.createdAt);

    return SubscriptionGuard(
      child: GestureDetector(
        onTap: () => _navigateToEditWorker(worker),
        child: Slidable(
        key: ValueKey(worker.id),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.55,
          children: [
            CustomSlidableAction(
              onPressed: (context) => _navigateToEditWorker(worker),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              child: SubscriptionGuard(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_outlined),
                      Text("Tahrirlash", style: TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
              ),
            ),
            CustomSlidableAction(
              onPressed: (context) => _showDeleteDialog(worker),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              child: SubscriptionGuard(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete_outline),
                      Text("O'chirish", style: TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(color: const Color(0xFF5B4FFF).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.person_outline, color: Color(0xFF5B4FFF), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(worker.name ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(worker.workerPositionName ?? 'Lavozim ko\'rsatilmagan', style: const TextStyle(color: Colors.black54, fontSize: 13)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (worker.phone != null)
                    Text(
                      _formatPhone(worker.phone),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
                    ),
                  const SizedBox(height: 4),
                  Text(timeText, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: const Color(0xFF5B4FFF).withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.person_outline, size: 64, color: Color(0xFF5B4FFF)),
          ),
          const SizedBox(height: 24),
          Text(
            _searchController.text.isEmpty ? 'Ishchilar mavjud emas' : 'Hech narsa topilmadi',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isEmpty ? 'Yangi ishchi qo\'shish uchun + tugmasini bosing' : 'Boshqa kalit so\'z bilan qidirib ko\'ring',
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 6, 16),
      child: ListView.builder(
        itemCount: 8,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10, right: 10),
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
                          width: 120,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          height: 12,
                          width: 80,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                    ],
                  ),
                ),
                // Time shimmer
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 12,
                    width: 40,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
