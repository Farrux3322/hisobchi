import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:hisobchi/application/project_income/project_income_bloc.dart';
import 'package:hisobchi/application/project_income/project_income_event.dart';
import 'package:hisobchi/application/project_income/project_income_state.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/models/project_income_model.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/components/basic_widgets.dart';
import 'package:hisobchi/presentation/components/loading/loading.dart';
import 'package:hisobchi/presentation/components/toast/toast.dart';
import 'package:hisobchi/presentation/pages/project/screens/project_income/project_income_add_edit_page.dart';
import 'package:hisobchi/presentation/components/subscription/subscription_guard.dart';
import 'package:collection/collection.dart';
import 'package:shimmer/shimmer.dart';

/// Result object returned when navigating back from ProjectIncomeListPage
/// Indicates whether transactions were modified
class ProjectIncomeListResult {
  final bool hasChanges;

  const ProjectIncomeListResult({required this.hasChanges});

  /// Factory for when transactions were modified
  factory ProjectIncomeListResult.modified() => const ProjectIncomeListResult(hasChanges: true);

  /// Factory for when no changes were made
  factory ProjectIncomeListResult.noChanges() => const ProjectIncomeListResult(hasChanges: false);
}

class ProjectIncomeListPage extends StatefulWidget {
  final int projectId;

  const ProjectIncomeListPage({super.key, required this.projectId});

  @override
  State<ProjectIncomeListPage> createState() => _ProjectIncomeListPageState();
}

