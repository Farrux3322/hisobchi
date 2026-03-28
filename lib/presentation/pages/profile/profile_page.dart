import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:hisobchi/presentation/pages/auth/passcode/set_passcode_page.dart';
import 'package:hisobchi/presentation/pages/auth/passcode/verify_old_passcode_page.dart';
import 'package:hisobchi/presentation/pages/notification/notification_page.dart';
import 'package:hisobchi/presentation/routes/coordinator.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:hisobchi/application/subscription/subscription_bloc.dart';
import 'package:hisobchi/domain/common/data/user_data.dart';
import 'package:hisobchi/infrastructure/services/shared_service.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/pages/profile/screens/profile_update_page.dart';
import 'package:hisobchi/presentation/routes/entity/routes.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../application/notification/notification_bloc.dart';
import '../../components/toast/toast.dart';
import 'widgets/usage_section.dart';
import '../staff/staff_list_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<SubscriptionBloc>().add(GetSubscriptionInfoEvent());
    context.read<NotificationBloc>().add(const GetUnreadCount());
  }

  String _formatPhoneNumber(String phone) {
    if (phone.isEmpty) return '+998 (__) ___-__-__';
    final digits = phone.replaceAll(RegExp(r'\D'), '');

    if (digits.length == 12 && digits.startsWith('998')) {
      return '+998 (${digits.substring(3, 5)}) ${digits.substring(5, 8)}-${digits.substring(8, 10)}-${digits.substring(10, 12)}';
    }

    if (digits.length == 9) {
      return '+998 (${digits.substring(0, 2)}) ${digits.substring(2, 5)}-${digits.substring(5, 7)}-${digits.substring(7, 9)}';
    }

    return phone;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   centerTitle: false,
      //   title: Text('Profil'),
      //   actions: [
      //     BlocBuilder<NotificationBloc, NotificationState>(
      //       builder: (context, state) {
      //         return Stack(
      //           clipBehavior: Clip.none,
      //           children: [
      //             Container(
      //               margin: const EdgeInsets.all(8),
      //               width: 40,
      //               height: 40,
      //               decoration: BoxDecoration(
      //                 color: AppTheme.colors.white,
      //                 borderRadius: BorderRadius.circular(12),
      //                 border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.2)),
      //               ),
      //               child: IconButton(
      //                 icon: Icon(Icons.notifications, color: AppTheme.colors.primary, size: 20),
      //                 onPressed: () {
      //                   pushScreen(context, screen: const NotificationPage()).then((_) {
      //                     if (context.mounted) {
      //                       context.read<NotificationBloc>().add(const GetUnreadCount());
      //                     }
      //                   });
      //                 },
      //                 padding: EdgeInsets.zero,
      //               ),
      //             ),
      //             if (state.unreadCount > 0)
      //               Positioned(
      //                 right: 4,
      //                 top: 4,
      //                 child: Container(
      //                   padding: const EdgeInsets.all(4),
      //                   decoration: BoxDecoration(color: AppTheme.colors.primary, shape: BoxShape.circle),
      //                   constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      //                   child: Text(
      //                     state.unreadCount > 99 ? '99+' : '${state.unreadCount}',
      //                     style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      //                     textAlign: TextAlign.center,
      //                   ),
      //                 ),
      //               ),
      //           ],
      //         );
      //       },
      //     ),
      //     const Gap(10),
      //   ],
      // ),
      body: Stack(
        children: [
          _buildBackgroundGradients(),
          RefreshIndicator(
            onRefresh: () async {
              context.read<SubscriptionBloc>().add(GetSubscriptionInfoEvent());
              context.read<NotificationBloc>().add(const GetUnreadCount());
            },
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: 80.0.h,
                  floating: false,
                  pinned: false,
                  snap: false,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  stretch: true,
                  centerTitle: false,
                  flexibleSpace: FlexibleSpaceBar(
                    stretchModes: const [StretchMode.blurBackground, StretchMode.zoomBackground],
                    titlePadding: const EdgeInsetsDirectional.only(start: 16, bottom: 16),
                    title: Text(
                      'Profil',
                      style: TextStyle(
                        color: AppTheme.colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  actions: [
                    _buildNotificationIcon(),
                    const SizedBox(width: 16),
                  ],
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // const Gap(10),
                      _buildUserCard(),
                      const Gap(12),

                      if (UserData.xZiffler) ...[
                        UsageSection(),
                        const Gap(12),
                      ],

                      _buildSectionTitle('Asosiy sozlamalar'),
                      const Gap(12),
                      _buildSettingsCard(),

                      const Gap(24),
                      _buildSectionTitle('Ilovadan chiqish'),
                      const Gap(12),
                      _buildLogoutButton(),

                      _buildVersionInfo(),
                      Gap(MediaQuery.of(context).padding.bottom + 20),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionInfo() {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) => Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: Center(child: Text('Versiya: ${snapshot.data?.version ?? "..."}', style: TextStyle(fontSize: 13, color: Colors.grey.withOpacity(0.5))))),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.red.withOpacity(0.1))),
      child: ListTile(
        onTap: _showLogoutDialog,
        leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.logout_rounded, color: Colors.red, size: 20)),
        title: const Text('Ilovadan chiqish', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
      ),
    );
  }


  Widget _buildUserCard() {
    final userName = UserData.name.isEmpty ? 'Ism kiritilmagan' : UserData.name;
    final userPhone = _formatPhoneNumber(UserData.phone);
    final userImage = UserData.image;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Hero(
            tag: 'profile_avatar',
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.colors.primary.withValues(alpha: 0.2), width: 2),
              ),
              child: _buildAvatar(userName, userImage),
            ),
          ),
          const Gap(16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.colors.black,
                      letterSpacing: -0.5
                  ),
                ),
                const Gap(4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(AppIcons.phone),
                    // Icon(Icons.phone_android_rounded, color: AppTheme.colors.gray.withValues(alpha: 0.6), size: 14),
                    const Gap(4),
                    Text(
                      userPhone,
                      style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.colors.gray.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500
                      ),
                    ),
                  ],
                ),

                if (UserData.isWorkerMode) ...[
                  const Gap(8),
                  _buildWorkerBadge(),
                ],
              ],
            ),
          ),
          _buildEditButton(),
        ],
      ),
    );
  }

  Widget _buildWorkerBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.colors.primary.withValues(alpha: 0.15),
            AppTheme.colors.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.colors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_user_rounded, color: AppTheme.colors.primary, size: 12),
          const Gap(6),
          Flexible(
            child: Text(
              (UserData.positionName.isNotEmpty ? UserData.positionName : 'Xodim').toUpperCase(),
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.colors.primary,
                  letterSpacing: 0.5
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          pushScreen(context, screen: const ProfileUpdatePage()).then((_) {
            setState(() {});
          });
        },
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.colors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(15),
          ),
          child: SvgPicture.asset(
              AppIcons.edit,
              width: 18,
              height: 18,
              colorFilter: ColorFilter.mode(AppTheme.colors.primary, BlendMode.srcIn)
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String name, String? imageUrl, {VoidCallback? onTap}) {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, state) {
        final subscription = state.subscriptionInfo?.subscription;
        final bool isPremium = subscription?.status == 'ACTIVE';

        final String planInternalName = subscription?.plan?.name ?? 'STANDARD';
        final String planDisplayName = subscription?.plan?.displayName ?? 'STANDART';

        final style = PlanStyle.fromName(planInternalName);

        final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';


        return GestureDetector(
          onTap: onTap,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              if (isPremium)
                Container(
                  width: 78.w,
                  height: 78.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: style.outerGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),

              Container(
                width: 70.w,
                height: 70.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.white,
                    width: isPremium ? 2.5.w : 1.5.w,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(35.r),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: style.outerGradient,
                        begin: Alignment.topCenter,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => _buildInitialsWidget(initials),
                    )
                        : _buildInitialsWidget(initials),
                  ),
                ),
              ),

              if (isPremium)
                Positioned(
                  bottom: -4.h,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: style.badgeColor,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: style.outerGradient.first, width: 0.5.w),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4.r,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(style.icon, color: style.contentColor, size: 10.sp),
                        SizedBox(width: 4.w),
                        Text(
                          planDisplayName.toUpperCase(),
                          style: TextStyle(
                            color: style.contentColor,
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
  Widget _buildInitialsWidget(String initials) {
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          fontSize: 32.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1,
          shadows: [
            Shadow(
              color: Colors.black54,
              blurRadius: 2,
              offset: Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
  // Widget _buildInitials(String initials) {
  //   return Center(
  //     child: Text(
  //       initials,
  //       style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
  //     ),
  //   );
  // }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.colors.gray, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: AppIcons.clients,
            title: 'Xodimlar',
            onTap: () {
              if (UserData.isWorkerMode) {
                Toast.showWarningToast(message: 'Sizda bunday huquq yo\'q');
                return;
              }
              Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffListPage()));
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            iconData: Icons.menu_book_rounded,
            title: 'Foydalanish bo\'yicha qo\'llanma',
            onTap: () => context.pushNamed(Routes.usageGuide.name),
          ),
          _buildDivider(),
          _buildMenuItem(
            iconData: Icons.headset_mic_rounded,
            iconColor: const Color(0xFF3813FF),
            title: 'Biz bilan aloqa',
            // subtitle: '@ehisob_admin',
            onTap: _showContactBottomSheet,
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: AppIcons.language,
            title: 'Tillar',
            subtitle: 'Uzbek tili',
            isEnabled: false,
            onTap: () {},
          ),
          _buildDivider(),
          _buildPinCodeSwitch(),
          _buildBiometricSwitch(),
          _buildDivider(),
          _buildMenuItem(
            icon: AppIcons.lock,
            title: 'PIN-kodni o\'zgartirish',
            onTap: _handlePinChangeLogic,
          ),
        ],
      ),
    );
  }

  Future<void> _handlePinChangeLogic() async {
    final pref = await SharedPrefService.initialize();

    if (pref.passcode.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white),
                SizedBox(width: 8),
                Text('Avval PIN-kod yarating'),
              ],
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
      return;
    }

    if (mounted) {
      final isVerified = await Navigator.of(context, rootNavigator: true).push<bool>(
        MaterialPageRoute(builder: (_) => const VerifyOldPasscodePage()),
      );

      if (isVerified == true && mounted) {
        final result = await Navigator.of(context, rootNavigator: true).push<bool>(
          MaterialPageRoute(builder: (_) => const SetPasscodePage()),
        );

        if (result == true && mounted) {
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('PIN-kod muvaffaqiyatli o\'zgartirildi'),
                ],
              ),
              backgroundColor: AppTheme.colors.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    }
  }

  Widget _buildDivider() {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.0),
            Colors.white,
            Colors.white.withValues(alpha: 0.0),
          ],
          stops: [0.0, 0.5, 1.0],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: Divider(
        color: Colors.grey.withValues(alpha: 0.5),
        thickness: 1,
        height: 1,
      ),
    );
  }

  Widget _buildMenuItem({
    String? icon,
    IconData? iconData,
    Color? iconColor,
    required String title,
    String? subtitle,
    bool isEnabled = true,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Opacity(
                  opacity: isEnabled ? 1.0 : 0.4,
                  child: Row(
                    children: [
                      _buildIconContainer(icon: icon, iconData: iconData, color: iconColor),
                      const Gap(16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isEnabled ? AppTheme.colors.black : Colors.grey.shade700,
                              ),
                            ),
                            if (subtitle != null)
                              Text(
                                subtitle,
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (!isEnabled)
                _buildComingSoonBadge()
              else
                Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildIconContainer({String? icon, IconData? iconData, Color? color}) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: (color ?? AppTheme.colors.primary).withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: iconData != null
          ? Icon(iconData, color: color ?? AppTheme.colors.primary, size: 22)
          : Padding(
        padding: const EdgeInsets.all(10),
        child: SvgPicture.asset(icon!, color: color ?? AppTheme.colors.primary),
      ),
    );
  }


  Widget _buildComingSoonBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.colors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'Yaqinda',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.colors.primary),
      ),
    );
  }



  Widget _buildPinCodeSwitch() {
    return FutureBuilder<Map<String, dynamic>>(
      future: SharedPrefService.initialize().then((pref) => {
        'isEnabled': pref.isPasscodeEnabled,
        'hasPasscode': pref.passcode.isNotEmpty
      }),
      builder: (context, snapshot) {
        final data = snapshot.data ?? {'isEnabled': false, 'hasPasscode': false};
        return _buildSwitchTile(
          icon: AppIcons.lock,
          title: 'PIN-kod o\'rnatish',
          value: data['isEnabled'],
          onChanged: (val) async {
            final pref = await SharedPrefService.initialize();
            if (val) {
              if (!(data['hasPasscode'])) {
                if (mounted) {
                  final res = await Navigator.of(context, rootNavigator: true).push<bool>(MaterialPageRoute(builder: (_) => const SetPasscodePage()));
                  if (res == true) setState(() {});
                }
              } else {
                pref.setPasscodeEnabled(true);
                setState(() {});
              }
            } else {
              pref.setPasscodeEnabled(false);
              setState(() {});
            }
          },
        );
      },
    );
  }
  Widget _buildSwitchTile({
    String? icon,
    IconData? iconData,


    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: AppTheme.colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Center(
              child: icon != null
                  ? SvgPicture.asset(
                icon,
                width: 20.w,
                height: 20.w,
                colorFilter: ColorFilter.mode(AppTheme.colors.primary, BlendMode.srcIn),
              )
                  : Icon(
                  iconData ?? Icons.fingerprint_rounded,
                  color: AppTheme.colors.primary,
                  size: 22.sp
              ),
            ),
          ),
          Gap(16.w),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.colors.black
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: AppTheme.colors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricSwitch() {
    return FutureBuilder<Map<String, dynamic>>(
      future: () async {
        final pref = await SharedPrefService.initialize();
        final localAuth = LocalAuthentication();

        final bool canCheck = await localAuth.canCheckBiometrics;
        final bool isSupported = await localAuth.isDeviceSupported();
        final List<BiometricType> available = await localAuth.getAvailableBiometrics();

        bool hasFace = available.contains(BiometricType.face) ||
            available.contains(BiometricType.strong);
        bool hasFingerprint = available.contains(BiometricType.fingerprint);

        return {
          'canCheck': (canCheck || isSupported) && available.isNotEmpty,
          'hasFace': hasFace,
          'hasFingerprint': hasFingerprint,
          'isEnabled': pref.isBiometricEnabled,
          'isPinEnabled': pref.isPasscodeEnabled
        };
      }(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!;
        final bool isPinEnabled = data['isPinEnabled'] ?? false;
        final bool canCheck = data['canCheck'] ?? false;

        if (!canCheck || !isPinEnabled) {
          return const SizedBox.shrink();
        }

        String? svgIcon;
        IconData? materialIcon;
        String label;

        if (data['hasFace'] == true) {
          svgIcon = AppIcons.faceid;
          label = 'Face ID';
        } else if (data['hasFingerprint'] == true) {
          materialIcon = Icons.fingerprint_rounded;
          label = 'Barmoq izi (Touch ID)';
        } else {
          materialIcon = Icons.security_rounded;
          label = 'Biometrik kirish';
        }

        return Column(
          children: [
            _buildDivider(),
            _buildSwitchTile(
              icon: svgIcon,
              iconData: materialIcon,
              title: label,
              value: data['isEnabled'] ?? false,
              onChanged: (val) async {
                final pref = await SharedPrefService.initialize();

                pref.setBiometricEnabled(val);

                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }

  void _showContactBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.colors.gray.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Biz bilan aloqa',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.colors.black),
              ),
              const SizedBox(height: 24),
              _buildContactOption(
                iconData: FontAwesomeIcons.telegram,
                iconColor: const Color(0xFF0088cc),
                title: 'Telegram admin',
                subtitle: '@ehisob_admin',
                onTap: () async {
                  Navigator.pop(context);
                  final Uri telegramApp = Uri.parse("tg://resolve?domain=ehisob_admin");
                  final Uri telegramWeb = Uri.parse("https://t.me/ehisob_admin");
                  if (await canLaunchUrl(telegramApp)) {
                    await launchUrl(telegramApp, mode: LaunchMode.externalApplication);
                  } else {
                    await launchUrl(telegramWeb, mode: LaunchMode.externalApplication);
                  }
                },
              ),
              const SizedBox(height: 12),
              _buildContactOption(
                iconData: FontAwesomeIcons.bullhorn,
                iconColor: const Color(0xFF0088cc),
                title: 'Telegram kanal',
                subtitle: '@E_Hisob',
                onTap: () async {
                  Navigator.pop(context);
                  final Uri telegramApp = Uri.parse("tg://resolve?domain=E_Hisob");
                  final Uri telegramWeb = Uri.parse("https://t.me/E_Hisob");
                  if (await canLaunchUrl(telegramApp)) {
                    await launchUrl(telegramApp, mode: LaunchMode.externalApplication);
                  } else {
                    await launchUrl(telegramWeb, mode: LaunchMode.externalApplication);
                  }
                },
              ),
              const SizedBox(height: 12),
              _buildContactOption(
                iconData: FontAwesomeIcons.instagram,
                iconColor: const Color(0xFFE1306C),
                title: 'Instagram',
                subtitle: '@ehisob_uz',
                onTap: () async {
                  Navigator.pop(context);
                  final Uri instagramApp = Uri.parse("instagram://user?username=ehisob_uz");
                  final Uri instagramWeb = Uri.parse("https://www.instagram.com/ehisob_uz?igsh=MTRwOHR3cmdydDRveQ==");
                  if (await canLaunchUrl(instagramApp)) {
                    await launchUrl(instagramApp, mode: LaunchMode.externalApplication);
                  } else {
                    await launchUrl(instagramWeb, mode: LaunchMode.externalApplication);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactOption({
    required IconData iconData,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isEnabled = true,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Opacity(
          opacity: isEnabled ? 1.0 : 0.5,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.colors.divider),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.colors.black),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 13, color: AppTheme.colors.gray, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: AppTheme.colors.gray, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        contentPadding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFFEF4444).withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 32),
            ),
            const SizedBox(height: 24),
            Text(
              'Ilovadan chiqish',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.colors.black, letterSpacing: -0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'Haqiqatan ham ilovadan chiqmoqchimisiz? Barcha hisob-kitoblaringiz saqlanib qolinadi.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: AppTheme.colors.gray, height: 1.5),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: AppTheme.colors.divider),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      'Qaytish',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.colors.gray),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final pref = await SharedPrefService.initialize();
                      UserData.reset();
                      pref.setName('');
                      pref.setToken('');
                      pref.setPhone('');
                      setPasscodeVerified(false);
                      if (context.mounted) {
                        GoRouter.of(context).go(Routes.signIn.path);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Chiqish', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundGradients() {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: CircleAvatar(radius: 200, backgroundColor: const Color(0xFFC7B8F5).withOpacity(0.3)),
          ),
          Positioned(
            bottom: -50,
            right: -100,
            child: CircleAvatar(radius: 250, backgroundColor: const Color(0xFFB3E5FC).withOpacity(0.3)),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  )
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.notifications_none_rounded, color: AppTheme.colors.black, size: 24),
                onPressed: () => pushScreen(context, screen: const NotificationPage()),
              ),
            ),
            if (state.unreadCount > 0)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  child: Text(
                    '${state.unreadCount}',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class PlanStyle {
  final List<Color> outerGradient;
  final Color badgeColor;
  final Color contentColor;
  final IconData icon;

  PlanStyle({
    required this.outerGradient,
    required this.badgeColor,
    required this.contentColor,
    required this.icon,
  });

  factory PlanStyle.fromName(String? name) {
    final normalizedName = name?.trim().toUpperCase() ?? '';

    switch (normalizedName) {
      case 'BUSINESS':
        return PlanStyle(
          outerGradient: [const Color(0xFFBF953F), const Color(0xFFFCF6BA), const Color(0xFFB38728)],
          badgeColor: const Color(0xFF1A1A1A),
          contentColor: const Color(0xFFFCF6BA),
          icon: Icons.auto_awesome,
        );
      case 'PROFESSIONAL':
        return PlanStyle(
          outerGradient: [const Color(0xFF6A11CB), const Color(0xFF2575FC)],
          badgeColor: const Color(0xFF001529),
          contentColor: Colors.white,
          icon: Icons.verified_user_rounded,
        );
      default:
        return PlanStyle(
          outerGradient: [const Color(0xFFBDC3C7), const Color(0xFF2C3E50)],
          badgeColor: const Color(0xFF34495E),
          contentColor: Colors.white,
          icon: Icons.star_border_rounded,
        );
    }
  }
}
