import { Router } from 'express';
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { simplifiedAIController } from '../controllers/SimplifiedAIController';

const router = Router();

// Configure multer for file uploads
// Use memory storage for Vercel serverless (filesystem is read-only except /tmp)
// For local development, we can optionally use disk storage
const isVercel = process.env.VERCEL === '1' || process.env.NODE_ENV === 'production';

let storage: multer.StorageEngine;
if (isVercel) {
  // Use memory storage for Vercel
  storage = multer.memoryStorage();
} else {
  // Use disk storage for local development
  storage = multer.diskStorage({
    destination: (req, file, cb) => {
      const uploadDir = path.join(process.cwd(), 'uploads');
      if (!fs.existsSync(uploadDir)) {
        fs.mkdirSync(uploadDir, { recursive: true });
      }
      cb(null, uploadDir);
    },
    filename: (req, file, cb) => {
      const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
      cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
    }
  });
}

const upload = multer({
  storage,
  limits: {
    fileSize: 10 * 1024 * 1024 // 10MB limit
  },
  fileFilter: (req, file, cb) => {
    // Accept only image files
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Only image files are allowed'));
    }
  }
});

/**
 * @route GET /api/simplified-ai/status
 * @desc Check AI service status and availability
 * @access Public
 */
router.get('/status', simplifiedAIController.checkStatus);

/**
 * @route POST /api/simplified-ai/process-model
 * @desc Process user model photo for outfit fitting
 * @access Public
 * @body {
 *   enhance_quality?: boolean,
 *   remove_background?: boolean,
 *   upscale?: boolean
 * }
 */
router.post('/process-model', upload.single('image'), simplifiedAIController.processModel);

/**
 * @route POST /api/simplified-ai/process-clothing
 * @desc Process clothing item for catalog management
 * @access Public
 * @body {
 *   remove_background?: boolean,
 *   enhance_quality?: boolean,
 *   categorize?: boolean,
 *   extract_colors?: boolean
 * }
 */
router.post('/process-clothing', upload.single('image'), simplifiedAIController.processClothing);

/**
 * @route POST /api/simplified-ai/generate-outfit
 * @desc Generate outfit visualization with model and clothing items
 * @access Public
 * @body {
 *   model_image_path: string,
 *   clothing_item_paths: string[],
 *   options?: {
 *     occasion?: string,
 *     style?: string,
 *     season?: string,
 *     color_scheme?: string
 *   }
 * }
 */
router.post('/generate-outfit', simplifiedAIController.generateOutfit);

/**
 * @route POST /api/simplified-ai/recommendations
 * @desc Generate personalized style recommendations
 * @access Public
 * @body {
 *   preferences: object,
 *   wardrobe_items: object[],
 *   count?: number (default: 5)
 * }
 */
router.post('/recommendations', simplifiedAIController.getRecommendations);

export default router;