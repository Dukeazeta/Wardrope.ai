import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class LocalStorageService {
  // Use unified configuration from AppConfig
  static String get _baseUrl => AppConfig.localStorageBaseUrl;

  static Duration get _timeout => AppConfig.apiTimeout;

  // User Management Methods

  /// Get user profile and settings
  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/user/profile'),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to get user profile (${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Update user profile
  static Future<Map<String, dynamic>> updateUserProfile({
    String? name,
    String? email,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {};
      if (name != null) requestBody['name'] = name;
      if (email != null) requestBody['email'] = email;

      final response = await http
          .put(
            Uri.parse('$_baseUrl/user/profile'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(requestBody),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to update profile (${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Update user settings
  static Future<Map<String, dynamic>> updateUserSettings(
    Map<String, dynamic> settings,
  ) async {
    try {
      final response = await http
          .put(
            Uri.parse('$_baseUrl/user/settings'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'settings': settings}),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to update settings (${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Clothing Items Methods

  /// Get all clothing items with optional filters
  static Future<Map<String, dynamic>> getClothingItems({
    String? category,
    String? style,
    String? color,
  }) async {
    try {
      final Uri uri = Uri.parse('$_baseUrl/clothing').replace(
        queryParameters: {
          if (category != null) 'category': category,
          if (style != null) 'style': style,
          if (color != null) 'color': color,
        },
      );

      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'],
          'count': data['count'],
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to get clothing items (${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Create new clothing item
  static Future<Map<String, dynamic>> createClothingItem({
    required String name,
    required String category,
    required String style,
    required List<String> colors,
    String? material,
    String? size,
    String? brand,
    required String originalImageUrl,
    String? processedImageUrl,
    Map<String, dynamic>? metadata,
    int? qualityScore,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        'name': name,
        'category': category,
        'style': style,
        'colors': colors,
        'original_image_url': originalImageUrl,
        if (processedImageUrl != null) 'processed_image_url': processedImageUrl,
        if (material != null) 'material': material,
        if (size != null) 'size': size,
        if (brand != null) 'brand': brand,
        if (metadata != null) 'metadata': metadata,
        if (qualityScore != null) 'quality_score': qualityScore,
      };

      final response = await http
          .post(
            Uri.parse('$_baseUrl/clothing'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(requestBody),
          )
          .timeout(_timeout);

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? 'Failed to create clothing item',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Update clothing item
  static Future<Map<String, dynamic>> updateClothingItem(
    String itemId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await http
          .put(
            Uri.parse('$_baseUrl/clothing/$itemId'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(updates),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? 'Failed to update clothing item',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Delete clothing item
  static Future<Map<String, dynamic>> deleteClothingItem(String itemId) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$_baseUrl/clothing/$itemId'),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? 'Failed to delete clothing item',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Outfits Methods

  /// Get all outfits with optional filters
  static Future<Map<String, dynamic>> getOutfits({
    String? occasion,
    String? style,
    String? season,
    bool? favorite,
  }) async {
    try {
      final Uri uri = Uri.parse('$_baseUrl/outfits').replace(
        queryParameters: {
          if (occasion != null) 'occasion': occasion,
          if (style != null) 'style': style,
          if (season != null) 'season': season,
          if (favorite != null) 'favorite': favorite.toString(),
        },
      );

      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'],
          'count': data['count'],
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to get outfits (${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Create new outfit
  static Future<Map<String, dynamic>> createOutfit({
    required String name,
    String? description,
    required String occasion,
    required String style,
    String? season,
    required List<String> clothingItemIds,
    String? modelImageUrl,
    String? visualizationUrl,
    Map<String, dynamic>? metadata,
    bool isFavorite = false,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        'name': name,
        'occasion': occasion,
        'style': style,
        'clothing_item_ids': clothingItemIds,
        if (description != null) 'description': description,
        if (season != null) 'season': season,
        if (modelImageUrl != null) 'model_image_url': modelImageUrl,
        if (visualizationUrl != null) 'visualization_url': visualizationUrl,
        if (metadata != null) 'metadata': metadata,
        'is_favorite': isFavorite,
      };

      final response = await http
          .post(
            Uri.parse('$_baseUrl/outfits'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(requestBody),
          )
          .timeout(_timeout);

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? 'Failed to create outfit',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Update outfit
  static Future<Map<String, dynamic>> updateOutfit(
    String outfitId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await http
          .put(
            Uri.parse('$_baseUrl/outfits/$outfitId'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(updates),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? 'Failed to update outfit',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Delete outfit
  static Future<Map<String, dynamic>> deleteOutfit(String outfitId) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$_baseUrl/outfits/$outfitId'),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? 'Failed to delete outfit',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // User Models Methods

  /// Get all user models
  static Future<Map<String, dynamic>> getUserModels() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/user-models'),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'],
          'count': data['count'],
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to get user models (${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Create new user model
  static Future<Map<String, dynamic>> createUserModel({
    required String name,
    required String originalImageUrl,
    String? processedImageUrl,
    required String modelType,
    required String status,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        'name': name,
        'original_image_url': originalImageUrl,
        'model_type': modelType,
        'status': status,
        if (processedImageUrl != null) 'processed_image_url': processedImageUrl,
        if (metadata != null) 'metadata': metadata,
      };

      final response = await http
          .post(
            Uri.parse('$_baseUrl/user-models'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(requestBody),
          )
          .timeout(_timeout);

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? 'Failed to create user model',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Update user model
  static Future<Map<String, dynamic>> updateUserModel(
    String modelId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await http
          .put(
            Uri.parse('$_baseUrl/user-models/$modelId'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(updates),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? 'Failed to update user model',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Delete user model
  static Future<Map<String, dynamic>> deleteUserModel(String modelId) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$_baseUrl/user-models/$modelId'),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? 'Failed to delete user model',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Statistics Methods

  /// Get wardrobe statistics and analytics
  static Future<Map<String, dynamic>> getWardrobeStats() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/stats/wardrobe'),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to get wardrobe stats (${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}