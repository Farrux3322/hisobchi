import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hisobchi/infrastructure/services/showcase_service.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late PageController _pageController;
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Bosh sahifa',
      description: 'Bu yerda moliyaviy hisobotlaringiz, statistikalar va umumiy ma\'lumotlarni ko\'rishingiz mumkin',
      icon: AppIcons.home,
      color: const Color(0xFF4F46E5),
    ),
    OnboardingData(
      title: 'Mijozlar',
      description: 'Mijozlarni boshqaring, ularning hisoblarini kuzating va yangi mijoz qo\'shing',
      icon: AppIcons.clients,
      color: const Color(0xFF10B981),
    ),
    OnboardingData(
      title: 'Loyihalar',
      description: 'Loyihalaringizni yarating, tahrirlang va ularga mijozlarni biriktirib boshqaring',
      icon: AppIcons.project,
      color: const Color(0xFFF59E0B),
    ),
    OnboardingData(
      title: 'Profil',
      description: 'Shaxsiy ma\'lumotlaringiz, sozlamalar va obuna tarifini bu yerdan boshqaring',
      icon: AppIcons.profile,
      color: const Color(0xFFEC4899),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

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

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _finishOnboarding() async {
    await ShowcaseService.setShowcaseCompleted();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with skip button
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo or app name
                  Text(
                    'eHisob',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.colors.primary,
                    ),
                  ),
                  // Skip button
                  TextButton(
                    onPressed: _finishOnboarding,
                    child: Text(
                      'O\'tkazib yuborish',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.colors.gray,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Page indicator
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: List.generate(
                  _pages.length,
                  (index) => Expanded(
                    child: Container(
                      height: 4.h,
                      margin: EdgeInsets.only(right: index < _pages.length - 1 ? 8.w : 0),
                      decoration: BoxDecoration(
                        color: index <= _currentPage
                            ? _pages[_currentPage].color
                            : AppTheme.colors.gray.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index], index);
                },
              ),
            ),

            // Bottom navigation buttons
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
              child: Row(
                children: [
                  // Counter
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: _pages[_currentPage].color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      '${_currentPage + 1}/${_pages.length}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: _pages[_currentPage].color,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Previous button
                  if (_currentPage > 0)
                    IconButton(
                      onPressed: _previousPage,
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: _pages[_currentPage].color,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: _pages[_currentPage].color.withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.all(12.w),
                      ),
                    ),
                  if (_currentPage > 0) Gap(12.w),
                  // Next/Finish button
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _pages[_currentPage].color,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentPage == _pages.length - 1 ? 'Boshlash' : 'Keyingisi',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Gap(8.w),
                        Icon(
                          _currentPage == _pages.length - 1
                              ? Icons.check_rounded
                              : Icons.arrow_forward_rounded,
                          size: 20.sp,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingData data, int index) {
    return Padding(
      padding: EdgeInsets.all(32.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Icon
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            tween: Tween(begin: 0.0, end: _currentPage == index ? 1.0 : 0.0),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.5 + (0.5 * value),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: Container(
              width: 160.w,
              height: 160.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    data.color,
                    data.color.withValues(alpha: 0.7),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: data.color.withValues(alpha: 0.3),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Center(
                child: SvgPicture.asset(
                  data.icon,
                  width: 80.w,
                  height: 80.w,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
          Gap(48.h),
          // Title
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            tween: Tween(begin: 0.0, end: _currentPage == index ? 1.0 : 0.0),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: Text(
              data.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.w800,
                color: AppTheme.colors.black,
                height: 1.2,
              ),
            ),
          ),
          Gap(16.h),
          // Description
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 700),
            tween: Tween(begin: 0.0, end: _currentPage == index ? 1.0 : 0.0),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: Text(
              data.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: AppTheme.colors.gray,
                height: 1.6,
              ),
            ),
          ),
          Gap(48.h),
          // Features list (if needed)
          if (index == 0) _buildFeaturesList(data.color),
        ],
      ),
    );
  }

  Widget _buildFeaturesList(Color color) {
    final features = [
      'Moliyaviy hisobotlar',
      'Statistikalar va tahlillar',
      'Umumiy ma\'lumotlar',
    ];

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: _currentPage == 0 ? 1.0 : 0.0),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: Column(
        children: features.map((feature) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 16.sp,
                    color: color,
                  ),
                ),
                Gap(12.w),
                Text(
                  feature,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.colors.black,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final String icon;
  final Color color;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}