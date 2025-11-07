class AppConfig {
  // Environment configuration
  static const bool _isDevelopment = false; // Set to false for production

  // API URLs
  static const String _developmentBaseUrl = 'http://10.100.179.172:3000/api/simplified-ai';
  static const String _productionBaseUrl = 'https://wardrope-ai-backend.vercel.app/api/simplified-ai';

  // Current base URL based on environment
  static String get baseUrl => _isDevelopment ? _developmentBaseUrl : _productionBaseUrl;

  // Environment helpers
  static bool get isDevelopment => _isDevelopment;
  static bool get isProduction => !_isDevelopment;

  // App info
  static const String appName = 'Wardrope.ai';
  static const String appVersion = '1.0.0';

  // API timeout
  static const Duration apiTimeout = Duration(seconds: 60);

  // Feature flags
  static const bool enableDebugMode = true;
  static const bool enableLogging = true;
}