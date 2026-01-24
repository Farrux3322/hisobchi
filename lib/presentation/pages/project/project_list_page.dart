import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/app_manager/app_manager_cubit.dart';
import 'package:hisobchi/application/project/project_bloc.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/dto/models/project/project_model.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/components/basic_widgets.dart';
import 'package:hisobchi/presentation/components/toast/toast.dart';
import 'package:hisobchi/presentation/pages/project/project_show_page.dart';
import 'package:hisobchi/presentation/pages/project/widgets/project_card_item.dart';
import 'package:hisobchi/presentation/pages/project/widgets/project_filter_bottom_sheet.dart';
import 'package:hisobchi/presentation/pages/project/components/project_filter_field.dart';
import 'package:hisobchi/presentation/routes/index_routes.dart';
import 'package:shimmer/shimmer.dart';

class ProjectListPage extends StatefulWidget {
  const ProjectListPage({super.key});

  @override
  State<ProjectListPage> createState() => _ProjectListPageState();
}

class _ProjectListPageState extends State<ProjectListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ProjectBloc>().add(const GetAllProjectEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    AppManagerCubit.context = context;
    return DeFocus(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
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
              backgroundColor: const Color(0xFFF8FAFC),
              appBar: AppBar(
                title: const Text('Loyihalar'),
                backgroundColor: Colors.white,
                elevation: 0,
                centerTitle: false,
                titleTextStyle: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
              ),
              body: Column(
                children: [
                  _buildHeader(),
                  Expanded(child: _buildBody(state)),
                ],
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
      ),
    );
  }

  Widget _buildBody(ProjectState state) {
    if (state.status == Status.loading) {
      return _buildShimmerLoading();
    }

    if (state.models.isEmpty) {
      if (state.search != null || state.statusFilter != null || state.date != null) {
        return _buildNoResultsState();
      }
      return _buildEmptyState();
    }

    final projects = state.models;

    return RefreshIndicator(
      color: AppTheme.colors.primary,
      onRefresh: () async {
        context.read<ProjectBloc>().add(const GetAllProjectEvent());
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final project = projects[index];
          return ProjectCardItem(
            projectModel: project,
            onTap: () async {
              final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => ProjectShowPage(projectId: project.id ?? 0)));
              if (context.mounted) {
                if (result is ProjectShowResult && result.hasChanges) {
                  context.read<ProjectBloc>().add(const GetAllProjectEvent());
                } else if (result == true) {
                  context.read<ProjectBloc>().add(const GetAllProjectEvent());
                }
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    final state = context.watch<ProjectBloc>().state;
    final hasActiveFilter = state.statusFilter != null || state.date != null;

    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ProjectFilterField(
        searchController: _searchController,
        hasActiveFilters: hasActiveFilter,
        date: state.date,
        statusFilter: state.statusFilter,
        onFilterTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const ProjectFilterBottomSheet(),
          );
        },
        onSearchChanged: (value) {
          context.read<ProjectBloc>().add(GetAllProjectEvent(search: value, updateSearch: true));
        },
        onClearSearch: () {
          _searchController.clear();
          context.read<ProjectBloc>().add(const GetAllProjectEvent(search: '', updateSearch: true));
        },
        onRemoveDate: () {
          context.read<ProjectBloc>().add(const GetAllProjectEvent(date: null, updateFilters: true));
        },
        onRemoveStatusFilter: () {
          context.read<ProjectBloc>().add(const GetAllProjectEvent(status: null, updateFilters: true));
        },
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[300]),
          const Gap(16),
          const Text(
            'Hech narsa topilmadi',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
          ),
          const Gap(8),
          Text(
            'Tanlangan filtrlar bo\'yicha ma\'lumot yo\'q.\nBoshqa parametrlar bilan qidiring.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[500], height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(60)),
              child: SvgPicture.asset(AppIcons.project,width: 60,height: 60,),
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

  /// Shimmer loading widget for project list
  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Project Icon shimmer
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: 52.w,
                        height: 52.h,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14.r)),
                      ),
                    ),
                    SizedBox(width: 14.w),
                    // Project Name and Owner shimmer
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    height: 16,
                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  width: 60.w,
                                  height: 20.h,
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.r)),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: 120,
                              height: 14,
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                // Address shimmer (optional - sometimes shown)
                if (index % 2 == 0) ...[
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
                    ),
                  ),
                  SizedBox(height: 8.h),
                ],
                // Phone and Date shimmer
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
