
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hisobchi/application/auth/init/init_auth_bloc.dart';
import 'package:hisobchi/presentation/components/defocus.dart';
import 'package:hisobchi/presentation/components/inputs/pin_put_x.dart';
import 'package:hisobchi/presentation/routes/index_routes.dart';
import 'package:timer_count_down/timer_count_down.dart';

import '../../../../domain/common/second_to_time.dart';
import '../../../assets/asset_index.dart';

class RestOTPPage extends StatefulWidget {
  const RestOTPPage({super.key});

  @override
  State<RestOTPPage> createState() => _RestOTPPageState();
}

class _RestOTPPageState extends State<RestOTPPage> {
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
              // context.pushReplacement(Routes.createPasscode.path);
              // if (UserData.role == 'seller') {
              //   context.go("/${Routes.product.name}");
              // } else if (UserData.role == "inspection") {
              //   context.go("/${Routes.inspectionStartPage.name}");
              //   context.read<InspectionBloc>().add(const CheckInspectionEvent());
              // } else {
              //   context.go("/${Routes.addImages.name}");
              // }
              context.go(Routes.clientPage.path);
              // if (UserData.role == 'seller' || UserData.role == 'admin') {
              //   context.go("/${Routes.rootSeller.name}/${Routes.product.name}");
              // } else if (UserData.role == "inspection") {
              //   context.go("/${Routes.rootInspection.name}/${Routes.inspectionHomePage.name}");
              // } else if (UserData.role == "gold_inspection") {
              //   context.go("/${Routes.rootGoldInspection.name}/${Routes.goldInspectionHomePage.name}");
              // } else {
              //   context.go("/${Routes.rootPhoto.name}/${Routes.addImages.name}");
              // }
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
                  SvgPicture.asset(AppIcons.photo, height: 0.13.sh),
                  Gap(0.2.sh),
                  PintPutX(
                    onComplete: (value) {
                      context.read<InitAuthBloc>().add(ResetSendOtpEvent(otp: value, password: context.read<InitAuthBloc>().password));
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
