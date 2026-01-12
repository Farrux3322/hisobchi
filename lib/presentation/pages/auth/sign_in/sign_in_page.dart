import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hisobchi/application/app_manager/app_manager_cubit.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/assets/res/app_icons.dart';
import 'package:hisobchi/presentation/components/buttons/text_button.dart';
import 'package:hisobchi/presentation/components/register_dialog.dart';
import 'package:hisobchi/presentation/routes/index_routes.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../../../application/auth/init/init_auth_bloc.dart';
import '../../../components/defocus.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> with TickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  var maskFormatter = MaskTextInputFormatter(
    mask: '+998 (##) ###-##-##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );
  String password = '';
  bool showPassword = true;
  TextEditingController controller = TextEditingController(text: "+998");
  String pageStatus = '';

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _passwordController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _passwordFadeAnimation;
  late Animation<Offset> _passwordSlideAnimation;

  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _showPasswordField = false;

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

    _passwordController = AnimationController(
      duration: const Duration(milliseconds: 600),
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

    _passwordFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _passwordController, curve: Curves.easeOut),
    );

    _passwordSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _passwordController, curve: Curves.easeOutCubic));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _passwordController.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppManagerCubit.context = context;
    return DeFocus(
      child: BlocConsumer<InitAuthBloc, InitAuthState>(
        listener: (context, state) {
          if (state is InitSuccess) {
            pageStatus = state.pageStatus;
            if (state.pageStatus == "register") {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return WarningNotRegisterDialog(
                    phone: maskFormatter.getMaskedText(),
                    onPressed: () => context.push(Routes.register.path),
                  );
                },
              );
            } else if (state.pageStatus == "login") {
              // Show password field with animation
              if (!_showPasswordField) {
                setState(() {
                  _showPasswordField = true;
                });
                _passwordController.forward();
                // Auto focus on password field after animation
                Future.delayed(const Duration(milliseconds: 400), () {
                  if (mounted) {
                    _passwordFocusNode.requestFocus();
                  }
                });
              }
            }
          }
          if (state is SignInSuccess) {
            HapticFeedback.mediumImpact();
            context.push(Routes.homePage.path);
          } else if (state is SignInError) {
            HapticFeedback.heavyImpact();
            EasyLoading.showError(state.error);
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
                    Colors.blueAccent.shade100,
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
                          SizedBox(height: 24.h),
                          _buildLogoSection(),
                          SizedBox(height: 24.h),
                          _buildWelcomeSection(),
                          SizedBox(height: 24.h),
                          _buildFormSection(state),
                          if (_showPasswordField) ...[
                            SizedBox(height: 24.h),
                            _buildLoginButton(state),
                          ],
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
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.colors.primary.withValues(alpha: 0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Image.asset(
                AppIcons.appLogo,
                height: 100.h,
                width: 100.w,
              ),
            ),
            Text(
              'E-HISOB',
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.w900,
                color: AppTheme.colors.primary,
                letterSpacing: 1,
                fontFamily: 'SF Pro Display',
              ),
            ),
            SizedBox(height: 4.h),
            Container(
              height: 3.h,
              width: 40.w,
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

  Widget _buildWelcomeSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            Text(
              tr('sign_in.welcome_back'),
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.w800,
                color: AppTheme.colors.black,
                letterSpacing: -0.5,
                height: 1.2,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              tr('sign_in.subtitle'),
              style: TextStyle(
                fontSize: 16.sp,
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
              _buildPhoneField(state),
              if (_showPasswordField) ...[
                SizedBox(height: 20.h),
                FadeTransition(
                  opacity: _passwordFadeAnimation,
                  child: SlideTransition(
                    position: _passwordSlideAnimation,
                    child: _buildPasswordField(state),
                  ),
                ),
                SizedBox(height: 16.h),
                FadeTransition(
                  opacity: _passwordFadeAnimation,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButtonX(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        context.push(Routes.resetPassword.path);
                      },
                      text: "Parolni tiklash",
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneField(InitAuthState state) {
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
                Icons.phone_android_rounded,
                size: 20.sp,
                color: AppTheme.colors.primary,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              tr('sign_in.phone_number'),
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
          controller: controller,
          focusNode: _phoneFocusNode,
          enabled: state is! LoadingState || state is! SignInLoading,
          keyboardType: TextInputType.phone,
          inputFormatters: [maskFormatter],
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.colors.black,
          ),
          decoration: InputDecoration(
            hintText: '+998 (90) 123-45-67',
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
            suffixIcon: _buildPhoneSuffixIcon(state),
          ),
          onChanged: (v) {
            if (maskFormatter.isFill()) {
              context.read<InitAuthBloc>().add(
                    VerifyNumber(
                      phone: maskFormatter.getUnmaskedText(),
                    ),
                  );
            }
          },
          validator: (v) {
            if (v?.isEmpty ?? false) {
              return tr('errors.this_field_cannot_empty');
            }
            if (!maskFormatter.isFill()) {
              return tr('errors.incorrect_text');
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget? _buildPhoneSuffixIcon(InitAuthState state) {
    if ((state is InitSuccess && state.pageStatus == "login") ||
        (state is SignInError && pageStatus == 'login')) {
      return Container(
        margin: EdgeInsets.all(12.w),
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check_rounded,
          color: const Color(0xFF10B981),
          size: 20.sp,
        ),
      );
    } else if (state is LoadingState) {
      return Padding(
        padding: EdgeInsets.all(12.w),
        child: SizedBox(
          width: 24.w,
          height: 24.h,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.colors.primary),
          ),
        ),
      );
    }
    return null;
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
              tr('sign_in.password'),
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
          focusNode: _passwordFocusNode,
          obscureText: showPassword,
          enabled: (state is! LoadingState || state is! SignInLoading),
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
                  showPassword = !showPassword;
                });
              },
              icon: Icon(
                showPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: AppTheme.colors.primary,
                size: 20.sp,
              ),
            ),
          ),
          onChanged: (v) => password = v,
          validator: (v) {
            if (v?.isEmpty ?? false) {
              return tr('errors.this_field_cannot_empty');
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLoginButton(InitAuthState state) {
    final isLoading = state is LoadingState || state is SignInLoading;

    if (!_showPasswordField) {
      return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: _passwordFadeAnimation,
      child: SlideTransition(
        position: _passwordSlideAnimation,
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
                            SignInEvent(
                              phone: maskFormatter.getUnmaskedText(),
                              password: password,
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
                        tr('sign_in.login'),
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