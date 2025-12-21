import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hisobchi/domain/common/data/user_data.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/pages/auth/confirmation/sign_in_confirmation_page.dart';
import 'package:hisobchi/presentation/pages/auth/register/register_page.dart';
import 'package:hisobchi/presentation/pages/auth/reset_password/reset_otp.dart';
import 'package:hisobchi/presentation/pages/auth/reset_password/reset_password.dart';
import 'package:hisobchi/presentation/pages/client/client_list_page.dart';
import 'package:hisobchi/presentation/pages/profile/profile_page.dart';
import 'package:hisobchi/presentation/pages/project/project_list_page.dart';
import 'package:hisobchi/presentation/pages/project/project_add_page.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'entity/pages.dart';
import 'entity/routes.dart';

final parentKey = GlobalKey<NavigatorState>();

String? _redirects() {
  if (UserData.token.isEmpty) {
    return Routes.signIn.path;
  }
  // else if (!UserData.authStatus) {
  //   return Routes.createPasscode.path;
  // }
  return null;
}

final router = GoRouter(
  navigatorKey: parentKey,
  initialLocation: Routes.clientPage.path,
  debugLogDiagnostics: true,
  routes: [
    ///auth
    GoRoute(
      name: Routes.signIn.name,
      path: Routes.signIn.path,
      pageBuilder: (context, state) => MaterialPage<void>(
        key: state.pageKey,
        child: const SignInPage(),
      ),
    ),
    GoRoute(
      name: Routes.register.name,
      path: Routes.register.path,
      pageBuilder: (context, state) => MaterialPage<void>(
        key: state.pageKey,
        child: const RegisterPage(),
      ),
    ),
    GoRoute(
      name: Routes.resetPassword.name,
      path: Routes.resetPassword.path,
      pageBuilder: (context, state) => MaterialPage<void>(
        key: state.pageKey,
        child: const ResetPasswordPage(),
      ),
    ),
    GoRoute(
      name: Routes.signInConfirmation.name,
      path: Routes.signInConfirmation.path,
      pageBuilder: (context, state) => MaterialPage<void>(
        key: state.pageKey,
        child: const SignInConfirmationPage(),
      ),
    ),
    GoRoute(
      name: Routes.resetOTP.name,
      path: Routes.resetOTP.path,
      pageBuilder: (context, state) => MaterialPage<void>(
        key: state.pageKey,
        child: const RestOTPPage(),
      ),
    ),
    GoRoute(
      name: Routes.checkPasscode.name,
      path: Routes.checkPasscode.path,
      pageBuilder: (context, state) => MaterialPage<void>(
        key: state.pageKey,
        child: const CheckPasscodePage(),
      ),
    ),
    GoRoute(
      name: Routes.createPasscode.name,
      path: Routes.createPasscode.path,
      pageBuilder: (context, state) => MaterialPage<void>(
        key: state.pageKey,
        child: const SetPasscodePage(),
      ),
    ),

    GoRoute(
      name: Routes.root.name,
      path: Routes.root.path,
      redirect: (context, state) => _redirects(),
      builder: (context, state) => const SizedBox(),
      routes: [
        StatefulShellRoute.indexedStack(
          parentNavigatorKey: parentKey,
          builder: (context, state, navigatorShell) {
            return PopScope(
              canPop: false,
              child: PersistentTabView.router(
                  tabs: tabs,
                  navBarHeight: 65.h,
                  popActionScreens: PopActionScreensType.all,
                  popAllScreensOnTapAnyTabs: true,
                  popAllScreensOnTapOfSelectedTab: true,
                  onTabChanged: (index) {},
                  navBarBuilder: (navBarConfig) => Style7BottomNavBar(
                        navBarConfig: navBarConfig,
                      ),
                  // navBarBuilder: (navBarConfig) => CustomNavigationBar(navBarConfig: navBarConfig),
                  navigationShell: navigatorShell),
            );
          },
          branches: branches,
        ),
      ],
    ),
  ],
);

