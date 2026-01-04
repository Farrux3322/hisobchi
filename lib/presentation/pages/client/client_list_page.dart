import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hisobchi/application/app_manager/app_manager_cubit.dart';
import 'package:hisobchi/application/currency/currency_bloc.dart';
import 'package:hisobchi/application/file_upload/file_upload_bloc.dart';
import 'package:hisobchi/application/partner/partner_bloc.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/dto/models/partner/partner_model.dart';
import 'package:hisobchi/infrastructure/repository/file_upload/file_upload_repository.dart';
import 'package:hisobchi/infrastructure/services/showcase_service.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/components/basic_widgets.dart';
import 'package:hisobchi/presentation/components/toast/toast.dart';
import 'package:hisobchi/presentation/components/utils/price_extension.dart';
import 'package:hisobchi/presentation/pages/client/client_account_page.dart';
import 'package:hisobchi/presentation/pages/client/widgets/client_add_bottom_sheet.dart';
import 'package:hisobchi/presentation/pages/client/widgets/client_card_item.dart';
import 'package:hisobchi/presentation/pages/client/widgets/client_filter_bottom_sheet.dart';
import 'package:hisobchi/presentation/pages/currency/currency_page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:showcaseview/showcaseview.dart';

class ClientPage extends StatefulWidget {
  const ClientPage({super.key});

  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  // Showcase keys
  final GlobalKey _searchKey = GlobalKey();
  final GlobalKey _filterKey = GlobalKey();
  final GlobalKey _addButtonKey = GlobalKey();

  String searchQuery = '';
  DateTime? filterStartDate;
  DateTime? filterEndDate;
  String? filterSort;
  String? filterStatusFilter;

  @override
  void initState() {
    super.initState();
    // Fetch partners when page loads
    _fetchPartners();
    // Fetch exchange rates
    context.read<CurrencyBloc>().add(const GetExchangeRates());
  }


  void _fetchPartners() {
    context.read<PartnerBloc>().add(GetAllEvent(
      startDate: filterStartDate,
      endDate: filterEndDate,
      search: searchQuery.isNotEmpty ? searchQuery : null,
      sort: filterSort,
      statusFilter: filterStatusFilter,
    ));
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

  bool get hasActiveFilters =>
      filterStartDate != null || filterEndDate != null || filterSort != null || filterStatusFilter != null;

  List<PartnerModel> _filterPartners(List<PartnerModel> partners) {
    if (searchQuery.isEmpty) return partners;

    return partners.where((partner) {
      final name = partner.name?.toLowerCase() ?? '';
      final phone = partner.phone ?? '';
      final query = searchQuery.toLowerCase();

      return name.contains(query) || phone.contains(query);
    }).toList();
  }


  @override
  Widget build(BuildContext context) {
    AppManagerCubit.context = context;
    return DeFocus(
      child: BlocConsumer<PartnerBloc, PartnerState>(
        listener: (context, state) {
          // Handle create success
          if (state.statusAdd == Status.success) {
            Toast.showSuccessToast(message: 'Muvaffaqiyatli saqlandi');
            // Refresh the list
            context.read<PartnerBloc>().add(const GetAllEvent());
          }

          // Handle create error
          if (state.statusAdd == Status.error) {
            Toast.showErrorToast(message: state.errorMessage ?? 'Xatolik yuz berdi');
          }

          // Handle fetch error
          if (state.status == Status.error) {
            Toast.showErrorToast(message: state.errorMessage ?? 'Ma\'lumotlarni yuklashda xatolik');
          }
        },
        builder: (context, state) {
          // ignore: deprecated_member_use
          return ShowCaseWidget(
            onFinish: () => ShowcaseService.markShowcaseCompleted('client_showcase_completed'),
            builder: (showcaseContext) {
              // Start showcase after build
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ShowcaseService.checkAndStartShowcase(
                  showcaseKey: 'client_showcase_completed',
                  showcaseContext: showcaseContext,
                  globalKeys: [_searchKey, _filterKey, _addButtonKey],
                );
              });

              return Scaffold(
                // backgroundColor: AppTheme.colors.background,
                body: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      _buildHeader(),
                      Expanded(child: _buildBody(state)),
                    ],
                  ),
                ),
                floatingActionButton: Showcase(
                  key: _addButtonKey,
                  description: 'Bu yerda yangi mijoz qo\'shishingiz mumkin. Ismini, telefon raqamini va boshqa ma\'lumotlarini kiriting.',
                  targetBorderRadius: BorderRadius.circular(28),
                  tooltipBorderRadius: BorderRadius.circular(12),
                  child: FloatingActionButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) =>
                            BlocProvider(
                              create: (context) =>
                                  FileUploadBloc(
                                    repository: FileUploadRepository(),
                                  ),
                              child: AddClientBottomSheet(),
                            ),
                      ).then((v){
                        if(v==true && context.mounted){
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
          );
        },
      ),
    );
  }

