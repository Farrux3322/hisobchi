import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/auth/passcode/passcode_cubit.dart';
import 'package:hisobchi/infrastructure/services/shared_service.dart';
import '../../../../domain/common/enums/passcode_step.dart';
import '../../../assets/asset_index.dart';
import 'components/passcode_field.dart';
import 'components/set_passcode_keyboard.dart';

class SetPasscodePage extends StatefulWidget {
  const SetPasscodePage({super.key});

  @override
  State<SetPasscodePage> createState() => _SetPasscodePageState();
}

class _SetPasscodePageState extends State<SetPasscodePage> with TickerProviderStateMixin {
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
    return BlocProvider<PasscodeCubit>(
      create: (context) => PasscodeCubit(passcodeStep: PasscodeStep.create),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: AppTheme.colors.background,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.colors.black, size: 20.sp),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Container(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                // Logo with modern design (smaller)
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
                                // Title with step indicator and error handling
                                BlocConsumer<PasscodeCubit, PasscodeState>(
                                  listener: (context, state) {
                                    if (state.isProcessCompleted) {
                                      HapticFeedback.heavyImpact();
                                      SharedPrefService.initialize().then((pref) {
                                        pref
                                          ..setPasscodeEnabled(true)
                                          ..setPasscode(state.passcodeOne);

                                        if (context.mounted) {
                                          Navigator.pop(context, true);
                                        }
                                      });
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
                                          // Step indicator
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              _buildStepIndicator(1, state.passcodeStep == PasscodeStep.create),
                                              Container(
                                                width: 36.w,
                                                height: 2.h,
                                                margin: EdgeInsets.symmetric(horizontal: 10.w),
                                                decoration: BoxDecoration(
                                                  color: state.passcodeStep == PasscodeStep.confirm
                                                      ? AppTheme.colors.primary
                                                      : AppTheme.colors.gray.withValues(alpha: 0.25),
                                                  borderRadius: BorderRadius.circular(2.r),
                                                ),
                                              ),
                                              _buildStepIndicator(2, state.passcodeStep == PasscodeStep.confirm),
                                            ],
                                          ),
                                          Gap(20.h),
                                          Text(
                                            state.isIncorrectPasscode
                                                ? 'PIN kodlar mos emas!'
                                                : state.passcodeStep == PasscodeStep.create
                                                    ? "passcode.set_passcode".tr()
                                                    : "passcode.confirm_passcode".tr(),
                                            style: TextStyle(
                                              fontSize: 22.sp,
                                              fontWeight: FontWeight.w700,
                                              color: state.isIncorrectPasscode ? AppTheme.colors.red : AppTheme.colors.black,
                                              letterSpacing: -0.5,
                                            ),
                                          ),
                                          Gap(6.h),
                                          Text(
                                            state.isIncorrectPasscode
                                                ? 'Qaytadan urinib ko\'ring'
                                                : state.passcodeStep == PasscodeStep.create
                                                    ? '4 raqamli PIN kod yarating'
                                                    : 'PIN kodni qayta kiriting',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 13.sp,
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

                                Gap(24.h),

                                // PIN Field
                                BlocBuilder<PasscodeCubit, PasscodeState>(
                                  builder: (context, state) {
                                    return SlideTransition(
                                      position: _shakeAnimation,
                                      child: const PasscodeField(),
                                    );
                                  },
                                ),
                              ],
                            ),

                            // Keyboard at bottom
                            Column(
                              children: [
                                const SetPasscodeKeyboard(),
                                Gap(16.h),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepIndicator(int step, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 36.w,
      height: 36.w,
      decoration: BoxDecoration(
        gradient: isActive
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.colors.primary,
                  AppTheme.colors.primary.withValues(alpha: 0.85),
                ],
              )
            : null,
        color: isActive ? null : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? Colors.transparent : AppTheme.colors.gray.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppTheme.colors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          '$step',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: isActive ? Colors.white : AppTheme.colors.gray.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}
