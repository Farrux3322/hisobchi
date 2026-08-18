import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ehisob/presentation/assets/asset_index.dart';
import 'package:ehisob/presentation/components/buttons/text_button.dart';
import 'package:ehisob/presentation/components/register_dialog.dart';
import 'package:ehisob/presentation/pages/auth/register/terms_of_service_page.dart';
import 'package:ehisob/presentation/routes/index_routes.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../../../application/auth/init/init_auth_bloc.dart';
import '../../../components/defocus.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage>
    with TickerProviderStateMixin {
  final loginFormKey = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();

  // 0: Kirish, 1: Ro'yxatdan o'tish
  int _selectedTab = 0;

  var maskFormatter = MaskTextInputFormatter(
    mask: '+998 (##) ###-##-##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  // Login controllers & state
  TextEditingController phoneController = TextEditingController(text: "+998");
  String password = '';
  bool showPassword = true;
  bool _showPasswordField = false;
  String pageStatus = '';

  // Register state
  String? registerName = '';
  String? registerPassword1 = '';
  String? registerPassword2 = '';
  bool _showRegPassword1 = true;
  bool _showRegPassword2 = true;
  bool _isOfertaAccepted = false;

  late AnimationController _fadeController;
  late AnimationController _passwordController;
  late AnimationController _floatController;
  late AnimationController _shimmerController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _passwordFadeAnimation;
  late Animation<Offset> _passwordSlideAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _shimmerAnimation;

  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _regNameFocusNode = FocusNode();
  final FocusNode _regPassword1FocusNode = FocusNode();
  final FocusNode _regPassword2FocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _passwordController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );

    _passwordFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _passwordController, curve: Curves.easeOutCubic),
    );

    _passwordSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _passwordController, curve: Curves.easeOutCubic),
    );

    _floatAnimation = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _shimmerAnimation = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _passwordController.dispose();
    _floatController.dispose();
    _shimmerController.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _regNameFocusNode.dispose();
    _regPassword1FocusNode.dispose();
    _regPassword2FocusNode.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void _switchTab(int tab) {
    if (_selectedTab == tab) return;
    HapticFeedback.selectionClick();
    FocusScope.of(context).unfocus();
    setState(() {
      _selectedTab = tab;
    });
  }

  void _resetPhoneField() {
    HapticFeedback.lightImpact();
    setState(() {
      _showPasswordField = false;
    });
    _passwordController.reverse();
    _phoneFocusNode.requestFocus();
  }

  Future<void> _openOferta() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const TermsOfServicePage()),
    );
    if (result == true && mounted) {
      HapticFeedback.mediumImpact();
      setState(() => _isOfertaAccepted = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppTheme.colors.primary;

    return DeFocus(
      child: BlocConsumer<InitAuthBloc, InitAuthState>(
        listener: (context, state) {
          if (state is InitSuccess) {
            pageStatus = state.pageStatus;
            if (state.pageStatus == "register") {
              setState(() {
                _selectedTab = 1;
              });
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return WarningNotRegisterDialog(
                    phone: maskFormatter.getMaskedText(),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  );
                },
              );
            } else if (state.pageStatus == "login") {
              if (!_showPasswordField) {
                setState(() {
                  _showPasswordField = true;
                });
                _passwordController.forward();
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (mounted) {
                    _passwordFocusNode.requestFocus();
                  }
                });
              }
            }
          } else if (state is OtpSuccess) {
            HapticFeedback.mediumImpact();
            context.pushReplacement(Routes.signInConfirmation.path);
          } else if (state is SignInSuccess) {
            HapticFeedback.mediumImpact();
            final result = state.meData.result;
            if (result.role.length == 1 &&
                result.role.contains('user') &&
                result.worksFor.isEmpty) {
              context.goNamed(Routes.homePage.name);
            } else {
              context.goNamed(
                Routes.workspaceSelection.name,
                extra: state.meData,
              );
            }
          } else if (state is SignInError) {
            HapticFeedback.heavyImpact();
            EasyLoading.showError(state.error);
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: const Color(0xFFF1F5F9),
            body: AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Stack(
                  children: [
                    // Dynamic Orbs
                    Positioned(
                      top: -100.h + (_floatAnimation.value * 1.5),
                      right: -80.w,
                      child: Container(
                        width: 320.w,
                        height: 320.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              primaryColor.withValues(alpha: 0.18),
                              const Color(0xFF3B82F6).withValues(alpha: 0.08),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -120.h - (_floatAnimation.value * 1.5),
                      left: -90.w,
                      child: Container(
                        width: 340.w,
                        height: 340.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF10B981).withValues(alpha: 0.15),
                              primaryColor.withValues(alpha: 0.05),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Main Scrollable Content
                    SafeArea(
                      child: Center(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 24.w, vertical: 16.h),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Top Brand Stage
                                _buildTopBrandingStage(primaryColor),

                                SizedBox(height: 24.h),

                                // Gliding Segmented Tab Switcher
                                _buildSegmentedTab(primaryColor),

                                SizedBox(height: 20.h),

                                // Silky Smooth Glassmorphism Form Studio (AnimatedCrossFade)
                                _buildGlassFormCard(state, primaryColor),

                                SizedBox(height: 24.h),

                                // Security Footer
                                _buildSecurityBadge(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  /// Top Brand Stage
  Widget _buildTopBrandingStage(Color primaryColor) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            Transform.translate(
              offset: Offset(0, _floatAnimation.value * 0.4),
              child: Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.15),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.15),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Image.asset(
                  AppIcons.appLogo,
                  height: 54.h,
                  width: 54.w,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            SizedBox(height: 14.h),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.r),
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.6),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'EHISOB • MOLIYA PLATFORMASI',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF334155),
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12.h),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _selectedTab == 0 ? 'Tizimga Kirish' : 'Ro\'yxatdan O\'tish',
                key: ValueKey(_selectedTab),
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _selectedTab == 0
                    ? (_showPasswordField
                        ? 'Parolingizni kiriting va tizimga kiring'
                        : 'Telefon raqamingizni kiriting va davom eting')
                    : 'Yangi EHisob hisobingizni yarating',
                key: ValueKey('${_selectedTab}_$_showPasswordField'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Gliding Segmented Control Tab Switcher
  Widget _buildSegmentedTab(Color primaryColor) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        height: 52.h,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26.r),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tabWidth = (constraints.maxWidth - 8.w) / 2;
            return Stack(
              children: [
                // Gliding Indicator Box
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  left: _selectedTab == 0 ? 0 : tabWidth,
                  top: 0,
                  bottom: 0,
                  width: tabWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _selectedTab == 0
                          ? primaryColor
                          : const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(22.r),
                      boxShadow: [
                        BoxShadow(
                          color: (_selectedTab == 0
                                  ? primaryColor
                                  : const Color(0xFF10B981))
                              .withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),

                // Tab Buttons Row
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _switchTab(0),
                        behavior: HitTestBehavior.opaque,
                        child: Center(
                          child: Text(
                            'Tizimga Kirish',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: _selectedTab == 0
                                  ? Colors.white
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _switchTab(1),
                        behavior: HitTestBehavior.opaque,
                        child: Center(
                          child: Text(
                            'Ro\'yxatdan O\'tish',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: _selectedTab == 1
                                  ? Colors.white
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Silky Smooth Glassmorphism Form Card (AnimatedCrossFade)
  Widget _buildGlassFormCard(InitAuthState state, Color primaryColor) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(30.r),
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: AnimatedCrossFade(
                crossFadeState: _selectedTab == 0
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                duration: const Duration(milliseconds: 350),
                firstCurve: Curves.easeOutCubic,
                secondCurve: Curves.easeOutCubic,
                sizeCurve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                firstChild: Form(
                  key: loginFormKey,
                  child: _buildLoginForm(state, primaryColor),
                ),
                secondChild: Form(
                  key: registerFormKey,
                  child: _buildRegisterForm(state),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Login Form
  Widget _buildLoginForm(InitAuthState state, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TELEFON RAQAM',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF475569),
                letterSpacing: 0.5,
              ),
            ),
            if (_showPasswordField)
              InkWell(
                onTap: _resetPhoneField,
                borderRadius: BorderRadius.circular(12.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 12.sp,
                        color: primaryColor,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'O\'zgartirish',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 8.h),

        // Phone Input
        TextFormField(
          controller: phoneController,
          focusNode: _phoneFocusNode,
          enabled: (state is! LoadingState || state is! SignInLoading) &&
              !_showPasswordField,
          keyboardType: TextInputType.phone,
          inputFormatters: [maskFormatter],
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
            letterSpacing: 0.5,
          ),
          decoration: InputDecoration(
            hintText: '+998 (90) 123-45-67',
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: _showPasswordField
                ? const Color(0xFFF1F5F9)
                : const Color(0xFFF8FAFC),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            prefixIcon: Container(
              margin: EdgeInsets.only(left: 12.w, right: 8.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🇺🇿', style: TextStyle(fontSize: 18.sp)),
                  SizedBox(width: 6.w),
                  Container(
                    width: 1.w,
                    height: 18.h,
                    color: Colors.grey.shade300,
                  ),
                ],
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18.r),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18.r),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18.r),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18.r),
              borderSide: BorderSide(
                color: primaryColor,
                width: 2,
              ),
            ),
            suffixIcon: _buildPhoneSuffixIcon(state, primaryColor),
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

        // Password Input (Animated Reveal)
        if (_showPasswordField) ...[
          SizedBox(height: 18.h),
          FadeTransition(
            opacity: _passwordFadeAnimation,
            child: SlideTransition(
              position: _passwordSlideAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PAROL',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF475569),
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextFormField(
                    initialValue: '',
                    focusNode: _passwordFocusNode,
                    obscureText: showPassword,
                    enabled:
                        (state is! LoadingState || state is! SignInLoading),
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 16.h),
                      suffixIconConstraints: BoxConstraints(
                        minWidth: 46.w,
                        minHeight: 46.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18.r),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18.r),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18.r),
                        borderSide: BorderSide(
                          color: primaryColor,
                          width: 2,
                        ),
                      ),
                      suffixIcon: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(minWidth: 44.w, minHeight: 44.h),
                        splashRadius: 20.r,
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                        icon: Icon(
                          showPassword
                              ? CupertinoIcons.eye_slash
                              : CupertinoIcons.eye,
                          color: const Color(0xFF64748B),
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
                  SizedBox(height: 10.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButtonX(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        context.push(Routes.resetPassword.path);
                      },
                      text: "Parolni tiklash?",
                    ),
                  ),
                  SizedBox(height: 20.h),
                  _buildShimmerButton(
                    text: tr('sign_in.login'),
                    onPressed: () async {
                      if (loginFormKey.currentState!.validate()) {
                        HapticFeedback.mediumImpact();
                        context.read<InitAuthBloc>().add(
                              SignInEvent(
                                phone: maskFormatter.getUnmaskedText(),
                                password: password,
                              ),
                            );
                      }
                    },
                    isLoading: state is LoadingState || state is SignInLoading,
                    gradientColors: [
                      primaryColor,
                      const Color(0xFF2563EB),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Register Form
  Widget _buildRegisterForm(InitAuthState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ISM VA FAMILIYA',
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF475569),
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 6.h),
        TextFormField(
          initialValue: registerName,
          focusNode: _regNameFocusNode,
          enabled: state is! OtpLoading,
          keyboardType: TextInputType.name,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
          decoration: _inputDecoration(
            hint: 'Ismingizni kiriting',
            icon: Icons.person_outline_rounded,
          ),
          onChanged: (v) => registerName = v,
          validator: (v) => (v?.isEmpty ?? false)
              ? tr('errors.this_field_cannot_empty')
              : null,
        ),

        SizedBox(height: 14.h),

        Text(
          'YANGI PAROL',
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF475569),
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 6.h),
        TextFormField(
          initialValue: registerPassword1,
          focusNode: _regPassword1FocusNode,
          obscureText: _showRegPassword1,
          enabled: state is! OtpLoading,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
          decoration: _inputDecoration(
            hint: '••••••••',
            icon: Icons.lock_outline_rounded,
            suffix: IconButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                setState(() => _showRegPassword1 = !_showRegPassword1);
              },
              icon: Icon(
                _showRegPassword1
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: const Color(0xFF64748B),
                size: 20.sp,
              ),
            ),
          ),
          onChanged: (v) => registerPassword1 = v,
          validator: (v) {
            if (v?.isEmpty ?? false) return tr('errors.this_field_cannot_empty');
            if ((v?.length ?? 0) < 6) return tr('errors.min_password');
            return null;
          },
        ),

        SizedBox(height: 14.h),

        Text(
          'PAROLNI TAKRORLANG',
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF475569),
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 6.h),
        TextFormField(
          initialValue: registerPassword2,
          focusNode: _regPassword2FocusNode,
          obscureText: _showRegPassword2,
          enabled: state is! OtpLoading,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
          decoration: _inputDecoration(
            hint: '••••••••',
            icon: Icons.lock_reset_rounded,
            suffix: IconButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                setState(() => _showRegPassword2 = !_showRegPassword2);
              },
              icon: Icon(
                _showRegPassword2
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: const Color(0xFF64748B),
                size: 20.sp,
              ),
            ),
          ),
          onChanged: (v) => registerPassword2 = v,
          validator: (v) {
            if (v?.isEmpty ?? false) return tr('errors.this_field_cannot_empty');
            if (registerPassword1 != registerPassword2) {
              return tr('errors.incorrect_password');
            }
            return null;
          },
        ),

        SizedBox(height: 16.h),

        _buildOfertaBox(),

        SizedBox(height: 20.h),

        _buildShimmerButton(
          text: tr('sign_in.register'),
          onPressed: _isOfertaAccepted
              ? () {
                  if (registerFormKey.currentState!.validate()) {
                    HapticFeedback.mediumImpact();
                    context.read<InitAuthBloc>().add(
                          SendOtpEvent(
                            password: registerPassword2!,
                            name: registerName ?? '',
                          ),
                        );
                  }
                }
              : null,
          isLoading: state is OtpLoading,
          gradientColors: const [
            Color(0xFF10B981),
            Color(0xFF059669),
          ],
        ),
      ],
    );
  }

  /// Oferta Checkbox Box
  Widget _buildOfertaBox() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: _isOfertaAccepted
            ? const Color(0xFFECFDF5)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: _isOfertaAccepted
              ? const Color(0xFFA7F3D0)
              : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _isOfertaAccepted = !_isOfertaAccepted);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20.w,
              height: 20.h,
              decoration: BoxDecoration(
                color: _isOfertaAccepted
                    ? const Color(0xFF10B981)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(
                  color: _isOfertaAccepted
                      ? const Color(0xFF10B981)
                      : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: _isOfertaAccepted
                  ? Icon(Icons.check_rounded, size: 14.sp, color: Colors.white)
                  : null,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 10.sp,
                  color: const Color(0xFF475569),
                  height: 1.4,
                ),
                children: [
                  const TextSpan(text: 'Men '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: GestureDetector(
                      onTap: _openOferta,
                      child: Text(
                        'ommaviy oferta shartlari',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF10B981),
                          decoration: TextDecoration.underline,
                          decorationColor: const Color(0xFF10B981),
                        ),
                      ),
                    ),
                  ),
                  const TextSpan(text: 'ni o\'qib chiqdim va roziman'),
                ],
              ),
            ),
          ),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: _openOferta,
            child: Icon(
              Icons.open_in_new_rounded,
              size: 14.sp,
              color: const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }

  /// Phone Suffix Icon
  Widget? _buildPhoneSuffixIcon(InitAuthState state, Color primaryColor) {
    if ((state is InitSuccess && state.pageStatus == "login") ||
        _showPasswordField ||
        (state is SignInError && pageStatus == 'login')) {
      return Container(
        margin: EdgeInsets.all(10.w),
        padding: EdgeInsets.all(4.w),
        decoration: const BoxDecoration(
          color: Color(0xFFECFDF5),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check_rounded,
          color: const Color(0xFF10B981),
          size: 16.sp,
        ),
      );
    } else if (state is LoadingState) {
      return Padding(
        padding: EdgeInsets.all(12.w),
        child: SizedBox(
          width: 20.w,
          height: 20.h,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
        ),
      );
    }
    return null;
  }

  /// Shimmer Animated Button
  Widget _buildShimmerButton({
    required String text,
    required VoidCallback? onPressed,
    required bool isLoading,
    required List<Color> gradientColors,
  }) {
    final isEnabled = onPressed != null && !isLoading;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isEnabled ? 1.0 : 0.5,
      child: GestureDetector(
        onTap: isEnabled ? onPressed : null,
        child: AnimatedBuilder(
          animation: _shimmerAnimation,
          builder: (context, child) {
            return Container(
              height: 52.h,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22.r),
                boxShadow: isEnabled
                    ? [
                        BoxShadow(
                          color: gradientColors.first.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : [],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (isLoading)
                    SizedBox(
                      width: 22.w,
                      height: 22.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          text,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 20.sp,
                          color: Colors.white,
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.grey.shade400,
        fontSize: 15.sp,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18.r),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18.r),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18.r),
        borderSide: const BorderSide(
          color: Color(0xFF10B981),
          width: 2,
        ),
      ),
      suffixIcon: suffix,
    );
  }

  /// Security Footer Badge
  Widget _buildSecurityBadge() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shield_outlined,
            size: 14.sp,
            color: const Color(0xFF94A3B8),
          ),
          SizedBox(width: 6.w),
          Text(
            '256-bit SSL shifrlangan va xavfsiz bog\'lanish',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}