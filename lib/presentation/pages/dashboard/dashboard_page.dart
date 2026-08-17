import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:ehisob/application/currency/currency_bloc.dart';
import 'package:ehisob/application/dashboard/dashboard_bloc.dart';
import 'package:ehisob/application/project/project_bloc.dart';
import 'package:ehisob/domain/common/constants.dart';
import 'package:ehisob/presentation/assets/asset_index.dart';
import 'package:ehisob/presentation/components/utils/price_extension.dart';
import 'package:shimmer/shimmer.dart';

import '../../../infrastructure/services/permission_extension.dart';
import '../../components/toast/toast.dart';
import '../client/report/report_client_main_page.dart';
import '../currency/currency_page.dart';
import 'due_dates/due_dates_page.dart';

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

    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));

    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _navigateToProjects({required String status}) {
    // 1. Switch tab to Projects (index 2)
    StatefulNavigationShell.of(context).goBranch(2);

    // 2. Clear search and set status filter
    // context.read<ProjectBloc>().add(const GetAllProjectEvent(search: '', updateSearch: true));
    context.read<ProjectBloc>().add(GetAllProjectEvent(status: status, updateFilters: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                            padding: EdgeInsets.symmetric(horizontal: 14.w),
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
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r)),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(18.w, 14.h, 12.w, 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(AppIcons.appLogo, width: 32.w, height: 32.h),
              SizedBox(width: 10.w),
              Text(
                'E-Hisob',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A), letterSpacing: -0.5),
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
            final usdCurrency = state.exchangeRateModel!.rates.firstWhere((rate) => rate.code == 'USD', orElse: () => state.exchangeRateModel!.rates.first);
            usdRate = usdCurrency.rate;
          } catch (_) {
            usdRate = '...';
          }
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CurrencyPage()));
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [BoxShadow(color: AppTheme.colors.primary.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Row(
              children: [
                Text(
                  'USD 1',
                  style: TextStyle(fontSize: 13.sp, color: const Color(0xFF1E293B), fontWeight: FontWeight.w600),
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
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppTheme.colors.primary),
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

    final qarzExpired = details?.qarzExpired?.count ?? 0;
    final installmentExpired = details?.installmentExpired?.count ?? 0;
    final qarzToday = details?.qarzToday?.count ?? 0;
    final installmentToday = details?.installmentToday?.count ?? 0;
    final qarz3Days = details?.qarz3Days?.count ?? 0;
    final installment3Days = details?.installment3Days?.count ?? 0;

    final expiredCount = qarzExpired + installmentExpired;
    final todayCount = qarzToday + installmentToday;
    final soonCount = qarz3Days + installment3Days;

    void openDueDates({required String title, required String qarzType, required String installmentType, int initialTab = 0, required int qarzCount, required int instCount}) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DueDatesPage(
            title: title,
            qarzType: qarzType,
            installmentType: installmentType,
            initialTabIndex: initialTab,
            qarzCount: qarzCount,
            installmentCount: instCount,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HamkorlarCard(
          totalCount: partners?.partnersCount ?? 0,
          expiredCount: expiredCount,
          todayCount: todayCount,
          soonCount: soonCount,
          onExpiredTap: () => openDueDates(
            title: "Muddati o’tgan",
            qarzType: 'qarz_expired',
            installmentType: 'installment_expired',
            qarzCount: qarzExpired,
            instCount: installmentExpired,
          ),
          onTodayTap: () => openDueDates(
            title: 'Bugungilar',
            qarzType: 'qarz_today',
            installmentType: 'installment_today',
            qarzCount: qarzToday,
            instCount: installmentToday,
          ),
          onSoonTap: () => openDueDates(
            title: 'Tez orada',
            qarzType: 'qarz_3_days',
            installmentType: 'installment_3_days',
            qarzCount: qarz3Days,
            instCount: installment3Days,
          ),
        ),
        SizedBox(height: 14.h),
        LoyihalarCard(
          totalCount: projects?.projectsCount ?? 0,
          inProgressCount: projects?.inProgress ?? 0,
          frozenCount: projects?.frozen ?? 0,
          completedCount: projects?.completed ?? 0,
          onInProgressTap: () => _navigateToProjects(status: 'in_progress'),
          onFrozenTap: () => _navigateToProjects(status: 'frozen'),
          onCompletedTap: () => _navigateToProjects(status: 'completed'),
        ),
        SizedBox(height: 32.h),
      ],
    );
  }
}

class HamkorlarCard extends StatelessWidget {
  final int totalCount;
  final int expiredCount;
  final int todayCount;
  final int soonCount;
  final VoidCallback onExpiredTap;
  final VoidCallback onTodayTap;
  final VoidCallback onSoonTap;

  const HamkorlarCard({
    super.key,
    required this.totalCount,
    required this.expiredCount,
    required this.todayCount,
    required this.soonCount,
    required this.onExpiredTap,
    required this.onTodayTap,
    required this.onSoonTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 18.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.colors.primary.withValues(alpha: 0.08), // Soft primary-tint shadow
            blurRadius: 28,
            spreadRadius: -4,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SvgPicture.asset(AppIcons.clients,colorFilter: ColorFilter.mode(AppTheme.colors.primary, BlendMode.srcIn),),
                  SizedBox(width: 10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mijozlar hisoboti',
                        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B), letterSpacing: -0.2),
                      ),
                      Text(
                        'Qarz muddatlari',
                        style: TextStyle(fontSize: 11.sp, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
              AnimatedCounter(
                value: totalCount,
                style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.w500, color: const Color(0xFF0F172A), height: 1.1),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 280.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left side: Donut Chart
                Expanded(
                  flex: 5,
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final availableHeight = constraints.maxHeight;
                        final double strokeWidth = availableHeight * 0.13; // Restored thickness
                        // Calculate width needed to properly bound the semi-circle
                        final double requiredWidth = (availableHeight / 2) + (strokeWidth / 2);

                        return Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            SizedBox(
                              height: availableHeight,
                              width: requiredWidth,
                              child: TweenAnimationBuilder<double>(
                                tween: Tween<double>(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 1400),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, child) {
                                  return CustomPaint(
                                    painter: HamkorlarHalfDonutPainter(
                                      expiredCount: expiredCount,
                                      todayCount: todayCount,
                                      soonCount: soonCount,
                                      animationValue: value,
                                      strokeWidth: strokeWidth,
                                    ),
                                  );
                                },
                              ),
                            ),
                            // The semi-pill button inside the donut
                            Positioned(
                              left: 0,
                              child: GestureDetector(
                                onTap: () {
                                  if (!context.hasPermission('report_partners.view')) {
                                    Toast.showWarningToast(message: 'Sizda bunday huquq yo\'q');
                                    return;
                                  }
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportClientMainPage()));
                                },
                                child: Container(
                                  width: availableHeight * 0.33, // proportional width
                                  height: availableHeight * 0.55, // proportional height
                                  decoration: BoxDecoration(
                                    color: AppTheme.colors.gray.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(100.r),
                                      bottomRight: Radius.circular(100.r),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF151515).withValues(alpha: 0.06),
                                        blurRadius: 15,
                                        spreadRadius: 0,
                                        offset: const Offset(4, 0),
                                      )
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.colors.primary, size: 48.sp),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                Spacer(),
                // SizedBox(width: 18.w),
                // Right side: Mini cards
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      Expanded(
                        child: _buildMiniCard(
                          label: 'Muddati o\'tgan',
                          count: expiredCount,
                          colorTheme: const Color(0xFFEF4444),
                          bgColor: const Color(0xFFFFF0ED),
                          icon: Icons.report_problem_rounded,
                          onTap: onExpiredTap,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Expanded(
                        child: _buildMiniCard(
                          label: 'Bugungilar',
                          count: todayCount,
                          colorTheme: const Color(0xFFF59E0B),
                          bgColor: const Color(0xFFFFFBEB),
                          icon: Icons.notifications_active_rounded,
                          onTap: onTodayTap,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Expanded(
                        child: _buildMiniCard(
                          label: 'Tez orada',
                          count: soonCount,
                          colorTheme: const Color(0xFF3B82F6),
                          bgColor: const Color(0xFFEFF6FF),
                          icon: Icons.hourglass_top_rounded,
                          onTap: onSoonTap,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniCard({required String label, required int count, required Color colorTheme, required Color bgColor, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        // padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16.r),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Senior-level watermark decoration (shifted further for better bleeding effect)
            Positioned(
              right: -12.w,
              top: -12.h,
              child: IgnorePointer(
                child: Transform.rotate(
                  angle: math.pi / 4,
                  child: Icon(
                    icon,
                    color: colorTheme.withValues(alpha: 0.08),
                    size: 48.sp,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: colorTheme, size: 24.sp),
                  SizedBox(height: 4.h),
                  Text(
                    label,
                    style: TextStyle(fontSize: 11.sp, color: const Color(0xFF475569), fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 5.w,
                        height: 5.w,
                        decoration: BoxDecoration(color: colorTheme, shape: BoxShape.circle),
                      ),
                      SizedBox(width: 4.w),
                      AnimatedCounter(
                        value: count,
                        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HamkorlarHalfDonutPainter extends CustomPainter {
  final int expiredCount;
  final int todayCount;
  final int soonCount;
  final double animationValue;
  final double strokeWidth;

  HamkorlarHalfDonutPainter({required this.expiredCount, required this.todayCount, required this.soonCount, required this.animationValue, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    // Perfectly bounded coordinates
    final height = size.height;
    final radius = (height - strokeWidth) / 2;
    // Pushed slightly right by strokeWidth/2 so the arc hits exactly at x=0 smoothly.
    final center = Offset(strokeWidth / 2, height / 2);

    int total = expiredCount + todayCount + soonCount;

    // Background track
    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = const Color(0xFFF1F5F9)
      ..strokeCap = StrokeCap.round;

    final startAngleBg = -3.14159265 / 2;
    final sweepAngleBg = 3.14159265;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngleBg,
      sweepAngleBg,
      false,
      bgPaint,
    );

    if (total == 0) return;

    final double gap = 0.035;

    List<Map<String, dynamic>> segments = [];
    if (expiredCount > 0) segments.add({'count': expiredCount, 'color': const Color(0xFFEF4444)}); // Deep Red
    if (todayCount > 0) segments.add({'count': todayCount, 'color': const Color(0xFFF59E0B)}); // Deep Amber
    if (soonCount > 0) segments.add({'count': soonCount, 'color': const Color(0xFF3B82F6)}); // Deep Blue

    int activeSegments = segments.length;
    double drawableSweep = sweepAngleBg - ((activeSegments > 1 ? activeSegments - 1 : 0) * gap);

    if (drawableSweep <= 0) {
      drawableSweep = sweepAngleBg;
    }

    double currentAngle = startAngleBg;

    for (var segment in segments) {
      double targetSweep = (segment['count'] / total) * drawableSweep;
      double actualSweep = targetSweep * animationValue;

      if (actualSweep > 0) {
        final shadowPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..color = segment['color'].withValues(alpha: 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
          ..strokeCap = StrokeCap.round;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          currentAngle,
          actualSweep,
          false,
          shadowPaint,
        );

        final paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..color = segment['color']
          ..strokeCap = StrokeCap.round;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          currentAngle,
          actualSweep,
          false,
          paint,
        );
      }

      currentAngle += targetSweep + gap;
    }
  }

  @override
  bool shouldRepaint(covariant HamkorlarHalfDonutPainter oldDelegate) {
    return oldDelegate.expiredCount != expiredCount || oldDelegate.todayCount != todayCount || oldDelegate.soonCount != soonCount || oldDelegate.animationValue != animationValue || oldDelegate.strokeWidth != strokeWidth;
  }
}

class LoyihalarCard extends StatelessWidget {
  final int totalCount;
  final int inProgressCount;
  final int frozenCount;
  final int completedCount;
  final VoidCallback onInProgressTap;
  final VoidCallback onFrozenTap;
  final VoidCallback onCompletedTap;

  const LoyihalarCard({
    super.key,
    required this.totalCount,
    required this.inProgressCount,
    required this.frozenCount,
    required this.completedCount,
    required this.onInProgressTap,
    required this.onFrozenTap,
    required this.onCompletedTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 18.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.colors.primary.withValues(alpha: 0.08), // Soft primary-tint shadow
            blurRadius: 28,
            spreadRadius: -4,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SvgPicture.asset(AppIcons.project,colorFilter: ColorFilter.mode(AppTheme.colors.primary, BlendMode.srcIn),),
                  SizedBox(width: 10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Loyihalar',
                        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B), letterSpacing: -0.2),
                      ),
                      Text(
                        'Statuslar bo‘yicha',
                        style: TextStyle(fontSize: 11.sp, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
              AnimatedCounter(
                value: totalCount,
                style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.w500, color: const Color(0xFF0F172A), height: 1.1),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: _buildLoyihaCard(
                  label: 'Jarayonda',
                  count: inProgressCount,
                  colorTheme: const Color(0xFF60A5FA), // Blue
                  bgColor: const Color(0xFFF8FAFC),
                  icon: Icons.play_arrow_rounded,
                  onTap: onInProgressTap,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildLoyihaCard(
                  label: 'Muzlatilgan',
                  count: frozenCount,
                  colorTheme: const Color(0xFFFBBF24), // Orange/Yellow
                  bgColor: const Color(0xFFF8FAFC),
                  icon: Icons.pause_rounded,
                  onTap: onFrozenTap,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildLoyihaCard(
                  label: 'Yakunlangan',
                  count: completedCount,
                  colorTheme: const Color(0xFF34D399), // Green
                  bgColor: const Color(0xFFF8FAFC),
                  icon: Icons.check_rounded,
                  onTap: onCompletedTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoyihaCard({required String label, required int count, required Color colorTheme, required Color bgColor, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        height: 104.h,
        // padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16.r),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Top Right decorative intersecting circles
            Positioned(
              right: -10.w,
              top: -15.h,
              child: CustomPaint(
                size: Size(50.w, 50.h),
                painter: CircleDecorationPainter(color: colorTheme.withValues(alpha: 0.8)),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Icon(icon, color: colorTheme, size: 24.sp),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          label,
                          style: TextStyle(fontSize: 12.sp, color: const Color(0xFF475569), fontWeight: FontWeight.w600),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      AnimatedCounter(
                        value: count,
                        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CircleDecorationPainter extends CustomPainter {
  final Color color;
  CircleDecorationPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw two intersecting thin circles
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.4), 16.w, paint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.6), 16.w, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AnimatedCounter extends StatelessWidget {
  final int value;
  final TextStyle style;

  const AnimatedCounter({super.key, required this.value, this.style = const TextStyle()});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOutExpo,
      builder: (context, value, child) {
        return Text(value.toString(), style: style);
      },
    );
  }
}
