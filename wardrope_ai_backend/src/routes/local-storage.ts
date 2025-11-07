import { Router } from 'express';
import { localStorageController } from '../controllers/LocalStorageController';

const router = Router();

// USER MANAGEMENT ROUTES

/**
 * @route GET /api/local/user/profile
 * @desc Get user profile and settings
 * @access Public
 */
router.get('/user/profile', localStorageController.getUserProfile);

/**
 * @route PUT /api/local/user/profile
 * @desc Update user profile information
 * @access Public
 * @body {
 *   name?: string,
 *   email?: string
 * }
 */
router.put('/user/profile', localStorageController.updateUserProfile);

/**
 * @route PUT /api/local/user/settings
 * @desc Update user settings
 * @access Public
 * @body {
 *   settings: object
 * }
 */
router.put('/user/settings', localStorageController.updateUserSettings);

// CLOTHING ITEMS ROUTES

/**
 * @route GET /api/local/clothing
 * @desc Get all clothing items with optional filters
 * @access Public
 * @query {
 *   category?: string,
 *   style?: string,
 *   color?: string
 * }
 */
router.get('/clothing', localStorageController.getClothingItems);

/**
 * @route POST /api/local/clothing
 * @desc Create new clothing item
 * @access Public
 * @body {
 *   name: string,
 *   category: string,
 *   style: string,
 *   colors: string[],
 *   material?: string,
 *   size?: string,
 *   brand?: string,
 *   original_image_url: string,
 *   processed_image_url?: string,
 *   metadata?: object,
 *   quality_score?: number
 * }
 */
router.post('/clothing', localStorageController.createClothingItem);

/**
 * @route PUT /api/local/clothing/:id
 * @desc Update clothing item
 * @access Public
 * @body: Partial<ClothingItem>
 */
router.put('/clothing/:id', localStorageController.updateClothingItem);

/**
 * @route DELETE /api/local/clothing/:id
 * @desc Delete clothing item
 * @access Public
 */
router.delete('/clothing/:id', localStorageController.deleteClothingItem);

// OUTFITS ROUTES

/**
 * @route GET /api/local/outfits
 * @desc Get all outfits with optional filters
 * @access Public
 * @query {
 *   occasion?: string,
 *   style?: string,
 *   season?: string,
 *   favorite?: boolean
 * }
 */
router.get('/outfits', localStorageController.getOutfits);

/**
 * @route POST /api/local/outfits
 * @desc Create new outfit
 * @access Public
 * @body {
 *   name: string,
 *   description?: string,
 *   occasion: string,
 *   style: string,
 *   season?: string,
 *   clothing_item_ids: string[],
 *   model_image_url?: string,
 *   visualization_url?: string,
 *   metadata?: object,
 *   is_favorite?: boolean
 * }
 */
router.post('/outfits', localStorageController.createOutfit);

/**
 * @route PUT /api/local/outfits/:id
 * @desc Update outfit
 * @access Public
 * @body: Partial<Outfit>
 */
router.put('/outfits/:id', localStorageController.updateOutfit);

/**
 * @route DELETE /api/local/outfits/:id
 * @desc Delete outfit
 * @access Public
 */
router.delete('/outfits/:id', localStorageController.deleteOutfit);

// USER MODELS ROUTES

/**
 * @route GET /api/local/user-models
 * @desc Get all user models
 * @access Public
 */
router.get('/user-models', localStorageController.getUserModels);

/**
 * @route POST /api/local/user-models
 * @desc Create new user model
 * @access Public
 * @body {
 *   name: string,
 *   original_image_url: string,
 *   processed_image_url?: string,
 *   model_type: string,
 *   status: string,
 *   metadata?: object
 * }
 */
router.post('/user-models', localStorageController.createUserModel);

/**
 * @route PUT /api/local/user-models/:id
 * @desc Update user model
 * @access Public
 * @body: Partial<UserModel>
 */
router.put('/user-models/:id', localStorageController.updateUserModel);

/**
 * @route DELETE /api/local/user-models/:id
 * @desc Delete user model
 * @access Public
 */
router.delete('/user-models/:id', localStorageController.deleteUserModel);

// STATISTICS ROUTES

/**
 * @route GET /api/local/stats/wardrobe
 * @desc Get wardrobe statistics and analytics
 * @access Public
 */
router.get('/stats/wardrobe', localStorageController.getWardrobeStats);

export default router;