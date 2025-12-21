
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hisobchi/application/auth/init/init_auth_bloc.dart';
import 'package:hisobchi/domain/common/second_to_time.dart';
import 'package:hisobchi/presentation/components/defocus.dart';
import 'package:hisobchi/presentation/components/inputs/pin_put_x.dart';
import 'package:hisobchi/presentation/routes/index_routes.dart';
import 'package:timer_count_down/timer_count_down.dart';

import '../../../assets/asset_index.dart';

class SignInConfirmationPage extends StatefulWidget {
  const SignInConfirmationPage({super.key});

  @override
  State<SignInConfirmationPage> createState() => _SignInConfirmationPageState();
}

class _SignInConfirmationPageState extends State<SignInConfirmationPage> {
  bool showCountDown = true;

  @override
  Widget build(BuildContext context) {
    return DeFocus(
      child: Scaffold(
        appBar: AppBar(),
        body: BlocConsumer<InitAuthBloc, InitAuthState>(
          listener: (context, state) {
            if (state is RegisterLoading || state is OtpLoading) {
              EasyLoading.show();
            } else if (state is RegisterSuccess) {
              context.read<InitAuthBloc>().add(ResetAuthEvent());
              EasyLoading.dismiss();
              context.go(Routes.clientPage.path);
            } else {
              EasyLoading.dismiss();
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: ScreenSize.w16,
                top: ScreenSize.h20,
                right: ScreenSize.w16,
              ),
              child: Column(
                children: [
                  SvgPicture.asset(
                    AppIcons.photo,
                    height: 0.13.sh,
                  ),
                  Gap(0.2.sh),
                  PintPutX(
                    onComplete: (value) {
                      context.read<InitAuthBloc>().add(RegisterEvent(otp: value));
                    },
                  ),
                  Gap(0.05.sh),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Visibility(
                        visible: !showCountDown,
                        child: ElevatedButton(
                          onPressed: () {
                            showCountDown = !showCountDown;
                            context.read<InitAuthBloc>().add(
                                  SendOtpEvent(password: context.read<InitAuthBloc>().password,name: context.read<InitAuthBloc>().name),
                                );
                          },
                          style: ElevatedButton.styleFrom(fixedSize: Size.fromHeight(60.h)),
                          child: const Text("Qayta yuborish"),
                        ),
                      ),
                      Visibility(
                        visible: showCountDown,
                        child: Countdown(
                          seconds: 120,
                          build: (_, time) {
                            return Text(
                              tr(
                                'confirmation.resend_in',
                                namedArgs: {'time': secondToTime(time.toInt())},
                              ),
                              style: AppTheme.data.textTheme.titleSmall?.copyWith(
                                color: AppTheme.colors.primary,
                              ),
                            );
                          },
                          onFinished: () {
                            showCountDown = !showCountDown;
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
