import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hisobchi/application/currency/currency_bloc.dart';
import 'package:hisobchi/application/dashboard/dashboard_bloc.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/components/utils/price_extension.dart';
import 'package:hisobchi/presentation/pages/currency/currency_page.dart';
import 'package:shimmer/shimmer.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(const LoadDashboard());
    context.read<CurrencyBloc>().add(const GetExchangeRates());
    
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardBloc>().add(const LoadDashboard());
                context.read<CurrencyBloc>().add(const GetExchangeRates());
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader()),
                  if (state.status == Status.loading)
                    SliverToBoxAdapter(child: _buildShimmerLoading())
                  else if (state.status == Status.error)
                    SliverFillRemaining(child: Center(child: Text(state.errorMessage ?? 'Xatolik yuz berdi')))
                  else
                    SliverToBoxAdapter(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                            child: _buildBody(state),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Column(
        children: [
          _buildCardShimmer(),
          SizedBox(height: 28.h),
          _buildCardShimmer(),
        ],
      ),
    );
  }

  Widget _buildCardShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        height: 220.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 10.w, 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(AppIcons.appLogo, width: 44.w, height: 44.h),
              SizedBox(width: 14.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'E-Hisob',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Bosh sahifa',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
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
    );
  }

  Widget _buildCurrencyWidget() {
    return BlocBuilder<CurrencyBloc, CurrencyState>(
      builder: (context, state) {
        String usdRate = '1';
        bool isLoading = state.exchangeRatesStatus == Status.loading;

        if (state.exchangeRatesStatus == Status.success && state.exchangeRateModel != null) {
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

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CurrencyPage()),
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Text(
                  'USD 1',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF1E293B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(Icons.swap_horiz_rounded, size: 16.sp, color: const Color(0xFF94A3B8)),
                SizedBox(width: 8.w),
                if (isLoading)
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(width: 60.w, height: 14.h, color: Colors.white),
                  )
                else
                  Text(
                    'UZS ${PriceFormatter.priceFormat(usdRate)}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.colors.primary,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(DashboardState state) {
    final result = state.dashboardModel?.result;
    final partners = result?.partners;
    final projects = result?.projects;
    final details = partners?.details;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardHeaderCard(
          title: 'Hamkorlar',
          subtitle: 'Qarz muddatlari',
          icon: AppIcons.clients,
          totalCount: partners?.partnersCount ?? 0,
          totalLabel: 'Hamkor',
          gradient: [AppTheme.colors.primary, AppTheme.colors.primary.withValues(alpha: .9)],
          statusCards: [
            StatusMiniCard(
              label: 'Muddati o‘tgan',
              count: details?.qarzExpired?.count ?? 0,
              icon: Icons.error_outline_rounded,
              backgroundColor: const Color(0xFFFFF1F0),
              iconColor: const Color(0xFFE53935),
              onTap: () {},
            ),
            StatusMiniCard(
              label: 'Bugun',
              count: details?.qarzToday?.count ?? 0,
              icon: Icons.warning_amber_rounded,
              backgroundColor: const Color(0xFFFFF8E1),
              iconColor: const Color(0xFFF9A825),
              onTap: () {},
            ),
            StatusMiniCard(
              label: 'Yaqinlashmoqda',
              count: details?.qarz3Days?.count ?? 0,
              icon: Icons.schedule_rounded,
              backgroundColor: const Color(0xFFEEF4FF),
              iconColor: const Color(0xFF2962FF),
              onTap: () {},
            ),
          ],
        ),
        SizedBox(height: 28.h),
        DashboardHeaderCard(
          title: 'Loyihalar',
          subtitle: 'Statuslar bo‘yicha',
          icon: AppIcons.project,
          totalCount: projects?.projectsCount ?? 0,
          totalLabel: 'Loyiha',
          gradient: [AppTheme.colors.primary, AppTheme.colors.primary.withValues(alpha: .9)],
          statusCards: [
            StatusMiniCard(
              label: 'Jarayonda',
              count: projects?.inProgress ?? 0,
              icon: Icons.play_arrow_rounded,
              backgroundColor: const Color(0xFFFFF3E0),
              iconColor: Colors.orange,
              onTap: () {},
            ),
            StatusMiniCard(
              label: 'Muzlatilgan',
              count: projects?.frozen ?? 0,
              icon: Icons.pause_rounded,
              backgroundColor: const Color(0xFFEEF3FF),
              iconColor: Colors.blue,
              onTap: () {},
            ),
            StatusMiniCard(
              label: 'Yakunlangan',
              count: projects?.completed ?? 0,
              icon: Icons.check_circle_outline_rounded,
              backgroundColor: const Color(0xFFE8F5E9),
              iconColor: Colors.green,
              onTap: () {},
            ),
          ],
        ),
        SizedBox(height: 32.h),
      ],
    );
  }
}

class DashboardHeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String icon;
  final int totalCount;
  final String totalLabel;
  final List<Color> gradient;
  final List<StatusMiniCard> statusCards;

  const DashboardHeaderCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.totalCount,
    required this.totalLabel,
    required this.gradient,
    required this.statusCards,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal:  16.w,vertical: 7.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(16.r), topRight: Radius.circular(16.r)),

              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(icon,height: 24,width: 24,colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AnimatedCounter(
                      value: totalCount,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      totalLabel,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal:  8.w).copyWith(bottom: 16.w),
            child: Row(
              children: statusCards.map((card) => Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: card,
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class StatusMiniCard extends StatefulWidget {
  final String label;
  final int count;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onTap;

  const StatusMiniCard({
    super.key,
    required this.label,
    required this.count,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  State<StatusMiniCard> createState() => _StatusMiniCardState();
}

class _StatusMiniCardState extends State<StatusMiniCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            children: [
              Icon(widget.icon, color: widget.iconColor, size: 36.sp),
              SizedBox(height: 8.h),
              AnimatedCounter(
                value: widget.count,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedCounter extends StatelessWidget {
  final int value;
  final TextStyle style;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.style = const TextStyle(),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOutExpo,
      builder: (context, value, child) {
        return Text(
          value.toString(),
          style: style,
        );
      },
    );
  }
}
