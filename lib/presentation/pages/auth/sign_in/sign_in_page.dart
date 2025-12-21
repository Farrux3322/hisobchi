import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hisobchi/application/app_manager/app_manager_cubit.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/assets/res/app_icons.dart';
import 'package:hisobchi/presentation/components/buttons/text_button.dart';
import 'package:hisobchi/presentation/components/register_dialog.dart';
import 'package:hisobchi/presentation/routes/index_routes.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../application/auth/init/init_auth_bloc.dart';
import '../../../components/defocus.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final formKey = GlobalKey<FormState>();
  var maskFormatter = MaskTextInputFormatter(
    mask: '+998 (##) ###-##-##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );
  String password = '';
  bool showPassword = true;

  @override
  void initState() {
    // checkAndRequestPermission();
    super.initState();
  }

  TextEditingController controller = TextEditingController(text: "+998");

  String pageStatus = '';

  @override
  Widget build(BuildContext context) {
    AppManagerCubit.context = context;
    return DeFocus(
      child: BlocConsumer<InitAuthBloc, InitAuthState>(
        listener: (context, state) {
          if (state is InitSuccess) {
            pageStatus = state.pageStatus;
            if (state.pageStatus == "register") {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return WarningNotRegisterDialog(
                    phone: maskFormatter.getMaskedText(),
                    onPressed: () => context.push(Routes.register.path),
                  );
                },
              );
            }
          }
          if (state is SignInSuccess) {
            context.push(Routes.clientPage.path);
          } else if (state is SignInError) {
            EasyLoading.showError(state.error);
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: SingleChildScrollView(
              reverse: true,
              padding: EdgeInsets.only(top: kToolbarHeight + 35.h),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    SvgPicture.asset(
                      AppIcons.photo,
                      height: 0.13.sh,
                    ),
                    Gap(0.1.sh),
                    Padding(
                      padding: EdgeInsets.all(0.1.sw),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr('sign_in.phone_number'),
                            style: AppTheme.data.textTheme.labelSmall,
                          ),
                          TextFormField(
                            // initialValue: '+998',
                            controller: controller,
                            enabled: state is! LoadingState || state is! SignInLoading,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [maskFormatter],
                            decoration: InputDecoration(
                              hintText: tr('sign_in.phone_number'),
                              suffixIcon: (state is InitSuccess && state.pageStatus == "login") || (state is SignInError && pageStatus == 'login')
                                  ? Icon(
                                Icons.check,
                                color: AppTheme.colors.green,
                                size: 30,
                              )
                                  : state is LoadingState
                                  ? CupertinoActivityIndicator(color: AppTheme.colors.primary)
                                  : const SizedBox(),
                            ),
                            onChanged: (v) {
                              if (maskFormatter.isFill()) {
                                context.read<InitAuthBloc>().add(
                                  VerifyNumber(
                                    phone: maskFormatter.getUnmaskedText(),
                                  ),
                                );
                              }
                            },
                            validator: (v) {
                              if (v?.isEmpty ?? false) {
                                return tr('errors.this_field_cannot_empty');
                              }
                              if (!maskFormatter.isFill()) {
                                return tr('errors.incorrect_text');
                              }
                              return null;
                            },
                          ),
                          Gap(0.015.sh),
                          Text(
                            tr('sign_in.password'),
                            style: AppTheme.data.textTheme.labelSmall,
                          ),
                          TextFormField(
                            initialValue: '',
                            obscureText: showPassword,
                            enabled: (state is! LoadingState || state is! SignInLoading),
                            decoration: InputDecoration(
                              hintText: tr('sign_in.password'),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  showPassword = !showPassword;
                                  setState(() {});
                                },
                                icon: showPassword
                                    ? Icon(
                                  Icons.remove_red_eye_outlined,
                                  color: AppTheme.colors.primary,
                                  size: 30,
                                )
                                    : Icon(
                                  Icons.remove_red_eye,
                                  color: AppTheme.colors.primary,
                                  size: 30,
                                ),
                              ),
                            ),
                            onChanged: (v) => password = v,
                            validator: (v) {
                              if (v?.isEmpty ?? false) {
                                return tr('errors.this_field_cannot_empty');
                              }
                              return null;
                            },
                          ),
                          Gap(0.015.sh),
                          Visibility(
                            visible: (state is InitSuccess && state.pageStatus == "login") || ((state is SignInError && pageStatus == 'login')),
                            child: TextButtonX(
                                onPressed: () {
                                  context.push(Routes.resetPassword.path);
                                },
                                text: "Parolni tiklash"),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 0.1.sw),
                      child: ElevatedButton(
                        onPressed: (state is LoadingState || state is SignInLoading)
                            ? null
                            : () async {
                          if (formKey.currentState!.validate()) {
                            context.read<InitAuthBloc>().add(
                              SignInEvent(
                                phone: maskFormatter.getUnmaskedText(),
                                password: password,
                              ),
                            );
                          }
                        },
                        child: state is LoadingState || state is SignInLoading
                            ? CupertinoActivityIndicator(color: AppTheme.colors.primary)
                            : Text(
                          tr('sign_in.login'),
                          style: AppTheme.data.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}