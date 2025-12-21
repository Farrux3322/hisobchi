import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hisobchi/application/auth/passcode/passcode_cubit.dart';
import 'package:hisobchi/infrastructure/services/shared_service.dart';
import '../../../../domain/common/enums/passcode_step.dart';
import '../../../assets/asset_index.dart';
import 'components/passcode_field.dart';
import 'components/passcode_keyboard.dart';

class SetPasscodePage extends StatelessWidget {
  const SetPasscodePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PasscodeCubit>(
      create: (context) => PasscodeCubit(passcodeStep: PasscodeStep.create),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(),
            body: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  Gap(0.05.sh),
                  Align(child: SvgPicture.asset(AppIcons.photo, width: 0.13.sh)),
                  Gap(0.03.sh),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: BlocConsumer<PasscodeCubit, PasscodeState>(
                      listener: (context, state) {
                        if (state.isProcessCompleted) {
                          SharedPrefService.initialize().then((pref) {
                            pref
                              ..setAuthStatus(true)
                              ..setPasscode(state.passcodeOne.substring(0, 4));
                          });
                          // UserData.authStatus = true;
                          //
                          // if (UserData.role.contains('seller')) {
                          //   context.go("/${Routes.product.name}");
                          // } else if (UserData.role.contains("inspection")) {
                          //   context.go("/${Routes.inspectionStartPage.name}");
                          //   context.read<InspectionBloc>().add(const CheckInspectionEvent());
                          // } else {
                          //   context.go("/${Routes.addImages.name}");
                          // }
                        }
                      },
                      builder: (context, state) {
                        return Text(
                          state.passcodeStep == PasscodeStep.create ? "passcode.set_passcode".tr() : "passcode.confirm_passcode".tr(),
                          style: AppTheme.data.textTheme.headlineLarge,
                        );
                      },
                    ),
                  ),
                  Gap(0.04.sh),
                  const PasscodeField(),
                  Gap(0.04.sh),
                  const PasscodeKeyboard()
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
