import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hisobchi/domain/common/data/user_data.dart';
import 'package:hisobchi/infrastructure/services/shared_service.dart';
import 'package:hisobchi/presentation/components/back_button.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:hisobchi/infrastructure/repository/auth/auth_repository.dart';
import 'package:pinput/pinput.dart';
import 'package:oktoast/oktoast.dart';
import 'package:go_router/go_router.dart';
import 'package:hisobchi/presentation/routes/entity/routes.dart';
import 'package:hisobchi/presentation/routes/coordinator.dart';
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

  final _phoneMask = MaskTextInputFormatter(mask: '(##) ###-##-##', filter: {"#": RegExp(r'[0-9]')}, type: MaskAutoCompletionType.lazy);

  @override
  void initState() {
    super.initState();
    _initialName = UserData.name;
    // Normalize initial phone to 9 meaningful digits
    String raw = UserData.phone.replaceAll(RegExp(r'\D'), '');
    if (raw.length == 12 && raw.startsWith('998')) {
      _initialPhone = raw.substring(3);
    } else {
      _initialPhone = raw;
    }

    _nameController = TextEditingController(text: _initialName);

    // Format only the 9 digits for the mask
    final maskedText = _phoneMask.maskText(_initialPhone);
    _phoneController = TextEditingController(text: maskedText);
    
    // Sync the mask formatter internal state by processing the initial value
    _phoneMask.formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: maskedText));

    _nameController.addListener(_checkChanges);
    _phoneController.addListener(_checkChanges);
  }

  void _checkChanges() {
    final currentName = _nameController.text.trim();
    final current9Digits = _phoneMask.getUnmaskedText();

    final nameChanged = currentName != _initialName;

    // Phone is changed AND complete (9 digits)
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
      debugPrint('Dio Error Data: $data');
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

    debugPrint('Action -> showing Error Toast: $errorMessage');
    showToast(
      errorMessage,
      duration: const Duration(seconds: 4),
      position: ToastPosition.center,
      backgroundColor: Colors.red,
      radius: 10.0,
      textStyle: const TextStyle(color: Colors.white, fontSize: 16.0),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final pref = await SharedPrefService.initialize();
      final newName = _nameController.text.trim();

      // Only call API if name actually changed
      if (_isNameChanged) {
        final res = await _repo.updateProfileInfo(name: newName);
        debugPrint('updateProfileInfo Response: $res');
        if (res['status'] != true) {
          final error = res['error'];
          String? message;
          if (error is Map) message = error['message']?.toString();
          throw message ?? 'Ismni yangilab bo\'lmadi';
        }
      }

      // Update UserData
      UserData.name = newName;
      
      // Update SharedPref
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

            // Clear all data
            final pref = await SharedPrefService.initialize();
            pref.clear(); // Clear SharedPreferences
            UserData.reset(); // Clear UserData in-memory
            setPasscodeVerified(false); // Reset session passcode status

            if (context.mounted) {
              Navigator.pop(context); // Close dialog
              context.go(Routes.signIn.path); // Navigate to Sign-In
              showToast(
                'Akkaunt muvaffaqiyatli o\'chirildi',
                backgroundColor: const Color(0xFF10B981),
                position: ToastPosition.bottom,
              );
            }
          } catch (e) {
            if (context.mounted) {
              Navigator.pop(context); // Close dialog
              _showError(e);
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: const BackArrowButton(),
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Profilni tahrirlash',
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // App Logo Section
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(AppIcons.appLogo, height: 80, width: 80),
                      const Gap(12),
                      Text(
                        'E-HISOB',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.colors.primary, letterSpacing: 1),
                      ),
                      const Gap(4),
                      Text(
                        'Profil ma\'lumotlarini yangilash',
                        style: TextStyle(fontSize: 14, color: AppTheme.colors.gray, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const Gap(48),
                  _buildMinimalInput(controller: _nameController, hint: 'To\'liq ismingiz', icon: Icons.person_outline_rounded, validator: (v) => (v == null || v.isEmpty) ? 'Ism kiritilmagan' : null),
                  const Gap(16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMinimalInput(
                          controller: _phoneController,
                          hint: 'Telefon raqami',
                          icon: Icons.phone_android_outlined,
                          keyboardType: TextInputType.phone,
                          formatters: [_phoneMask],
                          prefixText: '+998 ',
                          validator: (v) {
                            final digits = _phoneMask.getUnmaskedText();
                            if (digits.isEmpty) return 'Telefon kiritilmagan';
                            if (digits.length != 9) return 'Telefon raqam to\'liq emas';
                            return null;
                          },
                          suffix: _isPhoneVerified ? const Icon(Icons.check_circle, color: Color(0xFF10B981)) : null,
                        ),
                      ),
                      if (_isPhoneChanged && !_isPhoneVerified) ...[
                        const Gap(12),
                        GestureDetector(
                          onTap: () => _isLoading ? null : _handleVerifyPhone(),
                          child: Container(
                            height: 58,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.2)),
                            ),
                            child: const Center(
                              child: Text(
                                'Tasdiqlash',
                                style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const Gap(20),
                  _buildSubmitButton(),
                  const Gap(24),
                  _buildDeleteAccountButton(),
                  const Gap(80),
                ],
              ),
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
      // Step 1: Verify if phone can be changed
      final verifyRes = await _repo.updateProfilePhoneVerify(phone: digits);

      if (verifyRes['status'] != true) {
        final error = verifyRes['error'];
        String? message;
        if (error is Map) message = error['message']?.toString();
        throw message ?? 'Xatolik yuz berdi';
      }

      // Step 2: If verify success and page is otp_verify, send OTP
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
            _isPhoneChanged = false; // Reset changed state since its verified and updated
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
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w400, fontSize: 16),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 20, right: 10),
          child: Icon(icon, size: 22, color: const Color(0xFF94A3B8)),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 50),
        prefixText: prefixText,
        prefixStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: AppTheme.colors.primary.withValues(alpha: 0.5), width: 1.5),
        ),
        errorStyle: TextStyle(fontSize: 12.sp),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final isEnabled = _isNameChanged || (_isPhoneChanged && _isPhoneVerified);

    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: (_isLoading || !isEnabled) ? null : _handleSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? AppTheme.colors.primary : Colors.grey[300],
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: _isLoading
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Saqlash', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
      ),
    );
  }

  Widget _buildDeleteAccountButton() {
    return TextButton(
      onPressed: _isLoading ? null : _handleDeleteAccount,
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFFEF4444),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFEF4444), width: 1),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_remove_rounded, size: 20),
          Gap(8),
          Text(
            'Akkauntni o\'chirish',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
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
      width: 56,
      height: 60,
      textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.transparent),
      ),
    );

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 32,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
          const Gap(24),
          const Text('Tasdiqlash kodi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Gap(12),
          Text(
            '${_formatPhone(widget.phone)} raqamiga yuborilgan kodni kiriting',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF94A3B8)),
          ),
          const Gap(32),
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
          const Gap(40),
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: _isLoading ? null : () => _verifyOtp(_otpController.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.colors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Tasdiqlash',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
      debugPrint('updateProfilePhoneCheckOtp Response: $res');

      if (res['status'] != true) {
        final error = res['error'];
        String? message;
        if (error is Map) message = error['message']?.toString();
        throw message ?? 'OTP xato kiritilgan!';
      }

      // Success
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
    debugPrint('_OtpBottomSheet Error: $e');
    String errorMessage = 'Xatolik yuz berdi';
    
    if (e is String) {
      errorMessage = e;
    } else if (e is DioException) {
      final data = e.response?.data;
      debugPrint('Dio Error Data (Sheet): $data');
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

    debugPrint('Action -> showing Error Toast (Sheet): $errorMessage');
    showToast(
      errorMessage,
      duration: const Duration(seconds: 4),
      position: ToastPosition.center,
      backgroundColor: Colors.red,
      radius: 10.0,
      textStyle: const TextStyle(color: Colors.white, fontSize: 16.0),
    );
  }
}
