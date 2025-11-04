import path from 'path';
import fs from 'fs/promises';
import crypto from 'crypto';
import { AWSService } from './aws';

export class Utils {
  /**
   * Generate a unique filename with timestamp and random string
   */
  static generateUniqueFilename(originalName: string): string {
    const timestamp = Date.now();
    const randomString = crypto.randomBytes(8).toString('hex');
    const extension = path.extname(originalName);
    const basename = path.basename(originalName, extension);
    
    return `${basename}_${timestamp}_${randomString}${extension}`;
  }

  /**
   * Generate UUID v4
   */
  static generateUUID(): string {
    return crypto.randomUUID();
  }

  /**
   * Validate email format
   */
  static isValidEmail(email: string): boolean {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }

  /**
   * Sanitize filename for safe storage
   */
  static sanitizeFilename(filename: string): string {
    return filename.replace(/[^a-zA-Z0-9.\-_]/g, '_');
  }

  /**
   * Create directory if it doesn't exist
   */
  static async ensureDirectoryExists(dirPath: string): Promise<void> {
    try {
      await fs.access(dirPath);
    } catch {
      await fs.mkdir(dirPath, { recursive: true });
    }
  }

  /**
   * Format date to ISO string
   */
  static formatDate(date: Date): string {
    return date.toISOString();
  }

  /**
   * Parse JSON safely
   */
  static safeJSONParse(str: string, defaultValue: any = null): any {
    try {
      return JSON.parse(str);
    } catch {
      return defaultValue;
    }
  }

  /**
   * Sleep function for delays
   */
  static sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  /**
   * Validate image file types
   */
  static isValidImageType(mimetype: string): boolean {
    const validTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];
    return validTypes.includes(mimetype);
  }

  /**
   * Convert bytes to human readable format
   */
  static formatBytes(bytes: number, decimals = 2): string {
    if (bytes === 0) return '0 Bytes';

    const k = 1024;
    const dm = decimals < 0 ? 0 : decimals;
    const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];

    const i = Math.floor(Math.log(bytes) / Math.log(k));

    return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
  }

  /**
   * Validate user update data
   */
  static validateUserUpdateData(data: any): string | null {
    if (data.email && !Utils.isValidEmail(data.email)) {
      return 'Invalid email format';
    }

    if (data.first_name && typeof data.first_name !== 'string') {
      return 'First name must be a string';
    }

    if (data.last_name && typeof data.last_name !== 'string') {
      return 'Last name must be a string';
    }

    return null; // No validation errors
  }

  /**
   * Process and upload image using AWS S3
   */
  static async processAndUploadImage(file: Express.Multer.File, path: string): Promise<string> {
    try {
      if (!AWSService.isConfigured()) {
        throw new Error('AWS is not properly configured');
      }

      const { processedUrl } = await AWSService.uploadImage(file, path, {
        maxWidth: 1024,
        maxHeight: 1024,
        quality: 85,
        format: 'jpeg'
      });

      return processedUrl;
    } catch (error) {
      console.error('Error processing and uploading image:', error);
      throw new Error('Failed to process and upload image');
    }
  }
}
