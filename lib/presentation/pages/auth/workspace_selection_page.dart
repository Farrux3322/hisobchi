import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/auth/init/init_auth_bloc.dart';
import 'package:hisobchi/infrastructure/models/user_me_model.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';

import '../../components/loading/premium_loading.dart';
import '../../components/toast/toast.dart';
import '../../routes/index_routes.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class MathUtility {
  static double sin(double v) => math.sin(v);
  static double cos(double v) => math.cos(v);
}

class WorkspaceSelectionPage extends StatefulWidget {
  final UserMeModel meData;
  const WorkspaceSelectionPage({super.key, required this.meData});

  @override
  State<WorkspaceSelectionPage> createState() => _WorkspaceSelectionPageState();
}

class _WorkspaceSelectionPageState extends State<WorkspaceSelectionPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final PageController _staffPageController = PageController(viewportFraction: 0.88);

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    _staffPageController.dispose();
    super.dispose();
  }

  String _formatPhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) return '';
    String cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.length > 9) cleanPhone = cleanPhone.substring(cleanPhone.length - 9);
    if (cleanPhone.length == 9) {
      return '+998 (${cleanPhone.substring(0, 2)}) ${cleanPhone.substring(2, 5)} ${cleanPhone.substring(5, 7)} ${cleanPhone.substring(7, 9)}';
    }
    return phone;
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.meData.result;
    final hasOwnerRole = result.role.contains('user');
    final hasWorkspaces = result.worksFor.isNotEmpty;

    // Pure Light Theme Aesthetics
    const bgColor = Color(0xFFF8FAFC);
    const cardColor = Colors.white;
    const textColor = Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: bgColor,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Stack(
          children: [
            _buildAmbientBackground(),
            SafeArea(
              child: BlocListener<InitAuthBloc, InitAuthState>(
                listener: (context, state) {
                  if (state is ActivateOwnerAccountSuccess) {
                    Toast.showSuccessToast(message: 'Hisob faollashtirildi!');
                  } else if (state is ActivateOwnerAccountFailed) {
                    Toast.showErrorToast(message: state.error);
                  } else if (state is SignInSuccess) {
                    context.go(Routes.homePage.path);
                  }
                },
                child: BlocBuilder<InitAuthBloc, InitAuthState>(
                  builder: (context, state) {
                    return Stack(
                      children: [
                        _buildLightBentoGallery(hasOwnerRole, hasWorkspaces, cardColor, textColor),
                        if (state is ActivateOwnerAccountLoading || state is SignInLoading)
                          const PremiumLoading(),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmbientBackground() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.5,
                colors: [
                  AppTheme.colors.primary.withValues(alpha: 0.03 + (_pulseController.value * 0.02)),
                  Colors.transparent,
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLightBentoGallery(bool hasOwnerRole, bool hasWorkspaces, Color cardColor, Color textColor) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildExecutiveHeader(textColor),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                physics: const BouncingScrollPhysics(),
                children: [
                  if (hasWorkspaces) ...[
                    _buildSectionTitle('Xodim sifatida qo\'shilgan hisobingiz'),
                    _buildStaffGallery(cardColor, textColor),
                    const Gap(32),
                  ],
                  _buildSectionTitle('Yangi hisob'),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: hasOwnerRole
                        ? _buildOwnerBentoCard(cardColor)
                        : _buildActivationBentoCard(cardColor, textColor),
                  ),
                  const Gap(40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
 
  Widget _buildExecutiveHeader(Color textColor) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HISOBNI TANLASH',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.colors.primary,
                    letterSpacing: 2,
                  ),
                ),
                const Gap(4),
                Text(
                  widget.meData.result.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Icon(Icons.shield_outlined, color: AppTheme.colors.primary, size: 24.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(26.w, 0, 24.w, 16.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF64748B),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildStaffGallery(Color cardColor, Color textColor) {
    final workspaces = widget.meData.result.worksFor;
    return Column(
      children: [
        SizedBox(
          height: 140.h,
          child: PageView.builder(
            controller: _staffPageController,
            itemCount: workspaces.length,
            itemBuilder: (context, index) {
              final workspace = workspaces[index];
              return _buildStaffGalleryItem(workspace, cardColor, textColor);
            },
          ),
        ),
        if (workspaces.length > 1) ...[
          const Gap(16),
          SmoothPageIndicator(
            controller: _staffPageController,
            count: workspaces.length,
            effect: ExpandingDotsEffect(
              dotWidth: 8,
              dotHeight: 4,
              expansionFactor: 3,
              spacing: 6,
              dotColor: AppTheme.colors.primary.withValues(alpha: 0.1),
              activeDotColor: AppTheme.colors.primary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStaffGalleryItem(WorksFor workspace, Color cardColor, Color textColor) {
    return _SelectionBentoCard(
      onTap: () {
        HapticFeedback.lightImpact();
        context.read<InitAuthBloc>().add(SelectWorkspaceEvent(meData: widget.meData, workspace: workspace));
      },
      child: Container(
        margin: EdgeInsets.only(right: 16.w),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Row(
          children: [
            _StaffAvatar(name: workspace.ownerName),
            const Gap(16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    workspace.ownerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: textColor),
                  ),
                  Text(
                    "Xodim bo'lib kirish",
                    style: TextStyle(fontSize: 13.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.colors.primary.withValues(alpha: 0.3), size: 18.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnerBentoCard(Color cardColor) {
    return _SelectionBentoCard(
      onTap: () {
        HapticFeedback.mediumImpact();
        context.read<InitAuthBloc>().add(SelectWorkspaceEvent(meData: widget.meData));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient:  LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.colors.primary, AppTheme.colors.primary.withValues(alpha: 0.8)],
          ),
          borderRadius: BorderRadius.circular(32.r),
          boxShadow: [
            BoxShadow(
              color: AppTheme.colors.primary.withValues(alpha: 0.25),
              blurRadius: 25,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SHAXSIY BOSHQARUV',
                    style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w900, color: Colors.white.withValues(alpha: 0.6), letterSpacing: 1.5),
                  ),
                  const Gap(8),
                  Text(
                    'Asosiy Hisob',
                    style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
                  ),
                  Text(
                    _formatPhoneNumber(widget.meData.result.phone),
                    style: TextStyle(fontSize: 14.sp, color: Colors.white.withValues(alpha: 0.7), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 32),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivationBentoCard(Color cardColor, Color textColor) {
    return _SelectionBentoCard(
      onTap: () => _showLiteActivationSheet(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: AppTheme.colors.primary.withValues(alpha: 0.15), width: 2),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 8)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shaxsiy hisob ochish',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: textColor),
                  ),

                ],
              ),
            ),
            Icon(Icons.add_task_rounded, color: AppTheme.colors.primary, size: 30),
          ],
        ),
      ),
    );
  }

  void _showLiteActivationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(36), topRight: Radius.circular(36)),
        ),
        padding: EdgeInsets.fromLTRB(32, 24, 32, MediaQuery.of(context).padding.bottom + 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10))),
            const Gap(40),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppTheme.colors.primary.withValues(alpha: 0.05), shape: BoxShape.circle),
              child: Icon(Icons.auto_awesome_rounded, color: AppTheme.colors.primary, size: 40),
            ),
            const Gap(24),
            Text('Sifatli Biznes Boshqaruvi', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
            const Gap(12),
            Text('E-Hisob tizimi orqali biznesingizni yangi darajaga olib chiqing va barcha jarayonlarni nazorat qiling.', textAlign: TextAlign.center, style: TextStyle(fontSize: 15.sp, color: const Color(0xFF64748B), height: 1.5)),
            const Gap(40),
            _LiteFeatureItem(icon: Icons.people_alt_rounded, title: 'Hamkorlar Nazorati', desc: 'Mijozlar va hamkorlar bilan barcha hisob-kitoblarni tizimli va shaffof holatda yuriting.'),
            const Gap(24),
            _LiteFeatureItem(icon: Icons.assignment_rounded, title: 'Loyihalar Boshqaruvi', desc: 'Loyiha doirasidagi xarajatlar, daromadlar va ishchilar hisobini aniq yuriting.'),
            const Gap(40),
            SizedBox(
              width: double.infinity,
              height: 60.h,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<InitAuthBloc>().add(ActivateOwnerAccountEvent(meData: widget.meData));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.colors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
                  elevation: 0,
                ),
                child: Text('Yangi hisob ochish', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaffAvatar extends StatelessWidget {
  final String name;
  const _StaffAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final char = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      width: 54.w,
      height: 54.w,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      alignment: Alignment.center,
      child: Text(char, style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900, color: AppTheme.colors.primary)),
    );
  }
}

class _SelectionBentoCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _SelectionBentoCard({required this.child, required this.onTap});

  @override
  State<_SelectionBentoCard> createState() => _SelectionBentoCardState();
}

class _SelectionBentoCardState extends State<_SelectionBentoCard> {
  double _scale = 1.0;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(scale: _scale, duration: const Duration(milliseconds: 100), child: widget.child),
    );
  }
}

class _LiteFeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _LiteFeatureItem({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppTheme.colors.primary.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(14.r)),
          child: Icon(icon, color: AppTheme.colors.primary, size: 24.sp),
        ),
        const Gap(16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
              Text(desc, style: TextStyle(fontSize: 13.sp, color: const Color(0xFF64748B))),
            ],
          ),
        ),
      ],
    );
  }
}
