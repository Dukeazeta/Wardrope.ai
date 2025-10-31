import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../services/model_service.dart';

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
      final response = await ModelService.getUserModels(event.userId);

      if (response['success'] == true) {
        final List<dynamic> modelsData = response['models'] ?? [];
        final List<ModelData> models = modelsData
            .map((modelJson) => ModelData.fromJson(modelJson))
            .toList();

        // Find the most recent processed model to set as current
        ModelData? currentModel;
        for (final model in models) {
          if (model.isProcessed) {
            if (currentModel == null || model.updatedAt.isAfter(currentModel.updatedAt)) {
              currentModel = model;
            }
          }
        }

        emit(state.copyWith(
          status: ModelStatus.loaded,
          userModels: models,
          currentModel: currentModel,
        ));
      } else {
        emit(state.copyWith(
          status: ModelStatus.error,
          errorMessage: response['message'] ?? 'Failed to load models',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ModelStatus.error,
        errorMessage: 'Error loading models: $e',
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
      final response = await ModelService.uploadModel(
        imageFile: event.imageFile,
        userId: event.userId,
        modelType: event.modelType,
      );

      if (response['success'] == true) {
        final Map<String, dynamic> modelDataJson = response['modelData'];
        final ModelData newModel = ModelData.fromJson(modelDataJson);

        // Update user models list
        final updatedModels = [...state.userModels, newModel];

        emit(state.copyWith(
          status: ModelStatus.loaded,
          userModels: updatedModels,
          currentModel: newModel,
          currentOutfitImage: null, // Clear any existing outfit
        ));

        // If userId was provided, refresh the models list
        if (event.userId != null) {
          add(ModelRefresh(event.userId!));
        }
      } else {
        emit(state.copyWith(
          status: ModelStatus.error,
          errorMessage: response['message'] ?? 'Failed to upload model',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ModelStatus.error,
        errorMessage: 'Error uploading model: $e',
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
      modelType: ModelService.modelTypeUser,
    ));
  }

  void _onModelUploadFromCamera(
    ModelUploadFromCamera event,
    Emitter<ModelState> emit,
  ) {
    add(ModelUploadRequested(
      imageFile: event.imageFile,
      userId: event.userId,
      modelType: ModelService.modelTypeUser,
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
      final response = await ModelService.deleteModel(event.modelId);

      if (response['success'] == true) {
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
          errorMessage: response['message'] ?? 'Failed to delete model',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ModelStatus.error,
        errorMessage: 'Error deleting model: $e',
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
      final response = await ModelService.applyOutfitToModel(
        modelId: event.modelId,
        clothingItemId: event.clothingItemId,
        outfitData: event.outfitData,
      );

      if (response['success'] == true) {
        emit(state.copyWith(
          isProcessingOutfit: false,
          currentOutfitImage: response['resultImageUrl'],
          outfitMetadata: response['metadata'],
        ));
      } else {
        emit(state.copyWith(
          status: ModelStatus.error,
          isProcessingOutfit: false,
          errorMessage: response['message'] ?? 'Failed to apply outfit',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ModelStatus.error,
        isProcessingOutfit: false,
        errorMessage: 'Error applying outfit: $e',
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
      final response = await ModelService.checkServiceStatus();

      if (response['success'] != true) {
        emit(state.copyWith(
          status: ModelStatus.error,
          errorMessage: 'Model service is unavailable',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ModelStatus.error,
        errorMessage: 'Model service check failed: $e',
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