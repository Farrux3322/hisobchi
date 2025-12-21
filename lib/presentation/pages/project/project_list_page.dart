import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hisobchi/application/app_manager/app_manager_cubit.dart';
import 'package:hisobchi/application/project/project_bloc.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/dto/models/project/project_model.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/components/basic_widgets.dart';
import 'package:hisobchi/presentation/components/loading/loading.dart';
import 'package:hisobchi/presentation/components/toast/toast.dart';
import 'package:hisobchi/presentation/pages/project/project_show_page.dart';
import 'package:hisobchi/presentation/pages/project/widgets/project_card_item.dart';
import 'package:hisobchi/presentation/routes/index_routes.dart';

class ProjectListPage extends StatefulWidget {
  const ProjectListPage({super.key});

  @override
  State<ProjectListPage> createState() => _ProjectListPageState();
}

class _ProjectListPageState extends State<ProjectListPage> {
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<ProjectBloc>().add(const GetAllProjectEvent());
  }

  List<ProjectModel> _filterProjects(List<ProjectModel> projects) {
    if (searchQuery.isEmpty) return projects;

    return projects.where((project) {
      final name = project.projectName?.toLowerCase() ?? '';
      final owner = project.projectOwner?.toLowerCase() ?? '';
      final phone = project.phone ?? '';
      final query = searchQuery.toLowerCase();

      return name.contains(query) || owner.contains(query) || phone.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    AppManagerCubit.context = context;
    return DeFocus(
      child: BlocConsumer<ProjectBloc, ProjectState>(
        listener: (context, state) {
          if (state.statusAdd == Status.success) {
            Toast.showSuccessToast(message: 'Muvaffaqiyatli saqlandi');
            context.read<ProjectBloc>().add(const GetAllProjectEvent());
          }

          if (state.statusAdd == Status.error) {
            Toast.showErrorToast(message: state.errorMessage ?? 'Xatolik yuz berdi');
          }

          if (state.status == Status.error) {
            Toast.showErrorToast(message: state.errorMessage ?? 'Ma\'lumotlarni yuklashda xatolik');
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(child: _buildBody(state)),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                context.pushNamed(Routes.projectAddPage.name);
              },
              backgroundColor: AppTheme.colors.primary,
              child: SvgPicture.asset(AppIcons.projectAdd),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(ProjectState state) {
    if (state.status == Status.loading) {
      return Loading();
    }

    if (state.models.isEmpty) {
      return _buildEmptyState();
    }

    final filteredProjects = _filterProjects(state.models);

    if (filteredProjects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Hech narsa topilmadi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            Text('Boshqa kalit so\'z bilan qidiring', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppTheme.colors.primary,
      onRefresh: () async {
        context.read<ProjectBloc>().add(const GetAllProjectEvent());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredProjects.length,
        itemBuilder: (context, index) {
          final project = filteredProjects[index];
          return Column(
            children: [
              ProjectCardItem(
                projectModel: project,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProjectShowPage(projectId: project.id ?? 0),
                    ),
                  ).then((_) {
                    if (context.mounted) {
                      context.read<ProjectBloc>().add(const GetAllProjectEvent());
                    }
                  });
                },
              ),
              if(index==filteredProjects.length-1)Gap(MediaQuery.of(context).padding.bottom)
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Logo va valyuta
          const Text(
            'Loyihalar',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 16),

          // Qidiruv
          Container(
            height: 48, // Fixed height qo'shamiz
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Qidiruv...',
                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                prefixIcon: Padding(
                  padding: EdgeInsets.only(left: 10.w),
                  child: const Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding:  EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(60)),
              child: Icon(Icons.business_outlined, size: 60, color: Colors.grey[400]),
            ),
            const SizedBox(height: 24),
            const Text(
              'Loyihalar topilmadi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            Text(
              'Yangi loyiha qo\'shish uchun\npastdagi tugmani bosing',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
