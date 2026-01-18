import 'package:flutter/animation.dart';

class OnboardingModel {
  final String title;
  final String description;
  final List<String> features;
  final String iconAsset;
  final List<Color> gradientColors;

  const OnboardingModel({
    required this.title,
    required this.description,
    required this.features,
    required this.iconAsset,
    required this.gradientColors,
  });
}
