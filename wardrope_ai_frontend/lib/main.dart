import 'package:flutter/material.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/model_upload_screen.dart';
import 'screens/main_container.dart';
import 'screens/add_clothing_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const WardropeApp());
}

class WardropeApp extends StatelessWidget {
  const WardropeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wardrope.ai',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (context) => const OnboardingScreen(),
            );
          case '/home':
            final imageData = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (context) => MainContainer(imageData: imageData),
            );
          case '/model-upload':
            return MaterialPageRoute(
              builder: (context) => const ModelUploadScreen(),
            );
          case '/add-clothing':
            return MaterialPageRoute(
              builder: (context) => const AddClothingScreen(),
            );
          default:
            return MaterialPageRoute(
              builder: (context) => const OnboardingScreen(),
            );
        }
      },
    );
  }
}
