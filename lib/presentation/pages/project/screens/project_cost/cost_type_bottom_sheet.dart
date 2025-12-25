import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gap/gap.dart';
import 'package:hisobchi/application/cost_type/cost_type_bloc.dart';
import 'package:hisobchi/application/cost_type/cost_type_event.dart';
import 'package:hisobchi/application/cost_type/cost_type_state.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/models/cost_type_model.dart';
import 'package:hisobchi/presentation/components/loading/loading.dart';
import 'package:hisobchi/presentation/components/toast/toast.dart';

class CostTypeBottomSheet extends StatefulWidget {
  const CostTypeBottomSheet({super.key});

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
        _filteredCostTypes = _allCostTypes
            .where((costType) => costType.name!.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  Future<void> _showAddCostTypeDialog({CostTypeModel? costType}) async {
    final nameController = TextEditingController(text: costType?.name);
    final descriptionController = TextEditingController(text: costType?.description);
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(costType == null ? 'Yangi chiqim turi' : 'Chiqim turini tahrirlash'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Chiqim turi nomi*',
                  hintText: 'Masalan: Transport xarajatlari',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF5B4FFF), width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nomni kiriting';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Izoh',
                  hintText: 'Qo\'shimcha ma\'lumot',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF5B4FFF), width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B4FFF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(costType == null ? 'Yaratish' : 'Saqlash'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      if (costType == null) {
        context.read<CostTypeBloc>().add(
              CreateCostTypeEvent(
                name: nameController.text.trim(),
                description: descriptionController.text.trim().isEmpty
                    ? null
                    : descriptionController.text.trim(),
              ),
            );
      } else {
        context.read<CostTypeBloc>().add(
              UpdateCostTypeEvent(
                costTypeId: costType.id!,
                name: nameController.text.trim(),
                description: descriptionController.text.trim().isEmpty
                    ? null
                    : descriptionController.text.trim(),
              ),
            );
      }
    }
  }

  Future<void> _showDeleteDialog(CostTypeModel costType) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.delete_outline, color: Colors.red, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'O\'chirish',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        content: Text(
          costType.isDeleted
              ? 'Ushbu chiqim turini butunlay o\'chirmoqchimisiz?'
              : 'Ushbu chiqim turini o\'chirmoqchimisiz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Yo\'q'),
          ),
          if (costType.isDeleted) ...[
            TextButton(
              onPressed: () => Navigator.pop(context, 'restore'),
              child: const Text('Tiklash', style: TextStyle(color: Colors.green)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, 'force_delete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Butunlay o\'chirish'),
            ),
          ] else
            ElevatedButton(
              onPressed: () => Navigator.pop(context, 'delete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('O\'chirish'),
            ),
        ],
      ),
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
          height: MediaQuery.of(context).size.height * 0.8,
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
                        'Chiqim turi tanlash',
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
                      onPressed: () => _showAddCostTypeDialog(),
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

              // Cost Types List
              Expanded(
                child: state.status == Status.loading && _allCostTypes.isEmpty
                    ? const Center(child: Loading())
                    : _filteredCostTypes.isEmpty
                        ? _buildEmptyState()
                        : Stack(
                            children: [
                              ListView.separated(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _filteredCostTypes.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final costType = _filteredCostTypes[index];
                                  return Column(
                                    children: [
                                      _buildCostTypeItem(costType),
                                      if(index==_filteredCostTypes.length-1)Gap(MediaQuery.of(context).padding.bottom+10)
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
            ],
          ),
        );
      },
    );
  }

  Widget _buildCostTypeItem(CostTypeModel costType) {
    final bool isDeleted = costType.isDeleted;

    return Slidable(
      key: ValueKey(costType.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: isDeleted ? 0.6 : 0.5,
        children: isDeleted
            ? [
                SlidableAction(
                  onPressed: (context) => _showDeleteDialog(costType),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  icon: Icons.restore,
                  label: "Tiklash",
                  borderRadius: BorderRadius.circular(12),
                ),
                SlidableAction(
                  onPressed: (context) => _showDeleteDialog(costType),
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  icon: Icons.delete_forever,
                  label: "Butunlay",
                  borderRadius: BorderRadius.circular(12),
                ),
              ]
            : [
                SlidableAction(
                  onPressed: (context) => _showAddCostTypeDialog(costType: costType),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  icon: Icons.edit,
                  label: "Tahrirlash",
                  borderRadius: BorderRadius.circular(12),
                ),
                SlidableAction(
                  onPressed: (context) => _showDeleteDialog(costType),
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
                child: const Icon(Icons.category_outlined, color: Color(0xFF5B4FFF), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      costType.name ?? '',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDeleted ? Colors.grey : const Color(0xFF1E293B),
                        decoration: isDeleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (costType.description != null && costType.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        costType.description!,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDeleted ? Colors.grey : const Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
            child: const Icon(Icons.category_outlined, size: 64, color: Color(0xFF5B4FFF)),
          ),
          const SizedBox(height: 24),
          Text(
            _searchController.text.isEmpty ? 'Chiqim turlari mavjud emas' : 'Hech narsa topilmadi',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isEmpty
                ? 'Yangi chiqim turi yaratish uchun + tugmasini bosing'
                : 'Boshqa kalit so\'z bilan qidirib ko\'ring',
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}