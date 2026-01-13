import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/auth/passcode/passcode_cubit.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/infrastructure/services/shared_service.dart';
import 'package:local_auth/local_auth.dart';

class PasscodeKeyboard extends StatefulWidget {
  const PasscodeKeyboard({super.key});

  @override
  State<PasscodeKeyboard> createState() => _PasscodeKeyboardState();
}

class _PasscodeKeyboardState extends State<PasscodeKeyboard> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _canCheckBiometrics = false;
  List<BiometricType> _availableBiometrics = [];

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics = false;
    List<BiometricType> availableBiometrics = [];

    try {
      canCheckBiometrics = await _localAuth.canCheckBiometrics;

      if (canCheckBiometrics) {
        availableBiometrics = await _localAuth.getAvailableBiometrics();
      }
    } catch (e) {
      debugPrint('Error checking biometrics: $e');
    }

    if (mounted) {
      setState(() {
        _canCheckBiometrics = canCheckBiometrics;
        _availableBiometrics = availableBiometrics;
      });

      // Senior: Auto-prompt biometrics if available and enabled
      final pref = await SharedPrefService.initialize();
      if (canCheckBiometrics && availableBiometrics.isNotEmpty && pref.isBiometricEnabled) {
        // Delay slightly to allow UI to settle and avoid issues on some devices
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _authenticateWithBiometrics();
          }
        });
      }

      debugPrint('Can check biometrics: $canCheckBiometrics');
      debugPrint('Available biometrics: $_availableBiometrics');
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      debugPrint('Starting biometric authentication...');

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Ilovaga kirish uchun autentifikatsiya qiling',

      );

      debugPrint('Authentication result: $didAuthenticate');

      if (didAuthenticate && mounted) {
        HapticFeedback.heavyImpact();
        context.read<PasscodeCubit>().completeBiometric();
      }
    } catch (e) {
      debugPrint('Biometric authentication error: $e');
      if (mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text('Autentifikatsiya xatosi: $e'),
        //     backgroundColor: AppTheme.colors.red,
        //   ),
        // );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Raqamlar 1-9
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 20.w,
              mainAxisSpacing: 16.h,
              childAspectRatio: 1.15,
            ),
            itemCount: 9,
            itemBuilder: (context, index) {
              return _buildNumberKey('${index + 1}');
            },
          ),

          SizedBox(height: 16.h),

          // Oxirgi qator: Biometric, 0, Delete
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Biometric tugma
              SizedBox(
                width: 70.w,
                height: 70.w,
                child: _canCheckBiometrics && _availableBiometrics.isNotEmpty
                    ? _buildBiometricKey()
                    : const SizedBox(),
              ),

              SizedBox(width: 20.w),

              // 0 tugma
              SizedBox(
                width: 70.w,
                height: 70.w,
                child: _buildNumberKey('0'),
              ),

              SizedBox(width: 20.w),

              // Delete tugma
              SizedBox(
                width: 70.w,
                height: 70.w,
                child: _buildDeleteKey(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberKey(String number) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          context.read<PasscodeCubit>().fillInput(number);
        },
        borderRadius: BorderRadius.circular(20.r),
        splashColor: AppTheme.colors.primary.withValues(alpha: 0.1),
        highlightColor: AppTheme.colors.primary.withValues(alpha: 0.05),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.white.withValues(alpha: 0.95),
              ],
            ),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: AppTheme.colors.gray.withValues(alpha: 0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.colors.primary.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: -2,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            number,
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.colors.black,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricKey() {
    IconData icon = Icons.fingerprint;

    if (Platform.isIOS) {
      if (_availableBiometrics.contains(BiometricType.face)) {
        icon = Icons.face;
      }
    } else {
      if (_availableBiometrics.contains(BiometricType.fingerprint)) {
        icon = Icons.fingerprint;
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _authenticateWithBiometrics,
        borderRadius: BorderRadius.circular(20.r),
        splashColor: AppTheme.colors.primary.withValues(alpha: 0.2),
        highlightColor: AppTheme.colors.primary.withValues(alpha: 0.1),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.colors.primary.withValues(alpha: 0.12),
                AppTheme.colors.primary.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: AppTheme.colors.primary.withValues(alpha: 0.25),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.colors.primary.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: -2,
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 36.sp,
            color: AppTheme.colors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteKey() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          context.read<PasscodeCubit>().onBackspacePressed();
        },
        borderRadius: BorderRadius.circular(20.r),
        splashColor: AppTheme.colors.gray.withValues(alpha: 0.1),
        highlightColor: AppTheme.colors.gray.withValues(alpha: 0.05),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.white.withValues(alpha: 0.95),
              ],
            ),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: AppTheme.colors.gray.withValues(alpha: 0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.colors.gray.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: -2,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.backspace_outlined,
            color: AppTheme.colors.gray.withValues(alpha: 0.8),
            size: 28.sp,
          ),
        ),
      ),
    );
  }
}