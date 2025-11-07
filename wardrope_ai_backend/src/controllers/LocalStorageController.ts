import { Request, Response } from 'express';
import { hybridSQLiteService } from '../libs/sqlite';

export class LocalStorageController {
  /**
   * Get user profile and settings
   */
  async getUserProfile(req: Request, res: Response): Promise<void> {
    try {
      // For hybrid architecture, we use a default user ID
      const userId = 'default_user';

      const user = await hybridSQLiteService.getUser(userId);

      if (user) {
        res.json({
          success: true,
          data: {
            id: user.id,
            name: user.name,
            email: user.email,
            preferences: user.preferences,
            settings: user.settings,
            created_at: user.created_at,
            updated_at: user.updated_at
          }
        });
      } else {
        // Create default user if not exists
        const userData: any = {
          name: 'User',
          preferences: {
            style: ['casual', 'formal'],
            colors: ['blue', 'black', 'white'],
            sizes: ['M', 'L'],
            brands: [],
            budget_range: 'moderate'
          },
          settings: {
            theme: 'light',
            notifications: true,
            auto_backup: false,
            language: 'en'
          }
        };

        const defaultUser = await hybridSQLiteService.createUser(userData);

        res.json({
          success: true,
          data: {
            id: defaultUser.id,
            name: defaultUser.name,
            email: defaultUser.email,
            preferences: defaultUser.preferences,
            settings: defaultUser.settings,
            created_at: defaultUser.created_at,
            updated_at: defaultUser.updated_at
          }
        });
      }
    } catch (error: any) {
      console.error('Error getting user profile:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get user profile',
        error: error.message
      });
    }
  }

  /**
   * Update user profile
   */
  async updateUserProfile(req: Request, res: Response): Promise<void> {
    try {
      const { name, email } = req.body;
      const userId = 'default_user';

      const updatedUser = await hybridSQLiteService.updateUser(userId, {
        name,
        email
      });

      if (updatedUser) {
        res.json({
          success: true,
          message: 'User profile updated successfully',
          data: {
            id: updatedUser.id,
            name: updatedUser.name,
            email: updatedUser.email,
            preferences: updatedUser.preferences,
            settings: updatedUser.settings,
            updated_at: updatedUser.updated_at
          }
        });
      } else {
        res.status(404).json({
          success: false,
          message: 'User not found'
        });
      }
    } catch (error: any) {
      console.error('Error updating user profile:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to update user profile',
        error: error.message
      });
    }
  }

  /**
   * Update user settings
   */
  async updateUserSettings(req: Request, res: Response): Promise<void> {
    try {
      const { settings } = req.body;
      const userId = 'default_user';

      if (!settings) {
        res.status(400).json({
          success: false,
          message: 'Settings data is required'
        });
        return;
      }

      const updatedUser = await hybridSQLiteService.updateUser(userId, {
        settings
      });

      if (updatedUser) {
        res.json({
          success: true,
          message: 'User settings updated successfully',
          data: {
            settings: updatedUser.settings,
            updated_at: updatedUser.updated_at
          }
        });
      } else {
        res.status(404).json({
          success: false,
          message: 'User not found'
        });
      }
    } catch (error: any) {
      console.error('Error updating user settings:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to update user settings',
        error: error.message
      });
    }
  }

  /**
   * Get all clothing items
   */
  async getClothingItems(req: Request, res: Response): Promise<void> {
    try {
      const userId = 'default_user';
      const { category, style, color } = req.query;

      const filters: any = {};
      if (category) filters.category = category as string;
      if (style) filters.style = style as string;
      if (color) filters.color = color as string;

      const items = await hybridSQLiteService.getClothingItems(userId, filters);

      res.json({
        success: true,
        data: items,
        count: items.length
      });
    } catch (error: any) {
      console.error('Error getting clothing items:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get clothing items',
        error: error.message
      });
    }
  }

  /**
   * Create new clothing item
   */
  async createClothingItem(req: Request, res: Response): Promise<void> {
    try {
      const {
        name,
        category,
        style,
        colors,
        material,
        size,
        brand,
        original_image_url,
        processed_image_url,
        metadata,
        quality_score
      } = req.body;

      if (!name || !category || !style || !colors || !original_image_url) {
        res.status(400).json({
          success: false,
          message: 'Missing required fields: name, category, style, colors, original_image_url'
        });
        return;
      }

      const userId = 'default_user';

      const itemData: any = {
        user_id: userId,
        name,
        category,
        style,
        colors: Array.isArray(colors) ? colors : [colors],
        material,
        size,
        brand,
        original_image_url,
        processed_image_url,
        metadata: metadata || {},
      };

      if (quality_score !== undefined) {
        itemData.quality_score = parseInt(quality_score);
      }

      const newItem = await hybridSQLiteService.createClothingItem(itemData);

      res.status(201).json({
        success: true,
        message: 'Clothing item created successfully',
        data: newItem
      });
    } catch (error: any) {
      console.error('Error creating clothing item:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to create clothing item',
        error: error.message
      });
    }
  }

  /**
   * Update clothing item
   */
  async updateClothingItem(req: Request, res: Response): Promise<void> {
    try {
      const { id } = req.params;
      const updates = req.body;

      if (!id) {
        res.status(400).json({
          success: false,
          message: 'Item ID is required'
        });
        return;
      }

      const updatedItem = await hybridSQLiteService.updateClothingItem(id, updates);

      if (updatedItem) {
        res.json({
          success: true,
          message: 'Clothing item updated successfully',
          data: updatedItem
        });
      } else {
        res.status(404).json({
          success: false,
          message: 'Clothing item not found'
        });
      }
    } catch (error: any) {
      console.error('Error updating clothing item:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to update clothing item',
        error: error.message
      });
    }
  }

  /**
   * Delete clothing item
   */
  async deleteClothingItem(req: Request, res: Response): Promise<void> {
    try {
      const { id } = req.params;

      if (!id) {
        res.status(400).json({
          success: false,
          message: 'Item ID is required'
        });
        return;
      }

      const deleted = await hybridSQLiteService.deleteClothingItem(id);

      if (deleted) {
        res.json({
          success: true,
          message: 'Clothing item deleted successfully'
        });
      } else {
        res.status(404).json({
          success: false,
          message: 'Clothing item not found'
        });
      }
    } catch (error: any) {
      console.error('Error deleting clothing item:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to delete clothing item',
        error: error.message
      });
    }
  }

  /**
   * Get all outfits
   */
  async getOutfits(req: Request, res: Response): Promise<void> {
    try {
      const userId = 'default_user';
      const { occasion, style, season, favorite } = req.query;

      const filters: any = {};
      if (occasion) filters.occasion = occasion as string;
      if (style) filters.style = style as string;
      if (season) filters.season = season as string;
      if (favorite !== undefined) filters.favorite = favorite === 'true';

      const outfits = await hybridSQLiteService.getOutfits(userId, filters);

      res.json({
        success: true,
        data: outfits,
        count: outfits.length
      });
    } catch (error: any) {
      console.error('Error getting outfits:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get outfits',
        error: error.message
      });
    }
  }

  /**
   * Create new outfit
   */
  async createOutfit(req: Request, res: Response): Promise<void> {
    try {
      const {
        name,
        description,
        occasion,
        style,
        season,
        clothing_item_ids,
        model_image_url,
        visualization_url,
        metadata,
        is_favorite
      } = req.body;

      if (!name || !occasion || !style || !clothing_item_ids) {
        res.status(400).json({
          success: false,
          message: 'Missing required fields: name, occasion, style, clothing_item_ids'
        });
        return;
      }

      const userId = 'default_user';

      const newOutfit = await hybridSQLiteService.createOutfit({
        user_id: userId,
        name,
        description,
        occasion,
        style,
        season,
        clothing_item_ids: Array.isArray(clothing_item_ids) ? clothing_item_ids : [clothing_item_ids],
        model_image_url,
        visualization_url,
        metadata: metadata || {},
        is_favorite: is_favorite || false
      });

      res.status(201).json({
        success: true,
        message: 'Outfit created successfully',
        data: newOutfit
      });
    } catch (error: any) {
      console.error('Error creating outfit:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to create outfit',
        error: error.message
      });
    }
  }

  /**
   * Update outfit
   */
  async updateOutfit(req: Request, res: Response): Promise<void> {
    try {
      const { id } = req.params;
      const updates = req.body;

      if (!id) {
        res.status(400).json({
          success: false,
          message: 'Outfit ID is required'
        });
        return;
      }

      const updatedOutfit = await hybridSQLiteService.updateOutfit(id, updates);

      if (updatedOutfit) {
        res.json({
          success: true,
          message: 'Outfit updated successfully',
          data: updatedOutfit
        });
      } else {
        res.status(404).json({
          success: false,
          message: 'Outfit not found'
        });
      }
    } catch (error: any) {
      console.error('Error updating outfit:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to update outfit',
        error: error.message
      });
    }
  }

  /**
   * Delete outfit
   */
  async deleteOutfit(req: Request, res: Response): Promise<void> {
    try {
      const { id } = req.params;

      if (!id) {
        res.status(400).json({
          success: false,
          message: 'Outfit ID is required'
        });
        return;
      }

      const deleted = await hybridSQLiteService.deleteOutfit(id);

      if (deleted) {
        res.json({
          success: true,
          message: 'Outfit deleted successfully'
        });
      } else {
        res.status(404).json({
          success: false,
          message: 'Outfit not found'
        });
      }
    } catch (error: any) {
      console.error('Error deleting outfit:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to delete outfit',
        error: error.message
      });
    }
  }

  /**
   * Get wardrobe statistics
   */
  async getWardrobeStats(req: Request, res: Response): Promise<void> {
    try {
      const userId = 'default_user';

      const stats = await hybridSQLiteService.getWardrobeStats(userId);

      res.json({
        success: true,
        data: stats
      });
    } catch (error: any) {
      console.error('Error getting wardrobe stats:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get wardrobe statistics',
        error: error.message
      });
    }
  }

  /**
   * Get user models
   */
  async getUserModels(req: Request, res: Response): Promise<void> {
    try {
      const userId = 'default_user';

      const models = await hybridSQLiteService.getUserModels(userId);

      res.json({
        success: true,
        data: models,
        count: models.length
      });
    } catch (error: any) {
      console.error('Error getting user models:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get user models',
        error: error.message
      });
    }
  }

  /**
   * Create user model
   */
  async createUserModel(req: Request, res: Response): Promise<void> {
    try {
      const {
        name,
        original_image_url,
        processed_image_url,
        model_type,
        status,
        metadata
      } = req.body;

      if (!name || !original_image_url || !model_type || !status) {
        res.status(400).json({
          success: false,
          message: 'Missing required fields: name, original_image_url, model_type, status'
        });
        return;
      }

      const userId = 'default_user';

      const newModel = await hybridSQLiteService.createUserModel({
        user_id: userId,
        name,
        original_image_url,
        processed_image_url,
        model_type,
        status,
        metadata: metadata || {}
      });

      res.status(201).json({
        success: true,
        message: 'User model created successfully',
        data: newModel
      });
    } catch (error: any) {
      console.error('Error creating user model:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to create user model',
        error: error.message
      });
    }
  }

  /**
   * Update user model
   */
  async updateUserModel(req: Request, res: Response): Promise<void> {
    try {
      const { id } = req.params;
      const updates = req.body;

      if (!id) {
        res.status(400).json({
          success: false,
          message: 'Model ID is required'
        });
        return;
      }

      const updatedModel = await hybridSQLiteService.updateUserModel(id, updates);

      if (updatedModel) {
        res.json({
          success: true,
          message: 'User model updated successfully',
          data: updatedModel
        });
      } else {
        res.status(404).json({
          success: false,
          message: 'User model not found'
        });
      }
    } catch (error: any) {
      console.error('Error updating user model:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to update user model',
        error: error.message
      });
    }
  }

  /**
   * Delete user model
   */
  async deleteUserModel(req: Request, res: Response): Promise<void> {
    try {
      const { id } = req.params;

      if (!id) {
        res.status(400).json({
          success: false,
          message: 'Model ID is required'
        });
        return;
      }

      const deleted = await hybridSQLiteService.deleteUserModel(id);

      if (deleted) {
        res.json({
          success: true,
          message: 'User model deleted successfully'
        });
      } else {
        res.status(404).json({
          success: false,
          message: 'User model not found'
        });
      }
    } catch (error: any) {
      console.error('Error deleting user model:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to delete user model',
        error: error.message
      });
    }
  }
}

export const localStorageController = new LocalStorageController();