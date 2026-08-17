import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:ehisob/application/worker/worker_bloc.dart';
import 'package:ehisob/application/worker/worker_event.dart';
import 'package:ehisob/application/worker/worker_state.dart';
import 'package:ehisob/domain/common/constants.dart';
import 'package:ehisob/infrastructure/models/worker_model.dart';
import 'package:ehisob/presentation/pages/project/screens/worker/widgets/add_worker_position_sheet.dart';
import 'package:ehisob/presentation/pages/project/screens/worker/widgets/delete_position_confirm_sheet.dart';
import 'package:ehisob/presentation/pages/project/screens/worker/widgets/force_delete_position_confirm_sheet.dart';
import 'package:ehisob/presentation/components/loading/loading.dart';
import 'package:ehisob/presentation/components/toast/toast.dart';
import '../../../../assets/asset_index.dart';

class WorkerPositionBottomSheet extends StatefulWidget {
  const WorkerPositionBottomSheet({super.key});

  @override
  State<WorkerPositionBottomSheet> createState() => _WorkerPositionBottomSheetState();
}

class _WorkerPositionBottomSheetState extends State<WorkerPositionBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<WorkerPositionModel> _filteredPositions = [];
  List<WorkerPositionModel> _allPositions = [];

  @override
  void initState() {
    super.initState();
    context.read<WorkerBloc>().add(const GetWorkerPositionsEvent());
    _searchController.addListener(_filterPositions);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterPositions() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredPositions = _allPositions;
      } else {
        _filteredPositions = _allPositions
            .where((position) => position.name!.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  Future<void> _showAddWorkerPositionSheet({WorkerPositionModel? position}) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddWorkerPositionSheet(position: position),
    );

    if (result == true && mounted) {
      context.read<WorkerBloc>().add(const GetWorkerPositionsEvent());
    }
  }


  Future<void> _showDeleteSheet(WorkerPositionModel position) async {
    HapticFeedback.mediumImpact();
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => DeletePositionConfirmSheet(position: position),
    );

    if (result == true && mounted) {
      context.read<WorkerBloc>().add(DeleteWorkerPositionEvent(positionId: position.id!));
    }
  }

  Future<void> _showRestoreSheet(WorkerPositionModel position) async {
    HapticFeedback.mediumImpact();
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => DeletePositionConfirmSheet(position: position),
    );

    if (result == true && mounted) {
      context.read<WorkerBloc>().add(RestoreWorkerPositionEvent(positionId: position.id!));
    }
  }

  Future<void> _showForceDeleteSheet(WorkerPositionModel position) async {
    HapticFeedback.heavyImpact();
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ForceDeletePositionConfirmSheet(position: position),
    );

    if (result == true && mounted) {
      context.read<WorkerBloc>().add(ForceDeleteWorkerPositionEvent(positionId: position.id!));
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
            if (state.statusPositions == Status.success) {
              setState(() {
                _allPositions = state.positions;
                _filterPositions();
              });
            }
            if (state.statusPositions == Status.error) {
              Toast.showErrorToast(message: state.errorMessage ?? 'Xatolik yuz berdi');
            }
            if (state.statusPositionAction == Status.success) {
              Toast.showSuccessToast(message: 'Muvaffaqiyatli bajarildi');
              context.read<WorkerBloc>().add(const GetWorkerPositionsEvent());
            }
            if (state.statusPositionAction == Status.error) {
              Toast.showErrorToast(message: state.errorMessage ?? 'Xatolik yuz berdi');
            }
          },
          builder: (context, state) {
            return Container(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
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
                        const Expanded(
                          child: Text(
                            'Lavozim tanlash',
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
                              color: AppTheme.colors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.add, color: Colors.white, size: 20),
                          ),
                          onPressed: () => _showAddWorkerPositionSheet(),
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

                  // Positions List
                  Expanded(
                    child: state.statusPositions == Status.loading && _allPositions.isEmpty
                        ? const Center(child: Loading())
                        : _filteredPositions.isEmpty
                            ? _buildEmptyState()
                            : Stack(
                                children: [
                                  ListView.separated(
                                    controller: scrollController,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    itemCount: _filteredPositions.length,
                                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                                    itemBuilder: (context, index) {
                                      final position = _filteredPositions[index];
                                      return Column(
                                        children: [
                                          _buildPositionItem(position),
                                          if (index == _filteredPositions.length - 1) Gap(MediaQuery.of(context).padding.bottom+10)
                                        ],
                                      );
                                    },
                                  ),
                                  if (state.statusPositionAction == Status.loading)
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
      },
    );
  }

  Widget _buildPositionItem(WorkerPositionModel position) {
    final bool isDeleted = position.isDeleted;

    return Slidable(
      key: ValueKey(position.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: isDeleted ? 0.6 : 0.35,
        children: isDeleted
            ? [
                SlidableAction(
                  onPressed: (context) => _showRestoreSheet(position),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  icon: Icons.restore,
                  label: "Tiklash",
                  borderRadius: BorderRadius.circular(12),
                ),
                SlidableAction(
                  onPressed: (context) => _showForceDeleteSheet(position),
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  icon: Icons.delete_forever,
                  label: "Butunlay",
                  borderRadius: BorderRadius.circular(12),
                ),
              ]
            : [
                SlidableAction(
                  onPressed: (context) => _showAddWorkerPositionSheet(position: position),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  icon: Icons.edit,
                  label: "Tahrirlash",
                  borderRadius: BorderRadius.circular(12),
                ),
                SlidableAction(
                  onPressed: (context) => _showDeleteSheet(position),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  icon: Icons.delete_outline,
                  label: "O'chirish",
                  borderRadius: BorderRadius.circular(12),
                ),
              ],

      ),
      child: GestureDetector(
        onTap: isDeleted ? null : () => Navigator.pop(context, position),
        child: Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: isDeleted ? Colors.red.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: isDeleted
                ? Border.all(color: Colors.red.shade300, width: 2)
                : Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: isDeleted
                ? null
                : [
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
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF5B4FFF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.work_outline, color: Color(0xFF5B4FFF), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      position.name ?? '',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDeleted ? Colors.grey : const Color(0xFF1E293B),
                        decoration: isDeleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (position.description != null && position.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        position.description!,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDeleted ? Colors.grey : const Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (position.activity != null && position.activity!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.person_outline_rounded, size: 12, color: AppTheme.colors.primary.withValues(alpha: 0.6)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              position.activity!,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.colors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (!isDeleted)
                const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF64748B)),
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
            decoration: BoxDecoration(
              color: const Color(0xFF5B4FFF).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.work_outline, size: 64, color: Color(0xFF5B4FFF)),
          ),
          const SizedBox(height: 24),
          Text(
            _searchController.text.isEmpty ? 'Lavozimlar mavjud emas' : 'Hech narsa topilmadi',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isEmpty
                ? 'Yangi lavozim yaratish uchun + tugmasini bosing'
                : 'Boshqa kalit so\'z bilan qidirib ko\'ring',
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}