import 'dart:async';
import 'dart:io';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hisobchi/application/auth/init/init_auth_bloc.dart';
import 'package:hisobchi/application/contract/contract_bloc.dart';
import 'package:hisobchi/application/currency/currency_bloc.dart';
import 'package:hisobchi/application/dashboard/dashboard_bloc.dart';
import 'package:hisobchi/application/file_upload/file_upload_bloc.dart';
import 'package:hisobchi/application/notification/notification_bloc.dart';
import 'package:hisobchi/application/partner/partner_bloc.dart';
import 'package:hisobchi/application/project/project_bloc.dart';
import 'package:hisobchi/application/project_cost/project_cost_bloc.dart';
import 'package:hisobchi/application/project_income/project_income_bloc.dart';
import 'package:hisobchi/application/subscription/subscription_bloc.dart';
import 'package:hisobchi/application/subscription/subscription_status_cubit.dart';
import 'package:hisobchi/application/theme/theme_bloc.dart';
import 'package:hisobchi/application/theme/theme_event.dart';
import 'package:hisobchi/application/update_checker/update_checker_bloc.dart';
import 'package:hisobchi/application/work_type/work_type_bloc.dart';
import 'package:hisobchi/application/worker/worker_bloc.dart';
import 'package:hisobchi/firebase_options.dart';
import 'package:hisobchi/infrastructure/repository/project_cost/project_cost_repository.dart';
import 'package:hisobchi/infrastructure/repository/project_income/project_income_repository.dart';
import 'package:hisobchi/infrastructure/repository/theme/theme_repository.dart';
import 'package:hisobchi/infrastructure/repository/worker/worker_repository.dart';
import 'package:hisobchi/presentation/components/notification.dart';
import 'application/app_manager/app_manager_cubit.dart';
import 'application/cost_type/cost_type_bloc.dart';
import 'domain/common/app_init.dart';
import 'infrastructure/repository/cost_type/cost_type_repository.dart';
import 'infrastructure/repository/file_upload/file_upload_repository.dart';
import 'presentation/assets/theme/app_theme.dart';
import 'presentation/pages/app_widget.dart';


@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> getDeviceToken() async {
  try {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Ba'zida servis tayyor bo'lishi uchun ozgina kutish kerak bo'lishi mumkin
      String? token = await messaging.getToken().timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('Firebase token olish vaqti tugadi'),
          );
      debugPrint('Device Token: $token');
    } else {
      debugPrint('Push notificationga ruxsat berilmadi');
    }
  } catch (e) {
    debugPrint('Firebase Token olishda xatolik: $e');
    if (e.toString().contains('SERVICE_NOT_AVAILABLE')) {
      debugPrint('TEKSHIRING: Google Play Services ishlayaptimi? Yoqi Firebase Installations API yoqilganmi?');
    }
  }
}
Future<void> main() async {
  await runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    getDeviceToken();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          icon: 'resource://drawable/applogo',
          // bu yerda small icon resursi,
          channelKey: 'basic_channel',
          channelName: 'Basic Notifications',
          channelDescription: 'Bildirishnomalar',
          defaultColor: Colors.white,
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
        ),
      ],
    );
    AwesomeNotifications().setGlobalBadgeCounter(0);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFFF5F6F8),
      systemNavigationBarColor: Color(0xFFF5F6F8),
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await initializeApp();

    runApp(
      EasyLocalization(
        supportedLocales: const [
          Locale('en'),
          Locale('uz'),
          Locale('ru'),
        ],
        useFallbackTranslations: true,
        useOnlyLangCode: true,
        fallbackLocale: const Locale('ru'),
        startLocale: const Locale('uz'),
        path: 'assets/translations',
        child: const MyApp(),
      ),
    );
  }, (error, stack) {
    debugPrint('stack=${stack.toString()}, error = ${error.toString()}');
  });
}

final navKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    EasyLoading.instance.backgroundColor = const Color.fromRGBO(56, 131, 146, 1);
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    // Foreground holatda pushni tinglash
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (Platform.isIOS) {
        if (message.notification == null) {
          showAwesomeNotification(message);
        }
      } else {
        showAwesomeNotification(message);
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppManagerCubit>(create: (context) => AppManagerCubit()..init()),
        BlocProvider(create: (context) => ThemeBloc(repository: ThemeRepository())..add(const LoadThemeEvent())),
        BlocProvider(create: (context) => CurrencyBloc()..add(const GetCurrency())),
        BlocProvider(create: (context) => InitAuthBloc()),
        BlocProvider(create: (context) => PartnerBloc()),
        BlocProvider(create: (context) => ProjectBloc()),
        BlocProvider(create: (context) => CostTypeBloc(repository: CostTypeRepository())),
        BlocProvider(create: (context) => DashboardBloc()),
        BlocProvider(create: (context) => WorkTypeBloc()),
        BlocProvider(create: (context) => ProjectCostBloc(repository: ProjectCostRepository())),
        BlocProvider(create: (context) => ProjectIncomeBloc(repository: ProjectIncomeRepository())),
        BlocProvider(create: (context) => WorkerBloc(repository: WorkerRepository())),
        BlocProvider(create: (context) => ContractBloc()),
        BlocProvider(create: (context) => FileUploadBloc(repository: FileUploadRepository())),
        BlocProvider(create: (context) => SubscriptionBloc()),
        BlocProvider(create: (context) => NotificationBloc()),
        BlocProvider(create: (context) => SubscriptionStatusCubit()),
        BlocProvider(create: (context) => UpdateCheckerBloc()..add(const CheckUpdate())),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          // ScreenUtil initialized bo'lgandan keyin AppTheme ni initialize qilamiz
          AppTheme.init();
          return const AppWidget();
        },
      ),
    );
  }
}
