import { Router } from 'express';
import multer from 'multer';
import { ModelController } from '../controllers/ModelController';

const router = Router();

// Configure multer for file uploads
const storage = multer.memoryStorage();
const upload = multer({
  storage,
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB limit
  },
  fileFilter: (req: any, file: any, cb: any) => {
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Only image files are allowed'));
    }
  },
});

// Model management routes
router.post('/upload', upload.single('model'), ModelController.uploadModel);
router.get('/user/:userId', ModelController.getUserModels);
router.get('/primary/:userId', ModelController.getPrimaryModel);
router.post('/primary/:userId/:modelId', ModelController.setPrimaryModel);
router.delete('/:modelId', ModelController.deleteModel);

// Model processing routes
router.get('/:modelId/status', ModelController.getProcessingStatus);
router.get('/:modelId/progress', ModelController.getProcessingProgress);
router.post('/:modelId/regenerate', ModelController.regenerateModel);

// Model application routes
router.post('/:modelId/apply-outfit', ModelController.applyOutfitToModel);

export default router;