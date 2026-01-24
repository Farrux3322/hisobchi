import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hisobchi/application/app_manager/app_manager_cubit.dart';
import 'package:hisobchi/application/currency/currency_bloc.dart';
import 'package:hisobchi/application/dashboard/dashboard_bloc.dart';
import 'package:hisobchi/application/project/project_bloc.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/components/utils/price_extension.dart';
import 'package:hisobchi/presentation/pages/client/report/partner_operations_detail_page.dart';
import 'package:shimmer/shimmer.dart';

import '../currency/currency_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  String _selectedCurrency = 'UZS';

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
    AppManagerCubit.context = context;
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
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
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
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A), letterSpacing: -0.5),
                  ),
                  Text(
                    'Bosh sahifa',
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: const Color(0xFF94A3B8)),
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
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
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

    final availableCurrencies = partners?.details?.keys.toList() ?? ['UZS'];
    if (!availableCurrencies.contains(_selectedCurrency)) {
      _selectedCurrency = availableCurrencies.first;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardHeaderCard(
          title: 'Hamkorlar',
          subtitle: 'Qarz muddatlari',
          icon: AppIcons.clients,
          totalCount: partners?.partnersCount ?? 0,
          totalLabel: 'Hamkor',
          availableCurrencies: availableCurrencies,
          selectedCurrency: _selectedCurrency,
          onCurrencyChanged: (currency) {
            setState(() {
              _selectedCurrency = currency;
            });
          },
          gradient: [AppTheme.colors.primary, AppTheme.colors.primary.withValues(alpha: .9)],
          statusPages: availableCurrencies.map((currency) {
            final currencyDetails = partners?.details?[currency];
            final currencyTypeId = currency == 'UZS' ? 1 : 2;
            return [
              StatusMiniCard(
                label: 'Muddati o‘tgan',
                count: currencyDetails?.qarzExpired?.count ?? 0,
                icon: Icons.error_outline_rounded,
                backgroundColor: const Color(0xFFFEF2F2),
                iconColor: const Color(0xFFEF4444),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PartnerOperationsDetailPage(type: currencyDetails?.qarzExpired?.type ?? 'qarz_expired', currencyTypeId: currencyTypeId, title: 'Muddati o‘tgan'),
                    ),
                  );
                },
              ),
              StatusMiniCard(
                label: 'Bugun',
                count: currencyDetails?.qarzToday?.count ?? 0,
                icon: Icons.notifications_active_outlined,
                backgroundColor: const Color(0xFFFFFBEB),
                iconColor: const Color(0xFFF59E0B),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PartnerOperationsDetailPage(type: currencyDetails?.qarzToday?.type ?? 'qarz_today', currencyTypeId: currencyTypeId, title: 'Bugun'),
                    ),
                  );
                },
              ),
              StatusMiniCard(
                label: 'Yaqinlashmoqda',
                count: currencyDetails?.qarz3Days?.count ?? 0,
                icon: Icons.event_note_outlined,
                backgroundColor: const Color(0xFFF0F9FF),
                iconColor: const Color(0xFF0EA5E9),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PartnerOperationsDetailPage(type: currencyDetails?.qarz3Days?.type ?? 'qarz_3_days', currencyTypeId: currencyTypeId, title: 'Yaqinlashmoqda'),
                    ),
                  );
                },
              ),
            ];
          }).toList(),
        ),
        SizedBox(height: 28.h),
        DashboardHeaderCard(
          title: 'Loyihalar',
          subtitle: 'Statuslar bo‘yicha',
          icon: AppIcons.project,
          totalCount: projects?.projectsCount ?? 0,
          totalLabel: 'Loyiha',
          gradient: [AppTheme.colors.primary, AppTheme.colors.primary.withValues(alpha: .9)],
          statusPages: [
            [
              StatusMiniCard(
                label: 'Jarayonda',
                count: projects?.inProgress ?? 0,
                icon: Icons.play_arrow_rounded,
                backgroundColor: const Color(0xFFEEF3FF),
                iconColor: Colors.blue,
                onTap: () => _navigateToProjects(status: 'in_progress'),
              ),
              StatusMiniCard(
                label: 'Muzlatilgan',
                count: projects?.frozen ?? 0,
                icon: Icons.pause_rounded,
                backgroundColor: const Color(0xFFFFF3E0),
                iconColor: Colors.orange,
                onTap: () => _navigateToProjects(status: 'frozen'),
              ),
              StatusMiniCard(
                label: 'Yakunlangan',
                count: projects?.completed ?? 0,
                icon: Icons.check_circle_outline_rounded,
                backgroundColor: const Color(0xFFE8F5E9),
                iconColor: Colors.green,
                onTap: () => _navigateToProjects(status: 'completed'),
              ),
            ],
          ],
        ),
        SizedBox(height: 32.h),
      ],
    );
  }
}

class DashboardHeaderCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String icon;
  final int totalCount;
  final String totalLabel;
  final List<Color> gradient;
  final List<List<StatusMiniCard>> statusPages;
  final List<String>? availableCurrencies;
  final String? selectedCurrency;
  final ValueChanged<String>? onCurrencyChanged;

  const DashboardHeaderCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.totalCount,
    required this.totalLabel,
    required this.gradient,
    required this.statusPages,
    this.availableCurrencies,
    this.selectedCurrency,
    this.onCurrencyChanged,
  });

  @override
  State<DashboardHeaderCard> createState() => _DashboardHeaderCardState();
}

class _DashboardHeaderCardState extends State<DashboardHeaderCard> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    int initialPage = 0;
    if (widget.availableCurrencies != null && widget.selectedCurrency != null) {
      initialPage = widget.availableCurrencies!.indexOf(widget.selectedCurrency!);
    }
    _pageController = PageController(initialPage: initialPage >= 0 ? initialPage : 0);
  }

  @override
  void didUpdateWidget(covariant DashboardHeaderCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCurrency != oldWidget.selectedCurrency && widget.availableCurrencies != null) {
      int targetPage = widget.availableCurrencies!.indexOf(widget.selectedCurrency!);
      if (targetPage >= 0 && _pageController.hasClients && _pageController.page?.round() != targetPage) {
        _pageController.animateToPage(targetPage, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: widget.gradient.first.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(16.r), topRight: Radius.circular(16.r)),
              gradient: LinearGradient(colors: widget.gradient, begin: Alignment.topLeft, end: Alignment.bottomRight, stops: const [0.0, 1.0]),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                            ),
                            child: SvgPicture.asset(widget.icon, height: 22.sp, width: 22.sp, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.title,
                                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.2),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  widget.subtitle,
                                  style: TextStyle(fontSize: 10.sp, color: Colors.white.withValues(alpha: 0.7), fontWeight: FontWeight.w500),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: AnimatedCounter(
                              value: widget.totalCount,
                              style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1),
                            ),
                          ),
                          Text(
                            widget.totalLabel.toUpperCase(),
                            style: TextStyle(fontSize: 10.sp, color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.w700, letterSpacing: 0.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (widget.availableCurrencies != null && widget.availableCurrencies!.length > 1) ...[
                  SizedBox(height: 8.h),
                  Container(
                    height: 36.h,
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10.r)),
                    child: Row(
                      children: widget.availableCurrencies!.map((currency) {
                        final isSelected = widget.selectedCurrency == currency;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              widget.onCurrencyChanged?.call(currency);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(8.r),
                                boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))] : [],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                currency,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                  color: isSelected ? widget.gradient.first : Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 12.h),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 160.h, minHeight: 130.h),
            child: SizedBox(
              height: 0.16.sh,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.statusPages.length,
                onPageChanged: (index) {
                  if (widget.availableCurrencies != null && index < widget.availableCurrencies!.length) {
                    widget.onCurrencyChanged?.call(widget.availableCurrencies![index]);
                  }
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Row(
                      children: widget.statusPages[index]
                          .map(
                            (card) => Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.w),
                                child: card,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 12.h),
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

  const StatusMiniCard({super.key, required this.label, required this.count, required this.icon, required this.backgroundColor, required this.iconColor, required this.onTap});

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
          padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: widget.iconColor.withValues(alpha: 0.1), width: 1.5),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(color: widget.iconColor.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: Icon(widget.icon, color: widget.iconColor, size: 24.sp),
              ),
              SizedBox(height: 10.h),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: AnimatedCounter(
                    value: widget.count,
                    style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B), letterSpacing: -0.5),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  widget.label,
                  style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700, color: const Color(0xFF64748B), letterSpacing: 0.2),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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
