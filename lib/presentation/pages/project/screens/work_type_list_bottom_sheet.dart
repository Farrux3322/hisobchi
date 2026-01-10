import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/work_type/work_type_bloc.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/models/work_type_model.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/components/loading/loading.dart';
import 'package:hisobchi/presentation/components/toast/toast.dart';
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

  Future<void> _showDeleteDialog(WorkTypeModel workType) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Ishonchingiz komilmi?'),
        content: Text(workType.isDeleted ? 'Ushbu ish turini butunlay o\'chirmoqchimisiz?' : 'Ushbu ish turini o\'chirmoqchimisiz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Bekor qilish')),
          if (workType.isDeleted) ...[
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
        context.read<WorkTypeBloc>().add(DeleteWorkTypeEvent(id: workType.id!));
      } else if (result == 'restore') {
        context.read<WorkTypeBloc>().add(RestoreWorkTypeEvent(id: workType.id!));
      } else if (result == 'force_delete') {
        context.read<WorkTypeBloc>().add(ForceDeleteWorkTypeEvent(id: workType.id!));
      }
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
                            padding:  EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
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
                                    return Column(
                                      children: [
                                        _WorkTypeItem(
                                          workType: workType,
                                          onTap: () {
                                            widget.onSelect(workType);
                                            Navigator.pop(context);
                                          },
                                          onEdit: () => _showEditWorkTypeBottomSheet(workType),
                                          onDelete: () => _showDeleteDialog(workType),
                                        ),
                                        if (index == _filteredList.length - 1) Gap(MediaQuery.of(context).padding.bottom + 10),
                                      ],
                                    );
                                  },
                                ),
                                if (state.statusAdd == Status.loading)
                                  Container(
                                    color: Colors.black.withOpacity(0.3),
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

  const _WorkTypeItem({required this.workType, required this.onTap, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: workType.isDeleted ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: workType.isDeleted ? Colors.grey[100] : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: workType.isDeleted ? Colors.grey[300]! : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: workType.isDeleted ? Colors.grey[300] : AppTheme.colors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.work_outline, color: workType.isDeleted ? Colors.grey : AppTheme.colors.primary, size: 24),
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
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Color(0xFF64748B)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              itemBuilder: (context) => [
                if (!workType.isDeleted)
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 20, color: Color(0xFF64748B)),
                        SizedBox(width: 8),
                        Text('Tahrirlash'),
                      ],
                    ),
                  ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(workType.isDeleted ? Icons.restore : Icons.delete_outline, size: 20, color: workType.isDeleted ? Colors.green : Colors.red),
                      const SizedBox(width: 8),
                      Text(workType.isDeleted ? 'Tiklash/O\'chirish' : 'O\'chirish', style: TextStyle(color: workType.isDeleted ? Colors.green : Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                } else if (value == 'delete') {
                  onDelete();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
