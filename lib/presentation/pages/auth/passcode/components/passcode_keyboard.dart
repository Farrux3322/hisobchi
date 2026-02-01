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
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRow(['1', '2', '3']),
          SizedBox(height: 20.h),
          _buildRow(['4', '5', '6']),
          SizedBox(height: 20.h),
          _buildRow(['7', '8', '9']),
          SizedBox(height: 20.h),
          _buildBottomRow(),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((n) => _buildNumberKey(n)).toList(),
    );
  }

  Widget _buildBottomRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Biometric tugma
        SizedBox(
          width: 75.w,
          height: 75.w,
          child: _canCheckBiometrics && _availableBiometrics.isNotEmpty
              ? _buildBiometricKey()
              : const SizedBox(),
        ),

        // 0 tugma
        _buildNumberKey('0'),

        // Delete tugma
        _buildDeleteKey(),
      ],
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
        customBorder: const CircleBorder(),
        splashColor: AppTheme.colors.primary.withValues(alpha: 0.15),
        highlightColor: AppTheme.colors.primary.withValues(alpha: 0.1),
        child: Container(
          width: 75.w,
          height: 75.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
              color: AppTheme.colors.gray.withValues(alpha: 0.12),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            number,
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.colors.black,
              // Senior: Using font display properly
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
        customBorder: const CircleBorder(),
        splashColor: AppTheme.colors.primary.withValues(alpha: 0.15),
        highlightColor: AppTheme.colors.primary.withValues(alpha: 0.1),
        child: Container(
          width: 75.w,
          height: 75.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.colors.primary.withValues(alpha: 0.08),
            border: Border.all(
              color: AppTheme.colors.primary.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            size: 32.sp,
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
        customBorder: const CircleBorder(),
        splashColor: AppTheme.colors.red.withValues(alpha: 0.1),
        highlightColor: AppTheme.colors.red.withValues(alpha: 0.05),
        child: Container(
          width: 75.w,
          height: 75.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
              color: AppTheme.colors.gray.withValues(alpha: 0.12),
              width: 1.5,
            ),
          ),
          child: Icon(
            Icons.backspace_outlined,
            color: AppTheme.colors.gray.withValues(alpha: 0.8),
            size: 26.sp,
          ),
        ),
      ),
    );
  }
}