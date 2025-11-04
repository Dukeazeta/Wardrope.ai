import { Request, Response } from 'express';
import { Outfit, OutfitAttributes } from '../models/Outfit';
import { ClothingItem } from '../models/ClothingItem';
import { UserModel } from '../models/UserModel';
import { AWSService } from '../libs/aws';
import { GoogleImagenService } from '../libs/googleImagen';

export class OutfitController {
  /**
   * Get user's outfits
   */
  static async getUserOutfits(req: Request, res: Response): Promise<void> {
    try {
      const { userId } = req.params;
      const { limit = 20, offset = 0 } = req.query;

      if (!userId) {
        res.status(400).json({
          success: false,
          message: 'User ID is required'
        });
        return;
      }

      const outfits = await Outfit.findByUserId(userId);

      res.json({
        success: true,
        data: outfits,
        pagination: {
          limit: parseInt(limit as string),
          offset: parseInt(offset as string),
          total: outfits.length
        }
      });
    } catch (error) {
      console.error('Error getting user outfits:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Create new outfit
   */
  static async createOutfit(req: Request, res: Response): Promise<void> {
    try {
      const { userId } = req.params;
      const { name, description, clothingItemIds, modelId, tags } = req.body;

      if (!userId) {
        res.status(400).json({
          success: false,
          message: 'User ID is required'
        });
        return;
      }

      if (!name || !clothingItemIds || !Array.isArray(clothingItemIds) || clothingItemIds.length === 0) {
        res.status(400).json({
          success: false,
          message: 'Name and clothing items are required'
        });
        return;
      }

      // Verify all clothing items exist and belong to the user
      for (const itemId of clothingItemIds) {
        const item = await ClothingItem.findById(itemId);
        if (!item || item.user_id !== userId) {
          res.status(400).json({
            success: false,
            message: `Invalid clothing item: ${itemId}`
          });
          return;
        }
      }

      // Verify model if provided
      if (modelId) {
        const model = await UserModel.findById(modelId);
        if (!model || model.user_id !== userId) {
          res.status(400).json({
            success: false,
            message: 'Invalid model ID'
          });
          return;
        }
      }

      const outfitAttributes: OutfitAttributes = {
        user_id: userId,
        name,
        description,
        clothing_item_ids: clothingItemIds,
        tags: tags || [],
        is_favorite: false
      };

      const outfit = await Outfit.create(outfitAttributes);

      if (!outfit) {
        res.status(500).json({
          success: false,
          message: 'Failed to create outfit'
        });
        return;
      }

      res.status(201).json({
        success: true,
        data: outfit,
        message: 'Outfit created successfully'
      });
    } catch (error) {
      console.error('Error creating outfit:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Get specific outfit
   */
  static async getOutfit(req: Request, res: Response): Promise<void> {
    try {
      const { outfitId } = req.params;

      if (!outfitId) {
        res.status(400).json({
          success: false,
          message: 'Outfit ID is required'
        });
        return;
      }

      const outfitData = await Outfit.findById(outfitId);
      if (!outfitData) {
        res.status(404).json({
          success: false,
          message: 'Outfit not found'
        });
        return;
      }

      // Get clothing items details
      const clothingItems = [];
      for (const itemId of outfitData.clothing_item_ids) {
        const item = await ClothingItem.findById(itemId);
        if (item) {
          clothingItems.push(item);
        }
      }

      res.json({
        success: true,
        data: {
          ...outfitData,
          clothingItemsDetails: clothingItems
        }
      });
    } catch (error) {
      console.error('Error getting outfit:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Update outfit
   */
  static async updateOutfit(req: Request, res: Response): Promise<void> {
    try {
      const { outfitId } = req.params;
      const updates = req.body;

      if (!outfitId) {
        res.status(400).json({
          success: false,
          message: 'Outfit ID is required'
        });
        return;
      }

      const outfitData = await Outfit.findById(outfitId);
      if (!outfitData) {
        res.status(404).json({
          success: false,
          message: 'Outfit not found'
        });
        return;
      }

      // Update allowed fields
      const allowedFields = ['name', 'description', 'clothing_item_ids', 'tags'];
      const updateData: any = {};
      allowedFields.forEach(field => {
        if (updates[field] !== undefined) {
          updateData[field] = updates[field];
        }
      });

      const updatedOutfit = await Outfit.update(outfitId, updateData);
      if (!updatedOutfit) {
        res.status(500).json({
          success: false,
          message: 'Failed to update outfit'
        });
        return;
      }

      res.json({
        success: true,
        data: updatedOutfit,
        message: 'Outfit updated successfully'
      });
    } catch (error) {
      console.error('Error updating outfit:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Delete outfit
   */
  static async deleteOutfit(req: Request, res: Response): Promise<void> {
    try {
      const { outfitId } = req.params;

      if (!outfitId) {
        res.status(400).json({
          success: false,
          message: 'Outfit ID is required'
        });
        return;
      }

      const outfitData = await Outfit.findById(outfitId);
      if (!outfitData) {
        res.status(404).json({
          success: false,
          message: 'Outfit not found'
        });
        return;
      }

      const success = await Outfit.delete(outfitId);

      if (!success) {
        res.status(500).json({
          success: false,
          message: 'Failed to delete outfit'
        });
        return;
      }

      res.json({
        success: true,
        message: 'Outfit deleted successfully'
      });
    } catch (error) {
      console.error('Error deleting outfit:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Get favorite outfits
   */
  static async getFavoriteOutfits(req: Request, res: Response): Promise<void> {
    try {
      const { userId } = req.params;

      if (!userId) {
        res.status(400).json({
          success: false,
          message: 'User ID is required'
        });
        return;
      }

      const outfits = await Outfit.findByUserId(userId);
      const favorites = outfits.filter(outfit => outfit.is_favorite);

      res.json({
        success: true,
        data: favorites
      });
    } catch (error) {
      console.error('Error getting favorite outfits:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Toggle favorite status
   */
  static async toggleFavorite(req: Request, res: Response): Promise<void> {
    try {
      const { outfitId } = req.params;

      if (!outfitId) {
        res.status(400).json({
          success: false,
          message: 'Outfit ID is required'
        });
        return;
      }

      const outfitData = await Outfit.findById(outfitId);
      if (!outfitData) {
        res.status(404).json({
          success: false,
          message: 'Outfit not found'
        });
        return;
      }

      const updatedOutfit = await Outfit.update(outfitId, {
        is_favorite: !outfitData.is_favorite
      });

      res.json({
        success: true,
        data: updatedOutfit,
        message: `Outfit ${updatedOutfit?.is_favorite ? 'added to' : 'removed from'} favorites`
      });
    } catch (error) {
      console.error('Error toggling favorite:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Share outfit
   */
  static async shareOutfit(req: Request, res: Response): Promise<void> {
    try {
      const { outfitId } = req.params;

      if (!outfitId) {
        res.status(400).json({
          success: false,
          message: 'Outfit ID is required'
        });
        return;
      }

      const outfitData = await Outfit.findById(outfitId);
      if (!outfitData) {
        res.status(404).json({
          success: false,
          message: 'Outfit not found'
        });
        return;
      }

      // Generate share link (in production, this would create a public share record)
      const shareId = `outfit_${outfitId}_${Date.now()}`;
      const shareUrl = `${req.protocol}://${req.get('host')}/api/outfits/shared/${shareId}`;

      res.json({
        success: true,
        data: {
          shareId,
          shareUrl,
          expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000) // 7 days
        },
        message: 'Outfit share link generated'
      });
    } catch (error) {
      console.error('Error sharing outfit:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Get shared outfit
   */
  static async getSharedOutfit(req: Request, res: Response): Promise<void> {
    try {
      const { shareId } = req.params;

      // In production, this would look up the share record and return the outfit
      res.status(501).json({
        success: false,
        message: 'Shared outfit viewing not implemented yet'
      });
    } catch (error) {
      console.error('Error getting shared outfit:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Generate outfit image with user's model
   */
  static async generateOutfitImage(req: Request, res: Response): Promise<void> {
    try {
      const { userId } = req.params;
      const { outfitId, modelId, style = 'realistic', occasion = 'casual', lighting = 'natural' } = req.body;

      if (!outfitId) {
        res.status(400).json({
          success: false,
          message: 'Outfit ID is required'
        });
        return;
      }

      // Get outfit details
      const outfit = await Outfit.findById(outfitId);
      if (!outfit || outfit.user_id !== userId) {
        res.status(404).json({
          success: false,
          message: 'Outfit not found'
        });
        return;
      }

      // Get user's model (use provided modelId or get primary model)
      let userModel;
      if (modelId) {
        userModel = await UserModel.findById(modelId);
        if (!userModel || userModel.user_id !== userId) {
          res.status(404).json({
            success: false,
            message: 'Model not found'
          });
          return;
        }
      } else {
        // Get user's primary model
        const models = await UserModel.findByUserId(userId);
        userModel = models.find(model => model.is_primary);
        
        if (!userModel) {
          res.status(404).json({
            success: false,
            message: 'No user model found. Please upload a model first.'
          });
          return;
        }
      }

      // Verify model is ready for use
      if (userModel.processing_status !== 'completed') {
        res.status(400).json({
          success: false,
          message: 'User model is still processing. Please wait for completion.'
        });
        return;
      }

      // Get clothing items details
      const clothingItems = [];
      for (const itemId of outfit.clothing_item_ids) {
        const item = await ClothingItem.findById(itemId);
        if (item) {
          clothingItems.push(item);
        }
      }

      if (clothingItems.length === 0) {
        res.status(400).json({
          success: false,
          message: 'No valid clothing items found in outfit'
        });
        return;
      }

      // Check if Google Imagen is configured
      if (!GoogleImagenService.isConfigured()) {
        res.status(500).json({
          success: false,
          message: 'AI image generation service not configured'
        });
        return;
      }

      // Ensure we have a valid model image URL
      const modelImageUrl = userModel.processed_model_url || userModel.original_image_url;
      if (!modelImageUrl) {
        res.status(400).json({
          success: false,
          message: 'User model has no valid image URL'
        });
        return;
      }

      try {
        // Generate outfit visualization with user's model
        const generationResult = await GoogleImagenService.generateOutfitVisualization({
          modelImageUrl,
          clothingItems: clothingItems.map(item => ({
            id: item.id!,
            imageUrl: item.image_url || '',
            category: item.category,
            color: item.color || 'default'
          })),
          style,
          occasion,
          lighting
        });

        if (generationResult.status === 'failed') {
          res.status(500).json({
            success: false,
            message: 'Failed to generate outfit image',
            error: generationResult.metadata?.error
          });
          return;
        }

        // Save generated image URL to AWS S3 if needed
        let finalImageUrl = generationResult.imageUrl;
        if (generationResult.imageUrl && AWSService.isConfigured()) {
          try {
            // Download the generated image and save to S3 for persistence
            const response = await fetch(generationResult.imageUrl);
            const imageBuffer = await response.arrayBuffer();
            const filename = `generated-outfits/${userId}/${outfitId}_${Date.now()}.jpg`;
            finalImageUrl = await AWSService.uploadFile(Buffer.from(imageBuffer), filename, 'image/jpeg');
          } catch (saveError) {
            console.warn('Failed to save generated image to S3:', saveError);
            // Continue with original URL
          }
        }

        // Update outfit with generated image URL
        await Outfit.update(outfitId, {
          generated_image_url: finalImageUrl
        });

        res.json({
          success: true,
          data: {
            outfitId,
            generatedImageUrl: finalImageUrl,
            outfit: {
              ...outfit,
              generated_image_url: finalImageUrl
            },
            userModel: {
              id: userModel.id,
              modelType: userModel.model_type
            },
            clothingItems: clothingItems.map(item => ({
              id: item.id,
              name: item.name,
              category: item.category
            })),
            generationMetadata: {
              style,
              occasion,
              lighting,
              generatedAt: new Date().toISOString()
            }
          },
          message: 'Outfit image generated successfully showing the user wearing the outfit'
        });

      } catch (aiError) {
        console.error('AI generation error:', aiError);
        res.status(500).json({
          success: false,
          message: 'Failed to generate outfit image with AI service',
          error: aiError instanceof Error ? aiError.message : 'Unknown AI service error'
        });
      }

    } catch (error) {
      console.error('Error generating outfit image:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Generate outfit image preview (for trying on clothes before creating outfit)
   */
  static async generateOutfitImagePreview(req: Request, res: Response): Promise<void> {
    try {
      const { userId } = req.params;
      const { clothingItemIds, modelId, style = 'realistic', occasion = 'casual', lighting = 'natural' } = req.body;

      if (!userId) {
        res.status(400).json({
          success: false,
          message: 'User ID is required'
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

      // Get user's model
      let userModel;
      if (modelId) {
        userModel = await UserModel.findById(modelId);
        if (!userModel || userModel.user_id !== userId) {
          res.status(404).json({
            success: false,
            message: 'Model not found'
          });
          return;
        }
      } else {
        const models = await UserModel.findByUserId(userId);
        userModel = models.find(model => model.is_primary);
        
        if (!userModel) {
          res.status(404).json({
            success: false,
            message: 'No user model found. Please upload a model first.'
          });
          return;
        }
      }

      // Verify model is ready
      if (userModel.processing_status !== 'completed') {
        res.status(400).json({
          success: false,
          message: 'User model is still processing'
        });
        return;
      }

      // Get clothing items
      const clothingItems = [];
      for (const itemId of clothingItemIds) {
        const item = await ClothingItem.findById(itemId);
        if (!item || item.user_id !== userId) {
          res.status(400).json({
            success: false,
            message: `Invalid clothing item: ${itemId}`
          });
          return;
        }
        clothingItems.push(item);
      }

      // Check if Google Imagen is configured
      if (!GoogleImagenService.isConfigured()) {
        res.status(500).json({
          success: false,
          message: 'AI image generation service not configured'
        });
        return;
      }

      // Ensure we have valid model image URL
      const modelImageUrl = userModel.processed_model_url || userModel.original_image_url;
      if (!modelImageUrl) {
        res.status(400).json({
          success: false,
          message: 'User model has no valid image URL'
        });
        return;
      }

      try {
        // Generate preview without saving
        const generationResult = await GoogleImagenService.generateOutfitVisualization({
          modelImageUrl,
          clothingItems: clothingItems.map(item => ({
            id: item.id!,
            imageUrl: item.image_url || '',
            category: item.category,
            color: item.color || 'default'
          })),
          style,
          occasion,
          lighting
        });

        if (generationResult.status === 'failed') {
          res.status(500).json({
            success: false,
            message: 'Failed to generate outfit preview',
            error: generationResult.metadata?.error
          });
          return;
        }

        res.json({
          success: true,
          data: {
            previewImageUrl: generationResult.imageUrl,
            userModel: {
              id: userModel.id,
              modelType: userModel.model_type
            },
            clothingItems: clothingItems.map(item => ({
              id: item.id,
              name: item.name,
              category: item.category
            })),
            generationMetadata: {
              style,
              occasion,
              lighting,
              isPreview: true,
              generatedAt: new Date().toISOString()
            }
          },
          message: 'Outfit preview generated successfully'
        });

      } catch (aiError) {
        console.error('AI generation error:', aiError);
        res.status(500).json({
          success: false,
          message: 'Failed to generate outfit preview',
          error: aiError instanceof Error ? aiError.message : 'Unknown AI service error'
        });
      }

    } catch (error) {
      console.error('Error generating outfit preview:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Get outfit statistics
   */
  static async getOutfitStats(req: Request, res: Response): Promise<void> {
    try {
      const { userId } = req.params;

      if (!userId) {
        res.status(400).json({
          success: false,
          message: 'User ID is required'
        });
        return;
      }

      const outfits = await Outfit.findByUserId(userId);

      const stats = {
        totalOutfits: outfits.length,
        favorites: outfits.filter(outfit => outfit.is_favorite).length,
        recentlyCreated: outfits
          .sort((a, b) => new Date(b.created_at!).getTime() - new Date(a.created_at!).getTime())
          .slice(0, 5)
      };

      res.json({
        success: true,
        data: stats
      });
    } catch (error) {
      console.error('Error getting outfit stats:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }
}
