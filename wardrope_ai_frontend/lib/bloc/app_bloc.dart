import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth/auth_bloc.dart';
import 'wardrobe/wardrobe_bloc.dart';
import 'onboarding/onboarding_bloc.dart';
import 'navigation/navigation_bloc.dart';

class AppBlocProvider {
  static final List<BlocProvider> providers = [
    BlocProvider<AuthBloc>(
      create: (context) => AuthBloc()..add(AuthStarted()),
    ),
    BlocProvider<WardrobeBloc>(
      create: (context) => WardrobeBloc(),
    ),
    BlocProvider<OnboardingBloc>(
      create: (context) => OnboardingBloc(),
    ),
    BlocProvider<NavigationBloc>(
      create: (context) => NavigationBloc(),
    ),
  ];
}