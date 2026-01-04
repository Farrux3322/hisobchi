import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/auth/passcode/passcode_cubit.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';

class PasscodeKeyboard extends StatelessWidget {
  const PasscodeKeyboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.5.sh,
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      child: GridView.count(
        crossAxisCount: 3,
        mainAxisSpacing: 16.h,
        crossAxisSpacing: 16.w,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildKey('1', context),
          _buildKey('2', context),
          _buildKey('3', context),
          _buildKey('4', context),
          _buildKey('5', context),
          _buildKey('6', context),
          _buildKey('7', context),
          _buildKey('8', context),
          _buildKey('9', context),
          const SizedBox(),
          _buildKey('0', context),
          _buildDeleteKey(context),
        ],
      ),
    );
  }

  Widget _buildKey(String text, BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.read<PasscodeCubit>().fillInput(text),
        borderRadius: BorderRadius.circular(100),
        splashColor: AppTheme.colors.primary.withValues(alpha: 0.1),
        highlightColor: AppTheme.colors.primary.withValues(alpha: 0.05),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.colors.white,
            border: Border.all(
              color: AppTheme.colors.gray.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 28.sp,
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
        onTap: () => context.read<PasscodeCubit>().onBackspacePressed(),
        borderRadius: BorderRadius.circular(100),
        splashColor: AppTheme.colors.red.withValues(alpha: 0.1),
        highlightColor: AppTheme.colors.red.withValues(alpha: 0.05),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.colors.white,
            border: Border.all(
              color: AppTheme.colors.gray.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.backspace_outlined,
            color: AppTheme.colors.gray,
            size: 24.sp,
          ),
        ),
      ),
    );
  }
}
