import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ehisob/application/staff/staff_bloc.dart';
import 'package:ehisob/application/staff/staff_event.dart';
import 'package:ehisob/application/staff/staff_state.dart';
import 'package:ehisob/domain/common/constants.dart';
import 'package:ehisob/presentation/assets/asset_index.dart';
import 'package:ehisob/presentation/components/back_button.dart';
import 'package:ehisob/presentation/components/toast/toast.dart';
import 'package:pinput/pinput.dart';

class StaffOtpPage extends StatefulWidget {
  final String phone;
  final String name;
  final String password;
  final List<String> permissions;

  const StaffOtpPage({
    super.key,
    required this.phone,
    required this.name,
    required this.password,
    required this.permissions,
  });

  @override
  State<StaffOtpPage> createState() => _StaffOtpPageState();
}

class _StaffOtpPageState extends State<StaffOtpPage> {
  final _pinController = TextEditingController();
  Timer? _timer;
  int _secondsLeft = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _secondsLeft = 60;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          _canResend = true;
          t.cancel();
        }
      });
    });
  }

  void _resendOtp() {
    if (!_canResend) return;
    _pinController.clear();
    context.read<StaffBloc>().add(StaffSendOtp(phone: widget.phone));
    _startTimer();
  }

  void _verifyOtp(String code) {
    if (code.length < 4) return;
    context.read<StaffBloc>().add(StaffVerifyOtp(phone: widget.phone, otpCode: code));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StaffBloc, StaffState>(
      listener: (context, state) {
        if (state.lastAction == StaffActionType.verifyOtp && state.statusAction == Status.success) {
          // Verify was successful → create the staff member
          final token = state.verifyToken ?? '';
          context.read<StaffBloc>().add(StaffCreate(
            phone: widget.phone,
            verifyToken: token,
            name: widget.name,
            password: widget.password,
            permissions: widget.permissions,
          ));
        }

        if (state.lastAction == StaffActionType.createStaff && state.statusAction == Status.success) {
          Toast.showSuccessToast(message: 'Xodim muvaffaqiyatli qo\'shildi');
          // Pop back to list (2 pages: OTP + AddPage)
          int count = 0;
          Navigator.popUntil(context, (_) => count++ >= 2);
        }

        if (state.statusAction == Status.error &&
            (state.lastAction == StaffActionType.verifyOtp || state.lastAction == StaffActionType.createStaff)) {
          _pinController.clear();
          Toast.showErrorToast(message: state.errorMessage ?? 'Xatolik yuz berdi');
        }
      },
      builder: (context, state) {
        final isVerifying = state.statusAction == Status.loading &&
            (state.lastAction == StaffActionType.verifyOtp || state.lastAction == StaffActionType.createStaff);

        final theme = PinTheme(
          width: 56.w,
          height: 58.h,
          textStyle: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
          ),
        );

        final focusedTheme = theme.copyWith(
          decoration: theme.decoration!.copyWith(border: Border.all(color: AppTheme.colors.primary, width: 2)),
        );

        final submittedTheme = theme.copyWith(
          decoration: theme.decoration!.copyWith(
            color: AppTheme.colors.primary.withValues(alpha: 0.05),
            border: Border.all(color: AppTheme.colors.primary.withValues(alpha: 0.4), width: 1.5),
          ),
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text('OTP tasdiqlash'),
            backgroundColor: Colors.white,
            leading: BackArrowButton(),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  SizedBox(height: 48.h),
                  // ... (rest of the code)

                  // Icon
                  Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.colors.primary, AppTheme.colors.primary.withValues(alpha: 0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.sms_outlined, color: Colors.white, size: 36.sp),
                  ),

                  SizedBox(height: 24.h),

                  Text(
                    'Tasdiqlash kodini kiriting',
                    style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B), letterSpacing: -0.5),
                  ),

                  SizedBox(height: 10.h),

                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B), height: 1.5),
                      children: [
                        const TextSpan(text: '+998 '),
                        TextSpan(
                          text: widget.phone,
                          style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                        ),
                        const TextSpan(text: ' raqamiga\n4 xonali kod yuborildi'),
                      ],
                    ),
                  ),

                  SizedBox(height: 40.h),

                  // PIN input
                  Pinput(
                    length: 4,
                    controller: _pinController,
                    defaultPinTheme: theme,
                    focusedPinTheme: focusedTheme,
                    submittedPinTheme: submittedTheme,
                    keyboardType: TextInputType.number,
                    onCompleted: _verifyOtp,
                    enabled: !isVerifying,
                    hapticFeedbackType: HapticFeedbackType.lightImpact,
                  ),

                  SizedBox(height: 32.h),

                  // Loading / Verify button
                  if (isVerifying)
                    Column(
                      children: [
                        CircularProgressIndicator(color: AppTheme.colors.primary, strokeWidth: 2.5),
                        SizedBox(height: 12.h),
                        Text(
                          'Tekshirilmoqda...',
                          style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B)),
                        ),
                      ],
                    )
                  else
                   SizedBox(),

                  SizedBox(height: 24.h),

                  // Resend timer
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _canResend
                        ? TextButton.icon(
                            key: const ValueKey('resend'),
                            onPressed: _resendOtp,
                            icon: Icon(Icons.refresh_rounded, size: 18.sp, color: AppTheme.colors.primary),
                            label: Text(
                              'Qayta yuborish',
                              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppTheme.colors.primary),
                            ),
                          )
                        : Row(
                            key: const ValueKey('timer'),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.timer_outlined, size: 16.sp, color: const Color(0xFF94A3B8)),
                              SizedBox(width: 6.w),
                              Text(
                                '${_secondsLeft}s dan so\'ng qayta yuborish',
                                style: TextStyle(fontSize: 14.sp, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
