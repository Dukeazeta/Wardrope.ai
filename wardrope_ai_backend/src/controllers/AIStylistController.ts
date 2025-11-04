import { Request, Response } from 'express';
import { ClothingItem, ClothingItemAttributes } from '../models/ClothingItem';
import { User, UserAttributes } from '../models/User';

export class AIStylistController {
  /**
   * Get outfit recommendations based on user's wardrobe
   */
  static async getOutfitRecommendations(req: Request, res: Response): Promise<void> {
    try {
      const { userId } = req.params;
      const { occasion, weather, season } = req.body;

      if (!userId) {
        res.status(400).json({
          success: false,
          message: 'User ID is required'
        });
        return;
      }

      const items = await ClothingItem.findByUserId(userId);

      if (items.length === 0) {
        res.json({
          success: true,
          data: {
            recommendations: [],
            message: 'Add more items to your wardrobe for better recommendations'
          }
        });
        return;
      }

      // Basic recommendation logic (in production, this would use AI), TODO
      const recommendations = AIStylistController.generateBasicRecommendations(items, occasion, weather, season);

      res.json({
        success: true,
        data: {
          recommendations,
          totalItems: items.length,
          criteria: { occasion, weather, season }
        },
        message: 'Outfit recommendations generated successfully'
      });
    } catch (error) {
      console.error('Error getting recommendations:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Analyze user's personal style
   */
  static async analyzePersonalStyle(req: Request, res: Response): Promise<void> {
    try {
      const { userId } = req.params;
      
      if (!userId) {
        res.status(400).json({
          success: false,
          message: 'User ID is required'
        });
        return;
      }

      const items = await ClothingItem.findByUserId(userId);
      const user = await User.findById(userId);

      if (!user) {
        res.status(404).json({
          success: false,
          message: 'User not found'
        });
        return;
      }

      // Basic style analysis
      const styleAnalysis = AIStylistController.analyzeStyle(items);

      res.json({
        success: true,
        data: styleAnalysis,
        message: 'Style analysis completed'
      });
    } catch (error) {
      console.error('Error analyzing style:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Suggest outfit combinations
   */
  static async suggestOutfitCombinations(req: Request, res: Response): Promise<void> {
    try {
      const { userId } = req.params;
      const { maxCombinations = 5 } = req.body;
      
      if (!userId) {
        res.status(400).json({
          success: false,
          message: 'User ID is required'
        });
        return;
      }

      const items = await ClothingItem.findByUserId(userId);
      const combinations = AIStylistController.generateCombinations(items, maxCombinations);

      res.json({
        success: true,
        data: {
          combinations,
          totalPossible: combinations.length
        },
        message: 'Outfit combinations generated'
      });
    } catch (error) {
      console.error('Error generating combinations:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Get seasonal recommendations
   */
  static async getSeasonalRecommendations(req: Request, res: Response): Promise<void> {
    try {
      const { userId, season } = req.params;
      
      if (!userId || !season) {
        res.status(400).json({
          success: false,
          message: 'User ID and season are required'
        });
        return;
      }

      const items = await ClothingItem.findByUserId(userId);
      const seasonalItems = AIStylistController.filterBySeason(items, season);

      res.json({
        success: true,
        data: {
          season,
          recommendations: seasonalItems,
          tips: AIStylistController.getSeasonalTips(season)
        }
      });
    } catch (error) {
      console.error('Error getting seasonal recommendations:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Get occasion-based outfits
   */
  static async getOccasionOutfits(req: Request, res: Response): Promise<void> {
    try {
      const { userId, occasion } = req.params;

      if (!userId || !occasion) {
        res.status(400).json({
          success: false,
          message: 'User ID and occasion are required'
        });
        return;
      }
      const items = await ClothingItem.findByUserId(userId);
      const occasionOutfits = AIStylistController.filterByOccasion(items, occasion);

      res.json({
        success: true,
        data: {
          occasion,
          outfits: occasionOutfits,
          suggestions: AIStylistController.getOccasionSuggestions(occasion)
        }
      });
    } catch (error) {
      console.error('Error getting occasion outfits:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Get style profile
   */
  static async getStyleProfile(req: Request, res: Response): Promise<void> {
    try {
      const { userId } = req.params;

      if (!userId) {
        res.status(400).json({
          success: false,
          message: 'User ID is required'
        });
        return;
      }
      const user = await User.findById(userId);
      if (!user) {
        res.status(404).json({
          success: false,
          message: 'User not found'
        });
        return;
      }

      const styleProfile = user.preferences?.styleProfile || {
        styles: [],
        colors: [],
        occasions: [],
        brands: []
      };

      res.json({
        success: true,
        data: styleProfile
      });
    } catch (error) {
      console.error('Error getting style profile:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Update style profile
   */
  static async updateStyleProfile(req: Request, res: Response): Promise<void> {
    try {
      const { userId } = req.params;
      const styleProfile = req.body;

      if (!userId) {
        res.status(400).json({
          success: false,
          message: 'User ID is required'
        });
        return;
      }

      const userData = await User.findById(userId);
      if (!userData) {
        res.status(404).json({
          success: false,
          message: 'User not found'
        });
        return;
      }

      const currentPreferences = userData.preferences || {};
      currentPreferences.styleProfile = styleProfile;

      await User.update(userId, { preferences: currentPreferences });

      res.json({
        success: true,
        data: styleProfile,
        message: 'Style profile updated successfully'
      });
    } catch (error) {
      console.error('Error updating style profile:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Submit outfit feedback
   */
  static async submitOutfitFeedback(req: Request, res: Response): Promise<void> {
    try {
      const { userId } = req.params;
      const { outfitId, rating, feedback } = req.body;

      // Store feedback for ML training (in production)
      res.json({
        success: true,
        message: 'Feedback submitted successfully'
      });
    } catch (error) {
      console.error('Error submitting feedback:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Get current trends
   */
  static async getCurrentTrends(req: Request, res: Response): Promise<void> {
    try {
      const trends = [
        { name: 'Oversized Blazers', popularity: 95 },
        { name: 'Wide-leg Pants', popularity: 88 },
        { name: 'Chunky Sneakers', popularity: 82 },
        { name: 'Neutral Tones', popularity: 90 },
        { name: 'Layered Necklaces', popularity: 75 }
      ];

      res.json({
        success: true,
        data: {
          trends,
          lastUpdated: new Date().toISOString()
        }
      });
    } catch (error) {
      console.error('Error getting trends:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Get personalized trends
   */
  static async getPersonalizedTrends(req: Request, res: Response): Promise<void> {
    try {
      const { userId } = req.params;

      if (!userId) {
        res.status(400).json({
          success: false,
          message: 'User ID is required'
        });
        return;
      }

      const items = await ClothingItem.findByUserId(userId);
      const personalizedTrends = AIStylistController.generatePersonalizedTrends(items);

      res.json({
        success: true,
        data: personalizedTrends
      });
    } catch (error) {
      console.error('Error getting personalized trends:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Analyze color palette
   */
  static async analyzeColorPalette(req: Request, res: Response): Promise<void> {
    try {
      const { userId } = req.params;

      if (!userId) {
        res.status(400).json({
          success: false,
          message: 'User ID is required'
        });
        return;
      }

      const items = await ClothingItem.findByUserId(userId);
      const colorAnalysis = AIStylistController.analyzeColors(items);

      res.json({
        success: true,
        data: colorAnalysis
      });
    } catch (error) {
      console.error('Error analyzing color palette:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Get color matching items
   */
  static async getColorMatchingItems(req: Request, res: Response): Promise<void> {
    try {
      const { userId } = req.params;
      const { targetColor } = req.body;

      if (!userId) {
        res.status(400).json({
          success: false,
          message: 'User ID is required'
        });
        return;
      }

      const items = await ClothingItem.findByUserId(userId);
      const matchingItems = items.filter(item => 
        item.color && AIStylistController.colorsMatch(item.color, targetColor)
      );

      res.json({
        success: true,
        data: {
          targetColor,
          matchingItems
        }
      });
    } catch (error) {
      console.error('Error getting color matching items:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Helper methods
  private static generateBasicRecommendations(items: ClothingItemAttributes[], occasion?: string, weather?: string, season?: string) {
    // Basic recommendation logic - group by category
    const tops = items.filter(item => ['T-Shirts', 'Shirts', 'Sweaters', 'Hoodies'].includes(item.category || ''));
    const bottoms = items.filter(item => ['Pants', 'Shorts', 'Skirts'].includes(item.category || ''));
    const shoes = items.filter(item => ['Shoes', 'Sneakers', 'Boots'].includes(item.category || ''));

    const recommendations = [];
    for (let i = 0; i < Math.min(5, tops.length); i++) {
      if (bottoms.length > 0 && shoes.length > 0) {
        recommendations.push({
          id: `rec_${i}`,
          items: [
            tops[i],
            bottoms[i % bottoms.length],
            shoes[i % shoes.length]
          ],
          confidence: Math.random() * 30 + 70, // 70-100%
          reason: 'Color coordination and style balance'
        });
      }
    }

    return recommendations;
  }

  private static analyzeStyle(items: ClothingItemAttributes[]) {
    const categories = items.reduce((acc: Record<string, number>, item) => {
      const category = item.category || 'Unknown';
      acc[category] = (acc[category] || 0) + 1;
      return acc;
    }, {});

    const colors = items.reduce((acc: Record<string, number>, item) => {
      if (item.color) {
        acc[item.color] = (acc[item.color] || 0) + 1;
      }
      return acc;
    }, {});

    return {
      dominantCategories: Object.entries(categories)
        .sort(([,a], [,b]) => (b as number) - (a as number))
        .slice(0, 3),
      colorPalette: Object.entries(colors)
        .sort(([,a], [,b]) => (b as number) - (a as number))
        .slice(0, 5),
      stylePersonality: items.length > 10 ? 'Fashion Forward' : 'Minimalist',
      totalItems: items.length
    };
  }

  private static generateCombinations(items: ClothingItemAttributes[], maxCombinations: number) {
    // Simple combination generation
    const combinations = [];
    const tops = items.filter(item => ['T-Shirts', 'Shirts'].includes(item.category || ''));
    const bottoms = items.filter(item => ['Pants', 'Shorts'].includes(item.category || ''));

    for (let i = 0; i < Math.min(maxCombinations, tops.length * bottoms.length); i++) {
      const topIndex = i % tops.length;
      const bottomIndex = Math.floor(i / tops.length) % bottoms.length;
      
      if (tops[topIndex] && bottoms[bottomIndex]) {
        combinations.push({
          id: `combo_${i}`,
          items: [tops[topIndex], bottoms[bottomIndex]],
          compatibility: Math.random() * 30 + 70
        });
      }
    }

    return combinations;
  }

  private static filterBySeason(items: ClothingItemAttributes[], season: string) {
    const seasonalCategories: Record<string, string[]> = {
      spring: ['T-Shirts', 'Light Jackets', 'Sneakers'],
      summer: ['T-Shirts', 'Shorts', 'Sandals', 'Dresses'],
      fall: ['Sweaters', 'Jackets', 'Boots', 'Pants'],
      winter: ['Coats', 'Sweaters', 'Boots', 'Pants']
    };

    const categories = seasonalCategories[season.toLowerCase()] || [];
    return items.filter(item => categories.includes(item.category || ''));
  }

  private static filterByOccasion(items: ClothingItemAttributes[], occasion: string) {
    const occasionCategories: Record<string, string[]> = {
      work: ['Shirts', 'Pants', 'Blazers', 'Dress Shoes'],
      casual: ['T-Shirts', 'Jeans', 'Sneakers'],
      formal: ['Suits', 'Dresses', 'Dress Shoes'],
      party: ['Dresses', 'Heels', 'Accessories']
    };

    const categories = occasionCategories[occasion.toLowerCase()] || [];
    return items.filter(item => categories.includes(item.category || ''));
  }

  private static getSeasonalTips(season: string): string[] {
    const tips: Record<string, string[]> = {
      spring: ['Layer light pieces', 'Add colorful accessories'],
      summer: ['Choose breathable fabrics', 'Opt for lighter colors'],
      fall: ['Embrace earth tones', 'Layer for temperature changes'],
      winter: ['Focus on warm layers', 'Add texture with knits']
    };

    return tips[season.toLowerCase()] || ['Dress for comfort and style'];
  }

  private static getOccasionSuggestions(occasion: string): string[] {
    const suggestions: Record<string, string[]> = {
      work: ['Professional silhouettes', 'Neutral color palette'],
      casual: ['Comfortable fabrics', 'Mix and match basics'],
      formal: ['Classic cuts', 'Elegant accessories'],
      party: ['Statement pieces', 'Bold colors or patterns']
    };

    return suggestions[occasion.toLowerCase()] || ['Express your personal style'];
  }

  private static generatePersonalizedTrends(items: ClothingItemAttributes[]) {
    const userCategories = [...new Set(items.map(item => item.category).filter(Boolean))];
    const trends = [
      'Sustainable Fashion',
      'Gender-Neutral Clothing',
      'Vintage Revival',
      'Tech-Wear',
      'Minimalist Aesthetic'
    ];

    return trends.slice(0, 3).map(trend => ({
      name: trend,
      relevance: Math.random() * 30 + 70,
      reason: `Based on your ${userCategories[0] || 'fashion'} collection`
    }));
  }

  private static analyzeColors(items: ClothingItemAttributes[]) {
    const colors = items.reduce((acc: Record<string, number>, item) => {
      if (item.color) {
        acc[item.color] = (acc[item.color] || 0) + 1;
      }
      return acc;
    }, {});

    const dominantColors = Object.entries(colors)
      .sort(([,a], [,b]) => (b as number) - (a as number))
      .slice(0, 5);

    return {
      dominantColors,
      palette: dominantColors.length > 0 ? 'Neutral-based' : 'Diverse',
      recommendations: ['Add more color variety', 'Consider seasonal colors']
    };
  }

  private static colorsMatch(color1: string, color2: string): boolean {
    // Simple color matching logic
    const colorFamilies = {
      neutral: ['black', 'white', 'gray', 'grey', 'beige', 'brown'],
      warm: ['red', 'orange', 'yellow', 'pink'],
      cool: ['blue', 'green', 'purple', 'navy']
    };

    for (const family of Object.values(colorFamilies)) {
      if (family.includes(color1.toLowerCase()) && family.includes(color2.toLowerCase())) {
        return true;
      }
    }

    return color1.toLowerCase() === color2.toLowerCase();
  }
}
