import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const String _onboardingCompletedKey = 'onboarding_completed';
  static bool _hasCheckedOnboarding = false;
  static bool _isFirstLaunch = true;

  static Future<bool> isFirstLaunch() async {
    if (_hasCheckedOnboarding) {
      return _isFirstLaunch;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      _isFirstLaunch = !(prefs.getBool(_onboardingCompletedKey) ?? false);
      _hasCheckedOnboarding = true;
      return _isFirstLaunch;
    } catch (e) {
      // If SharedPreferences fails, assume it's first launch and use in-memory state
      _isFirstLaunch = true;
      _hasCheckedOnboarding = true;
      return _isFirstLaunch;
    }
  }

  static Future<void> markOnboardingCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingCompletedKey, true);
    } catch (e) {
      // Continue with in-memory state even if persistence fails
    }
    _isFirstLaunch = false;
  }

  static Future<void> resetOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_onboardingCompletedKey);
    } catch (e) {
      // SharedPreferences failed, continue with in-memory state
    }
    _isFirstLaunch = true;
  }
}