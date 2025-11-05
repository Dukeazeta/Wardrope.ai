import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_theme.dart';
import '../utils/theme_aware_image.dart';

class OnboardingPageWidget extends StatelessWidget {
  final VoidCallback onGetStarted;

  const OnboardingPageWidget({
    super.key,
    required this.onGetStarted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  Colors.black,
                  Colors.black,
                ]
              : [
                  const Color(0xFFF8F9FA),
                  Colors.white,
                ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingXL, vertical: AppTheme.spacingM),
          child: Column(
            children: [
              SizedBox(height: AppTheme.spacingL),

              // Logo and App Name
              _buildAppHeader(context),
              SizedBox(height: AppTheme.spacingL),

              // Onboarding Image
              _buildOnboardingImage(context),

              SizedBox(height: AppTheme.spacingXL),

              // Get Started Button
              _buildGetStartedButton(context),
              SizedBox(height: AppTheme.spacingL),
            ],
          ),
        ),
      ),
    );
  }

  
  Widget _buildAppHeader(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.headlineLarge?.color ?? Colors.black;

    return Column(
      children: [
        // App Logo
        Container(
          width: 120.w,
          height: 120.w,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                blurRadius: 20,
                offset: Offset(0, 10.h),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
            child: ThemeAwareImage.build(
              context: context,
              assetPath: 'assets/onboarding/Logo.png',
              width: 120.w,
              height: 120.w,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(AppTheme.radiusL),
                  ),
                  child: Icon(
                    Icons.style,
                    size: AppTheme.iconXL,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(height: AppTheme.spacingL),

        // App Name
        Text(
          'Wardrobe.ai',
          style: TextStyle(
            fontFamily: 'Goodly',
            fontSize: AppTheme.displayLargeFontSize,
            fontWeight: FontWeight.bold,
            color: textColor,
            letterSpacing: -1,
          ),
        ),
        SizedBox(height: AppTheme.spacingS),
        Text(
          'AI-powered fashion companion',
          style: AppTheme.primaryFont.copyWith(
            fontSize: AppTheme.bodyLargeFontSize,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildOnboardingImage(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxHeight: 300.h),
      child: ThemeAwareImage.build(
        context: context,
        assetPath: 'assets/onboarding/Onboarding.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200.h,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_outlined,
                    size: AppTheme.iconXL,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                  SizedBox(height: AppTheme.spacingS),
                  Text(
                    'Onboarding image not found',
                    style: AppTheme.primaryFont.copyWith(
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      fontSize: AppTheme.bodyMediumFontSize,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGetStartedButton(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: AppTheme.buttonHeightL + 4.h,
      decoration: BoxDecoration(
        color: isDark ? Colors.white : Colors.black,
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.2),
            blurRadius: 20,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onGetStarted,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: isDark ? Colors.black : Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          'Get Started',
          style: AppTheme.primaryFont.copyWith(
            fontSize: AppTheme.titleLargeFontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  }