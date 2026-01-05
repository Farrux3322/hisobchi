import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hisobchi/application/project_cost/project_cost_bloc.dart';
import 'package:hisobchi/application/project_cost/project_cost_event.dart';
import 'package:hisobchi/application/project_cost/project_cost_state.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/models/project_cost_model.dart';
import 'package:hisobchi/presentation/assets/res/app_icons.dart';
import 'package:hisobchi/presentation/assets/theme/app_theme.dart';
import 'package:hisobchi/presentation/components/loading/loading.dart';
import 'package:hisobchi/presentation/components/toast/toast.dart';
import 'package:hisobchi/presentation/pages/project/screens/project_cost/project_cost_add_edit_page.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

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
            .where(
              (cost) =>
                  (cost.costTypeName?.toLowerCase().contains(query) ?? false) ||
                  (cost.workerName?.toLowerCase().contains(query) ?? false) ||
                  (cost.description?.toLowerCase().contains(query) ?? false),
            )
            .toList();
      }
    });
  }

  DateTime? _tryParseDate(String? input) {
    if (input == null || input.trim().isEmpty) return null;

    try {
      return DateTime.parse(input);
    } catch (_) {}

    final formats = [DateFormat('dd.MM.yyyy HH:mm:ss'), DateFormat('dd.MM.yyyy HH:mm'), DateFormat('dd.MM.yyyy'), DateFormat('yyyy-MM-dd HH:mm:ss'), DateFormat("yyyy-MM-dd'T'HH:mm:ss")];

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
    HapticFeedback.mediumImpact();
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFBBF24).withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                'Chiqimni o\'chirish',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                'Ushbu chiqimni o\'chirmoqchimisiz?',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Info box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFBBF24).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFFF59E0B),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Keyinchalik qayta tiklash mumkin',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFFE2E8F0), width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Yo\'q',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFFF59E0B),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Ha',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (result == true && mounted) {
      context.read<ProjectCostBloc>().add(DeleteProjectCostEvent(projectCostId: cost.id!));
    }
  }

  Future<void> _showRestoreDialog(ProjectCostModel cost) async {
    HapticFeedback.mediumImpact();
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.restore_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                'Chiqimni tiklash',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                'Ushbu chiqimni tiklashni xohlaysizmi?',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Info box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFF059669),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Chiqim qayta faol holatga qaytadi',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFFE2E8F0), width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Yo\'q',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF10B981),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Ha',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (result == true && mounted) {
      context.read<ProjectCostBloc>().add(RestoreProjectCostEvent(projectCostId: cost.id!));
    }
  }

  Future<void> _showForceDeleteDialog(ProjectCostModel cost) async {
    HapticFeedback.heavyImpact();
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.delete_forever_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                'Butunlay o\'chirish',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                'Ushbu chiqimni butunlay o\'chirmoqchimisiz?',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Warning box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_rounded,
                      color: Color(0xFFDC2626),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Bu amalni ortga qaytarib bo\'lmaydi!',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFFE2E8F0), width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Yo\'q',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFFEF4444),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Ha',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (result == true && mounted) {
      context.read<ProjectCostBloc>().add(ForceDeleteProjectCostEvent(projectCostId: cost.id!));
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
                BoxShadow(color: Color.fromRGBO(255, 255, 255, 0.1), blurRadius: 1, spreadRadius: 0, offset: Offset(0, 1)),
                BoxShadow(color: Color.fromRGBO(50, 50, 93, 0.25), blurRadius: 100, spreadRadius: -20, offset: Offset(0, 50)),
                BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.3), blurRadius: 60, spreadRadius: -30, offset: Offset(0, 30)),
              ],
            ),
            child: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Loyiha chiqimlari',
          style: TextStyle(color: Color(0xFF1E293B), fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(onPressed: _navigateToAddCost, backgroundColor: AppTheme.colors.primary, child: SvgPicture.asset(AppIcons.projectAdd)),

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
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 5),
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
                      ? _buildShimmerLoading()
                      : _filteredCosts.isEmpty
                      ? _buildEmptyState()
                      : Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 6, 16),
                              child: CustomScrollView(slivers: _buildGroupedCosts()),
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
          height: 40,
          color: AppTheme.colors.background,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          alignment: Alignment.centerLeft,
          child: Text(
            DateFormat('dd.MM.yyyy').format(dateKey),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF212529)),
          ),
        ),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final cost = items[index];
            return Padding(padding: const EdgeInsets.only(bottom: 10), child: _buildCostCard(cost));
          }, childCount: items.length),
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
                    onPressed: (context) => _showRestoreDialog(cost),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    icon: Icons.restore,
                    label: "Tiklash",
                    borderRadius: BorderRadius.circular(12),
                  ),
                  SlidableAction(
                    onPressed: (context) => _showForceDeleteDialog(cost),
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
            boxShadow: isDeleted ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(12)),
                child: SvgPicture.asset(AppIcons.chiqim),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cost.costTypeName ?? 'Chiqim turi ko\'rsatilmagan',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDeleted ? Colors.grey : const Color(0xFF1E293B), decoration: isDeleted ? TextDecoration.lineThrough : null),
                    ),
                    const SizedBox(height: 4),
                    Text(cost.workerName ?? 'Ishchi ko\'rsatilmagan', style: TextStyle(color: isDeleted ? Colors.grey : Colors.black54, fontSize: 13)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatCurrency(cost.summa, cost.currencyTypeName),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDeleted ? Colors.grey : const Color(0xFFEF4444)),
                  ),
                  const SizedBox(height: 4),
                  Text(timeText, style: TextStyle(color: isDeleted ? Colors.grey : Colors.black54, fontSize: 12)),
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
            decoration: BoxDecoration(color: AppTheme.colors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: SvgPicture.asset(AppIcons.chiqim, height: 40, width: 40, colorFilter: ColorFilter.mode(AppTheme.colors.primary, BlendMode.srcIn)),
          ),
          const SizedBox(height: 24),
          Text(
            _searchController.text.isEmpty ? 'Chiqimlar mavjud emas' : 'Hech narsa topilmadi',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isEmpty ? 'Yangi chiqim qo\'shish uchun + tugmasini bosing' : 'Boshqa kalit so\'z bilan qidirib ko\'ring',
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 6, 16),
      child: ListView.builder(
        itemCount: 8,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10, right: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Row(
              children: [
                // Icon shimmer
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(width: 12),
                // Text shimmer
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          height: 14,
                          width: 120,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          height: 12,
                          width: 80,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                    ],
                  ),
                ),
                // Time shimmer
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 12,
                    width: 40,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

}
