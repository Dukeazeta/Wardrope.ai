import { S3Client, PutObjectCommand, GetObjectCommand, DeleteObjectCommand, GetObjectCommandOutput } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import { config } from './config';
import sharp from 'sharp';
import { v4 as uuidv4 } from 'uuid';

export class AWSService {
  private static s3Client: S3Client;

  static {
    this.s3Client = new S3Client({
      region: config.aws.region,
      credentials: {
        accessKeyId: config.aws.accessKeyId,
        secretAccessKey: config.aws.secretAccessKey,
      },
    });
  }

  /**
   * Upload file to S3
   */
  static async uploadFile(
    file: Buffer,
    key: string,
    contentType: string,
    metadata?: Record<string, string>
  ): Promise<string> {
    try {
      const command = new PutObjectCommand({
        Bucket: config.aws.s3.bucket,
        Key: key,
        Body: file,
        ContentType: contentType,
        Metadata: metadata,
      });

      await this.s3Client.send(command);
      return `https://${config.aws.s3.bucket}.s3.${config.aws.s3.region}.amazonaws.com/${key}`;
    } catch (error) {
      console.error('Error uploading file to S3:', error);
      throw new Error('Failed to upload file to S3');
    }
  }

  /**
   * Upload and process image
   */
  static async uploadImage(
    file: Express.Multer.File,
    folder: string,
    options?: {
      maxWidth?: number;
      maxHeight?: number;
      quality?: number;
      format?: 'jpeg' | 'png' | 'webp';
    }
  ): Promise<{ originalUrl: string; processedUrl: string }> {
    try {
      const { maxWidth = 1920, maxHeight = 1920, quality = 90, format = 'jpeg' } = options || {};
      
      // Generate unique filename
      const fileExtension = format;
      const timestamp = Date.now();
      const uniqueId = uuidv4().substring(0, 8);
      const baseKey = `${folder}/${timestamp}_${uniqueId}`;

      // Upload original image
      const originalKey = `${baseKey}_original.${file.mimetype.split('/')[1]}`;
      const originalUrl = await this.uploadFile(
        file.buffer,
        originalKey,
        file.mimetype,
        {
          originalName: file.originalname,
          uploadedAt: new Date().toISOString(),
        }
      );

      // Process image
      let processedBuffer: Buffer;
      const sharpImage = sharp(file.buffer);

      if (format === 'jpeg') {
        processedBuffer = await sharpImage
          .resize(maxWidth, maxHeight, { fit: 'inside', withoutEnlargement: true })
          .jpeg({ quality })
          .toBuffer();
      } else if (format === 'png') {
        processedBuffer = await sharpImage
          .resize(maxWidth, maxHeight, { fit: 'inside', withoutEnlargement: true })
          .png({ quality })
          .toBuffer();
      } else if (format === 'webp') {
        processedBuffer = await sharpImage
          .resize(maxWidth, maxHeight, { fit: 'inside', withoutEnlargement: true })
          .webp({ quality })
          .toBuffer();
      } else {
        throw new Error('Unsupported image format');
      }

      // Upload processed image
      const processedKey = `${baseKey}_processed.${fileExtension}`;
      const processedUrl = await this.uploadFile(
        processedBuffer,
        processedKey,
        `image/${fileExtension}`,
        {
          originalName: file.originalname,
          processedAt: new Date().toISOString(),
          dimensions: `${maxWidth}x${maxHeight}`,
          quality: quality.toString(),
        }
      );

      return {
        originalUrl,
        processedUrl,
      };
    } catch (error) {
      console.error('Error processing and uploading image:', error);
      throw new Error('Failed to process and upload image');
    }
  }

