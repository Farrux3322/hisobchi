import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ehisob/application/auth/init/init_auth_bloc.dart';
import 'package:ehisob/presentation/assets/asset_index.dart';
import 'package:ehisob/presentation/components/defocus.dart';
import 'package:ehisob/presentation/pages/auth/register/terms_of_service_page.dart';
import 'package:ehisob/presentation/routes/index_routes.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();

  bool _showPassword1 = true;
  bool _showPassword2 = true;
  bool _isOfertaAccepted = false;

  String? password1, password2, name = '';

  late AnimationController _fadeController;
  late AnimationController _floatController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _floatAnimation;

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _password1FocusNode = FocusNode();
  final FocusNode _password2FocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );

    _floatAnimation = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _floatController.dispose();
    _nameFocusNode.dispose();
    _password1FocusNode.dispose();
    _password2FocusNode.dispose();
    super.dispose();
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
    return DeFocus(
      child: BlocConsumer<InitAuthBloc, InitAuthState>(
        listener: (context, state) {
          if (state is OtpSuccess) {
            HapticFeedback.mediumImpact();
            context.pushReplacement(Routes.signInConfirmation.path);
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
                              const Color(0xFF10B981).withValues(alpha: 0.18),
                              AppTheme.colors.primary.withValues(alpha: 0.08),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Center(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 24.w, vertical: 16.h),
                            child: Form(
                              key: formKey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildHeroHeader(),
                                  SizedBox(height: 20.h),
                                  _buildGlassFormCard(state),
                                  SizedBox(height: 24.h),
                                  _buildSecurityFooter(),
                                ],
                              ),
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

  /// Header Branding Section
  Widget _buildHeroHeader() {
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
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Image.asset(
                  AppIcons.appLogo,
                  height: 48.h,
                  width: 48.w,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: 12.h),

            Text(
              'Ro\'yxatdan O\'tish',
              style: TextStyle(
                fontSize: 26.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Yangi EHisob hisobingizni yarating',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Form Card Section
  Widget _buildGlassFormCard(InitAuthState state) {
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNameField(state),
                  SizedBox(height: 14.h),
                  _buildPasswordField(state),
                  SizedBox(height: 14.h),
                  _buildConfirmPasswordField(state),
                  SizedBox(height: 16.h),
                  _buildOfertaSection(),
                  SizedBox(height: 20.h),
                  _buildRegisterButton(state),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Oferta Section
  Widget _buildOfertaSection() {
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

  /// Register Submit Button
  Widget _buildRegisterButton(InitAuthState state) {
    final isLoading = state is OtpLoading;
    final isEnabled = !isLoading && _isOfertaAccepted;

    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: !_isOfertaAccepted
              ? Padding(
                  key: const ValueKey('hint'),
                  padding: EdgeInsets.only(bottom: 6.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline_rounded,
                          size: 12.sp, color: Colors.amber.shade800),
                      SizedBox(width: 4.w),
                      Text(
                        'Davom etish uchun shartlarni qabul qiling',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.amber.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox(key: ValueKey('empty')),
        ),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: isEnabled ? 1.0 : 0.5,
          child: SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: isEnabled
                  ? () {
                      if (formKey.currentState!.validate()) {
                        HapticFeedback.mediumImpact();
                        context.read<InitAuthBloc>().add(
                              SendOtpEvent(
                                password: password2!,
                                name: name ?? '',
                              ),
                            );
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 22.w,
                      height: 22.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          tr('sign_in.register'),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(Icons.arrow_forward_rounded, size: 20.sp),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  /// Fields
  Widget _buildNameField(InitAuthState state) {
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
          initialValue: '',
          focusNode: _nameFocusNode,
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
          onChanged: (v) => name = v,
          validator: (v) =>
              (v?.isEmpty ?? false) ? tr('errors.this_field_cannot_empty') : null,
        ),
      ],
    );
  }

  Widget _buildPasswordField(InitAuthState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          initialValue: '',
          focusNode: _password1FocusNode,
          obscureText: _showPassword1,
          enabled: state is! OtpLoading,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
          decoration: _inputDecoration(
            hint: '••••••••',
            icon: CupertinoIcons.lock,
            suffix: IconButton(
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(minWidth: 44.w, minHeight: 44.h),
              splashRadius: 20.r,
              onPressed: () {
                HapticFeedback.selectionClick();
                setState(() => _showPassword1 = !_showPassword1);
              },
              icon: Icon(
                _showPassword1
                    ? CupertinoIcons.eye_slash
                    : CupertinoIcons.eye,
                color: const Color(0xFF64748B),
                size: 20.sp,
              ),
            ),
          ),
          onChanged: (v) => password1 = v,
          validator: (v) {
            if (v?.isEmpty ?? false) return tr('errors.this_field_cannot_empty');
            if ((v?.length ?? 0) < 6) return tr('errors.min_password');
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
          initialValue: '',
          focusNode: _password2FocusNode,
          obscureText: _showPassword2,
          enabled: state is! OtpLoading,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
          decoration: _inputDecoration(
            hint: '••••••••',
            icon: CupertinoIcons.lock_shield,
            suffix: IconButton(
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(minWidth: 44.w, minHeight: 44.h),
              splashRadius: 20.r,
              onPressed: () {
                HapticFeedback.selectionClick();
                setState(() => _showPassword2 = !_showPassword2);
              },
              icon: Icon(
                _showPassword2
                    ? CupertinoIcons.eye_slash
                    : CupertinoIcons.eye,
                color: const Color(0xFF64748B),
                size: 20.sp,
              ),
            ),
          ),
          onChanged: (v) => password2 = v,
          validator: (v) {
            if (v?.isEmpty ?? false) return tr('errors.this_field_cannot_empty');
            if (password1 != password2) return tr('errors.incorrect_password');
            return null;
          },
        ),
      ],
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
        borderSide: const BorderSide(
          color: Color(0xFF10B981),
          width: 2,
        ),
      ),
      suffixIcon: suffix,
    );
  }

  Widget _buildSecurityFooter() {
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