import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'screens/onboarding_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/main_container.dart';
import 'screens/model_upload_screen.dart';
import 'screens/settings_screen.dart';
import 'bloc/app_bloc.dart';
import 'bloc/onboarding/onboarding_bloc.dart';
import 'services/onboarding_service.dart';
import 'services/theme_service.dart';

void main() {
  runApp(const WardrobeApp());
}

class WardrobeApp extends StatefulWidget {
  const WardrobeApp({super.key});

  @override
  State<WardrobeApp> createState() => _WardrobeAppState();
}

class _WardrobeAppState extends State<WardrobeApp> {
  final ThemeService _themeService = ThemeService();

  @override
  void initState() {
    super.initState();
    _themeService.init();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: AppBlocProvider.providers,
      child: ListenableBuilder(
        listenable: _themeService,
        builder: (context, child) {
          return ScreenUtilInit(
            designSize: const Size(375, 812), // iPhone X dimensions as base
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return MaterialApp(
                title: 'Wardrobe.ai',
                debugShowCheckedModeBanner: false,
                theme: _themeService.getLightTheme(),
                darkTheme: _themeService.getDarkTheme(),
                themeMode: _themeService.themeMode,
                home: const AppInitializer(),
                routes: {
                  '/home': (context) => const MainContainer(),
                  '/model': (context) => const ModelUploadScreen(),
                  '/settings': (context) => SettingsScreen(themeService: _themeService),
                },
              );
            },
          );
        },
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      onAnimationComplete: () => _navigateToNextScreen(),
    );
  }

  void _navigateToNextScreen() async {
    // Check if this is the first launch
    final isFirstLaunch = await OnboardingService.isFirstLaunch();
    final isModelUploadCompleted = await OnboardingService.isModelUploadCompleted();

    if (mounted) {
      if (isFirstLaunch) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const OnboardingWrapper(),
          ),
        );
      } else if (!isModelUploadCompleted) {
        Navigator.of(context).pushReplacementNamed('/model');
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainContainer(),
          ),
        );
      }
    }
  }
}

class OnboardingWrapper extends StatelessWidget {
  const OnboardingWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        // Handle onboarding completion
        if (state.status == OnboardingStatus.completed ||
            state.status == OnboardingStatus.skipped) {
          // Mark onboarding as completed
          OnboardingService.markOnboardingCompleted();

          // Navigate to main container
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const MainContainer(),
            ),
          );
        }
      },
      child: const OnboardingScreen(),
    );
  }
}