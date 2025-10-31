part of 'model_bloc.dart';

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
    this.modelType = ModelService.modelTypeUser,
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