import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/auth/passcode/passcode_cubit.dart';
import 'package:hisobchi/domain/common/enums/passcode_step.dart';
import 'package:hisobchi/presentation/components/back_button.dart';
import '../../../assets/asset_index.dart';
import 'components/passcode_field.dart';
import 'components/set_passcode_keyboard.dart';

class VerifyOldPasscodePage extends StatefulWidget {
  const VerifyOldPasscodePage({super.key});

  @override
  State<VerifyOldPasscodePage> createState() => _VerifyOldPasscodePageState();
}

class _VerifyOldPasscodePageState extends State<VerifyOldPasscodePage>
    with TickerProviderStateMixin {
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
      create: (context) => PasscodeCubit(passcodeStep: PasscodeStep.check),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: AppTheme.colors.background,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: BackArrowButton(),
              title: Text(
                'Eski PIN kodni kiriting',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.colors.black,
                ),
              ),
              centerTitle: true,
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
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
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
                                // Title and error handling
                                BlocConsumer<PasscodeCubit, PasscodeState>(
                                  listener: (context, state) {
                                    if (state.isProcessCompleted) {
                                      HapticFeedback.heavyImpact();
                                      if (context.mounted) {
                                        Navigator.pop(context, true);
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
                                            state.isIncorrectPasscode
                                                ? 'Noto\'g\'ri PIN kod!'
                                                : 'Eski PIN kodni tasdiqlang',
                                            style: TextStyle(
                                              fontSize: 22.sp,
                                              fontWeight: FontWeight.w700,
                                              color: state.isIncorrectPasscode
                                                  ? AppTheme.colors.red
                                                  : AppTheme.colors.black,
                                              letterSpacing: -0.5,
                                            ),
                                          ),
                                          Gap(8.h),
                                          Text(
                                            state.isIncorrectPasscode
                                                ? 'Qaytadan urinib ko\'ring'
                                                : 'Xavfsizlik uchun eski PIN kodni kiriting',
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
                            Gap(24.h),
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
}