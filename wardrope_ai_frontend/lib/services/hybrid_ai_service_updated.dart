import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:logger/logger.dart';
import '../config/app_config.dart';

class HybridAIService {
  static final Logger _logger = Logger();

  // Use unified configuration from AppConfig
  static String get baseUrl => AppConfig.simplifiedAIBaseUrl;

  static Duration get _timeout => AppConfig.apiTimeout;

  /// Check AI service availability
  static Future<Map<String, dynamic>> checkStatus() async {
    final url = baseUrl;
    final fullUrl = '$url/status';

    try {
      _logger.i('Checking AI service status at: $fullUrl');

      // Parse URI to ensure it's valid
      final uri = Uri.parse(fullUrl);
      _logger.d('Parsed URI - Scheme: ${uri.scheme}, Host: ${uri.host}, Port: ${uri.port}, Path: ${uri.path}');

      final response = await http
          .get(uri)
          .timeout(_timeout);

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
      _logger.e('Full URL attempted: $fullUrl');
      _logger.e('Base URL: $url');

      // Provide more detailed error information
      String errorMessage = e.toString();
      if (e.toString().contains('Connection refused') || e.toString().contains('port')) {
        errorMessage += '\n\n⚠️ Troubleshooting:\n'
            '• Check if device has proxy/VPN enabled (Settings → Network)\n'
            '• Try disabling VPN/proxy temporarily\n'
            '• Ensure device has internet connectivity\n'
            '• Verify backend is accessible: https://wardrope-ai-backend.vercel.app/health';
      }

      return {
        'success': false,
        'error': errorMessage,
        'url': fullUrl,
      };
    }
  }

  /// Process user model photo for outfit fitting (local-only version)
  static Future<Map<String, dynamic>> processUserModel(
    File imageFile, {
    bool enhanceQuality = true,
    bool removeBackground = true,
    bool upscale = false,
    Function(double)? onProgress,
    Function(String)? onStatus,
  }) async {
    final url = baseUrl;
    final fullUrl = '$url/process-model';

    try {
      onStatus?.call('Preparing image...');
      onProgress?.call(0.1);

      _logger.i('Processing user model at: $fullUrl');

      // Parse URI to ensure it's valid and uses correct port
      final uri = Uri.parse(fullUrl);
      _logger.d('Parsed URI - Scheme: ${uri.scheme}, Host: ${uri.host}, Port: ${uri.port}, Path: ${uri.path}');

      // Ensure HTTPS uses port 443 explicitly if not specified
      final finalUri = uri.scheme == 'https' && uri.port == 0
          ? uri.replace(port: 443)
          : uri;

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        finalUri,
      );

      // Add image file with proper MIME type
      final imageBytes = await imageFile.readAsBytes();
      final filename = imageFile.path.split('/').last;

      // Determine MIME type from file extension
      String contentType = 'image/jpeg'; // default
      final extension = filename.toLowerCase().split('.').last;
      if (extension == 'png') {
        contentType = 'image/png';
      } else if (extension == 'jpg' || extension == 'jpeg') {
        contentType = 'image/jpeg';
      } else if (extension == 'webp') {
        contentType = 'image/webp';
      } else if (extension == 'gif') {
        contentType = 'image/gif';
      }

      _logger.d('Uploading image: $filename, Content-Type: $contentType, Size: ${imageBytes.length} bytes');

      final multipartFile = http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: filename,
        contentType: MediaType.parse(contentType),
      );
      request.files.add(multipartFile);

      // Add processing options
      request.fields['enhance_quality'] = enhanceQuality.toString();
      request.fields['remove_background'] = removeBackground.toString();
      request.fields['upscale'] = upscale.toString();
      // Request binary response instead of JSON
      request.fields['response_format'] = 'binary';

      onStatus?.call('Processing image...');
      onProgress?.call(0.3);

      // Send request and stream response
      final streamedResponse = await request.send().timeout(_timeout);

      onStatus?.call('Downloading processed image...');
      onProgress?.call(0.8);

      _logger.d('Response status: ${streamedResponse.statusCode}');
      _logger.d('Response content-type: ${streamedResponse.headers['content-type']}');

