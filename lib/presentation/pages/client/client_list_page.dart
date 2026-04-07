import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/file_upload/file_upload_bloc.dart';
import 'package:hisobchi/application/partner/partner_bloc.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/dto/models/partner/partner_model.dart';
import 'package:hisobchi/infrastructure/repository/file_upload/file_upload_repository.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/components/basic_widgets.dart';
import 'package:hisobchi/presentation/components/toast/toast.dart';
import 'package:hisobchi/presentation/pages/client/client_account_page.dart';
import 'package:hisobchi/presentation/pages/client/components/client_filter_field.dart';
import 'package:hisobchi/presentation/pages/client/report/report_client_main_page.dart';
import 'package:hisobchi/presentation/pages/client/client_add_page.dart';
import 'package:hisobchi/presentation/pages/client/widgets/client_card_item.dart';
import 'package:hisobchi/presentation/pages/client/widgets/client_filter_bottom_sheet.dart';
import 'package:hisobchi/infrastructure/services/permission_extension.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import 'package:hisobchi/presentation/routes/entity/routes.dart';

import '../../components/subscription/subscription_guard.dart';

// Status tab definition
class _StatusTab {
  final String label;
  final String? value;

  const _StatusTab({required this.label, required this.value});
}

const _statusTabs = [
  _StatusTab(label: 'Barchasi', value: null),
  _StatusTab(label: 'Haqdor', value: 'xaqdor'),
  _StatusTab(label: 'Qarzdor', value: 'qarzdor'),
  _StatusTab(label: "Muddati o'tgan", value: 'muddati_otgan_qarzdor'),
];

class ClientPage extends StatefulWidget {
  const ClientPage({super.key});

  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  DateTime? filterStartDate;
  DateTime? filterEndDate;
  String? filterSort;

  late TabController _tabController;

