import 'package:flutter/material.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/model_upload_screen.dart';
import 'screens/wardrobe_screen.dart';
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
      routes: {
        '/': (context) => const OnboardingScreen(),
        '/home': (context) => const HomeScreen(),
        '/model-upload': (context) => const ModelUploadScreen(),
        '/wardrobe': (context) => const WardrobeScreen(),
        '/add-clothing': (context) => const AddClothingScreen(),
      },
    );
  }
}
