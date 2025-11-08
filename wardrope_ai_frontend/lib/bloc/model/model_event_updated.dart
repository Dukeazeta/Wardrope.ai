import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class ModelEvent extends Equatable {
  const ModelEvent();

  @override
  List<Object?> get props => [];
}

class ModelLoadRequested extends ModelEvent {
  final String userId;

  const ModelLoadRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

class ModelUploadRequested extends ModelEvent {
  final File imageFile;
  final String? userId;
  final String modelType;

  const ModelUploadRequested({
    required this.imageFile,
    this.userId,
    this.modelType = 'user',
  });

  @override
  List<Object?> get props => [imageFile, userId, modelType];
}

class ModelUploadFromGallery extends ModelEvent {
  final File imageFile;
  final String? userId;

  const ModelUploadFromGallery({
    required this.imageFile,
    this.userId,
  });

  @override
  List<Object?> get props => [imageFile, userId];
}

class ModelUploadFromCamera extends ModelEvent {
  final File imageFile;
  final String? userId;

  const ModelUploadFromCamera({
    required this.imageFile,
    this.userId,
  });

  @override
  List<Object?> get props => [imageFile, userId];
}

class ModelSetCurrent extends ModelEvent {
  final ModelData model;

  const ModelSetCurrent(this.model);

  @override
  List<Object?> get props => [model];
}

class ModelDeleteRequested extends ModelEvent {
  final String modelId;

  const ModelDeleteRequested(this.modelId);

  @override
  List<Object?> get props => [modelId];
}

class OutfitApplicationRequested extends ModelEvent {
  final String modelId;
  final String clothingItemId;
  final Map<String, dynamic>? outfitData;

  const OutfitApplicationRequested({
    required this.modelId,
    required this.clothingItemId,
    this.outfitData,
  });

  @override
  List<Object?> get props => [modelId, clothingItemId, outfitData];
}

class OutfitClearRequested extends ModelEvent {}

class ModelStatusCheckRequested extends ModelEvent {}

class ModelRefresh extends ModelEvent {
  final String userId;

  const ModelRefresh(this.userId);

  @override
  List<Object?> get props => [userId];
}

// Model data class (moved here for dependency resolution)
class ModelData extends Equatable {
  final String id;
  final String? userId;
  final String originalImageUrl;
  final String? processedImageUrl;
  final String modelType;
  final String status;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ModelData({
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
    // Handle both snake_case (backend) and camelCase (frontend) field names
    final id = json['id']?.toString() ?? '';
    final userId = json['userId'] ?? json['user_id'];
    final originalImageUrl = json['originalImageUrl'] ?? json['original_image_url'] ?? '';
    final processedImageUrl = json['processedImageUrl'] ?? json['processed_image_url'];
    final modelType = json['modelType'] ?? json['model_type'] ?? 'user';
    final status = json['status'] ?? json['processing_status'] ?? 'pending';
    final metadata = json['metadata'] as Map<String, dynamic>?;

    // Parse dates - handle both ISO strings and DateTime objects
    DateTime createdAt;
    DateTime updatedAt;

    try {
      if (json['createdAt'] is String) {
        createdAt = DateTime.parse(json['createdAt']);
      } else if (json['created_at'] is String) {
        createdAt = DateTime.parse(json['created_at']);
      } else if (json['createdAt'] is DateTime) {
        createdAt = json['createdAt'] as DateTime;
      } else if (json['created_at'] is DateTime) {
        createdAt = json['created_at'] as DateTime;
      } else {
        createdAt = DateTime.now();
      }
    } catch (e) {
      createdAt = DateTime.now();
    }

    try {
      if (json['updatedAt'] is String) {
        updatedAt = DateTime.parse(json['updatedAt']);
      } else if (json['updated_at'] is String) {
        updatedAt = DateTime.parse(json['updated_at']);
      } else if (json['updatedAt'] is DateTime) {
        updatedAt = json['updatedAt'] as DateTime;
      } else if (json['updated_at'] is DateTime) {
        updatedAt = json['updated_at'] as DateTime;
      } else {
        updatedAt = DateTime.now();
      }
    } catch (e) {
      updatedAt = DateTime.now();
    }

    return ModelData(
      id: id,
      userId: userId?.toString(),
      originalImageUrl: originalImageUrl,
      processedImageUrl: processedImageUrl?.toString(),
      modelType: modelType,
      status: status,
      metadata: metadata,
      createdAt: createdAt,
      updatedAt: updatedAt,
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

  /// Check if this model uses local-only storage
  bool get isLocalOnly {
    final meta = metadata;
    return meta != null && (meta['local_only'] == true || meta['no_cloud_storage'] == true);
  }

  /// Get display information about storage
  String get storageInfo {
    if (isLocalOnly) {
      return 'Stored locally on device';
    } else if (processedImageUrl != null && processedImageUrl!.startsWith('http')) {
      return 'Stored in cloud';
    } else {
      return 'Stored locally';
    }
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        originalImageUrl,
        processedImageUrl,
        modelType,
        status,
        metadata,
        createdAt,
        updatedAt,
      ];
}