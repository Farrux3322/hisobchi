import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ehisob/application/project/project_bloc.dart';
import 'package:ehisob/domain/common/constants.dart';
import 'package:ehisob/presentation/assets/asset_index.dart';
import 'package:ehisob/presentation/components/basic_widgets.dart';
import 'package:ehisob/presentation/components/toast/toast.dart';
import 'package:ehisob/presentation/pages/project/project_show_page.dart';
import 'package:ehisob/presentation/pages/project/widgets/project_card_item.dart';
import 'package:ehisob/presentation/pages/project/widgets/project_filter_bottom_sheet.dart';
import 'package:ehisob/presentation/pages/project/components/project_filter_field.dart';
import 'package:ehisob/presentation/components/subscription/subscription_guard.dart';
import 'package:ehisob/presentation/routes/index_routes.dart';
import 'package:ehisob/infrastructure/services/permission_extension.dart';
import 'package:shimmer/shimmer.dart';

class ProjectListPage extends StatefulWidget {
  const ProjectListPage({super.key});

  @override
  State<ProjectListPage> createState() => _ProjectListPageState();
}

class _ProjectListPageState extends State<ProjectListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ProjectBloc>().add(const GetAllProjectEvent());
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final state = context.read<ProjectBloc>().state;
    if (_isBottom && state.statusLoadMore != Status.loading && !state.hasReachedMax) {
      context.read<ProjectBloc>().add(
            LoadMoreProjectsEvent(
              search: state.search,
              status: state.statusFilter,
              date: state.date,
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


  @override
  Widget build(BuildContext context) {
    return DeFocus(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: BlocConsumer<ProjectBloc, ProjectState>(
          listenWhen: (previous, current) => previous.search != current.search || previous.statusAdd != current.statusAdd || previous.status != current.status,
          listener: (context, state) {
            // Synchronize search controller with state
            if (_searchController.text != (state.search ?? '')) {
              _searchController.text = state.search ?? '';
            }

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
              appBar: AppBar(
                title: const Text('Loyihalar'),
                elevation: 0,
                centerTitle: false,
              ),
              body: Column(
                children: [
                  _buildHeader(),
                  Expanded(child: _buildBody(state)),
                ],
              ),
              floatingActionButton: Container(
                margin: EdgeInsets.only(bottom: 72.h),
                child: SubscriptionGuard(
                  child: SizedBox(
                    width: 52.w,
                    height: 52.w,
                    child: FloatingActionButton(
                      heroTag: 'project_fab',
                      elevation: 4,
                      onPressed: () {
                        if (!context.hasPermission('projects.create')) {
                          Toast.showWarningToast(message: 'Sizda bunday huquq yo\'q');
                          return;
                        }
                        context.pushNamed(Routes.projectAddPage.name);
                      },
                      backgroundColor: AppTheme.colors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
                      child: Icon(Icons.add, color: Colors.white, size: 32.sp),
                    ),
                  ),
                ),
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
        return _buildNoResultsState(state);
      }
      return _buildEmptyState(state);
    }

    final projects = state.models;

    return RefreshIndicator(
      color: AppTheme.colors.primary,
      onRefresh: () async {
        context.read<ProjectBloc>().add(const GetAllProjectEvent());
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(
          12.w,
          4.h,
          12.w,
          MediaQuery.of(context).padding.bottom + 96.h,
        ),
        itemCount: state.hasReachedMax ? projects.length : projects.length + 1,
        itemBuilder: (context, index) {
          if (index >= projects.length) {
            return _buildLoadMoreIndicator();
          }
          final project = projects[index];
          return ProjectCardItem(
            projectModel: project,
            onTap: () async {
              final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => ProjectShowPage(projectId: project.id ?? 0)));
              if (context.mounted && result is ProjectShowResult && result.hasChanges) {
                context.read<ProjectBloc>().add(const GetAllProjectEvent());
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      alignment: Alignment.center,
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.colors.primary.withValues(alpha: 0.5)),
        ),
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

  Widget _buildNoResultsState(ProjectState state) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 48.w,
                color: Colors.grey[400],
              ),
            ),
            Gap(24.h),
            Text(
              'Hech narsa topilmadi',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
                letterSpacing: -0.5,
              ),
            ),
            Gap(8.h),
            Text(
              'Tanlangan filtrlar bo\'yicha ma\'lumot yo\'q.\nBoshqa parametrlar bilan qidiring.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[500],
                height: 1.5,
              ),
            ),
            Gap(32.h),
            SizedBox(
              height: 46.h,
              child: Bounce(
                duration: const Duration(milliseconds: 110),
                onPressed: () {
                  if (state.status != Status.loading) {
                    context.read<ProjectBloc>().add(const GetAllProjectEvent(search: '', updateSearch: true, date: null, status: null, updateFilters: true));
                    _searchController.clear();
                  }
                },
                child: OutlinedButton.icon(
                  onPressed: null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.colors.primary,
                    side: BorderSide(color: AppTheme.colors.primary.withValues(alpha: 0.2), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                  ),
                  icon: state.status == Status.loading
                      ? SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.colors.primary),
                          ),
                        )
                      : Icon(Icons.layers_clear_rounded, size: 20.sp),
                  label: Text(
                    'Filtrlarni tozalash',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ProjectState state) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 20.h),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(28.w),
              decoration: BoxDecoration(
                color: AppTheme.colors.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                AppIcons.project,
                width: 64.w,
                height: 64.w,
                colorFilter: ColorFilter.mode(
                  AppTheme.colors.primary.withValues(alpha: 0.4),
                  BlendMode.srcIn,
                ),
              ),
            ),
            Gap(24.h),
            Text(
              'Loyihalar topilmadi',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
                letterSpacing: -0.5,
              ),
            ),
            Gap(8.h),
            Text(
              'Hali hech qanday loyiha qo\'shilmagan\nyoki ma\'lumotlar yuklanmadi',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[500],
                height: 1.5,
              ),
            ),
            Gap(32.h),
            SizedBox(
              height: 46.h,
              child: Bounce(
                duration: const Duration(milliseconds: 110),
                onPressed: () {
                  if (state.status != Status.loading) {
                    context.read<ProjectBloc>().add(const GetAllProjectEvent());
                  }
                },
                child: OutlinedButton.icon(
                  onPressed: null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.colors.primary,
                    side: BorderSide(color: AppTheme.colors.primary.withValues(alpha: 0.2), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                  ),
                  icon: state.status == Status.loading
                      ? SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.colors.primary),
                          ),
                        )
                      : Icon(Icons.refresh_rounded, size: 20.sp),
                  label: Text(
                    'Qayta yuklash',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
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
