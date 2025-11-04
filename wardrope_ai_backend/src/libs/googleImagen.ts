import axios from 'axios';
import { config } from './config';
import { AWSService } from './aws';
import { v4 as uuidv4 } from 'uuid';

export interface ImageGenerationRequest {
  prompt: string;
  negativePrompt?: string;
  aspectRatio?: '1:1' | '9:16' | '16:9' | '4:3' | '3:4';
  seed?: number;
  guidanceScale?: number;
  style?: 'photorealistic' | 'artistic' | 'illustration' | 'sketch';
}

export interface ImageGenerationResponse {
  imageUrl: string;
  jobId: string;
  status: 'completed' | 'processing' | 'failed';
  metadata?: any;
}

export interface OutfitVisualizationRequest {
  modelImageUrl: string;
  clothingItems: Array<{
    id: string;
    imageUrl: string;
    category: string;
    color: string;
  }>;
  style?: string;
  occasion?: string;
  lighting?: 'natural' | 'studio' | 'outdoor' | 'indoor';
}

export class GoogleImagenService {
  private static baseUrl = 'https://us-central1-aiplatform.googleapis.com/v1';
  private static projectId: string;

  static {
    // Extract project ID from the endpoint URL in config
    const endpoint = config.googleAI.imagenEndpoint;
    const match = endpoint.match(/projects\/([^\/]+)\//);
    this.projectId = match ? match[1] : '';
  }

  /**
   * Generate image using Google Imagen
   */
  static async generateImage(request: ImageGenerationRequest): Promise<ImageGenerationResponse> {
    try {
      if (!config.googleAI.imagenApiKey) {
        throw new Error('Google Imagen API key not configured');
      }

      const payload = {
        instances: [
          {
            prompt: request.prompt,
            negative_prompt: request.negativePrompt || '',
            aspect_ratio: request.aspectRatio || '1:1',
            seed: request.seed || Math.floor(Math.random() * 1000000),
            guidance_scale: request.guidanceScale || 7.5,
          }
        ],
        parameters: {
          sample_count: 1,
          style: request.style || 'photorealistic',
        }
      };

      const response = await axios.post(
        `${this.baseUrl}/projects/${this.projectId}/locations/us-central1/publishers/google/models/imagegeneration:predict`,
        payload,
        {
          headers: {
            'Authorization': `Bearer ${config.googleAI.imagenApiKey}`,
            'Content-Type': 'application/json',
          },
          timeout: 30000, // 30 seconds
        }
      );

      if (response.data && response.data.predictions && response.data.predictions[0]) {
        const prediction = response.data.predictions[0];
        const imageBase64 = prediction.bytes_base64_encoded;
        
        // Convert base64 to buffer and upload to AWS S3
        const imageBuffer = Buffer.from(imageBase64, 'base64');
        const jobId = uuidv4();
        const imageKey = `generated-images/${jobId}.png`;
        
        const imageUrl = await AWSService.uploadFile(
          imageBuffer,
          imageKey,
          'image/png',
          {
            generatedAt: new Date().toISOString(),
            prompt: request.prompt,
            jobId,
          }
        );

        return {
          imageUrl,
          jobId,
          status: 'completed',
          metadata: {
            prompt: request.prompt,
            aspectRatio: request.aspectRatio,
            style: request.style,
          },
        };
      } else {
        throw new Error('Invalid response from Imagen API');
      }
    } catch (error) {
      console.error('Error generating image with Imagen:', error);
      
      // Return a placeholder or error response
      return {
        imageUrl: '',
        jobId: uuidv4(),
        status: 'failed',
        metadata: { error: error instanceof Error ? error.message : 'Unknown error' },
      };
    }
  }

  /**
   * Generate outfit visualization on a model
   */
  static async generateOutfitVisualization(request: OutfitVisualizationRequest): Promise<ImageGenerationResponse> {
    try {
      // Construct a detailed prompt for outfit visualization
      const clothingDescriptions = request.clothingItems.map(item => 
        `${item.color} ${item.category}`
      ).join(', ');

      const prompt = `A ${request.style || 'stylish'} person wearing ${clothingDescriptions} for ${request.occasion || 'casual wear'}. The image should show a full-body view with ${request.lighting || 'natural'} lighting. Professional fashion photography style, high quality, detailed clothing textures, realistic fabric rendering.`;

      const negativePrompt = 'blurry, low quality, distorted, deformed, extra limbs, missing limbs, bad anatomy, poorly fitted clothes, unrealistic proportions';

      return await this.generateImage({
        prompt,
        negativePrompt,
        aspectRatio: '9:16', // Typical fashion/portrait ratio
        style: 'photorealistic',
        guidanceScale: 8.0,
      });
    } catch (error) {
      console.error('Error generating outfit visualization:', error);
      throw new Error('Failed to generate outfit visualization');
    }
  }

  /**
   * Generate clothing item variations
   */
  static async generateClothingVariations(
    originalClothingUrl: string,
    variations: string[]
  ): Promise<ImageGenerationResponse[]> {
    try {
      const results: ImageGenerationResponse[] = [];

      for (const variation of variations) {
        const prompt = `A piece of clothing similar to the reference image but with ${variation}. Professional product photography, white background, high quality, detailed fabric texture.`;

        const result = await this.generateImage({
          prompt,
          aspectRatio: '1:1',
          style: 'photorealistic',
          guidanceScale: 7.0,
        });

        results.push(result);
      }

      return results;
    } catch (error) {
      console.error('Error generating clothing variations:', error);
      throw new Error('Failed to generate clothing variations');
    }
  }

  /**
   * Generate style recommendations based on user preferences
   */
  static async generateStyleRecommendations(
    userPreferences: {
      style: string[];
      colors: string[];
      occasions: string[];
      bodyType?: string;
    },
    count: number = 3
  ): Promise<ImageGenerationResponse[]> {
    try {
      const results: ImageGenerationResponse[] = [];

      for (let i = 0; i < count; i++) {
        const style = userPreferences.style[Math.floor(Math.random() * userPreferences.style.length)];
        const color = userPreferences.colors[Math.floor(Math.random() * userPreferences.colors.length)];
        const occasion = userPreferences.occasions[Math.floor(Math.random() * userPreferences.occasions.length)];

        const prompt = `A ${style} outfit in ${color} colors suitable for ${occasion}. Professional fashion photography, full body view, modern styling, high quality.`;

        const result = await this.generateImage({
          prompt,
          aspectRatio: '9:16',
          style: 'photorealistic',
          guidanceScale: 7.5,
        });

        results.push(result);
      }

      return results;
    } catch (error) {
      console.error('Error generating style recommendations:', error);
      throw new Error('Failed to generate style recommendations');
    }
  }

  /**
   * Check if the service is properly configured
   */
  static isConfigured(): boolean {
    return !!(
      config.googleAI.imagenApiKey &&
      config.googleAI.imagenEndpoint &&
      this.projectId
    );
  }

  /**
   * Get service status
   */
  static getServiceStatus(): {
    configured: boolean;
    projectId: string;
    hasApiKey: boolean;
  } {
    return {
      configured: this.isConfigured(),
      projectId: this.projectId,
      hasApiKey: !!config.googleAI.imagenApiKey,
    };
  }
}

export default GoogleImagenService;