  Widget _buildBody(PartnerState state) {
    // Loading state
    if (state.status == Status.loading) {
      return _buildShimmerLoading();
    }

    // Empty state
    if (state.models.isEmpty) {
      return _buildEmptyState();
    }

    // Filter partners based on search
    final filteredPartners = _filterPartners(state.models);

    // No results for search
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

    // Success state with data
    return RefreshIndicator(
      color: AppTheme.colors.primary,
      onRefresh: () async {
        context.read<PartnerBloc>().add(const GetAllEvent());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
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
              if(index==filteredPartners.length-1)Gap(MediaQuery.of(context).padding.bottom)
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Qidiruv
              Row(
                children: [
                  Expanded(
                    child: Showcase(
                      key: _searchKey,
                      description: 'Bu yerda mijozlarni ism yoki telefon raqami bo\'yicha qidirishingiz mumkin.',
                      targetBorderRadius: BorderRadius.circular(12),
                      tooltipBorderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                          },
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Ism, Telefon raqami',
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
                    ),
                  ),
                  const SizedBox(width: 8),
                  Showcase(
                    key: _filterKey,
                    description: 'Filtrlar orqali mijozlarni sana, holat yoki tartiblash bo\'yicha saralashingiz mumkin.',
                    targetBorderRadius: BorderRadius.circular(12),
                    tooltipBorderRadius: BorderRadius.circular(12),
                    child: GestureDetector(
                      onTap: () {
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
                      child: Stack(
                        children: [
                          Container(
                            height: 48,
                            width: 48,
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: hasActiveFilters
                                  ? AppTheme.colors.primary.withValues(alpha: 0.1)
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: hasActiveFilters
                                    ? AppTheme.colors.primary
                                    : AppTheme.colors.colorE1EOEE,
                              ),
                            ),
                            child: SvgPicture.asset(
                              AppIcons.filter,
                              fit: BoxFit.contain,
                              colorFilter: hasActiveFilters
                                  ? ColorFilter.mode(
                                      AppTheme.colors.primary,
                                      BlendMode.srcIn,
                                    )
                                  : null,
                            ),
                          ),
                          if (hasActiveFilters)
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppTheme.colors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 1.5),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Currency widget with real-time USD rate from API
  Widget _buildCurrencyWidget() {
    return BlocBuilder<CurrencyBloc, CurrencyState>(
      builder: (context, state) {
        // Get USD rate from exchange rates
        String usdRate = '...';
        bool isLoading = false;

        if (state.exchangeRatesStatus == Status.loading) {
          isLoading = true;
        } else if (state.exchangeRatesStatus == Status.success &&
                   state.exchangeRateModel != null) {
          try {
            final usdCurrency = state.exchangeRateModel!.rates.firstWhere(
              (rate) => rate.code == 'USD',
              orElse: () => state.exchangeRateModel!.rates.first,
            );
            usdRate = usdCurrency.rate;
          } catch (e) {
            usdRate = '...';
          }
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CurrencyPage()),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                const Text(
                  'USD 1',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.swap_horiz, size: 14, color: Color(0xFF94A3B8)),
                const SizedBox(width: 6),
                if (isLoading)
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 70,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  )
                else
                  Builder(
                    builder: (context) {
                      try {
                        return Text(
                          'UZS ${PriceFormatter.priceFormat(usdRate)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        );
                      } catch (e) {
                        return Text(
                          'UZS $usdRate',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        );
                      }
                    },
                  ),

              ],
            ),
          ),
        );
      },
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
              child: Icon(Icons.people_outline, size: 60, color: Colors.grey[400]),
            ),
            const SizedBox(height: 24),
            const Text(
              'Mijozlar topilmadi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            Text(
              'Yangi mijoz qo\'shish uchun\npastdagi tugmani bosing',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  /// Shimmer loading widget for client list
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
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Avatar shimmer
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                    SizedBox(width: 14.w),
                    // Name shimmer
                    Expanded(
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    // Balance shimmer
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: 80,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: 80,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                // Phone and Date shimmer
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
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
