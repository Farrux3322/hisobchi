import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hisobchi/presentation/pages/notification/notification_page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:hisobchi/application/subscription/subscription_bloc.dart';
import 'package:hisobchi/application/theme/theme_bloc.dart';
import 'package:hisobchi/application/theme/theme_state.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/domain/common/data/user_data.dart';
import 'package:hisobchi/infrastructure/services/shared_service.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/pages/profile/widgets/theme_selector_bottom_sheet.dart';
import 'package:hisobchi/presentation/pages/subscription/subscription_page.dart';
import 'package:hisobchi/presentation/routes/index_routes.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profil',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppTheme.colors.black),
        ),
        actions: [
          Container(
            margin: EdgeInsets.all(8),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
            ),
            child: IconButton(
              icon: Icon(Icons.notifications, color: AppTheme.colors.primary, size: 20),
              onPressed: () {
                pushScreen(context, screen: const NotificationPage());
              },
              padding: EdgeInsets.zero,
            ),
          ),

          Gap(10),
        ],
      ),
      // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
              _buildPlanCard(),
              const SizedBox(height: 16),
              _buildSmsLimitCard(),
              const SizedBox(height: 24),
              _buildSectionTitle('Savollaringiz bormi?'),
              const SizedBox(height: 12),
              _buildMenuItem(icon: AppIcons.telegram, title: 'Telegram bot', onTap: () {}),
              const SizedBox(height: 8),
              _buildMenuItem(icon: AppIcons.telegram, title: 'Telegram guruh', onTap: () {}),
              const SizedBox(height: 24),
              _buildSectionTitle('Tashqi ko\'rinishi'),
              const SizedBox(height: 12),
              _buildMenuItem(icon: AppIcons.language, title: 'Tillar', subtitle: 'Uzbek tili', onTap: () {}),
              const SizedBox(height: 8),
              BlocBuilder<ThemeBloc, ThemeState>(
                builder: (context, themeState) {
                  return _buildMenuItem(
                    icon: AppIcons.theme,
                    title: 'Mavzular',
                    subtitle: themeState.themeModeName,
                    onTap: () {
                      showModalBottomSheet(context: context, backgroundColor: Colors.transparent, isScrollControlled: true, builder: (context) => const ThemeSelectorBottomSheet());
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Xavfsizlik'),
              const SizedBox(height: 12),
              _buildMenuItem(icon: AppIcons.lock, title: 'Parolni o\'zgartirish', onTap: () {}),
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
               SizedBox(height: MediaQuery.of(context).padding.bottom+10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.colors.white,
        boxShadow: [BoxShadow(color: AppTheme.colors.divider, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Profil',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppTheme.colors.black),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
            ),
            child: IconButton(
              icon: Icon(Icons.notifications, color: Color(0xFF10B981), size: 20),
              onPressed: () {
                print('Fartsda');
                pushScreen(context, screen: const NotificationPage());
              },
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard() {
    final userName = UserData.name.isEmpty ? 'Samandarbek' : UserData.name;
    final userPhone = UserData.phone.isEmpty ? '+998 (93) 123-45-67' : UserData.phone;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.colors.divider),
        boxShadow: [BoxShadow(color: AppTheme.colors.divider, blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppTheme.colors.primary, AppTheme.colors.primary.withOpacity(0.8)]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: AppTheme.colors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.colors.black),
                ),
                const SizedBox(height: 4),
                Text(userPhone, style: TextStyle(fontSize: 14, color: AppTheme.colors.gray)),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.colors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.colors.divider),
            ),
            child: IconButton(
              icon: Icon(Icons.edit_outlined, color: AppTheme.colors.gray, size: 18),
              onPressed: () {},
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard() {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, state) {
        if (state.infoStatus == Status.loading) {
          return _buildPlanCardSkeleton();
        }

        final subscription = state.subscriptionInfo?.subscription;
        final planType = subscription?.plan?.displayName ?? 'Free';
        final planExpiry = subscription?.currentPeriod?.end ?? '-';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.colors.primary.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: AppTheme.colors.background, borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.all(12),
                child: SvgPicture.asset(AppIcons.crown, colorFilter: ColorFilter.mode(AppTheme.colors.primary, BlendMode.srcIn)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Joriy tarifingiz: ', style: TextStyle(fontSize: 14, color: AppTheme.colors.gray)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: AppTheme.colors.primary, borderRadius: BorderRadius.circular(6)),
                          child: Text(
                            planType,
                            style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Amal qilish muddati: $planExpiry',
                      style: TextStyle(fontSize: 13, color: AppTheme.colors.black, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.colors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.colors.primary.withOpacity(0.2)),
                ),
                child: IconButton(
                  icon: Icon(Icons.add, color: AppTheme.colors.primary, size: 20),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => TariflarScreen())).then((v) {
                      if (v == true && context.mounted) {
                        context.read<SubscriptionBloc>().add(GetSubscriptionInfoEvent());
                      }
                    });
                  },
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Shimmer skeleton for plan card
  Widget _buildPlanCardSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.colors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 100,
                        height: 14,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 50,
                        height: 20,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 160,
                    height: 13,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                  ),
                ],
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmsLimitCard() {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, state) {
        if (state.infoStatus == Status.loading) {
          return _buildSmsLimitCardSkeleton();
        }

        final smsUsage = state.subscriptionInfo?.subscription?.usage?.sms;
        final smsUsed = smsUsage?.current ?? 0;
        final smsTotal = smsUsage?.max ?? 0;
        final smsProgress = smsTotal > 0 ? smsUsed / smsTotal : 0.0;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(color: AppTheme.colors.background, borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.all(12),
                    child: SvgPicture.asset(AppIcons.sms, colorFilter: const ColorFilter.mode(Color(0xFF10B981), BlendMode.srcIn)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SMS limiti', style: TextStyle(fontSize: 14, color: AppTheme.colors.gray)),
                        const SizedBox(height: 4),
                        Text(
                          '$smsUsed / $smsTotal',
                          style: TextStyle(fontSize: 16, color: AppTheme.colors.black, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.colors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
                    ),
                    child: const IconButton(
                      icon: Icon(Icons.add, color: Color(0xFF10B981), size: 20),
                      onPressed: null,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(value: smsProgress, backgroundColor: AppTheme.colors.background, valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)), minHeight: 8),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Shimmer skeleton for SMS limit card
  Widget _buildSmsLimitCardSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.colors.divider),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 80,
                        height: 14,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 60,
                        height: 16,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 8,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            ),
          ],
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
      margin: const EdgeInsets.only(bottom: 0),
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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Ilovadan chiqish',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.colors.black),
        ),
        content: Text('Haqiqatan ham ilovadan chiqmoqchimisiz?', style: TextStyle(fontSize: 15, color: AppTheme.colors.gray)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Bekor qilish',
              style: TextStyle(color: AppTheme.colors.gray, fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final pref = await SharedPrefService.initialize();
              pref.clear();
              UserData.token = '';
              if (context.mounted) {
                GoRouter.of(context).go(Routes.signIn.path);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Chiqish', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
