import { Request, Response } from 'express';
import { UserModel, UserModelAttributes } from '../models/UserModel';
import { ClothingItem } from '../models/ClothingItem';
import { Outfit, OutfitAttributes } from '../models/Outfit';
import { AWSService } from '../libs/aws';
import { GoogleImagenService } from '../libs/googleImagen';

export class ModelController {
  /**
   * Upload and process model image
   */
  static async uploadModel(req: Request, res: Response): Promise<void> {
    try {
      if (!req.file) {
        res.status(400).json({
          success: false,
          message: 'No model image file provided'
        });
        return;
      }

      const { userId, modelType = 'user_uploaded' } = req.body;

      if (!userId) {
        res.status(400).json({
          success: false,
          message: 'User ID is required'
        });
        return;
      }

      // Check if AWS is configured
      if (!AWSService.isConfigured()) {
        res.status(500).json({
          success: false,
          message: 'Storage service not configured'
        });
        return;
      }

      // Upload model files to AWS S3
      const { originalImageUrl, processedImageUrl, modelDataUrl } = await AWSService.uploadModelFiles(
        userId,
        req.file,
        {
          originalSize: req.file.size,
          dimensions: { width: 1080, height: 1920 },
          uploadedAt: new Date().toISOString(),
          modelType,
        }
      );

      // Create model record
      const modelAttributes: UserModelAttributes = {
        user_id: userId,
        model_type: modelType,
        original_image_url: originalImageUrl,
        processed_model_url: processedImageUrl,
        processing_status: 'completed',
        processing_progress: 100,
        is_primary: false,
        metadata: {
          originalSize: req.file.size,
          dimensions: { width: 1080, height: 1920 },
          modelDataUrl,
        }
      };

      // Check if this is the user's first model
      const existingModels = await UserModel.findByUserId(userId);
      if (existingModels.length === 0) {
        modelAttributes.is_primary = true;
      }

      const model = await UserModel.create(modelAttributes);

      if (!model) {
        res.status(500).json({
          success: false,
          message: 'Failed to save model data'
        });
        return;
      }

      res.status(201).json({
        success: true,
        data: model,
        message: 'Model uploaded and processed successfully'
      });
    } catch (error) {
      console.error('Error uploading model:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Get user's models
   */
  static async getUserModels(req: Request, res: Response): Promise<void> {
    try {
      const { userId } = req.params;

      if (!userId) {
        res.status(400).json({
          success: false,
          message: 'User ID is required'
        });
        return;
      }

      const models = await UserModel.findByUserId(userId);

      res.json({
        success: true,
        data: models
      });
    } catch (error) {
      console.error('Error getting user models:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Get primary model for user
   */
  static async getPrimaryModel(req: Request, res: Response): Promise<void> {
    try {
      const { userId } = req.params;

      if (!userId) {
        res.status(400).json({
          success: false,
          message: 'User ID is required'
        });
        return;
      }

      const models = await UserModel.findByUserId(userId);
      const primaryModel = models.find(model => model.is_primary);

      if (!primaryModel) {
        res.status(404).json({
          success: false,
          message: 'No primary model found'
        });
        return;
      }

      res.json({
        success: true,
        data: primaryModel
      });
    } catch (error) {
      console.error('Error getting primary model:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Set model as primary
   */
  static async setPrimaryModel(req: Request, res: Response): Promise<void> {
    try {
      const { userId, modelId } = req.params;

      if (!userId || !modelId) {
        res.status(400).json({
          success: false,
          message: 'User ID and Model ID are required'
        });
        return;
      }

      const modelData = await UserModel.findById(modelId);
      if (!modelData || modelData.user_id !== userId) {
        res.status(404).json({
          success: false,
          message: 'Model not found'
        });
        return;
      }

      // Unset current primary model
      await UserModel.unsetPrimary(userId);

      // Set new primary model
      const updatedModel = await UserModel.update(modelId, { is_primary: true });

      if (!updatedModel) {
        res.status(500).json({
          success: false,
          message: 'Failed to set primary model'
        });
        return;
      }

      res.json({
        success: true,
        data: updatedModel,
        message: 'Primary model set successfully'
      });
    } catch (error) {
      console.error('Error setting primary model:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Get model processing status
   */
  static async getProcessingStatus(req: Request, res: Response): Promise<void> {
    try {
      const { modelId } = req.params;

      if (!modelId) {
        res.status(400).json({
          success: false,
          message: 'Model ID is required'
        });
        return;
      }

      const modelData = await UserModel.findById(modelId);
      if (!modelData) {
        res.status(404).json({
          success: false,
          message: 'Model not found'
        });
        return;
      }

      res.json({
        success: true,
        data: {
          status: modelData.processing_status,
          progress: modelData.processing_progress,
          error_message: modelData.error_message,
          isReady: modelData.processing_status === 'completed'
        }
      });
    } catch (error) {
      console.error('Error getting processing status:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Apply outfit to model using AI generation
   */
  static async applyOutfitToModel(req: Request, res: Response): Promise<void> {
    try {
      const { modelId } = req.params;
      const { clothingItemIds, style, occasion } = req.body;

      if (!modelId) {
        res.status(400).json({
          success: false,
          message: 'Model ID is required'
        });
        return;
      }

      if (!clothingItemIds || !Array.isArray(clothingItemIds) || clothingItemIds.length === 0) {
        res.status(400).json({
          success: false,
          message: 'Clothing item IDs are required'
        });
        return;
      }

      // Verify model exists and is ready
      const modelData = await UserModel.findById(modelId);
      if (!modelData) {
        res.status(404).json({
          success: false,
          message: 'Model not found'
        });
        return;
      }

      if (modelData.processing_status !== 'completed') {
        res.status(400).json({
          success: false,
          message: 'Model is not ready for outfit application'
        });
        return;
      }

      // Get clothing items
      const clothingItems = [];
      for (const itemId of clothingItemIds) {
        const item = await ClothingItem.findById(itemId);
        if (!item) {
          res.status(404).json({
            success: false,
            message: `Clothing item not found: ${itemId}`
          });
          return;
        }
        clothingItems.push(item);
      }

      // Check if Google Imagen is configured for AI generation
      if (GoogleImagenService.isConfigured()) {
        try {
          // Ensure we have a valid model image URL
          const modelImageUrl = modelData.processed_model_url || modelData.original_image_url;
          if (!modelImageUrl) {
            throw new Error('No valid model image URL available');
          }

          // Generate outfit visualization using AI
          const imageGenResult = await GoogleImagenService.generateOutfitVisualization({
            modelImageUrl,
            clothingItems: clothingItems.map(item => ({
              id: item.id!,
              imageUrl: item.image_url || '',
              category: item.category,
              color: item.color || 'default'
            })),
            style: style || 'casual',
            occasion: occasion || 'daily',
            lighting: 'natural'
          });

          if (imageGenResult.status === 'completed') {
            // Create outfit record with generated image
            const outfitAttributes: OutfitAttributes = {
              user_id: modelData.user_id,
              name: `AI Generated Outfit - ${new Date().toLocaleDateString()}`,
              description: `AI-generated outfit featuring ${clothingItems.map(item => item.name).join(', ')}`,
              clothing_item_ids: clothingItemIds,
              is_favorite: false,
              tags: [style || 'ai-generated'],
              generated_image_url: imageGenResult.imageUrl
            };

            const outfit = await Outfit.create(outfitAttributes);

            if (outfit) {
              res.json({
                success: true,
                data: {
                  outfit,
                  generatedImage: imageGenResult.imageUrl,
                  model: modelData,
                  clothingItems
                },
                message: 'Outfit applied to model successfully with AI generation'
              });
              return;
            }
          }
        } catch (aiError) {
          console.error('AI generation failed, falling back to basic outfit creation:', aiError);
        }
      }

      // Fallback: Create basic outfit without AI generation
      const outfitAttributes: OutfitAttributes = {
        user_id: modelData.user_id,
        name: `Outfit - ${new Date().toLocaleDateString()}`,
        description: `Outfit featuring ${clothingItems.map(item => item.name).join(', ')}`,
        clothing_item_ids: clothingItemIds,
        is_favorite: false,
        tags: [style || 'manual']
      };

      const outfit = await Outfit.create(outfitAttributes);

      if (!outfit) {
        res.status(500).json({
          success: false,
          message: 'Failed to create outfit'
        });
        return;
      }

      res.json({
        success: true,
        data: {
          outfit,
          model: modelData,
          clothingItems,
          note: 'Basic outfit created. AI generation not available.'
        },
        message: 'Outfit applied to model successfully'
      });
    } catch (error) {
      console.error('Error applying outfit to model:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Delete model
   */
  static async deleteModel(req: Request, res: Response): Promise<void> {
    try {
      const { modelId } = req.params;

      if (!modelId) {
        res.status(400).json({
          success: false,
          message: 'Model ID is required'
        });
        return;
      }

      const modelData = await UserModel.findById(modelId);
      if (!modelData) {
        res.status(404).json({
          success: false,
          message: 'Model not found'
        });
        return;
      }

      // Delete associated images from AWS S3
      try {
        if (modelData.original_image_url) {
          await AWSService.deleteFile(modelData.original_image_url);
        }

        if (modelData.processed_model_url) {
          await AWSService.deleteFile(modelData.processed_model_url);
        }
      } catch (deleteError) {
        console.warn('Failed to delete model images from S3:', deleteError);
      }

      // Delete model record
      const success = await UserModel.delete(modelId);

      if (!success) {
        res.status(500).json({
          success: false,
          message: 'Failed to delete model'
        });
        return;
      }

      res.json({
        success: true,
        message: 'Model deleted successfully'
      });
    } catch (error) {
      console.error('Error deleting model:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Regenerate model (reprocess existing image)
   */
  static async regenerateModel(req: Request, res: Response): Promise<void> {
    try {
      const { modelId } = req.params;

      if (!modelId) {
        res.status(400).json({
          success: false,
          message: 'Model ID is required'
        });
        return;
      }

      const modelData = await UserModel.findById(modelId);
      if (!modelData) {
        res.status(404).json({
          success: false,
          message: 'Model not found'
        });
        return;
      }

      // Update processing status
      const updatedModel = await UserModel.update(modelId, {
        processing_status: 'processing',
        processing_progress: 0
      });

      // In a real implementation, this would trigger background processing
      // For now, we'll simulate completion
      setTimeout(async () => {
        await UserModel.update(modelId, {
          processing_status: 'completed',
          processing_progress: 100
        });
      }, 5000);

      res.json({
        success: true,
        data: updatedModel,
        message: 'Model regeneration started'
      });
    } catch (error) {
      console.error('Error regenerating model:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Get processing progress
   */
  static async getProcessingProgress(req: Request, res: Response): Promise<void> {
    try {
      const { modelId } = req.params;

      if (!modelId) {
        res.status(400).json({
          success: false,
          message: 'Model ID is required'
        });
        return;
      }

      const modelData = await UserModel.findById(modelId);
      if (!modelData) {
        res.status(404).json({
          success: false,
          message: 'Model not found'
        });
        return;
      }

      res.json({
        success: true,
        data: {
          progress: modelData.processing_progress,
          status: modelData.processing_status,
          eta: modelData.processing_status === 'processing' ? '2-3 minutes' : null
        }
      });
    } catch (error) {
      console.error('Error getting processing progress:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }
}
