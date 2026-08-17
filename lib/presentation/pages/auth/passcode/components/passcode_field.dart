import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ehisob/application/auth/passcode/passcode_cubit.dart';
import 'package:ehisob/presentation/assets/asset_index.dart';

class PasscodeField extends StatelessWidget {
  const PasscodeField({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.15.sw),
      child: BlocConsumer<PasscodeCubit, PasscodeState>(
        listener: (context, state) {
          if (state.isIncorrectPasscode) {
            Future.delayed(const Duration(milliseconds: 350), () {
              if (context.mounted) context.read<PasscodeCubit>().clearIncorrectField();
            });
          }
        },
        builder: (context, state) {
          return Shake(
            key: ValueKey<bool>(state.isIncorrectPasscode),
            preferences: AnimationPreferences(
              autoPlay: state.isIncorrectPasscode ? AnimationPlayStates.Forward : AnimationPlayStates.None,
              duration: const Duration(milliseconds: 600),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < 4; i++) ...[
                  _buildDot(i, state),
                  if (i < 3) SizedBox(width: 24.w),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDot(int index, PasscodeState state) {
    final isFilled = state.filledInputCount >= index;
    final isError = state.isIncorrectPasscode;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 250),
      tween: Tween(begin: 0.0, end: isFilled ? 1.0 : 0.0),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isError
                  ? AppTheme.colors.red
                  : isFilled
                      ? AppTheme.colors.primary
                      : Colors.transparent,
              border: Border.all(
                color: isError
                    ? AppTheme.colors.red
                    : isFilled
                        ? AppTheme.colors.primary
                        : AppTheme.colors.gray.withValues(alpha: 0.35),
                width: 2.5,
              ),
              boxShadow: isFilled && !isError
                  ? [
                      BoxShadow(
                        color: AppTheme.colors.primary.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
          ),
        );
      },
    );
  }
}
