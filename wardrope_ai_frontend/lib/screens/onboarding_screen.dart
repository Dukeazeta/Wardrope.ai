import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/onboarding_page.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _navigateToHome(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/model-upload');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        child: OnboardingPageWidget(
          onGetStarted: () => _navigateToHome(context),
        ),
      ),
    );
  }
}