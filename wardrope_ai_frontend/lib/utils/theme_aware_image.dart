import 'package:flutter/material.dart';
import '../services/theme_service.dart';

class ThemeAwareImage {
  static String getImageAsset(BuildContext context, String assetPath) {
    final themeService = ThemeService();
    final isDarkMode = themeService.isDarkModeEnabled(context);

    // If not dark mode, return original asset
    if (!isDarkMode) {
      return assetPath;
    }

    // Try to find dark mode variant
    final darkVariant = _getDarkVariant(assetPath);

    // For now, return original since dark variants don't exist yet
    // You can replace these with actual dark mode images when you create them
    return darkVariant ?? assetPath;
  }

  static String? _getDarkVariant(String originalPath) {
    // Define mapping of light images to their dark variants
    final Map<String, String> darkMappings = {
      'assets/onboarding/Logo.png': 'assets/Logo_dark.png',
      'assets/onboarding/Onboarding.png': 'assets/Onboarding_dark.png',
      'assets/Add clothes 02.png': 'assets/Add clothes 02_dark.png',
      'assets/Add clothes.png': 'assets/Add clothes_dark.png',
      'assets/Model.png': 'assets/Model_dark.png',
    };

    return darkMappings[originalPath];
  }

  static Widget build({
    required BuildContext context,
    required String assetPath,
    double? width,
    double? height,
    BoxFit? fit,
    ImageErrorWidgetBuilder? errorBuilder,
  }) {
    final themeAwarePath = getImageAsset(context, assetPath);

    return Image.asset(
      themeAwarePath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: errorBuilder ?? _defaultErrorBuilder,
    );
  }

  static Widget _defaultErrorBuilder(BuildContext context, Object error, StackTrace? stackTrace) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 48,
          color: isDark ? Colors.grey.shade400 : Colors.grey,
        ),
      ),
    );
  }
}