import 'coordinate.dart';

/// A set of routes for the entire app.
class Routes implements Coordinate {
  const Routes._({required this.name, required this.path});

  final String name;
  final String path;

  ///auth
  ///
  static const signIn = Routes._(name: 'sign_in_page', path: '/sign_in');
  static const resetPassword = Routes._(
    name: 'reset_password_page',
    path: '/reset_password',
  );
  static const resetOTP = Routes._(
    name: 'reset_otp_page',
    path: '/reset_otp',
  );
  static const signInConfirmation = Routes._(name: 'sign_in_confirmation_page', path: '/sign_in_confirmation');
  static const register = Routes._(name: 'register_page', path: '/register');
  static const verify = Routes._(name: 'verify_page', path: '/verify');
  static const createPasscode = Routes._(name: 'set_passcode_page', path: '/set_passcode');
  static const checkPasscode = Routes._(name: 'check_passcode_page', path: '/check_passcode');
  static const onboarding = Routes._(name: 'onboarding_page', path: '/onboarding');
  static const privacyPolicy = Routes._(name: 'privacy_policy', path: '/privacy_policy');
  static const workspaceSelection = Routes._(name: 'workspace_selection', path: '/workspace_selection');

  ///Root
  static const root = Routes._(name: 'root', path: '/');
  static const homePage = Routes._(name: 'home_page', path: '/home_page');

  static const profilePage = Routes._(name: 'profile_page', path: '/profile_page');
  static const subscription = Routes._(name: 'subscription', path: '/subscription');
  static const subscriptionDetail = Routes._(name: 'subscription_detail', path: '/subscription_detail');
  static const paymentSuccess = Routes._(name: 'payment_success', path: '/payment-success');
  static const clientPage = Routes._(name: 'client_page', path: '/client_page');
  static const projectPage = Routes._(name: 'project_page', path: '/project_page');
  static const projectAddPage = Routes._(name: 'project_add_page', path: '/project_add_page');
  static const projectCostListPage = Routes._(name: 'project_cost_list_page', path: '/project_cost_list_page');
  static const smsBuyPage = Routes._(name: 'sms_buy_page', path: '/sms_buy_page');
  static const identification = Routes._(name: 'identification_page', path: '/identification');
  static const usageGuide = Routes._(name: 'usage_guide_page', path: '/usage_guide');
  static const videoPlayer = Routes._(name: 'video_player_page', path: '/video_player');
  static const paymentSchedule = Routes._(name: 'payment_schedule_page', path: '/payment_schedule');

  @override
  String toString() => 'name=$name, path=$path';
}
