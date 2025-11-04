import { Router } from 'express';
import { ImageController } from '../controllers/ImageController';
import multer from 'multer';
import path from 'path';

const router = Router();

// Configure multer for image uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/images/');
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB limit
  },
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Only image files are allowed!'));
    }
  }
});

// Image processing routes
router.post('/process', upload.single('image'), ImageController.processClothingImage);
router.get('/status', ImageController.getServiceStatus);
router.post('/remove-background', upload.single('image'), ImageController.removeBackground);
router.post('/enhance', upload.single('image'), ImageController.enhanceImage);

export default router;
