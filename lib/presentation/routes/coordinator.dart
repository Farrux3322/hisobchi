import 'dart:ui';
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
import 'package:hisobchi/presentation/pages/dashboard/dashboard_page.dart';
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
                navBarBuilder: (navBarConfig) => GlassBottomNavBar(navBarConfig: navBarConfig),
                navigationShell: navigatorShell,
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
    // navigatorKey: _shellKey,
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
    // navigatorKey: _shellKey,
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
            pageBuilder: (context, state) => MaterialPage<void>(key: state.pageKey, child: const ProjectAddPage()),
          ),
        ],
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
        routes: [],
      ),
    ],
  ),
];

///TABS
final tabs = [
  PersistentRouterTabConfig(
    item: ItemConfig(
      activeForegroundColor: AppTheme.colors.primary,
      icon: SvgPicture.asset(AppIcons.home, height: 20.sp, colorFilter: ColorFilter.mode(AppTheme.colors.primary, BlendMode.srcIn)),
      inactiveIcon: SvgPicture.asset(AppIcons.home, height: 20.sp, colorFilter: ColorFilter.mode(AppTheme.colors.gray, BlendMode.srcIn)),
      title: "Home",
      textStyle: AppTheme.data.textTheme.labelSmall!,
    ),
  ),

  PersistentRouterTabConfig(
    item: ItemConfig(
      activeForegroundColor: AppTheme.colors.primary,
      icon: SvgPicture.asset(AppIcons.clients, height: 20.sp, colorFilter: ColorFilter.mode(AppTheme.colors.primary, BlendMode.srcIn)),
      inactiveIcon: SvgPicture.asset(AppIcons.clients, height: 20.sp, colorFilter: ColorFilter.mode(AppTheme.colors.gray, BlendMode.srcIn)),
      title: "Mijozlar",
      textStyle: AppTheme.data.textTheme.labelSmall!,
    ),
  ),

  PersistentRouterTabConfig(
    item: ItemConfig(
      activeForegroundColor: AppTheme.colors.primary,
      icon: SvgPicture.asset(AppIcons.project, height: 20.sp, colorFilter: ColorFilter.mode(AppTheme.colors.primary, BlendMode.srcIn)),
      inactiveIcon: SvgPicture.asset(AppIcons.project, height: 20.sp, colorFilter: ColorFilter.mode(AppTheme.colors.gray, BlendMode.srcIn)),
      title: "Proyektlar",
      textStyle: AppTheme.data.textTheme.labelSmall!,
    ),
  ),
  PersistentRouterTabConfig(
    item: ItemConfig(
      activeForegroundColor: AppTheme.colors.primary,
      icon: SvgPicture.asset(AppIcons.profile, height: 20.sp, colorFilter: ColorFilter.mode(AppTheme.colors.primary, BlendMode.srcIn)),
      inactiveIcon: SvgPicture.asset(AppIcons.profile, height: 20.sp, colorFilter: ColorFilter.mode(AppTheme.colors.gray, BlendMode.srcIn)),
      title: 'Profile',
      textStyle: AppTheme.data.textTheme.labelSmall!,
    ),
  ),
];

///CUSTOM GLASS BOTTOM NAVIGATION BAR - iOS 26 GLASS MORPHISM
class GlassBottomNavBar extends StatelessWidget {
  final NavBarConfig navBarConfig;

  const GlassBottomNavBar({super.key, required this.navBarConfig});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 15.h),
      height: 80.h,
      child: Stack(
        children: [
          // Background blur effect with colorful glass
          ClipRRect(
            borderRadius: BorderRadius.circular(32.r),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [const Color(0xFFF5F7FF).withValues(alpha: 0.8), const Color(0xFFFFFFFF).withValues(alpha: 0.7), const Color(0xFFFFF5F7).withValues(alpha: 0.75)],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(32.r),
                  border: Border.all(color: AppTheme.colors.primary.withValues(alpha: .05)),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.12), blurRadius: 35, offset: const Offset(0, 12), spreadRadius: -6),
                    BoxShadow(color: const Color(0xFFEC4899).withValues(alpha: 0.08), blurRadius: 25, offset: const Offset(0, 8), spreadRadius: -4),
                    BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 18, offset: const Offset(0, 4), spreadRadius: -2),
                  ],
                ),
              ),
            ),
          ),
          // Inner content
          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(32.r)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _GlassNavItem(icon: AppIcons.profile, label: 'Home', isSelected: navBarConfig.selectedIndex == 0, onTap: () => navBarConfig.onItemSelected(0)),
                _GlassNavItem(icon: AppIcons.clients, label: 'Mijozlar', isSelected: navBarConfig.selectedIndex == 1, onTap: () => navBarConfig.onItemSelected(1)),
                _GlassNavItem(icon: AppIcons.project, label: 'Proyektlar', isSelected: navBarConfig.selectedIndex == 2, onTap: () => navBarConfig.onItemSelected(2)),
                _GlassNavItem(icon: AppIcons.profile, label: 'Profile', isSelected: navBarConfig.selectedIndex == 3, onTap: () => navBarConfig.onItemSelected(3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassNavItem extends StatefulWidget {
  final String icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GlassNavItem({required this.icon, required this.label, required this.isSelected, required this.onTap});

  @override
  State<_GlassNavItem> createState() => _GlassNavItemState();
}

class _GlassNavItemState extends State<_GlassNavItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    if (widget.isSelected) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_GlassNavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Beautiful active item background
              if (widget.isSelected)
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: Container(
                      width: 80.w,
                      height: 60.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [AppTheme.colors.primary.withValues(alpha: .9), AppTheme.colors.primary.withValues(alpha: .8)],
                        ),
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF667EEA).withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8), spreadRadius: -2),
                          BoxShadow(color: const Color(0xFF764BA2).withValues(alpha: 0.3), blurRadius: 14, offset: const Offset(0, 4), spreadRadius: -1),
                        ],
                      ),
                    ),
                  ),
                ),
              // Icon and Label
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: widget.isSelected ? 1.0 : 0.0),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOutCubic,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, -3 * value),
                        child: Transform.scale(
                          scale: 1.0 + (0.12 * value),
                          child: SvgPicture.asset(
                            widget.icon,
                            height: 20.sp,
                            width: 20.sp,
                            colorFilter: ColorFilter.mode(Color.lerp(const Color(0xFF64748B).withValues(alpha: 0.7), Colors.white, value)!, BlendMode.srcIn),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 4.h),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: widget.isSelected ? 1.0 : 0.0),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOutCubic,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: 0.85 + (0.15 * value),
                        child: Text(
                          widget.label,
                          style: AppTheme.data.textTheme.labelSmall!.copyWith(
                            color: Color.lerp(const Color(0xFF64748B).withValues(alpha: 0.85), Colors.white, value),
                            fontWeight: FontWeight.lerp(FontWeight.w600, FontWeight.w800, value),
                            fontSize: 9.5.sp + (0.5 * value),
                            letterSpacing: 0.2,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
