import { Router } from 'express';
import authRoutes from './auth';
import userRoutes from './users';
import wardrobeRoutes from './wardrobe';
import modelRoutes from './model';
import imageRoutes from './image';
import outfitRoutes from './outfits';
import aiStylistRoutes from './ai-stylist';

const router = Router();

// Health check route
router.get('/health', (req, res) => {
  res.json({
    success: true,
    message: 'Wardrope.ai API is running',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

// API version
router.get('/version', (req, res) => {
  res.json({
    success: true,
    data: {
      version: '1.0.0',
      apiVersion: 'v1',
      name: 'Wardrope.ai Backend API'
    }
  });
});

// Mount route modules
router.use('/auth', authRoutes);
router.use('/users', userRoutes);
router.use('/wardrobe', wardrobeRoutes);
router.use('/model', modelRoutes);
router.use('/image', imageRoutes);
router.use('/outfits', outfitRoutes);
router.use('/ai-stylist', aiStylistRoutes);

export default router;