class _ProjectIncomeListPageState extends State<ProjectIncomeListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ProjectIncomeModel> _filteredCosts = [];
  List<ProjectIncomeModel> _allCosts = [];

  /// Tracks whether any changes were made (add/edit/delete/restore transactions)
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadCosts();
    _searchController.addListener(_filterCosts);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isBottom) {
      final state = context.read<ProjectIncomeBloc>().state;
      context.read<ProjectIncomeBloc>().add(
            LoadMoreProjectIncomesEvent(
              projectId: widget.projectId,
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
    context.read<ProjectIncomeBloc>().add(GetProjectIncomesEvent(projectId: widget.projectId));
  }

  /// Mark that changes were made - parent should refresh when going back
  void _markAsChanged() {
    _hasChanges = true;
  }

  void _onSearch(String query) {
    context.read<ProjectIncomeBloc>().add(GetProjectIncomesEvent(projectId: widget.projectId, search: query));
  }

  void _filterCosts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCosts = _allCosts;
      } else {
        _filteredCosts = _allCosts.where((cost) => (cost.description?.toLowerCase().contains(query) ?? false) || (cost.summa?.toLowerCase().contains(query) ?? false)).toList();
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

  Future<void> _navigateToAddCost() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<ProjectIncomeBloc>(),
          child: ProjectIncomeAddEditPage(projectId: widget.projectId),
        ),
      ),
    );

    if (result == true && mounted) {
      _markAsChanged();
      _loadCosts();
    }
  }

  Future<void> _navigateToEditCost(ProjectIncomeModel cost) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<ProjectIncomeBloc>(),
          child: ProjectIncomeAddEditPage(projectId: widget.projectId, income: cost),
        ),
      ),
    );

    if (result == true && mounted) {
      _markAsChanged();
      _loadCosts();
    }
  }

  /// Show delete confirmation dialog
  Future<void> _showDeleteDialog(ProjectIncomeModel cost) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(Icons.delete_outline, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 24),
              const Text(
                'Kirimni o\'chirish',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Ushbu kirimni o\'chirishni xohlaysizmi?',
                style: TextStyle(fontSize: 15, color: Color(0xFF64748B), height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFFBBF24).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: const Text(
                  'Kirimni keyinchalik qayta tiklash mumkin',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFFF59E0B)),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
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
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFFFBBF24),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Ha', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
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
      context.read<ProjectIncomeBloc>().add(DeleteProjectIncomeEvent(projectIncomeId: cost.id!, projectId: widget.projectId));
    }
  }

  /// Show restore confirmation dialog
  Future<void> _showRestoreDialog(ProjectIncomeModel cost) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(Icons.restore, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 24),
              const Text(
                'Kirimni tiklash',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Ushbu kirimni tiklashni xohlaysizmi?',
                style: TextStyle(fontSize: 15, color: Color(0xFF64748B), height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: const Text(
                  'Kirim barcha ma\'lumotlari bilan tiklanadi',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF059669)),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
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
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Ha', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
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
      context.read<ProjectIncomeBloc>().add(RestoreProjectIncomeEvent(projectIncomeId: cost.id!, projectId: widget.projectId));
    }
  }

  /// Show force delete confirmation dialog
  Future<void> _showForceDeleteDialog(ProjectIncomeModel cost) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(Icons.delete_forever, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 24),
              const Text(
                'Butunlay o\'chirish',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Ushbu kirimni butunlay o\'chirishni xohlaysizmi?',
                style: TextStyle(fontSize: 15, color: Color(0xFF64748B), height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFEF4444).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: const Column(
                  children: [
                    Text(
                      '⚠️ DIQQAT',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFFDC2626)),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Bu amal qaytarib bo\'lmaydi!\nBarcha ma\'lumotlar butunlay yo\'qoladi',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFFDC2626)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
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
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Ha', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
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
      context.read<ProjectIncomeBloc>().add(ForceDeleteProjectIncomeEvent(projectIncomeId: cost.id!, projectId: widget.projectId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          final navResult = _hasChanges ? ProjectIncomeListResult.modified() : ProjectIncomeListResult.noChanges();
        }
      },
      child: DeFocus(
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            leading: Center(
              child: InkWell(
                onTap: () {
                  final result = _hasChanges ? ProjectIncomeListResult.modified() : ProjectIncomeListResult.noChanges();
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
              'Loyiha kirimlari',
            ),
            centerTitle: true,
          ),
          floatingActionButton: Padding(
            padding:  EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
            child: SubscriptionGuard(
              child: FloatingActionButton(
              heroTag: 'project_income_fab',
              onPressed: _navigateToAddCost,
              backgroundColor: AppTheme.colors.primary,
              child: SvgPicture.asset(AppIcons.projectAdd),
            ),
            ),
          ),

          body: BlocConsumer<ProjectIncomeBloc, ProjectIncomeState>(
            listener: (context, state) {
              // Toast xabarlarini ko'rsatish
              if (state.statusAction == Status.success) {
                _markAsChanged(); // Mark changes when delete/restore/force delete succeeds
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    Toast.showSuccessToast(message: 'Muvaffaqiyatli bajarildi');
                  }
                });
              } else if (state.statusAction == Status.error) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    Toast.showErrorToast(message: state.errorMessage ?? 'Xatolik yuz berdi');
                  }
                });
              }

              // Ma'lumotlarni yangilash
              if (state.status == Status.success) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _allCosts = state.incomes;
                      _filterCosts();
                    });
                  }
                });
              } else if (state.status == Status.error) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    Toast.showErrorToast(message: state.errorMessage ?? 'Xatolik yuz berdi');
                  }
                });
              }
            },
            builder: (context, state) {
              return SafeArea(
                child: Column(
                  children: [
                    // Search Bar
                    Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          _onSearch(value);
                        },
                        decoration: InputDecoration(
                          hintText: 'Qidirish...',
                          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(left: 8.0, right: 4),
                            child: Icon(Icons.search, color: Color(0xFF64748B), size: 20),
                          ),
                          filled: true,
                          fillColor: Colors.white,
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
                          : RefreshIndicator(
                              onRefresh: () async {
                                _loadCosts();
                              },
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(16, 0, 6, 0),
                                    child: CustomScrollView(
                                      controller: _scrollController,
                                      slivers: _buildGroupedCosts(state),
                                    ),
                                  ),
                                  if (state.statusAction == Status.loading) const Center(child: Loading()),
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

  List<Widget> _buildGroupedCosts(ProjectIncomeState state) {
    final groupedData = groupBy<ProjectIncomeModel, DateTime>(_filteredCosts, (cost) {
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

  Widget _buildCostCard(ProjectIncomeModel cost) {
    final String timeText = _formatTimeOnly(cost.createdAt);
    final bool isDeleted = cost.isDeleted;

    // Helper to format amount
    String formattedAmount = '0';
    if (cost.summa != null) {
      try {
        final number = double.parse(cost.summa!);
        final formatter = NumberFormat('#,##0.##', 'uz');
        formattedAmount = formatter.format(number);
      } catch (e) {
        formattedAmount = cost.summa!;
      }
    }

    return SubscriptionGuard(
      child: GestureDetector(
        onTap: isDeleted ? null : () => _navigateToEditCost(cost),
        child: Slidable(
        key: ValueKey(cost.id),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: isDeleted ? 0.6 : 0.55,
          children: isDeleted
              ? [
                  CustomSlidableAction(
                    onPressed: (context) => _showRestoreDialog(cost),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    child: SubscriptionGuard(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.restore),
                            Text("Tiklash", style: TextStyle(fontSize: 10)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  CustomSlidableAction(
                    onPressed: (context) => _showForceDeleteDialog(cost),
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    child: SubscriptionGuard(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.delete_forever),
                            Text("Butunlay", style: TextStyle(fontSize: 10)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ]
              : [
                  CustomSlidableAction(
                    onPressed: (context) => _navigateToEditCost(cost),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    child: SubscriptionGuard(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit_outlined),
                            Text("Tahrirlash", style: TextStyle(fontSize: 10)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  CustomSlidableAction(
                    onPressed: (context) => _showDeleteDialog(cost),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    child: SubscriptionGuard(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.delete_outline),
                            Text("O'chirish", style: TextStyle(fontSize: 10)),
                          ],
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
                    decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(12)),
                    child: SvgPicture.asset(AppIcons.income, colorFilter: isDeleted ? ColorFilter.mode(Colors.grey, BlendMode.srcIn) : null),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cost.description?.isNotEmpty == true ? cost.description! : 'Kirim',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(timeText, style: TextStyle(color: isDeleted ? Colors.grey : const Color(0xFF64748B), fontSize: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: formattedAmount,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF10B981)),
                            ),
                            TextSpan(
                              text: ' ${cost.currencyTypeName ?? ''}',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF10B981).withValues(alpha: 0.8)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (isDeleted) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(6)),
                    child: Text(
                      'O\'chirilgan',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.red.shade700),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppTheme.colors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: SvgPicture.asset(AppIcons.income, height: 40, width: 40, colorFilter: ColorFilter.mode(AppTheme.colors.primary, BlendMode.srcIn)),
          ),
          const SizedBox(height: 24),
          Text(
            _searchController.text.isEmpty ? 'Kirimlar mavjud emas' : 'Hech narsa topilmadi',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isEmpty ? 'Yangi kirim qo\'shish uchun + tugmasini bosing' : 'Boshqa kalit so\'z bilan qidirib ko\'ring',
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Shimmer loading widget for project income list
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
