import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ehisob/domain/common/data/user_data.dart';
import 'package:ehisob/infrastructure/services/shared_service.dart';
import 'package:ehisob/presentation/components/back_button.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:ehisob/infrastructure/repository/auth/auth_repository.dart';
import 'package:pinput/pinput.dart';
import 'package:oktoast/oktoast.dart';
import 'package:go_router/go_router.dart';
import 'package:ehisob/presentation/routes/entity/routes.dart';
import 'package:ehisob/presentation/routes/coordinator.dart';
import 'package:shimmer/shimmer.dart';
import '../widgets/delete_account_dialog.dart';
import '../../../assets/asset_index.dart';

class ProfileUpdatePage extends StatefulWidget {
  const ProfileUpdatePage({super.key});

  @override
  State<ProfileUpdatePage> createState() => _ProfileUpdatePageState();
}

class _ProfileUpdatePageState extends State<ProfileUpdatePage> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _repo = AuthRepository();

  late String _initialName;
  late String _initialPhone;
  bool _isNameChanged = false;
  bool _isPhoneChanged = false;
  bool _isPhoneVerified = false;

  final _phoneMask = MaskTextInputFormatter(
    mask: '(##) ###-##-##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  void initState() {
    super.initState();
    _initialName = UserData.name;
    String raw = UserData.phone.replaceAll(RegExp(r'\D'), '');
    if (raw.length == 12 && raw.startsWith('998')) {
      _initialPhone = raw.substring(3);
    } else {
      _initialPhone = raw;
    }

    _nameController = TextEditingController(text: _initialName);

    final maskedText = _phoneMask.maskText(_initialPhone);
    _phoneController = TextEditingController(text: maskedText);
    _phoneMask.formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: maskedText));

    _nameController.addListener(_checkChanges);
    _phoneController.addListener(_checkChanges);
  }

  void _checkChanges() {
    final currentName = _nameController.text.trim();
    final current9Digits = _phoneMask.getUnmaskedText();

    final nameChanged = currentName != _initialName;
    final isPhoneComplete = current9Digits.length == 9;
    final isPhoneDifferent = current9Digits != _initialPhone;

    final phoneChangedState = isPhoneComplete && isPhoneDifferent;

    if (mounted && (_isNameChanged != nameChanged || _isPhoneChanged != phoneChangedState)) {
      setState(() {
        _isNameChanged = nameChanged;
        _isPhoneChanged = phoneChangedState;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showError(Object e) {
    debugPrint('ProfileUpdatePage Error: $e');
    String errorMessage = 'Xatolik yuz berdi';

    if (e is String) {
      errorMessage = e;
    } else if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        if (data['error'] != null) {
          final error = data['error'];
          if (error is Map) {
            errorMessage = error['message']?.toString() ?? error.toString();
          } else {
            errorMessage = error.toString();
          }
        } else if (data['message'] != null) {
          errorMessage = data['message'].toString();
        }
      } else {
        errorMessage = e.message ?? e.toString();
      }
    } else {
      errorMessage = e.toString();
    }

    showToast(
      errorMessage,
      duration: const Duration(seconds: 4),
      position: ToastPosition.bottom,
      backgroundColor: const Color(0xFFEF4444),
      radius: 12.0,
      textStyle: const TextStyle(color: Colors.white, fontSize: 14.0, fontWeight: FontWeight.w600),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final pref = await SharedPrefService.initialize();
      final newName = _nameController.text.trim();

      if (_isNameChanged) {
        final res = await _repo.updateProfileInfo(name: newName);
        if (res['status'] != true) {
          final error = res['error'];
          String? message;
          if (error is Map) message = error['message']?.toString();
          throw message ?? 'Ismni yangilab bo\'lmadi';
        }
      }

      UserData.name = newName;
      pref.setName(UserData.name);
      pref.setPhone(UserData.phone);

      if (mounted) {
        showToast(
          textPadding: EdgeInsets.all(16.r),
          'Profil muvaffaqiyatli yangilandi',
          backgroundColor: const Color(0xFF10B981),
          position: ToastPosition.bottom,
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) _showError(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDeleteAccount() async {
    showDialog(
      context: context,
      builder: (context) => DeleteAccountDialog(
        onConfirm: () async {
          try {
            final res = await _repo.deleteAccount();
            if (res['status'] != true) {
              final error = res['error'];
              String? message;
              if (error is Map) message = error['message']?.toString();
              throw message ?? 'Akkauntni o\'chirib bo\'lmadi';
            }

            final pref = await SharedPrefService.initialize();
            pref.clear();
            UserData.reset();
            setPasscodeVerified(false);

            if (context.mounted) {
              Navigator.pop(context);
              context.go(Routes.signIn.path);
              showToast(
                'Akkaunt muvaffaqiyatli o\'chirildi',
                backgroundColor: const Color(0xFF10B981),
                position: ToastPosition.bottom,
              );
            }
          } catch (e) {
            if (context.mounted) {
              Navigator.pop(context);
              _showError(e);
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = UserData.name.isEmpty ? 'Mening profilim' : UserData.name;
    final userImage = UserData.image;
    final initials = userName.isNotEmpty ? userName[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: const BackArrowButton(),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        title: Text(
          'Profilni tahrirlash',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E293B),
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 8.h),

                // Hero Avatar Section
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 84.r,
                        height: 84.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [AppTheme.colors.primary, const Color(0xFF0D9488)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.colors.primary.withValues(alpha: 0.25),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(42.r),
                          child: userImage.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: userImage,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Shimmer.fromColors(
                                    baseColor: Colors.grey[200]!,
                                    highlightColor: Colors.grey[50]!,
                                    child: Container(color: Colors.white),
                                  ),
                                  errorWidget: (context, url, error) => Center(
                                    child: Text(
                                      initials,
                                      style: TextStyle(fontSize: 30.sp, fontWeight: FontWeight.w900, color: Colors.white),
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    initials,
                                    style: TextStyle(fontSize: 30.sp, fontWeight: FontWeight.w900, color: Colors.white),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 12.h),
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Shaxsiy ma\'lumotlarni yangilash',
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),

                SizedBox(height: 28.h),

                // Grouped Form Fields Container
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ism va familiya',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF475569),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      _buildMinimalInput(
                        controller: _nameController,
                        hint: 'To\'liq ismingiz',
                        icon: CupertinoIcons.person_fill,
                        validator: (v) => (v == null || v.isEmpty) ? 'Ism kiritilmagan' : null,
                      ),

                      SizedBox(height: 16.h),

                      Text(
                        'Telefon raqami',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF475569),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMinimalInput(
                              controller: _phoneController,
                              hint: 'Telefon raqami',
                              icon: CupertinoIcons.phone_fill,
                              keyboardType: TextInputType.phone,
                              formatters: [_phoneMask],
                              prefixText: '+998 ',
                              validator: (v) {
                                final digits = _phoneMask.getUnmaskedText();
                                if (digits.isEmpty) return 'Telefon kiritilmagan';
                                if (digits.length != 9) return 'Telefon raqam to\'liq emas';
                                return null;
                              },
                              suffix: _isPhoneVerified
                                  ? const Icon(CupertinoIcons.checkmark_seal_fill, color: Color(0xFF10B981))
                                  : null,
                            ),
                          ),
                          if (_isPhoneChanged && !_isPhoneVerified) ...[
                            SizedBox(width: 8.w),
                            GestureDetector(
                              onTap: () {
                                if (!_isLoading) {
                                  HapticFeedback.selectionClick();
                                  _handleVerifyPhone();
                                }
                              },
                              child: Container(
                                height: 50.h,
                                padding: EdgeInsets.symmetric(horizontal: 12.w),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(14.r),
                                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                                ),
                                child: Center(
                                  child: Text(
                                    'Tasdiqlash',
                                    style: TextStyle(
                                      color: const Color(0xFF047857),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12.5.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // Submit Button
                _buildSubmitButton(),

                SizedBox(height: 16.h),

                // Delete Account Button
                _buildDeleteAccountButton(),

                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleVerifyPhone() async {
    final digits = _phoneMask.getUnmaskedText();
    if (digits.length != 9) return;

    setState(() => _isLoading = true);
    try {
      final verifyRes = await _repo.updateProfilePhoneVerify(phone: digits);

      if (verifyRes['status'] != true) {
        final error = verifyRes['error'];
        String? message;
        if (error is Map) message = error['message']?.toString();
        throw message ?? 'Xatolik yuz berdi';
      }

      if (verifyRes['result']?['page'] == 'otp_verify') {
        final otpRes = await _repo.otp(phone: digits);
        if (otpRes['status'] != true) {
          throw otpRes['message'] ?? 'OTP yuborishda xatolik';
        }

        if (mounted) {
          setState(() => _isLoading = false);
          _showOtpBottomSheet(digits);
        }
      } else {
        throw 'Kutilmagan javob: ${verifyRes['result']?['page']}';
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError(e);
      }
    }
  }

  void _showOtpBottomSheet(String phone) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _OtpBottomSheet(
        phone: phone,
        onVerified: () {
          setState(() {
            _isPhoneVerified = true;
            _isPhoneChanged = false;
            _initialPhone = phone.replaceAll(RegExp(r'\D'), '');
            if (_initialPhone.startsWith('998')) _initialPhone = _initialPhone.substring(3);
          });
        },
      ),
    );
  }

  Widget _buildMinimalInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? formatters,
    String? Function(String?)? validator,
    Widget? suffix,
    String? prefixText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: formatters,
      validator: validator,
      style: TextStyle(fontSize: 14.5.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: const Color(0xFF94A3B8), fontWeight: FontWeight.w400, fontSize: 14.5.sp),
        prefixIcon: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Icon(icon, size: 18.sp, color: const Color(0xFF64748B)),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 42),
        prefixText: prefixText,
        prefixStyle: TextStyle(fontSize: 14.5.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: AppTheme.colors.primary, width: 1.5),
        ),
        errorStyle: TextStyle(fontSize: 11.sp),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final isEnabled = _isNameChanged || (_isPhoneChanged && _isPhoneVerified);

    return Container(
      width: double.infinity,
      height: 52.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: AppTheme.colors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: (_isLoading || !isEnabled)
            ? null
            : () {
                HapticFeedback.mediumImpact();
                _handleSave();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? AppTheme.colors.primary : const Color(0xFFE2E8F0),
          foregroundColor: isEnabled ? Colors.white : const Color(0xFF94A3B8),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        ),
        child: _isLoading
            ? SizedBox(
                width: 22.r,
                height: 22.r,
                child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(
                'Saqlash',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
      ),
    );
  }

  Widget _buildDeleteAccountButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isLoading
            ? null
            : () {
                HapticFeedback.selectionClick();
                _handleDeleteAccount();
              },
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 13.h),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFFECACA)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.trash_fill, color: const Color(0xFFDC2626), size: 17.sp),
              SizedBox(width: 8.w),
              Text(
                'Akkauntni o\'chirish',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFDC2626),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtpBottomSheet extends StatefulWidget {
  final String phone;
  final VoidCallback onVerified;

  const _OtpBottomSheet({required this.phone, required this.onVerified});

  @override
  State<_OtpBottomSheet> createState() => _OtpBottomSheetState();
}

class _OtpBottomSheetState extends State<_OtpBottomSheet> {
  final _otpController = TextEditingController();
  final _repo = AuthRepository();
  bool _isLoading = false;

  String _formatPhone(String phone) {
    if (phone.length != 9) return phone;
    return '+998 (${phone.substring(0, 2)}) ${phone.substring(2, 5)} ${phone.substring(5, 7)} ${phone.substring(7, 9)}';
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 52.r,
      height: 56.r,
      textStyle: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
    );

    return Container(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 14.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36.w,
            height: 4.h,
            decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2.r)),
          ),
          SizedBox(height: 20.h),
          Text(
            'Tasdiqlash kodi',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
          ),
          SizedBox(height: 6.h),
          Text(
            '${_formatPhone(widget.phone)} raqamiga yuborilgan 4 xonali kodni kiriting',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.sp, color: const Color(0xFF64748B)),
          ),
          SizedBox(height: 24.h),
          Pinput(
            controller: _otpController,
            length: 4,
            defaultPinTheme: defaultPinTheme,
            focusedPinTheme: defaultPinTheme.copyWith(
              decoration: defaultPinTheme.decoration!.copyWith(
                border: Border.all(color: AppTheme.colors.primary, width: 2),
              ),
            ),
            onCompleted: (pin) => _verifyOtp(pin),
          ),
          SizedBox(height: 28.h),
          Container(
            width: double.infinity,
            height: 52.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.colors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : () => _verifyOtp(_otpController.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.colors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                elevation: 0,
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 22.r,
                      height: 22.r,
                      child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      'Tasdiqlash',
                      style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w800),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyOtp(String pin) async {
    if (pin.length < 4) return;

    setState(() => _isLoading = true);
    try {
      final res = await _repo.updateProfilePhoneCheckOtp(phone: widget.phone, otp: pin);

      if (res['status'] != true) {
        final error = res['error'];
        String? message;
        if (error is Map) message = error['message']?.toString();
        throw message ?? 'OTP xato kiritilgan!';
      }

      final pref = await SharedPrefService.initialize();
      UserData.phone = widget.phone;
      pref.setPhone(UserData.phone);

      if (mounted) {
        showToast(
          res['result'] ?? 'Telefon raqam muvaffaqiyatli yangilandi!',
          backgroundColor: const Color(0xFF10B981),
          position: ToastPosition.bottom,
        );
        widget.onVerified();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _otpController.clear();
        _showError(e);
      }
    }
  }

  void _showError(Object e) {
    String errorMessage = 'Xatolik yuz berdi';
    
    if (e is String) {
      errorMessage = e;
    } else if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        if (data['error'] != null) {
          final error = data['error'];
          if (error is Map) {
            errorMessage = error['message']?.toString() ?? error.toString();
          } else {
            errorMessage = error.toString();
          }
        } else if (data['message'] != null) {
          errorMessage = data['message'].toString();
        }
      } else {
        errorMessage = e.message ?? e.toString();
      }
    } else {
      errorMessage = e.toString();
    }

    showToast(
      errorMessage,
      duration: const Duration(seconds: 4),
      position: ToastPosition.bottom,
      backgroundColor: const Color(0xFFEF4444),
      radius: 12.0,
      textStyle: const TextStyle(color: Colors.white, fontSize: 14.0, fontWeight: FontWeight.w600),
    );
  }
}
