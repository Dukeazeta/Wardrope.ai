import 'dart:io';
import 'package:flutter/foundation.dart';
import 'hybrid_ai_service.dart';
import 'local_storage_service.dart';
import 'image_processing_service.dart';
import 'outfit_generation_service.dart';

class HybridDemo {
  /// Run complete demo of hybrid architecture
  static Future<Map<String, dynamic>> runCompleteDemo({
    Function(String)? onLog,
    Function(double)? onProgress,
  }) async {
    onLog?.call('🚀 Starting Hybrid Architecture Demo...\n');
    onProgress?.call(0.0);

    final results = <String, dynamic>{};

    try {
      // Step 1: Check AI Service Status
      onLog?.call('📊 Step 1: Checking AI Service Status...');
      final aiStatus = await HybridAIService.checkStatus();
      results['ai_status'] = aiStatus;

      if (aiStatus['success']) {
        onLog?.call('✅ AI Service is operational');
      } else {
        onLog?.call('❌ AI Service is not available: ${aiStatus['error']}');
        return {
          'success': false,
          'error': 'AI Service not available',
          'results': results,
        };
      }
      onProgress?.call(0.1);

      // Step 2: Get User Profile
      onLog?.call('\n👤 Step 2: Getting User Profile...');
      final userProfile = await LocalStorageService.getUserProfile();
      results['user_profile'] = userProfile;

      if (userProfile['success']) {
        onLog?.call('✅ User profile loaded successfully');
      } else {
        onLog?.call('⚠️ User profile creation may be needed');
      }
      onProgress?.call(0.15);

      // Step 3: Get Wardrobe Statistics
      onLog?.call('\n📈 Step 3: Getting Wardrobe Statistics...');
      final wardrobeStats = await LocalStorageService.getWardrobeStats();
      results['wardrobe_stats'] = wardrobeStats;

      if (wardrobeStats['success']) {
        final stats = wardrobeStats['data'];
        onLog?.call('✅ Wardrobe stats loaded:');
        onLog?.call('   - Clothing items: ${stats['total_clothing_items']}');
        onLog?.call('   - Outfits: ${stats['total_outfits']}');
        onLog?.call('   - Models: ${stats['total_models']}');
      }
      onProgress?.call(0.2);

      // Step 4: Get User Models
      onLog?.call('\n👥 Step 4: Getting User Models...');
      final userModels = await LocalStorageService.getUserModels();
      results['user_models'] = userModels;

      if (userModels['success'] && userModels['data'].isNotEmpty) {
        onLog?.call('✅ Found ${userModels['data'].length} user models');
      } else {
        onLog?.call('ℹ️ No user models found - this is normal for first-time use');
      }
      onProgress?.call(0.25);

      // Step 5: Get Clothing Items
      onLog?.call('\n👔 Step 5: Getting Clothing Items...');
      final clothingItems = await LocalStorageService.getClothingItems();
      results['clothing_items'] = clothingItems;

      if (clothingItems['success']) {
        onLog?.call('✅ Found ${clothingItems['data'].length} clothing items');

        if (clothingItems['data'].isNotEmpty) {
          final categories = <String, int>{};
          for (final item in clothingItems['data']) {
            final category = item['category'];
            categories[category] = (categories[category] ?? 0) + 1;
          }
          onLog?.call('   Categories: ${categories.entries.map((e) => '${e.key}(${e.value})').join(', ')}');
        }
      }
      onProgress?.call(0.3);

      // Step 6: Test Style Recommendations (if we have items)
      if (clothingItems['success'] && clothingItems['data'].isNotEmpty) {
        onLog?.call('\n🎨 Step 6: Testing Style Recommendations...');

        final recommendations = await OutfitGenerationService.generateStyleRecommendations(
          count: 3,
          onProgress: (progress) {
            onProgress?.call(0.3 + (progress * 0.2)); // 0.3 to 0.5
          },
          onStatus: (status) {
            onLog?.call('   $status');
          },
        );
        results['style_recommendations'] = recommendations;

        if (recommendations['success']) {
          onLog?.call('✅ Style recommendations generated successfully');
          final recs = recommendations['data']['recommendations'];
          if (recs['recommendations'] != null) {
            onLog?.call('   Generated ${recs['recommendations'].length} recommendations');
          }
        } else {
          onLog?.call('⚠️ Style recommendations failed: ${recommendations['error']}');
        }
      } else {
        onLog?.call('\n🎨 Step 6: Skipping Style Recommendations (no items)');
        results['style_recommendations'] = {'success': false, 'error': 'No clothing items available'};
      }
      onProgress?.call(0.5);

      // Step 7: Test Wardrobe Combinations (if we have items)
      if (clothingItems['success'] && clothingItems['data'].length >= 2) {
        onLog?.call('\n🔀 Step 7: Testing Wardrobe Combinations...');

        final combinations = await OutfitGenerationService.generateWardrobeCombinations(
          maxCombinations: 3,
          onProgress: (progress) {
            onProgress?.call(0.5 + (progress * 0.2)); // 0.5 to 0.7
          },
          onStatus: (status) {
            onLog?.call('   $status');
          },
        );
        results['wardrobe_combinations'] = combinations;

        if (combinations['success']) {
          final combos = combinations['data']['combinations'];
          onLog?.call('✅ Generated ${combos.length} wardrobe combinations');
        } else {
          onLog?.call('⚠️ Wardrobe combinations failed: ${combinations['error']}');
        }
      } else {
        onLog?.call('\n🔀 Step 7: Skipping Wardrobe Combinations (insufficient items)');
        results['wardrobe_combinations'] = {'success': false, 'error': 'Insufficient clothing items'};
      }
      onProgress?.call(0.7);

      // Step 8: Get Existing Outfits
      onLog?.call('\n👗 Step 8: Getting Existing Outfits...');
      final outfits = await LocalStorageService.getOutfits();
      results['outfits'] = outfits;

      if (outfits['success']) {
        onLog?.call('✅ Found ${outfits['data'].length} outfits');

        if (outfits['data'].isNotEmpty) {
          final occasions = <String, int>{};
          for (final outfit in outfits['data']) {
            final occasion = outfit['occasion'];
            occasions[occasion] = (occasions[occasion] ?? 0) + 1;
          }
          onLog?.call('   Occasions: ${occasions.entries.map((e) => '${e.key}(${e.value})').join(', ')}');
        }
      }
      onProgress?.call(0.8);

      // Step 9: Test Weather-Based Suggestions
      onLog?.call('\n🌤️ Step 9: Testing Weather-Based Suggestions...');

      final weatherSuggestions = await OutfitGenerationService.getWeatherBasedSuggestions(
        temperature: 'mild',
        condition: 'sunny',
        onProgress: (progress) {
          onProgress?.call(0.8 + (progress * 0.1)); // 0.8 to 0.9
        },
        onStatus: (status) {
          onLog?.call('   $status');
        },
      );
      results['weather_suggestions'] = weatherSuggestions;

      if (weatherSuggestions['success']) {
        final combos = weatherSuggestions['data']['combinations'];
        onLog?.call('✅ Generated ${combos.length} weather-based suggestions');
      } else {
        onLog?.call('⚠️ Weather suggestions failed: ${weatherSuggestions['error']}');
      }
      onProgress?.call(0.9);

      // Step 10: Final Summary
      onLog?.call('\n📊 Step 10: Generating Final Summary...');

      final summary = {
        'demo_completed_at': DateTime.now().toIso8601String(),
        'ai_service_available': aiStatus['success'],
        'user_profile_loaded': userProfile['success'],
        'wardrobe_stats_loaded': wardrobeStats['success'],
        'clothing_items_count': clothingItems['success'] ? clothingItems['data'].length : 0,
        'outfits_count': outfits['success'] ? outfits['data'].length : 0,
        'user_models_count': userModels['success'] ? userModels['data'].length : 0,
        'style_recommendations_generated': results['style_recommendations']['success'] ?? false,
        'wardrobe_combinations_generated': results['wardrobe_combinations']['success'] ?? false,
        'weather_suggestions_generated': weatherSuggestions['success'],
        'overall_health_score': _calculateHealthScore(results),
      };

      results['summary'] = summary;
      onProgress?.call(1.0);

      onLog?.call('\n🎉 Hybrid Architecture Demo Complete!');
      onLog?.call('📊 Overall Health Score: ${summary['overall_health_score']}/100');

      if (summary['overall_health_score'] >= 80) {
        onLog?.call('🟢 System is operating optimally!');
      } else if (summary['overall_health_score'] >= 60) {
        onLog?.call('🟡 System is functional but could be improved');
      } else {
        onLog?.call('🔴 System needs attention');
      }

      return {
        'success': true,
        'data': results,
      };

    } catch (e) {
      onLog?.call('\n❌ Demo failed with error: $e');
      return {
        'success': false,
        'error': e.toString(),
        'results': results,
      };
    }
  }

