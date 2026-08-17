import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:ehisob/domain/common/data/user_data.dart';
import 'package:ehisob/infrastructure/services/shared_service.dart';
import 'package:ehisob/presentation/pages/auth/confirmation/sign_in_confirmation_page.dart';
import 'package:ehisob/presentation/pages/auth/register/register_page.dart';
import 'package:ehisob/presentation/pages/auth/reset_password/reset_otp.dart';
import 'package:ehisob/presentation/pages/auth/reset_password/reset_password.dart';
import 'package:ehisob/presentation/pages/client/client_list_page.dart';
import 'package:ehisob/presentation/pages/dashboard/dashboard_page.dart';
import 'package:ehisob/presentation/pages/onboarding/onboarding_page.dart';
import 'package:ehisob/presentation/pages/profile/profile_page.dart';
import 'package:ehisob/presentation/pages/project/project_list_page.dart';
import 'package:ehisob/presentation/pages/project/project_add_page.dart';
import 'package:ehisob/presentation/pages/subscription/subscription_page.dart';
import 'package:ehisob/presentation/pages/subscription/subscription_detail_page.dart';
import 'package:ehisob/presentation/pages/subscription/payment_success_page.dart';
import 'package:ehisob/presentation/pages/profile/screens/sms_buy_page/sms_buy_page.dart';
import 'package:ehisob/presentation/pages/profile/screens/usage_guide_page.dart';
import 'package:ehisob/presentation/pages/profile/screens/youtube_full_screen_player_page.dart';
import 'package:ehisob/infrastructure/models/user_me_model.dart';
import 'package:ehisob/presentation/pages/auth/workspace_selection_page.dart';
import 'package:ehisob/features/payment_schedule/presentation/pages/payment_schedule_page.dart';

import 'entity/pages.dart';
import 'entity/routes.dart';
import 'widgets/liquid_glass_shell.dart';
import 'widgets/liquid_bottom_bar.dart';

final parentKey = GlobalKey<NavigatorState>();
final shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final shellNavigatorClientsKey = GlobalKey<NavigatorState>(debugLabel: 'clients');
final shellNavigatorProjectsKey = GlobalKey<NavigatorState>(debugLabel: 'projects');
final shellNavigatorProfileKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

// Global variable to track passcode verification status in current session
bool _isPasscodeVerifiedInSession = false;

Future<String?> _redirects() async {
  // Check onboarding first
  final pref = await SharedPrefService.initialize();
  if (!pref.hasCompletedOnboarding) {
    return Routes.onboarding.path;
  }

  if (UserData.token.isEmpty) {
    return Routes.signIn.path;
  }

  // PIN kod tekshiruvi
  if (pref.isPasscodeEnabled && pref.passcode.isNotEmpty && !_isPasscodeVerifiedInSession) {
    return Routes.checkPasscode.path;
  }

  return null;
}

void setPasscodeVerified(bool value) {
  _isPasscodeVerifiedInSession = value;
}

