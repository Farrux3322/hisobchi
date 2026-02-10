import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:hisobchi/application/cost_type/cost_type_bloc.dart';
import 'package:hisobchi/application/project_cost/project_cost_bloc.dart';
import 'package:hisobchi/application/project_cost/project_cost_event.dart';
import 'package:hisobchi/application/project_cost/project_cost_state.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/models/cost_type_model.dart';
import 'package:hisobchi/infrastructure/models/project_cost_model.dart';
import 'package:hisobchi/presentation/components/basic_widgets.dart';
import 'package:hisobchi/presentation/components/loading/loading.dart';
import 'package:hisobchi/presentation/components/toast/toast.dart';
import 'package:hisobchi/presentation/pages/project/screens/project_cost/cost_type_bottom_sheet.dart';
import 'package:hisobchi/infrastructure/dto/models/project_report/project_cost_detail_item_model.dart';
import 'package:hisobchi/presentation/pages/project/screens/project_cost/project_cost_add_edit_page.dart';
import 'package:hisobchi/presentation/pages/project/screens/report/project_cost_document_show_page.dart';
import 'package:hisobchi/presentation/components/subscription/subscription_guard.dart';
import 'package:collection/collection.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../assets/asset_index.dart';

/// Result object returned when navigating back from ProjectCostListPage
/// Indicates whether transactions were modified
class ProjectCostListResult {
  final bool hasChanges;

  const ProjectCostListResult({required this.hasChanges});

  /// Factory for when transactions were modified
  factory ProjectCostListResult.modified() => const ProjectCostListResult(hasChanges: true);

  /// Factory for when no changes were made
  factory ProjectCostListResult.noChanges() => const ProjectCostListResult(hasChanges: false);
}

class ProjectCostListPage extends StatefulWidget {
  final int projectId;
  final int? costTypeId;
  final String? costTypeName;

  const ProjectCostListPage({super.key, required this.projectId, this.costTypeId, this.costTypeName});

  @override
  State<ProjectCostListPage> createState() => _ProjectCostListPageState();
}

