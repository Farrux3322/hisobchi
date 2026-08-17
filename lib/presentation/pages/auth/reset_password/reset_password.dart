import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ehisob/application/auth/init/init_auth_bloc.dart';
import 'package:ehisob/presentation/assets/asset_index.dart';
import 'package:ehisob/presentation/components/defocus.dart';
import 'package:ehisob/presentation/routes/index_routes.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage>
    with TickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  bool showPassword1 = true;
  bool showPassword2 = true;

  String? password1, password2 = '';

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  final FocusNode _password1FocusNode = FocusNode();
  final FocusNode _password2FocusNode = FocusNode();

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
    _password1FocusNode.dispose();
    _password2FocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DeFocus(
      child: BlocConsumer<InitAuthBloc, InitAuthState>(
        listener: (context, state) {
          if (state is OtpSuccess) {
            HapticFeedback.mediumImpact();
            context.pushReplacement(Routes.resetOTP.path);
          }
        },
        builder: (context, state) {
          return Scaffold(
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
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: [
                          SizedBox(height: 16.h),
                          _buildLogoSection(),
                          SizedBox(height: 16.h),
                          _buildTitleSection(),
                          SizedBox(height: 16.h),
                          _buildFormSection(state),
                          SizedBox(height: 16.h),
                          _buildResetButton(state),
                          SizedBox(height: 16.h),
                        ],
                      ),
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

  Widget _buildLogoSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
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
                height: 70.h,
                width: 70.w,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'E-HISOB',
              style: TextStyle(
                fontSize: 22.sp,
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
              'Parolni tiklash',
              style: TextStyle(
                fontSize: 26.sp,
                fontWeight: FontWeight.w800,
                color: AppTheme.colors.black,
                letterSpacing: -0.4,
                height: 1.2,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Yangi parolni kiriting',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppTheme.colors.black.withValues(alpha: 0.6),
                letterSpacing: 0,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection(InitAuthState state) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPasswordField(state),
              SizedBox(height: 20.h),
              _buildConfirmPasswordField(state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(InitAuthState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppTheme.colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.lock_rounded,
                size: 20.sp,
                color: AppTheme.colors.primary,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              tr('sign_in.new_password'),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.colors.black,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        TextFormField(
          initialValue: '',
          focusNode: _password1FocusNode,
          obscureText: showPassword1,
          enabled: state is! OtpLoading,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.colors.black,
          ),
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: TextStyle(
              color: AppTheme.colors.black.withValues(alpha: 0.3),
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: AppTheme.colors.primary.withValues(alpha: 0.03),
            contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(
                color: AppTheme.colors.primary.withValues(alpha: 0.1),
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(
                color: AppTheme.colors.primary.withValues(alpha: 0.1),
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(
                color: AppTheme.colors.primary,
                width: 2.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444),
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444),
                width: 2.5,
              ),
            ),
            suffixIcon: IconButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                setState(() {
                  showPassword1 = !showPassword1;
                });
              },
              icon: Icon(
                showPassword1 ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: AppTheme.colors.primary,
                size: 20.sp,
              ),
            ),
          ),
          onChanged: (v) => password1 = v,
          validator: (v) {
            if (v?.isEmpty ?? false) {
              return tr('errors.this_field_cannot_empty');
            }
            if ((v?.length ?? 0) < 6) {
              return tr('errors.min_password');
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField(InitAuthState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppTheme.colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.lock_outline_rounded,
                size: 20.sp,
                color: AppTheme.colors.primary,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              tr('sign_in.retry_password'),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.colors.black,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        TextFormField(
          initialValue: '',
          focusNode: _password2FocusNode,
          obscureText: showPassword2,
          enabled: state is! OtpLoading,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.colors.black,
          ),
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: TextStyle(
              color: AppTheme.colors.black.withValues(alpha: 0.3),
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: AppTheme.colors.primary.withValues(alpha: 0.03),
            contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(
                color: AppTheme.colors.primary.withValues(alpha: 0.1),
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(
                color: AppTheme.colors.primary.withValues(alpha: 0.1),
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(
                color: AppTheme.colors.primary,
                width: 2.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444),
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444),
                width: 2.5,
              ),
            ),
            suffixIcon: IconButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                setState(() {
                  showPassword2 = !showPassword2;
                });
              },
              icon: Icon(
                showPassword2 ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: AppTheme.colors.primary,
                size: 20.sp,
              ),
            ),
          ),
          onChanged: (v) => password2 = v,
          validator: (v) {
            if (v?.isEmpty ?? false) {
              return tr('errors.this_field_cannot_empty');
            }
            if (password1 != password2) {
              return tr('errors.incorrect_password');
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildResetButton(InitAuthState state) {
    final isLoading = state is OtpLoading;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SizedBox(
          width: double.infinity,
          height: 60.h,
          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : () async {
                    if (formKey.currentState!.validate()) {
                      HapticFeedback.mediumImpact();
                      context.read<InitAuthBloc>().add(
                            SendOtpEvent(
                              password: password2!,
                              name: context.read<InitAuthBloc>().name,
                            ),
                          );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.colors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shadowColor: AppTheme.colors.primary.withValues(alpha: 0.4),
              disabledBackgroundColor: AppTheme.colors.primary.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: isLoading
                ? SizedBox(
                    width: 24.w,
                    height: 24.h,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Parolni yangilash',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.arrow_forward_rounded, size: 22.sp),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
