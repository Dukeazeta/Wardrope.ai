import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _modelUploadCompletedKey = 'model_upload_completed';
  static bool _hasCheckedOnboarding = false;
  static bool _isFirstLaunch = true;
  static bool _hasCheckedModelUpload = false;
  static bool _isModelUploadCompleted = true;

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

  static Future<bool> isModelUploadCompleted() async {
    if (_hasCheckedModelUpload) {
      return _isModelUploadCompleted;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      _isModelUploadCompleted = prefs.getBool(_modelUploadCompletedKey) ?? false;
      _hasCheckedModelUpload = true;
      return _isModelUploadCompleted;
    } catch (e) {
      // If SharedPreferences fails, assume model upload not completed
      _isModelUploadCompleted = false;
      _hasCheckedModelUpload = true;
      return _isModelUploadCompleted;
    }
  }

  static Future<void> markModelUploadCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_modelUploadCompletedKey, true);
    } catch (e) {
      // Continue with in-memory state even if persistence fails
    }
    _isModelUploadCompleted = true;
  }

  static Future<void> resetModelUpload() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_modelUploadCompletedKey);
    } catch (e) {
      // SharedPreferences failed, continue with in-memory state
    }
    _isModelUploadCompleted = false;
  }
}