import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class HybridAIService {
  static final Logger _logger = Logger();

  static Future<String> get baseUrl async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Check if running on emulator or physical device
      if (await _isRunningOnEmulator()) {
        return 'http://10.0.2.2:3000/api/simplified-ai';
      } else {
        // Physical device - use your computer's local IP address
        return 'http://10.100.179.172:3000/api/simplified-ai';
      }
    } else {
      return 'http://localhost:3000/api/simplified-ai';
    }
  }

  static Future<String> get _baseUrl async => await baseUrl;

  static Future<bool> _isRunningOnEmulator() async {
    // Check if running on Android emulator
    try {
      final result = await Process.run('getprop', ['ro.kernel.qemu']);
      return result.exitCode == 0;
    } catch (e) {
      // If we can't check, assume it's a physical device
      return false;
    }
  }

  static const Duration _timeout = Duration(seconds: 120);

  /// Check AI service availability
  static Future<Map<String, dynamic>> checkStatus() async {
    try {
      final baseUrl = await _baseUrl;
      final response = await http
          .get(
            Uri.parse('$baseUrl/status'),
          ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'error': 'Service unavailable (${response.statusCode})',
        };
      }
    } catch (e) {
      _logger.e('HybridAIService Error: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Process user model photo for outfit fitting
  static Future<Map<String, dynamic>> processUserModel(
    File imageFile, {
    bool enhanceQuality = true,
    bool removeBackground = true,
    bool upscale = false,
    Function(double)? onProgress,
    Function(String)? onStatus,
  }) async {
    try {
      onStatus?.call('Preparing image...');
      onProgress?.call(0.1);

      final baseUrl = await _baseUrl;
      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/process-model'),
      );

      // Add image file
      final imageBytes = await imageFile.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: imageFile.path.split('/').last,
      );
      request.files.add(multipartFile);

      // Add processing options
      request.fields['enhance_quality'] = enhanceQuality.toString();
      request.fields['remove_background'] = removeBackground.toString();
      request.fields['upscale'] = upscale.toString();

      onStatus?.call('Processing image...');
      onProgress?.call(0.3);

      // Send request
      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse).timeout(_timeout);

      onStatus?.call('Finalizing...');
      onProgress?.call(0.9);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        onProgress?.call(1.0);
        onStatus?.call('Complete!');

        return {
          'success': true,
          'data': data['data'],
          'metadata': data['metadata'],
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? 'Processing failed',
        };
      }
    } catch (e) {
      _logger.e('HybridAIService Error: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Process clothing item for catalog management
  static Future<Map<String, dynamic>> processClothingItem(
    File imageFile, {
    bool removeBackground = true,
    bool enhanceQuality = true,
    bool categorize = true,
    bool extractColors = true,
    Function(double)? onProgress,
    Function(String)? onStatus,
  }) async {
    try {
      onStatus?.call('Preparing image...');
      onProgress?.call(0.1);

      final baseUrl = await _baseUrl;
      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/process-clothing'),
      );

      // Add image file
      final imageBytes = await imageFile.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: imageFile.path.split('/').last,
      );
      request.files.add(multipartFile);

      // Add processing options
      request.fields['remove_background'] = removeBackground.toString();
      request.fields['enhance_quality'] = enhanceQuality.toString();
      request.fields['categorize'] = categorize.toString();
      request.fields['extract_colors'] = extractColors.toString();

      onStatus?.call('Processing image...');
      onProgress?.call(0.3);

      // Send request
      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse).timeout(_timeout);

      onStatus?.call('Finalizing...');
      onProgress?.call(0.9);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        onProgress?.call(1.0);
        onStatus?.call('Complete!');

        return {
          'success': true,
          'data': data['data'],
          'metadata': data['metadata'],
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? 'Processing failed',
        };
      }
    } catch (e) {
      _logger.e('HybridAIService Error: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Generate outfit visualization
  static Future<Map<String, dynamic>> generateOutfitVisualization(
    File modelImage,
    List<File> clothingItems, {
    String? occasion,
    String? style,
    String? season,
    String? colorScheme,
    Function(double)? onProgress,
    Function(String)? onStatus,
  }) async {
    try {
      onStatus?.call('Preparing files...');
      onProgress?.call(0.1);

      // Create request body
      final Map<String, dynamic> requestBody = {
        'model_image_path': modelImage.path,
        'clothing_item_paths': clothingItems.map((item) => item.path).toList(),
      };

      // Add options if provided
      final Map<String, dynamic> options = {};
      if (occasion != null) options['occasion'] = occasion;
      if (style != null) options['style'] = style;
      if (season != null) options['season'] = season;
      if (colorScheme != null) options['color_scheme'] = colorScheme;

      if (options.isNotEmpty) {
        requestBody['options'] = options;
      }

      onStatus?.call('Generating outfit...');
      onProgress?.call(0.3);

      // Send request
      final baseUrl = await _baseUrl;
      final response = await http
          .post(
            Uri.parse('$baseUrl/generate-outfit'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(requestBody),
          )
          .timeout(_timeout);

      onStatus?.call('Finalizing...');
      onProgress?.call(0.9);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        onProgress?.call(1.0);
        onStatus?.call('Complete!');

        return {
          'success': true,
          'data': data['data'],
          'metadata': data['metadata'],
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? 'Generation failed',
        };
      }
    } catch (e) {
      _logger.e('HybridAIService Error: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Generate style recommendations
  static Future<Map<String, dynamic>> getStyleRecommendations(
    Map<String, dynamic> preferences,
    List<Map<String, dynamic>> wardrobeItems, {
    int count = 5,
    Function(double)? onProgress,
    Function(String)? onStatus,
  }) async {
    try {
      onStatus?.call('Analyzing preferences...');
      onProgress?.call(0.2);

      // Create request body
      final Map<String, dynamic> requestBody = {
        'preferences': preferences,
        'wardrobe_items': wardrobeItems,
        'count': count,
      };

      onStatus?.call('Generating recommendations...');
      onProgress?.call(0.5);

      // Send request
      final baseUrl = await _baseUrl;
      final response = await http
          .post(
            Uri.parse('$baseUrl/recommendations'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(requestBody),
          )
          .timeout(_timeout);

      onStatus?.call('Finalizing...');
      onProgress?.call(0.9);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        onProgress?.call(1.0);
        onStatus?.call('Complete!');

        return {
          'success': true,
          'data': data['data'],
          'metadata': data['metadata'],
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? 'Recommendation failed',
        };
      }
    } catch (e) {
      _logger.e('HybridAIService Error: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}