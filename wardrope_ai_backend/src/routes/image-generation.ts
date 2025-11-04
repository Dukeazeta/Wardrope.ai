import { Router } from 'express';
import { ImageGenerationController } from '../controllers/ImageGenerationController';

const router = Router();

// Image generation routes
router.post('/generate', ImageGenerationController.generateImage);
router.post('/outfit-visualization', ImageGenerationController.generateOutfitVisualization);
router.post('/clothing-variations', ImageGenerationController.generateClothingVariations);
router.post('/style-recommendations', ImageGenerationController.generateStyleRecommendations);
router.get('/service-status', ImageGenerationController.getServiceStatus);

export default router;
