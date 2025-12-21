import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/project/project_bloc.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/dto/models/project/project_model.dart';
import 'package:hisobchi/presentation/components/utils/phone_formatter.dart';
import 'package:hisobchi/presentation/pages/project/project_edit_page.dart';
import 'package:hisobchi/presentation/pages/project/screens/contract_list_page.dart';
import 'package:hisobchi/presentation/pages/project/screens/project_cost/project_cost_list_page.dart';
import 'package:hisobchi/presentation/pages/project/screens/project_income/project_income_list_page.dart';
import 'package:hisobchi/presentation/pages/project/screens/worker/worker_list_page.dart';
import 'package:intl/intl.dart';

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
            return const Center(child: CircularProgressIndicator());
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
                                icon: const Icon(Icons.edit_outlined, color: Colors.blue),
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
                              icon: Icons.credit_card,
                              label: 'Kirim',
                              amount: _buildAmountText(project.accounts?.credit),
                              color: Colors.green,
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
                              icon: Icons.credit_card,
                              label: 'Chiqim',
                              amount: _buildAmountText(project.accounts?.debt),
                              color: Colors.red,
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

  Widget _buildActionButton({required IconData icon, required String label, required String amount, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 28),
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
        padding: const EdgeInsets.all(20),
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
}
