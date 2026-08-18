import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:ehisob/infrastructure/services/shared_service.dart';
import 'package:ehisob/presentation/assets/asset_index.dart';
import 'package:ehisob/presentation/pages/onboarding/models/onboarding_model.dart';
import 'package:ehisob/presentation/pages/onboarding/widgets/gradient_button.dart';
import 'package:ehisob/presentation/pages/onboarding/widgets/onboarding_content.dart';
import 'package:ehisob/presentation/pages/onboarding/widgets/page_indicator.dart';
import 'package:ehisob/presentation/routes/entity/routes.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late final List<OnboardingModel> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      OnboardingModel(
        badge: '⚡ Moliyaviy Nazorat',
        badgeIcon: Icons.account_balance_wallet_rounded,
        title: 'Moliyangizni Bir Joyda\nBoshqaring',
        description:
            'EHisob bilan barcha kirim-chiqimlaringizni real vaqt rejimida nazorat qiling va biznesingizni oson yuring.',
        features: const [
          'Tezkor va oson',
          'Real-vaqt hisoboti',
          '100% Himoyalangan',
        ],
        primaryColor: AppTheme.colors.primary,
        secondaryColor: const Color(0xFF2563EB),
      ),
      OnboardingModel(
        badge: '📁 Loyiha va Mijozlar',
        badgeIcon: Icons.folder_shared_rounded,
        title: 'Loyihalar va Mijozlar\nDoim Nazoratda',
        description:
            'Mijozlar bilan barcha o\'zaro hisob-kitoblarni aniq va shaffof yuriting, qarzdorliklarni vaqtida kuzating.',
        features: const [
          'Mijozlar balansi',
          'Bosqichma-bosqich',
          'Aniq hisob-kitob',
        ],
        primaryColor: const Color(0xFF10B981),
        secondaryColor: const Color(0xFF059669),
      ),
      OnboardingModel(
        badge: '📊 Valyuta va Tahlil',
        badgeIcon: Icons.analytics_rounded,
        title: 'Balans va Valyutalarni\nTahlil Qiling',
        description:
            'Kirim-chiqim grafiklari va valyuta kurslari onlayn yangilanib turadi. Ishonch bilan qaror qabul qiling.',
        features: const [
          'Valyuta konvertori',
          'Vizual grafiklar',
          'Tezkor eksport',
        ],
        primaryColor: const Color(0xFF8B5CF6),
        secondaryColor: const Color(0xFF6366F1),
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    HapticFeedback.selectionClick();
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _finishOnboarding() async {
    HapticFeedback.mediumImpact();

    // Mark onboarding as completed
    final sharedPref = await SharedPrefService.initialize();
    sharedPref.setOnboardingCompleted(true);

    if (mounted) {
      context.go(Routes.signIn.path);
    }
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _skipOnboarding() {
    HapticFeedback.lightImpact();
    _finishOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final activeModel = _pages[_currentPage];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: PopScope(
        canPop: false,
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar: Step Segment Progress Bar & Header
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 4.h),
                child: Column(
                  children: [
                    // Segmented Progress Bar
                    Row(
                      children: List.generate(
                        _pages.length,
                        (index) => Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 350),
                            height: 4.h,
                            margin: EdgeInsets.symmetric(horizontal: 2.w),
                            decoration: BoxDecoration(
                              color: index <= _currentPage
                                  ? activeModel.primaryColor
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),

                    // Step Indicator & Skip Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Step Pill
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Text(
                            '0${_currentPage + 1} / 0${_pages.length}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),

                        // Skip Pill
                        if (_currentPage < _pages.length - 1)
                          InkWell(
                            onTap: _skipOnboarding,
                            borderRadius: BorderRadius.circular(20.r),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 5.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(color: Colors.grey.shade200),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'O\'tkazib yuborish',
                                    style: TextStyle(
                                      color: const Color(0xFF64748B),
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 10.sp,
                                    color: const Color(0xFF64748B),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                      ],
                    ),
                  ],
                ),
              ),

              // PageView Main Body Content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return OnboardingContent(
                      model: _pages[index],
                      pageIndex: index,
                    );
                  },
                ),
              ),

              // Seamless Floating Bottom Action Bar (No heavy card blocking body)
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 12.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Smooth Page Indicator
                    PageIndicator(
                      currentPage: _currentPage,
                      pageCount: _pages.length,
                      activeColor: activeModel.primaryColor,
                      inactiveColor: const Color(0xFFCBD5E1),
                    ),

                    // Next / Finish Action Button
                    GradientButton(
                      text: _currentPage == _pages.length - 1
                          ? 'Boshlash'
                          : 'Keyingisi',
                      onPressed: _nextPage,
                      height: 50.h,
                      borderRadius: 25,
                      icon: _currentPage == _pages.length - 1
                          ? Icons.check_circle_rounded
                          : Icons.arrow_forward_rounded,
                      gradientColors: [
                        activeModel.primaryColor,
                        activeModel.secondaryColor,
                      ],
                      textColor: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