  // Derived from tab selection
  String? get filterStatusFilter => _statusTabs[_tabController.index].value;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusTabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _fetchPartners();
        setState(() {});
      }
    });
    _fetchPartners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _fetchPartners() {
    context.read<PartnerBloc>().add(
      GetAllEvent(
        startDate: filterStartDate,
        endDate: filterEndDate,
        search: _searchController.text.trim().isNotEmpty ? _searchController.text.trim() : null,
        sort: filterSort,
        statusFilter: filterStatusFilter,
      ),
    );
  }

  void _handleFilterApply(DateTime? startDate, DateTime? endDate, String? sort) {
    setState(() {
      filterStartDate = startDate;
      filterEndDate = endDate;
      filterSort = sort;
    });
    _fetchPartners();
  }

  bool get hasActiveFilters => filterStartDate != null || filterEndDate != null || filterSort != null;

  List<PartnerModel> _filterPartners(List<PartnerModel> partners) {
    if (_searchController.text.isEmpty) return partners;
    return partners.where((partner) {
      final name = partner.name?.toLowerCase() ?? '';
      final phone = partner.phone ?? '';
      final activity = partner.activity?.toLowerCase() ?? '';
      final query = _searchController.text.toLowerCase();
      return name.contains(query) || phone.contains(query) || activity.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: DeFocus(
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          child: BlocConsumer<PartnerBloc, PartnerState>(
            listener: (context, state) {
              if (state.statusAdd == Status.success) {
                Toast.showSuccessToast(message: 'Muvaffaqiyatli saqlandi');
              }
              if (state.statusAdd == Status.error) {
                Toast.showErrorToast(message: state.errorMessage ?? 'Xatolik yuz berdi');
              }
              if (state.status == Status.error) {
                Toast.showErrorToast(message: state.errorMessage ?? "Ma'lumotlarni yuklashda xatolik");
              }
            },
            builder: (context, state) {
              return Scaffold(
                body: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _ClientHeaderDelegate(child: _buildHeader(), hasActiveFilters: hasActiveFilters),
                      ),
                    ];
                  },
                  body: TabBarView(controller: _tabController, children: _statusTabs.map((_) => _buildBody(state)).toList()),
                ),
                floatingActionButton: SubscriptionGuard(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 56.w,
                        height: 56.w,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18.r),
                          child: FloatingActionButton(
                            tooltip: "Mijozlar hisoboti",
                            heroTag: 'client_report_fab',
                            elevation: 0,
                            focusElevation: 0,
                            hoverElevation: 0,
                            highlightElevation: 0,
                            onPressed: () {
                              if (!context.hasPermission('report_partners.view')) {
                                Toast.showWarningToast(message: "Sizda bunday huquq yo'q");
                                return;
                              }
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportClientMainPage()));
                            },
                            backgroundColor: AppTheme.colors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.r),
                              side: BorderSide(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                            ),
                            child: Icon(Icons.analytics_rounded, color: AppTheme.colors.white, size: 28.sp),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      SizedBox(
                        width: 56.w,
                        height: 56.w,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18.r),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: FloatingActionButton(
                              heroTag: 'client_fab',
                              elevation: 0,
                              focusElevation: 0,
                              hoverElevation: 0,
                              highlightElevation: 0,
                              onPressed: () {
                                if (!context.hasPermission('partners.create')) {
                                  Toast.showWarningToast(message: "Sizda bunday huquq yo'q");
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BlocProvider(
                                      create: (context) => FileUploadBloc(repository: FileUploadRepository()),
                                      child: const ClientAddPage(),
                                    ),
                                  ),
                                ).then((v) {
                                  if (v is PartnerModel && context.mounted) {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => AccountPage(partnerModel: v))).then((_) {
                                      if (context.mounted) {
                                        context.read<PartnerBloc>().add(const GetAllEvent());
                                      }
                                    });
                                  } else if (v == true && context.mounted) {
                                    context.read<PartnerBloc>().add(const GetAllEvent());
                                  }
                                });
                              },
                              backgroundColor: AppTheme.colors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.r),
                                side: BorderSide(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                              ),
                              child: Icon(Icons.add, color: Colors.white, size: 36.sp),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(PartnerState state) {
    if (state.status == Status.loading) {
      return _buildShimmerLoading();
    }

    if (state.models.isEmpty) {
      return _buildEmptyState(state);
    }

    final filteredPartners = _filterPartners(state.models);

    if (filteredPartners.isEmpty) {
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
            Text("Boshqa kalit so'z bilan qidiring", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo is ScrollUpdateNotification) {
          final maxScroll = scrollInfo.metrics.maxScrollExtent;
          final currentScroll = scrollInfo.metrics.pixels;
          if (currentScroll >= (maxScroll * 0.9) && state.statusLoadMore != Status.loading && !state.hasReachedMax) {
            context.read<PartnerBloc>().add(
              LoadMorePartnersEvent(
                startDate: filterStartDate,
                endDate: filterEndDate,
                search: _searchController.text.trim().isNotEmpty ? _searchController.text.trim() : null,
                sort: filterSort,
                statusFilter: filterStatusFilter,
              ),
            );
          }
        }
        return false;
      },
      child: RefreshIndicator(
        color: AppTheme.colors.primary,
        onRefresh: () async {
          context.read<PartnerBloc>().add(const GetAllEvent());
        },
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          itemCount: state.hasReachedMax ? filteredPartners.length : filteredPartners.length + 1,
          itemBuilder: (context, index) {
            if (index >= filteredPartners.length) {
              return _buildLoadMoreIndicator();
            }
            final partner = filteredPartners[index];
            return Column(
              children: [
                ClientCardItem(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => AccountPage(partnerModel: partner))).then((v) {
                      if (v == true && context.mounted) {
                        context.read<PartnerBloc>().add(const GetAllEvent());
                      }
                    });
                  },
                  partnerModel: partner,
                ),
                if (index == filteredPartners.length - 1 && state.hasReachedMax) Gap(MediaQuery.of(context).padding.bottom + 20.h),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 32.h),
      alignment: Alignment.center,
      child: SizedBox(
        width: 24.w,
        height: 24.w,
        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppTheme.colors.primary.withValues(alpha: 0.5))),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppTheme.colors.background,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search + filter
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
            child: ClientFilterField(
              searchController: _searchController,
              hasActiveFilters: hasActiveFilters,
              onFilterTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => ClientFilterBottomSheet(initialStartDate: filterStartDate, initialEndDate: filterEndDate, initialSort: filterSort, onApply: _handleFilterApply),
                );
              },
              onSearchChanged: () {
                setState(() {});
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 500), () {
                  if (_searchController.text.isEmpty || _searchController.text.length >= 2) {
                    _fetchPartners();
                  }
                });
              },
              onClearSearch: () {
                _searchController.clear();
                setState(() {});
                _fetchPartners();
              },
              startDate: filterStartDate,
              endDate: filterEndDate,
              selectedSort: filterSort,
              onRemoveDate: () {
                setState(() {
                  filterStartDate = null;
                  filterEndDate = null;
                });
                _fetchPartners();
              },
              onRemoveSort: () {
                setState(() => filterSort = null);
                _fetchPartners();
              },
            ),
          ),
          // Status TabBar
          _buildStatusTabBar(),
        ],
      ),
    );
  }

  Widget _buildStatusTabBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(0.w, 8.h, 0.w, 12.h),
      child: Container(
        height: 46.h,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppTheme.colors.background, // Subtle grey background
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
          labelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
          unselectedLabelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
          labelColor: const Color(0xFF0F172A),
          unselectedLabelColor: const Color(0xFF64748B),
          padding: EdgeInsets.zero,
          labelPadding: EdgeInsets.symmetric(horizontal: 16.w),
          tabs: _statusTabs.map((tab) {
            return Tab(height: 38.h, text: tab.label);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState(PartnerState state) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 20.h),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(color: AppTheme.colors.primary.withValues(alpha: 0.05), shape: BoxShape.circle),
              child: SvgPicture.asset(AppIcons.clients, width: 64.w, height: 64.w, colorFilter: ColorFilter.mode(AppTheme.colors.primary.withValues(alpha: 0.4), BlendMode.srcIn)),
            ),
            Gap(24.h),
            Text(
              'Mijozlar topilmadi',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B), letterSpacing: -0.5),
            ),
            Gap(8.h),
            Text(
              "Hali hech qanday mijoz qo'shilmagan\nyoki ma'lumotlar yuklanmadi",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[500], height: 1.5),
            ),
            Gap(32.h),
            SizedBox(
              height: 46.h,
              child: Bounce(
                duration: const Duration(milliseconds: 110),
                onPressed: () {
                  if (state.status != Status.loading) {
                    _fetchPartners();
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
                          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppTheme.colors.primary)),
                        )
                      : Icon(Icons.refresh_rounded, size: 20.sp),
                  label: Text(
                    'Qayta yuklash',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          decoration: BoxDecoration(
            color: AppTheme.colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppTheme.colors.divider),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.r)),
                      ),
                    ),
                    SizedBox(width: 14.w),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: 80,
                            height: 14,
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: 80,
                            height: 14,
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 32,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.r)),
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

// ─── Header Delegate ──────────────────────────────────────────────────────────

class _ClientHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final bool hasActiveFilters;

  _ClientHeaderDelegate({required this.child, required this.hasActiveFilters});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(height: _height, child: child);
  }

  @override
  double get maxExtent => _height;

  @override
  double get minExtent => _height;

  double get _height {
    // Search row: 12.h (top padding) + 54.h (field) = 66.h
    // TabBar row (Segmented style): 46.h + 8.h + 12.h = 66.h
    // Filter chips (if active): 12.h gap + 32.h = 44.h
    final base = 66.h + 66.h; // 132.h
    return hasActiveFilters ? base + 44.h : base;
  }

  @override
  bool shouldRebuild(_ClientHeaderDelegate oldDelegate) => oldDelegate.hasActiveFilters != hasActiveFilters || oldDelegate.child != child;
}
