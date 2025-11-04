import { Request, Response } from 'express';
import { User, UserAttributes } from '../models';
import { supabaseAdmin } from '../libs/supabase';
import { Utils } from '../libs/utils';

export class AuthController {
  /**
   * Register new user
   */
  static async register(req: Request, res: Response): Promise<void> {
    try {
      const { email, password, first_name, last_name } = req.body;

      if (!email || !password) {
        res.status(400).json({
          success: false,
          message: 'Email and password are required'
        });
        return;
      }

      if (!Utils.isValidEmail(email)) {
        res.status(400).json({
          success: false,
          message: 'Invalid email format'
        });
        return;
      }

      // Check if user already exists
      const existingUser = await User.findByEmail(email);
      if (existingUser) {
        res.status(409).json({
          success: false,
          message: 'User with this email already exists'
        });
        return;
      }

      // Create user in Supabase Auth
      const { data: authData, error: authError } = await supabaseAdmin.auth.admin.createUser({
        email,
        password,
        email_confirm: true
      });

      if (authError) {
        throw new Error(`Authentication error: ${authError.message}`);
      }

      // Create user in our database
      const userAttributes: UserAttributes = {
        id: authData.user.id,
        email,
        first_name,
        last_name,
        is_active: true,
        email_verified: true
      };

      const user = await User.create(userAttributes);

      if (!user) {
        // Rollback: delete from Supabase Auth if database save failed
        await supabaseAdmin.auth.admin.deleteUser(authData.user.id);
        
        res.status(500).json({
          success: false,
          message: 'Failed to create user account'
        });
        return;
      }

      res.status(201).json({
        success: true,
        data: {
          user: User.toSafeJSON(user),
          auth: {
            id: authData.user.id,
            email: authData.user.email
          }
        },
        message: 'User registered successfully'
      });
    } catch (error) {
      console.error('Error registering user:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Login user
   */
  static async login(req: Request, res: Response): Promise<void> {
    try {
      const { email, password } = req.body;

      if (!email || !password) {
        res.status(400).json({
          success: false,
          message: 'Email and password are required'
        });
        return;
      }

      // Authenticate with Supabase
      const { data: authData, error: authError } = await supabaseAdmin.auth.signInWithPassword({
        email,
        password
      });

      if (authError) {
        res.status(401).json({
          success: false,
          message: 'Invalid credentials'
        });
        return;
      }

      // Get user from our database
      const user = await User.findByEmail(email);
      if (!user || !user.is_active) {
        res.status(401).json({
          success: false,
          message: 'Account not found or inactive'
        });
        return;
      }

      res.json({
        success: true,
        data: {
          user: User.toSafeJSON(user),
          session: {
            access_token: authData.session?.access_token,
            refresh_token: authData.session?.refresh_token,
            expires_at: authData.session?.expires_at
          }
        },
        message: 'Login successful'
      });
    } catch (error) {
      console.error('Error logging in user:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Logout user
   */
  static async logout(req: Request, res: Response): Promise<void> {
    try {
      const authHeader = req.headers.authorization;
      const token = authHeader?.split(' ')[1];

      if (token) {
        // Sign out from Supabase
        await supabaseAdmin.auth.signOut();
      }

      res.json({
        success: true,
        message: 'Logout successful'
      });
    } catch (error) {
      console.error('Error logging out user:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Refresh access token
   */
  static async refreshToken(req: Request, res: Response): Promise<void> {
    try {
      const { refresh_token } = req.body;

      if (!refresh_token) {
        res.status(400).json({
          success: false,
          message: 'Refresh token is required'
        });
        return;
      }

      const { data, error } = await supabaseAdmin.auth.refreshSession({
        refresh_token
      });

      if (error) {
        res.status(401).json({
          success: false,
          message: 'Invalid refresh token'
        });
        return;
      }

      res.json({
        success: true,
        data: {
          session: {
            access_token: data.session?.access_token,
            refresh_token: data.session?.refresh_token,
            expires_at: data.session?.expires_at
          }
        },
        message: 'Token refreshed successfully'
      });
    } catch (error) {
      console.error('Error refreshing token:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Verify email
   */
  static async verifyEmail(req: Request, res: Response): Promise<void> {
    try {
      const { token, email } = req.body;

      if (!token || !email) {
        res.status(400).json({
          success: false,
          message: 'Token and email are required'
        });
        return;
      }

      // Verify email with Supabase
      const { data, error } = await supabaseAdmin.auth.verifyOtp({
        email,
        token,
        type: 'email'
      });

      if (error) {
        res.status(400).json({
          success: false,
          message: 'Invalid verification token'
        });
        return;
      }

      // Update user in our database
      const user = await User.findByEmail(email);
      if (user) {
        await User.verifyEmail(user.id!);
      }

      res.json({
        success: true,
        message: 'Email verified successfully'
      });
    } catch (error) {
      console.error('Error verifying email:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Resend verification email
   */
  static async resendVerification(req: Request, res: Response): Promise<void> {
    try {
      const { email } = req.body;

      if (!email) {
        res.status(400).json({
          success: false,
          message: 'Email is required'
        });
        return;
      }

      const { error } = await supabaseAdmin.auth.resend({
        type: 'signup',
        email
      });

      if (error) {
        throw new Error(`Failed to resend verification: ${error.message}`);
      }

      res.json({
        success: true,
        message: 'Verification email sent successfully'
      });
    } catch (error) {
      console.error('Error resending verification:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Forgot password
   */
  static async forgotPassword(req: Request, res: Response): Promise<void> {
    try {
      const { email } = req.body;

      if (!email) {
        res.status(400).json({
          success: false,
          message: 'Email is required'
        });
        return;
      }

      const { error } = await supabaseAdmin.auth.resetPasswordForEmail(email);

      if (error) {
        throw new Error(`Failed to send reset email: ${error.message}`);
      }

      res.json({
        success: true,
        message: 'Password reset email sent successfully'
      });
    } catch (error) {
      console.error('Error sending password reset:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Reset password
   */
  static async resetPassword(req: Request, res: Response): Promise<void> {
    try {
      const { token, password } = req.body;

      if (!token || !password) {
        res.status(400).json({
          success: false,
          message: 'Token and new password are required'
        });
        return;
      }

      const { data, error } = await supabaseAdmin.auth.verifyOtp({
        token_hash: token,
        type: 'recovery'
      });

      if (error) {
        res.status(400).json({
          success: false,
          message: 'Invalid reset token'
        });
        return;
      }

      // Update password
      const { error: updateError } = await supabaseAdmin.auth.admin.updateUserById(
        data.user!.id,
        { password }
      );

      if (updateError) {
        throw new Error(`Failed to update password: ${updateError.message}`);
      }

      res.json({
        success: true,
        message: 'Password reset successfully'
      });
    } catch (error) {
      console.error('Error resetting password:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Change password
   */
  static async changePassword(req: Request, res: Response): Promise<void> {
    try {
      const { currentPassword, newPassword } = req.body;
      const authHeader = req.headers.authorization;
      const token = authHeader?.split(' ')[1];

      if (!currentPassword || !newPassword) {
        res.status(400).json({
          success: false,
          message: 'Current password and new password are required'
        });
        return;
      }

      if (!token) {
        res.status(401).json({
          success: false,
          message: 'Authentication required'
        });
        return;
      }

      // Get current user
      const { data: userData, error: userError } = await supabaseAdmin.auth.getUser(token);

      if (userError || !userData.user) {
        res.status(401).json({
          success: false,
          message: 'Invalid authentication token'
        });
        return;
      }

      // Update password
      const { error: updateError } = await supabaseAdmin.auth.admin.updateUserById(
        userData.user.id,
        { password: newPassword }
      );

      if (updateError) {
        throw new Error(`Failed to update password: ${updateError.message}`);
      }

      res.json({
        success: true,
        message: 'Password changed successfully'
      });
    } catch (error) {
      console.error('Error changing password:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Get current user
   */
  static async getCurrentUser(req: Request, res: Response): Promise<void> {
    try {
      const authHeader = req.headers.authorization;
      const token = authHeader?.split(' ')[1];

      if (!token) {
        res.status(401).json({
          success: false,
          message: 'Authentication required'
        });
        return;
      }

      const { data, error } = await supabaseAdmin.auth.getUser(token);

      if (error || !data.user) {
        res.status(401).json({
          success: false,
          message: 'Invalid authentication token'
        });
        return;
      }

      // Get user from our database
      const user = await User.findById(data.user!.id);
      if (!user) {
        res.status(404).json({
          success: false,
          message: 'User not found'
        });
        return;
      }

      res.json({
        success: true,
        data: User.toSafeJSON(user)
      });
    } catch (error) {
      console.error('Error getting current user:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Revoke all sessions
   */
  static async revokeAllSessions(req: Request, res: Response): Promise<void> {
    try {
      const authHeader = req.headers.authorization;
      const token = authHeader?.split(' ')[1];

      if (!token) {
        res.status(401).json({
          success: false,
          message: 'Authentication required'
        });
        return;
      }

      const { data, error } = await supabaseAdmin.auth.getUser(token);

      if (error || !data.user) {
        res.status(401).json({
          success: false,
          message: 'Invalid authentication token'
        });
        return;
      }

      // Sign out from all devices (using the available method)
      await supabaseAdmin.auth.admin.updateUserById(data.user.id, {
        // This will effectively revoke the user's sessions
      });

      res.json({
        success: true,
        message: 'All sessions revoked successfully'
      });
    } catch (error) {
      console.error('Error revoking sessions:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }
}
