import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/auth/passcode/passcode_cubit.dart';
import 'package:hisobchi/infrastructure/services/shared_service.dart';
import '../../../../domain/common/enums/passcode_step.dart';
import '../../../assets/asset_index.dart';
import 'components/passcode_field.dart';
import 'components/passcode_keyboard.dart';

class SetPasscodePage extends StatefulWidget {
  const SetPasscodePage({super.key});

  @override
  State<SetPasscodePage> createState() => _SetPasscodePageState();
}

class _SetPasscodePageState extends State<SetPasscodePage> with SingleTickerProviderStateMixin {
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
                child: SlideTransition(
                  position: _slideAnimation,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24.w),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Spacer(flex: 2),
                                  // Beautiful icon with gradient background
                                  // Image.asset(
                                  //   AppIcons.appLogo,
                                  //   height:60.h,
                                  // ),
                                  Gap(12.h),
                                  // Title with step indicator
                                  BlocConsumer<PasscodeCubit, PasscodeState>(
                                    listener: (context, state) {
                                      if (state.isProcessCompleted) {
                                        SharedPrefService.initialize().then((pref) {
                                          pref
                                            ..setPasscodeEnabled(true)
                                            ..setPasscode(state.passcodeOne);

                                          if (context.mounted) {
                                            Navigator.pop(context, true);
                                          }
                                        });
                                      }
                                    },
                                    builder: (context, state) {
                                      return Column(
                                        children: [
                                          // Step indicator
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              _buildStepIndicator(1, state.passcodeStep == PasscodeStep.create),
                                              Container(
                                                width: 32.w,
                                                height: 2.h,
                                                margin: EdgeInsets.symmetric(horizontal: 8.w),
                                                decoration: BoxDecoration(
                                                  color: state.passcodeStep == PasscodeStep.confirm
                                                      ? AppTheme.colors.primary
                                                      : AppTheme.colors.gray.withValues(alpha: 0.3),
                                                  borderRadius: BorderRadius.circular(2.r),
                                                ),
                                              ),
                                              _buildStepIndicator(2, state.passcodeStep == PasscodeStep.confirm),
                                            ],
                                          ),
                                          Gap(10.h),
                                          Text(
                                            state.passcodeStep == PasscodeStep.create ? "passcode.set_passcode".tr() : "passcode.confirm_passcode".tr(),
                                            style: TextStyle(
                                              fontSize: 22.sp,
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.colors.black,
                                              letterSpacing: -0.5,
                                            ),
                                          ),
                                          Gap(6.h),
                                          Text(
                                            state.passcodeStep == PasscodeStep.create
                                                ? '4 raqamli PIN kod yarating'
                                                : 'PIN kodni qayta kiriting',
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
                                  Gap(24.h),
                                  const PasscodeField(),
                                  Gap(16.h),
                                  const PasscodeKeyboard(),
                                  // Gap(20.h),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
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
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.colors.primary : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? AppTheme.colors.primary : AppTheme.colors.gray.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          '$step',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : AppTheme.colors.gray,
          ),
        ),
      ),
    );
  }
}
