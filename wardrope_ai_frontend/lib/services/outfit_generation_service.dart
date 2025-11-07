import 'hybrid_ai_service.dart';
import 'local_storage_service.dart';

class OutfitGenerationService {
  /// Generate style recommendations
  static Future<Map<String, dynamic>> generateStyleRecommendations({
    Map<String, dynamic>? preferences,
    int count = 5,
    Function(double)? onProgress,
    Function(String)? onStatus,
  }) async {
    try {
      onStatus?.call('Loading wardrobe data...');
      onProgress?.call(0.1);

      // Get user's wardrobe items
      final wardrobeResult = await LocalStorageService.getClothingItems();
      if (!wardrobeResult['success']) {
        return {
          'success': false,
          'error': 'Failed to load wardrobe items: ${wardrobeResult['error']}',
        };
      }

      final wardrobeItems = List<Map<String, dynamic>>.from(wardrobeResult['data']);

      // Get user preferences if not provided
      Map<String, dynamic> userPreferences = preferences ?? {};
      if (userPreferences.isEmpty) {
        onStatus?.call('Loading user preferences...');
        final userProfile = await LocalStorageService.getUserProfile();
        if (userProfile['success']) {
          userPreferences = userProfile['data']['preferences'] ?? {};
        }
      }

      onProgress?.call(0.3);
      onStatus?.call('Generating recommendations...');

      // Generate AI recommendations
      final aiResult = await HybridAIService.getStyleRecommendations(
        userPreferences,
        wardrobeItems,
        count: count,
        onProgress: (progress) {
          onProgress?.call(0.3 + (progress * 0.6)); // 0.3 to 0.9
        },
        onStatus: (status) {
          onStatus?.call('AI: $status');
        },
      );

      if (!aiResult['success']) {
        return {
          'success': false,
          'error': 'Failed to generate recommendations: ${aiResult['error']}',
        };
      }

      onProgress?.call(0.95);
      onStatus?.call('Finalizing...');

      final recommendations = aiResult['data'];

      onProgress?.call(1.0);
      onStatus?.call('Recommendations ready!');

      return {
        'success': true,
        'data': {
          'recommendations': recommendations,
          'preferences_used': userPreferences,
          'wardrobe_size': wardrobeItems.length,
          'generated_at': DateTime.now().toIso8601String(),
        },
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Generate outfit combinations from existing wardrobe
  static Future<Map<String, dynamic>> generateWardrobeCombinations({
    String? occasion,
    String? style,
    String? season,
    int maxCombinations = 10,
    Function(double)? onProgress,
    Function(String)? onStatus,
  }) async {
    try {
      onStatus?.call('Analyzing wardrobe...');
      onProgress?.call(0.1);

      // Get user's wardrobe items
      final wardrobeResult = await LocalStorageService.getClothingItems();
      if (!wardrobeResult['success']) {
        return {
          'success': false,
          'error': 'Failed to load wardrobe items: ${wardrobeResult['error']}',
        };
      }

      final wardrobeItems = List<Map<String, dynamic>>.from(wardrobeResult['data']);

      // Filter items based on criteria
      final filteredItems = wardrobeItems.where((item) {
        if (occasion != null && item['metadata']?['suitable_occasions']?.contains(occasion) == false) {
          return false;
        }
        if (style != null && item['style'] != style) {
          return false;
        }
        if (season != null && item['metadata']?['suitable_seasons']?.contains(season) == false) {
          return false;
        }
        return true;
      }).toList();

      onProgress?.call(0.3);
      onStatus?.call('Creating combinations...');

      // Group items by category
      final Map<String, List<Map<String, dynamic>>> itemsByCategory = {};
      for (final item in filteredItems) {
        final category = item['category'];
        if (!itemsByCategory.containsKey(category)) {
          itemsByCategory[category] = [];
        }
        itemsByCategory[category]!.add(item);
      }

      // Generate combinations
      final combinations = <Map<String, dynamic>>[];

      for (int i = 0; i < maxCombinations && i < 50; i++) {
        final combination = <Map<String, dynamic>>[];
        final usedCategories = <String>{};

        // Try to create a balanced outfit with items from different categories
        for (final category in ['Tops', 'Bottoms', 'Shoes', 'Outerwear']) {
          if (itemsByCategory.containsKey(category) && itemsByCategory[category]!.isNotEmpty) {
            final categoryItems = itemsByCategory[category]!;
            final randomIndex = (i + categoryItems.length) % categoryItems.length;
            combination.add(categoryItems[randomIndex]);
            usedCategories.add(category);
          }
        }

        // Add accessories if available
        if (itemsByCategory.containsKey('Accessories') && itemsByCategory['Accessories']!.isNotEmpty) {
          final accessories = itemsByCategory['Accessories']!;
          if (i % 2 == 0) { // Add accessories to every other combination
            final randomIndex = i % accessories.length;
            combination.add(accessories[randomIndex]);
          }
        }

        if (combination.length >= 2) { // Need at least 2 items for a combination
          combinations.add({
            'id': 'combo_${i + 1}',
            'items': combination,
            'occasion': occasion ?? 'casual',
            'style': style ?? 'mixed',
            'season': season,
            'item_count': combination.length,
            'categories': usedCategories.toList(),
            'generated_at': DateTime.now().toIso8601String(),
          });
        }

        onProgress?.call(0.3 + (i / maxCombinations) * 0.6); // 0.3 to 0.9
      }

      onProgress?.call(0.95);
      onStatus?.call('Finalizing combinations...');

      onProgress?.call(1.0);
      onStatus?.call('Combinations ready!');

      return {
        'success': true,
        'data': {
          'combinations': combinations,
          'wardrobe_size': wardrobeItems.length,
          'filtered_items': filteredItems.length,
          'criteria': {
            'occasion': occasion,
            'style': style,
            'season': season,
          },
          'generated_at': DateTime.now().toIso8601String(),
        },
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Save generated combination as an outfit
  static Future<Map<String, dynamic>> saveCombinationAsOutfit({
    required Map<String, dynamic> combination,
    required String name,
    String? description,
    bool isFavorite = false,
    Function(double)? onProgress,
    Function(String)? onStatus,
  }) async {
    try {
      onStatus?.call('Saving outfit...');
      onProgress?.call(0.2);

      // Extract item IDs from combination
      final clothingItemIds = <String>[];
      for (final item in combination['items']) {
        clothingItemIds.add(item['id']);
      }

      onProgress?.call(0.6);
      onStatus?.call('Creating outfit...');

      // Create outfit
      final result = await LocalStorageService.createOutfit(
        name: name,
        description: description,
        occasion: combination['occasion'] ?? 'casual',
        style: combination['style'] ?? 'mixed',
        season: combination['season'],
        clothingItemIds: clothingItemIds,
        metadata: {
          'generated_from_combination': true,
          'combination_id': combination['id'],
          'categories': combination['categories'],
          'item_count': combination['item_count'],
          'generated_at': combination['generated_at'],
        },
        isFavorite: isFavorite,
      );

      onProgress?.call(0.9);
      onStatus?.call('Finalizing...');

      if (!result['success']) {
        return {
          'success': false,
          'error': 'Failed to save outfit: ${result['error']}',
        };
      }

      onProgress?.call(1.0);
      onStatus?.call('Outfit saved!');

      return {
        'success': true,
        'data': {
          'outfit': result['data'],
          'combination': combination,
        },
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Get outfit suggestions based on weather
  static Future<Map<String, dynamic>> getWeatherBasedSuggestions({
    required String temperature, // e.g., "cold", "mild", "hot"
    String? condition, // e.g., "sunny", "rainy", "cloudy"
    Function(double)? onProgress,
    Function(String)? onStatus,
  }) async {
    try {
      onStatus?.call('Analyzing weather conditions...');
      onProgress?.call(0.1);

      // Define weather-based style rules
      final Map<String, Map<String, dynamic>> weatherRules = {
        'hot': {
          'recommended_categories': ['T-Shirts', 'Shorts', 'Dresses', 'Light Tops'],
          'avoid_categories': ['Sweaters', 'Coats', 'Heavy Jackets'],
          'recommended_materials': ['Cotton', 'Linen', 'Lightweight'],
          'colors': ['Light colors', 'White', 'Pastels'],
        },
        'cold': {
          'recommended_categories': ['Sweaters', 'Coats', 'Jackets', 'Long Sleeves'],
          'avoid_categories': ['Shorts', 'Tank Tops'],
          'recommended_materials': ['Wool', 'Fleece', 'Heavyweight'],
          'colors': ['Dark colors', 'Warm tones'],
        },
        'mild': {
          'recommended_categories': ['Shirts', 'Light Jackets', 'Cardigans'],
          'avoid_categories': [],
          'recommended_materials': ['Cotton', 'Light wool'],
          'colors': ['Any'],
        },
      };

      final rules = weatherRules[temperature] ?? weatherRules['mild']!;

      onProgress?.call(0.3);
      onStatus?.call('Finding suitable items...');

      // Get user's wardrobe items
      final wardrobeResult = await LocalStorageService.getClothingItems();
      if (!wardrobeResult['success']) {
        return {
          'success': false,
          'error': 'Failed to load wardrobe items: ${wardrobeResult['error']}',
        };
      }

      final wardrobeItems = List<Map<String, dynamic>>.from(wardrobeResult['data']);

      // Filter items based on weather rules
      final suitableItems = wardrobeItems.where((item) {
        final category = item['category'];

        // Check if category is recommended
        if (rules['recommended_categories'].contains(category)) {
          return true;
        }

        // Check if category should be avoided
        if (rules['avoid_categories'].contains(category)) {
          return false;
        }

        // Include items from neutral categories
        final neutralCategories = ['Shoes', 'Accessories', 'Bags'];
        return neutralCategories.contains(category);
      }).toList();

      onProgress?.call(0.6);
      onStatus?.call('Creating weather-appropriate combinations...');

      // Generate simple combinations
      final combinations = <Map<String, dynamic>>[];
      final tops = suitableItems.where((item) =>
        ['T-Shirts', 'Shirts', 'Sweaters', 'Tops'].contains(item['category'])
      ).toList();
      final bottoms = suitableItems.where((item) =>
        ['Pants', 'Shorts', 'Skirts'].contains(item['category'])
      ).toList();
      final shoes = suitableItems.where((item) => item['category'] == 'Shoes').toList();
      final outerwear = suitableItems.where((item) =>
        ['Jackets', 'Coats', 'Outerwear'].contains(item['category'])
      ).toList();

      // Create combinations
      for (int i = 0; i < 5; i++) {
        final combination = <Map<String, dynamic>>[];

        if (tops.isNotEmpty) {
          combination.add(tops[i % tops.length]);
        }
        if (bottoms.isNotEmpty) {
          combination.add(bottoms[i % bottoms.length]);
        }
        if (shoes.isNotEmpty) {
          combination.add(shoes[i % shoes.length]);
        }
        if (outerwear.isNotEmpty && temperature == 'cold') {
          combination.add(outerwear[i % outerwear.length]);
        }

        if (combination.length >= 2) {
          combinations.add({
            'id': 'weather_combo_${i + 1}',
            'items': combination,
            'temperature': temperature,
            'condition': condition,
            'weather_rules': rules,
            'item_count': combination.length,
            'generated_at': DateTime.now().toIso8601String(),
          });
        }
      }

      onProgress?.call(0.95);
      onStatus?.call('Finalizing suggestions...');

      onProgress?.call(1.0);
      onStatus?.call('Weather suggestions ready!');

      return {
        'success': true,
        'data': {
          'combinations': combinations,
          'weather_rules': rules,
          'temperature': temperature,
          'condition': condition,
          'suitable_items_count': suitableItems.length,
          'total_items': wardrobeItems.length,
          'generated_at': DateTime.now().toIso8601String(),
        },
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}