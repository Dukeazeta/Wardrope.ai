import { Request, Response } from 'express';
import { hybridAIService } from '../libs/geminiAI';
import path from 'path';
import fs from 'fs';

export class SimplifiedAIController {
  /**
   * Check AI service status
   */
  async checkStatus(req: Request, res: Response): Promise<void> {
    try {
      const aiService = hybridAIService();
      const result = await aiService.checkServiceStatus();

      if (result.success) {
        res.json({
          status: 'available',
          message: 'AI service is operational',
          data: result.data,
          timestamp: new Date().toISOString()
        });
      } else {
        res.status(503).json({
          status: 'unavailable',
          message: 'AI service is not available',
          error: result.error,
          timestamp: new Date().toISOString()
        });
      }
    } catch (error: any) {
      console.error('Error checking AI status:', error);
      res.status(500).json({
        status: 'error',
        message: 'Failed to check AI service status',
        error: error.message,
        timestamp: new Date().toISOString()
      });
    }
  }

  /**
   * Process user model photo
   */
  async processModel(req: Request, res: Response): Promise<void> {
    try {
      if (!req.file) {
        res.status(400).json({
          success: false,
          message: 'No image file provided'
        });
        return;
      }

      const options = {
        enhanceQuality: req.body.enhance_quality === 'true',
        removeBackground: req.body.remove_background === 'true',
        upscale: req.body.upscale === 'true'
      };

      const aiService = hybridAIService();
      const result = await aiService.processUserModel(req.file.path, options);

      if (result.success) {
        res.json({
          success: true,
          message: 'Model processed successfully',
          data: result.data,
          metadata: result.metadata
        });
      } else {
        res.status(400).json({
          success: false,
          message: 'Failed to process model',
          error: result.error
        });
      }
    } catch (error: any) {
      console.error('Error processing model:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error',
        error: error.message
      });
    }
  }

  /**
   * Process clothing item
   */
  async processClothing(req: Request, res: Response): Promise<void> {
    try {
      if (!req.file) {
        res.status(400).json({
          success: false,
          message: 'No image file provided'
        });
        return;
      }

      const options = {
        removeBackground: req.body.remove_background === 'true',
        enhanceQuality: req.body.enhance_quality === 'true',
        categorize: req.body.categorize === 'true',
        extractColors: req.body.extract_colors === 'true'
      };

      const aiService = hybridAIService();
      const result = await aiService.processClothingItem(req.file.path, options);

      if (result.success) {
        res.json({
          success: true,
          message: 'Clothing item processed successfully',
          data: result.data,
          metadata: result.metadata
        });
      } else {
        res.status(400).json({
          success: false,
          message: 'Failed to process clothing item',
          error: result.error
        });
      }
    } catch (error: any) {
      console.error('Error processing clothing item:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error',
        error: error.message
      });
    }
  }

  /**
   * Generate outfit visualization
   */
  async generateOutfit(req: Request, res: Response): Promise<void> {
    try {
      const { model_image_path, clothing_item_paths, options } = req.body;

      if (!model_image_path || !clothing_item_paths || !Array.isArray(clothing_item_paths)) {
        res.status(400).json({
          success: false,
          message: 'Missing required fields: model_image_path, clothing_item_paths (array)'
        });
        return;
      }

      // Validate that model image exists
      if (!fs.existsSync(model_image_path)) {
        res.status(400).json({
          success: false,
          message: 'Model image file not found'
        });
        return;
      }

      // Validate that all clothing item images exist
      for (const itemPath of clothing_item_paths) {
        if (!fs.existsSync(itemPath)) {
          res.status(400).json({
            success: false,
            message: `Clothing item image not found: ${itemPath}`
          });
          return;
        }
      }

      const aiService = hybridAIService();
      const result = await aiService.generateOutfitVisualization(
        model_image_path,
        clothing_item_paths,
        options || {}
      );

      if (result.success) {
        res.json({
          success: true,
          message: 'Outfit visualization generated successfully',
          data: result.data,
          metadata: result.metadata
        });
      } else {
        res.status(400).json({
          success: false,
          message: 'Failed to generate outfit visualization',
          error: result.error
        });
      }
    } catch (error: any) {
      console.error('Error generating outfit visualization:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error',
        error: error.message
      });
    }
  }

  /**
   * Generate style recommendations
   */
  async getRecommendations(req: Request, res: Response): Promise<void> {
    try {
      const { preferences, wardrobe_items, count } = req.body;

      if (!preferences || !wardrobe_items || !Array.isArray(wardrobe_items)) {
        res.status(400).json({
          success: false,
          message: 'Missing required fields: preferences, wardrobe_items (array)'
        });
        return;
      }

      const aiService = hybridAIService();
      const result = await aiService.generateStyleRecommendations(
        preferences,
        wardrobe_items,
        count || 5
      );

      if (result.success) {
        res.json({
          success: true,
          message: 'Style recommendations generated successfully',
          data: result.data,
          metadata: result.metadata
        });
      } else {
        res.status(400).json({
          success: false,
          message: 'Failed to generate style recommendations',
          error: result.error
        });
      }
    } catch (error: any) {
      console.error('Error generating style recommendations:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error',
        error: error.message
      });
    }
  }
}

export const simplifiedAIController = new SimplifiedAIController();