import { Router } from 'express';
import { AIStylistController } from '../controllers/AIStylistController';

const router = Router();

// AI Stylist recommendation routes
router.post('/:userId/recommendations', AIStylistController.getOutfitRecommendations);
router.post('/:userId/style-analysis', AIStylistController.analyzePersonalStyle);
router.post('/:userId/outfit-suggestions', AIStylistController.suggestOutfitCombinations);

// Seasonal and occasion-based recommendations
router.get('/:userId/seasonal/:season', AIStylistController.getSeasonalRecommendations);
router.post('/:userId/occasion/:occasion', AIStylistController.getOccasionOutfits);

// Style preferences and learning
router.get('/:userId/style-profile', AIStylistController.getStyleProfile);
router.put('/:userId/style-profile', AIStylistController.updateStyleProfile);
router.post('/:userId/feedback', AIStylistController.submitOutfitFeedback);

// Trend analysis
router.get('/trends/current', AIStylistController.getCurrentTrends);
router.post('/:userId/trends/personalized', AIStylistController.getPersonalizedTrends);

// Color analysis and matching
router.post('/:userId/color-analysis', AIStylistController.analyzeColorPalette);
router.post('/:userId/color-match', AIStylistController.getColorMatchingItems);

export default router;
