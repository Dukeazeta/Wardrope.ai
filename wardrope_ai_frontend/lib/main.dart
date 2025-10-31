import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'screens/onboarding_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/main_container.dart';
import 'screens/model_upload_screen.dart';
import 'bloc/app_bloc.dart';
import 'bloc/onboarding/onboarding_bloc.dart';
import 'services/onboarding_service.dart';

void main() {
  runApp(const WardropeApp());
}

class WardropeApp extends StatelessWidget {
  const WardropeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: AppBlocProvider.providers,
      child: ScreenUtilInit(
        designSize: const Size(375, 812), // iPhone X dimensions as base
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            title: 'Wardrope.ai',
            debugShowCheckedModeBanner: false,
            home: const AppInitializer(),
            routes: {
              '/home': (context) => const MainContainer(),
              '/model': (context) => const ModelUploadScreen(),
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