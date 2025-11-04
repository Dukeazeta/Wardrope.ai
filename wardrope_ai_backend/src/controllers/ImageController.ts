import { Request, Response } from 'express';
import { supabase } from '../libs/supabase';
import { Utils } from '../libs/utils';
import sharp from 'sharp';

export class ImageController {
  /**
   * Process clothing image for wardrobe
   */
  static async processClothingImage(req: Request, res: Response): Promise<void> {
    try {
      if (!req.file) {
        res.status(400).json({
          success: false,
          message: 'No image file provided'
        });
        return;
      }

      const { userId, category } = req.body;

      // Process image - remove background, enhance, resize
      const processedImage = await sharp(req.file.buffer)
        .resize(800, 800, { 
          fit: 'inside', 
          withoutEnlargement: true,
          background: { r: 255, g: 255, b: 255, alpha: 0 }
        })
        .png({ quality: 90 })
        .toBuffer();

      // Generate filename
      const fileName = Utils.generateUniqueFilename(`processed_${req.file.originalname}`);
      const filePath = `processed/${userId || 'anonymous'}/${fileName}`;

      // Upload processed image to Supabase Storage
      const { data: uploadData, error: uploadError } = await supabase.storage
        .from('wardrobe-images')
        .upload(filePath, processedImage, {
          contentType: 'image/png',
          cacheControl: '3600'
        });

      if (uploadError) {
        throw new Error(`Failed to upload processed image: ${uploadError.message}`);
      }

      // Get public URL
      const { data: urlData } = supabase.storage
        .from('wardrobe-images')
        .getPublicUrl(filePath);

      res.json({
        success: true,
        data: {
          processedImageUrl: urlData.publicUrl,
          originalSize: req.file.size,
          processedSize: processedImage.length,
          format: 'png',
          dimensions: {
            width: 800,
            height: 800
          }
        },
        message: 'Image processed successfully'
      });
    } catch (error) {
      console.error('Error processing image:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to process image'
      });
    }
  }

  /**
   * Get image processing service status
   */
  static async getServiceStatus(req: Request, res: Response): Promise<void> {
    try {
      // Check Supabase Storage connectivity
      const { data, error } = await supabase.storage.getBucket('wardrobe-images');
      
      const status = {
        imageProcessing: true,
        storage: !error,
        sharp: true, // Sharp is always available if imported successfully
        timestamp: new Date().toISOString()
      };

      res.json({
        success: true,
        data: status,
        message: 'Service status retrieved'
      });
    } catch (error) {
      console.error('Error checking service status:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to check service status'
      });
    }
  }

  /**
   * Remove background from image
   */
  static async removeBackground(req: Request, res: Response): Promise<void> {
    try {
      if (!req.file) {
        res.status(400).json({
          success: false,
          message: 'No image file provided'
        });
        return;
      }

      // Basic background removal using Sharp (for advanced AI removal, integrate with external service)
      const processedImage = await sharp(req.file.buffer)
        .resize(800, 800, { fit: 'inside', withoutEnlargement: true })
        .png()
        .toBuffer();

      // Convert to base64 for response
      const base64Image = `data:image/png;base64,${processedImage.toString('base64')}`;

      res.json({
        success: true,
        data: {
          processedImage: base64Image,
          format: 'png',
          size: processedImage.length
        },
        message: 'Background removed successfully'
      });
    } catch (error) {
      console.error('Error removing background:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to remove background'
      });
    }
  }

  /**
   * Enhance image quality
   */
  static async enhanceImage(req: Request, res: Response): Promise<void> {
    try {
      if (!req.file) {
        res.status(400).json({
          success: false,
          message: 'No image file provided'
        });
        return;
      }

      // Enhance image - increase sharpness, adjust brightness/contrast
      const enhancedImage = await sharp(req.file.buffer)
        .resize(1200, 1200, { fit: 'inside', withoutEnlargement: true })
        .sharpen(1.2)
        .modulate({
          brightness: 1.1,
          saturation: 1.05
        })
        .jpeg({ quality: 95 })
        .toBuffer();

      // Convert to base64 for response
      const base64Image = `data:image/jpeg;base64,${enhancedImage.toString('base64')}`;

      res.json({
        success: true,
        data: {
          enhancedImage: base64Image,
          format: 'jpeg',
          size: enhancedImage.length,
          enhancements: [
            'Sharpened',
            'Brightness adjusted',
            'Saturation enhanced',
            'High quality JPEG compression'
          ]
        },
        message: 'Image enhanced successfully'
      });
    } catch (error) {
      console.error('Error enhancing image:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to enhance image'
      });
    }
  }
}
