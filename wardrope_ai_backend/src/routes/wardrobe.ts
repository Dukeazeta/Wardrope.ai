import { Router } from 'express';
import { WardrobeController, uploadMiddleware } from '../controllers/WardrobeController';

const router = Router();

// Wardrobe management routes
router.get('/:userId/items', WardrobeController.getWardrobeItems);
router.post('/:userId/items', uploadMiddleware, WardrobeController.addClothingItem);
router.get('/:userId/items/:itemId', WardrobeController.getClothingItem);
router.put('/:userId/items/:itemId', uploadMiddleware, WardrobeController.updateClothingItem);
router.delete('/:userId/items/:itemId', WardrobeController.deleteClothingItem);

// Category and search routes
router.get('/:userId/categories', WardrobeController.getCategories);
router.get('/:userId/search', WardrobeController.searchItems);

// AI enhancement routes
router.post('/:userId/items/:itemId/enhance', WardrobeController.generateEnhancedImage);

// Wardrobe analytics
router.get('/:userId/stats', WardrobeController.getWardrobeStats);

export default router;
