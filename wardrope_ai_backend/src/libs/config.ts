import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

export const config = {
  // Server Configuration
  port: parseInt(process.env.PORT || '3000', 10),
  nodeEnv: process.env.NODE_ENV || 'development',

  // Database Configuration
  database: {
    url: process.env.DATABASE_URL || '',
    host: process.env.POSTGRES_HOST || 'localhost',
    port: parseInt(process.env.POSTGRES_PORT || '5432', 10),
    database: process.env.POSTGRES_DATABASE || 'wardrope_ai',
    user: process.env.POSTGRES_USER || '',
    password: process.env.POSTGRES_PASSWORD || '',
  },

  // Supabase Configuration (Optional - for auth only)
  supabase: {
    url: process.env.SUPABASE_URL || '',
    anonKey: process.env.SUPABASE_ANON_KEY || '',
    serviceRoleKey: process.env.SUPABASE_SERVICE_ROLE_KEY || '',
  },

  // AWS Configuration
  aws: {
    region: process.env.AWS_REGION || 'us-east-1',
    accessKeyId: process.env.AWS_ACCESS_KEY_ID || '',
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY || '',
    s3: {
      bucket: process.env.AWS_S3_BUCKET || 'wardrope-ai-storage',
      region: process.env.AWS_S3_REGION || 'us-east-1',
    },
  },

  // Google AI Configuration
  googleAI: {
    projectId: process.env.GOOGLE_PROJECT_ID || '',
    apiKey: process.env.GOOGLE_AI_API_KEY || '',
    geminiApiKey: process.env.GEMINI_API_KEY || '',
    imagenApiKey: process.env.GOOGLE_IMAGEN_API_KEY || '',
    imagenEndpoint: process.env.GOOGLE_IMAGEN_ENDPOINT || '',
  },

  // JWT Configuration
  jwt: {
    secret: process.env.JWT_SECRET || 'your-secret-key',
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  },

  // Upload Configuration
  upload: {
    maxFileSize: parseInt(process.env.MAX_FILE_SIZE || '10485760', 10), // 10MB
    allowedImageTypes: (process.env.ALLOWED_IMAGE_TYPES || 'image/jpeg,image/png,image/webp').split(','),
    uploadPath: process.env.UPLOAD_PATH || './uploads',
  },

  // API Rate Limiting
  rateLimit: {
    windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '900000', 10), // 15 minutes
    maxRequests: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100', 10),
  },

  // CORS Configuration
  cors: {
    origin: process.env.CORS_ORIGIN || 'http://localhost:3000',
    allowedOrigins: (process.env.ALLOWED_ORIGINS || 'http://localhost:3000,http://localhost:8080').split(','),
  },
};

export default config;
