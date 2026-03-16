import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/auth/init/init_auth_bloc.dart';
import 'package:hisobchi/infrastructure/models/user_me_model.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';

import '../../components/loading/premium_loading.dart';
import '../../components/toast/toast.dart';
import '../../routes/index_routes.dart';

class WorkspaceSelectionPage extends StatefulWidget {
  final UserMeModel meData;
  const WorkspaceSelectionPage({super.key, required this.meData});

  @override
  State<WorkspaceSelectionPage> createState() => _WorkspaceSelectionPageState();
}

class _WorkspaceSelectionPageState extends State<WorkspaceSelectionPage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _backgroundController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  String _formatPhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) return '';
    // Remove non-numeric characters
    String cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    
    // If it starts with 998, take the last 9 digits
    if (cleanPhone.length > 9) {
      cleanPhone = cleanPhone.substring(cleanPhone.length - 9);
    }
    
    if (cleanPhone.length == 9) {
      return '+998 (${cleanPhone.substring(0, 2)}) ${cleanPhone.substring(2, 5)} ${cleanPhone.substring(5, 7)} ${cleanPhone.substring(7, 9)}';
    }
    return phone;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(40),
                  _buildHeader(),
                  const Gap(40),
                  Expanded(
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
                              _buildContent(),
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
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: -100 + (50 * _backgroundController.value),
              right: -100 + (30 * _backgroundController.value),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.colors.primary.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              bottom: 100 - (40 * _backgroundController.value),
              left: -50 + (20 * _backgroundController.value),
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF6366F1).withValues(alpha: 0.06),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Hisobni tanlash',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.colors.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const Gap(16),
            Text(
              'Xush kelibsiz,',
              style: TextStyle(
                fontSize: 18.sp,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              widget.meData.result.name,
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1E293B),
                letterSpacing: -1,
              ),
            ),
            const Gap(8),
            Text(
              'Davom etish uchun kerakli hisobni tanlang',
              style: TextStyle(
                fontSize: 15.sp,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          if (widget.meData.result.role.contains('user')) ...[
            _buildSectionHeader('ASOSIY HISOB'),
            _buildWorkspaceCard(
              title: 'Shaxsiy hisob (Owner)',
              subtitle: _formatPhoneNumber(widget.meData.result.phone),
              icon: Icons.account_circle_rounded,
              color: AppTheme.colors.primary,
              onTap: () {
                HapticFeedback.mediumImpact();
                context.read<InitAuthBloc>().add(
                      SelectWorkspaceEvent(meData: widget.meData),
                    );
              },
            ),
            const Gap(32),
          ],
          if (widget.meData.result.worksFor.isNotEmpty) ...[
            _buildSectionHeader('ISH JOYLARI'),
            ...widget.meData.result.worksFor.map((w) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildWorkspaceCard(
                    title: w.ownerName,
                    subtitle: _formatPhoneNumber(w.ownerPhone),
                    icon: Icons.business_center_rounded,
                    color: const Color(0xFF6366F1),
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      context.read<InitAuthBloc>().add(
                            SelectWorkspaceEvent(meData: widget.meData, workspace: w),
                          );
                    },
                  ),
                )),
          ],
          if (!widget.meData.result.role.contains('user')) ...[
            const Gap(12),
            _buildActivationCTA(),
          ],
          const Gap(40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF94A3B8),
              letterSpacing: 1.5,
            ),
          ),
          const Gap(12),
          Expanded(
            child: Divider(
              color: const Color(0xFFE2E8F0),
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkspaceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: color.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withValues(alpha: 0.2),
                        color.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 30,
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const Gap(2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivationCTA() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.colors.primary.withValues(alpha: 0.1),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.colors.primary.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.colors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_business_rounded,
                color: AppTheme.colors.primary,
                size: 32,
              ),
            ),
            const Gap(16),
            Text(
              'O\'z biznesingizni boshlamoqchimisiz?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E293B),
              ),
            ),
            const Gap(8),
            Text(
              'Shaxsiy hisob ochish orqali loyihalaringizni mustaqil boshqarish imkoniyatiga ega bo\'ling.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const Gap(20),
            InkWell(
              onTap: () => _showActivationBottomSheet(context),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Batafsil ma\'lumot',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.colors.primary,
                      ),
                    ),
                    const Gap(8),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: AppTheme.colors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActivationBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        padding: EdgeInsets.fromLTRB(32, 20, 32, MediaQuery.of(context).padding.bottom + 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const Gap(32),
            Text(
              'E-HISOB Imkoniyatlari',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1E293B),
                letterSpacing: -0.5,
              ),
            ),
            const Gap(24),
            _buildFeatureInfo(
              icon: Icons.analytics_outlined,
              title: 'Moliyaviy tahlillar',
              description: 'Barcha daromad va xarajatlaringizni real vaqt rejimida kuzatib boring.',
            ),
            const Gap(20),
            _buildFeatureInfo(
              icon: Icons.people_outline_rounded,
              title: 'Xodimlarni boshqarish',
              description: 'O\'z jamoangizni shakllantiring va ularga kerakli ruxsatlarni belgilang.',
            ),
            const Gap(20),
            _buildFeatureInfo(
              icon: Icons.assignment_outlined,
              title: 'Loyiha nazorati',
              description: 'Har bir loyiha uchun alohida budjet va hisob-kitoblarni yuriting.',
            ),
            const Gap(40),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<InitAuthBloc>().add(ActivateOwnerAccountEvent(meData: widget.meData));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.colors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  shadowColor: AppTheme.colors.primary.withValues(alpha: 0.3),
                ),
                child: Text(
                  'Hisobni faollashtirish',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureInfo({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.colors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.colors.primary, size: 24),
        ),
        const Gap(16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const Gap(4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: const Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
