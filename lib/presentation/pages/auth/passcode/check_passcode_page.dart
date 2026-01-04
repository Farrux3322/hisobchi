import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hisobchi/application/app_manager/app_manager_cubit.dart';
import 'package:hisobchi/application/auth/passcode/passcode_cubit.dart';
import 'package:hisobchi/presentation/routes/coordinator.dart';
import 'package:hisobchi/presentation/routes/entity/routes.dart';
import '../../../assets/asset_index.dart';
import 'components/passcode_field.dart';
import 'components/passcode_keyboard.dart';

class CheckPasscodePage extends StatefulWidget {
  const CheckPasscodePage({super.key});

  @override
  State<CheckPasscodePage> createState() => _CheckPasscodePageState();
}

class _CheckPasscodePageState extends State<CheckPasscodePage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppManagerCubit.context = context;
    return BlocProvider<PasscodeCubit>(
      create: (context) => PasscodeCubit(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: AppTheme.colors.background,
            body: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(flex: 2),
                        // Beautiful icon with gradient background
                        Container(
                          width: 80.w,
                          height: 80.w,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppTheme.colors.primary,
                                AppTheme.colors.primary.withValues(alpha: 0.7),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.colors.primary.withValues(alpha: 0.25),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.lock_outline_rounded,
                            size: 40.sp,
                            color: Colors.white,
                          ),
                        ),
                        Gap(32.h),
                        // Title
                        BlocConsumer<PasscodeCubit, PasscodeState>(
                          listener: (context, state) {
                            if (state.isProcessCompleted) {
                              // PIN kod to'g'ri - session uchun belgilash
                              setPasscodeVerified(true);

                              // Bosh sahifaga o'tish
                              if (context.mounted) {
                                context.go(Routes.homePage.path);
                              }
                            }
                          },
                          builder: (context, state) {
                            return Column(
                              children: [
                                Text(
                                  tr('passcode.enter_passcode'),
                                  style: TextStyle(
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.colors.black,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                Gap(6.h),
                                Text(
                                  'Ilovaga kirish uchun PIN kodni kiriting',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w400,
                                    color: AppTheme.colors.gray,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        Gap(40.h),
                        const PasscodeField(),
                        const Spacer(flex: 3),
                        const PasscodeKeyboard(),
                        Gap(20.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
