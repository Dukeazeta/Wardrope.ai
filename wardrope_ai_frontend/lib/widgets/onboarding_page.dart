import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_theme.dart';

class OnboardingPageWidget extends StatelessWidget {
  final VoidCallback onGetStarted;

  const OnboardingPageWidget({
    super.key,
    required this.onGetStarted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF8F9FA),
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
              _buildAppHeader(),
              SizedBox(height: AppTheme.spacingL),

              // Onboarding Image
              _buildOnboardingImage(),

              SizedBox(height: AppTheme.spacingXL),

              // Get Started Button
              _buildGetStartedButton(),
              SizedBox(height: AppTheme.spacingL),
            ],
          ),
        ),
      ),
    );
  }

  
  Widget _buildAppHeader() {
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
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: Offset(0, 10.h),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
            child: Image.asset(
              'assets/onboarding/Logo.png',
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
          'Wardrope.ai',
          style: TextStyle(
            fontSize: AppTheme.displayLargeFontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: -1,
          ),
        ),
        SizedBox(height: AppTheme.spacingS),
        Text(
          'AI-powered fashion companion',
          style: TextStyle(
            fontSize: AppTheme.bodyLargeFontSize,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildOnboardingImage() {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxHeight: 300.h),
      child: Image.asset(
        'assets/onboarding/Onboarding.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200.h,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_outlined,
                    size: AppTheme.iconXL,
                    color: Colors.grey,
                  ),
                  SizedBox(height: AppTheme.spacingS),
                  Text(
                    'Onboarding image not found',
                    style: TextStyle(
                      color: Colors.grey,
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

  Widget _buildGetStartedButton() {
    return Container(
      width: double.infinity,
      height: AppTheme.buttonHeightL + 4.h,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onGetStarted,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          'Get Started',
          style: TextStyle(
            fontSize: AppTheme.titleLargeFontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  }