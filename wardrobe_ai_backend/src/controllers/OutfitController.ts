/**
   * Generate outfit image for existing outfit (without updating outfit record)
   */
  static async generateOutfitImagePreview(req: Request, res: Response): Promise<void> {
    try {
      const { userId } = req.params;
      const { clothingItemIds, modelId, style = 'realistic', occasion = 'casual', lighting = 'natural' } = req.body;

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

      try {
        // Generate preview without saving
        const generationResult = await GoogleImagenService.generateOutfitVisualization({
          modelImageUrl: userModel.processed_model_url || userModel.original_image_url,
          clothingItems: clothingItems.map(item => ({
            id: item.id!,
            imageUrl: item.image_url,
            category: item.category,
            color: item.color || 'default',
            name: item.name
          })),
          style,
          occasion,
          lighting,
          userPrompt: `Generate a realistic preview image of the person wearing: ${clothingItems.map(item => `${item.name} (${item.category})`).join(', ')}`
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
   * Generate outfit images for multiple outfits in batch
   */
  static async generateOutfitImagesBatch(req: Request, res: Response): Promise<void> {
    try {
      const { userId } = req.params;
      const { outfits, modelId, style = 'realistic', occasion = 'casual', lighting = 'natural' } = req.body;

      if (!outfits || !Array.isArray(outfits) || outfits.length === 0) {
        res.status(400).json({
          success: false,
          message: 'Outfits data is required'
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

      // Process each outfit for image generation
      const generatedImages = [];
      for (const outfit of outfits) {
        const { clothingItemIds } = outfit;

        if (!clothingItemIds || !Array.isArray(clothingItemIds) || clothingItemIds.length === 0) {
          res.status(400).json({
            success: false,
            message: 'Clothing item IDs are required for each outfit'
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

        // Generate image for the outfit
        try {
          const generationResult = await GoogleImagenService.generateOutfitVisualization({
            modelImageUrl: userModel.processed_model_url || userModel.original_image_url,
            clothingItems: clothingItems.map(item => ({
              id: item.id!,
              imageUrl: item.image_url,
              category: item.category,
              color: item.color || 'default',
              name: item.name
            })),
            style,
            occasion,
            lighting,
            userPrompt: `Generate a realistic image of the person wearing: ${clothingItems.map(item => `${item.name} (${item.category})`).join(', ')}`
          });

          if (generationResult.status === 'failed') {
            res.status(500).json({
              success: false,
              message: 'Failed to generate outfit image',
              error: generationResult.metadata?.error
            });
            return;
          }

          generatedImages.push({
            previewImageUrl: generationResult.imageUrl,
            clothingItems: clothingItems.map(item => ({
              id: item.id,
              name: item.name,
              category: item.category
            })),
            generationMetadata: {
              style,
              occasion,
              lighting,
              isPreview: false,
              generatedAt: new Date().toISOString()
            }
          });

        } catch (aiError) {
          console.error('AI generation error for outfit:', outfit, aiError);
          res.status(500).json({
            success: false,
            message: 'Failed to generate outfit image',
            error: aiError instanceof Error ? aiError.message : 'Unknown AI service error'
          });
          return;
        }
      }

      res.json({
        success: true,
        data: {
          generatedImages,
          userModel: {
            id: userModel.id,
            modelType: userModel.model_type
          }
        },
        message: 'Outfit images generated successfully'
      });

    } catch (error) {
      console.error('Error generating outfit images batch:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // ...existing code...