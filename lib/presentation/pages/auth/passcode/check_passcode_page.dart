import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hisobchi/application/app_manager/app_manager_cubit.dart';
import 'package:hisobchi/application/auth/passcode/passcode_cubit.dart';
import '../../../assets/asset_index.dart';
import 'components/passcode_field.dart';
import 'components/passcode_keyboard.dart';

class CheckPasscodePage extends StatefulWidget {
  const CheckPasscodePage({super.key});

  @override
  State<CheckPasscodePage> createState() => _CheckPasscodePageState();
}

class _CheckPasscodePageState extends State<CheckPasscodePage> {
  int forDeveloper = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppManagerCubit.context = context;
    return BlocProvider<PasscodeCubit>(
      create: (context) => PasscodeCubit(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(),
            body: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  Align(child: SvgPicture.asset(AppIcons.photo, width: 0.13.sh)),
                  Gap(0.03.sh),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: BlocConsumer<PasscodeCubit, PasscodeState>(
                      listener: (context, state) {
                        if (state.isProcessCompleted) {
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
                          tr('passcode.enter_passcode'),
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