      if (streamedResponse.statusCode == 200) {
        try {
          // Check if we received JSON metadata or binary image
          final contentType = streamedResponse.headers['content-type']?.toLowerCase() ?? '';

          if (contentType.contains('application/json')) {
            // Handle JSON response (for errors or metadata)
            final response = await http.Response.fromStream(streamedResponse).timeout(_timeout);
            final data = json.decode(response.body);

            if (data['success'] == true) {
              onProgress?.call(1.0);
              onStatus?.call('Complete!');
              return {
                'success': true,
                'data': data['data'],
                'metadata': data['metadata'],
              };
            } else {
              return {
                'success': false,
                'error': data['error'] ?? data['message'] ?? 'AI processing failed',
              };
            }
          } else if (contentType.contains('image/')) {
            // Handle binary image response
            final imageBytes = await streamedResponse.stream.toBytes();
            _logger.d('Received binary image: ${imageBytes.length} bytes');

            if (imageBytes.isEmpty) {
              return {
                'success': false,
                'error': 'Received empty image from server',
              };
            }

            onProgress?.call(1.0);
            onStatus?.call('Complete!');

            return {
              'success': true,
              'data': {
                'processed_image_bytes': imageBytes,
                'content_type': contentType,
              },
              'metadata': {
                'processing_method': 'binary_stream',
                'file_size': imageBytes.length,
                'processed_at': DateTime.now().toIso8601String(),
              },
            };
          } else {
            // Unexpected content type
            final response = await http.Response.fromStream(streamedResponse).timeout(_timeout);
            _logger.e('Unexpected content-type: $contentType');
            _logger.e('Response preview: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');

            return {
              'success': false,
              'error': 'Server returned unexpected content-type: $contentType',
            };
          }
        } catch (e) {
          _logger.e('Failed to process response: $e');
          return {
            'success': false,
            'error': 'Failed to process server response: ${e.toString()}',
          };
        }
      } else {
        // Non-200 status code - try to get error details
        try {
          final response = await http.Response.fromStream(streamedResponse).timeout(_timeout);
          final errorData = json.decode(response.body);
          return {
            'success': false,
            'error': errorData['error'] ??
                      errorData['message'] ??
                      'Processing failed (${streamedResponse.statusCode})',
          };
        } catch (e) {
          return {
            'success': false,
            'error': 'Processing failed (${streamedResponse.statusCode})',
          };
        }
      }
    } catch (e) {
      _logger.e('HybridAIService Error: $e');
      _logger.e('Full URL attempted: $fullUrl');
      _logger.e('Base URL: $url');

      // Provide more detailed error information
      String errorMessage = e.toString();
      if (e.toString().contains('Connection refused') || e.toString().contains('port')) {
        errorMessage += '\n\n⚠️ Network Issue Detected:\n'
            'The device appears to be using a proxy/VPN that is interfering with HTTPS connections.\n\n'
            '🔧 Troubleshooting Steps:\n'
            '1. Disable any VPN or proxy apps on your device\n'
            '2. Check Settings → Network → Private DNS (set to "Automatic" or "Off")\n'
            '3. Try connecting to a different Wi-Fi network\n'
            '4. Restart your device\n'
            '5. Test the backend URL in Chrome: https://wardrope-ai-backend.vercel.app/health\n\n'
            'The random port numbers indicate a proxy is intercepting HTTPS traffic.';
      }

      return {
        'success': false,
        'error': errorMessage,
        'url': fullUrl,
      };
    }
  }

  /// Process clothing item for catalog management (local-only version)
  static Future<Map<String, dynamic>> processClothingItem(
    File imageFile, {
    bool removeBackground = true,
    bool enhanceQuality = true,
    bool categorize = true,
    bool extractColors = true,
    Function(double)? onProgress,
    Function(String)? onStatus,
  }) async {
    final url = baseUrl;
    final fullUrl = '$url/process-clothing';

    try {
      onStatus?.call('Preparing image...');
      onProgress?.call(0.1);

      _logger.i('Processing clothing item at: $fullUrl');

      // Parse URI to ensure it's valid and uses correct port
      final uri = Uri.parse(fullUrl);
      _logger.d('Parsed URI - Scheme: ${uri.scheme}, Host: ${uri.host}, Port: ${uri.port}, Path: ${uri.path}');

      // Ensure HTTPS uses port 443 explicitly if not specified
      final finalUri = uri.scheme == 'https' && uri.port == 0
          ? uri.replace(port: 443)
          : uri;

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        finalUri,
      );

      // Add image file with proper MIME type
      final imageBytes = await imageFile.readAsBytes();
      final filename = imageFile.path.split('/').last;

      // Determine MIME type from file extension
      String contentType = 'image/jpeg'; // default
      final extension = filename.toLowerCase().split('.').last;
      if (extension == 'png') {
        contentType = 'image/png';
      } else if (extension == 'jpg' || extension == 'jpeg') {
        contentType = 'image/jpeg';
      } else if (extension == 'webp') {
        contentType = 'image/webp';
      } else if (extension == 'gif') {
        contentType = 'image/gif';
      }

      _logger.d('Uploading image: $filename, Content-Type: $contentType, Size: ${imageBytes.length} bytes');

      final multipartFile = http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: filename,
        contentType: MediaType.parse(contentType),
      );
      request.files.add(multipartFile);

      // Add processing options
      request.fields['remove_background'] = removeBackground.toString();
      request.fields['enhance_quality'] = enhanceQuality.toString();
      request.fields['categorize'] = categorize.toString();
      request.fields['extract_colors'] = extractColors.toString();
      // Request binary response for processed image
      request.fields['response_format'] = 'binary';

      onStatus?.call('Processing image...');
      onProgress?.call(0.3);

      // Send request and stream response
      final streamedResponse = await request.send().timeout(_timeout);

      onStatus?.call('Downloading processed image...');
      onProgress?.call(0.8);

      _logger.d('Response status: ${streamedResponse.statusCode}');
      _logger.d('Response content-type: ${streamedResponse.headers['content-type']}');

      if (streamedResponse.statusCode == 200) {
        try {
          // Check if we received JSON metadata or binary image
          final contentType = streamedResponse.headers['content-type']?.toLowerCase() ?? '';

          if (contentType.contains('application/json')) {
            // Handle JSON response (for errors or metadata without image)
            final response = await http.Response.fromStream(streamedResponse).timeout(_timeout);
            final data = json.decode(response.body);

            if (data['success'] == true) {
              onProgress?.call(1.0);
              onStatus?.call('Complete!');
              return {
                'success': true,
                'data': data['data'],
                'metadata': data['metadata'],
              };
            } else {
              return {
                'success': false,
                'error': data['error'] ?? data['message'] ?? 'AI processing failed',
              };
            }
          } else if (contentType.contains('image/')) {
            // Handle binary image response
            final imageBytes = await streamedResponse.stream.toBytes();
            _logger.d('Received binary image: ${imageBytes.length} bytes');

            if (imageBytes.isEmpty) {
              return {
                'success': false,
                'error': 'Received empty image from server',
              };
            }

            onProgress?.call(1.0);
            onStatus?.call('Complete!');

            return {
              'success': true,
              'data': {
                'processed_image_bytes': imageBytes,
                'content_type': contentType,
              },
              'metadata': {
                'processing_method': 'binary_stream',
                'file_size': imageBytes.length,
                'processed_at': DateTime.now().toIso8601String(),
              },
            };
          } else {
            // Unexpected content type
            final response = await http.Response.fromStream(streamedResponse).timeout(_timeout);
            _logger.e('Unexpected content-type: $contentType');
            _logger.e('Response preview: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');

            return {
              'success': false,
              'error': 'Server returned unexpected content-type: $contentType',
            };
          }
        } catch (e) {
          _logger.e('Failed to process response: $e');
          return {
            'success': false,
            'error': 'Failed to process server response: ${e.toString()}',
          };
        }
      } else {
        // Non-200 status code - try to get error details
        try {
          final response = await http.Response.fromStream(streamedResponse).timeout(_timeout);
          final errorData = json.decode(response.body);
          return {
            'success': false,
            'error': errorData['error'] ??
                      errorData['message'] ??
                      'Processing failed (${streamedResponse.statusCode})',
          };
        } catch (e) {
          return {
            'success': false,
            'error': 'Processing failed (${streamedResponse.statusCode})',
          };
        }
      }
    } catch (e) {
      _logger.e('HybridAIService Error: $e');
      _logger.e('Full URL attempted: $fullUrl');
      _logger.e('Base URL: $url');

      // Provide more detailed error information
      String errorMessage = e.toString();
      if (e.toString().contains('Connection refused') || e.toString().contains('port')) {
        errorMessage += '\n\n⚠️ Network Issue Detected:\n'
            'The device appears to be using a proxy/VPN that is interfering with HTTPS connections.\n\n'
            '🔧 Troubleshooting Steps:\n'
            '1. Disable any VPN or proxy apps on your device\n'
            '2. Check Settings → Network → Private DNS (set to "Automatic" or "Off")\n'
            '3. Try connecting to a different Wi-Fi network\n'
            '4. Restart your device\n'
            '5. Test the backend URL in Chrome: https://wardrope-ai-backend.vercel.app/health\n\n'
            'The random port numbers indicate a proxy is intercepting HTTPS traffic.';
      }

      return {
        'success': false,
        'error': errorMessage,
        'url': fullUrl,
      };
    }
  }

  /// Generate outfit visualization (keep as JSON for now)
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
      final url = baseUrl;
      _logger.i('Generating outfit visualization at: $url/generate-outfit');
      final response = await http
          .post(
            Uri.parse('$url/generate-outfit'),
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
      final url = baseUrl;
      _logger.i('Getting style recommendations at: $url/recommendations');
      final response = await http
          .post(
            Uri.parse('$url/recommendations'),
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