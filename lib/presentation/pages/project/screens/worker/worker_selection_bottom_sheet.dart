import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/worker/worker_bloc.dart';
import 'package:hisobchi/application/worker/worker_event.dart';
import 'package:hisobchi/application/worker/worker_state.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/models/worker_model.dart';
import 'package:hisobchi/infrastructure/repository/worker/worker_repository.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
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
    context.read<WorkerBloc>().add(GetAllWorkersEvent(projectId: widget.projectId));
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
      context.read<WorkerBloc>().add(GetAllWorkersEvent(projectId: widget.projectId));
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

    // if (widget.isSelectionMode) {
    //   // For single selection mode, return the first selected worker
    //   final selectedWorker = _allWorkers.firstWhere((w) => w.id == _selectedWorkerIds.first);
    //   Navigator.pop(context, selectedWorker);
    // } else {
    // Add multiple workers to project
    context.read<WorkerBloc>().add(AddWorkersToProjectEvent(workerIds: _selectedWorkerIds.toList(), projectId: widget.projectId));
    // }
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
            if (state.statusAction == Status.success) {
              HapticFeedback.mediumImpact();
              
              // Only pop if we were adding workers to the project
              if (_selectedWorkerIds.isNotEmpty && state.statusAllWorkers != Status.loading) {
                Toast.showSuccessToast(message: '${_selectedWorkerIds.length} ta ishchi qo\'shildi');
                Navigator.pop(context, true);
              } else {
                // If it was a delete/restore/force-delete action, just refresh the list
                context.read<WorkerBloc>().add(GetAllWorkersEvent(projectId: widget.projectId));
                _selectedWorkerIds.clear(); // Clear selection after action
              }
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
                          child: Column(
                            children: [
                              Text(
                                'Ushbu loyihaga biriktirilmagan ishchilar',
                                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                                textAlign: TextAlign.center,
                              ),
                              if (_selectedWorkerIds.isNotEmpty)
                                Text(
                                  '${_selectedWorkerIds.length} ta tanlandi',
                                  style:  TextStyle(fontSize: 13, color: AppTheme.colors.primary, fontWeight: FontWeight.w500),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: AppTheme.colors.primary, borderRadius: BorderRadius.circular(8)),
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
                        prefixIcon:  Padding(
                          padding:  EdgeInsets.only(left: 8.0,right: 4),
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
                          borderSide:  BorderSide(color: AppTheme.colors.primary, width: 2),
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
                        ? Padding(
                            padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
                            child: _buildEmptyState(),
                          )
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
                                  return Column(children: [_buildWorkerItem(worker, isSelected), if (index == _filteredWorkers.length - 1) Gap(80 + MediaQuery.of(context).padding.bottom)]);
                                },
                              ),
                              if (state.statusAction == Status.loading || (state.statusAllWorkers == Status.loading && _allWorkers.isNotEmpty))
                                Container(
                                  color: Colors.white.withValues(alpha: 0.5),
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
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -5))],
                      ),
                      child: SafeArea(
                        top: false,
                        child: SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: state.statusAction == Status.loading ? null : _submitSelectedWorkers,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.colors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              disabledBackgroundColor: AppTheme.colors.primary.withValues(alpha: 0.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (state.statusAction == Status.loading)
                                  const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                                else
                                  Text('Loyihaga biriktirish (${_selectedWorkerIds.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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

  void _showDeleteConfirmation(WorkerModel worker) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titlePadding: EdgeInsets.zero,
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        title: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: AppTheme.colors.red.withValues(alpha: 0.1),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Icon(Icons.delete_outline_rounded, color: AppTheme.colors.red, size: 48),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ishchini o\'chirish',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800, color: AppTheme.colors.black),
            ),
            const SizedBox(height: 12),
            Text(
              'Rostdan ham "${worker.name}" ishchisini o\'chirmoqchimisiz?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: AppTheme.colors.gray, height: 1.5),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Bekor qilish', style: TextStyle(color: AppTheme.colors.gray, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.read<WorkerBloc>().add(DeleteWorkerEvent(workerId: worker.id!));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.colors.red,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('O\'chirish', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRestoreForceDeleteDialog(WorkerModel worker) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titlePadding: EdgeInsets.zero,
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        title: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: AppTheme.colors.primary.withValues(alpha: 0.1),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Icon(Icons.settings_backup_restore_rounded, color: AppTheme.colors.primary, size: 48),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'O\'chirilgan ishchi',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800, color: AppTheme.colors.black),
            ),
            const SizedBox(height: 12),
            Text(
              '"${worker.name}" ishchisini qayta tiklamoqchimisiz yoki butunlay o\'chirib tashlaysizmi?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: AppTheme.colors.gray, height: 1.5),
            ),
          ],
        ),
        actions: [
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.read<WorkerBloc>().add(RestoreWorkerEvent(workerId: worker.id!));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.colors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Qayta tiklash', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showForceDeleteConfirmation(worker);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Butunlay o\'chirish', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Yopish', style: TextStyle(color: AppTheme.colors.gray)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showForceDeleteConfirmation(WorkerModel worker) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title:  Icon(Icons.warning_amber_rounded, color: AppTheme.colors.red, size: 48),
        content: Text(
          'Diqqat! "${worker.name}" ishchisini butunlay o\'chirib yuborsangiz, unga tegishli barcha ma\'lumotlar qayta tiklanmaydigan qilib o\'chiriladi. Davom etasizmi?',
          textAlign: TextAlign.center,
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.colors.gray, foregroundColor: Colors.white),
                  child: const Text('Bekor qilish'),
                ),
              ),
              Gap(10.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.read<WorkerBloc>().add(ForceDeleteWorkerEvent(workerId: worker.id!));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.colors.red, foregroundColor: Colors.white),
                  child: Center(child: const Text('Ha, butunlay o\'chirilsin',textAlign: TextAlign.center)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkerItem(WorkerModel worker, bool isSelected) {
    final bool isDeleted = worker.isDeleted;

    return Slidable(
      key: ValueKey(worker.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: isDeleted ? 0.5 : 0.25,
        children: [
          if (!isDeleted)
            SlidableAction(
              onPressed: (context) => _showDeleteConfirmation(worker),
              backgroundColor: AppTheme.colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete_outline_rounded,
              label: 'O\'chirish',
              borderRadius: BorderRadius.circular(12),
            )
          else ...[
            SlidableAction(
              onPressed: (context) => context.read<WorkerBloc>().add(RestoreWorkerEvent(workerId: worker.id!)),
              backgroundColor: AppTheme.colors.primary,
              foregroundColor: Colors.white,
              icon: Icons.restore_rounded,
              label: 'Tiklash',
              borderRadius: BorderRadius.horizontal(left: Radius.circular(12)),
            ),
            SlidableAction(
              onPressed: (context) => _showForceDeleteConfirmation(worker),
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              icon: Icons.delete_forever_rounded,
              label: "O'chirish",
              borderRadius: BorderRadius.horizontal(right: Radius.circular(12)),
            ),
          ],
        ],
      ),
      child: GestureDetector(
        onTap: isDeleted ? () => _showRestoreForceDeleteDialog(worker) : () => _toggleWorkerSelection(worker),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDeleted 
                ? AppTheme.colors.gray.withValues(alpha: 0.05)
                : isSelected ? const Color(0xFF5B4FFF).withValues(alpha: 0.05) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDeleted 
                  ? AppTheme.colors.red.withValues(alpha: 0.2)
                  : isSelected ? AppTheme.colors.primary : const Color(0xFFE2E8F0), 
              width: isSelected ? 2 : 1
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isSelected ? 0.05 : 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: isDeleted 
                      ? AppTheme.colors.gray.withValues(alpha: 0.1)
                      : const Color(0xFF5B4FFF).withValues(alpha: isSelected ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isDeleted ? Icons.person_off_outlined : Icons.person_outline, 
                  color: isDeleted 
                      ? AppTheme.colors.black.withValues(alpha: 0.9)
                      : isSelected ? const Color(0xFF5B4FFF) : const Color(0xFF5B4FFF).withValues(alpha: 0.7), 
                  size: 24
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            worker.name ?? '',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15, 
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600, 
                              color: isDeleted ? AppTheme.colors.black.withValues(alpha: 0.6) : const Color(0xFF1E293B),
                              decoration: isDeleted ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                        if (isDeleted)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'O\'chirilgan',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.colors.red),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (worker.phone != null)
                      Text(
                        _formatPhone(worker.phone),
                        style: TextStyle(
                          fontSize: 14, 
                          fontWeight: FontWeight.w600, 
                          color: isDeleted ? AppTheme.colors.black.withValues(alpha: 0.4) : Color(0xFF64748B)
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      worker.workerPositionName ?? 'Lavozim ko\'rsatilmagan', 
                      style: TextStyle(
                        fontSize: 13, 
                        color: isDeleted ? AppTheme.colors.black.withValues(alpha: 0.4) : Color(0xFF64748B)
                      )
                    ),
                  ],
                ),
              ),

              if (!isDeleted)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.colors.primary : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(color: isSelected ? AppTheme.colors.primary : const Color(0xFF94A3B8), width: 2),
                  ),
                  child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                )
              else
                Icon(Icons.more_vert_rounded, color: AppTheme.colors.gray.withValues(alpha: 0.3)),
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
            _searchController.text.isEmpty ? 'Yangi ishchi yaratish uchun + tugmasini bosing' : 'Boshqa kalit so\'z bilan qidirib ko\'ring',
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
