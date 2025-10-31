import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Wardrope.ai',
          style: TextStyle(
            color: const Color(0xFF2D3436),
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
              'Welcome to Wardrope.ai',
              style: TextStyle(
                fontSize: AppTheme.displaySmallFontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D3436),
              ),
            ),
            SizedBox(height: AppTheme.spacingM),
            Text(
              'Your AI-powered fashion companion',
              style: TextStyle(
                fontSize: AppTheme.bodyLargeFontSize,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}