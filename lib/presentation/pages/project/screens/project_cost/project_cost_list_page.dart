import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:hisobchi/application/project_cost/project_cost_bloc.dart';
import 'package:hisobchi/application/project_cost/project_cost_event.dart';
import 'package:hisobchi/application/project_cost/project_cost_state.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/models/project_cost_model.dart';
import 'package:hisobchi/presentation/components/loading/loading.dart';
import 'package:hisobchi/presentation/components/toast/toast.dart';
import 'package:hisobchi/presentation/pages/project/screens/project_cost/project_cost_add_edit_page.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

class ProjectCostListPage extends StatefulWidget {
  final int projectId;

  const ProjectCostListPage({super.key, required this.projectId});

  @override
  State<ProjectCostListPage> createState() => _ProjectCostListPageState();
}

class _ProjectCostListPageState extends State<ProjectCostListPage> {
  final TextEditingController _searchController = TextEditingController();
  List<ProjectCostModel> _filteredCosts = [];
  List<ProjectCostModel> _allCosts = [];

  @override
  void initState() {
    super.initState();
    _loadCosts();
    _searchController.addListener(_filterCosts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadCosts() {
    context.read<ProjectCostBloc>().add(GetProjectCostsEvent(projectId: widget.projectId));
  }

  void _filterCosts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCosts = _allCosts;
      } else {
        _filteredCosts = _allCosts
            .where((cost) =>
                (cost.costTypeName?.toLowerCase().contains(query) ?? false) ||
                (cost.workerName?.toLowerCase().contains(query) ?? false) ||
                (cost.description?.toLowerCase().contains(query) ?? false))
            .toList();
      }
    });
  }

  DateTime? _tryParseDate(String? input) {
    if (input == null || input.trim().isEmpty) return null;

    try {
      return DateTime.parse(input);
    } catch (_) {}

    final formats = [
      DateFormat('dd.MM.yyyy HH:mm:ss'),
      DateFormat('dd.MM.yyyy HH:mm'),
      DateFormat('dd.MM.yyyy'),
      DateFormat('yyyy-MM-dd HH:mm:ss'),
      DateFormat("yyyy-MM-dd'T'HH:mm:ss")
    ];

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

  String _formatCurrency(String? amount, String? currency) {
    if (amount == null) return '0';
    try {
      final number = double.parse(amount);
      final formatter = NumberFormat('#,##0.##', 'uz');
      return '${formatter.format(number)} ${currency ?? ''}';
    } catch (e) {
      return '$amount ${currency ?? ''}';
    }
  }

  Future<void> _navigateToAddCost() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<ProjectCostBloc>(),
          child: ProjectCostAddEditPage(projectId: widget.projectId),
        ),
      ),
    );

    if (result == true && mounted) {
      _loadCosts();
    }
  }

  Future<void> _navigateToEditCost(ProjectCostModel cost) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<ProjectCostBloc>(),
          child: ProjectCostAddEditPage(projectId: widget.projectId, cost: cost),
        ),
      ),
    );

    if (result == true && mounted) {
      _loadCosts();
    }
  }

  Future<void> _showDeleteDialog(ProjectCostModel cost) async {
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
          cost.isDeleted
              ? 'Ushbu chiqimni butunlay o\'chirmoqchimisiz?'
              : 'Ushbu chiqimni o\'chirmoqchimisiz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Yo\'q'),
          ),
          if (cost.isDeleted) ...[
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
        context.read<ProjectCostBloc>().add(DeleteProjectCostEvent(projectCostId: cost.id!));
      } else if (result == 'restore') {
        context.read<ProjectCostBloc>().add(RestoreProjectCostEvent(projectCostId: cost.id!));
      } else if (result == 'force_delete') {
        context.read<ProjectCostBloc>().add(ForceDeleteProjectCostEvent(projectCostId: cost.id!));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(255, 255, 255, 0.1),
                  blurRadius: 1,
                  spreadRadius: 0,
                  offset: Offset(0, 1),
                ),
                BoxShadow(
                  color: Color.fromRGBO(50, 50, 93, 0.25),
                  blurRadius: 100,
                  spreadRadius: -20,
                  offset: Offset(0, 50),
                ),
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.3),
                  blurRadius: 60,
                  spreadRadius: -30,
                  offset: Offset(0, 30),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Loyiha chiqimlari',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5B4FFF), Color(0xFF7C3AED)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5B4FFF).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
            onPressed: _navigateToAddCost,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: BlocConsumer<ProjectCostBloc, ProjectCostState>(
        listener: (context, state) {
          if (state.statusAction == Status.success) {
            Toast.showSuccessToast(message: 'Muvaffaqiyatli bajarildi');
            _loadCosts();
          } else if (state.statusAction == Status.error) {
            Toast.showErrorToast(message: state.errorMessage ?? 'Xatolik yuz berdi');
          }

          if (state.status == Status.success) {
            setState(() {
              _allCosts = state.projectCosts;
              _filterCosts();
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
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
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

                // Costs List
                Expanded(
                  child: state.status == Status.loading && _allCosts.isEmpty
                      ? const Center(child: Loading())
                      : _filteredCosts.isEmpty
                          ? _buildEmptyState()
                          : Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 12, 6, 16),
                                  child: CustomScrollView(
                                    slivers: _buildGroupedCosts(),
                                  ),
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

  List<Widget> _buildGroupedCosts() {
    final groupedData = groupBy<ProjectCostModel, DateTime>(_filteredCosts, (cost) {
      final parsed = _tryParseDate(cost.createdAt);
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
          height: 50,
          color: const Color(0xFFF5F5F5),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          alignment: Alignment.centerLeft,
          child: Text(
            DateFormat('dd.MM.yyyy').format(dateKey),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF212529)),
          ),
        ),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final cost = items[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildCostCard(cost),
              );
            },
            childCount: items.length,
          ),
        ),
      );
    }).toList();
  }

  Widget _buildCostCard(ProjectCostModel cost) {
    final String timeText = _formatTimeOnly(cost.createdAt);
    final bool isDeleted = cost.isDeleted;

    return GestureDetector(
      onTap: isDeleted ? null : () => _navigateToEditCost(cost),
      child: Slidable(
        key: ValueKey(cost.id),

        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: isDeleted ? 0.6 : 0.55,
          children: isDeleted
              ? [
                  SlidableAction(
                    onPressed: (context) => _showDeleteDialog(cost),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    icon: Icons.restore,
                    label: "Tiklash",
                    borderRadius: BorderRadius.circular(12),
                  ),
                  SlidableAction(
                    onPressed: (context) => _showDeleteDialog(cost),
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    icon: Icons.delete_forever,
                    label: "Butunlay",
                    borderRadius: BorderRadius.circular(12),
                  ),
                ]
              : [
                  SlidableAction(
                    onPressed: (context) => _navigateToEditCost(cost),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    icon: Icons.edit_outlined,
                    label: "Tahrirlash",
                    borderRadius: BorderRadius.circular(12),
                  ),
                  SlidableAction(
                    onPressed: (context) => _showDeleteDialog(cost),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.delete_outline,
                    label: "O'chirish",
                    borderRadius: BorderRadius.circular(12),
                  ),
                ],
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: isDeleted ? Colors.red.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: isDeleted ? Border.all(color: Colors.red.shade300, width: 2) : null,
            boxShadow: isDeleted
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
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
                  color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.money_off_outlined, color: Color(0xFFEF4444), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cost.costTypeName ?? 'Chiqim turi ko\'rsatilmagan',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDeleted ? Colors.grey : const Color(0xFF1E293B),
                        decoration: isDeleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cost.workerName ?? 'Ishchi ko\'rsatilmagan',
                      style: TextStyle(
                        color: isDeleted ? Colors.grey : Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatCurrency(cost.summa, cost.currencyTypeName),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDeleted ? Colors.grey : const Color(0xFFEF4444),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeText,
                    style: TextStyle(
                      color: isDeleted ? Colors.grey : Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
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
              color: const Color(0xFFEF4444).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.money_off_outlined, size: 64, color: Color(0xFFEF4444)),
          ),
          const SizedBox(height: 24),
          Text(
            _searchController.text.isEmpty ? 'Chiqimlar mavjud emas' : 'Hech narsa topilmadi',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isEmpty
                ? 'Yangi chiqim qo\'shish uchun + tugmasini bosing'
                : 'Boshqa kalit so\'z bilan qidirib ko\'ring',
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}