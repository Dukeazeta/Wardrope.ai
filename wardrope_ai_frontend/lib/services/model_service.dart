import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ModelService {
  static const String baseUrl = 'http://localhost:3000/api';
  static const Duration timeout = Duration(minutes: 5);

  // Model data structure
  static const String modelTypeUser = 'user';
  static const String modelTypeAiGenerated = 'ai_generated';

  // Upload and process model image
  static Future<Map<String, dynamic>> uploadModel({
    required File imageFile,
    String? userId,
    String modelType = modelTypeUser,
  }) async {
    try {
      // Create a multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/model/upload'),
      );

      // Add form fields
      if (userId != null) {
        request.fields['userId'] = userId;
      }
      request.fields['modelType'] = modelType;

      // Add the image file
      final imageBytes = await imageFile.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'modelImage',
        imageBytes,
        filename: 'model_${DateTime.now().millisecondsSinceEpoch}.${imageFile.path.split('.').last}',
      );
      request.files.add(multipartFile);

      // Send the request
      final streamedResponse = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse).timeout(timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to upload model: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error uploading model: $e');
    }
  }

  // Get user's models
  static Future<Map<String, dynamic>> getUserModels(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/model/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get user models: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting user models: $e');
    }
  }

  // Apply outfit to model
  static Future<Map<String, dynamic>> applyOutfitToModel({
    required String modelId,
    required String clothingItemId,
    Map<String, dynamic>? outfitData,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/model/apply-outfit'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'modelId': modelId,
          'clothingItemId': clothingItemId,
          'outfitData': outfitData,
        }),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to apply outfit: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error applying outfit to model: $e');
    }
  }

  // Delete a model
  static Future<Map<String, dynamic>> deleteModel(String modelId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/model/$modelId'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to delete model: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting model: $e');
    }
  }

  // Check model processing service status
  static Future<Map<String, dynamic>> checkServiceStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/model/status'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Model service unavailable: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error checking model service status: $e');
    }
  }

  // Save base64 image to file (for processed images)
  static Future<File> saveBase64ImageToFile(String base64Data, String filename) async {
    try {
      // Extract base64 data from data URL if needed
      String pureBase64 = extractBase64FromDataUrl(base64Data);

      // Decode base64 to bytes
      final imageBytes = base64.decode(pureBase64);

      // Create temporary file
      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/$filename');
      await file.writeAsBytes(imageBytes);

      return file;
    } catch (e) {
      throw Exception('Error saving base64 image to file: $e');
    }
  }

  // Extract base64 data from data URL
  static String extractBase64FromDataUrl(String dataUrl) {
    final RegExp regExp = RegExp(r'data:image/[^;]+;base64,(.+)');
    final match = regExp.firstMatch(dataUrl);
    return match?.group(1) ?? '';
  }

  // Get MIME type from data URL
  static String getDataUrlMimeType(String dataUrl) {
    final RegExp regExp = RegExp(r'data:([^;]+);base64,');
    final match = regExp.firstMatch(dataUrl);
    return match?.group(1) ?? 'image/jpeg';
  }

  // Convert file to base64 data URL
  static Future<String> fileToBase64DataUrl(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final base64String = base64.encode(bytes);
      final mimeType = _getMimeType(file.path);
      return 'data:$mimeType;base64,$base64String';
    } catch (e) {
      throw Exception('Error converting file to base64: $e');
    }
  }

  // Get MIME type from file extension
  static String _getMimeType(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}

// Model data class for better type safety
class ModelData {
  final String id;
  final String? userId;
  final String originalImageUrl;
  final String? processedImageUrl;
  final String modelType;
  final String status;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  ModelData({
    required this.id,
    this.userId,
    required this.originalImageUrl,
    this.processedImageUrl,
    required this.modelType,
    required this.status,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ModelData.fromJson(Map<String, dynamic> json) {
    return ModelData(
      id: json['id'],
      userId: json['userId'],
      originalImageUrl: json['originalImageUrl'],
      processedImageUrl: json['processedImageUrl'],
      modelType: json['modelType'],
      status: json['status'],
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'originalImageUrl': originalImageUrl,
      'processedImageUrl': processedImageUrl,
      'modelType': modelType,
      'status': status,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isProcessed => status == 'completed' && processedImageUrl != null;
  bool get isProcessing => status == 'processing';
  bool get hasFailed => status == 'failed';
}

// Outfit application request class
class OutfitApplicationRequest {
  final String modelId;
  final String clothingItemId;
  final Map<String, dynamic>? outfitData;

  OutfitApplicationRequest({
    required this.modelId,
    required this.clothingItemId,
    this.outfitData,
  });

  Map<String, dynamic> toJson() {
    return {
      'modelId': modelId,
      'clothingItemId': clothingItemId,
      'outfitData': outfitData,
    };
  }
}