import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/auth/passcode/passcode_cubit.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';

class SetPasscodeKeyboard extends StatelessWidget {
  const SetPasscodeKeyboard({super.key});

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
              return _buildNumberKey(context, '${index + 1}');
            },
          ),

          SizedBox(height: 16.h),

          // Oxirgi qator: Bo'sh joy, 0, Delete
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Bo'sh joy (biometric tugma o'rnida)
              SizedBox(
                width: 70.w,
                height: 70.w,
              ),

              SizedBox(width: 20.w),

              // 0 tugma
              SizedBox(
                width: 70.w,
                height: 70.w,
                child: _buildNumberKey(context, '0'),
              ),

              SizedBox(width: 20.w),

              // Delete tugma
              SizedBox(
                width: 70.w,
                height: 70.w,
                child: _buildDeleteKey(context),
              ),
            ],
          ),
        ],
      ),
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

  Widget _buildDeleteKey(BuildContext context) {
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