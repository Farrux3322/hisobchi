import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ehisob/application/currency/currency_bloc.dart';
import 'package:ehisob/application/dashboard/dashboard_bloc.dart';
import 'package:ehisob/application/project/project_bloc.dart';
import 'package:ehisob/domain/common/constants.dart';
import 'package:ehisob/presentation/assets/asset_index.dart';
import 'package:ehisob/presentation/components/utils/price_extension.dart';

import '../currency/currency_page.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/dashboard_quick_actions.dart';
import 'widgets/dashboard_urgent_banner.dart';
import 'widgets/dashboard_shimmer.dart';
import 'widgets/debt_control_card.dart';
import 'widgets/project_control_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(const LoadDashboard());
    context.read<CurrencyBloc>().add(const GetExchangeRates());

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToProjects({String? status}) {
    StatefulNavigationShell.of(context).goBranch(2);
    if (status != null) {
      context
          .read<ProjectBloc>()
          .add(GetAllProjectEvent(status: status, updateFilters: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: const Color(0xFFF8FAFC),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppTheme.colors.primary.withValues(alpha: 0.15),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Image.asset(AppIcons.appLogo, width: 22.w, height: 22.h),
            ),
            SizedBox(width: 10.w),
            Text(
              'EHisob',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
        actions: [
          _buildCurrencyWidget(),
          SizedBox(width: 16.w),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          return RefreshIndicator(
            color: AppTheme.colors.primary,
            onRefresh: () async {
              context.read<DashboardBloc>().add(const LoadDashboard());
              context.read<CurrencyBloc>().add(const GetExchangeRates());
            },
            child: _buildBodyContent(state),
          );
        },
      ),
    );
  }

  Widget _buildCurrencyWidget() {
    return BlocBuilder<CurrencyBloc, CurrencyState>(
      builder: (context, state) {
        String usdRate = '1';
        bool isLoading = state.exchangeRatesStatus == Status.loading;

        if (state.exchangeRatesStatus == Status.success &&
            state.exchangeRateModel != null) {
          try {
            final usdCurrency = state.exchangeRateModel!.rates.firstWhere(
              (rate) => rate.code == 'USD',
              orElse: () => state.exchangeRateModel!.rates.first,
            );
            usdRate = usdCurrency.rate;
          } catch (_) {
            usdRate = '...';
          }
        }

        return Center(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16.r),
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CurrencyPage()));
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: AppTheme.colors.primary.withValues(alpha: 0.18),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'USD 1',
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        color: AppTheme.colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.swap_horiz_rounded,
                      size: 14.sp,
                      color: AppTheme.colors.primary,
                    ),
                    SizedBox(width: 4.w),
                    if (isLoading)
                      SizedBox(
                        width: 12.sp,
                        height: 12.sp,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.colors.primary,
                        ),
                      )
                    else
                      Text(
                        'UZS ${PriceFormatter.priceFormat(usdRate)}',
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.colors.primary,
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

  Widget _buildBodyContent(DashboardState state) {
    final bottomPadding = MediaQuery.of(context).padding.bottom + 96.h;

    if (state.status == Status.loading) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, bottomPadding),
        child: const DashboardShimmer(),
      );
    }

    if (state.status == Status.error) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48.sp,
                color: AppTheme.colors.red,
              ),
              SizedBox(height: 12.h),
              Text(
                state.errorMessage ??
                    'Ma\'lumotlarni yuklashda xatolik yuz berdi',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () {
                  context.read<DashboardBloc>().add(const LoadDashboard());
                  context.read<CurrencyBloc>().add(const GetExchangeRates());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.colors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                child: Text(
                  'Qayta urinish',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, bottomPadding),
          child: _buildDashboardContent(state),
        ),
      ),
    );
  }

  Widget _buildDashboardContent(DashboardState state) {
    final result = state.dashboardModel?.result;
    final partners = result?.partners;
    final projects = result?.projects;
    final details = partners?.details;

    final qarzExpired = details?.qarzExpired?.count ?? 0;
    final installmentExpired = details?.installmentExpired?.count ?? 0;
    final qarzToday = details?.qarzToday?.count ?? 0;
    final installmentToday = details?.installmentToday?.count ?? 0;
    final qarz3Days = details?.qarz3Days?.count ?? 0;
    final installment3Days = details?.installment3Days?.count ?? 0;

    final expiredCount = qarzExpired + installmentExpired;
    final todayCount = qarzToday + installmentToday;
    final soonCount = qarz3Days + installment3Days;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Welcome & Stats Overview Studio Card
        DashboardWelcomeCard(state: state),

        // Urgent Due Dates Alert Banner
        DashboardUrgentBanner(
          expiredCount: expiredCount,
          todayCount: todayCount,
          qarzExpired: qarzExpired,
          installmentExpired: installmentExpired,
          qarzToday: qarzToday,
          installmentToday: installmentToday,
        ),

        // Quick Actions Grid
        const DashboardQuickActions(),

        // Debt & Due Dates Control Card
        DebtControlCard(
          totalCount: partners?.partnersCount ?? 0,
          expiredCount: expiredCount,
          todayCount: todayCount,
          soonCount: soonCount,
          qarzExpired: qarzExpired,
          installmentExpired: installmentExpired,
          qarzToday: qarzToday,
          installmentToday: installmentToday,
          qarz3Days: qarz3Days,
          installment3Days: installment3Days,
        ),
        SizedBox(height: 16.h),

        // Projects Monitoring Card
        ProjectControlCard(
          totalCount: projects?.projectsCount ?? 0,
          inProgressCount: projects?.inProgress ?? 0,
          frozenCount: projects?.frozen ?? 0,
          completedCount: projects?.completed ?? 0,
          onInProgressTap: () => _navigateToProjects(status: 'in_progress'),
          onFrozenTap: () => _navigateToProjects(status: 'frozen'),
          onCompletedTap: () => _navigateToProjects(status: 'completed'),
          onAllTap: () => _navigateToProjects(),
        ),
      ],
    );
  }
}
