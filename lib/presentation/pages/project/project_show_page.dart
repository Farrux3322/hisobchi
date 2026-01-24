import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hisobchi/application/project/project_bloc.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/dto/models/project/project_model.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/components/utils/phone_formatter.dart';
import 'package:hisobchi/presentation/pages/project/project_edit_page.dart';
import 'package:hisobchi/presentation/pages/project/screens/contract_list_page.dart';
import 'package:hisobchi/presentation/pages/project/screens/project_cost/project_cost_add_edit_page.dart';
import 'package:hisobchi/presentation/pages/project/screens/project_cost/project_cost_list_page.dart';
import 'package:hisobchi/presentation/pages/project/screens/project_income/project_income_add_edit_page.dart';
import 'package:hisobchi/presentation/pages/project/screens/project_income/project_income_list_page.dart';
import 'package:hisobchi/presentation/pages/project/screens/worker/worker_list_page.dart';
import 'package:hisobchi/presentation/pages/project/screens/report/project_report_page.dart';
import 'package:shimmer/shimmer.dart';

/// Result object returned when navigating back from ProjectShowPage
/// Indicates whether data was modified and list should be refreshed
class ProjectShowResult {
  final bool hasChanges;

  const ProjectShowResult({required this.hasChanges});

  /// Factory for when project or transactions were modified
  factory ProjectShowResult.modified() => const ProjectShowResult(hasChanges: true);

  /// Factory for when no changes were made
  factory ProjectShowResult.noChanges() => const ProjectShowResult(hasChanges: false);
}

class ProjectShowPage extends StatefulWidget {
  final int projectId;

  const ProjectShowPage({super.key, required this.projectId});

  @override
  State<ProjectShowPage> createState() => _ProjectShowPageState();
}

