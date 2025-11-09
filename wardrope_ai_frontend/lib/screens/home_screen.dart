import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final textColor = theme.textTheme.headlineLarge?.color ?? Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
=======
    return Scaffold(
      backgroundColor: Colors.white,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
<<<<<<< HEAD
          'Wardrobe.ai',
          style: AppTheme.primaryFont.copyWith(
            color: textColor,
=======
          'Wardrope.ai',
          style: TextStyle(
            color: const Color(0xFF2D3436),
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
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
<<<<<<< HEAD
              'Welcome to Wardrobe.ai',
              style: AppTheme.primaryFont.copyWith(
                fontSize: AppTheme.displaySmallFontSize,
                fontWeight: FontWeight.bold,
                color: textColor,
=======
              'Welcome to Wardrope.ai',
              style: TextStyle(
                fontSize: AppTheme.displaySmallFontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D3436),
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
              ),
            ),
            SizedBox(height: AppTheme.spacingM),
            Text(
              'Your AI-powered fashion companion',
<<<<<<< HEAD
              style: AppTheme.primaryFont.copyWith(
                fontSize: AppTheme.bodyLargeFontSize,
                color: isDark ? Colors.grey.shade400 : Colors.grey,
=======
              style: TextStyle(
                fontSize: AppTheme.bodyLargeFontSize,
                color: Colors.grey,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
              ),
            ),
          ],
        ),
      ),
    );
  }
}