  /**
   * Delete file from S3
   */
  static async deleteFile(url: string): Promise<boolean> {
    try {
      // Extract key from URL
      const key = this.extractKeyFromUrl(url);
      if (!key) {
        throw new Error('Invalid S3 URL');
      }

      const command = new DeleteObjectCommand({
        Bucket: config.aws.s3.bucket,
        Key: key,
      });

      await this.s3Client.send(command);
      return true;
    } catch (error) {
      console.error('Error deleting file from S3:', error);
      return false;
    }
  }

  /**
   * Generate presigned URL for temporary access
   */
  static async getPresignedUrl(key: string, expiresIn: number = 3600): Promise<string> {
    try {
      const command = new GetObjectCommand({
        Bucket: config.aws.s3.bucket,
        Key: key,
      });

      const url = await getSignedUrl(this.s3Client, command, { expiresIn });
      return url;
    } catch (error) {
      console.error('Error generating presigned URL:', error);
      throw new Error('Failed to generate presigned URL');
    }
  }

  /**
   * Upload model files (images, metadata, etc.)
   */
  static async uploadModelFiles(
    userId: string,
    originalImage: Express.Multer.File,
    metadata?: any
  ): Promise<{
    originalImageUrl: string;
    processedImageUrl: string;
    modelDataUrl?: string;
  }> {
    try {
      const folder = `models/${userId}`;
      
      // Upload and process the model image
      const { originalUrl, processedUrl } = await this.uploadImage(originalImage, folder, {
        maxWidth: 1080,
        maxHeight: 1920,
        quality: 90,
        format: 'jpeg'
      });

      let modelDataUrl;
      if (metadata) {
        // Upload metadata as JSON
        const metadataKey = `${folder}/${Date.now()}_metadata.json`;
        modelDataUrl = await this.uploadFile(
          Buffer.from(JSON.stringify(metadata)),
          metadataKey,
          'application/json'
        );
      }

      const result: { originalImageUrl: string; processedImageUrl: string; modelDataUrl?: string } = {
        originalImageUrl: originalUrl,
        processedImageUrl: processedUrl,
      };

      if (modelDataUrl) {
        result.modelDataUrl = modelDataUrl;
      }

      return result;
    } catch (error) {
      console.error('Error uploading model files:', error);
      throw new Error('Failed to upload model files');
    }
  }

  /**
   * Upload clothing item image
   */
  static async uploadClothingImage(
    userId: string,
    clothingImage: Express.Multer.File
  ): Promise<{ originalUrl: string; processedUrl: string; thumbnailUrl: string }> {
    try {
      const folder = `clothing/${userId}`;
      
      // Upload and process main image
      const { originalUrl, processedUrl } = await this.uploadImage(clothingImage, folder, {
        maxWidth: 1024,
        maxHeight: 1024,
        quality: 85,
        format: 'jpeg'
      });

      // Create and upload thumbnail
      const thumbnailBuffer = await sharp(clothingImage.buffer)
        .resize(300, 300, { fit: 'cover' })
        .jpeg({ quality: 80 })
        .toBuffer();

      const thumbnailKey = `${folder}/${Date.now()}_${uuidv4().substring(0, 8)}_thumbnail.jpeg`;
      const thumbnailUrl = await this.uploadFile(
        thumbnailBuffer,
        thumbnailKey,
        'image/jpeg'
      );

      return {
        originalUrl,
        processedUrl,
        thumbnailUrl,
      };
    } catch (error) {
      console.error('Error uploading clothing image:', error);
      throw new Error('Failed to upload clothing image');
    }
  }

  /**
   * Extract S3 key from URL
   */
  private static extractKeyFromUrl(url: string): string | null {
    try {
      const urlObject = new URL(url);
      // Remove leading slash
      return urlObject.pathname.substring(1);
    } catch {
      return null;
    }
  }

  /**
   * Check if S3 is properly configured
   */
  static isConfigured(): boolean {
    return !!(
      config.aws.accessKeyId &&
      config.aws.secretAccessKey &&
      config.aws.s3.bucket &&
      config.aws.region
    );
  }
}

export default AWSService;
