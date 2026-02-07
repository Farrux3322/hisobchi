import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/app_manager/app_manager_cubit.dart';
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
import 'package:hisobchi/presentation/pages/client/widgets/partner_report_widget.dart';
import 'package:hisobchi/presentation/pages/client/widgets/client_filter_bottom_sheet.dart';
import 'package:hisobchi/presentation/components/subscription/subscription_guard.dart';
import 'package:shimmer/shimmer.dart';

class ClientPage extends StatefulWidget {
  const ClientPage({super.key});

  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  final TextEditingController _searchController = TextEditingController();
  DateTime? filterStartDate;
  DateTime? filterEndDate;
  String? filterSort;
  String? filterStatusFilter;

  @override
  void initState() {
    super.initState();
    _fetchPartners();
  }

  @override
  void dispose() {
    _searchController.dispose();
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

  void _handleFilterApply(DateTime? startDate, DateTime? endDate, String? sort, String? statusFilter) {
    setState(() {
      filterStartDate = startDate;
      filterEndDate = endDate;
      filterSort = sort;
      filterStatusFilter = statusFilter;
    });
    _fetchPartners();
  }

  bool get hasActiveFilters => filterStartDate != null || filterEndDate != null || filterSort != null || filterStatusFilter != null;

  List<PartnerModel> _filterPartners(List<PartnerModel> partners) {
    if (_searchController.text.isEmpty) return partners;

    return partners.where((partner) {
      final name = partner.name?.toLowerCase() ?? '';
      final phone = partner.phone ?? '';
      final query = _searchController.text.toLowerCase();

      return name.contains(query) || phone.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    AppManagerCubit.context = context;
    return DeFocus(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: BlocConsumer<PartnerBloc, PartnerState>(
          listener: (context, state) {
            if (state.statusAdd == Status.success) {
              Toast.showSuccessToast(message: 'Muvaffaqiyatli saqlandi');
              context.read<PartnerBloc>().add(const GetAllEvent());
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
              body: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(title: const Text('Hamkorlar'), elevation: 0, centerTitle: false, pinned: true),
                    SliverToBoxAdapter(
                      child: PartnerReportWidget(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportClientMainPage()));
                        },
                      ),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _DynamicSliverHeaderDelegate(child: _buildHeader(), hasActiveFilters: hasActiveFilters),
                    ),
                  ];
                },
                body: _buildBody(state),
              ),
              floatingActionButton: SubscriptionGuard(
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider(
                          create: (context) => FileUploadBloc(repository: FileUploadRepository()),
                          child: const ClientAddPage(),
                        ),
                      ),
                    ).then((v) {
                      if (v == true && context.mounted) {
                        context.read<PartnerBloc>().add(const GetAllEvent());
                      }
                    });
                  },
                  backgroundColor: AppTheme.colors.primary,
                  child: SvgPicture.asset(AppIcons.clientAdd),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(PartnerState state) {
    if (state.status == Status.loading) {
      return _buildShimmerLoading();
    }

    if (state.models.isEmpty) {
      return _buildEmptyState();
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
            Text('Boshqa kalit so\'z bilan qidiring', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppTheme.colors.primary,
      onRefresh: () async {
        context.read<PartnerBloc>().add(const GetAllEvent());
      },
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: filteredPartners.length,
        itemBuilder: (context, index) {
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
              if (index == filteredPartners.length - 1) Gap(MediaQuery.of(context).padding.bottom),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: ClientFilterField(
        searchController: _searchController,
        hasActiveFilters: hasActiveFilters,
        onFilterTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => ClientFilterBottomSheet(
              initialStartDate: filterStartDate,
              initialEndDate: filterEndDate,
              initialSort: filterSort,
              initialStatusFilter: filterStatusFilter,
              onApply: _handleFilterApply,
            ),
          );
        },
        onSearchChanged: () {
          setState(() {});
          if (_searchController.text.isEmpty || _searchController.text.length >= 2) {
            _fetchPartners();
          }
        },
        onClearSearch: () {
          _searchController.clear();
          setState(() {});
          _fetchPartners();
        },
        startDate: filterStartDate,
        endDate: filterEndDate,
        selectedSort: filterSort,
        selectedStatusFilter: filterStatusFilter,
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
        onRemoveStatusFilter: () {
          setState(() => filterStatusFilter = null);
          _fetchPartners();
        },
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
            SvgPicture.asset(AppIcons.clients, width: 60, height: 60),
            const SizedBox(height: 24),
            const Text(
              'Hamkorlar topilmadi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            Text(
              'Yangi hamkor qo\'shish uchun\npastdagi tugmani bosing',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
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

class _DynamicSliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final bool hasActiveFilters;

  _DynamicSliverHeaderDelegate({required this.child, required this.hasActiveFilters});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => _intrinsicHeight;

  @override
  double get minExtent => _intrinsicHeight;

  double get _intrinsicHeight {
    // Search bar (54.h) + Vert padding (12.h * 2) = 78.h
    // If filters: adds gap (12.h) + chips (32.h) = 122.h
    return hasActiveFilters ? 130.h : 80.h;
  }

  @override
  bool shouldRebuild(_DynamicSliverHeaderDelegate oldDelegate) {
    return oldDelegate.hasActiveFilters != hasActiveFilters || oldDelegate.child != child;
  }
}
