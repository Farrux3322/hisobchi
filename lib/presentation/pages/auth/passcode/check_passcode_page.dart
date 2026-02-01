import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _CheckPasscodePageState extends State<CheckPasscodePage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _shakeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _shakeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(_shakeController);

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _performShake() {
    HapticFeedback.heavyImpact();

    final shakeSequence = TweenSequence<Offset>([
      TweenSequenceItem(tween: Tween(begin: Offset.zero, end: const Offset(-0.02, 0)), weight: 1),
      TweenSequenceItem(tween: Tween(begin: const Offset(-0.02, 0), end: const Offset(0.02, 0)), weight: 1),
      TweenSequenceItem(tween: Tween(begin: const Offset(0.02, 0), end: const Offset(-0.02, 0)), weight: 1),
      TweenSequenceItem(tween: Tween(begin: const Offset(-0.02, 0), end: Offset.zero), weight: 1),
    ]);

    setState(() {
      _shakeAnimation = shakeSequence.animate(_shakeController);
    });

    _shakeController.forward(from: 0.0);
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
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    children: [
                      const Spacer(flex: 2),

                      // Logo with modern design
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer glow effect
                          Container(
                            width: 140.w,
                            height: 140.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppTheme.colors.primary.withValues(alpha: 0.15),
                                  AppTheme.colors.primary.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                          // Main logo container
                          Image.asset(
                            AppIcons.appLogo,
                            height: 100.h,
                            width: 100.w,
                          ),
                        ],
                      ),

                      Gap(40.h),

                      // Title and error message
                      BlocConsumer<PasscodeCubit, PasscodeState>(
                        listener: (context, state) {
                          if (state.isProcessCompleted) {
                            HapticFeedback.heavyImpact();
                            setPasscodeVerified(true);

                            if (context.mounted) {
                              context.go(Routes.homePage.path);
                            }
                          }

                          if (state.isIncorrectPasscode) {
                            _performShake();
                            Future.delayed(const Duration(milliseconds: 1000), () {
                              if (context.mounted) {
                                context.read<PasscodeCubit>().clearIncorrectField();
                              }
                            });
                          }
                        },
                        builder: (context, state) {
                          return SlideTransition(
                            position: _shakeAnimation,
                            child: Column(
                              children: [
                                Text(
                                  state.isIncorrectPasscode ? 'Noto\'g\'ri PIN!' : tr('passcode.enter_passcode'),
                                  style: TextStyle(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.w700,
                                    color: state.isIncorrectPasscode ? AppTheme.colors.red : AppTheme.colors.black,
                                  ),
                                ),
                                Gap(8.h),
                                Text(
                                  state.isIncorrectPasscode
                                      ? 'Qaytadan urinib ko\'ring'
                                      : 'Ilovaga kirish uchun PIN kodni kiriting',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w400,
                                    color: state.isIncorrectPasscode
                                        ? AppTheme.colors.red.withValues(alpha: 0.7)
                                        : AppTheme.colors.gray,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      Gap(15.h),

                      // PIN Field
                      BlocBuilder<PasscodeCubit, PasscodeState>(
                        builder: (context, state) {
                          return SlideTransition(
                            position: _shakeAnimation,
                            child: const PasscodeField(),
                          );
                        },
                      ),

                      const Spacer(flex: 2),

                      // Keyboard
                      const PasscodeKeyboard(),

                      Gap(20.h),
                    ],
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