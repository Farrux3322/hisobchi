import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
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

  const WorkerSelectionBottomSheet({super.key, required this.projectId, this.isSelectionMode = false});

  @override
  State<WorkerSelectionBottomSheet> createState() => _WorkerSelectionBottomSheetState();
}

class _WorkerSelectionBottomSheetState extends State<WorkerSelectionBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<WorkerModel> _filteredWorkers = [];
  List<WorkerModel> _allWorkers = [];
  final Set<int> _selectedWorkerIds = {};

  @override
  void initState() {
    super.initState();
    context.read<WorkerBloc>().add( GetAllWorkersEvent(projectId: widget.projectId));
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
      context.read<WorkerBloc>().add( GetAllWorkersEvent(projectId: widget.projectId));
    }
  }

  void _toggleWorkerSelection(WorkerModel worker) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_selectedWorkerIds.contains(worker.id)) {
        _selectedWorkerIds.remove(worker.id);
      } else {
        _selectedWorkerIds.add(worker.id!);
      }
    });
  }

  void _submitSelectedWorkers() {
    if (_selectedWorkerIds.isEmpty) {
      Toast.showErrorToast(message: 'Kamida bitta ishchini tanlang');
      return;
    }

    if (widget.isSelectionMode) {
      // For single selection mode, return the first selected worker
      final selectedWorker = _allWorkers.firstWhere((w) => w.id == _selectedWorkerIds.first);
      Navigator.pop(context, selectedWorker);
    } else {
      // Add multiple workers to project
      context.read<WorkerBloc>().add(
            AddWorkersToProjectEvent(
              workerIds: _selectedWorkerIds.toList(),
              projectId: widget.projectId,
            ),
          );
    }
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
              HapticFeedback.mediumImpact();
              Toast.showSuccessToast(message: '${_selectedWorkerIds.length} ta ishchi qo\'shildi');
              Navigator.pop(context, true);
            }
            if (state.statusAction == Status.error) {
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
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2),
                      ),
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
                          child: Column(
                            children: [
                              const Text(
                                'Ishchi tanlash',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                                textAlign: TextAlign.center,
                              ),
                              if (_selectedWorkerIds.isNotEmpty)
                                Text(
                                  '${_selectedWorkerIds.length} ta tanlandi',
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF5B4FFF), fontWeight: FontWeight.w500),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFF5B4FFF), Color(0xFF7C3AED)]),
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
                                    controller: scrollController,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    itemCount: _filteredWorkers.length,
                                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                                    itemBuilder: (context, index) {
                                      final worker = _filteredWorkers[index];
                                      final isSelected = _selectedWorkerIds.contains(worker.id);
                                      return Column(
                                        children: [
                                          _buildWorkerItem(worker, isSelected),
                                          if (index == _filteredWorkers.length - 1) Gap(80 + MediaQuery.of(context).padding.bottom)
                                        ],
                                      );
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

                  // Bottom Submit Button
                  if (_selectedWorkerIds.isNotEmpty)
                    Container(
                      padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        top: false,
                        child: SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: state.statusAction == Status.loading ? null : _submitSelectedWorkers,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5B4FFF),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              disabledBackgroundColor: const Color(0xFF5B4FFF).withValues(alpha: 0.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (state.statusAction == Status.loading)
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                else
                                  Text(
                                    'Saqlash (${_selectedWorkerIds.length})',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                              ],
                            ),
                          ),
                        ),
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

  Widget _buildWorkerItem(WorkerModel worker, bool isSelected) {
    return GestureDetector(
      onTap: () => _toggleWorkerSelection(worker),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5B4FFF).withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF5B4FFF) : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isSelected ? 0.05 : 0.02),
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
                color: const Color(0xFF5B4FFF).withValues(alpha: isSelected ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.person_outline,
                color: isSelected ? const Color(0xFF5B4FFF) : const Color(0xFF5B4FFF).withValues(alpha: 0.7),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    worker.name ?? '',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: const Color(0xFF1E293B),
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
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text(
                  worker.phone!,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
                ),
              ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF5B4FFF) : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF5B4FFF) : const Color(0xFF94A3B8),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
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
            _searchController.text.isEmpty ? 'Yangi ishchi yaratish uchun + tugmasini bosing' : 'Boshqa kalit so\'z bilan qidirib ko\'ring',
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}