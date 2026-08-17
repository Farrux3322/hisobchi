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

  // Barcha onboarding gradientlari endi qattiq kodlangan hex emas,
  // bevosita ilovaning AppTheme/BaseColors tokenlaridan olinadi.
  final List<OnboardingModel> _pages = [
    OnboardingModel(
      title: 'Moliyangizni\nBir Joyda Ko\'ring',
      description:
          'E-Hisob bilan kundalik hisob-kitoblaringizni soddalashtiring va biznesingizni ishonch bilan boshqaring',
      features: const [
        'Tez va tushunarli interfeys',
        'Ma\'lumotlar real vaqtda yangilanadi',
        'Ma\'lumotlaringiz ishonchli himoyada',
      ],
      // Primary → Secondary (ilovaning ikkita asosiy brend rangi)
      gradientColors: [
        AppTheme.colors.primary,
        AppTheme.colors.secondary.withValues(alpha: 1),
      ],
    ),
    OnboardingModel(
      title: 'Loyiha va Mijozlar\nDoim Nazoratda',
      description:
          'Har bir loyihangiz va mijozingiz bilan bog\'liq hisob-kitoblarni bir joydan kuzatib boring',
      features: const [
        'Loyihalarni bosqichma-bosqich yuriting',
        'Mijozlar bilan hisob-kitob aniqligi',
        'Har lahzada yangilanadigan hisobotlar',
      ],
      // Ilovaning ThemeData'dagi "green" tokenidan monoxrom gradient
      gradientColors: [
        AppTheme.colors.green,
        Color.lerp(AppTheme.colors.green, Colors.black, 0.25)!,
      ],
    ),
    OnboardingModel(
      title: 'Balansni Kuzating,\nAniq Qaror Qabul Qiling',
      description:
          'Kirim-chiqim va valyuta kurslarini bir qarashda ko\'ring, moliyaviy holatingizdan doimo xabardor bo\'ling',
      features: const [
        'Kirim va chiqimlar tahlili',
        'Valyuta kurslari onlayn kuzatuvda',
        'Aniq va tushunarli hisobotlar',
      ],
      // Ilovaning "red" va "primary" tokenlaridan hosil qilingan gradient
      gradientColors: [
        AppTheme.colors.red,
        AppTheme.colors.primary,
      ],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
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
    HapticFeedback.lightImpact();
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
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
    return Scaffold(
      body: PopScope(
        canPop: false,
        child: Stack(
          children: [
            // PageView
            PageView.builder(
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

            // Skip Button (only show if not on last page)
            if (_currentPage < _pages.length - 1)
              Positioned(
                top: 8.h,
                right: 24.w,
                child: SafeArea(
                  child: TextButton(
                    onPressed: _skipOnboarding,
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 10.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                    ),
                    child: Text(
                      'O\'tkazib yuborish',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

            // Bottom Navigation
            Positioned(
              bottom: -25,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 32.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Page Indicator
                      PageIndicator(
                        currentPage: _currentPage,
                        pageCount: _pages.length,
                        activeColor: Colors.white,
                        inactiveColor: Colors.white.withValues(alpha: 0.3),
                      ),

                      SizedBox(height: 32.h),

                      // Next/Start Button
                      GradientButton(
                        text: _currentPage == _pages.length - 1
                            ? 'Boshlash'
                            : 'Keyingisi',
                        onPressed: _nextPage,
                        height: 56.h,
                        gradientColors: [
                          Colors.white,
                          Colors.white.withValues(alpha: 0.9),
                        ],
                        textColor: _pages[_currentPage].gradientColors.first,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
