import { GoogleGenerativeAI } from '@google/generative-ai';
import fs from 'fs';
import path from 'path';

export interface AIProcessResult {
  success: boolean;
  data?: any;
  error?: string;
  metadata?: any;
}

export interface ProcessModelOptions {
  enhanceQuality?: boolean;
  removeBackground?: boolean;
  upscale?: boolean;
}

export interface ProcessClothingOptions {
  removeBackground?: boolean;
  enhanceQuality?: boolean;
  categorize?: boolean;
  extractColors?: boolean;
}

export interface OutfitGenerationOptions {
  occasion?: string;
  style?: string;
  season?: string;
  colorScheme?: string;
}

class HybridAIService {
  private genAI: GoogleGenerativeAI;
  private model: any;

  constructor() {
    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey) {
      throw new Error('GEMINI_API_KEY environment variable is required');
    }

    this.genAI = new GoogleGenerativeAI(apiKey);
    this.model = this.genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });
  }

  /**
   * Process user model photo for better outfit fitting
   */
  async processUserModel(imagePath: string, options: ProcessModelOptions = {}): Promise<AIProcessResult> {
    try {
      const imageBuffer = fs.readFileSync(imagePath);
      const imageBase64 = imageBuffer.toString('base64');

      let prompt = `Process this user model photo for wardrobe management and outfit visualization.

      Tasks to perform:
      - Remove background and isolate the person
      - Enhance image quality for better outfit overlay
      - Standardize pose and proportions for consistent outfit fitting
      - Ensure full body is visible and well-positioned

      Return a structured response with:
      - processed_image_url: URL to the processed image
      - metadata: processing info, dimensions, pose data
      - confidence: processing confidence score
      - recommendations: any issues found or improvements made`;

      if (options.removeBackground) {
        prompt += "\n- Focus on clean background removal";
      }
      if (options.enhanceQuality) {
        prompt += "\n- Enhance image quality and resolution";
      }
      if (options.upscale) {
        prompt += "\n- Upscale image for better resolution";
      }

      const result = await this.model.generateContent([
        prompt,
        {
          inlineData: {
            data: imageBase64,
            mimeType: 'image/jpeg'
          }
        }
      ]);

      const response = await result.response;
      const text = response.text();

      // Try to parse JSON response
      try {
        const jsonMatch = text.match(/\{[\s\S]*\}/);
        if (jsonMatch) {
          const data = JSON.parse(jsonMatch[0]);
          return {
            success: true,
            data: data,
            metadata: {
              originalPath: imagePath,
              processedAt: new Date().toISOString(),
              options: options
            }
          };
        }
      } catch (parseError) {
        // If JSON parsing fails, return the text response
        return {
          success: true,
          data: { processedText: text },
          metadata: {
            originalPath: imagePath,
            processedAt: new Date().toISOString(),
            options: options,
            note: 'Raw text response due to JSON parsing failure'
          }
        };
      }

      return {
        success: false,
        error: 'Failed to process AI response'
      };

    } catch (error: any) {
      console.error('Error processing user model:', error);
      return {
        success: false,
        error: error.message || 'Failed to process user model'
      };
    }
  }

  /**
   * Process clothing item for better catalog management
   */
  async processClothingItem(imagePath: string, options: ProcessClothingOptions = {}): Promise<AIProcessResult> {
    try {
      const imageBuffer = fs.readFileSync(imagePath);
      const imageBase64 = imageBuffer.toString('base64');

      let prompt = `Process this clothing item image for wardrobe catalog management.

      Tasks to perform:
      - Remove background to isolate the clothing item
      - Enhance image quality and colors
      - Identify clothing category, style, and material
      - Extract dominant colors
      - Determine appropriate sizing information
      - Assess condition and quality

      Return a structured response with:
      - processed_image_url: URL to the processed image
      - category: clothing category (shirt, pants, dress, etc.)
      - style: style descriptor (casual, formal, athletic, etc.)
      - colors: array of dominant colors with hex codes
      - material: likely material type
      - size_info: size information if visible
      - quality_score: 1-10 quality assessment
      - metadata: additional processing info`;

      if (options.categorize) {
        prompt += "\n- Provide detailed categorization";
      }
      if (options.extractColors) {
        prompt += "\n- Extract detailed color palette";
      }

      const result = await this.model.generateContent([
        prompt,
        {
          inlineData: {
            data: imageBase64,
            mimeType: 'image/jpeg'
          }
        }
      ]);

      const response = await result.response;
      const text = response.text();

      try {
        const jsonMatch = text.match(/\{[\s\S]*\}/);
        if (jsonMatch) {
          const data = JSON.parse(jsonMatch[0]);
          return {
            success: true,
            data: data,
            metadata: {
              originalPath: imagePath,
              processedAt: new Date().toISOString(),
              options: options
            }
          };
        }
      } catch (parseError) {
        return {
          success: true,
          data: { processedText: text },
          metadata: {
            originalPath: imagePath,
            processedAt: new Date().toISOString(),
            options: options,
            note: 'Raw text response due to JSON parsing failure'
          }
        };
      }

      return {
        success: false,
        error: 'Failed to process AI response'
      };

    } catch (error: any) {
      console.error('Error processing clothing item:', error);
      return {
        success: false,
        error: error.message || 'Failed to process clothing item'
      };
    }
  }

  /**
   * Generate outfit visualization
   */
  async generateOutfitVisualization(
    modelImagePath: string,
    clothingItemPaths: string[],
    options: OutfitGenerationOptions = {}
  ): Promise<AIProcessResult> {
    try {
      const modelBuffer = fs.readFileSync(modelImagePath);
      const modelBase64 = modelBuffer.toString('base64');

      const clothingImages = clothingItemPaths.map(path => {
        const buffer = fs.readFileSync(path);
        return {
          data: buffer.toString('base64'),
          mimeType: 'image/jpeg'
        };
      });

      let prompt = `Generate an outfit visualization combining the user model with the provided clothing items.

      Instructions:
      - Create a realistic outfit overlay on the model
      - Ensure proper fit, proportions, and positioning
      - Match lighting and shadows for realistic appearance
      - Handle different body types and clothing styles appropriately

      Considerations:`;

      if (options.occasion) {
        prompt += `\n- Occasion: ${options.occasion}`;
      }
      if (options.style) {
        prompt += `\n- Style preference: ${options.style}`;
      }
      if (options.season) {
        prompt += `\n- Season: ${options.season}`;
      }
      if (options.colorScheme) {
        prompt += `\n- Color scheme: ${options.colorScheme}`;
      }

      prompt += `

      Return a structured response with:
      - visualization_url: URL to the generated outfit visualization
      - outfit_items: list of items used in the outfit
      - fit_quality: assessment of how well the items fit
      - style_score: 1-10 style coordination score
      - recommendations: styling suggestions or adjustments
      - metadata: generation info and parameters`;

      const imageParts = [
        prompt,
        {
          inlineData: {
            data: modelBase64,
            mimeType: 'image/jpeg'
          }
        },
        ...clothingImages.map(img => ({
          inlineData: img
        }))
      ];

      const result = await this.model.generateContent(imageParts);
      const response = await result.response;
      const text = response.text();

      try {
        const jsonMatch = text.match(/\{[\s\S]*\}/);
        if (jsonMatch) {
          const data = JSON.parse(jsonMatch[0]);
          return {
            success: true,
            data: data,
            metadata: {
              modelImagePath,
              clothingItemPaths,
              processedAt: new Date().toISOString(),
              options: options
            }
          };
        }
      } catch (parseError) {
        return {
          success: true,
          data: { processedText: text },
          metadata: {
            modelImagePath,
            clothingItemPaths,
            processedAt: new Date().toISOString(),
            options: options,
            note: 'Raw text response due to JSON parsing failure'
          }
        };
      }

      return {
        success: false,
        error: 'Failed to process AI response'
      };

    } catch (error: any) {
      console.error('Error generating outfit visualization:', error);
      return {
        success: false,
        error: error.message || 'Failed to generate outfit visualization'
      };
    }
  }

  /**
   * Generate style recommendations
   */
  async generateStyleRecommendations(
    userPreferences: any,
    wardrobeItems: any[],
    count: number = 5
  ): Promise<AIProcessResult> {
    try {
      const prompt = `Generate ${count} personalized style recommendations based on user preferences and existing wardrobe.

      User Preferences:
      ${JSON.stringify(userPreferences, null, 2)}

      Existing Wardrobe Items:
      ${JSON.stringify(wardrobeItems.slice(0, 20), null, 2)} // Limit to prevent token overflow

      Instructions:
      - Analyze user style preferences and existing wardrobe
      - Identify gaps in wardrobe coverage
      - Recommend specific outfit combinations
      - Suggest new items that would complement existing pieces
      - Consider different occasions and seasons

      Return a structured response with:
      - recommendations: array of outfit recommendations
      - wardrobe_gaps: identified missing items or categories
      - style_tips: personalized styling advice
      - outfit_combinations: specific combinations from existing items
      - confidence: overall confidence in recommendations
      - metadata: analysis parameters and user context`;

      const result = await this.model.generateContent(prompt);
      const response = await result.response;
      const text = response.text();

      try {
        const jsonMatch = text.match(/\{[\s\S]*\}/);
        if (jsonMatch) {
          const data = JSON.parse(jsonMatch[0]);
          return {
            success: true,
            data: data,
            metadata: {
              userPreferences,
              wardrobeSize: wardrobeItems.length,
              processedAt: new Date().toISOString()
            }
          };
        }
      } catch (parseError) {
        return {
          success: true,
          data: { processedText: text },
          metadata: {
            userPreferences,
            wardrobeSize: wardrobeItems.length,
            processedAt: new Date().toISOString(),
            note: 'Raw text response due to JSON parsing failure'
          }
        };
      }

      return {
        success: false,
        error: 'Failed to process AI response'
      };

    } catch (error: any) {
      console.error('Error generating style recommendations:', error);
      return {
        success: false,
        error: error.message || 'Failed to generate style recommendations'
      };
    }
  }

  /**
   * Check AI service availability and configuration
   */
  async checkServiceStatus(): Promise<AIProcessResult> {
    try {
      if (!process.env.GEMINI_API_KEY) {
        return {
          success: false,
          error: 'GEMINI_API_KEY not configured'
        };
      }

      // Test API with a simple request
      const result = await this.model.generateContent('Hello, can you respond with just "API working"?');
      const response = await result.response;
      const text = response.text();

      return {
        success: true,
        data: {
          status: 'available',
          model: 'gemini-2.5-flash',
          testResponse: text,
          configuredAt: new Date().toISOString()
        }
      };

    } catch (error: any) {
      console.error('Error checking AI service status:', error);
      return {
        success: false,
        error: error.message || 'AI service unavailable'
      };
    }
  }
}

let hybridAIServiceInstance: HybridAIService | null = null;

export const hybridAIService = (): HybridAIService => {
  if (!hybridAIServiceInstance) {
    hybridAIServiceInstance = new HybridAIService();
  }
  return hybridAIServiceInstance;
};