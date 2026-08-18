import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ehisob/presentation/pages/auth/passcode/set_passcode_page.dart';
import 'package:ehisob/presentation/pages/auth/passcode/verify_old_passcode_page.dart';
import 'package:ehisob/presentation/pages/notification/notification_page.dart';
import 'package:ehisob/presentation/routes/coordinator.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:ehisob/application/subscription/subscription_bloc.dart';
import 'package:ehisob/domain/common/data/user_data.dart';
import 'package:ehisob/infrastructure/services/shared_service.dart';
import 'package:ehisob/presentation/assets/asset_index.dart';
import 'package:ehisob/presentation/pages/profile/screens/profile_update_page.dart';
import 'package:ehisob/presentation/routes/entity/routes.dart';
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        title: Text(
          'Mening profilim',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E293B),
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                    width: 40.r,
                    height: 40.r,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: IconButton(
                      icon: Icon(
                        CupertinoIcons.bell,
                        color: const Color(0xFF1E293B),
                        size: 20.sp,
                      ),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        pushScreen(context, screen: const NotificationPage()).then((_) {
                          if (context.mounted) {
                            context.read<NotificationBloc>().add(const GetUnreadCount());
                          }
                        });
                      },
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  if (state.unreadCount > 0)
                    Positioned(
                      right: 8.w,
                      top: 6.h,
                      child: Container(
                        padding: EdgeInsets.all(4.r),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                        constraints: BoxConstraints(minWidth: 18.r, minHeight: 18.r),
                        child: Text(
                          state.unreadCount > 99 ? '99+' : '${state.unreadCount}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.colors.primary,
        onRefresh: () async {
          context.read<SubscriptionBloc>().add(GetSubscriptionInfoEvent());
          context.read<NotificationBloc>().add(const GetUnreadCount());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, MediaQuery.of(context).padding.bottom + 96.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero User Profile Card
              _buildUserCard(),

              SizedBox(height: 16.h),

              // Usage & Plan Section if active
              if (UserData.xZiffler) ...[
                const UsageSection(),
                SizedBox(height: 18.h),
              ],

              // Group 1: Foydalanuvchilar & Xodimlar
              _buildSectionHeader('Boshqaruv va Xodimlar'),
              _buildGroupedCard([
                _buildGroupedTile(
                  iconData: CupertinoIcons.person_3_fill,
                  iconColor: const Color(0xFF3B82F6),
                  title: 'Xodimlar',
                  subtitle: 'Tizim xodimlari va ruxsatlar',
                  onTap: () {
                    if (UserData.isWorkerMode) {
                      Toast.showWarningToast(message: 'Sizda bunday huquq yo\'q');
                      return;
                    }
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffListPage()));
                  },
                ),
              ]),

              SizedBox(height: 18.h),

              // Group 2: Yordam va Qo'llanma
              _buildSectionHeader('Yordam va Aloqa'),
              _buildGroupedCard([
                _buildGroupedTile(
                  iconData: CupertinoIcons.book_fill,
                  iconColor: const Color(0xFF10B981),
                  title: 'Foydalanish qo\'llanmasi',
                  subtitle: 'Video va matnli qo\'llanmalar',
                  onTap: () => context.pushNamed(Routes.usageGuide.name),
                ),
                _buildGroupDivider(),
                _buildGroupedTile(
                  iconData: CupertinoIcons.headphones,
                  iconColor: const Color(0xFF8B5CF6),
                  title: 'Biz bilan aloqa',
                  subtitle: 'Telegram, Instagram va qo\'llab-quvvatlash',
                  onTap: _showContactBottomSheet,
                ),
              ]),

              // // Group 3: Tashqi Ko'rinish & Tizim
              // _buildSectionHeader('Ilova sozlamalari'),
              // _buildGroupedCard([
              //   _buildGroupedTile(
              //     iconData: CupertinoIcons.globe,
              //     iconColor: const Color(0xFF0EA5E9),
              //     title: 'Tizim tili',
              //     subtitle: 'O\'zbek tili (Lotin)',
              //     badge: 'Asosiy',
              //     isEnabled: false,
              //     onTap: () {},
              //   ),
              // ]),
              // SizedBox(height: 18.h),

              // Group 4: Xavfsizlik
              _buildSectionHeader('Xavfsizlik va Maxfiylik'),
              _buildGroupedCard([
                _buildPinCodeSwitchTile(),
                _buildGroupDivider(),
                _buildBiometricSwitchTile(),
                _buildGroupDivider(),
                _buildGroupedTile(
                  iconData: CupertinoIcons.lock_shield_fill,
                  iconColor: const Color(0xFFF59E0B),
                  title: 'PIN-kodni yangilash',
                  subtitle: 'Mavjud xavfsizlik kodini o\'zgartirish',
                  onTap: _handlePasscodeChange,
                ),
              ]),

              SizedBox(height: 18.h),

              // Group 5: Chiqish
              _buildGroupedCard([
                _buildGroupedTile(
                  iconData: CupertinoIcons.arrow_right_square_fill,
                  iconColor: const Color(0xFFEF4444),
                  title: 'Hisobdan chiqish',
                  titleColor: const Color(0xFFEF4444),
                  showChevron: false,
                  onTap: _showLogoutDialog,
                ),
              ]),

              SizedBox(height: 20.h),

              // App Version Footer
              FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  final version = snapshot.data?.version ?? '1.0.0';
                  return Center(
                    child: Column(
                      children: [
                        Text(
                          'EHisob • Versiya $version',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF94A3B8),
                            letterSpacing: 0.2,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Barcha hisob-kitoblar xavfsiz himoyalangan',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFFCBD5E1),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Section Header
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 6.w, bottom: 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12.5.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF64748B),
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  // Apple Grouped Container
  Widget _buildGroupedCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.r),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildGroupDivider() {
    return Padding(
      padding: EdgeInsets.only(left: 54.w),
      child: const Divider(height: 1, color: Color(0xFFF1F5F9)),
    );
  }

  // Grouped Menu Tile
  Widget _buildGroupedTile({
    required IconData iconData,
    required Color iconColor,
    required String title,
    String? subtitle,
    String? badge,
    Color? titleColor,
    bool showChevron = true,
    bool isEnabled = true,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled
            ? () {
                HapticFeedback.selectionClick();
                onTap();
              }
            : null,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          child: Row(
            children: [
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(iconData, color: iconColor, size: 18.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: titleColor ?? const Color(0xFF1E293B),
                          ),
                        ),
                        if (badge != null) ...[
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                            decoration: BoxDecoration(
                              color: AppTheme.colors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              badge,
                              style: TextStyle(
                                fontSize: 9.5.sp,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.colors.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: const Color(0xFF94A3B8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (showChevron)
                Icon(
                  CupertinoIcons.chevron_forward,
                  color: const Color(0xFFCBD5E1),
                  size: 16.sp,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Hero User Card
  Widget _buildUserCard() {
    final userName = UserData.name.isEmpty ? 'Mening profilim' : UserData.name;
    final userPhone = _formatPhoneNumber(UserData.phone);
    final userImage = UserData.image;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.colors.primary.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildAvatar(userName, userImage),
          SizedBox(width: 14.w),
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
                    fontSize: 16.5.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(CupertinoIcons.phone, color: const Color(0xFF64748B), size: 12.sp),
                    SizedBox(width: 4.w),
                    Text(
                      userPhone,
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (UserData.isWorkerMode) ...[
                  SizedBox(height: 6.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: AppTheme.colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.briefcase_fill, color: AppTheme.colors.primary, size: 11.sp),
                        SizedBox(width: 4.w),
                        Flexible(
                          child: Text(
                            UserData.positionName.isNotEmpty ? UserData.positionName : 'Xodim',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.colors.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Material(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12.r),
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                pushScreen(context, screen: const ProfileUpdatePage()).then((_) {
                  setState(() {});
                });
              },
              borderRadius: BorderRadius.circular(12.r),
              child: Padding(
                padding: EdgeInsets.all(9.r),
                child: Icon(
                  CupertinoIcons.pencil,
                  size: 18.sp,
                  color: AppTheme.colors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String name, String? imageUrl) {
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      width: 52.r,
      height: 52.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppTheme.colors.primary, AppTheme.colors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.colors.primary.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26.r),
        child: imageUrl != null && imageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[200]!,
                  highlightColor: Colors.grey[50]!,
                  child: Container(color: Colors.white),
                ),
                errorWidget: (context, url, error) => _buildInitials(initials),
              )
            : _buildInitials(initials),
      ),
    );
  }

  Widget _buildInitials(String initials) {
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.sp,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  // Pin Code Switch Tile
  Widget _buildPinCodeSwitchTile() {
    return FutureBuilder<Map<String, dynamic>>(
      future: SharedPrefService.initialize().then(
        (pref) => {'isEnabled': pref.isPasscodeEnabled, 'hasPasscode': pref.passcode.isNotEmpty},
      ),
      builder: (context, snapshot) {
        final data = snapshot.data ?? {'isEnabled': false, 'hasPasscode': false};
        final isEnabled = data['isEnabled'] as bool;
        final hasPasscode = data['hasPasscode'] as bool;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          child: Row(
            children: [
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(CupertinoIcons.number_square_fill, color: const Color(0xFF6366F1), size: 18.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PIN-kod himoyasi',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      isEnabled ? 'Faollashtirilgan' : 'O\'chirilgan',
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        color: isEnabled ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoSwitch(
                value: isEnabled,
                activeTrackColor: AppTheme.colors.primary,
                onChanged: (value) async {
                  HapticFeedback.selectionClick();
                  final pref = await SharedPrefService.initialize();

                  if (value) {
                    if (!hasPasscode) {
                      if (context.mounted) {
                        final result = await Navigator.of(context, rootNavigator: true).push<bool>(
                          MaterialPageRoute(builder: (_) => const SetPasscodePage()),
                        );
                        if (result == true && context.mounted) {
                          setState(() {});
                        }
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
              ),
            ],
          ),
        );
      },
    );
  }

  // Biometric Switch Tile
  Widget _buildBiometricSwitchTile() {
    return FutureBuilder<Map<String, dynamic>>(
      future: () async {
        final pref = await SharedPrefService.initialize();
        final localAuth = LocalAuthentication();
        final canCheck = await localAuth.canCheckBiometrics;
        final available = await localAuth.getAvailableBiometrics();
        final isPinEnabled = pref.isPasscodeEnabled;

        return {
          'canCheck': canCheck && available.isNotEmpty,
          'isEnabled': pref.isBiometricEnabled,
          'isPinEnabled': isPinEnabled,
        };
      }(),
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null || !(data['canCheck'] as bool) || !(data['isPinEnabled'] as bool)) {
          return const SizedBox.shrink();
        }

        final isEnabled = data['isEnabled'] as bool;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          child: Row(
            children: [
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(CupertinoIcons.viewfinder_circle_fill, color: const Color(0xFF10B981), size: 18.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Biometrik kirish (Face ID)',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      isEnabled ? 'Ulangan' : 'Ulanmagan',
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        color: isEnabled ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoSwitch(
                value: isEnabled,
                activeTrackColor: AppTheme.colors.primary,
                onChanged: (value) async {
                  HapticFeedback.selectionClick();
                  final pref = await SharedPrefService.initialize();
                  pref.setBiometricEnabled(value);
                  setState(() {});
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Passcode change handler
  Future<void> _handlePasscodeChange() async {
    final pref = await SharedPrefService.initialize();

    if (pref.passcode.isEmpty) {
      if (mounted) {
        Toast.showWarningToast(message: 'Avval PIN-kod yarating');
      }
      return;
    }

    if (!mounted) return;

    final isVerified = await Navigator.of(context, rootNavigator: true).push<bool>(
      MaterialPageRoute(builder: (_) => const VerifyOldPasscodePage()),
    );

    if (isVerified == true && mounted) {
      final result = await Navigator.of(context, rootNavigator: true).push<bool>(
        MaterialPageRoute(builder: (_) => const SetPasscodePage()),
      );

      if (result == true && mounted) {
        setState(() {});
        Toast.showSuccessToast(message: 'PIN-kod muvaffaqiyatli o\'zgartirildi');
      }
    }
  }

  // Contact Bottom Sheet
  void _showContactBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 34.h),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Biz bilan aloqa',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Savol yoki takliflaringiz bo\'lsa, bizga murojaat qiling',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 20.h),
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
              SizedBox(height: 10.h),
              _buildContactOption(
                iconData: FontAwesomeIcons.bullhorn,
                iconColor: const Color(0xFF0088cc),
                title: 'Telegram rasmiy kanal',
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
              SizedBox(height: 10.h),
              _buildContactOption(
                iconData: FontAwesomeIcons.instagram,
                iconColor: const Color(0xFFE1306C),
                title: 'Instagram sahifamiz',
                subtitle: '@ehisob_uz',
                onTap: () async {
                  Navigator.pop(context);
                  final Uri instagramApp = Uri.parse("instagram://user?username=ehisob_uz");
                  final Uri instagramWeb = Uri.parse("https://www.instagram.com/ehisob_uz");
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
    required FaIconData iconData,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: FaIcon(iconData, color: iconColor, size: 20.sp),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(CupertinoIcons.chevron_forward, color: const Color(0xFFCBD5E1), size: 16.sp),
            ],
          ),
        ),
      ),
    );
  }

  // Logout Dialog
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        contentPadding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 20.h),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.arrow_right_square_fill,
                color: const Color(0xFFEF4444),
                size: 28.sp,
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              'Hisobdan chiqish',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E293B),
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Haqiqatan ham hisobingizdan chiqmoqchimisiz? Barcha ma\'lumotlaringiz xavfsiz saqlanadi.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5.sp,
                color: const Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    ),
                    child: Text(
                      'Bekor qilish',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
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
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    ),
                    child: Text(
                      'Chiqish',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
