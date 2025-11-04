import { Router } from 'express';
import { UserController } from '../controllers/UserController';

const router = Router();

// Get user profile
router.get('/:userId', UserController.getProfile);

// Update user profile
router.put('/:userId', UserController.updateProfile);

// Get user preferences
router.get('/:userId/preferences', UserController.getPreferences);

// Update user preferences
router.put('/:userId/preferences', UserController.updatePreferences);

// Delete user account
router.delete('/:userId', UserController.deleteAccount);

export default router;