final router = GoRouter(
  navigatorKey: parentKey,
  initialLocation: Routes.homePage.path,
  debugLogDiagnostics: true,
  routes: [
    ///auth
    GoRoute(
      name: Routes.signIn.name,
      path: Routes.signIn.path,
      pageBuilder: (context, state) => MaterialPage<void>(key: state.pageKey, child: const SignInPage()),
    ),
    GoRoute(
      name: Routes.register.name,
      path: Routes.register.path,
      pageBuilder: (context, state) => MaterialPage<void>(key: state.pageKey, child: const RegisterPage()),
    ),
    GoRoute(
      name: Routes.resetPassword.name,
      path: Routes.resetPassword.path,
      pageBuilder: (context, state) => MaterialPage<void>(key: state.pageKey, child: const ResetPasswordPage()),
    ),
    GoRoute(
      name: Routes.signInConfirmation.name,
      path: Routes.signInConfirmation.path,
      pageBuilder: (context, state) => MaterialPage<void>(key: state.pageKey, child: const SignInConfirmationPage()),
    ),
    GoRoute(
      name: Routes.resetOTP.name,
      path: Routes.resetOTP.path,
      pageBuilder: (context, state) => MaterialPage<void>(key: state.pageKey, child: const RestOTPPage()),
    ),
    GoRoute(
      name: Routes.checkPasscode.name,
      path: Routes.checkPasscode.path,
      pageBuilder: (context, state) => MaterialPage<void>(key: state.pageKey, child: const CheckPasscodePage()),
    ),
    GoRoute(
      name: Routes.createPasscode.name,
      path: Routes.createPasscode.path,
      pageBuilder: (context, state) => MaterialPage<void>(key: state.pageKey, child: const SetPasscodePage()),
    ),
    GoRoute(
      name: Routes.onboarding.name,
      path: Routes.onboarding.path,
      pageBuilder: (context, state) => MaterialPage<void>(key: state.pageKey, child: const OnboardingPage()),
    ),
    GoRoute(
      name: Routes.paymentSuccess.name,
      path: Routes.paymentSuccess.path,
      pageBuilder: (context, state) => MaterialPage<void>(
        key: state.pageKey,
        child: PaymentSuccessPage(isTarif: state.extra as bool? ?? false),
      ),
    ),
    GoRoute(
      name: Routes.workspaceSelection.name,
      path: Routes.workspaceSelection.path,
      pageBuilder: (context, state) => MaterialPage<void>(
        key: state.pageKey,
        child: WorkspaceSelectionPage(meData: state.extra as UserMeModel),
      ),
    ),
    GoRoute(
      name: Routes.subscription.name,
      path: Routes.subscription.path,
      pageBuilder: (context, state) => MaterialPage<void>(key: state.pageKey, child: const TariflarScreen()),
    ),
    GoRoute(
      name: Routes.smsBuyPage.name,
      path: Routes.smsBuyPage.path,
      pageBuilder: (context, state) => MaterialPage<void>(key: state.pageKey, child: const SMSBuyPage()),
    ),
    GoRoute(
      name: Routes.usageGuide.name,
      path: Routes.usageGuide.path,
      pageBuilder: (context, state) => MaterialPage<void>(key: state.pageKey, child: const UsageGuidePage()),
    ),
    // GoRoute(
    //   name: Routes.identification.name,
    //   path: Routes.identification.path,
    //   pageBuilder: (context, state) => MaterialPage<void>(key: state.pageKey, child: const IdentificationPage()),
    // ),
    GoRoute(
      name: Routes.subscriptionDetail.name,
      path: Routes.subscriptionDetail.path,
      pageBuilder: (context, state) {
        final extras = state.extra as Map<String, dynamic>?;
        return MaterialPage<void>(
          key: state.pageKey,
          child: SubscriptionDetailPage(planId: extras?['planId'] ?? 0, planName: extras?['planName'] ?? ''),
        );
      },
    ),

    GoRoute(
      name: Routes.videoPlayer.name,
      path: Routes.videoPlayer.path,
      pageBuilder: (context, state) {
        final extras = state.extra as Map<String, dynamic>?;
        final videoId = extras?['videoId'] as String? ?? '';
        final startAt = extras?['startAt'] as Duration? ?? Duration.zero;
        return MaterialPage<void>(
          key: state.pageKey,
          child: YouTubeFullScreenPlayerPage(videoId: videoId, startAt: startAt),
        );
      },
    ),
    GoRoute(
      name: Routes.paymentSchedule.name,
      path: Routes.paymentSchedule.path,
      pageBuilder: (context, state) => MaterialPage<void>(
        key: state.pageKey,
        child: const PaymentSchedulePage(),
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
            return SafeArea(
              top: false,
              right: false,
              left: false,
              child: PopScope(
                canPop: false,
                onPopInvokedWithResult: (context, result) {
                  SystemNavigator.pop(animated: true);
                },
                child: LiquidGlassShell(
                  navigationShell: navigatorShell,
                  navigatorKeys: [
                    shellNavigatorHomeKey,
                    shellNavigatorClientsKey,
                    shellNavigatorProjectsKey,
                    shellNavigatorProfileKey,
                  ],
                  items: [
                    LiquidTabItem(icon: Icons.home_rounded, label: 'Asosiy'),
                    LiquidTabItem(icon: Icons.people_alt_rounded, label: 'Mijozlar'),
                    LiquidTabItem(icon: Icons.work_rounded, label: 'Loyihalar'),
                    LiquidTabItem(icon: Icons.person_rounded, label: 'Profile'),
                  ],
                ),
              ),
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
  ///Home
  StatefulShellBranch(
    navigatorKey: shellNavigatorHomeKey,
    routes: [
      GoRoute(
        name: Routes.homePage.name,
        path: Routes.homePage.path,
        // parentNavigatorKey: _shellKey,
        redirect: (context, state) => _redirects(),
        pageBuilder: (context, state) => MaterialPage<void>(key: state.pageKey, child: const DashboardPage()),
        routes: [],
      ),
    ],
  ),

  ///Client
  StatefulShellBranch(
    navigatorKey: shellNavigatorClientsKey,
    routes: [
      GoRoute(
        name: Routes.clientPage.name,
        path: Routes.clientPage.path,
        // parentNavigatorKey: _shellKey,
        redirect: (context, state) => _redirects(),
        pageBuilder: (context, state) => MaterialPage<void>(key: state.pageKey, child: const ClientPage()),
        routes: [],
      ),
    ],
  ),

  ///Project
  StatefulShellBranch(
    navigatorKey: shellNavigatorProjectsKey,
    routes: [
      // Document
      GoRoute(
        name: Routes.projectPage.name,
        path: Routes.projectPage.path,
        // parentNavigatorKey: _shellKey,
        redirect: (context, state) => _redirects(),
        pageBuilder: (context, state) => MaterialPage<void>(key: state.pageKey, child: const ProjectListPage()),
        routes: [
          GoRoute(
            name: Routes.projectAddPage.name,
            path: Routes.projectAddPage.path,
            redirect: (context, state) => _redirects(),
            pageBuilder: (context, state) => MaterialPage<void>(key: state.pageKey, child: const ProjectAddPage()),
          ),
        ],
      ),
    ],
  ),

  ///Profile
  StatefulShellBranch(
    navigatorKey: shellNavigatorProfileKey,
    routes: [
      GoRoute(
        name: Routes.profilePage.name,
        path: Routes.profilePage.path,
        // parentNavigatorKey: _shellKey,
        redirect: (context, state) => _redirects(),
        pageBuilder: (context, state) => MaterialPage<void>(key: state.pageKey, child: const ProfilePage()),
        routes: [],
      ),
    ],
  ),
];
