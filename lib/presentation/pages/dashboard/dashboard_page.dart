import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hisobchi/application/app_manager/app_manager_cubit.dart';
import 'package:hisobchi/application/client_report/client_report_bloc.dart';
import 'package:hisobchi/application/currency/currency_bloc.dart';
import 'package:hisobchi/application/dashboard/dashboard_bloc.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/repository/client_report/client_report_repository.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/components/toast/toast.dart';
import 'package:hisobchi/presentation/components/utils/price_extension.dart';
import 'package:hisobchi/presentation/pages/currency/currency_page.dart';
import 'package:hisobchi/presentation/pages/dashboard/client_report/client_report_main_page.dart';
import 'package:shimmer/shimmer.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Showcase keys


  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(const GetDashboardEvent());
    context.read<CurrencyBloc>().add(const GetExchangeRates());
  }


  @override
  Widget build(BuildContext context) {
    AppManagerCubit.context = context;
    // ignore: deprecated_member_use
    return Scaffold(
      // backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: BlocConsumer<DashboardBloc, DashboardState>(
          listener: (context, state) {
            if (state.status == Status.error) {
              Toast.showErrorToast(
                message: state.errorMessage ?? 'Ma\'lumotlarni yuklashda xatolik',
              );
            }
          },
          builder: (context, state) {
            return RefreshIndicator(
              color: AppTheme.colors.primary,
              onRefresh: () async {
                context.read<DashboardBloc>().add(const GetDashboardEvent());
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Header
                  SliverToBoxAdapter(child: _buildHeader()),

                  // Stats Cards
                  if (state.status == Status.loading)
                    SliverToBoxAdapter(child: _buildLoadingState())
                  else if (state.status == Status.success && state.dashboardModel?.result != null)
                    SliverToBoxAdapter(
                      child: _buildDashboardContent(state.dashboardModel!.result!),
                    )
                  else
                    SliverFillRemaining(
                      child: _buildEmptyState(),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(AppIcons.appLogo, width: 40.w, height: 40.h),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'E-Hisob',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.colors.black,
                        ),
                      ),
                      Text(
                        'Bosh sahifa',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              _buildCurrencyWidget(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyWidget() {
    return BlocBuilder<CurrencyBloc, CurrencyState>(
      builder: (context, state) {
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
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(8.r),
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
                Text(
                  'USD 1',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF1E293B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 6.w),
                Icon(Icons.swap_horiz, size: 14.sp, color: const Color(0xFF94A3B8)),
                SizedBox(width: 6.w),
                if (isLoading)
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 70.w,
                      height: 12.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  )
                else
                  Builder(
                    builder: (context) {
                      try {
                        return Text(
                          'UZS ${PriceFormatter.priceFormat(usdRate)}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E293B),
                          ),
                        );
                      } catch (e) {
                        return Text(
                          'UZS $usdRate',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E293B),
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

  Widget _buildDashboardContent(result) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          _buildWelcomeCard(),
          SizedBox(height: 16.h),

          // Stats Grid
          _buildStatsGrid(result),
          SizedBox(height: 16.h),

          // Balance Card
          _buildBalanceCard(result),SizedBox(height: 16.h),

          // Late Payments Warning
          if ((result.partnersWithLatePaymentsCount ?? 0) > 0)
            _buildLatePaymentsCard(result.partnersWithLatePaymentsCount ?? 0),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.colors.primary,
            AppTheme.colors.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.colors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Xush kelibsiz! 👋',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Umumiy natijalaringiz bilan tanishing',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(result) {
    return Row(
      children: [
        Expanded(
          child:  GestureDetector(
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider(
                    create: (context) => ClientReportBloc(
                      repository: ClientReportRepository(),
                    ),
                    child: const ClientReportMainPage(),
                  ),
                ),
              );
            },
            child: _buildStatCard(
              icon: AppIcons.clients,
              title: 'Hamkorlar',
              value: '${result.totalPartnersCount ?? 0}',
              color: const Color(0xFF10B981),
              iconBgColor: const Color(0xFFD1FAE5),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard(
            icon: AppIcons.project,
            title: 'Loyihalar',
            value: '${result.totalProjectsCount ?? 0}',
            color: const Color(0xFF3B82F6),
            iconBgColor: const Color(0xFFDBEAFE),
          )
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String icon,
    required String title,
    required String value,
    required Color color,
    required Color iconBgColor,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: SvgPicture.asset(
                  icon,
                  width: 24.w,
                  height: 24.h,
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),

            ],
          ),
          SizedBox(width: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.colors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(result) {
    final uzs = result.totalDebtCreditPartners?.uzs ?? 0;
    final usd = result.totalDebtCreditPartners?.usd ?? 0;
    final isPositiveUzs = uzs >= 0;
    final isPositiveUsd = usd >= 0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: SvgPicture.asset(
                  AppIcons.balance,
                  width: 24.w,
                  height: 24.h,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFFF59E0B),
                    BlendMode.srcIn,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Umumiy balans',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // UZS Balance
          _buildBalanceRow(
            currency: 'UZS',
            amount: uzs,
            isPositive: isPositiveUzs,
          ),

          SizedBox(height: 12.h),
          Divider(color: AppTheme.colors.colorE1EOEE),
          SizedBox(height: 12.h),

          // USD Balance
          _buildBalanceRow(
            currency: 'USD',
            amount: usd,
            isPositive: isPositiveUsd,
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceRow({
    required String currency,
    required num amount,
    required bool isPositive,
  }) {
    final color = isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final icon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;
    final prefix = isPositive ? '+' : '';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, size: 16.sp, color: color),
            ),
            SizedBox(width: 12.w),
            Text(
              currency,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
        Text(
          '$prefix${PriceFormatter.priceFormat(amount.toString())}',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildLatePaymentsCard(int count) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.warning_rounded,
              color: const Color(0xFFEF4444),
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kech to\'lovlar',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFEF4444),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '$count ta hamkor to\'lovni kechiktirmoqda',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF991B1B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          // Welcome Card Shimmer
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: double.infinity,
              height: 120.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Stats Grid Shimmer
          Row(
            children: [
              Expanded(
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 140.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 140.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Balance Card Shimmer
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: double.infinity,
              height: 180.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120.w,
            height: 120.h,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(60.r),
            ),
            child: Icon(
              Icons.dashboard_outlined,
              size: 60.sp,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Ma\'lumot topilmadi',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Dashboard ma\'lumotlarini\nyuklashda xatolik yuz berdi',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
