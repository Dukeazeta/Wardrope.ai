import { Request, Response } from 'express';
import { GoogleImagenService, ImageGenerationRequest } from '../libs/googleImagen';

export class ImageGenerationController {
  /**
   * Generate image using Google Imagen
   */
  static async generateImage(req: Request, res: Response): Promise<void> {
    try {
      const { prompt, negativePrompt, aspectRatio, style, guidanceScale } = req.body;

      if (!prompt) {
        res.status(400).json({
          success: false,
          message: 'Prompt is required'
        });
        return;
      }

      const request: ImageGenerationRequest = {
        prompt,
        negativePrompt,
        aspectRatio,
        style,
        guidanceScale
      };

      const result = await GoogleImagenService.generateImage(request);

      if (result.status === 'failed') {
        res.status(500).json({
          success: false,
          message: 'Image generation failed',
          error: result.metadata?.error
        });
        return;
      }

      res.json({
        success: true,
        data: result,
        message: 'Image generated successfully'
      });
    } catch (error) {
      console.error('Error in image generation:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Generate outfit visualization
   */
  static async generateOutfitVisualization(req: Request, res: Response): Promise<void> {
    try {
      const { modelImageUrl, clothingItems, style, occasion, lighting } = req.body;

      if (!modelImageUrl || !clothingItems || !Array.isArray(clothingItems)) {
        res.status(400).json({
          success: false,
          message: 'Model image URL and clothing items are required'
        });
        return;
      }

      const result = await GoogleImagenService.generateOutfitVisualization({
        modelImageUrl,
        clothingItems,
        style,
        occasion,
        lighting
      });

      if (result.status === 'failed') {
        res.status(500).json({
          success: false,
          message: 'Outfit visualization generation failed',
          error: result.metadata?.error
        });
        return;
      }

      res.json({
        success: true,
        data: result,
        message: 'Outfit visualization generated successfully'
      });
    } catch (error) {
      console.error('Error in outfit visualization:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Generate clothing variations
   */
  static async generateClothingVariations(req: Request, res: Response): Promise<void> {
    try {
      const { originalClothingUrl, variations } = req.body;

      if (!originalClothingUrl || !variations || !Array.isArray(variations)) {
        res.status(400).json({
          success: false,
          message: 'Original clothing URL and variations array are required'
        });
        return;
      }

      const results = await GoogleImagenService.generateClothingVariations(
        originalClothingUrl,
        variations
      );

      res.json({
        success: true,
        data: results,
        message: 'Clothing variations generated successfully'
      });
    } catch (error) {
      console.error('Error in clothing variations:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Generate style recommendations
   */
  static async generateStyleRecommendations(req: Request, res: Response): Promise<void> {
    try {
      const { userPreferences, count = 3 } = req.body;

      if (!userPreferences || typeof userPreferences !== 'object') {
        res.status(400).json({
          success: false,
          message: 'User preferences object is required'
        });
        return;
      }

      const results = await GoogleImagenService.generateStyleRecommendations(
        userPreferences,
        count
      );

      res.json({
        success: true,
        data: results,
        message: 'Style recommendations generated successfully'
      });
    } catch (error) {
      console.error('Error in style recommendations:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Get image generation service status
   */
  static async getServiceStatus(req: Request, res: Response): Promise<void> {
    try {
      const status = GoogleImagenService.getServiceStatus();

      res.json({
        success: true,
        data: status,
        message: 'Service status retrieved successfully'
      });
    } catch (error) {
      console.error('Error getting service status:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }
}
