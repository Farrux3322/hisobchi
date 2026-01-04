import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/auth/passcode/passcode_cubit.dart';
import 'package:hisobchi/domain/common/enums/passcode_step.dart';
import '../../../assets/asset_index.dart';
import 'components/passcode_field.dart';
import 'components/passcode_keyboard.dart';

class VerifyOldPasscodePage extends StatefulWidget {
  const VerifyOldPasscodePage({super.key});

  @override
  State<VerifyOldPasscodePage> createState() => _VerifyOldPasscodePageState();
}

class _VerifyOldPasscodePageState extends State<VerifyOldPasscodePage>
    with SingleTickerProviderStateMixin {
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
    ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));

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
      create: (context) => PasscodeCubit(passcodeStep: PasscodeStep.check),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: AppTheme.colors.background,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppTheme.colors.black, size: 20.sp),
                onPressed: () => Navigator.pop(context),
              ),
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
                                  Container(
                                    width: 80.w,
                                    height: 80.w,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          AppTheme.colors.primary,
                                          AppTheme.colors.primary
                                              .withValues(alpha: 0.7),
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.colors.primary
                                              .withValues(alpha: 0.25),
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
                                        // Eski PIN kod to'g'ri - yangi PIN kod sahifasiga o'tish
                                        if (context.mounted) {
                                          Navigator.pop(context, true);
                                        }
                                      }

                                      if (state.isIncorrectPasscode) {
                                        // Xato PIN kod kiritildi
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Row(
                                              children: [
                                                Icon(Icons.error_outline,
                                                    color: Colors.white),
                                                SizedBox(width: 8),
                                                Text('Noto\'g\'ri PIN kod!'),
                                              ],
                                            ),
                                            backgroundColor: Colors.red,
                                            behavior: SnackBarBehavior.floating,
                                            duration: Duration(seconds: 2),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    builder: (context, state) {
                                      return Column(
                                        children: [
                                          Text(
                                            'Eski PIN kodni tasdiqlang',
                                            style: TextStyle(
                                              fontSize: 22.sp,
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.colors.black,
                                              letterSpacing: -0.5,
                                            ),
                                          ),
                                          Gap(6.h),
                                          Text(
                                            'Xavfsizlik uchun eski PIN kodni kiriting',
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
}