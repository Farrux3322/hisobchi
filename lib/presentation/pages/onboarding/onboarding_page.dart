import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hisobchi/infrastructure/services/shared_service.dart';
import 'package:hisobchi/presentation/pages/onboarding/models/onboarding_model.dart';
import 'package:hisobchi/presentation/pages/onboarding/widgets/gradient_button.dart';
import 'package:hisobchi/presentation/pages/onboarding/widgets/onboarding_content.dart';
import 'package:hisobchi/presentation/pages/onboarding/widgets/page_indicator.dart';
import 'package:hisobchi/presentation/routes/entity/routes.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingModel> _pages = [
    const OnboardingModel(
      title: 'E-Hisob ga\nXush Kelibsiz!',
      description:
          'Professional moliyaviy boshqaruv va biznesingizni rivojlantirish uchun eng yaxshi vosita',
      features: [
        'Sodda va qulay interfeys',
        'Real-time ma\'lumotlar',
        'Xavfsiz va ishonchli',
      ],
      iconAsset: '',
      gradientColors: [
        Color(0xFF6366F1),
        Color(0xFF8B5CF6),
      ],
    ),
    const OnboardingModel(
      title: 'Biznesingizni\nBoshqaring',
      description:
          'Loyihalar, mijozlar va moliyaviy oqimlarni bir joyda nazorat qiling',
      features: [
        'Loyihalarni professional kuzatish',
        'Mijozlar bilan aniq hisob-kitob',
        'Real-time balans va hisobotlar',
      ],
      iconAsset: '',
      gradientColors: [
        Color(0xFF10B981),
        Color(0xFF059669),
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
                top: 8,
                right: 24,
                child: SafeArea(
                  child: TextButton(
                    onPressed: _skipOnboarding,
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'O\'tkazib yuborish',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
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
                  padding: const EdgeInsets.all(32),
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

                      const SizedBox(height: 32),

                      // Next/Start Button
                      GradientButton(
                        text: _currentPage == _pages.length - 1
                            ? 'Boshlash'
                            : 'Keyingisi',
                        onPressed: _nextPage,
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
