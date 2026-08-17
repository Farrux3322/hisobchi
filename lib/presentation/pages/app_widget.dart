
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ehisob/application/app_manager/app_manager_cubit.dart';
import 'package:ehisob/application/theme/theme_bloc.dart';
import 'package:ehisob/application/theme/theme_state.dart';
import 'package:ehisob/application/update_checker/update_checker_bloc.dart';
import 'package:ehisob/presentation/assets/asset_index.dart';
import 'package:ehisob/presentation/components/connectivity_listener.dart';
import 'package:ehisob/presentation/components/dialog/update_dialog.dart';
import 'package:ehisob/presentation/routes/coordinator.dart';
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      if (mounted) {
        context.read<UpdateCheckerBloc>().add(const CheckUpdate());
      }
    }
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
          return Container(
            color: AppTheme.colors.background,
            alignment: Alignment.center,
            child: CupertinoActivityIndicator(color: AppTheme.colors.primary),
          );
        } else if (state is AppManagerError) {
          return ErrorView(error: state.error);
        } else {
          return BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, themeState) {
              AppTheme.updateTheme(themeState.themeMode);
              return OKToast(
                child: AnnotatedRegion<SystemUiOverlayStyle>(
                  value: SystemUiOverlayStyle(
                    statusBarColor: AppTheme.colors.background,
                    systemNavigationBarColor: AppTheme.colors.background,
                    statusBarIconBrightness: themeState.themeMode == ThemeMode.dark ? Brightness.light : Brightness.dark,
                    systemNavigationBarIconBrightness: themeState.themeMode == ThemeMode.dark ? Brightness.light : Brightness.dark,
                  ),
                  child: MaterialApp.router(
                    title: 'E-Hisob',
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
                          child: BlocBuilder<UpdateCheckerBloc, UpdateCheckerState>(
                            builder: (context, updateState) {
                              return Stack(
                                children: [
                                  child ?? Material(color: AppTheme.colors.background, child: const SizedBox()),
                                  if (updateState.hasUpdate && !updateState.isDismissed) ...[
                                    // Modal Barrier
                                    Positioned.fill(
                                      child: ListenableBuilder(
                                        listenable: Listenable.merge([]),
                                        builder: (context, _) => GestureDetector(
                                          onTap: null,
                                          child: Container(
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Dialog
                                    Center(
                                      child: UpdateAppDialog(status: updateState.updateStatus),
                                    ),
                                  ],
                                ],
                              );
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

