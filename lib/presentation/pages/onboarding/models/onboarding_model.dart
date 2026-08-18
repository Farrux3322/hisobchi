import 'package:flutter/material.dart';

class OnboardingModel {
  final String badge;
  final String title;
  final String description;
  final List<String> features;
  final Color primaryColor;
  final Color secondaryColor;
  final IconData badgeIcon;

  const OnboardingModel({
    required this.badge,
    required this.title,
    required this.description,
    required this.features,
    required this.primaryColor,
    required this.secondaryColor,
    required this.badgeIcon,
  });
}

