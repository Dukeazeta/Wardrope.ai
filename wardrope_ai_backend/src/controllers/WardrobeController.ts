import { Request, Response } from 'express';
import { ClothingItem, ClothingItemAttributes } from '../models/ClothingItem';
import { AWSService } from '../libs/aws';
import { GoogleImagenService } from '../libs/googleImagen';
import multer from 'multer';
import sharp from 'sharp';

// Configure multer for memory storage
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB limit
  },
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(null, false);
    }
  },
});

export class WardrobeController {
  /**
   * Get user's wardrobe items
   */
  static async getWardrobeItems(req: Request, res: Response): Promise<void> {
    try {
      const { userId } = req.params;
      const { category, color, season, limit = 20, offset = 0 } = req.query;

      if (!userId) {
        res.status(400).json({
          success: false,
          message: 'User ID is required'
        });
        return;
      }

      let clothingItems = await ClothingItem.findByUserId(userId);

      // Apply filters
      if (category) {
        clothingItems = clothingItems.filter(item => 
          item.category.toLowerCase() === (category as string).toLowerCase()
        );
      }

      if (color) {
        clothingItems = clothingItems.filter(item => 
          item.color?.toLowerCase().includes((color as string).toLowerCase())
        );
      }

      if (season) {
        clothingItems = clothingItems.filter(item => 
          item.season && item.season.includes(season as string)
        );
      }

      // Apply pagination
      const startIndex = parseInt(offset as string);
      const endIndex = startIndex + parseInt(limit as string);
      const paginatedItems = clothingItems.slice(startIndex, endIndex);

      res.json({
        success: true,
        data: paginatedItems,
        pagination: {
          limit: parseInt(limit as string),
          offset: parseInt(offset as string),
          total: clothingItems.length
        }
      });
    } catch (error) {
      console.error('Error getting wardrobe items:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Add new clothing item with image upload
   */
  static async addClothingItem(req: Request, res: Response): Promise<void> {
    try {
      const { userId } = req.params;
      const { name, category, brand, color, size, season, tags, purchase_date, price } = req.body;
      const file = req.file;

      if (!userId) {
        res.status(400).json({
          success: false,
          message: 'User ID is required'
        });
        return;
      }

      if (!name || !category || !color) {
        res.status(400).json({
          success: false,
          message: 'Name, category, and color are required'
        });
        return;
      }

      let imageUrl = '';
      
      // Upload image to AWS S3 if provided
      if (file) {
        try {
          // Process image with Sharp (resize and optimize)
          const processedImageBuffer = await sharp(file.buffer)
            .resize(800, 800, { 
              fit: 'inside',
              withoutEnlargement: true 
            })
            .jpeg({ quality: 85 })
            .toBuffer();

          // Generate unique filename
          const filename = `wardrobe/${userId}/${Date.now()}_${file.originalname}`;
          
          // Upload to S3
          imageUrl = await AWSService.uploadFile(processedImageBuffer, filename, file.mimetype);
        } catch (uploadError) {
          console.error('Error uploading image:', uploadError);
          res.status(500).json({
            success: false,
            message: 'Failed to upload image'
          });
          return;
        }
      }

      const clothingItemAttributes: ClothingItemAttributes = {
        user_id: userId,
        name,
        category,
        color,
        brand: brand || undefined,
        size: size || undefined,
        season: season ? [season] : undefined,
        ...(imageUrl && { image_url: imageUrl }),
        tags: tags ? (Array.isArray(tags) ? tags : [tags]) : [],
        ...(purchase_date && { purchase_date: new Date(purchase_date) }),
        ...(price && { price: parseFloat(price) })
      };

      const clothingItem = await ClothingItem.create(clothingItemAttributes);

      if (!clothingItem) {
        res.status(500).json({
          success: false,
          message: 'Failed to create clothing item'
        });
        return;
      }

      res.status(201).json({
        success: true,
        data: clothingItem,
        message: 'Clothing item added successfully'
      });
    } catch (error) {
      console.error('Error adding clothing item:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Get specific clothing item
   */
  static async getClothingItem(req: Request, res: Response): Promise<void> {
    try {
      const { itemId } = req.params;

      if (!itemId) {
        res.status(400).json({
          success: false,
          message: 'Item ID is required'
        });
        return;
      }

      const clothingItem = await ClothingItem.findById(itemId);
      if (!clothingItem) {
        res.status(404).json({
          success: false,
          message: 'Clothing item not found'
        });
        return;
      }

      res.json({
        success: true,
        data: clothingItem
      });
    } catch (error) {
      console.error('Error getting clothing item:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Update clothing item
   */
  static async updateClothingItem(req: Request, res: Response): Promise<void> {
    try {
      const { itemId } = req.params;
      const updates = req.body;
      const file = req.file;

      if (!itemId) {
        res.status(400).json({
          success: false,
          message: 'Item ID is required'
        });
        return;
      }

      const existingItem = await ClothingItem.findById(itemId);
      if (!existingItem) {
        res.status(404).json({
          success: false,
          message: 'Clothing item not found'
        });
        return;
      }

      // Handle image upload if new file provided
      if (file) {
        try {
          // Process image with Sharp
          const processedImageBuffer = await sharp(file.buffer)
            .resize(800, 800, { 
              fit: 'inside',
              withoutEnlargement: true 
            })
            .jpeg({ quality: 85 })
            .toBuffer();

          // Generate unique filename
          const filename = `wardrobe/${existingItem.user_id}/${Date.now()}_${file.originalname}`;
          
          // Upload new image to S3
          const newImageUrl = await AWSService.uploadFile(processedImageBuffer, filename, file.mimetype);
          
          // Delete old image if it exists
          if (existingItem.image_url) {
            try {
              await AWSService.deleteFile(existingItem.image_url);
            } catch (deleteError) {
              console.warn('Failed to delete old image:', deleteError);
            }
          }
          
          updates.image_url = newImageUrl;
        } catch (uploadError) {
          console.error('Error uploading new image:', uploadError);
          res.status(500).json({
            success: false,
            message: 'Failed to upload new image'
          });
          return;
        }
      }

      // Update allowed fields
      const allowedFields = ['name', 'category', 'brand', 'color', 'size', 'season', 'tags', 'purchase_date', 'price', 'image_url'];
      const updateData: any = {};
      allowedFields.forEach(field => {
        if (updates[field] !== undefined) {
          if (field === 'tags' && typeof updates[field] === 'string') {
            updateData[field] = [updates[field]];
          } else if (field === 'purchase_date' && updates[field]) {
            updateData[field] = new Date(updates[field]);
          } else if (field === 'price' && updates[field]) {
            updateData[field] = parseFloat(updates[field]);
          } else {
            updateData[field] = updates[field];
          }
        }
      });

      const updatedItem = await ClothingItem.update(itemId, updateData);
      if (!updatedItem) {
        res.status(500).json({
          success: false,
          message: 'Failed to update clothing item'
        });
        return;
      }

      res.json({
        success: true,
        data: updatedItem,
        message: 'Clothing item updated successfully'
      });
    } catch (error) {
      console.error('Error updating clothing item:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Delete clothing item
   */
  static async deleteClothingItem(req: Request, res: Response): Promise<void> {
    try {
      const { itemId } = req.params;

      if (!itemId) {
        res.status(400).json({
          success: false,
          message: 'Item ID is required'
        });
        return;
      }

      const existingItem = await ClothingItem.findById(itemId);
      if (!existingItem) {
        res.status(404).json({
          success: false,
          message: 'Clothing item not found'
        });
        return;
      }

      // Delete image from S3 if it exists
      if (existingItem.image_url) {
        try {
          await AWSService.deleteFile(existingItem.image_url);
        } catch (deleteError) {
          console.warn('Failed to delete image from S3:', deleteError);
        }
      }

      const success = await ClothingItem.delete(itemId);
      if (!success) {
        res.status(500).json({
          success: false,
          message: 'Failed to delete clothing item'
        });
        return;
      }

      res.json({
        success: true,
        message: 'Clothing item deleted successfully'
      });
    } catch (error) {
      console.error('Error deleting clothing item:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Get wardrobe categories
   */
  static async getCategories(req: Request, res: Response): Promise<void> {
    try {
      const { userId } = req.params;

      if (!userId) {
        res.status(400).json({
          success: false,
          message: 'User ID is required'
        });
        return;
      }

      const clothingItems = await ClothingItem.findByUserId(userId);
      const categories = [...new Set(clothingItems.map(item => item.category))];

      res.json({
        success: true,
        data: categories
      });
    } catch (error) {
      console.error('Error getting categories:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Get wardrobe statistics
   */
  static async getWardrobeStats(req: Request, res: Response): Promise<void> {
    try {
      const { userId } = req.params;

      if (!userId) {
        res.status(400).json({
          success: false,
          message: 'User ID is required'
        });
        return;
      }

      const clothingItems = await ClothingItem.findByUserId(userId);

      const stats = {
        totalItems: clothingItems.length,
        categories: [...new Set(clothingItems.map(item => item.category))],
        brands: [...new Set(clothingItems.filter(item => item.brand).map(item => item.brand))],
        colors: [...new Set(clothingItems.filter(item => item.color).map(item => item.color))],
        seasons: [...new Set(clothingItems.filter(item => item.season).flatMap(item => item.season!))],
        recentlyAdded: clothingItems
          .sort((a, b) => new Date(b.created_at!).getTime() - new Date(a.created_at!).getTime())
          .slice(0, 5),
        totalValue: clothingItems
          .filter(item => item.price)
          .reduce((sum, item) => sum + (item.price || 0), 0)
      };

      res.json({
        success: true,
        data: stats
      });
    } catch (error) {
      console.error('Error getting wardrobe stats:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Generate AI-enhanced clothing item image
   */
  static async generateEnhancedImage(req: Request, res: Response): Promise<void> {
    try {
      const { itemId } = req.params;
      const { prompt, style = 'photorealistic' } = req.body;

      if (!itemId) {
        res.status(400).json({
          success: false,
          message: 'Item ID is required'
        });
        return;
      }

      const clothingItem = await ClothingItem.findById(itemId);
      if (!clothingItem) {
        res.status(404).json({
          success: false,
          message: 'Clothing item not found'
        });
        return;
      }

      // Generate enhanced image using Google Imagen
      const enhancedPrompt = prompt || `Professional product photo of ${clothingItem.name} ${clothingItem.category} in ${clothingItem.color || 'neutral'} color, ${style} style, clean background`;
      
      // Check if Google Imagen is configured
      if (!GoogleImagenService.isConfigured()) {
        res.status(500).json({
          success: false,
          message: 'AI image generation service not configured'
        });
        return;
      }

      try {
        const generationResult = await GoogleImagenService.generateImage({
          prompt: enhancedPrompt,
          aspectRatio: '1:1'
        });

        if (!generationResult || generationResult.status === 'failed') {
          res.status(500).json({
            success: false,
            message: 'Failed to generate enhanced image',
            error: generationResult?.metadata?.error
          });
          return;
        }

        res.json({
          success: true,
          data: {
            originalImageUrl: clothingItem.image_url,
            enhancedImageUrl: generationResult.imageUrl,
            prompt: enhancedPrompt,
            jobId: generationResult.jobId
          },
          message: 'Enhanced image generated successfully'
        });
      } catch (aiError) {
        console.error('Error generating AI image:', aiError);
        res.status(500).json({
          success: false,
          message: 'Failed to generate enhanced image',
          error: aiError instanceof Error ? aiError.message : 'Unknown error'
        });
      }
    } catch (error) {
      console.error('Error in generateEnhancedImage:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Search wardrobe items
   */
  static async searchItems(req: Request, res: Response): Promise<void> {
    try {
      const { userId } = req.params;
      const { query, category, color, season } = req.query;

      if (!userId) {
        res.status(400).json({
          success: false,
          message: 'User ID is required'
        });
        return;
      }

      let clothingItems = await ClothingItem.findByUserId(userId);

      // Apply search filters
      if (query) {
        const searchQuery = (query as string).toLowerCase();
        clothingItems = clothingItems.filter(item => 
          item.name.toLowerCase().includes(searchQuery) ||
          item.category.toLowerCase().includes(searchQuery) ||
          item.brand?.toLowerCase().includes(searchQuery) ||
          item.color?.toLowerCase().includes(searchQuery) ||
          (item.tags && item.tags.some(tag => tag.toLowerCase().includes(searchQuery)))
        );
      }

      if (category) {
        clothingItems = clothingItems.filter(item => 
          item.category.toLowerCase() === (category as string).toLowerCase()
        );
      }

      if (color) {
        clothingItems = clothingItems.filter(item => 
          item.color?.toLowerCase().includes((color as string).toLowerCase())
        );
      }

      if (season) {
        clothingItems = clothingItems.filter(item => 
          item.season && item.season.includes(season as string)
        );
      }

      res.json({
        success: true,
        data: clothingItems,
        count: clothingItems.length
      });
    } catch (error) {
      console.error('Error searching items:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }
}

// Export multer upload middleware for use in routes
export const uploadMiddleware = upload.single('image');
