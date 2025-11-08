import 'package:equatable/equatable.dart';
import 'model_event_updated.dart';

enum ModelStatus { initial, loading, loaded, error, uploading, processing }

class ModelState extends Equatable {
  final ModelStatus status;
  final ModelData? currentModel;
  final List<ModelData> userModels;
  final String? currentOutfitImage;
  final String? errorMessage;
  final bool isProcessingOutfit;
  final Map<String, dynamic>? outfitMetadata;

  const ModelState({
    this.status = ModelStatus.initial,
    this.currentModel,
    this.userModels = const [],
    this.currentOutfitImage,
    this.errorMessage,
    this.isProcessingOutfit = false,
    this.outfitMetadata,
  });

  ModelState copyWith({
    ModelStatus? status,
    ModelData? currentModel,
    List<ModelData>? userModels,
    String? currentOutfitImage,
    String? errorMessage,
    bool? isProcessingOutfit,
    Map<String, dynamic>? outfitMetadata,
    bool clearErrorMessage = false,
  }) {
    return ModelState(
      status: status ?? this.status,
      currentModel: currentModel ?? this.currentModel,
      userModels: userModels ?? this.userModels,
      currentOutfitImage: currentOutfitImage ?? this.currentOutfitImage,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      isProcessingOutfit: isProcessingOutfit ?? this.isProcessingOutfit,
      outfitMetadata: outfitMetadata ?? this.outfitMetadata,
    );
  }

  @override
  List<Object?> get props => [
        status,
        currentModel,
        userModels,
        currentOutfitImage,
        errorMessage,
        isProcessingOutfit,
        outfitMetadata,
      ];

  // Convenience getters
  bool get hasModel => currentModel != null && currentModel!.isProcessed;
  bool get isLoading => status == ModelStatus.loading || status == ModelStatus.uploading || status == ModelStatus.processing;
  bool get hasError => status == ModelStatus.error;
  bool get hasOutfit => currentOutfitImage != null;
  bool get canApplyOutfit => hasModel && !isProcessingOutfit;
}