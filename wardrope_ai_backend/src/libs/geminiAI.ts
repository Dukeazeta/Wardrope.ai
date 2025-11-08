import { GoogleGenerativeAI } from '@google/generative-ai';
import fs from 'fs';
import path from 'path';

export interface AIProcessResult {
  success: boolean;
  data?: any;
  error?: string;
  metadata?: any;
  details?: string;
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
      console.error('❌ GEMINI_API_KEY environment variable is missing');
      throw new Error('GEMINI_API_KEY environment variable is required');
    }

    try {
      this.genAI = new GoogleGenerativeAI(apiKey);
      // Use gemini-2.5-flash for image understanding/processing
      // For image generation, use gemini-2.5-flash-image, but for understanding use gemini-2.5-flash
      this.model = this.genAI.getGenerativeModel({ model: 'gemini-2.5-flash' });
      console.log('✅ Gemini AI service initialized with model: gemini-2.5-flash');
    } catch (error: any) {
      console.error('❌ Failed to initialize Gemini AI:', error);
      throw new Error(`Failed to initialize Gemini AI: ${error.message}`);
    }
  }

  /**
   * Process user model photo for better outfit fitting
   * Accepts either a file path (string) or a buffer
   */
  async processUserModel(imagePathOrBuffer: string | Buffer, options: ProcessModelOptions = {}): Promise<AIProcessResult> {
    try {
      // Handle both file path and buffer
      let imageBuffer: Buffer;
      let imagePath: string | undefined;
      
      if (Buffer.isBuffer(imagePathOrBuffer)) {
        imageBuffer = imagePathOrBuffer;
      } else {
        imagePath = imagePathOrBuffer;
        imageBuffer = fs.readFileSync(imagePath);
      }
      
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
              originalPath: imagePath || 'buffer',
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
            originalPath: imagePath || 'buffer',
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
      console.error('Error details:', {
        message: error.message,
        code: error.code,
        status: error.status,
        stack: error.stack
      });
      
      // Provide more specific error messages
      let errorMessage = error.message || 'Failed to process user model';
      if (error.message?.includes('API key')) {
        errorMessage = 'Invalid or missing Gemini API key. Please check GEMINI_API_KEY environment variable.';
      } else if (error.message?.includes('quota') || error.message?.includes('rate limit')) {
        errorMessage = 'API quota exceeded or rate limit reached. Please try again later.';
      } else if (error.message?.includes('model')) {
        errorMessage = 'Invalid model name or model not available.';
      }
      
      return {
        success: false,
        error: errorMessage,
        details: process.env.NODE_ENV === 'development' ? error.message : undefined
      };
    }
  }

  /**
   * Process clothing item for better catalog management
   * Accepts either a file path (string) or a buffer
   */
  async processClothingItem(imagePathOrBuffer: string | Buffer, options: ProcessClothingOptions = {}): Promise<AIProcessResult> {
    try {
      // Handle both file path and buffer
      let imageBuffer: Buffer;
      let imagePath: string | undefined;
      
      if (Buffer.isBuffer(imagePathOrBuffer)) {
        imageBuffer = imagePathOrBuffer;
      } else {
        imagePath = imagePathOrBuffer;
        imageBuffer = fs.readFileSync(imagePath);
      }
      
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
              originalPath: imagePath || 'buffer',
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
            originalPath: imagePath || 'buffer',
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
      console.error('Error details:', {
        message: error.message,
        code: error.code,
        status: error.status,
        stack: error.stack
      });
      
      // Provide more specific error messages
      let errorMessage = error.message || 'Failed to process clothing item';
      if (error.message?.includes('API key')) {
        errorMessage = 'Invalid or missing Gemini API key. Please check GEMINI_API_KEY environment variable.';
      } else if (error.message?.includes('quota') || error.message?.includes('rate limit')) {
        errorMessage = 'API quota exceeded or rate limit reached. Please try again later.';
      } else if (error.message?.includes('model')) {
        errorMessage = 'Invalid model name or model not available.';
      }
      
      return {
        success: false,
        error: errorMessage,
        details: process.env.NODE_ENV === 'development' ? error.message : undefined
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