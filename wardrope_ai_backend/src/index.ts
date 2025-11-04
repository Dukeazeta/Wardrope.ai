import express, { Application, Request, Response, NextFunction } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import dotenv from 'dotenv';
import routes from './routes';
import { errorHandler } from './middlewares/errorHandler';

// Load environment variables
dotenv.config();

const app: Application = express();
const PORT: number = parseInt(process.env.PORT || '3000', 10);

// Middleware
app.use(helmet());
app.use(cors());
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
app.use('*', (req: Request, res: Response<ErrorResponse>) => {
  res.status(404).json({
    error: 'Route not found',
    path: req.originalUrl
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Server is running on port ${PORT}`);
  console.log(`📊 Health check: http://localhost:${PORT}/health`);
  console.log(`🔧 Environment: ${process.env.NODE_ENV || 'development'}`);
});

export default app;