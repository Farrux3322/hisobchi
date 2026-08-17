import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ehisob/application/auth/passcode/passcode_cubit.dart';
import 'package:ehisob/presentation/assets/asset_index.dart';

class SetPasscodeKeyboard extends StatelessWidget {
  const SetPasscodeKeyboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRow(context, ['1', '2', '3']),
          SizedBox(height: 20.h),
          _buildRow(context, ['4', '5', '6']),
          SizedBox(height: 20.h),
          _buildRow(context, ['7', '8', '9']),
          SizedBox(height: 20.h),
          _buildBottomRow(context),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((n) => _buildNumberKey(context, n)).toList(),
    );
  }

  Widget _buildBottomRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Biometric tugma o'rnidagi bo'sh joy
        SizedBox(
          width: 75.w,
          height: 75.w,
        ),

        // 0 tugma
        _buildNumberKey(context, '0'),

        // Delete tugma
        _buildDeleteKey(context),
      ],
    );
  }

  Widget _buildNumberKey(BuildContext context, String number) {
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
              color: const Color(0xFFE2E8F0),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            number,
            style: TextStyle(
              fontSize: 30.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteKey(BuildContext context) {
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
              color: const Color(0xFFE2E8F0),
              width: 1.5,
            ),
          ),
          child: Icon(
            Icons.backspace_outlined,
            color: const Color(0xFF64748B),
            size: 26.sp,
          ),
        ),
      ),
    );
  }
}
