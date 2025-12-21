import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hisobchi/application/auth/passcode/passcode_cubit.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';

class PasscodeKeyboard extends StatelessWidget {
  const PasscodeKeyboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.6.sh,
      width: 0.55.sw,
      padding: EdgeInsets.zero,
      child: GridView.count(
        crossAxisCount: 3,
        mainAxisSpacing: 15.h,
        crossAxisSpacing: 15.w,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          keyboard('1', context),
          keyboard('2', context),
          keyboard('3', context),
          keyboard('4', context),
          keyboard('5', context),
          keyboard('6', context),
          keyboard('7', context),
          keyboard('8', context),
          keyboard('9', context),
          const SizedBox(),
          keyboard('0', context),
          keyboardDel(context),
        ],
      ),
    );
  }

  Widget keyboard(
    String text,
    BuildContext context,
  ) {
    return RawMaterialButton(
      onPressed: () => context.read<PasscodeCubit>().fillInput(text),
      shape: const CircleBorder(),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.colors.black),
        ),
        child: Text(
          text,
          style: AppTheme.data.textTheme.displaySmall,
        ),
      ),
    );
  }

  Widget keyboardDel(BuildContext context) {
    return RawMaterialButton(
      onPressed: () => context.read<PasscodeCubit>().onBackspacePressed(),
      shape: const CircleBorder(),
      child: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: SvgPicture.asset(
          AppIcons.backspace,
          height: 0.05.sw,
        ),
      ),
    );
  }
}
