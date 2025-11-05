import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final textColor = theme.textTheme.headlineLarge?.color ?? Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Wardrobe.ai',
          style: AppTheme.primaryFont.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: AppTheme.displaySmallFontSize,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.style,
              size: AppTheme.iconXXL,
              color: const Color(0xFF6C63FF),
            ),
            SizedBox(height: AppTheme.spacingL),
            Text(
              'Welcome to Wardrobe.ai',
              style: AppTheme.primaryFont.copyWith(
                fontSize: AppTheme.displaySmallFontSize,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            SizedBox(height: AppTheme.spacingM),
            Text(
              'Your AI-powered fashion companion',
              style: AppTheme.primaryFont.copyWith(
                fontSize: AppTheme.bodyLargeFontSize,
                color: isDark ? Colors.grey.shade400 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}