///BRANCHES
final branches = [
  ///Client
  StatefulShellBranch(
    // navigatorKey: _shellKey,
    routes: [
      GoRoute(
        name: Routes.clientPage.name,
        path: Routes.clientPage.path,
        // parentNavigatorKey: _shellKey,
        redirect: (context, state) => _redirects(),
        pageBuilder: (context, state) => MaterialPage<void>(key: state.pageKey, child: const ClientPage()),
        routes: []
      ),
    ],
  ),

  // ///Directory
  // StatefulShellBranch(
  //   // navigatorKey: _shellKey,
  //   routes: [
  //     // Document
  //     GoRoute(
  //       name: Routes.directoryPage.name,
  //       path: Routes.directoryPage.name,
  //       // parentNavigatorKey: _shellKey,
  //       redirect: (context, state) => _redirects(),
  //       pageBuilder: (context, state) => MaterialPage<void>(key: state.pageKey, child: const DirectoryPage()),
  //       routes: [
  //         GoRoute(
  //             name: Routes.employeeShowPage.name,
  //             path: Routes.employeeShowPage.path,
  //             redirect: (context, state) => _redirects(),
  //             // parentNavigatorKey: _shellKey,
  //             pageBuilder: (context, state) => MaterialPage<void>(
  //                 key: state.pageKey,
  //                 child: BlocProvider(
  //                   create: (context) => EmployeeBloc(),
  //                   child: EmployeeShow(),
  //                 )),
  //             routes: [
  //               GoRoute(
  //                 name: Routes.employeeAddPage.name,
  //                 path: Routes.employeeAddPage.path,
  //                 redirect: (context, state) => _redirects(),
  //                 // parentNavigatorKey: _shellKey,
  //                 pageBuilder: (context, state) => MaterialPage<void>(
  //                     key: state.pageKey,
  //                     child: BlocProvider(
  //                       create: (context) => EmployeeBloc(),
  //                       child: EmployeeAdd(
  //                         employeeModel: state.extra as EmployeeModel?,
  //                       ),
  //                     )),
  //               ),
  //             ]),
  //         GoRoute(
  //             name: Routes.objectShowPage.name,
  //             path: Routes.objectShowPage.path,
  //             redirect: (context, state) => _redirects(),
  //             // parentNavigatorKey: _shellKey,
  //             pageBuilder: (context, state) => MaterialPage<void>(
  //                 key: state.pageKey,
  //                 child: BlocProvider(
  //                   create: (context) => ObjectBloc(),
  //                   child: ObjectShow(),
  //                 )),
  //             routes: [
  //               GoRoute(
  //                 name: Routes.objectAddPage.name,
  //                 path: Routes.objectAddPage.path,
  //                 redirect: (context, state) => _redirects(),
  //                 // parentNavigatorKey: _shellKey,
  //                 pageBuilder: (context, state) => MaterialPage<void>(
  //                     key: state.pageKey,
  //                     child: BlocProvider(
  //                       create: (context) => ObjectBloc(),
  //                       child: ObjectAdd(objectModel: state.extra as ObjectModel?),
  //                     )),
  //               ),
  //             ]),
  //         GoRoute(
  //             name: Routes.innerObjectShowPage.name,
  //             path: Routes.innerObjectShowPage.path,
  //             redirect: (context, state) => _redirects(),
  //             // parentNavigatorKey: _shellKey,
  //             pageBuilder: (context, state) => MaterialPage<void>(
  //                 key: state.pageKey,
  //                 child: BlocProvider(
  //                   create: (context) => InnerObjectBloc(),
  //                   child: InnerObjectShow(),
  //                 )),
  //             routes: [
  //               GoRoute(
  //                 name: Routes.innerObjectAddPage.name,
  //                 path: Routes.innerObjectAddPage.path,
  //                 redirect: (context, state) => _redirects(),
  //                 // parentNavigatorKey: _shellKey,
  //                 pageBuilder: (context, state) => MaterialPage<void>(
  //                     key: state.pageKey,
  //                     child: BlocProvider(
  //                       create: (context) => InnerObjectBloc(),
  //                       child: InnerObjectAdd(innerObjectModel: state.extra as InnerObjectModel?),
  //                     )),
  //               ),
  //             ]),
  //
  //         GoRoute(
  //             name: Routes.materialProductShowPage.name,
  //             path: Routes.materialProductShowPage.path,
  //             redirect: (context, state) => _redirects(),
  //             // parentNavigatorKey: _shellKey,
  //             pageBuilder: (context, state) => MaterialPage<void>(
  //                 key: state.pageKey,
  //                 child: BlocProvider(
  //                   create: (context) => MaterialProductBloc(),
  //                   child: MaterialShow(),
  //                 )),
  //             routes: [
  //               GoRoute(
  //                 name: Routes.materialProductAddPage.name,
  //                 path: Routes.materialProductAddPage.path,
  //                 redirect: (context, state) => _redirects(),
  //                 // parentNavigatorKey: _shellKey,
  //                 pageBuilder: (context, state) => MaterialPage<void>(
  //                     key: state.pageKey,
  //                     child: BlocProvider(
  //                       create: (context) => MaterialProductBloc(),
  //                       child: MaterialAdd(
  //                         materialModel: state.extra as MaterialModel?,
  //                       ),
  //                     )),
  //               ),
  //             ]),
  //
  //         GoRoute(
  //             name: Routes.partnerShowPage.name,
  //             path: Routes.partnerShowPage.path,
  //             redirect: (context, state) => _redirects(),
  //             // parentNavigatorKey: _shellKey,
  //             pageBuilder: (context, state) => MaterialPage<void>(
  //                 key: state.pageKey,
  //                 child: BlocProvider(
  //                   create: (context) => PartnerBloc(),
  //                   child: PartnerShow(),
  //                 )),
  //             routes: [
  //               GoRoute(
  //                 name: Routes.partnerAddPage.name,
  //                 path: Routes.partnerAddPage.path,
  //                 redirect: (context, state) => _redirects(),
  //                 // parentNavigatorKey: _shellKey,
  //                 pageBuilder: (context, state) => MaterialPage<void>(
  //                     key: state.pageKey,
  //                     child: BlocProvider(
  //                       create: (context) => PartnerBloc(),
  //                       child: PartnerAdd(partnerModel: state.extra as PartnerModel?),
  //                     )),
  //               ),
  //             ]),
  //
  //         GoRoute(
  //             name: Routes.masterForemanShowPage.name,
  //             path: Routes.masterForemanShowPage.path,
  //             redirect: (context, state) => _redirects(),
  //             // parentNavigatorKey: _shellKey,
  //             pageBuilder: (context, state) => MaterialPage<void>(
  //                 key: state.pageKey,
  //                 child: BlocProvider(
  //                   create: (context) => MasterForemanBloc(),
  //                   child: MasterForemanShow(),
  //                 )),
  //             routes: [
  //               GoRoute(
  //                 name: Routes.masterForemanAddPage.name,
  //                 path: Routes.masterForemanAddPage.path,
  //                 redirect: (context, state) => _redirects(),
  //                 // parentNavigatorKey: _shellKey,
  //                 pageBuilder: (context, state) => MaterialPage<void>(
  //                     key: state.pageKey,
  //                     child: BlocProvider(
  //                       create: (context) => MasterForemanBloc(),
  //                       child: MasterForemanAdd(
  //                         masterForemanModel: state.extra as MasterForemanModel?,
  //                       ),
  //                     )),
  //               ),
  //             ]),
  //
  //         GoRoute(
  //             name: Routes.roomShowPage.name,
  //             path: Routes.roomShowPage.path,
  //             redirect: (context, state) => _redirects(),
  //             // parentNavigatorKey: _shellKey,
  //             pageBuilder: (context, state) => MaterialPage<void>(
  //                 key: state.pageKey,
  //                 child: BlocProvider(
  //                   create: (context) => RoomBloc(),
  //                   child: RoomShow(),
  //                 )),
  //             routes: [
  //               GoRoute(
  //                 name: Routes.roomAddPage.name,
  //                 path: Routes.roomAddPage.path,
  //                 redirect: (context, state) => _redirects(),
  //                 // parentNavigatorKey: _shellKey,
  //                 pageBuilder: (context, state) => MaterialPage<void>(
  //                     key: state.pageKey,
  //                     child: BlocProvider(
  //                       create: (context) => RoomBloc(),
  //                       child: RoomAdd(
  //                         roomModel: state.extra as RoomModel?,
  //                       ),
  //                     )),
  //               ),
  //             ]),
  //
  //         GoRoute(
  //             name: Routes.typeOfConstructionShowPage.name,
  //             path: Routes.typeOfConstructionShowPage.path,
  //             redirect: (context, state) => _redirects(),
  //             // parentNavigatorKey: _shellKey,
  //             pageBuilder: (context, state) => MaterialPage<void>(
  //                 key: state.pageKey,
  //                 child: BlocProvider(
  //                   create: (context) => TypeOfConstructionBloc(),
  //                   child: TypeOfConstructionShow(),
  //                 )),
  //             routes: [
  //               GoRoute(
  //                 name: Routes.typeOfConstructionAddPage.name,
  //                 path: Routes.typeOfConstructionAddPage.path,
  //                 redirect: (context, state) => _redirects(),
  //                 // parentNavigatorKey: _shellKey,
  //                 pageBuilder: (context, state) => MaterialPage<void>(
  //                     key: state.pageKey,
  //                     child: BlocProvider(
  //                       create: (context) => TypeOfConstructionBloc(),
  //                       child: TypeOfConstructionAdd(
  //                         typeOfConstruction: state.extra as TypeOfConstructionModel?,
  //                       ),
  //                     )),
  //               ),
  //             ]),
  //         //-------------------
  //         GoRoute(
  //           name: Routes.categoryShowPage.name,
  //           path: Routes.categoryShowPage.path,
  //           redirect: (context, state) => _redirects(),
  //           // parentNavigatorKey: _shellKey,
  //           pageBuilder: (context, state) => MaterialPage<void>(
  //               key: state.pageKey,
  //               child: BlocProvider(
  //                 create: (context) => CategoryBloc(),
  //                 child: CategoryShow(),
  //               )),
  //           routes: [
  //             GoRoute(
  //               name: Routes.categoryAddPage.name,
  //               path: Routes.categoryAddPage.path,
  //               redirect: (context, state) => _redirects(),
  //               // parentNavigatorKey: _shellKey,
  //               pageBuilder: (context, state) => MaterialPage<void>(
  //                   key: state.pageKey,
  //                   child: BlocProvider(
  //                     create: (context) => CategoryBloc(),
  //                     child: CategoryAdd(
  //                       nomenclatirelLessueModel: state.extra as NomenclatirelLessueModel?,
  //                     ),
  //                   )),
  //             ),
  //           ],
  //         ), //-------------------
  //         GoRoute(
  //           name: Routes.expenseTypeShowPage.name,
  //           path: Routes.expenseTypeShowPage.path,
  //           redirect: (context, state) => _redirects(),
  //           pageBuilder: (context, state) => MaterialPage<void>(key: state.pageKey, child: ExpenseTypeShow()),
  //           routes: [
  //             GoRoute(
  //               name: Routes.expenseTypeAddPage.name,
  //               path: Routes.expenseTypeAddPage.path,
  //               redirect: (context, state) => _redirects(),
  //               pageBuilder: (context, state) => MaterialPage<void>(key: state.pageKey, child: ExpenseTypeAdd(expenseType: state.extra as ExpenseTypeModel?)),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   ],
  // ),

  ///Project
  StatefulShellBranch(
    // navigatorKey: _shellKey,
    routes: [
      // Document
      GoRoute(
        name: Routes.projectPage.name,
        path: Routes.projectPage.name,
        // parentNavigatorKey: _shellKey,
        redirect: (context, state) => _redirects(),
        pageBuilder: (context, state) => MaterialPage<void>(key: state.pageKey, child: const ProjectListPage()),
        routes: [
          GoRoute(
            name: Routes.projectAddPage.name,
            path: Routes.projectAddPage.path,
            redirect: (context, state) => _redirects(),
            pageBuilder: (context, state) => MaterialPage<void>(
              key: state.pageKey,
              child: const ProjectAddPage(),
            ),
          ),
        ]
      ),
    ],
  ),


  ///Profile
  StatefulShellBranch(
    // navigatorKey: _shellKey,
    routes: [
      GoRoute(
        name: Routes.profilePage.name,
        path: Routes.profilePage.name,
        // parentNavigatorKey: _shellKey,
        redirect: (context, state) => _redirects(),
        pageBuilder: (context, state) => MaterialPage<void>(key: state.pageKey, child: const ProfilePage()),
       routes: []
      ),
    ],
  ),
];

