import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hisobchi/application/auth/init/init_auth_bloc.dart';
import 'package:hisobchi/presentation/components/defocus.dart';
import 'package:hisobchi/presentation/components/inputs/pin_put_x.dart';
import 'package:hisobchi/presentation/routes/index_routes.dart';
import 'package:timer_count_down/timer_count_down.dart';

import '../../../../domain/common/second_to_time.dart';
import '../../../assets/asset_index.dart';

class RestOTPPage extends StatefulWidget {
  const RestOTPPage({super.key});

  @override
  State<RestOTPPage> createState() => _RestOTPPageState();
}

class _RestOTPPageState extends State<RestOTPPage> with TickerProviderStateMixin {
  bool showCountDown = true;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutBack),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DeFocus(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.colors.primary.withValues(alpha: 0.05),
                AppTheme.colors.primary.withValues(alpha: 0.02),
                Colors.white,
                AppTheme.colors.primary.withValues(alpha: 0.03),
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: SafeArea(
            child: BlocConsumer<InitAuthBloc, InitAuthState>(
              listener: (context, state) {
                if (state is RegisterLoading || state is OtpLoading) {
                  EasyLoading.show();
                } else if (state is RegisterSuccess) {
                  HapticFeedback.mediumImpact();
                  context.read<InitAuthBloc>().add(ResetAuthEvent());
                  EasyLoading.dismiss();
                  context.go(Routes.homePage.path);
                } else {
                  EasyLoading.dismiss();
                }
              },
              builder: (context, state) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      children: [
                        SizedBox(height: 40.h),
                        _buildLogoSection(),
                        SizedBox(height: 32.h),
                        _buildTitleSection(),
                        SizedBox(height: 32.h),
                        _buildPinSection(),
                        SizedBox(height: 32.h),
                        _buildResendSection(),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.colors.primary.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Image.asset(
                AppIcons.appLogo,
                height: 80.h,
                width: 80.w,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'E-HISOB',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w900,
                color: AppTheme.colors.primary,
                letterSpacing: 0.8,
              ),
            ),
            SizedBox(height: 3.h),
            Container(
              height: 2.5.h,
              width: 35.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.colors.primary.withValues(alpha: 0.3),
                    AppTheme.colors.primary,
                    AppTheme.colors.primary.withValues(alpha: 0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppTheme.colors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_reset_rounded,
                size: 40.sp,
                color: AppTheme.colors.primary,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Tasdiqlash kodi',
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.w800,
                color: AppTheme.colors.black,
                letterSpacing: -0.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'Telefon raqamingizga yuborilgan\n4 raqamli kodni kiriting',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w400,
                color: AppTheme.colors.black.withValues(alpha: 0.6),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: PintPutX(
            onComplete: (value) {
              HapticFeedback.mediumImpact();
              context.read<InitAuthBloc>().add(
                    ResetSendOtpEvent(
                      otp: value,
                      password: context.read<InitAuthBloc>().password,
                    ),
                  );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildResendSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: showCountDown ? _buildCountdownWidget() : _buildResendButton(),
        ),
      ),
    );
  }

  Widget _buildCountdownWidget() {
    return Container(
      key: const ValueKey('countdown'),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppTheme.colors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppTheme.colors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule_rounded,
            size: 20.sp,
            color: AppTheme.colors.primary,
          ),
          SizedBox(width: 8.w),
          Countdown(
            seconds: 120,
            build: (_, time) {
              return Text(
                tr(
                  'confirmation.resend_in',
                  namedArgs: {'time': secondToTime(time.toInt())},
                ),
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.colors.primary,
                ),
              );
            },
            onFinished: () {
              setState(() {
                showCountDown = false;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResendButton() {
    return SizedBox(
      key: const ValueKey('button'),
      width: double.infinity,
      height: 54.h,
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          setState(() {
            showCountDown = true;
          });
          context.read<InitAuthBloc>().add(
                SendOtpEvent(
                  password: context.read<InitAuthBloc>().password,
                  name: context.read<InitAuthBloc>().name,
                ),
              );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.colors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: AppTheme.colors.primary.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.refresh_rounded, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              'Qayta yuborish',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
