import 'dart:io';
import 'hybrid_ai_service.dart';
import 'local_storage_service.dart';

class ImageProcessingService {
  /// Complete clothing item processing pipeline
  static Future<Map<String, dynamic>> processClothingItemComplete({
    required File imageFile,
    required String name,
    required String category,
    required String style,
    String? color,
    String? material,
    String? size,
    String? brand,
    Function(double)? onProgress,
    Function(String)? onStatus,
  }) async {
    try {
      onStatus?.call('Starting processing...');
      onProgress?.call(0.05);

      // Step 1: Process image with AI
      onStatus?.call('Processing image with AI...');
      final aiResult = await HybridAIService.processClothingItem(
        imageFile,
        enhanceQuality: true,
        removeBackground: true,
        categorize: true,
        extractColors: true,
        onProgress: (progress) {
          onProgress?.call(0.05 + (progress * 0.3)); // 0.05 to 0.35
        },
        onStatus: (status) {
          onStatus?.call('AI Processing: $status');
        },
      );

      if (!aiResult['success']) {
        return {
          'success': false,
          'error': 'AI processing failed: ${aiResult['error']}',
        };
      }

      onProgress?.call(0.4);
      onStatus?.call('Extracting information...');

      // Step 2: Extract AI results
      final aiData = aiResult['data'];
      final processedImageUrl = aiData['processed_image_url'] ?? imageFile.path;
      final detectedCategory = aiData['category'] ?? category;
      final detectedStyle = aiData['style'] ?? style;
      final detectedColors = List<String>.from(aiData['colors'] ?? [color ?? 'unknown']);
      final detectedMaterial = aiData['material'] ?? material;
      final qualityScore = aiData['quality_score'];

      onProgress?.call(0.5);
      onStatus?.call('Saving to local storage...');

      // Step 3: Save to local storage
      final saveResult = await LocalStorageService.createClothingItem(
        name: name,
        category: detectedCategory,
        style: detectedStyle,
        colors: detectedColors,
        material: detectedMaterial,
        size: size,
        brand: brand,
        originalImageUrl: imageFile.path,
        processedImageUrl: processedImageUrl,
        metadata: {
          'ai_processed': true,
          'ai_data': aiData,
          'original_category': category,
          'original_style': style,
          'processing_date': DateTime.now().toIso8601String(),
        },
        qualityScore: qualityScore,
      );

      onProgress?.call(0.9);
      onStatus?.call('Finalizing...');

      if (!saveResult['success']) {
        return {
          'success': false,
          'error': 'Failed to save clothing item: ${saveResult['error']}',
        };
      }

      onProgress?.call(1.0);
      onStatus?.call('Complete!');

      return {
        'success': true,
        'data': {
          'clothing_item': saveResult['data'],
          'ai_data': aiData,
          'processing_summary': {
            'detected_category': detectedCategory,
            'detected_style': detectedStyle,
            'detected_colors': detectedColors,
            'detected_material': detectedMaterial,
            'quality_score': qualityScore,
          }
        },
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Complete model processing pipeline
  static Future<Map<String, dynamic>> processModelComplete({
    required File imageFile,
    required String name,
    String modelType = 'user',
    Function(double)? onProgress,
    Function(String)? onStatus,
  }) async {
    try {
      onStatus?.call('Starting model processing...');
      onProgress?.call(0.05);

      // Step 1: Process model with AI
      onStatus?.call('Processing model with AI...');
      final aiResult = await HybridAIService.processUserModel(
        imageFile,
        enhanceQuality: true,
        removeBackground: true,
        upscale: true,
        onProgress: (progress) {
          onProgress?.call(0.05 + (progress * 0.4)); // 0.05 to 0.45
        },
        onStatus: (status) {
          onStatus?.call('AI Processing: $status');
        },
      );

      if (!aiResult['success']) {
        return {
          'success': false,
          'error': 'AI processing failed: ${aiResult['error']}',
        };
      }

      onProgress?.call(0.5);
      onStatus?.call('Saving model...');

      // Step 2: Extract AI results
      final aiData = aiResult['data'];
      final processedImageUrl = aiData['processed_image_url'] ?? imageFile.path;

      // Step 3: Save to local storage
      final saveResult = await LocalStorageService.createUserModel(
        name: name,
        originalImageUrl: imageFile.path,
        processedImageUrl: processedImageUrl,
        modelType: modelType,
        status: 'completed',
        metadata: {
          'ai_processed': true,
          'ai_data': aiData,
          'processing_date': DateTime.now().toIso8601String(),
        },
      );

      onProgress?.call(0.9);
      onStatus?.call('Finalizing...');

      if (!saveResult['success']) {
        return {
          'success': false,
          'error': 'Failed to save model: ${saveResult['error']}',
        };
      }

      onProgress?.call(1.0);
      onStatus?.call('Complete!');

      return {
        'success': true,
        'data': {
          'user_model': saveResult['data'],
          'ai_data': aiData,
        },
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Create outfit with visualization
  static Future<Map<String, dynamic>> createOutfitWithVisualization({
    required String name,
    required String occasion,
    required String style,
    required List<String> clothingItemIds,
    File? modelImage,
    String? season,
    String? colorScheme,
    String? description,
    bool isFavorite = false,
    Function(double)? onProgress,
    Function(String)? onStatus,
  }) async {
    try {
      onStatus?.call('Creating outfit...');
      onProgress?.call(0.1);

      // Get clothing items to retrieve their image paths
      final clothingItems = <Map<String, dynamic>>[];
      for (final itemId in clothingItemIds) {
        // This would typically get the full item details from local storage
        // For now, we'll assume the items are available
        clothingItems.add({
          'id': itemId,
          'image_url': 'placeholder_url', // This would come from the actual item
        });
      }

      Map<String, dynamic>? visualizationData;

      // Step 1: Generate visualization if model image is provided
      if (modelImage != null) {
        onStatus?.call('Generating outfit visualization...');

        // Convert clothing items to files (this would need actual file paths)
        final clothingFiles = <File>[];
        for (final _ in clothingItems) {
          // This would get the actual file path from the item
          // For now, we'll use a placeholder
          // clothingFiles.add(File(item['image_url']));
        }

        // Skip visualization if we don't have actual clothing files
        if (clothingFiles.isNotEmpty) {
          final vizResult = await HybridAIService.generateOutfitVisualization(
            modelImage,
            clothingFiles,
            occasion: occasion,
            style: style,
            season: season,
            colorScheme: colorScheme,
            onProgress: (progress) {
              onProgress?.call(0.1 + (progress * 0.4)); // 0.1 to 0.5
            },
            onStatus: (status) {
              onStatus?.call('Visualization: $status');
            },
          );

          if (vizResult['success']) {
            visualizationData = vizResult['data'];
          }
        }
      }

      onProgress?.call(0.6);
      onStatus?.call('Saving outfit...');

      // Step 2: Save outfit to local storage
      final saveResult = await LocalStorageService.createOutfit(
        name: name,
        description: description,
        occasion: occasion,
        style: style,
        season: season,
        clothingItemIds: clothingItemIds,
        modelImageUrl: modelImage?.path,
        visualizationUrl: visualizationData?['visualization_url'],
        metadata: {
          'ai_generated': modelImage != null,
          'visualization_data': visualizationData,
          'created_date': DateTime.now().toIso8601String(),
        },
        isFavorite: isFavorite,
      );

      onProgress?.call(0.9);
      onStatus?.call('Finalizing...');

      if (!saveResult['success']) {
        return {
          'success': false,
          'error': 'Failed to save outfit: ${saveResult['error']}',
        };
      }

      onProgress?.call(1.0);
      onStatus?.call('Complete!');

      return {
        'success': true,
        'data': {
          'outfit': saveResult['data'],
          'visualization': visualizationData,
        },
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Batch process multiple clothing items
  static Future<Map<String, dynamic>> batchProcessClothingItems({
    required List<Map<String, dynamic>> items, // Each item should have file, name, category, style
    Function(double)? onProgress,
    Function(String)? onStatus,
    Function(Map<String, dynamic>)? onItemComplete,
  }) async {
    try {
      final results = <Map<String, dynamic>>[];
      final totalItems = items.length;

      onStatus?.call('Starting batch processing...');
      onProgress?.call(0.0);

      for (int i = 0; i < totalItems; i++) {
        final item = items[i];

        onStatus?.call('Processing item ${i + 1} of $totalItems: ${item['name']}');

        final result = await processClothingItemComplete(
          imageFile: item['file'],
          name: item['name'],
          category: item['category'],
          style: item['style'],
          color: item['color'],
          material: item['material'],
          size: item['size'],
          brand: item['brand'],
          onProgress: (progress) {
            final overallProgress = (i / totalItems) + (progress / totalItems);
            onProgress?.call(overallProgress);
          },
          onStatus: (status) {
            onStatus?.call('Item ${i + 1}: $status');
          },
        );

        results.add({
          'item': item,
          'result': result,
          'index': i,
        });

        if (onItemComplete != null) {
          onItemComplete(results.last);
        }
      }

      onProgress?.call(1.0);
      onStatus?.call('Batch processing complete!');

      final successCount = results.where((r) => r['result']['success']).length;
      final failureCount = results.length - successCount;

      return {
        'success': failureCount == 0,
        'data': {
          'results': results,
          'summary': {
            'total_items': totalItems,
            'successful': successCount,
            'failed': failureCount,
            'success_rate': successCount / totalItems,
          },
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