  /// Calculate system health score based on test results
  static int _calculateHealthScore(Map<String, dynamic> results) {
    int score = 0;
    final checks = {
      'ai_status': 25, // AI service is critical
      'user_profile': 15, // User management is important
      'wardrobe_stats': 10, // Statistics are useful
      'clothing_items': 10, // Need at least some items
      'style_recommendations': 15, // AI features are valuable
      'wardrobe_combinations': 15, // Core functionality
      'weather_suggestions': 10, // Additional features
    };

    for (final entry in checks.entries) {
      if (results.containsKey(entry.key)) {
        final result = results[entry.key];
        if (result is Map && result['success'] == true) {
          score += entry.value;
        }
      }
    }

    // Bonus points for having data
    if (results['clothing_items']?['success'] == true &&
        results['clothing_items']?['data']?.isNotEmpty == true) {
      score += 5;
    }

    if (results['outfits']?['success'] == true &&
        results['outfits']?['data']?.isNotEmpty == true) {
      score += 5;
    }

    return score.clamp(0, 100);
  }

  /// Quick health check
  static Future<Map<String, dynamic>> quickHealthCheck() async {
    final checks = <String, bool>{};

    // Check AI service
    try {
      final aiStatus = await HybridAIService.checkStatus();
      checks['ai_service'] = aiStatus['success'];
    } catch (e) {
      checks['ai_service'] = false;
    }

    // Check local storage
    try {
      final profile = await LocalStorageService.getUserProfile();
      checks['local_storage'] = profile['success'];
    } catch (e) {
      checks['local_storage'] = false;
    }

    // Check database connectivity
    try {
      final stats = await LocalStorageService.getWardrobeStats();
      checks['database'] = stats['success'];
    } catch (e) {
      checks['database'] = false;
    }

    final passedChecks = checks.values.where((v) => v).length;
    final totalChecks = checks.length;
    final healthScore = (passedChecks / totalChecks * 100).round();

    return {
      'success': true,
      'data': {
        'checks': checks,
        'health_score': healthScore,
        'status': healthScore >= 80 ? 'healthy' : healthScore >= 60 ? 'warning' : 'critical',
        'checked_at': DateTime.now().toIso8601String(),
      },
    };
  }

  /// Test image processing with a sample image (if available)
  static Future<Map<String, dynamic>> testImageProcessing(File? testImage) async {
    if (testImage == null) {
      return {
        'success': false,
        'error': 'No test image provided',
      };
    }

    try {
      final result = await ImageProcessingService.processClothingItemComplete(
        imageFile: testImage,
        name: 'Test Item',
        category: 'Shirt',
        style: 'casual',
        color: 'blue',
        onProgress: (progress) {
          debugPrint('Image processing progress: ${(progress * 100).toInt()}%');
        },
        onStatus: (status) {
          debugPrint('Image processing status: $status');
        },
      );

      return result;
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}