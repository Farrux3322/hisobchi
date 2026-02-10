import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/routes/index_routes.dart';

class WarningNotRegisterDialog extends StatefulWidget {
  const WarningNotRegisterDialog({
    super.key,
    required this.onPressed,
    required this.phone,
  });

  final VoidCallback onPressed;
  final String phone;

  @override
  State<WarningNotRegisterDialog> createState() => _WarningNotRegisterDialogState();
}

class _WarningNotRegisterDialogState extends State<WarningNotRegisterDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AlertDialog(
          backgroundColor: Colors.white,
          elevation: 24,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.r),
          ),
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: 340.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28.r),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  AppTheme.colors.primary.withValues(alpha: 0.01),
                ],
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Decorative top bar
                  Container(
                    height: 6.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.colors.primary.withValues(alpha: 0.3),
                          AppTheme.colors.primary,
                          AppTheme.colors.primary.withValues(alpha: 0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(28.r),
                        topRight: Radius.circular(28.r),
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.fromLTRB(28.w, 28.h, 28.w, 24.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon with animated background
                        SlideTransition(
                          position: _slideAnimation,
                          child: SvgPicture.asset(
                            AppIcons.warningYellow,
                            // height: 48.h,
                            // width: 48.w,
                          ),
                        ),

                        SizedBox(height: 20.h),

                        // Title
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Text(
                            'Ro\'yxatdan o\'ting',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.colors.black,
                              letterSpacing: -0.3,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        SizedBox(height: 8.h),

                        // Message with phone number
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            children: [
                              Text(
                                tr('sign_in.not_register', namedArgs: {'phone': widget.phone}),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.colors.black.withValues(alpha: 0.6),
                                  height: 1.4,
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 14.w,
                                  vertical: 8.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.colors.primary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: AppTheme.colors.primary.withValues(alpha: 0.15),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  widget.phone,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.colors.primary,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 24.h),

                        // Register button
                        SlideTransition(
                          position: _slideAnimation,
                          child: SizedBox(
                            width: double.infinity,
                            height: 50.h,
                            child: ElevatedButton(
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                context.pop();
                                widget.onPressed();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.colors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shadowColor: AppTheme.colors.primary.withValues(alpha: 0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.r),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.person_add_rounded, size: 18.sp),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'sign_in.register'.tr(),
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 10.h),

                        // Return button
                        SlideTransition(
                          position: _slideAnimation,
                          child: SizedBox(
                            width: double.infinity,
                            height: 44.h,
                            child: TextButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                context.pop();
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.colors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.r),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.arrow_back_rounded, size: 16.sp),
                                  SizedBox(width: 6.w),
                                  Text(
                                    'sign_in.return_home'.tr(),
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
