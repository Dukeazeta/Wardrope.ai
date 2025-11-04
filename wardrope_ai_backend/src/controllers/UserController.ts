import { Request, Response } from 'express';
import { User, UserAttributes } from '../models';
import { Utils } from '../libs/utils';

export class UserController {
  /**
   * Get user profile
   */
  static async getProfile(req: Request, res: Response): Promise<void> {
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

      // Remove password hash from response
      const { password_hash, ...userProfile } = user;

      res.status(200).json({
        success: true,
        data: userProfile
      });
    } catch (error) {
      console.error('Error getting user profile:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Update user profile
   */
  static async updateProfile(req: Request, res: Response): Promise<void> {
    try {
      const { userId } = req.params;
      const updateData = req.body;

      if (!userId) {
        res.status(400).json({
          success: false,
          message: 'User ID is required'
        });
        return;
      }

      // Remove sensitive fields from update data
      const { password_hash, id, created_at, updated_at, ...allowedUpdateData } = updateData;

      // Validate update data
      const validationError = Utils.validateUserUpdateData(allowedUpdateData);
      if (validationError) {
        res.status(400).json({
          success: false,
          message: validationError
        });
        return;
      }

      const updatedUser = await User.update(userId, allowedUpdateData);

      if (!updatedUser) {
        res.status(404).json({
          success: false,
          message: 'User not found'
        });
        return;
      }

      // Remove password hash from response
      const { password_hash: _, ...userProfile } = updatedUser;

      res.status(200).json({
        success: true,
        message: 'Profile updated successfully',
        data: userProfile
      });
    } catch (error) {
      console.error('Error updating user profile:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Upload profile image
   */
  static async uploadProfileImage(req: Request, res: Response): Promise<void> {
    try {
      const { userId } = req.params;

      if (!userId) {
        res.status(400).json({
          success: false,
          message: 'User ID is required'
        });
        return;
      }

      if (!req.file) {
        res.status(400).json({
          success: false,
          message: 'No image file provided'
        });
        return;
      }

      // Process and upload image
      const imageUrl = await Utils.processAndUploadImage(req.file, `users/${userId}/profile`);

      // Update user profile with new image URL
      const updatedUser = await User.update(userId, { profile_image_url: imageUrl });

      if (!updatedUser) {
        res.status(404).json({
          success: false,
          message: 'User not found'
        });
        return;
      }

      res.status(200).json({
        success: true,
        message: 'Profile image uploaded successfully',
        data: {
          profile_image_url: imageUrl
        }
      });
    } catch (error) {
      console.error('Error uploading profile image:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Get user preferences
   */
  static async getPreferences(req: Request, res: Response): Promise<void> {
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

      res.status(200).json({
        success: true,
        data: user.preferences || {}
      });
    } catch (error) {
      console.error('Error getting user preferences:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Update user preferences
   */
  static async updatePreferences(req: Request, res: Response): Promise<void> {
    try {
      const { userId } = req.params;
      const { preferences } = req.body;

      if (!userId) {
        res.status(400).json({
          success: false,
          message: 'User ID is required'
        });
        return;
      }

      if (!preferences || typeof preferences !== 'object') {
        res.status(400).json({
          success: false,
          message: 'Valid preferences object is required'
        });
        return;
      }

      const updatedUser = await User.update(userId, { preferences });

      if (!updatedUser) {
        res.status(404).json({
          success: false,
          message: 'User not found'
        });
        return;
      }

      res.status(200).json({
        success: true,
        message: 'Preferences updated successfully',
        data: updatedUser.preferences
      });
    } catch (error) {
      console.error('Error updating user preferences:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Complete onboarding
   */
  static async completeOnboarding(req: Request, res: Response): Promise<void> {
    try {
      const { userId } = req.params;

      if (!userId) {
        res.status(400).json({
          success: false,
          message: 'User ID is required'
        });
        return;
      }

      const updatedUser = await User.update(userId, { onboarding_completed: true });

      if (!updatedUser) {
        res.status(404).json({
          success: false,
          message: 'User not found'
        });
        return;
      }

      res.status(200).json({
        success: true,
        message: 'Onboarding completed successfully',
        data: {
          onboarding_completed: true
        }
      });
    } catch (error) {
      console.error('Error completing onboarding:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Delete user account
   */
  static async deleteAccount(req: Request, res: Response): Promise<void> {
    try {
      const { userId } = req.params;

      if (!userId) {
        res.status(400).json({
          success: false,
          message: 'User ID is required'
        });
        return;
      }

      const deleted = await User.delete(userId);

      if (!deleted) {
        res.status(404).json({
          success: false,
          message: 'User not found'
        });
        return;
      }

      res.status(200).json({
        success: true,
        message: 'Account deleted successfully'
      });
    } catch (error) {
      console.error('Error deleting user account:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }
}
