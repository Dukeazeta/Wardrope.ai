import { supabaseAdmin } from './supabase';
import { v4 as uuidv4 } from 'uuid';

export class SupabaseStorageService {
  private static readonly BUCKET_NAME = 'wardrobe-images';
  private static readonly MODELS_FOLDER = 'models';
  private static readonly CLOTHING_FOLDER = 'clothing';

  /**
   * Upload processed image to Supabase Storage
   */
  static async uploadProcessedImage(
    imageBuffer: Buffer,
    userId: string,
    imageType: 'model' | 'clothing',
    originalName?: string
  ): Promise<string> {
    try {
      const folder = imageType === 'model' ? this.MODELS_FOLDER : this.CLOTHING_FOLDER;
      const fileName = `${imageType}_${uuidv4()}.jpg`;
      const filePath = `${folder}/${userId}/${fileName}`;

      // Upload to Supabase Storage
      const { data, error } = await supabaseAdmin.storage
        .from(this.BUCKET_NAME)
        .upload(filePath, imageBuffer, {
          contentType: 'image/jpeg',
          upsert: true,
          cacheControl: '31536000', // 1 year cache
        });

      if (error) {
        console.error('Error uploading to Supabase:', error);
        throw new Error(`Failed to upload to Supabase: ${(error as any).message}`);
      }

      // Get public URL
      const { data: { publicUrl } } = supabaseAdmin.storage
        .from(this.BUCKET_NAME)
        .getPublicUrl(filePath);

      console.log(`✅ Uploaded ${imageType} image to Supabase: ${publicUrl}`);
      return publicUrl;
    } catch (error) {
      console.error(`Error uploading ${imageType} image:`, error);
      throw error;
    }
  }

  /**
   * Delete image from Supabase Storage
   */
  static async deleteImage(imageUrl: string): Promise<boolean> {
    try {
      // Extract file path from URL
      const url = new URL(imageUrl);
      const pathMatch = url.pathname.match(/\/wardrobe-images\/(.+)/);

      if (!pathMatch) {
        console.error('Could not extract file path from URL:', imageUrl);
        return false;
      }

      const filePath = pathMatch[1];

      const { error } = await supabaseAdmin.storage
        .from(this.BUCKET_NAME)
        .remove([filePath]);

      if (error) {
        console.error('Error deleting from Supabase:', error);
        return false;
      }

      console.log(`✅ Deleted image from Supabase: ${filePath}`);
      return true;
    } catch (error) {
      console.error('Error deleting image:', error);
      return false;
    }
  }

  /**
   * Check if bucket exists and create if needed
   */
  static async ensureBucketExists(): Promise<void> {
    try {
      // List buckets to check if our bucket exists
      const { data: buckets, error } = await supabaseAdmin.storage.listBuckets();

      if (error) {
        console.error('Error listing buckets:', error);
        return;
      }

      const bucketExists = buckets.some(bucket => bucket.name === this.BUCKET_NAME);

      if (!bucketExists) {
        console.log(`Creating bucket: ${this.BUCKET_NAME}`);
        const { error: createError } = await supabaseAdmin.storage.createBucket(
          this.BUCKET_NAME,
          {
            public: true,
            allowedMimeTypes: ['image/*'],
            fileSizeLimit: 10 * 1024 * 1024, // 10MB
          }
        );

        if (createError) {
          console.error('Error creating bucket:', createError);
          throw new Error(`Failed to create bucket: ${createError.message}`);
        }

        console.log(`✅ Created bucket: ${this.BUCKET_NAME}`);
      } else {
        console.log(`✅ Bucket ${this.BUCKET_NAME} already exists`);
      }
    } catch (error) {
      console.error('Error ensuring bucket exists:', error);
      throw error;
    }
  }

  /**
   * Test Supabase Storage connection
   */
  static async testConnection(): Promise<{ success: boolean; message: string }> {
    try {
      // Test by listing buckets
      const { data, error } = await supabaseAdmin.storage.listBuckets();

      if (error) {
        return {
          success: false,
          message: `Storage connection failed: ${error.message}`
        };
      }

      return {
        success: true,
        message: `Storage connected successfully. Found ${data.length} buckets.`
      };
    } catch (error: any) {
      return {
        success: false,
        message: `Storage test failed: ${error?.message || error}`
      };
    }
  }
}

export default SupabaseStorageService;