class _ProjectCostListPageState extends State<ProjectCostListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ProjectCostModel> _filteredCosts = [];
  List<ProjectCostModel> _allCosts = [];
  int? _selectedCostTypeId;
  String? _selectedCostTypeName;

  /// Tracks whether any changes were made (add/edit/delete/restore transactions)
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    // Initialize filters from constructor parameters
    if (widget.costTypeId != null) {
      _selectedCostTypeId = widget.costTypeId;
      _selectedCostTypeName = widget.costTypeName;
    }
    _loadCosts();
    _searchController.addListener(_filterCosts);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<ProjectCostBloc>().add(
            LoadMoreProjectCostsEvent(
              projectId: widget.projectId,
              costTypeId: _selectedCostTypeId,
              search: _searchController.text,
            ),
          );
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadCosts() {
    context.read<ProjectCostBloc>().add(GetProjectCostsEvent(projectId: widget.projectId, costTypeId: _selectedCostTypeId));
  }

  Future<void> _showFilterBottomSheet() async {
    final result = await showModalBottomSheet<CostTypeModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(value: context.read<CostTypeBloc>(), child:  CostTypeBottomSheet(isCreate: false,)),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedCostTypeId = result.id;
        _selectedCostTypeName = result.name;
      });
      _loadCosts();
    }
  }

  void _clearFilter() {
    setState(() {
      _selectedCostTypeId = null;
      _selectedCostTypeName = null;
    });
    _loadCosts();
  }

  /// Mark that changes were made - parent should refresh when going back
  void _markAsChanged() {
    _hasChanges = true;
  }

  void _onSearch(String query) {
    context.read<ProjectCostBloc>().add(GetProjectCostsEvent(projectId: widget.projectId, costTypeId: _selectedCostTypeId, search: query));
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
      _markAsChanged();
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
      _markAsChanged();
      _loadCosts();
    }
  }

  void _navigateToDetails(ProjectCostModel cost) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectCostDocumentShowPage(
          cost: _convertToDetailItem(cost),
        ),
      ),
    );
  }

  ProjectCostDetailItemModel _convertToDetailItem(ProjectCostModel cost) {
    return ProjectCostDetailItemModel(
      id: cost.id,
      costTypeId: cost.costTypeId,
      costTypeName: cost.costTypeName,
      workerId: cost.workerId,
      workerName: cost.workerName,
      currencyTypeId: cost.currencyTypeId,
      currencyType: cost.currencyTypeName,
      summa: double.tryParse(cost.summa ?? '0'),
      description: cost.description,
      files: cost.files?.map((f) => f.url ?? '').where((u) => u.isNotEmpty).toList() ?? [],
      projectId: cost.projectId,
      createdAt: cost.createdAt,
    );
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
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: const Color(0xFFFBBF24).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                'Chiqimni o\'chirish',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                'Ushbu chiqimni o\'chirmoqchimisiz?',
                style: TextStyle(fontSize: 15, color: Colors.grey[600], height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Info box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFBBF24).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Color(0xFFF59E0B), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Keyinchalik qayta tiklash mumkin',
                        style: TextStyle(fontSize: 13, color: Colors.grey[800], fontWeight: FontWeight.w500),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Yo\'q',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Ha',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
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
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: const Color(0xFF10B981).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: const Icon(Icons.restore_rounded, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                'Chiqimni tiklash',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                'Ushbu chiqimni tiklashni xohlaysizmi?',
                style: TextStyle(fontSize: 15, color: Colors.grey[600], height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Info box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Color(0xFF059669), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Chiqim qayta faol holatga qaytadi',
                        style: TextStyle(fontSize: 13, color: Colors.grey[800], fontWeight: FontWeight.w500),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Yo\'q',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Ha',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
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
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: const Color(0xFFEF4444).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: const Icon(Icons.delete_forever_rounded, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                'Butunlay o\'chirish',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                'Ushbu chiqimni butunlay o\'chirmoqchimisiz?',
                style: TextStyle(fontSize: 15, color: Colors.grey[600], height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Warning box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_rounded, color: Color(0xFFDC2626), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Bu amalni ortga qaytarib bo\'lmaydi!',
                        style: TextStyle(fontSize: 13, color: Colors.grey[800], fontWeight: FontWeight.w500),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Yo\'q',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Ha',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
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
    return DeFocus(
      child: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            final navResult = _hasChanges ? ProjectCostListResult.modified() : ProjectCostListResult.noChanges();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            leading: Center(
              child: InkWell(
                onTap: () {
                  final result = _hasChanges ? ProjectCostListResult.modified() : ProjectCostListResult.noChanges();
                  Navigator.of(context).pop(result);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 18),
                ),
              ),
            ),
            title: const Text(
              'Loyiha chiqimlari',
            ),
            centerTitle: true,
          ),
          floatingActionButton: Padding(
            padding:  EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
            child: SubscriptionGuard(
              child: FloatingActionButton(
              heroTag: 'project_cost_fab',
              onPressed: _navigateToAddCost,
              backgroundColor: AppTheme.colors.primary,
              child: SvgPicture.asset(AppIcons.projectAdd),
            ),
            ),
          ),
          body: BlocConsumer<ProjectCostBloc, ProjectCostState>(
            listener: (context, state) {
              if (state.statusAction == Status.success) {
                Toast.showSuccessToast(message: 'Muvaffaqiyatli bajarildi');
                _markAsChanged();
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
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          _onSearch(value);
                        },
                        decoration: InputDecoration(
                          hintText: 'Qidirish...',
                          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(left: 8, right: 4),
                            child: Icon(Icons.search, color: Color(0xFF64748B), size: 20),
                          ),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: IconButton(
                              onPressed: _showFilterBottomSheet,
                              icon: Icon(Icons.filter_list_rounded, color: _selectedCostTypeId != null ? AppTheme.colors.primary : const Color(0xFF64748B), size: 24),
                            ),
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

                    // Filter Chip
                    if (_selectedCostTypeName != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.centerLeft,
                        child: Chip(
                          avatar: Icon(Icons.filter_alt, size: 18, color: AppTheme.colors.primary),
                          label: Text(
                            _selectedCostTypeName!,
                            style: TextStyle(color: AppTheme.colors.primary, fontWeight: FontWeight.w500, fontSize: 13),
                          ),
                          deleteIcon: Icon(Icons.close, size: 18, color: AppTheme.colors.primary),
                          onDeleted: _clearFilter,
                          backgroundColor: AppTheme.colors.primary.withValues(alpha: 0.1),
                          side: BorderSide(color: AppTheme.colors.primary.withValues(alpha: 0.3), width: 1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        ),
                      ),

                    // Costs List
                    Expanded(
                      child: state.status == Status.loading && _allCosts.isEmpty
                          ? _buildShimmerLoading()
                          : _filteredCosts.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: () async {
                                _loadCosts();
                              },
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(16, 0, 6, 16),
                                    child: CustomScrollView(
                                      controller: _scrollController,
                                      slivers: _buildGroupedCosts(state),
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
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _buildGroupedCosts(ProjectCostState state) {
    final groupedData = groupBy<ProjectCostModel, DateTime>(_filteredCosts, (cost) {
      final parsed = _tryParseDate(cost.createdAt);
      if (parsed == null) {
        return DateTime(1970);
      }
      return _toDateOnly(parsed);
    });

    final List<Widget> slivers = [];

    groupedData.forEach((dateKey, items) {
      slivers.add(
        SliverStickyHeader(
          header: Container(
            height: 45.h,
            color: AppTheme.colors.background,
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
        ),
      );
    });

    if (!state.hasReachedMax) {
      slivers.add(
        SliverToBoxAdapter(
          child: _buildLoadMoreIndicator(),
        ),
      );
    }

    return slivers;
  }

  Widget _buildLoadMoreIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
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

  Widget _buildCostCard(ProjectCostModel cost) {
    final String timeText = _formatTimeOnly(cost.createdAt);
    final bool isDeleted = cost.isDeleted;

    return SubscriptionGuard(
      child: GestureDetector(
        onTap: isDeleted ? null : () => _navigateToDetails(cost),
        child: Slidable(
        key: ValueKey(cost.id),

        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: isDeleted ? 0.6 : 0.55,
          children: isDeleted
              ? [
                  CustomSlidableAction(
                    onPressed: (context) => _showRestoreDialog(cost),
                    backgroundColor: Colors.transparent,
                    foregroundColor: const Color(0xFF10B981),
                    padding: EdgeInsets.zero,
                    child: SubscriptionGuard(
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 4.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.undo_rounded, size: 22.sp),
                              Gap(4.h),
                              Text(
                                "Tiklash",
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  CustomSlidableAction(
                    onPressed: (context) => _showForceDeleteDialog(cost),
                    backgroundColor: Colors.transparent,
                    foregroundColor: const Color(0xFFE11D48),
                    padding: EdgeInsets.zero,
                    child: SubscriptionGuard(
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 4.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE11D48).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.delete_forever_rounded, size: 22.sp),
                              Gap(4.h),
                              Text(
                                "Butunlay",
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ]
              : [
                  CustomSlidableAction(
                    onPressed: (context) => _navigateToEditCost(cost),
                    backgroundColor: Colors.transparent,
                    foregroundColor: const Color(0xFF6366F1),
                    padding: EdgeInsets.zero,
                    child: SubscriptionGuard(
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 4.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(AppIcons.edit, height: 22.sp, width: 22.sp),
                              Gap(4.h),
                              Text(
                                "Tahrirlash",
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color:  Colors.black54,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  CustomSlidableAction(
                    onPressed: (context) => _showDeleteDialog(cost),
                    backgroundColor: Colors.transparent,
                    foregroundColor: const Color(0xFFF43F5E),
                    padding: EdgeInsets.zero,
                    child: SubscriptionGuard(
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 4.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF43F5E).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.delete_outline_rounded, size: 22.sp),
                              Gap(4.h),
                              Text(
                                "O'chirish",
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: isDeleted ? Colors.red.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDeleted ? Colors.grey.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SvgPicture.asset(
                      AppIcons.chiqim,
                      colorFilter: isDeleted ? ColorFilter.mode(Colors.grey, BlendMode.srcIn) : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cost.costTypeName ?? 'Chiqim turi ko\'rsatilmagan',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
                        ),
                        if(cost.workerName != null) const SizedBox(height: 4),
                        if(cost.workerName != null)Text(cost.workerName ?? '', style: TextStyle(color: Colors.black54, fontSize: 13)),
                        if (cost.description != null && cost.description!.trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            cost.description!.trim(),
                            style: TextStyle(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.w400),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatCurrency(cost.summa, cost.currencyTypeName),
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFFEF4444)),
                      ),
                      const SizedBox(height: 4),
                      Text(timeText, style: TextStyle(color: Colors.black54, fontSize: 12)),
                    ],
                  ),
                  // if (!isDeleted) ...[
                  //   const SizedBox(width: 8),
                  //   Container(
                  //     width: 32,
                  //     height: 32,
                  //     decoration: BoxDecoration(
                  //       color: const Color(0xFFF1F5F9),
                  //       borderRadius: BorderRadius.circular(8),
                  //     ),
                  //     child: IconButton(
                  //       onPressed: () => _navigateToEditCost(cost),
                  //       icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF64748B)),
                  //       padding: EdgeInsets.zero,
                  //       constraints: const BoxConstraints(),
                  //     ),
                  //   ),
                  // ],
                ],
              ),
              if (isDeleted) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'O\'chirilgan',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ));
  }
}
