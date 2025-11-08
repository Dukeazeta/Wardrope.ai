import express, { Application, Request, Response, NextFunction } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import dotenv from 'dotenv';
import routes from './routes';
import { errorHandler } from './middlewares/errorHandler';
import { hybridSQLiteService } from './libs/sqlite';

// Load environment variables
dotenv.config();

const app: Application = express();

// Middleware
app.use(helmet({
  crossOriginResourcePolicy: { policy: "cross-origin" }
}));
// CORS configuration - allow all origins for both development and production
// In production, you may want to restrict this to specific domains
app.use(cors({
  origin: process.env.CORS_ORIGIN || true, // Allow all origins, or use env var for specific origin
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Accept', 'Origin', 'X-Requested-With', 'X-Custom-Header'],
  exposedHeaders: ['Content-Length', 'Content-Type'],
  maxAge: 86400 // 24 hours
}));
app.use(morgan('combined'));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Types
interface ApiResponse {
  message: string;
  version: string;
  status: string;
}

interface HealthResponse {
  status: string;
  timestamp: string;
  uptime: number;
}

interface ErrorResponse {
  error: string;
  message?: string;
  path?: string;
}

// Basic route
app.get('/', (req: Request, res: Response<ApiResponse>) => {
  res.json({
    message: 'Wardrope AI Backend API',
    version: '1.0.0',
    status: 'running'
  });
});

// Health check route
app.get('/health', (req: Request, res: Response<HealthResponse>) => {
  res.json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// API Routes
app.use('/api', routes);

// Error handling middleware
app.use(errorHandler);

// 404 handler
app.use((req: Request, res: Response<ErrorResponse>) => {
  res.status(404).json({
    error: 'Route not found',
    path: req.originalUrl
  });
});

// Initialize services for serverless environment
let servicesInitialized = false;

async function ensureServicesInitialized() {
  if (!servicesInitialized) {
    try {
      await hybridSQLiteService.initialize();
      console.log('✅ Hybrid SQLite database initialized');
      servicesInitialized = true;
    } catch (error) {
      console.error('❌ Failed to initialize services:', error);
      throw error;
    }
  }
}

// Export for Vercel
export default async (req: Request, res: Response) => {
  await ensureServicesInitialized();
  return app(req, res);
};