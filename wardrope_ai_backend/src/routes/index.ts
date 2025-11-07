import { Router } from 'express';
// Legacy routes (commented out for hybrid architecture)
// import authRoutes from './auth';
// import userRoutes from './users';
// import wardrobeRoutes from './wardrobe';
// import modelRoutes from './model';
// import imageRoutes from './image';
// import outfitRoutes from './outfits';
// import aiStylistRoutes from './ai-stylist';
import simplifiedAIRoutes from './simplified-ai';
import localStorageRoutes from './local-storage';

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

// Hybrid Architecture Routes Only
router.use('/simplified-ai', simplifiedAIRoutes);
router.use('/local', localStorageRoutes);

export default router;
