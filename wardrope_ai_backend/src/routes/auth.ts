import { Router } from 'express';
import { AuthController } from '../controllers/AuthController';

const router = Router();

// Authentication routes
router.post('/register', AuthController.register);
router.post('/login', AuthController.login);
router.post('/logout', AuthController.logout);
router.post('/refresh', AuthController.refreshToken);

// Email verification
router.post('/verify-email', AuthController.verifyEmail);
router.post('/resend-verification', AuthController.resendVerification);

// Password management
router.post('/forgot-password', AuthController.forgotPassword);
router.post('/reset-password', AuthController.resetPassword);
router.put('/change-password', AuthController.changePassword);

// Session management
router.get('/me', AuthController.getCurrentUser);
router.delete('/sessions', AuthController.revokeAllSessions);

export default router;
