import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hisobchi/application/project_report/project_report_bloc.dart';
import 'package:hisobchi/infrastructure/dto/models/project_report/project_report_model.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/pages/project/screens/project_income/project_income_list_page.dart';
import 'package:hisobchi/presentation/pages/project/screens/report/project_cost_details_page.dart';
import 'package:hisobchi/presentation/pages/project/screens/report/project_income_details_page.dart';
import 'package:shimmer/shimmer.dart';

class ProjectReportPage extends StatelessWidget {
  final int projectId;

  const ProjectReportPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProjectReportBloc()..add(GetProjectReportEvent(projectId: projectId)),
      child: _ProjectReportView(projectId: projectId),
    );
  }
}

class _ProjectReportView extends StatelessWidget {
  final int projectId;

  const _ProjectReportView({required this.projectId});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.colors;
    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text(
          'Moliya Hisoboti',
          style: TextStyle(color: theme.black, fontWeight: FontWeight.w700, fontSize: 20),
        ),
        backgroundColor: theme.background,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.black),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: BlocBuilder<ProjectReportBloc, ProjectReportState>(
          builder: (context, state) {
            if (state.status == ReportStatus.loading) {
              return const _ReportLoadingShimmer();
            } else if (state.status == ReportStatus.error) {
              return _buildErrorState(context, state.errorMessage);
            } else if (state.status == ReportStatus.success && state.report != null) {
              return _buildContent(context, state.report!, projectId);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String? message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.05), shape: BoxShape.circle),
              child: const Icon(Icons.cloud_off_rounded, size: 64, color: Colors.redAccent),
            ),
            const Gap(24),
            Text(
              'Ma\'lumotlarni yuklashda xatolik',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
            ),
            const Gap(8),
            Text(
              message ?? 'Internet aloqasini tekshiring va qayta urinib ko\'ring',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600], height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ProjectReportModel report, int projectId) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Qoldiq Card
          _buildBalanceCard(report),
          const Gap(16),

          // 2. Kirim Card
          _buildIncomeCard(context, report, projectId),
          const Gap(16),

          // 3. Chiqim Card with Categories
          _buildExpenseCard(context, report, projectId),
          const Gap(20),
        ],
      ),
    );
  }

  // 1. Qoldiq Card
  Widget _buildBalanceCard(ProjectReportModel report) {
    final theme = AppTheme.colors;
    final formatter = NumberFormat("#,###", "ru_RU");
    final balanceUzs = report.balanceUzs ?? 0;
    final balanceUsd = report.balanceUsd ?? 0;
    final isPositive = balanceUzs >= 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [theme.primary, theme.primary]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: theme.primary.withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side - Title and Icon
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                      child: Icon(isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded, color: Colors.white, size: 20),
                    ),
                    const Gap(10),
                    Text(
                      'Qoldiq',
                      style: TextStyle(fontSize: 16.sp, color: Colors.white.withValues(alpha: 0.95), fontWeight: FontWeight.w700, letterSpacing: 0.5),
                    ),
                  ],
                ),
                const Gap(12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    isPositive ? 'Foyda' : 'Zarar',
                    style: TextStyle(fontSize: 12.sp, color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          // Right side - Vertical Balance
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              RichText(
                text: TextSpan(
                  text: formatter.format(balanceUzs).replaceAll(',', ' '),
                  style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900, color: Colors.white, height: 1.2),
                  children: [
                    TextSpan(
                      text: ' UZS',
                      style: TextStyle(fontSize: 12.sp, color: Colors.white.withValues(alpha: 0.85), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const Gap(8),
              RichText(
                text: TextSpan(
                  text: formatter.format(balanceUsd).replaceAll(',', ' '),
                  style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900, color: Colors.white.withValues(alpha: 0.9), height: 1.2),
                  children: [
                    TextSpan(
                      text: ' USD',
                      style: TextStyle(fontSize: 12.sp, color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. Kirim Card
  Widget _buildIncomeCard(BuildContext context, ProjectReportModel report, int projectId) {
    final formatter = NumberFormat("#,###", "ru_RU");
    final incomeUzs = report.incomeUzs ?? 0;
    final incomeUsd = report.incomeUsd ?? 0;

    return InkWell(
      onTap: () {
        // Navigate to income list page and check if changes were made
         Navigator.push(context, MaterialPageRoute(builder: (_) => ProjectIncomeListPage(projectId: projectId)));
        // Only refresh if transactions were actually modified
        // if (mounted && result is ProjectIncomeListResult && result.hasChanges) {
        //   _markAsChanged();
        //   context.read<ProjectBloc>().add(GetProjectByIdEvent(id: widget.projectId));
        // }
        // Navigator.push(context, MaterialPageRoute(builder: (_) => ProjectIncomeDetailsPage(projectId: projectId)));
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3), width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left side - Title and Icon
            Expanded(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                    child: SvgPicture.asset(AppIcons.income, width: 22, height: 22, colorFilter: const ColorFilter.mode(Color(0xFF10B981), BlendMode.srcIn)),
                  ),
                  const Gap(12),
                  Text(
                    'Kirim',
                    style: TextStyle(fontSize: 16.sp, color: const Color(0xFF1E293B), fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),

            // Right side - Vertical Income
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                RichText(
                  text: TextSpan(
                    text: formatter.format(incomeUzs).replaceAll(',', ' '),
                    style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: const Color(0xFF10B981), height: 1.2),
                    children: [
                      TextSpan(
                        text: ' UZS',
                        style: TextStyle(fontSize: 12.sp, color: const Color(0xFF10B981).withValues(alpha: 0.8), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                if (incomeUsd > 0) ...[
                  const Gap(6),
                  RichText(
                    text: TextSpan(
                      text: formatter.format(incomeUsd).replaceAll(',', ' '),
                      style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: const Color(0xFF059669), height: 1.2),
                      children: [
                        TextSpan(
                          text: ' USD',
                          style: TextStyle(fontSize: 12.sp, color: const Color(0xFF059669).withValues(alpha: 0.8), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 3. Chiqim Card with Categories
  Widget _buildExpenseCard(BuildContext context, ProjectReportModel report, int projectId) {
    final formatter = NumberFormat("#,###", "ru_RU");
    final costUzs = report.costs?.costUzs ?? 0;
    final costUsd = report.costs?.costUsd ?? 0;
    final details = report.costs?.details ?? [];

    // Calculate total cost in UZS equivalent (1 USD = 13000 UZS)
    // Sum all categories in UZS for accurate percentage calculation
    final totalCostInUzs = details.fold<double>(0.0, (sum, detail) => sum + (detail.summaUzs ?? 0) + ((detail.summaUsd ?? 0) * 13000));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side - Title and Icon
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: const Color(0xFFEF4444).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                      child: SvgPicture.asset(AppIcons.chiqim, width: 22, height: 22, colorFilter: ColorFilter.mode(const Color(0xFFEF4444), BlendMode.srcIn)),
                    ),
                    const Gap(12),
                    Text(
                      'Chiqim',
                      style: TextStyle(fontSize: 16.sp, color: const Color(0xFF1E293B), fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),

              // Right side - Vertical Expense
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  RichText(
                    text: TextSpan(
                      text: formatter.format(costUzs).replaceAll(',', ' '),
                      style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: const Color(0xFFEF4444), height: 1.2),
                      children: [
                        TextSpan(
                          text: ' UZS',
                          style: TextStyle(fontSize: 12.sp, color: const Color(0xFFEF4444).withValues(alpha: 0.8), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  if (costUsd > 0) ...[
                    const Gap(6),
                    RichText(
                      text: TextSpan(
                        text: formatter.format(costUsd).replaceAll(',', ' '),
                        style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: const Color(0xFFDC2626), height: 1.2),
                        children: [
                          TextSpan(
                            text: ' USD',
                            style: TextStyle(fontSize: 12.sp, color: const Color(0xFFDC2626).withValues(alpha: 0.8), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),

          // Categories with Progress
          if (details.isNotEmpty) ...[
            const Gap(24),
            Container(height: 1, color: Colors.grey[200]),
            const Gap(20),

            // Categories Title
            Row(
              children: [
                Icon(Icons.category_rounded, size: 18, color: const Color(0xFF64748B)),
                const Gap(8),
                Text(
                  'Kategoriyalar bo\'yicha',
                  style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    '${details.length}',
                    style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const Gap(16),

            // Categories List
            ...details.map((detail) {
              final categoryTotalUzs = (detail.summaUzs ?? 0) + ((detail.summaUsd ?? 0) * 13000);
              final percentage = totalCostInUzs > 0 ? (categoryTotalUzs / totalCostInUzs * 100) : 0.0;

              return Padding(padding: const EdgeInsets.only(bottom: 16), child: _buildCategoryItem(context, detail, percentage, formatter, projectId));
            }),
          ] else ...[
            const Gap(20),
            Center(
              child: Column(
                children: [
                  Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[300]),
                  const Gap(12),
                  Text(
                    'Xarajatlar mavjud emas',
                    style: TextStyle(fontSize: 14.sp, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const Gap(20),
          ],
        ],
      ),
    );
  }

  // Category Item with Progress Bar
  Widget _buildCategoryItem(BuildContext context, ProjectCostDetail detail, double percentage, NumberFormat formatter, int projectId) {
    final theme = AppTheme.colors;
    final color = theme.primary;
    // final color = _getCostColor(detail.costTypeName);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProjectCostDetailsPage(projectId: projectId, costTypeId: detail.costTypeId ?? 0, costTypeName: detail.costTypeName ?? 'Chiqim'),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.15), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Name and Amounts
                Row(
                  children: [
                    // Category Name
                    Expanded(
                      child: Text(
                        detail.costTypeName ?? 'Noma\'lum',
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const Gap(12),

                    // Amounts
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if ((detail.summaUzs ?? 0) > 0)
                          RichText(
                            text: TextSpan(
                              text: formatter.format(detail.summaUzs ?? 0).replaceAll(',', ' '),
                              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: color),
                              children: [
                                TextSpan(
                                  text: ' UZS',
                                  style: TextStyle(fontSize: 10.sp, color: color.withValues(alpha: 0.7), fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        if ((detail.summaUsd ?? 0) > 0) ...[
                          const Gap(4),
                          RichText(
                            text: TextSpan(
                              text: formatter.format(detail.summaUsd ?? 0).replaceAll(',', ' '),
                              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: color.withValues(alpha: 0.8)),
                              children: [
                                TextSpan(
                                  text: ' USD',
                                  style: TextStyle(fontSize: 10.sp, color: color.withValues(alpha: 0.6), fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),

                    const Gap(8),
                    Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey[400]),
                  ],
                ),

                const Gap(12),

                // Bottom Row: Progress Bar and Percentage
                Row(
                  children: [
                    // Progress Bar
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          minHeight: 8,
                          backgroundColor: theme.primary.withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
                        ),
                      ),
                    ),
                    const Gap(12),
                    // Percentage Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: theme.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                      child: Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w800, color: theme.primary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportLoadingShimmer extends StatelessWidget {
  const _ReportLoadingShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Balance Card Shimmer
            Container(
              height: 120,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            ),
            const Gap(16),

            // Income Card Shimmer
            Container(
              height: 100,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            ),
            const Gap(16),

            // Expense Card Shimmer
            Container(
              height: 400,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            ),
          ],
        ),
      ),
    );
  }
}
