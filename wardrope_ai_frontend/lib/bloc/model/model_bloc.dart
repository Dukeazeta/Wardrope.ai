import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../services/local_storage_service.dart';
import '../../services/image_processing_service.dart';
import '../../services/hybrid_ai_service.dart';

part 'model_event.dart';
part 'model_state.dart';

class ModelBloc extends Bloc<ModelEvent, ModelState> {
  String? _currentUserId;

  ModelBloc() : super(const ModelState()) {
    on<ModelLoadRequested>(_onModelLoadRequested);
    on<ModelUploadRequested>(_onModelUploadRequested);
    on<ModelUploadFromGallery>(_onModelUploadFromGallery);
    on<ModelUploadFromCamera>(_onModelUploadFromCamera);
    on<ModelSetCurrent>(_onModelSetCurrent);
    on<ModelDeleteRequested>(_onModelDeleteRequested);
    on<OutfitApplicationRequested>(_onOutfitApplicationRequested);
    on<OutfitClearRequested>(_onOutfitClearRequested);
    on<ModelStatusCheckRequested>(_onModelStatusCheckRequested);
    on<ModelRefresh>(_onModelRefresh);
  }

  Future<void> _onModelLoadRequested(
    ModelLoadRequested event,
    Emitter<ModelState> emit,
  ) async {
    _currentUserId = event.userId;
    emit(state.copyWith(
      status: ModelStatus.loading,
      clearErrorMessage: true,
    ));

    try {
      // Load models from local storage
      final result = await LocalStorageService.getUserModels();

      if (result['success']) {
        final models = result['data'];
        final userModels = models.map((model) => ModelData.fromJson(model)).toList();

        emit(state.copyWith(
          status: ModelStatus.loaded,
          userModels: userModels,
          currentModel: userModels.isNotEmpty ? userModels.first : null,
        ));
      } else {
        emit(state.copyWith(
          status: ModelStatus.error,
          errorMessage: 'Failed to load models: ${result['error']}',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ModelStatus.error,
        errorMessage: 'Unexpected error: ${e.toString()}',
      ));
    }
  }

  Future<void> _onModelUploadRequested(
    ModelUploadRequested event,
    Emitter<ModelState> emit,
  ) async {
    emit(state.copyWith(
      status: ModelStatus.uploading,
      clearErrorMessage: true,
    ));

    try {
      // Process model with hybrid service
      final result = await ImageProcessingService.processModelComplete(
        imageFile: event.imageFile,
        name: event.modelType == 'user' ? 'User Model' : 'Generated Model',
        modelType: event.modelType,
        onProgress: (progress) {
          // You could emit progress state here if needed
        },
        onStatus: (status) {
          // You could emit status updates here if needed
        },
      );

      if (result['success']) {
        final modelData = result['data']['user_model'];
        final newModel = ModelData.fromJson(modelData);

        final updatedModels = [...state.userModels, newModel];

        emit(state.copyWith(
          status: ModelStatus.loaded,
          userModels: updatedModels,
          currentModel: newModel,
          currentOutfitImage: null, // Clear any existing outfit
        ));
      } else {
        emit(state.copyWith(
          status: ModelStatus.error,
          errorMessage: 'Failed to process model: ${result['error']}',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ModelStatus.error,
        errorMessage: 'Unexpected error: ${e.toString()}',
      ));
    }
  }

  void _onModelUploadFromGallery(
    ModelUploadFromGallery event,
    Emitter<ModelState> emit,
  ) {
    add(ModelUploadRequested(
      imageFile: event.imageFile,
      userId: event.userId,
      modelType: 'user',
    ));
  }

  void _onModelUploadFromCamera(
    ModelUploadFromCamera event,
    Emitter<ModelState> emit,
  ) {
    add(ModelUploadRequested(
      imageFile: event.imageFile,
      userId: event.userId,
      modelType: 'user',
    ));
  }

  void _onModelSetCurrent(
    ModelSetCurrent event,
    Emitter<ModelState> emit,
  ) {
    emit(state.copyWith(
      currentModel: event.model,
      currentOutfitImage: null, // Clear outfit when switching models
    ));
  }

  Future<void> _onModelDeleteRequested(
    ModelDeleteRequested event,
    Emitter<ModelState> emit,
  ) async {
    try {
      // Delete from local storage
      final result = await LocalStorageService.deleteUserModel(event.modelId);

      if (result['success']) {
        // Remove from current state
        final updatedModels = state.userModels
            .where((model) => model.id != event.modelId)
            .toList();

        final ModelData? newCurrentModel =
            state.currentModel?.id == event.modelId
                ? (updatedModels.isNotEmpty ? updatedModels.first : null)
                : state.currentModel;

        emit(state.copyWith(
          status: ModelStatus.loaded,
          userModels: updatedModels,
          currentModel: newCurrentModel,
          currentOutfitImage: null,
        ));
      } else {
        emit(state.copyWith(
          status: ModelStatus.error,
          errorMessage: 'Failed to delete model: ${result['error']}',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ModelStatus.error,
        errorMessage: 'Unexpected error: ${e.toString()}',
      ));
    }
  }

  Future<void> _onOutfitApplicationRequested(
    OutfitApplicationRequested event,
    Emitter<ModelState> emit,
  ) async {
    if (state.currentModel == null) {
      emit(state.copyWith(
        status: ModelStatus.error,
        errorMessage: 'No model selected for outfit application',
      ));
      return;
    }

    emit(state.copyWith(
      isProcessingOutfit: true,
      clearErrorMessage: true,
    ));

    try {
      // Create outfit using hybrid service
      final result = await ImageProcessingService.createOutfitWithVisualization(
        name: 'Quick Outfit',
        occasion: 'Casual',
        style: 'Everyday',
        clothingItemIds: [event.clothingItemId],
        modelImage: File(state.currentModel!.originalImageUrl),
        description: 'Outfit created with model fitting',
        onProgress: (progress) {
          // Progress updates could be handled here
        },
        onStatus: (status) {
          // Status updates could be handled here
        },
      );

      if (result['success']) {
        final outfitData = result['data']['outfit'];
        final visualizationUrl = result['data']['visualization']?['visualization_url'];

        emit(state.copyWith(
          isProcessingOutfit: false,
          currentOutfitImage: visualizationUrl ?? 'outfit_created.jpg',
          outfitMetadata: {
            'processed': true,
            'outfit_id': outfitData['id'],
            'created_at': DateTime.now().toIso8601String(),
          },
        ));
      } else {
        emit(state.copyWith(
          isProcessingOutfit: false,
          status: ModelStatus.error,
          errorMessage: 'Failed to create outfit: ${result['error']}',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isProcessingOutfit: false,
        status: ModelStatus.error,
        errorMessage: 'Outfit application failed: ${e.toString()}',
      ));
    }
  }

  Future<void> _onOutfitClearRequested(
    OutfitClearRequested event,
    Emitter<ModelState> emit,
  ) async {
    emit(state.copyWith(
      currentOutfitImage: null,
      outfitMetadata: null,
    ));
  }

  Future<void> _onModelStatusCheckRequested(
    ModelStatusCheckRequested event,
    Emitter<ModelState> emit,
  ) async {
    try {
      // Check hybrid AI service status
      final result = await HybridAIService.checkStatus();

      if (result['success']) {
        // Service is available, could emit status if needed
        emit(state.copyWith(
          status: ModelStatus.loaded,
        ));
      } else {
        emit(state.copyWith(
          status: ModelStatus.error,
          errorMessage: 'AI service unavailable: ${result['error']}',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ModelStatus.error,
        errorMessage: 'Service check failed: ${e.toString()}',
      ));
    }
  }

  void _onModelRefresh(
    ModelRefresh event,
    Emitter<ModelState> emit,
  ) {
    add(ModelLoadRequested(event.userId));
  }

  // Helper method to get current user ID
  String? get currentUserId => _currentUserId;

  // Helper method to check if user has any models
  bool get hasUserModels => state.userModels.isNotEmpty;

  // Helper method to get processed models only
  List<ModelData> get processedModels =>
      state.userModels.where((model) => model.isProcessed).toList();
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