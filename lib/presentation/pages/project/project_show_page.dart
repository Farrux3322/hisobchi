import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hisobchi/application/project/project_bloc.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/dto/models/project/project_model.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/components/toast/toast.dart';
import 'package:hisobchi/presentation/components/utils/phone_formatter.dart';
import 'package:hisobchi/presentation/pages/project/project_edit_page.dart';
import 'package:hisobchi/presentation/pages/project/screens/contract_list_page.dart';
import 'package:hisobchi/presentation/pages/project/screens/project_cost/project_cost_list_page.dart';
import 'package:hisobchi/presentation/pages/project/screens/project_income/project_income_list_page.dart';
import 'package:hisobchi/presentation/pages/project/screens/worker/worker_list_page.dart';
import 'package:intl/intl.dart';
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
            // Ma'lumot yangilanishini kutamiz
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.symmetric(horizontal:  20,vertical: 16),
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
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Loyiha ma\'lumotlari',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              IconButton(
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
                                icon:SvgPicture.asset(AppIcons.edit),
                              ),
                            ],
                          ),
                          const Divider(),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            icon: Icons.business_center,
                            iconColor: Colors.blue,
                            label: 'Loyiha nomi:',
                            value: project.projectName ?? '',
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                            icon: Icons.person,
                            iconColor: Colors.blue,
                            label: 'Loyiha egasi:',
                            value: project.projectOwner ?? '',
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                            icon: Icons.phone,
                            iconColor: Colors.blue,
                            label: 'Tel raqami:',
                            value: PhoneFormatter.formatPhoneNumber(project.phone ?? ''),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                            icon: Icons.location_on,
                            iconColor: Colors.blue,
                            label: 'Manzil:',
                            value: project.address ?? '',
                          ),
                        ],
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
                              amount: _buildAmountText(project.accounts?.debt),
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
                              amount: _buildAmountText(project.accounts?.credit),
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

                          // Deleted project actions
                          if (project.deletedAt != null) ...[
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.red.shade700, size: 24),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Bu loyiha o\'chirilgan',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.red.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildRestoreButton(project),
                            const SizedBox(height: 12),
                            _buildForceDeleteButton(project),
                          ],

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _buildAmountText(CurrencyAmount? amount) {
    if (amount == null) {
      return '0 UZS\n0 \$';
    }
    final uzs = _formatCurrency(amount.uzs);
    final usd = _formatCurrency(amount.usd);
    return '$uzs UZS\n$usd \$';
  }

  Widget _buildInfoRow({required IconData icon, required Color iconColor, required String label, required String value}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: const TextStyle(fontSize: 15, color: Colors.black87)),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }

  Widget _buildActionButton({required String icon, required String label, required String amount, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          SvgPicture.asset(icon),
          // Icon(icon, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Text(
            amount,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            textAlign: TextAlign.right,
          ),
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

  /// Restore button for deleted projects
  Widget _buildRestoreButton(ProjectModel project) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showRestoreDialog(project),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.restore, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Loyihani tiklash',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Force delete button for deleted projects
  Widget _buildForceDeleteButton(ProjectModel project) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showForceDeleteDialog(project),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete_forever, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Butunlay o\'chirish',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Show restore confirmation dialog
  Future<void> _showRestoreDialog(ProjectModel project) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
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
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Icon(Icons.restore, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Loyihani tiklash',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  '${project.projectName} loyihasini tiklashni xohlaysizmi?',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF64748B),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Loyiha barcha ma\'lumotlari bilan tiklanadi',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF059669),
                    ),
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                        ),
                        child: const Text(
                          'Bekor qilish',
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
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Tiklash',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result == true && mounted) {
      HapticFeedback.mediumImpact();
      context.read<ProjectBloc>().add(RestoreProjectEvent(id: project.id!));
      _listenToRestoreResult();
    }
  }

  /// Show force delete confirmation dialog
  Future<void> _showForceDeleteDialog(ProjectModel project) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
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
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Icon(Icons.delete_forever, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 24),
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
                Text(
                  '${project.projectName} loyihasini butunlay o\'chirishni xohlaysizmi?',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF64748B),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        '⚠️ DIQQAT',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Bu amal qaytarib bo\'lmaydi!\nBarcha ma\'lumotlar butunlay yo\'qoladi',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFDC2626),
                        ),
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                        ),
                        child: const Text(
                          'Bekor qilish',
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
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'O\'chirish',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result == true && mounted) {
      HapticFeedback.heavyImpact();
      context.read<ProjectBloc>().add(ForceDeleteProjectEvent(id: project.id!));
      _listenToForceDeleteResult();
    }
  }

  /// Listen to restore result
  void _listenToRestoreResult() {
    final subscription = context.read<ProjectBloc>().stream.listen((state) {
      if (state.statusAdd == Status.success) {
        Toast.showSuccessToast(message: 'Loyiha muvaffaqiyatli tiklandi');
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else if (state.statusAdd == Status.error) {
        Toast.showErrorToast(message: state.errorMessage ?? 'Xatolik yuz berdi');
      }
    });

    Future.delayed(const Duration(seconds: 5), () {
      subscription.cancel();
    });
  }

  /// Listen to force delete result
  void _listenToForceDeleteResult() {
    final subscription = context.read<ProjectBloc>().stream.listen((state) {
      if (state.statusAdd == Status.success) {
        Toast.showSuccessToast(message: 'Loyiha butunlay o\'chirildi');
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else if (state.statusAdd == Status.error) {
        Toast.showErrorToast(message: state.errorMessage ?? 'Xatolik yuz berdi');
      }
    });

    Future.delayed(const Duration(seconds: 5), () {
      subscription.cancel();
    });
  }
}
