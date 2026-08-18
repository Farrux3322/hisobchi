import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ehisob/presentation/assets/asset_index.dart';

class OnboardingHeroIllustration extends StatefulWidget {
  final int pageIndex;
  final Color primaryColor;
  final Color secondaryColor;

  const OnboardingHeroIllustration({
    super.key,
    required this.pageIndex,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  State<OnboardingHeroIllustration> createState() =>
      _OnboardingHeroIllustrationState();
}

class _OnboardingHeroIllustrationState
    extends State<OnboardingHeroIllustration>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatController, _pulseController]),
      builder: (context, child) {
        switch (widget.pageIndex) {
          case 0:
            return _buildFinanceHero();
          case 1:
            return _buildProjectHero();
          case 2:
            return _buildCurrencyHero();
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  /// HERO 1: Finance & Balance Control
  Widget _buildFinanceHero() {
    return SizedBox(
      height: 200.h,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Background Glow Circle
          Positioned(
            child: ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 170.w,
                height: 170.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      widget.primaryColor.withValues(alpha: 0.22),
                      widget.secondaryColor.withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Main Glass Card
          Transform.translate(
            offset: Offset(0, _floatAnimation.value * 0.5),
            child: Container(
              width: 250.w,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: widget.primaryColor.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.8),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              color: widget.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Image.asset(
                              AppIcons.appLogo,
                              width: 18.w,
                              height: 18.w,
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Umumiy Balans',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'EHisob',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 7.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Text(
                          'Faol',
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  Text(
                    '38,450,000 UZS',
                    style: TextStyle(
                      fontSize: 19.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),

                  SizedBox(height: 12.h),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildBar(28.h, widget.primaryColor.withValues(alpha: 0.4)),
                      _buildBar(46.h, widget.primaryColor),
                      _buildBar(32.h, widget.primaryColor.withValues(alpha: 0.5)),
                      _buildBar(54.h, const Color(0xFF10B981)),
                      _buildBar(36.h, widget.primaryColor.withValues(alpha: 0.6)),
                      _buildBar(48.h, widget.primaryColor),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Floating Chip 1
          Positioned(
            top: 8.h,
            right: 10.w,
            child: Transform.translate(
              offset: Offset(0, -_floatAnimation.value),
              child: _buildFloatingBadge(
                icon: Icons.arrow_upward_rounded,
                iconColor: const Color(0xFF10B981),
                title: 'Kirim',
                value: '+ 15.4M UZS',
                badgeColor: const Color(0xFFECFDF5),
              ),
            ),
          ),

          // Floating Chip 2
          Positioned(
            bottom: 5.h,
            left: 10.w,
            child: Transform.translate(
              offset: Offset(0, _floatAnimation.value * 1.2),
              child: _buildFloatingBadge(
                icon: Icons.arrow_downward_rounded,
                iconColor: const Color(0xFFEF4444),
                title: 'Chiqim',
                value: '- 4.2M UZS',
                badgeColor: const Color(0xFFFEF2F2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// HERO 2: Projects & Clients Hero
  Widget _buildProjectHero() {
    return SizedBox(
      height: 200.h,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Glow
          Positioned(
            child: ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 170.w,
                height: 170.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      widget.primaryColor.withValues(alpha: 0.22),
                      widget.secondaryColor.withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Main Card Container
          Transform.translate(
            offset: Offset(0, _floatAnimation.value * 0.4),
            child: Container(
              width: 250.w,
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: widget.primaryColor.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.8),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Loyihalar Monitoringi',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Icon(
                        Icons.insights_rounded,
                        color: widget.primaryColor,
                        size: 18.sp,
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),

                  _buildProjectRow(
                    name: 'Toshkent Resident',
                    client: 'RealSoft MCHJ',
                    progress: 0.85,
                    progressColor: const Color(0xFF10B981),
                  ),

                  SizedBox(height: 8.h),
                  Divider(color: Colors.grey.shade200, height: 1),
                  SizedBox(height: 8.h),

                  _buildProjectRow(
                    name: 'IT Park Markazi',
                    client: 'Orient Group',
                    progress: 0.55,
                    progressColor: widget.primaryColor,
                  ),
                ],
              ),
            ),
          ),

          // Top Left Floating Avatar Chip
          Positioned(
            top: 8.h,
            left: 15.w,
            child: Transform.translate(
              offset: Offset(0, -_floatAnimation.value * 0.9),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 10.r,
                      backgroundColor: widget.primaryColor.withValues(alpha: 0.15),
                      child: Icon(
                        Icons.person_rounded,
                        size: 12.sp,
                        color: widget.primaryColor,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      '32 Faol Mijoz',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Right Floating Check Chip
          Positioned(
            bottom: 5.h,
            right: 15.w,
            child: Transform.translate(
              offset: Offset(0, _floatAnimation.value * 1.1),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 14.sp,
                      color: const Color(0xFF10B981),
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      'Hisobot Tayyor',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF047857),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// HERO 3: Multi-Currency & Analytics Hero
  Widget _buildCurrencyHero() {
    return SizedBox(
      height: 200.h,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Background Glow
          Positioned(
            child: ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 170.w,
                height: 170.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      widget.primaryColor.withValues(alpha: 0.22),
                      widget.secondaryColor.withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Card
          Transform.translate(
            offset: Offset(0, _floatAnimation.value * 0.5),
            child: Container(
              width: 250.w,
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: widget.primaryColor.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.8),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.currency_exchange_rounded,
                            color: widget.primaryColor,
                            size: 18.sp,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'Valyuta Kurslari',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 7.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          'Onlayn',
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10.h),

                  _buildCurrencyRow(
                    code: 'USD',
                    name: 'AQSH Dollari',
                    rate: '12,850 UZS',
                    change: '+0.35%',
                    isPositive: true,
                  ),

                  SizedBox(height: 8.h),

                  _buildCurrencyRow(
                    code: 'EUR',
                    name: 'Yevro',
                    rate: '13,920 UZS',
                    change: '+0.12%',
                    isPositive: true,
                  ),
                ],
              ),
            ),
          ),

          // Bottom Converter Chip
          Positioned(
            bottom: 5.h,
            child: Transform.translate(
              offset: Offset(0, -_floatAnimation.value * 0.8),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '100 USD',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      child: Icon(
                        Icons.swap_horiz_rounded,
                        color: const Color(0xFF10B981),
                        size: 16.sp,
                      ),
                    ),
                    Text(
                      '1,285,000 UZS',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF34D399),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper Widgets
  Widget _buildBar(double height, Color color) {
    return Container(
      width: 14.w,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6.r),
      ),
    );
  }

  Widget _buildFloatingBadge({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required Color badgeColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(5.w),
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 10.sp, color: iconColor),
          ),
          SizedBox(width: 6.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 8.sp,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectRow({
    required String name,
    required String client,
    required double progress,
    required Color progressColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  client,
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w800,
                color: progressColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 5.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 5.h,
            backgroundColor: Colors.grey.shade100,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencyRow({
    required String code,
    required String name,
    required String rate,
    required String change,
    required bool isPositive,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  code,
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  rate,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: isPositive ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            change,
            style: TextStyle(
              fontSize: 9.sp,
              fontWeight: FontWeight.w700,
              color: isPositive ? const Color(0xFF059669) : const Color(0xFFDC2626),
            ),
          ),
        ),
      ],
    );
  }
}
