import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/worker/worker_bloc.dart';
import 'package:hisobchi/application/worker/worker_event.dart';
import 'package:hisobchi/application/worker/worker_state.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/models/worker_model.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/components/loading/loading.dart';
import 'package:hisobchi/presentation/components/toast/toast.dart';
import 'package:hisobchi/presentation/pages/project/screens/worker/worker_selection_bottom_sheet.dart';

class SingleWorkerSelectionBottomSheet extends StatefulWidget {
  final int projectId;

  const SingleWorkerSelectionBottomSheet({super.key, required this.projectId});

  @override
  State<SingleWorkerSelectionBottomSheet> createState() => _SingleWorkerSelectionBottomSheetState();
}

class _SingleWorkerSelectionBottomSheetState extends State<SingleWorkerSelectionBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<WorkerModel> _filteredWorkers = [];
  List<WorkerModel> _allWorkers = [];

  @override
  void initState() {
    super.initState();
    context.read<WorkerBloc>().add(GetProjectWorkersEvent(projectId: widget.projectId));
    _searchController.addListener(_filterWorkers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  Future<void> _openWorkerSelectionBottomSheet() async {
    final result = await showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (bottomSheetContext) => BlocProvider.value(
        value: context.read<WorkerBloc>(),
        child: WorkerSelectionBottomSheet(projectId: widget.projectId, isSelectionMode: true),
      ),
    );

    // Only close this bottom sheet if a worker was actually selected
    if (result != null && result == true && mounted) {
      context.read<WorkerBloc>().add(GetProjectWorkersEvent(projectId: widget.projectId));
      // Navigator.pop(context, result);
    }
  }

  void _selectWorker(WorkerModel worker) {
    HapticFeedback.selectionClick();
    Navigator.pop(context, worker);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return BlocConsumer<WorkerBloc, WorkerState>(
          listener: (context, state) {
            if (state.status == Status.success) {
              setState(() {
                _allWorkers = state.projectWorkers;
                _filterWorkers();
              });
            }
            if (state.status == Status.error) {
              Toast.showErrorToast(message: state.errorMessage ?? 'Xatolik yuz berdi');
            }
          },
          builder: (context, state) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Drag Handle
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Text(
                            'Loyihaga biriktirilgan ishchilar',
                            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: AppTheme.colors.primary, borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.add, color: Colors.white, size: 20),
                          ),
                          onPressed: _openWorkerSelectionBottomSheet,
                        ),
                      ],
                    ),
                  ),

                  // Search
                  Padding(
                    padding: const EdgeInsets.all(16),
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

                  // Workers List
                  Expanded(
                    child: state.status == Status.loading && _allWorkers.isEmpty
                        ? const Center(child: Loading())
                        : _filteredWorkers.isEmpty
                        ? Padding(
                            padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
                            child: _buildEmptyState(),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filteredWorkers.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final worker = _filteredWorkers[index];
                              return Column(children: [_buildWorkerItem(worker), if (index == _filteredWorkers.length - 1) Gap(MediaQuery.of(context).padding.bottom + 10)]);
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWorkerItem(WorkerModel worker) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _selectWorker(worker),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(color: const Color(0xFF5B4FFF).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.person_outline, color: Color(0xFF5B4FFF), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      worker.name ?? '',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (worker.workerPositionName != null) ...[
                          Flexible(
                            child: Text(
                              worker.workerPositionName!,
                              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (worker.phone != null) ...[const Text(' • ', style: TextStyle(fontSize: 13, color: Color(0xFF64748B)))],
                        ],
                        if (worker.phone != null)
                          Flexible(
                            child: Text(
                              worker.phone!,
                              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF94A3B8)),
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
            child: const Icon(Icons.person_outline, size: 64, color: Color(0xFF5B4FFF)),
          ),
          const SizedBox(height: 24),
          Text(
            _searchController.text.isEmpty ? 'Ishchilar mavjud emas' : 'Hech narsa topilmadi',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isEmpty ? 'Barcha ishchilardan tanlash uchun + tugmasini bosing' : 'Boshqa kalit so\'z bilan qidirib ko\'ring',
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
