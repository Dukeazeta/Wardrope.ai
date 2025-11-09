import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_theme.dart';
<<<<<<< HEAD
import '../utils/theme_aware_image.dart';
=======
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19

class OnboardingPageWidget extends StatelessWidget {
  final VoidCallback onGetStarted;

  const OnboardingPageWidget({
    super.key,
    required this.onGetStarted,
  });

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
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
=======
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF8F9FA),
            Colors.white,
          ],
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingXL, vertical: AppTheme.spacingM),
          child: Column(
            children: [
              SizedBox(height: AppTheme.spacingL),

              // Logo and App Name
<<<<<<< HEAD
              _buildAppHeader(context),
              SizedBox(height: AppTheme.spacingL),

              // Onboarding Image
              _buildOnboardingImage(context),
=======
              _buildAppHeader(),
              SizedBox(height: AppTheme.spacingL),

              // Onboarding Image
              _buildOnboardingImage(),
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19

              SizedBox(height: AppTheme.spacingXL),

              // Get Started Button
<<<<<<< HEAD
              _buildGetStartedButton(context),
=======
              _buildGetStartedButton(),
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
              SizedBox(height: AppTheme.spacingL),
            ],
          ),
        ),
      ),
    );
  }

  
<<<<<<< HEAD
  Widget _buildAppHeader(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.headlineLarge?.color ?? Colors.black;

=======
  Widget _buildAppHeader() {
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
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
<<<<<<< HEAD
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
=======
                color: Colors.black.withValues(alpha: 0.1),
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                blurRadius: 20,
                offset: Offset(0, 10.h),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
<<<<<<< HEAD
            child: ThemeAwareImage.build(
              context: context,
              assetPath: 'assets/onboarding/Logo.png',
=======
            child: Image.asset(
              'assets/onboarding/Logo.png',
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
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
<<<<<<< HEAD
          'Wardrobe.ai',
          style: TextStyle(
            fontFamily: 'Goodly',
            fontSize: AppTheme.displayLargeFontSize,
            fontWeight: FontWeight.bold,
            color: textColor,
=======
          'Wardrope.ai',
          style: TextStyle(
            fontSize: AppTheme.displayLargeFontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
            letterSpacing: -1,
          ),
        ),
        SizedBox(height: AppTheme.spacingS),
        Text(
          'AI-powered fashion companion',
<<<<<<< HEAD
          style: AppTheme.primaryFont.copyWith(
            fontSize: AppTheme.bodyLargeFontSize,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
=======
          style: TextStyle(
            fontSize: AppTheme.bodyLargeFontSize,
            color: Colors.grey.shade600,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

<<<<<<< HEAD
  Widget _buildOnboardingImage(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxHeight: 300.h),
      child: ThemeAwareImage.build(
        context: context,
        assetPath: 'assets/onboarding/Onboarding.png',
=======
  Widget _buildOnboardingImage() {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxHeight: 300.h),
      child: Image.asset(
        'assets/onboarding/Onboarding.png',
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200.h,
            decoration: BoxDecoration(
<<<<<<< HEAD
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.05),
=======
              color: Colors.black.withValues(alpha: 0.05),
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_outlined,
                    size: AppTheme.iconXL,
<<<<<<< HEAD
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
=======
                    color: Colors.grey,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                  ),
                  SizedBox(height: AppTheme.spacingS),
                  Text(
                    'Onboarding image not found',
<<<<<<< HEAD
                    style: AppTheme.primaryFont.copyWith(
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
=======
                    style: TextStyle(
                      color: Colors.grey,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
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

<<<<<<< HEAD
  Widget _buildGetStartedButton(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

=======
  Widget _buildGetStartedButton() {
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
    return Container(
      width: double.infinity,
      height: AppTheme.buttonHeightL + 4.h,
      decoration: BoxDecoration(
<<<<<<< HEAD
        color: isDark ? Colors.white : Colors.black,
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.2),
=======
        color: Colors.black,
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
            blurRadius: 20,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onGetStarted,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
<<<<<<< HEAD
          foregroundColor: isDark ? Colors.black : Colors.white,
=======
          foregroundColor: Colors.white,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          'Get Started',
<<<<<<< HEAD
          style: AppTheme.primaryFont.copyWith(
=======
          style: TextStyle(
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
            fontSize: AppTheme.titleLargeFontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  }