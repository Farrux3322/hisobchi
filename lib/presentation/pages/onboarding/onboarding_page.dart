import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:ehisob/infrastructure/services/shared_service.dart';
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

  final List<OnboardingModel> _pages = [
    const OnboardingModel(
      title: 'Moliyangizni\nBir Joyda Ko\'ring',
      description:
          'E-Hisob bilan kundalik hisob-kitoblaringizni soddalashtiring va biznesingizni ishonch bilan boshqaring',
      features: [
        'Tez va tushunarli interfeys',
        'Ma\'lumotlar real vaqtda yangilanadi',
        'Ma\'lumotlaringiz ishonchli himoyada',
      ],
      gradientColors: [
        Color(0xFF6366F1),
        Color(0xFF8B5CF6),
      ],
    ),
    const OnboardingModel(
      title: 'Loyiha va Mijozlar\nDoim Nazoratda',
      description:
          'Har bir loyihangiz va mijozingiz bilan bog\'liq hisob-kitoblarni bir joydan kuzatib boring',
      features: [
        'Loyihalarni bosqichma-bosqich yuriting',
        'Mijozlar bilan hisob-kitob aniqligi',
        'Har lahzada yangilanadigan hisobotlar',
      ],
      gradientColors: [
        Color(0xFF10B981),
        Color(0xFF059669),
      ],
    ),
    const OnboardingModel(
      title: 'Balansni Kuzating,\nAniq Qaror Qabul Qiling',
      description:
          'Kirim-chiqim va valyuta kurslarini bir qarashda ko\'ring, moliyaviy holatingizdan doimo xabardor bo\'ling',
      features: [
        'Kirim va chiqimlar tahlili',
        'Valyuta kurslari onlayn kuzatuvda',
        'Aniq va tushunarli hisobotlar',
      ],
      gradientColors: [
        Color(0xFFF59E0B),
        Color(0xFFEA580C),
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
