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
import 'package:hisobchi/presentation/pages/project/screens/project_cost/project_cost_list_page.dart';
import 'package:hisobchi/presentation/pages/project/screens/project_income/project_income_list_page.dart';
import 'package:hisobchi/presentation/pages/project/screens/worker/worker_list_page.dart';
import 'package:hisobchi/presentation/pages/project/screens/report/project_report_page.dart';
import 'package:shimmer/shimmer.dart';

class ProjectShowPage extends StatefulWidget {
  final int projectId;

  const ProjectShowPage({super.key, required this.projectId});

  @override
  State<ProjectShowPage> createState() => _ProjectShowPageState();
}

class _ProjectShowPageState extends State<ProjectShowPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProjectBloc>().add(GetProjectByIdEvent(id: widget.projectId));
  }

  String _formatCurrency(num? value) {
    if (value == null) return '0';
    final formatter = NumberFormat('#,###', 'en_US');
    return formatter.format(value).replaceAll(',', ' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Loyiha tafsilotlari',
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: BlocBuilder<ProjectBloc, ProjectState>(
        buildWhen: (previous, current) => previous.statusDetail != current.statusDetail || previous.selectedProject != current.selectedProject,
        builder: (context, state) {
          if (state.statusDetail == Status.loading) {
            return _buildLoadingShimmer();
          }

          if (state.statusDetail == Status.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      state.errorMessage ?? 'Xatolik yuz berdi',
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ProjectBloc>().add(GetProjectByIdEvent(id: widget.projectId));
                      },
                      child: const Text('Qayta urinish'),
                    ),
                  ],
                ),
              ),
            );
          }

          final project = state.selectedProject;
          if (project == null) {
            return const Center(child: Text('Loyiha topilmadi'));
          }

          return _buildContent(project);
        },
      ),
    );
  }

  Widget _buildContent(ProjectModel project) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return RefreshIndicator(
          onRefresh: () async {
            context.read<ProjectBloc>().add(GetProjectByIdEvent(id: widget.projectId));
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                    Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          initiallyExpanded: false,
                          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          childrenPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 12),
                          collapsedShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [Colors.blue.shade400, Colors.blue.shade600],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius: BorderRadius.circular(10),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.blue.withValues(alpha: 0.3),
                                                    blurRadius: 6,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(Icons.business_center, color: Colors.white, size: 20),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Loyiha nomi',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.grey.shade600,
                                                      letterSpacing: 0.2,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    project.projectName ?? '-',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w700,
                                                      color: Color(0xFF1E293B),
                                                      letterSpacing: -0.3,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [Colors.purple.shade400, Colors.purple.shade600],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius: BorderRadius.circular(10),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.purple.withValues(alpha: 0.3),
                                                    blurRadius: 6,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(Icons.person, color: Colors.white, size: 20),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Loyiha egasi',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.grey.shade600,
                                                      letterSpacing: 0.2,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    project.projectOwner ?? '-',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w700,
                                                      color: Color(0xFF1E293B),
                                                      letterSpacing: -0.3,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ProjectEditPage(projectModel: project)),
                                ).then((v) {
                                  if (v == true && context.mounted) {
                                    context.read<ProjectBloc>().add(GetProjectByIdEvent(id: widget.projectId));
                                  }
                                });
                              },
                              icon: SvgPicture.asset(AppIcons.edit),
                              iconSize: 18,
                              padding: const EdgeInsets.all(8),
                              constraints: const BoxConstraints(),
                              tooltip: 'Tahrirlash',
                            ),
                          ),
                          children: [
                            const Divider(height: 1, thickness: 1.5, color: Color(0xFFE2E8F0)),
                            const SizedBox(height: 16),
                            _buildCompactInfoRow(
                              icon: Icons.phone,
                              iconColor: const Color(0xFF10B981),
                              label: 'Tel raqami',
                              value: PhoneFormatter.formatPhoneNumber(project.phone ?? ''),
                            ),
                            const SizedBox(height: 14),
                            _buildCompactInfoRow(
                              icon: Icons.location_on,
                              iconColor: const Color(0xFFEF4444),
                              label: 'Manzil',
                              value: project.address ?? '',
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProjectIncomeListPage(projectId: project.id ?? 0),
                                ),
                              ).then((_) {
                                // Income sahifasidan qaytganda refresh qilamiz
                                if (context.mounted) {
                                  context.read<ProjectBloc>().add(GetProjectByIdEvent(id: widget.projectId));
                                }
                              });
                            },
                            child: _buildActionButton(
                              icon: AppIcons.income,
                              label: 'Kirim',
                              amountWidget: _buildAmountWidget(project.accounts?.debt),
                              color: Color(0xFF3CC293),
                            ),
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProjectCostListPage(projectId: project.id ?? 0),
                                ),
                              ).then((_) {
                                // Cost sahifasidan qaytganda refresh qilamiz
                                if (context.mounted) {
                                  context.read<ProjectBloc>().add(GetProjectByIdEvent(id: widget.projectId));
                                }
                              });
                            },
                            child: _buildActionButton(
                              icon: AppIcons.chiqim,
                              label: 'Chiqim',
                              amountWidget: _buildAmountWidget(project.accounts?.credit),
                              color: Color(0xFFDE5050),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildMenuButton(
                            icon: Icons.description,
                            label: 'Shartnoma',
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => ContractListPage(projectId: project.id ?? 0)));
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildMenuButton(
                            icon: Icons.people,
                            label: 'Ishchilar',
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => WorkerListPage(projectId: project.id ?? 0)));
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildMenuButton(
                            icon: Icons.edit_document,
                            label: 'Hisobot',
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => ProjectReportPage(projectId: project.id ?? 0)));
                            },
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
            ),
          ),
        );
      },
    );
  }

  /// Senior darajadagi amount widget - RichText bilan formatlangan
  Widget _buildAmountWidget(CurrencyAmount? amount) {
    if (amount == null) {
      return RichText(
        textAlign: TextAlign.right,
        text: const TextSpan(
          children: [
            TextSpan(
              text: '0 ',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            TextSpan(
              text: 'UZS',
              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
            ),
            TextSpan(
              text: '\n0 ',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            TextSpan(
              text: 'USD',
              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }
    final uzs = _formatCurrency(amount.uzs);
    final usd = _formatCurrency(amount.usd);
    return RichText(
      textAlign: TextAlign.right,
      text: TextSpan(
        children: [
          TextSpan(
            text: '$uzs ',
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const TextSpan(
            text: 'UZS',
            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
          ),
          TextSpan(
            text: '\n$usd ',
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const TextSpan(
            text: 'USD',
            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  /// Senior darajadagi compact info row widget
  Widget _buildCompactInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            iconColor.withValues(alpha: 0.05),
            iconColor.withValues(alpha: 0.02),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? '-' : value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Senior darajadagi action button - RichText amount bilan
  Widget _buildActionButton({
    required String icon,
    required String label,
    required Widget amountWidget,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          SvgPicture.asset(icon),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          amountWidget,
        ],
      ),
    );
  }

  Widget _buildMenuButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal:  20,vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: Colors.blue, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Loyiha ma'lumotlari shimmer
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildShimmerBox(width: 150, height: 20),
                    _buildShimmerBox(width: 40, height: 40, borderRadius: 20),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                _buildShimmerInfoRow(),
                const SizedBox(height: 16),
                _buildShimmerInfoRow(),
                const SizedBox(height: 16),
                _buildShimmerInfoRow(),
                const SizedBox(height: 16),
                _buildShimmerInfoRow(),
              ],
            ),
          ),
          // Action buttons shimmer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildShimmerActionButton(color: Colors.green),
                const SizedBox(height: 12),
                _buildShimmerActionButton(color: Colors.red),
                const SizedBox(height: 12),
                _buildShimmerMenuButton(),
                const SizedBox(height: 12),
                _buildShimmerMenuButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerBox({required double width, required double height, double borderRadius = 8}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  Widget _buildShimmerInfoRow() {
    return Row(
      children: [
        _buildShimmerBox(width: 36, height: 36, borderRadius: 8),
        const SizedBox(width: 12),
        Expanded(
          child: _buildShimmerBox(width: double.infinity, height: 16),
        ),
        const SizedBox(width: 12),
        _buildShimmerBox(width: 100, height: 16),
      ],
    );
  }

  Widget _buildShimmerActionButton({required Color color}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildShimmerBox(width: 28, height: 28, borderRadius: 14),
          const SizedBox(width: 12),
          _buildShimmerBox(width: 60, height: 18),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildShimmerBox(width: 80, height: 16),
              const SizedBox(height: 4),
              _buildShimmerBox(width: 60, height: 16),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerMenuButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          _buildShimmerBox(width: 40, height: 40, borderRadius: 8),
          const SizedBox(width: 12),
          _buildShimmerBox(width: 100, height: 16),
          const Spacer(),
          _buildShimmerBox(width: 24, height: 24, borderRadius: 12),
        ],
      ),
    );
  }
}