class _ProjectShowPageState extends State<ProjectShowPage> {
  /// Tracks whether any changes were made (project edit, income/expense transactions)
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    context.read<ProjectBloc>().add(GetProjectByIdEvent(id: widget.projectId));
  }

  /// Mark that changes were made - list should be refreshed when going back
  void _markAsChanged() {
    _hasChanges = true;
  }

  String _formatCurrency(num? value) {
    if (value == null) return '0';
    final formatter = NumberFormat('#,###', 'en_US');
    return formatter.format(value).replaceAll(',', ' ');
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          // Return result based on whether changes were made
          final navResult = _hasChanges ? ProjectShowResult.modified() : ProjectShowResult.noChanges();
          // Note: In PopScope with canPop: true, we can't modify the result
          // The calling page should use the newer navigation pattern
        }
      },
      child: BlocBuilder<ProjectBloc, ProjectState>(
        buildWhen: (previous, current) => previous.statusDetail != current.statusDetail || previous.selectedProject != current.selectedProject,
        builder: (context, state) {
          final project = state.selectedProject;

          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              leading: InkWell(
                onTap: () {
                  // Return result when manually popping
                  final result = _hasChanges ? ProjectShowResult.modified() : ProjectShowResult.noChanges();
                  Navigator.of(context).pop(result);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    boxShadow: [
                      const BoxShadow(color: Color.fromRGBO(255, 255, 255, 0.1), blurRadius: 1, spreadRadius: 0, offset: Offset(0, 1)),
                      const BoxShadow(color: Color.fromRGBO(50, 50, 93, 0.25), blurRadius: 100, spreadRadius: -20, offset: Offset(0, 50)),
                      const BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.3), blurRadius: 60, spreadRadius: -30, offset: Offset(0, 30)),
                    ],
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
                ),
              ),
              centerTitle: true,
              title: const Text(
                'Loyiha tafsilotlari',
                style: TextStyle(color: Color(0xFF1E293B), fontSize: 17, fontWeight: FontWeight.w600),
              ),
              actions: [
                if (project != null && state.statusDetail != Status.loading)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ProjectEditPage(projectModel: project))).then((v) {
                          if (!context.mounted) return;

                          if (v is Map) {
                            final action = v['action'];
                            if (action == 'delete' || action == 'force_delete') {
                              _markAsChanged();
                              Navigator.of(context).pop(ProjectShowResult.modified());
                              return;
                            }
                            if (action == 'restore') {
                              _markAsChanged();
                              context.read<ProjectBloc>().add(GetProjectByIdEvent(id: widget.projectId));
                              return;
                            }
                          }

                          if (v == true) {
                            _markAsChanged();
                            context.read<ProjectBloc>().add(GetProjectByIdEvent(id: widget.projectId));
                          }
                        });
                      },
                      icon: SvgPicture.asset(AppIcons.edit, width: 22, colorFilter: const ColorFilter.mode(Color(0xFF1E293B), BlendMode.srcIn)),
                      tooltip: 'Tahrirlash',
                    ),
                  ),
              ],
            ),
            body: _buildBody(state),
          );
        },
      ),
    );
  }

  Widget _buildBody(ProjectState state) {
    if (state.statusDetail == Status.loading) {
      return _buildLoadingShimmer();
    }

    if (state.statusDetail == Status.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 64, color: Color(0xFFEF4444)),
              const Gap(16),
              Text(
                state.errorMessage ?? 'Xatolik yuz berdi',
                style: const TextStyle(fontSize: 16, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              const Gap(24),
              ElevatedButton(
                onPressed: () => context.read<ProjectBloc>().add(GetProjectByIdEvent(id: widget.projectId)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.colors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Qayta urinish',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final project = state.selectedProject;
    if (project == null) {
      return const Center(
        child: Text('Loyiha topilmadi', style: TextStyle(color: Color(0xFF64748B))),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ProjectBloc>().add(GetProjectByIdEvent(id: widget.projectId));
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32).copyWith(bottom: MediaQuery.of(context).padding.bottom + 10),
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        child: Column(
          children: [
            _buildProjectInfoExpansion(project),
            const Gap(12),
            _buildFinancialOverview(project),
            const Gap(12),
            _buildManagementMenu(project),
            const Gap(12),
            _buildStatusDisplayCard(state, project),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectInfoExpansion(ProjectModel project) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          collapsedShape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(24)),
          iconColor: const Color(0xFF94A3B8),
          collapsedIconColor: const Color(0xFF94A3B8),
          title: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: project.files != null && project.files!.isNotEmpty
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: project.files!.first.url ?? '',
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(child: CupertinoActivityIndicator(radius: 8)),
                          errorWidget: (context, url, error) => const Icon(Icons.business_center_rounded, color: Color(0xFF6366F1), size: 24),
                        ),
                      )
                    : const Icon(Icons.business_center_rounded, color: Color(0xFF6366F1), size: 24),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            project.projectName ?? '-',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Divider(color: Color(0xFFF1F5F9), thickness: 1),
            ),
            const Gap(12),
            _buildInfoRow(icon: Icons.person_outline_rounded, iconColor: const Color(0xFFF59E0B), label: 'Loyiha egasi', value: project.projectOwner ?? '-'),
            const Gap(12),
            _buildInfoRow(icon: Icons.phone_android_rounded, iconColor: const Color(0xFF10B981), label: 'Tel raqami', value: PhoneFormatter.formatPhoneNumber(project.phone ?? '')),
            const Gap(12),
            _buildInfoRow(icon: Icons.location_on_outlined, iconColor: const Color(0xFFEF4444), label: 'Manzil', value: project.address ?? '-'),
            if (project.location != null && project.location!.isNotEmpty) ...[
              const Gap(12),
              _buildInfoRow(
                icon: Icons.map_outlined,
                iconColor: const Color(0xFF3B82F6),
                label: 'Lokatsiya',
                value: 'Havolani ko\'rish',
                isLink: true,
                onTap: () {
                  // Handle location link
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required Color iconColor, required String label, required String value, bool isLink = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF94A3B8)),
                  ),
                  const Gap(1),
                  Text(
                    value,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isLink ? const Color(0xFF3B82F6) : const Color(0xFF1E293B)),
                  ),
                ],
              ),
            ),
            if (isLink) const Icon(Icons.open_in_new_rounded, size: 14, color: Color(0xFF3B82F6)),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialOverview(ProjectModel project) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          // Totals Row (Income & Expense)
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  label: 'Kirim',
                  amountUzs: project.accounts?.debt?.uzs,
                  amountUsd: project.accounts?.debt?.usd,
                  icon: AppIcons.income,
                  color: const Color(0xFF3CC293),
                  onTap: () async {
                    // Navigate to income list page and check if changes were made
                    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => ProjectIncomeListPage(projectId: project.id ?? 0)));
                    // Only refresh if transactions were actually modified
                    if (mounted && result is ProjectIncomeListResult && result.hasChanges) {
                      _markAsChanged();
                      context.read<ProjectBloc>().add(GetProjectByIdEvent(id: widget.projectId));
                    }
                  },
                ),
              ),
              const Gap(12),
              Expanded(
                child: _buildMetricCard(
                  label: 'Chiqim',
                  amountUzs: project.accounts?.credit?.uzs,
                  amountUsd: project.accounts?.credit?.usd,
                  icon: AppIcons.chiqim,
                  color: const Color(0xFFDE5050),
                  onTap: () async {
                    // Navigate to expense list page and check if changes were made
                    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => ProjectCostListPage(projectId: project.id ?? 0)));
                    // Only refresh if transactions were actually modified
                    if (mounted && result is ProjectCostListResult && result.hasChanges) {
                      _markAsChanged();
                      context.read<ProjectBloc>().add(GetProjectByIdEvent(id: widget.projectId));
                    }
                  },
                ),
              ),
            ],
          ),
          const Gap(12),
          // Large Balance Card
          _buildMainBalanceCard(project),
          const Gap(12),
          // Quick Action Buttons
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  label: 'Kirim',
                  icon: AppIcons.income,
                  color: const Color(0xFF3CC293),
                  gradient: const [Color(0xFF3CC293), Color(0xFF34B082)],
                  onTap: () {
                    // Adding new income transaction
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ProjectIncomeAddEditPage(projectId: project.id ?? 0))).then((v) {
                      // Transaction added, refresh detail page and mark as changed
                      if (mounted && v == true) {
                        _markAsChanged();
                        context.read<ProjectBloc>().add(GetProjectByIdEvent(id: widget.projectId));
                      }
                    });
                  },
                ),
              ),
              const Gap(12),
              Expanded(
                child: _buildActionButton(
                  label: 'Chiqim',
                  icon: AppIcons.chiqim,
                  color: const Color(0xFFDE5050),
                  gradient: const [Color(0xFFDE5050), Color(0xFFC54444)],
                  onTap: () {
                    // Adding new expense transaction
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ProjectCostAddEditPage(projectId: project.id ?? 0))).then((v) {
                      // Transaction added, refresh detail page and mark as changed
                      if (mounted && v == true) {
                        _markAsChanged();
                        context.read<ProjectBloc>().add(GetProjectByIdEvent(id: widget.projectId));
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({required String label, num? amountUzs, num? amountUsd, required String icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: SvgPicture.asset(icon, width: 20, height: 20, colorFilter: ColorFilter.mode(color, BlendMode.srcIn)),
                ),
                const Gap(8),
                Text(
                  label,
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.black),
                ),
              ],
            ),
            // const Gap(12),
            Align(
              alignment: Alignment.centerRight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      _formatCurrency(amountUzs),
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Colors.black),
                    ),
                    const Gap(4),
                    Text(
                      'UZS',
                      style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
            const Gap(4),
            Align(
              alignment: Alignment.centerRight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      _formatCurrency(amountUsd),
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Colors.black),
                    ),
                    const Gap(4),
                    Text(
                      'USD',
                      style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainBalanceCard(ProjectModel project) {
    final balance = project.accounts?.balance;
    final uzs = balance?.uzs ?? 0;
    final usd = balance?.usd ?? 0;

    // Senior approach: Conditional colors based on balance state
    final isNegative = uzs < 0 || usd < 0;
    final isZero = uzs == 0 && usd == 0;

    final Color balanceColor = isNegative
        ? const Color(0xFFDE5050)
        : (isZero ? AppTheme.colors.primary : const Color(0xFF3CC293));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: balanceColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: balanceColor.withValues(alpha: 0.25), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: balanceColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: SvgPicture.asset(
              AppIcons.balance,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(balanceColor, BlendMode.srcIn),
            ),
          ),
          const Gap(16),
          Text(
            'Qoldiq',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: balanceColor),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _formatCurrency(uzs),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: balanceColor,
                    ),
                  ),
                  const Gap(6),
                  Text(
                    'UZS',
                    style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700, color: balanceColor.withValues(alpha: 0.6)),
                  ),
                ],
              ),
              const Gap(2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _formatCurrency(usd),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: balanceColor,
                    ),
                  ),
                  const Gap(6),
                  Text(
                    'USD',
                    style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700, color: balanceColor.withValues(alpha: 0.6)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required String label, required String icon, required Color color, required List<Color> gradient, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(icon, width: 20, height: 20, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
              const Gap(8),
              Text(
                label,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManagementMenu(ProjectModel project) {
    return Column(
      children: [
        _buildMenuButton(
          icon: Icons.description_outlined,
          label: 'Shartnomalar',
          color: const Color(0xFF3B82F6),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ContractListPage(projectId: project.id ?? 0))),
        ),
        const Gap(12),
        _buildMenuButton(
          icon: Icons.people_outline_rounded,
          label: 'Ishchilar',
          color: const Color(0xFF8B5CF6),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WorkerListPage(projectId: project.id ?? 0))),
        ),
        const Gap(12),
        _buildMenuButton(
          icon: Icons.analytics_outlined,
          label: 'Loyiha hisoboti',
          color: const Color(0xFF64748B),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProjectReportPage(projectId: project.id ?? 0))),
        ),
      ],
    );
  }

  Widget _buildMenuButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color, size: 22),
            ),
            const Gap(16),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildShimmerItem(height: 80, borderRadius: 24), // Info
          const Gap(16),
          Row(
            children: [
              Expanded(child: _buildShimmerItem(height: 120, borderRadius: 24)), // Metric Left
              const Gap(12),
              Expanded(child: _buildShimmerItem(height: 120, borderRadius: 24)), // Metric Right
            ],
          ),
          const Gap(12),
          _buildShimmerItem(height: 110, borderRadius: 24), // Balance Card
          const Gap(12),
          Row(
            children: [
              Expanded(child: _buildShimmerItem(height: 54, borderRadius: 20)), // Action Left
              const Gap(12),
              Expanded(child: _buildShimmerItem(height: 54, borderRadius: 20)), // Action Right
            ],
          ),
          const Gap(24),
          _buildShimmerItem(height: 70, borderRadius: 20), // Menu 1
          const Gap(12),
          _buildShimmerItem(height: 70, borderRadius: 20), // Menu 2
          const Gap(12),
          _buildShimmerItem(height: 70, borderRadius: 20), // Menu 3
        ],
      ),
    );
  }

  Widget _buildShimmerItem({required double height, required double borderRadius}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade400,
      highlightColor: Colors.white,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(borderRadius)),
      ),
    );
  }

  Widget _buildStatusDisplayCard(ProjectState state, ProjectModel project) {
    String label;
    Color color;
    IconData icon;

    switch (project.status ?? '') {
      case 'in_progress':
      case 'Jarayonda':
        label = 'Jarayonda';
        color = Colors.orange;
        icon = Icons.play_circle_outline_rounded;
        break;
      case 'frozen':
      case 'Muzlatilgan':
        label = 'Muzlatilgan';
        color = Colors.blue;
        icon = Icons.pause_circle_outline_rounded;
        break;
      case 'completed':
      case 'Yakunlangan':
        label = 'Yakunlangan';
        color = Colors.green;
        icon = Icons.check_circle_outline_rounded;
        break;
      default:
        label = project.status ?? 'Noma\'lum';
        color = const Color(0xFF64748B);
        icon = Icons.help_outline_rounded;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Decorative Background Icon
            Positioned(
              right: -10,
              top: 0,
              child: Icon(
                icon,
                size: 60,
                color: color.withValues(alpha: 0.1),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const Gap(16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Loyiha holati',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF94A3B8),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: color,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Material(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () => _showStatusSelectionBottomSheet(project),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            Text(
                              'O\'zgartirish',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                            const Gap(4),
                            Icon(Icons.keyboard_arrow_right_rounded, color: color, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusSelectionBottomSheet(ProjectModel project) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return BlocConsumer<ProjectBloc, ProjectState>(
          listener: (context, state) {
            if (state.statusAction == Status.success) {
              Navigator.pop(context);
            }
          },
          builder: (context, state) {
            final isLoading = state.statusAction == Status.loading;
            final currentStatus = project.status ?? '';

            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(10)),
                  ),
                  const Gap(32),
                  const Text(
                    'Loyiha holatini tanlang',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                  ),
                  const Gap(12),
                  const Text(
                    'Loyiha holatini o\'zgartirish orqali uni boshqarishingiz mumkin',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Color(0xFF64748B)),
                  ),
                  const Gap(32),
                  _buildStatusSheetOption(
                    context,
                    label: 'Jarayonda',
                    slug: 'in_progress',
                    currentStatus: currentStatus,
                    color: Colors.orange,
                    icon: Icons.play_circle_outline_rounded,
                    isLoading: isLoading,
                    projectId: project.id ?? 0,
                  ),
                  const Gap(12),
                  _buildStatusSheetOption(
                    context,
                    label: 'Muzlatilgan',
                    slug: 'frozen',
                    currentStatus: currentStatus,
                    color: Colors.blue,
                    icon: Icons.pause_circle_outline_rounded,
                    isLoading: isLoading,
                    projectId: project.id ?? 0,
                  ),
                  const Gap(12),
                  _buildStatusSheetOption(
                    context,
                    label: 'Yakunlangan',
                    slug: 'completed',
                    currentStatus: currentStatus,
                    color: Colors.green,
                    icon: Icons.check_circle_outline_rounded,
                    isLoading: isLoading,
                    projectId: project.id ?? 0,
                  ),
                  const Gap(32),
                  if (isLoading) const CupertinoActivityIndicator(radius: 12),
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusSheetOption(
    BuildContext context, {
    required String label,
    required String slug,
    required String currentStatus,
    required Color color,
    required IconData icon,
    required bool isLoading,
    required int projectId,
  }) {
    final bool isSelected = currentStatus == slug || currentStatus == label;

    return InkWell(
      onTap: isLoading || isSelected
          ? null
          : () {
              context.read<ProjectBloc>().add(UpdateProjectStatusEvent(id: projectId, status: slug));
            },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.05) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 24),
            ),
            const Gap(16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? color : const Color(0xFF1E293B),
                ),
              ),
            ),
            if (isSelected) Icon(Icons.check_rounded, color: color, size: 24),
          ],
        ),
      ),
    );
  }
}
