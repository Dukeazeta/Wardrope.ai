import 'package:flutter/material.dart';

class OnboardingItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String? imageAsset;

  const OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.imageAsset,
  });
}

class OnboardingData {
  static List<OnboardingItem> get items => [
    OnboardingItem(
      title: 'Smart Wardrobe Analysis',
      description: 'Get personalized outfit recommendations based on your clothes, style preferences, and occasions.',
      icon: Icons.auto_awesome,
      color: Colors.black,
    ),
    OnboardingItem(
      title: 'Plan Your Looks',
      description: 'Organize your wardrobe, create outfits, and never wonder what to wear again.',
      icon: Icons.calendar_today,
      color: Colors.black,
    ),
    OnboardingItem(
      title: 'AI Fashion Insights',
      description: 'Transform your daily style routine with AI-powered fashion recommendations.',
      icon: Icons.insights,
      color: Colors.black,
    ),
  ];
}