
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hisobchi/application/project_report/project_report_bloc.dart';
import 'package:hisobchi/infrastructure/dto/models/project_report/project_report_model.dart';
import 'package:hisobchi/presentation/pages/project/screens/report/project_cost_details_page.dart';
import 'package:hisobchi/presentation/pages/project/screens/report/project_income_details_page.dart';
import 'package:intl/intl.dart';
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Very light cool grey
      appBar: AppBar(
        title: const Text(
          'Moliya Hisoboti',
          style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w700, fontSize: 20),
        ),
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        centerTitle: true,
      ),
      body: BlocBuilder<ProjectReportBloc, ProjectReportState>(
        builder: (context, state) {
          if (state.status == ReportStatus.loading) {
            return const _ReportLoadingShimmer();
          } else if (state.status == ReportStatus.error) {
            return _buildErrorState(context, state.errorMessage);
          } else if (state.status == ReportStatus.success && state.report != null) {
            return _buildModernContent(context, state.report!, projectId);
          }
          return const SizedBox.shrink();
        },
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
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
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
            const Gap(32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // User would typically need to reload here. 
                  // Since we are stateless, we assume logic exists or user re-enters.
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Qayta yuklash', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernContent(BuildContext context, ProjectReportModel report, int projectId) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTotalBalanceCard(report),
          const Gap(20),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProjectIncomeDetailsPage(projectId: projectId),
                      ),
                    );
                  },
                  child: _buildStatCard(
                    title: 'Kirim',
                    amountUzs: report.incomeUzs,
                    amountUsd: report.incomeUsd,
                    color: const Color(0xFF10B981),
                    icon: Icons.arrow_downward_rounded,
                  ),
                ),
              ),
              const Gap(16),
              Expanded(
                child: _buildStatCard(
                  title: 'Chiqim',
                  amountUzs: report.costs?.costUzs,
                  amountUsd: report.costs?.costUsd,
                  color: const Color(0xFFEF4444),
                  icon: Icons.arrow_upward_rounded,
                ),
              ),
            ],
          ),
          const Gap(32),
          Text(
            "Chiqimlar tarixi",
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
          ),
          const Gap(16),
          _buildCostList(report.costs?.details, projectId, context),
          const Gap(40),
        ],
      ),
    );
  }

  Widget _buildTotalBalanceCard(ProjectReportModel report) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)], // Blue gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 20),
              ),
              const Gap(10),
              Text(
                'Umumiy Balans',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const Gap(24),
          _buildBigCurrencyText(report.balanceUzs, 'UZS', textColor: Colors.white),
          if ((report.balanceUsd ?? 0) != 0) ...[
            const Gap(12),
            Container(width: double.infinity, height: 1, color: Colors.white.withOpacity(0.15)),
            const Gap(12),
            _buildBigCurrencyText(report.balanceUsd, 'USD', textColor: Colors.white),
          ]
        ],
      ),
    );
  }

  Widget _buildBigCurrencyText(num? amount, String symbol, {required Color textColor}) {
    final formatter = NumberFormat("#,###", "ru_RU");
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          formatter.format(amount ?? 0).replaceAll(',', ' '),
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.w700,
            color: textColor,
            letterSpacing: -0.5,
          ),
        ),
        const Gap(8),
        Text(
          symbol,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: textColor.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required num? amountUzs,
    required num? amountUsd,
    required Color color,
    required IconData icon,
  }) {
    final formatter = NumberFormat("#,###", "ru_RU");
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const Gap(16),
          Text(
            title,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[500], fontWeight: FontWeight.w500),
          ),
          const Gap(8),
          _buildStatCurrency(amountUzs, 'UZS'),
          if ((amountUsd ?? 0) != 0) ...[
            const Gap(4),
            _buildStatCurrency(amountUsd, 'USD'),
          ]
        ],
      ),
    );
  }

  Widget _buildStatCurrency(num? amount, String symbol) {
    if ((amount ?? 0) == 0) return const SizedBox.shrink();
    final formatter = NumberFormat("#,###", "ru_RU");
    return Row(
      children: [
        Flexible(
          child: Text(
            formatter.format(amount!).replaceAll(',', ' '),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
              letterSpacing: -0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Gap(4),
        Text(
          symbol,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }

  // Removed _buildChartSection as per request

  Widget _buildCostList(List<ProjectCostDetail>? details, int projectId, BuildContext context) {
    if (details == null || details.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 32),
        alignment: Alignment.center,
        child: Text(
          "Xarajatlar mavjud emas",
          style: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: details.length,
      separatorBuilder: (_, __) => const Gap(12),
      itemBuilder: (context, index) {
        final item = details[index];
        final colors = [
           Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple, Colors.teal, Colors.amber
        ];
        final color = colors[index % colors.length];

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProjectCostDetailsPage(
                    projectId: projectId,
                    costTypeId: item.costTypeId ?? 0,
                    costTypeName: item.costTypeName ?? 'Chiqim',
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        (item.costTypeName?.isNotEmpty == true) ? item.costTypeName![0].toUpperCase() : '?',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color),
                      ),
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: Text(
                      item.costTypeName ?? 'Noma\'lum',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF1E293B)),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                       if ((item.summaUzs ?? 0) > 0)
                        _buildListCurrency(item.summaUzs, 'UZS'),
                       if ((item.summaUsd ?? 0) > 0)
                        _buildListCurrency(item.summaUsd, 'USD'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildListCurrency(num? amount, String symbol) {
    final formatter = NumberFormat("#,###", "ru_RU");
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          formatter.format(amount ?? 0).replaceAll(',', ' '),
          style: TextStyle(color: const Color(0xFF1E293B), fontSize: 14.sp, fontWeight: FontWeight.w700),
        ),
        const Gap(4),
        Text(
          symbol,
          style: TextStyle(color: Colors.grey[500], fontSize: 11.sp, fontWeight: FontWeight.w600),
        ),
      ],
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
            Container(height: 180, width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24))),
            const Gap(20),
            Row(
              children: [
                Expanded(child: Container(height: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)))),
                const Gap(16),
                Expanded(child: Container(height: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)))),
              ],
            ),
            const Gap(24),
            Container(height: 250, width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24))),
            const Gap(24),
            ListView.builder(
              shrinkWrap: true,
              itemCount: 3,
              itemBuilder: (_, __) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(height: 70, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
              ),
            )
          ],
        ),
      ),
    );
  }
}
