import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

import 'widgets/usage_section.dart';

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
  }

  String _formatPhoneNumber(String phone) {
    if (phone.isEmpty) return '+998 (__) ___-__-__';
    // Remove all non-numeric characters
    final digits = phone.replaceAll(RegExp(r'\D'), '');

    // Handle standard 12-digit Uzbek numbers (998901234567)
    if (digits.length == 12 && digits.startsWith('998')) {
      return '+998 (${digits.substring(3, 5)}) ${digits.substring(5, 8)}-${digits.substring(8, 10)}-${digits.substring(10, 12)}';
    }

    // Handle 9-digit numbers (901234567)
    if (digits.length == 9) {
      return '+998 (${digits.substring(0, 2)}) ${digits.substring(2, 5)}-${digits.substring(5, 7)}-${digits.substring(7, 9)}';
    }

    return phone; // Return as is if format is unknown
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Profil',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.colors.black),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.2)),
            ),
            child: IconButton(
              icon: Icon(Icons.notifications, color: AppTheme.colors.primary, size: 20),
              onPressed: () {
                pushScreen(context, screen: const NotificationPage());
              },
              padding: EdgeInsets.zero,
            ),
          ),
          const Gap(10),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<SubscriptionBloc>().add(GetSubscriptionInfoEvent());
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserCard(),
              const SizedBox(height: 16),
              const UsageSection(),
              const SizedBox(height: 24),
              _buildSectionTitle('Savollaringiz bormi?'),
              const SizedBox(height: 12),
              _buildMenuItem(icon: AppIcons.telegram, title: 'Telegram bot', onTap: () {}),
              const SizedBox(height: 8),
              _buildMenuItem(
                icon: AppIcons.telegram,
                title: 'Telegram guruh',
                onTap: () async {
                  final Uri telegramApp = Uri.parse("tg://resolve?domain=eHisob_uz");
                  final Uri telegramWeb = Uri.parse("https://t.me/eHisob_uz");

                  if (await canLaunchUrl(telegramApp)) {
                    await launchUrl(telegramApp, mode: LaunchMode.externalApplication);
                  } else {
                    await launchUrl(telegramWeb, mode: LaunchMode.externalApplication);
                  }
                },
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Tashqi ko\'rinishi'),
              const SizedBox(height: 12),
              _buildMenuItem(icon: AppIcons.language, title: 'Tillar', subtitle: 'Uzbek tili', onTap: () {}),
              const SizedBox(height: 24),
              _buildSectionTitle('Xavfsizlik'),
              const SizedBox(height: 12),
              _buildPinCodeSwitch(),
              const SizedBox(height: 8),
              _buildBiometricSwitch(),
              const SizedBox(height: 8),
              _buildMenuItem(
                icon: AppIcons.lock,
                title: 'PIN-kodni o\'zgartirish',
                onTap: () async {
                  final pref = await SharedPrefService.initialize();

                  if (pref.passcode.isEmpty) {
                    if (context.mounted) {
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

                  if (context.mounted) {
                    final isVerified = await Navigator.of(context, rootNavigator: true).push<bool>(MaterialPageRoute(builder: (_) => const VerifyOldPasscodePage()));

                    if (isVerified == true && context.mounted) {
                      final result = await Navigator.of(context, rootNavigator: true).push<bool>(MaterialPageRoute(builder: (_) => const SetPasscodePage()));

                      if (result == true && context.mounted) {
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.white),
                                const SizedBox(width: 8),
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
                },
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Ilovadan chiqish'),
              const SizedBox(height: 12),
              _buildMenuItem(
                icon: AppIcons.logout,
                title: 'Ilovadan chiqish',
                titleColor: const Color(0xFFEF4444),
                showArrow: false,
                onTap: () {
                  _showLogoutDialog();
                },
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard() {
    final userName = UserData.name.isEmpty ? 'Ism kiritilmagan' : UserData.name;
    final userPhone = _formatPhoneNumber(UserData.phone);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.colors.divider.withValues(alpha: 0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                child: Icon(Icons.person_rounded, color: AppTheme.colors.primary, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.colors.black, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AppTheme.colors.background, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.phone_android_rounded, color: AppTheme.colors.primary, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            userPhone,
                            style: TextStyle(fontSize: 15, color: AppTheme.colors.primary, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 44,
                height: 44,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.colors.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.colors.divider),
                ),
                child: IconButton(
                  icon: SvgPicture.asset(AppIcons.edit, colorFilter: ColorFilter.mode(AppTheme.colors.primary, BlendMode.srcIn)),
                  onPressed: () {
                    pushScreen(context, screen: const ProfileUpdatePage()).then((_) {
                      setState(() {});
                    });
                  },
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.colors.gray, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildMenuItem({required String icon, required String title, String? subtitle, Color? titleColor, bool showArrow = true, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.colors.divider),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                SvgPicture.asset(icon),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: titleColor ?? AppTheme.colors.black),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(fontSize: 13, color: AppTheme.colors.primary, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ],
                  ),
                ),
                if (showArrow) Icon(Icons.chevron_right_rounded, color: AppTheme.colors.gray, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinCodeSwitch() {
    return FutureBuilder<Map<String, dynamic>>(
      future: SharedPrefService.initialize().then((pref) => {'isEnabled': pref.isPasscodeEnabled, 'hasPasscode': pref.passcode.isNotEmpty}),
      builder: (context, snapshot) {
        final data = snapshot.data ?? {'isEnabled': false, 'hasPasscode': false};
        final isEnabled = data['isEnabled'] as bool;
        final hasPasscode = data['hasPasscode'] as bool;

        return Container(
          decoration: BoxDecoration(
            color: AppTheme.colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.colors.divider),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(color: AppTheme.colors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.pin, color: AppTheme.colors.primary, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'PIN-kod',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.colors.black),
                  ),
                ),
                Switch.adaptive(
                  value: isEnabled,
                  activeTrackColor: AppTheme.colors.primary.withValues(alpha: 0.5),
                  activeThumbColor: AppTheme.colors.primary,
                  onChanged: (value) async {
                    final pref = await SharedPrefService.initialize();

                    if (value) {
                      if (!hasPasscode) {
                        if (context.mounted) {
                          final result = await Navigator.of(context, rootNavigator: true).push<bool>(MaterialPageRoute(builder: (_) => const SetPasscodePage()));
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
          ),
        );
      },
    );
  }

  Widget _buildBiometricSwitch() {
    return FutureBuilder<Map<String, dynamic>>(
      future: () async {
        final pref = await SharedPrefService.initialize();
        final localAuth = LocalAuthentication();
        final canCheck = await localAuth.canCheckBiometrics;
        final available = await localAuth.getAvailableBiometrics();
        final isPinEnabled = pref.isPasscodeEnabled;

        return {'canCheck': canCheck && available.isNotEmpty, 'isEnabled': pref.isBiometricEnabled, 'isPinEnabled': isPinEnabled};
      }(),
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null || !(data['canCheck'] as bool) || !(data['isPinEnabled'] as bool)) {
          return const SizedBox.shrink();
        }

        final isEnabled = data['isEnabled'] as bool;

        return Container(
          decoration: BoxDecoration(
            color: AppTheme.colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.colors.divider),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(color: AppTheme.colors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.fingerprint, color: AppTheme.colors.primary, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Biometrik autentifikatsiya',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.colors.black),
                  ),
                ),
                Switch.adaptive(
                  value: isEnabled,
                  activeTrackColor: AppTheme.colors.primary.withValues(alpha: 0.5),
                  activeThumbColor: AppTheme.colors.primary,
                  onChanged: (value) async {
                    final pref = await SharedPrefService.initialize();
                    pref.setBiometricEnabled(value);
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        );
      },
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
                      UserData.token = '';
                      UserData.name = '';
                      UserData.phone = '';
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
                    child: const Text(
                      'Chiqish',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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
