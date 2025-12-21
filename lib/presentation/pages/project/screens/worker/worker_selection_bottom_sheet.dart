import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/worker/worker_bloc.dart';
import 'package:hisobchi/application/worker/worker_event.dart';
import 'package:hisobchi/application/worker/worker_state.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/models/worker_model.dart';
import 'package:hisobchi/infrastructure/repository/worker/worker_repository.dart';
import 'package:hisobchi/presentation/components/loading/loading.dart';
import 'package:hisobchi/presentation/components/toast/toast.dart';
import 'package:hisobchi/presentation/pages/project/screens/worker/worker_add_edit_page.dart';

class WorkerSelectionBottomSheet extends StatefulWidget {
  final int projectId;
  final bool isSelectionMode;

  const WorkerSelectionBottomSheet({
    super.key,
    required this.projectId,
    this.isSelectionMode = false,
  });

  @override
  State<WorkerSelectionBottomSheet> createState() => _WorkerSelectionBottomSheetState();
}

class _WorkerSelectionBottomSheetState extends State<WorkerSelectionBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<WorkerModel> _filteredWorkers = [];
  List<WorkerModel> _allWorkers = [];

  @override
  void initState() {
    super.initState();
    context.read<WorkerBloc>().add(const GetAllWorkersEvent());
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
            .where((worker) =>
                (worker.name?.toLowerCase().contains(query) ?? false) ||
                (worker.phone?.toLowerCase().contains(query) ?? false) ||
                (worker.workerPositionName?.toLowerCase().contains(query) ?? false))
            .toList();
      }
    });
  }

  Future<void> _navigateToAddWorker() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => WorkerBloc(repository: WorkerRepository()),
          child: const WorkerAddEditPage(),
        ),
      ),
    );

    if (result == true && mounted) {
      context.read<WorkerBloc>().add(const GetAllWorkersEvent());
    }
  }

  void _addWorkerToProject(WorkerModel worker) {
    if (widget.isSelectionMode) {
      Navigator.pop(context, worker);
    } else {
      context.read<WorkerBloc>().add(
            AddWorkerToProjectEvent(
              workerId: worker.id!,
              projectId: widget.projectId,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WorkerBloc, WorkerState>(
      listener: (context, state) {
        if (state.statusAllWorkers == Status.success) {
          setState(() {
            _allWorkers = state.allWorkers;
            _filterWorkers();
          });
        }
        if (state.statusAllWorkers == Status.error) {
          Toast.showErrorToast(message: state.errorMessage ?? 'Xatolik yuz berdi');
        }
        if (state.statusAction == Status.success && !widget.isSelectionMode) {
          Toast.showSuccessToast(message: 'Ishchi qo\'shildi');
          Navigator.pop(context, true);
        }
        if (state.statusAction == Status.error) {
          Toast.showErrorToast(message: state.errorMessage ?? 'Xatolik yuz berdi');
        }
      },
      builder: (context, state) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
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
                    const Expanded(
                      child: Text(
                        'Ishchi tanlash',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF5B4FFF), Color(0xFF7C3AED)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 20),
                      ),
                      onPressed: _navigateToAddWorker,
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
                child: state.statusAllWorkers == Status.loading && _allWorkers.isEmpty
                    ? const Center(child: Loading())
                    : _filteredWorkers.isEmpty
                        ? _buildEmptyState()
                        : Stack(
                            children: [
                              ListView.separated(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _filteredWorkers.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final worker = _filteredWorkers[index];
                                  return _buildWorkerItem(worker);
                                },
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
    );
  }

  Widget _buildWorkerItem(WorkerModel worker) {
    return GestureDetector(
      onTap: () => _addWorkerToProject(worker),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF5B4FFF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.person_outline, color: Color(0xFF5B4FFF), size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    worker.name ?? '',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    worker.workerPositionName ?? 'Lavozim ko\'rsatilmagan',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            if (worker.phone != null)
              Text(
                worker.phone!,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
            const SizedBox(width: 8),
            Icon(
              widget.isSelectionMode ? Icons.check_circle_outline : Icons.add_circle_outline,
              color: const Color(0xFF5B4FFF),
              size: 24,
            ),
          ],
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
            decoration: BoxDecoration(
              color: const Color(0xFF5B4FFF).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_outline, size: 64, color: Color(0xFF5B4FFF)),
          ),
          const SizedBox(height: 24),
          Text(
            _searchController.text.isEmpty ? 'Ishchilar mavjud emas' : 'Hech narsa topilmadi',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isEmpty
                ? 'Yangi ishchi yaratish uchun + tugmasini bosing'
                : 'Boshqa kalit so\'z bilan qidirib ko\'ring',
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}