///TABS
final tabs = [
  PersistentRouterTabConfig(
    item: ItemConfig(
        activeForegroundColor: AppTheme.colors.primary,
        icon: SvgPicture.asset(
          AppIcons.clients,
          height: 20.sp,
          colorFilter: ColorFilter.mode(AppTheme.colors.primary, BlendMode.srcIn),
        ),
        inactiveIcon: SvgPicture.asset(
          AppIcons.clients,
          height: 20.sp,
          colorFilter: ColorFilter.mode(AppTheme.colors.gray, BlendMode.srcIn),
        ),
        title: "Mijozlar",
        textStyle: AppTheme.data.textTheme.labelSmall!),
  ),

 PersistentRouterTabConfig(
    item: ItemConfig(
        activeForegroundColor: AppTheme.colors.primary,
        icon: SvgPicture.asset(
          AppIcons.project,
          height: 20.sp,
          colorFilter: ColorFilter.mode(AppTheme.colors.primary, BlendMode.srcIn),
        ),
        inactiveIcon: SvgPicture.asset(
          AppIcons.project,
          height: 20.sp,
          colorFilter: ColorFilter.mode(AppTheme.colors.gray, BlendMode.srcIn),
        ),
        title: "Proyektlar",
        textStyle: AppTheme.data.textTheme.labelSmall!),
  ),
  PersistentRouterTabConfig(
    item: ItemConfig(
        activeForegroundColor: AppTheme.colors.primary,
        icon: SvgPicture.asset(
          AppIcons.profile,
          height: 20.sp,
          colorFilter: ColorFilter.mode(AppTheme.colors.primary, BlendMode.srcIn),
        ),
        inactiveIcon: SvgPicture.asset(
          AppIcons.profile,
          height: 20.sp,
          colorFilter: ColorFilter.mode(AppTheme.colors.gray, BlendMode.srcIn),
        ),
        title: 'Profile',
        textStyle: AppTheme.data.textTheme.labelSmall!),
  ),
];
