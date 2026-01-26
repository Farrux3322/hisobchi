
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/app_manager/app_manager_cubit.dart';
import 'package:hisobchi/application/theme/theme_bloc.dart';
import 'package:hisobchi/application/theme/theme_state.dart';
import 'package:hisobchi/application/update_checker/update_checker_bloc.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/components/dialog/update_dialog.dart';
import 'package:hisobchi/presentation/routes/coordinator.dart';
import 'package:oktoast/oktoast.dart';

import '../components/basic_widgets.dart';

class AppWidget extends StatefulWidget {
  const AppWidget({super.key});

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppManagerCubit, AppManagerState>(
      builder: (context, state) {
        if (state is AppManagerLoading) {
          return const CupertinoActivityIndicator();
        } else if (state is AppManagerError) {
          return ErrorView(error: state.error);
        } else {
          return BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, themeState) {
              // Theme o'zgarganda AppTheme ni yangilash
              AppTheme.updateTheme(themeState.themeMode);

              return OKToast(
                child: AnnotatedRegion<SystemUiOverlayStyle>(
                  value: SystemUiOverlayStyle(
                    statusBarColor:  Color(0xFFF5F6F8),
                    systemNavigationBarColor: Color(0xFFF5F6F8),
                  ),
                  child: MaterialApp.router(
                    title: 'Hisobchi',
                    theme: AppTheme.data,
                    darkTheme: AppTheme.darkData,
                    themeMode: themeState.themeMode,
                    debugShowCheckedModeBanner: false,
                    locale: context.locale,
                    localizationsDelegates: context.localizationDelegates,
                    supportedLocales: context.supportedLocales,
                    routeInformationParser: router.routeInformationParser,
                    routeInformationProvider: router.routeInformationProvider,
                    routerDelegate: router.routerDelegate,
                    builder: EasyLoading.init(
                      builder: (context, child) {
                        return MediaQuery(
                          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1)),
                          child: BlocConsumer<UpdateCheckerBloc, UpdateCheckerState>(
                            listener: (context, updateState) {
                              if (updateState.hasUpdate == true) {
                                if (context.mounted) {
                                  showDialog(
                                      barrierDismissible: updateState.updateStatus != 'hard',
                                      context: AppManagerCubit.context ?? context,
                                      builder: (BuildContext context) => UpdateAppDialog(status: updateState.updateStatus));
                                }
                              }
                            },
                            builder: (context, updateState) {
                              return child ?? const Material(color: Colors.white, child: SizedBox());
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}

