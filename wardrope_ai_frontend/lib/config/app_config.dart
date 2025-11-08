import 'dart:io';
import 'package:flutter/foundation.dart';

class AppConfig {
  // Environment configuration
  // Set to true for local development, false for production
  static const bool _isDevelopment = false;

  // Development URLs (for local testing)
  static const String _devSimplifiedAIBaseUrl = 'http://10.100.179.172:3000/api/simplified-ai';
  static const String _devLocalStorageBaseUrl = 'http://10.100.179.172:3000/api/local';

  // Production URLs (Vercel deployment)
  static const String _prodSimplifiedAIBaseUrl = 'https://wardrope-ai-backend.vercel.app/api/simplified-ai';
  static const String _prodLocalStorageBaseUrl = 'https://wardrope-ai-backend.vercel.app/api/local';

  // Get base URL for Simplified AI service
  static String get simplifiedAIBaseUrl {
    if (_isDevelopment) {
      // In development, detect platform for Android emulator support
      if (defaultTargetPlatform == TargetPlatform.android) {
        // For Android emulator, use 10.0.2.2 which maps to host's localhost
        // For physical device, use the local IP (update this to your machine's IP)
        return 'http://10.100.179.172:3000/api/simplified-ai';
      }
      return _devSimplifiedAIBaseUrl;
    }
    return _prodSimplifiedAIBaseUrl;
  }

  // Get base URL for Local Storage service
  static String get localStorageBaseUrl {
    if (_isDevelopment) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        return 'http://10.100.179.172:3000/api/local';
      }
      return _devLocalStorageBaseUrl;
    }
    return _prodLocalStorageBaseUrl;
  }

  // Legacy getter for backward compatibility
  static String get baseUrl => simplifiedAIBaseUrl;

  // Environment helpers
  static bool get isDevelopment => _isDevelopment;
  static bool get isProduction => !_isDevelopment;

  // App info
  static const String appName = 'Wardrope.ai';
  static const String appVersion = '1.0.0';

  // API timeout
  static const Duration apiTimeout = Duration(seconds: 120);

  // Feature flags
  static const bool enableDebugMode = true;
  static const bool enableLogging = true;
}