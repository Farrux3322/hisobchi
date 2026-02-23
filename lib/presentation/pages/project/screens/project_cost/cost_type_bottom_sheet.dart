import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gap/gap.dart';
import 'package:hisobchi/application/cost_type/cost_type_bloc.dart';
import 'package:hisobchi/application/cost_type/cost_type_event.dart';
import 'package:hisobchi/application/cost_type/cost_type_state.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/models/cost_type_model.dart';
import 'package:hisobchi/presentation/assets/theme/app_theme.dart';
import 'package:hisobchi/presentation/pages/project/screens/project_cost/widgets/add_cost_type_sheet.dart';
import 'package:hisobchi/presentation/pages/project/screens/project_cost/widgets/delete_confirm_sheet.dart';
import 'package:hisobchi/presentation/components/loading/loading.dart';

import '../../../../components/toast/toast.dart';

class CostTypeBottomSheet extends StatefulWidget {
  const CostTypeBottomSheet({super.key, required this.isCreate});

  final bool isCreate;

  @override
  State<CostTypeBottomSheet> createState() => _CostTypeBottomSheetState();
}

class _CostTypeBottomSheetState extends State<CostTypeBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<CostTypeModel> _filteredCostTypes = [];
  List<CostTypeModel> _allCostTypes = [];

  @override
  void initState() {
    super.initState();
    context.read<CostTypeBloc>().add(GetCostTypesEvent());
    _searchController.addListener(_filterCostTypes);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCostTypes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCostTypes = _allCostTypes;
      } else {
        _filteredCostTypes = _allCostTypes.where((costType) => costType.name!.toLowerCase().contains(query)).toList();
      }
    });
  }

  Future<void> _showAddCostTypeSheet({CostTypeModel? costType}) async {
    // Check if update is allowed
    if (costType != null && costType.isUpdateAndDelete == false) {
      Toast.showErrorToast(message: 'Ushbu chiqim turini tahrirlash mumkin emas');
      return;
    }

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddCostTypeSheet(costType: costType),
    );

    if (result != null && mounted) {
      final String name = result['name'];
      final String? description = result['description'];

      if (costType == null) {
        context.read<CostTypeBloc>().add(CreateCostTypeEvent(name: name, description: description));
      } else {
        context.read<CostTypeBloc>().add(
          UpdateCostTypeEvent(costTypeId: costType.id!, name: name, description: description),
        );
      }
    }
  }

  Future<void> _showDeleteSheet(CostTypeModel costType) async {
    // Check if delete is allowed
    if (costType.isUpdateAndDelete == false) {
      Toast.showErrorToast(message: 'Ushbu chiqim turini o\'chirish mumkin emas');
      return;
    }

    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => DeleteConfirmSheet(costType: costType),
    );

    if (result != null && mounted) {
      if (result == 'delete') {
        context.read<CostTypeBloc>().add(DeleteCostTypeEvent(costTypeId: costType.id!));
      } else if (result == 'restore') {
        context.read<CostTypeBloc>().add(RestoreCostTypeEvent(costTypeId: costType.id!));
      } else if (result == 'force_delete') {
        context.read<CostTypeBloc>().add(ForceDeleteCostTypeEvent(costTypeId: costType.id!));
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
        return BlocConsumer<CostTypeBloc, CostTypeState>(
          listener: (context, state) {
            if (state.status == Status.success) {
              setState(() {
                _allCostTypes = state.costTypes;
                _filterCostTypes();
              });
            }
            if (state.status == Status.error) {
              Toast.showErrorToast(message: state.errorMessage ?? 'Xatolik yuz berdi');
            }
            if (state.statusAction == Status.success) {
              Toast.showSuccessToast(message: 'Muvaffaqiyatli bajarildi');
              context.read<CostTypeBloc>().add(GetCostTypesEvent());
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
                        const Expanded(
                          child: Text(
                            'Chiqim turi tanlash',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if(widget.isCreate)IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: AppTheme.colors.primary, borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.add, color: Colors.white, size: 20),
                          ),
                          onPressed: () => _showAddCostTypeSheet(),
                        ),
                        if(!widget.isCreate)Gap(26)
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
                          borderSide: const BorderSide(color: Color(0xFF5B4FFF), width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),

                  // Cost Types List
                  Expanded(
                    child: state.status == Status.loading && _allCostTypes.isEmpty
                        ? const Center(child: Loading())
                        : _filteredCostTypes.isEmpty
                        ? _buildEmptyState()
                        : Stack(
                            children: [
                              ListView.separated(
                                controller: scrollController,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _filteredCostTypes.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final costType = _filteredCostTypes[index];
                                  return Column(children: [_buildCostTypeItem(costType), if (index == _filteredCostTypes.length - 1) Gap(MediaQuery.of(context).padding.bottom + 10)]);
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
      },
    );
  }

  Widget _buildCostTypeItem(CostTypeModel costType) {
    final bool isDeleted = costType.isDeleted;
    final bool canUpdateDelete = costType.isUpdateAndDelete ?? true;

    return Slidable(
      key: ValueKey(costType.id),
      // enabled: canUpdateDelete, // Disable sliding if cannot update/delete
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: isDeleted ? 0.6 : 0.5,
        children: isDeleted
            ? [
                SlidableAction(
                  onPressed: (context) => _showDeleteSheet(costType),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  icon: Icons.restore,
                  label: "Tiklash",
                  borderRadius: BorderRadius.circular(12),
                ),
                SlidableAction(
                  onPressed: (context) => _showDeleteSheet(costType),
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  icon: Icons.delete_forever,
                  label: "Butunlay",
                  borderRadius: BorderRadius.circular(12),
                ),
              ]
            : [
                SlidableAction(
                  onPressed: (context) => _showAddCostTypeSheet(costType: costType),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  icon: Icons.edit,
                  label: "Tahrirlash",
                  borderRadius: BorderRadius.circular(12),
                ),
                SlidableAction(
                  onPressed: (context) => _showDeleteSheet(costType),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  icon: Icons.delete_outline,
                  label: "O'chirish",
                  borderRadius: BorderRadius.circular(12),
                ),
              ],
      ),
      child: GestureDetector(
        onTap: isDeleted ? null : () => Navigator.pop(context, costType),
        child: Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: isDeleted ? Colors.red.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: isDeleted ? Border.all(color: Colors.red.shade300, width: 2) : Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: isDeleted ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      costType.name ?? '',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDeleted ? Colors.grey : const Color(0xFF1E293B), decoration: isDeleted ? TextDecoration.lineThrough : null),
                    ),
                    if (costType.description != null && costType.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        costType.description!,
                        style: TextStyle(fontSize: 13, color: isDeleted ? Colors.grey : const Color(0xFF64748B)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (!isDeleted) const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF64748B)),
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
            child: const Icon(Icons.category_outlined, size: 64, color: Color(0xFF5B4FFF)),
          ),
          const SizedBox(height: 24),
          Text(
            _searchController.text.isEmpty ? 'Chiqim turlari mavjud emas' : 'Hech narsa topilmadi',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isEmpty ? 'Yangi chiqim turi yaratish uchun + tugmasini bosing' : 'Boshqa kalit so\'z bilan qidirib ko\'ring',
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
