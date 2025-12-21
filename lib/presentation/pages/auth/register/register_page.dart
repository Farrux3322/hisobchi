import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hisobchi/application/auth/init/init_auth_bloc.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/components/defocus.dart';
import 'package:hisobchi/presentation/routes/index_routes.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final formKey = GlobalKey<FormState>();
  bool showPassword1 = true;
  bool showPassword2 = true;

  String? password1, password2,name = '';

  @override
  Widget build(BuildContext context) {
    return DeFocus(
      child: BlocConsumer<InitAuthBloc, InitAuthState>(
        listener: (context, state) {
          if (state is OtpSuccess) {
            context.pushReplacement(Routes.signInConfirmation.path);
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
                      padding: EdgeInsets.all(0.1.sw).copyWith(bottom: 15.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr('sign_in.name'),
                            style: AppTheme.data.textTheme.labelSmall,
                          ),

                          TextFormField(
                            initialValue: '',
                            enabled: state is! OtpLoading,
                            decoration: InputDecoration(
                              hintText: tr('sign_in.name'),
                            ),
                            onChanged: (v) => name = v,
                            validator: (v) {
                              if (v?.isEmpty ?? false) {
                                return tr('errors.this_field_cannot_empty');
                              }

                              return null;
                            },
                          ),
                          Gap(0.015.sh),
                          Text(
                            tr('sign_in.new_password'),
                            style: AppTheme.data.textTheme.labelSmall,
                          ),


                          TextFormField(
                            initialValue: '',
                            obscureText: showPassword1,
                            enabled: state is! OtpLoading,
                            decoration: InputDecoration(
                              hintText: tr('sign_in.new_password'),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  showPassword1 = !showPassword1;
                                  setState(() {});
                                },
                                icon: showPassword1
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
                            onChanged: (v) => password1 = v,
                            validator: (v) {
                              if (v?.isEmpty ?? false) {
                                return tr('errors.this_field_cannot_empty');
                              }
                              if ((v?.length ?? 0) < 6) {
                                return tr('errors.min_password');
                              }
                              return null;
                            },
                          ),
                          Gap(0.015.sh),
                          Text(
                            tr('sign_in.retry_password'),
                            style: AppTheme.data.textTheme.labelSmall,
                          ),
                          TextFormField(
                            initialValue: '',
                            enabled: state is! OtpLoading,
                            obscureText: showPassword2,
                            decoration: InputDecoration(
                              hintText: tr('sign_in.retry_password'),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  showPassword2 = !showPassword2;
                                  setState(() {});
                                },
                                icon: showPassword2
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
                            onChanged: (v) => password2 = v,
                            validator: (v) {
                              if (v?.isEmpty ?? false) {
                                return tr('errors.this_field_cannot_empty');
                              }
                              if (password1 != password2) {
                                return tr('errors.incorrect_password');
                              }
                              return null;
                            },
                          ),
                          Gap(0.1.sh),
                          ElevatedButton(
                            onPressed: state is OtpLoading
                                ? null
                                : () async {
                                    if (formKey.currentState!.validate()) {
                                      context.read<InitAuthBloc>().add(
                                            SendOtpEvent(password: password2!,name: name??''),
                                          );
                                    }
                                  },
                            child: state is OtpLoading
                                ? CupertinoActivityIndicator(color: AppTheme.colors.primary)
                                : Text(
                                    tr('sign_in.register'),
                                    style: AppTheme.data.textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.colors.white,
                                    ),
                                  ),
                          ),
                        ],
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
