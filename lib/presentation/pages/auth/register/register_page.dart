import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/auth/init/init_auth_bloc.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/components/defocus.dart';
import 'package:hisobchi/presentation/pages/auth/register/terms_of_service_page.dart';
import 'package:hisobchi/presentation/routes/index_routes.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with TickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();

  bool _showPassword1   = true;
  bool _showPassword2   = true;
  bool _isOfertaAccepted = false;      // ← yangi

  String? password1, password2, name = '';

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset>  _slideAnimation;
  late Animation<double>  _scaleAnimation;

  final FocusNode _nameFocusNode      = FocusNode();
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

    _fadeAnimation  = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
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
    _nameFocusNode.dispose();
    _password1FocusNode.dispose();
    _password2FocusNode.dispose();
    super.dispose();
  }

  // ─── Oferta ───────────────────────────────────────────────────────────────

  Future<void> _openOferta() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const TermsOfServicePage()),
    );
    // TermsOfServicePage "Qabul qilaman" bosilsa true qaytaradi
    if (result == true && mounted) {
      HapticFeedback.mediumImpact();
      setState(() => _isOfertaAccepted = true);
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

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
                          _buildWelcomeSection(),
                          SizedBox(height: 16.h),
                          _buildFormSection(state),
                          SizedBox(height: 16.h),
                          _buildOfertaSection(),         // ← oferta
                          SizedBox(height: 16.h),
                          _buildRegisterButton(state),
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

  // ─── Logo ─────────────────────────────────────────────────────────────────

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
                  ),
                ],
              ),
              child: Image.asset(AppIcons.appLogo, height: 70.h, width: 70.w),
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
                gradient: LinearGradient(colors: [
                  AppTheme.colors.primary.withValues(alpha: 0.3),
                  AppTheme.colors.primary,
                  AppTheme.colors.primary.withValues(alpha: 0.3),
                ]),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Welcome ──────────────────────────────────────────────────────────────

  Widget _buildWelcomeSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            Text(
              tr('sign_in.register'),
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
              'Ma\'lumotlarni kiriting',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppTheme.colors.black.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Form ─────────────────────────────────────────────────────────────────

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
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNameField(state),
              SizedBox(height: 20.h),
              _buildPasswordField(state),
              SizedBox(height: 20.h),
              _buildConfirmPasswordField(state),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Oferta section ───────────────────────────────────────────────────────

  Widget _buildOfertaSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: _isOfertaAccepted
                ? AppTheme.colors.primary.withValues(alpha: 0.05)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: _isOfertaAccepted
                  ? AppTheme.colors.primary.withValues(alpha: 0.35)
                  : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // ── Checkbox ────────────────────────────────────────────────
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
                        ? AppTheme.colors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(7.r),
                    border: Border.all(
                      color: _isOfertaAccepted
                          ? AppTheme.colors.primary
                          : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: _isOfertaAccepted
                      ? Icon(Icons.check_rounded, size: 14.sp, color: Colors.white)
                      : null,
                ),
              ),
              SizedBox(width: 10.w),

              // ── Text ─────────────────────────────────────────────────────
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppTheme.colors.black.withValues(alpha: 0.7),
                      height: 1.4,
                    ),
                    children: [
                      const TextSpan(text: 'Men '),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: GestureDetector(
                          onTap: _openOferta,
                          child: Text(
                            'foydalanish shartlari',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.colors.primary,
                              decoration: TextDecoration.underline,
                              decorationColor: AppTheme.colors.primary,
                            ),
                          ),
                        ),
                      ),
                      const TextSpan(text: 'ni o\'qib chiqdim va roziman'),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 6.w),

              // ── Open icon ─────────────────────────────────────────────────
              GestureDetector(
                onTap: _openOferta,
                child: Icon(
                  Icons.open_in_new_rounded,
                  size: 16.sp,
                  color: AppTheme.colors.primary.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Register button ──────────────────────────────────────────────────────

  Widget _buildRegisterButton(InitAuthState state) {
    final isLoading = state is OtpLoading;
    final isEnabled = !isLoading && _isOfertaAccepted;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            // ── Hint when oferta not accepted ──────────────────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) =>
                  FadeTransition(opacity: anim, child: SizeTransition(sizeFactor: anim, child: child)),
              child: !_isOfertaAccepted
                  ? Padding(
                key: const ValueKey('hint'),
                padding: EdgeInsets.only(bottom: 10.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline_rounded, size: 14.sp, color: Colors.orange.shade600),
                    SizedBox(width: 6.w),
                    Text(
                      'Davom etish uchun shartlarni qabul qiling',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.orange.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
                  : const SizedBox(key: ValueKey('empty')),
            ),

            // ── Button ────────────────────────────────────────────────────
            AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: isEnabled ? 1.0 : 0.45,
              child: SizedBox(
                width: double.infinity,
                height: 60.h,
                child: ElevatedButton(
                  onPressed: isEnabled
                      ? () {
                    if (formKey.currentState!.validate()) {
                      HapticFeedback.mediumImpact();
                      context.read<InitAuthBloc>().add(
                        SendOtpEvent(password: password2!, name: name ?? ''),
                      );
                    }
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.colors.primary,
                    foregroundColor: Colors.white,
                    elevation: isEnabled ? 4 : 0,
                    shadowColor: AppTheme.colors.primary.withValues(alpha: 0.35),
                    disabledBackgroundColor: AppTheme.colors.primary,
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
                        tr('sign_in.register'),
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
          ],
        ),
      ),
    );
  }

  // ─── Form fields (o'zgarmagan) ────────────────────────────────────────────

  InputDecoration _fieldDecoration({String? hint, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: AppTheme.colors.black.withValues(alpha: 0.3),
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: AppTheme.colors.primary.withValues(alpha: 0.03),
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(color: AppTheme.colors.primary.withValues(alpha: 0.1), width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(color: AppTheme.colors.primary.withValues(alpha: 0.1), width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(color: AppTheme.colors.primary, width: 2.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2.5),
      ),
    );
  }

  Widget _fieldLabel(String text, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppTheme.colors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, size: 20.sp, color: AppTheme.colors.primary),
        ),
        SizedBox(width: 12.w),
        Text(
          text,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppTheme.colors.black),
        ),
      ],
    );
  }

  Widget _buildNameField(InitAuthState state) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _fieldLabel(tr('sign_in.name'), Icons.person_outline_rounded),
      SizedBox(height: 12.h),
      TextFormField(
        initialValue: '',
        focusNode: _nameFocusNode,
        enabled: state is! OtpLoading,
        keyboardType: TextInputType.name,
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppTheme.colors.black),
        decoration: _fieldDecoration(hint: 'Ismingizni kiriting'),
        onChanged: (v) => name = v,
        validator: (v) => (v?.isEmpty ?? false) ? tr('errors.this_field_cannot_empty') : null,
      ),
    ]);
  }

  Widget _buildPasswordField(InitAuthState state) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _fieldLabel(tr('sign_in.new_password'), Icons.lock_rounded),
      SizedBox(height: 12.h),
      TextFormField(
        initialValue: '',
        focusNode: _password1FocusNode,
        obscureText: _showPassword1,
        enabled: state is! OtpLoading,
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppTheme.colors.black),
        decoration: _fieldDecoration(
          hint: '••••••••',
          suffix: IconButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(() => _showPassword1 = !_showPassword1);
            },
            icon: Icon(
              _showPassword1 ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              color: AppTheme.colors.primary,
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
    ]);
  }

  Widget _buildConfirmPasswordField(InitAuthState state) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _fieldLabel(tr('sign_in.retry_password'), Icons.lock_outline_rounded),
      SizedBox(height: 12.h),
      TextFormField(
        initialValue: '',
        focusNode: _password2FocusNode,
        obscureText: _showPassword2,
        enabled: state is! OtpLoading,
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppTheme.colors.black),
        decoration: _fieldDecoration(
          hint: '••••••••',
          suffix: IconButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(() => _showPassword2 = !_showPassword2);
            },
            icon: Icon(
              _showPassword2 ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              color: AppTheme.colors.primary,
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
    ]);
  }
}