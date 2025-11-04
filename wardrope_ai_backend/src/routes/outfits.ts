import { Router } from 'express';
import { OutfitController } from '../controllers/OutfitController';

const router = Router();

// Outfit management routes
router.get('/:userId', OutfitController.getUserOutfits);
router.post('/:userId', OutfitController.createOutfit);
router.get('/:userId/:outfitId', OutfitController.getOutfit);
router.put('/:userId/:outfitId', OutfitController.updateOutfit);
router.delete('/:userId/:outfitId', OutfitController.deleteOutfit);

// Outfit favorites
router.get('/:userId/favorites', OutfitController.getFavoriteOutfits);
router.post('/:userId/:outfitId/favorite', OutfitController.toggleFavorite);

// Outfit sharing and social features
router.post('/:userId/:outfitId/share', OutfitController.shareOutfit);
router.get('/shared/:shareId', OutfitController.getSharedOutfit);

// Outfit generation and AI
router.post('/:userId/generate', OutfitController.generateOutfitImage);
router.post('/:userId/preview', OutfitController.generateOutfitImagePreview);

// Outfit analytics
router.get('/:userId/stats', OutfitController.getOutfitStats);

export default router;
