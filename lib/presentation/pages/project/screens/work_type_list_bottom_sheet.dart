import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gap/gap.dart';
import 'package:hisobchi/application/work_type/work_type_bloc.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/models/work_type_model.dart';
import 'package:hisobchi/presentation/assets/theme/app_theme.dart';
import 'package:hisobchi/presentation/components/loading/loading.dart';
import 'package:hisobchi/presentation/components/toast/toast.dart';
import 'package:hisobchi/presentation/pages/client/components/history_dialogs.dart';
import 'package:hisobchi/presentation/pages/project/screens/work_type_add_edit_bottom_sheet.dart';

class WorkTypeListBottomSheet extends StatefulWidget {
  final Function(WorkTypeModel) onSelect;

  const WorkTypeListBottomSheet({super.key, required this.onSelect});

  @override
  State<WorkTypeListBottomSheet> createState() => _WorkTypeListBottomSheetState();
}

class _WorkTypeListBottomSheetState extends State<WorkTypeListBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<WorkTypeModel> _filteredList = [];
  List<WorkTypeModel> _allWorkTypes = [];

  @override
  void initState() {
    super.initState();
    context.read<WorkTypeBloc>().add(const GetAllWorkTypesEvent());
    _searchController.addListener(_filterWorkTypes);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterWorkTypes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredList = _allWorkTypes;
      } else {
        _filteredList = _allWorkTypes.where((workType) => workType.name!.toLowerCase().contains(query) || (workType.description?.toLowerCase().contains(query) ?? false)).toList();
      }
    });
  }

  Future<void> _showAddWorkTypeBottomSheet() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) => BlocProvider.value(value: context.read<WorkTypeBloc>(), child: const WorkTypeAddEditBottomSheet()),
    );

    if (result == true && mounted) {
      context.read<WorkTypeBloc>().add(const GetAllWorkTypesEvent());
    }
  }

  Future<void> _showEditWorkTypeBottomSheet(WorkTypeModel workType) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) => BlocProvider.value(
        value: context.read<WorkTypeBloc>(),
        child: WorkTypeAddEditBottomSheet(workType: workType),
      ),
    );

    if (result == true && mounted) {
      context.read<WorkTypeBloc>().add(const GetAllWorkTypesEvent());
    }
  }

  Future<void> _onDelete(WorkTypeModel workType) async {
    final confirm = await HistoryDialogs.showDeleteConfirmDialog(context);
    if (confirm == true && mounted) {
      context.read<WorkTypeBloc>().add(DeleteWorkTypeEvent(id: workType.id!));
    }
  }

  Future<void> _onRestore(WorkTypeModel workType) async {
    final confirm = await HistoryDialogs.showRestoreConfirmDialog(context);
    if (confirm == true && mounted) {
      context.read<WorkTypeBloc>().add(RestoreWorkTypeEvent(id: workType.id!));
    }
  }

  Future<void> _onForceDelete(WorkTypeModel workType) async {
    final confirm = await HistoryDialogs.showForceDeleteConfirmDialog(context);
    if (confirm == true && mounted) {
      context.read<WorkTypeBloc>().add(ForceDeleteWorkTypeEvent(id: workType.id!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: BlocConsumer<WorkTypeBloc, WorkTypeState>(
              listener: (context, state) {
                if (state.status == Status.success) {
                  _allWorkTypes = state.models;
                  _filterWorkTypes();
                }
                if (state.status == Status.error) {
                  Toast.showErrorToast(message: state.errorMessage ?? 'Xatolik yuz berdi');
                }
                if (state.statusAdd == Status.success) {
                  Toast.showSuccessToast(message: 'Muvaffaqiyatli bajarildi');
                  context.read<WorkTypeBloc>().add(const GetAllWorkTypesEvent());
                }
                if (state.statusAdd == Status.error) {
                  Toast.showErrorToast(message: state.errorMessage ?? 'Xatolik yuz berdi');
                }
              },
              builder: (context, state) {
                return Column(
                  children: [
                    const SizedBox(height: 12),
                    // Handle
                    Container(
                      width: 62,
                      height: 8,
                      decoration: BoxDecoration(color: AppTheme.colors.primary, borderRadius: BorderRadius.circular(10)),
                    ),
                    const SizedBox(height: 16),

                    // Header with Add button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Ish turini tanlang',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                          ),
                          IconButton(
                            onPressed: _showAddWorkTypeBottomSheet,
                            icon: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(color: AppTheme.colors.primary, borderRadius: BorderRadius.circular(6)),
                              child: const Icon(Icons.add, color: Colors.white, size: 24),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Search field
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Qidirish...',
                          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                          prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
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
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // List
                    Expanded(
                      child: state.status == Status.loading && _allWorkTypes.isEmpty
                          ? const Center(child: Loading())
                          : _filteredList.isEmpty
                              ? Padding(
                                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.work_outlined, size: 64, color: AppTheme.colors.primary),
                                        const SizedBox(height: 16),
                                        Text(_searchController.text.isEmpty ? 'Ish turlari mavjud emas' : 'Hech narsa topilmadi', style: TextStyle(fontSize: 16, color: AppTheme.colors.primary)),
                                      ],
                                    ),
                                  ),
                                )
                              : Stack(
                                  children: [
                                    ListView.separated(
                                      controller: scrollController,
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                      itemCount: _filteredList.length,
                                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                                      itemBuilder: (context, index) {
                                        final workType = _filteredList[index];
                                        return _WorkTypeItem(
                                          workType: workType,
                                          onTap: () {
                                            widget.onSelect(workType);
                                            Navigator.pop(context);
                                          },
                                          onEdit: () => _showEditWorkTypeBottomSheet(workType),
                                          onDelete: () => _onDelete(workType),
                                          onRestore: () => _onRestore(workType),
                                          onForceDelete: () => _onForceDelete(workType),
                                        );
                                      },
                                    ),
                                    if (state.statusAdd == Status.loading)
                                      Container(
                                        color: Colors.black.withValues(alpha: 0.3),
                                        child: const Center(child: Loading()),
                                      ),
                                  ],
                                ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _WorkTypeItem extends StatelessWidget {
  final WorkTypeModel workType;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onRestore;
  final VoidCallback onForceDelete;

  const _WorkTypeItem({
    required this.workType,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onRestore,
    required this.onForceDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(workType.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          if (workType.isDeleted) ...[
            SlidableAction(
              onPressed: (_) => onRestore(),
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              icon: Icons.restore,
              label: 'Tiklash',
              borderRadius: BorderRadius.only(topLeft: Radius.circular(12.r), bottomLeft: Radius.circular(12.r)),
            ),
            SlidableAction(
              onPressed: (_) => onForceDelete(),
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              icon: Icons.delete_forever,
              label: 'O\'chirish',
              borderRadius: BorderRadius.only(topRight: Radius.circular(12.r), bottomRight: Radius.circular(12.r)),
            ),
          ] else ...[
            SlidableAction(
              onPressed: (_) => onEdit(),
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Tahrirlash',
              borderRadius: BorderRadius.only(topLeft: Radius.circular(12.r), bottomLeft: Radius.circular(12.r)),
            ),
            SlidableAction(
              onPressed: (_) => onDelete(),
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              icon: Icons.delete_outline,
              label: 'O\'chirish',
              borderRadius: BorderRadius.only(topRight: Radius.circular(12.r), bottomRight: Radius.circular(12.r)),
            ),
          ],
        ],
      ),
      child: InkWell(
        onTap: workType.isDeleted ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: workType.isDeleted ? Colors.grey[100] : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: workType.isDeleted ? Colors.grey[300]! : const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: workType.isDeleted ? Colors.grey[300] : AppTheme.colors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.work_outline, color: workType.isDeleted ? Colors.grey : AppTheme.colors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workType.name ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: workType.isDeleted ? Colors.grey : const Color(0xFF1E293B),
                        decoration: workType.isDeleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (workType.description != null && workType.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        workType.description!,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (workType.isDeleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Text('O\'chirilgan', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                )
              else
                Icon(Icons.arrow_forward_ios_rounded, color: const Color(0xFFCBD5E1), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

