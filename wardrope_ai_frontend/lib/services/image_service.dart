import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ImageService {
  static const String baseUrl = 'http://localhost:3000/api';
  static const Duration timeout = Duration(minutes: 5);

  static Future<Map<String, dynamic>> processImage(File imageFile) async {
    try {
      // Create a multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/image/process'),
      );

      // Add the image file
      final imageBytes = await imageFile.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: imageFile.path.split('/').last,
      );
      request.files.add(multipartFile);

      // Send the request
      final streamedResponse = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse).timeout(timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to process image: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error processing image: $e');
    }
  }

  static Future<Map<String, dynamic>> checkServiceStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/image/status'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Service unavailable: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error checking service status: $e');
    }
  }

  static String extractBase64FromDataUrl(String dataUrl) {
    // Extract base64 data from data URL
    final RegExp regExp = RegExp(r'data:image/[^;]+;base64,(.+)');
    final match = regExp.firstMatch(dataUrl);
    return match?.group(1) ?? '';
  }

  static String getDataUrlMimeType(String dataUrl) {
    // Extract MIME type from data URL
    final RegExp regExp = RegExp(r'data:([^;]+);base64,');
    final match = regExp.firstMatch(dataUrl);
    return match?.group(1) ?? 'image/jpeg';
  }
}