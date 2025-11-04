# Wardrope.AI Backend

A scalable Express.js backend for Wardrope.AI - an intelligent wardrobe management and AI stylist application.

## 🚀 Features

- **User Authentication** - Secure authentication via Supabase
- **Wardrobe Management** - Add, organize, and manage clothing items
- **AI Image Generation** - Generate outfit visualizations using Google Imagen (Nano/Banana)
- **3D Model Integration** - Upload and process user models for virtual try-ons
- **Outfit Creation** - Create and manage outfit combinations
- **AI Stylist** - Get personalized outfit recommendations
- **Cloud Storage** - Secure file storage with AWS S3
- **Image Processing** - Automatic image optimization and resizing

## 🏗️ Architecture

```
src/
├── controllers/       # Request handlers with business logic
├── models/           # Database models and static methods
├── routes/           # API route definitions
├── services/         # External service integrations
├── libs/             # Core utilities and configurations
├── middlewares/      # Express middlewares
└── database/         # Database schemas and migrations
```

## 🛠️ Tech Stack

- **Runtime**: Node.js with TypeScript
- **Framework**: Express.js
- **Database**: PostgreSQL with Supabase
- **Storage**: AWS S3
- **AI**: Google Imagen (Nano/Banana models)
- **Image Processing**: Sharp
- **Authentication**: Supabase Auth

## 📋 Prerequisites

- Node.js 18+ 
- PostgreSQL database
- AWS account with S3 access
- Google Cloud account with Imagen API access
- Supabase project

## ⚙️ Environment Setup

Create a `.env` file in the root directory:

```env
# Server Configuration
PORT=3000
NODE_ENV=development

# Database Configuration
DATABASE_URL=postgresql://username:password@localhost:5432/wardrope_ai
DB_HOST=localhost
DB_PORT=5432
DB_NAME=wardrope_ai
DB_USER=your_username
DB_PASSWORD=your_password

# Supabase Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_anon_key
SUPABASE_SERVICE_KEY=your_service_key

# AWS S3 Configuration
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
AWS_REGION=us-east-1
AWS_S3_BUCKET_NAME=wardrope-ai-storage

# Google Imagen Configuration
GOOGLE_PROJECT_ID=your_project_id
GOOGLE_LOCATION=us-central1
GOOGLE_APPLICATION_CREDENTIALS=path/to/service-account.json

# Security
JWT_SECRET=your_jwt_secret
CORS_ORIGIN=http://localhost:3000
```

## 🚀 Quick Start

1. **Clone and Install**
   ```bash
   git clone <repository-url>
   cd wardrope_ai_backend
   npm install
   ```

2. **Database Setup**
   ```bash
   # Run database migrations
   npm run db:migrate
   
   # Or manually execute the schema
   psql -d wardrope_ai -f database/schema.sql
   ```

3. **Start Development Server**
   ```bash
   npm run dev
   ```

4. **Build for Production**
   ```bash
   npm run build
   npm start
   ```

## 📚 API Documentation

### Authentication
- `POST /api/auth/login` - User login
- `POST /api/auth/register` - User registration
- `POST /api/auth/logout` - User logout
- `GET /api/auth/profile` - Get user profile

### Wardrobe Management
- `GET /api/wardrobe/:userId/items` - Get user's clothing items
- `POST /api/wardrobe/:userId/items` - Add new clothing item
- `GET /api/wardrobe/:userId/items/:itemId` - Get specific item
- `PUT /api/wardrobe/:userId/items/:itemId` - Update clothing item
- `DELETE /api/wardrobe/:userId/items/:itemId` - Delete clothing item
- `GET /api/wardrobe/:userId/search` - Search clothing items

### User Models (3D/Photos)
- `POST /api/models/:userId/upload` - Upload user model
- `GET /api/models/:userId` - Get user's models
- `GET /api/models/:modelId` - Get specific model
- `PUT /api/models/:modelId` - Update model
- `DELETE /api/models/:modelId` - Delete model
- `POST /api/models/:modelId/apply-outfit` - Apply outfit to model

### Outfits
- `GET /api/outfits/:userId` - Get user's outfits
- `POST /api/outfits/:userId` - Create new outfit
- `GET /api/outfits/:outfitId` - Get specific outfit
- `PUT /api/outfits/:outfitId` - Update outfit
- `DELETE /api/outfits/:outfitId` - Delete outfit
- `POST /api/outfits/:userId/generate-image` - Generate outfit visualization
- `POST /api/outfits/:userId/generate-preview` - Generate outfit preview

### AI Stylist
- `POST /api/ai-stylist/:userId/recommendations` - Get outfit recommendations
- `POST /api/ai-stylist/:userId/style-analysis` - Analyze personal style
- `POST /api/ai-stylist/:userId/seasonal-suggestions` - Get seasonal suggestions

### Image Generation
- `POST /api/image-generation/generate` - Generate AI images
- `POST /api/image-generation/enhance` - Enhance existing images
- `GET /api/image-generation/status/:jobId` - Check generation status

## 🎨 Image Generation Features

### Outfit Visualization
Generate realistic images of users wearing specific outfits:
- Uses user's uploaded model photo as base
- Combines multiple clothing items
- Supports different styles and occasions
- Natural lighting and backgrounds

### AI Enhancement
Improve clothing item photos:
- Professional product photography style
- Background removal and replacement
- Color and lighting enhancement
- Multiple style variations

## 🗄️ Database Schema

### Core Tables
- `users` - User accounts and profiles
- `clothing_items` - Individual wardrobe items
- `user_models` - User photos/3D models
- `outfits` - Outfit combinations
- `ai_recommendations` - Stylist suggestions

### Key Features
- JSON fields for flexible metadata storage
- Array fields for tags and categories
- Optimized indexes for search performance
- Foreign key constraints for data integrity

## 🔒 Security Features

- JWT-based authentication
- Supabase Auth integration
- Request rate limiting
- Input validation and sanitization
- CORS protection
- Secure file upload handling

## 📈 Performance Optimizations

- Image compression and resizing
- Database query optimization
- Caching for frequently accessed data
- Efficient file storage with S3
- Background processing for AI tasks

## 🧪 Testing

```bash
# Run all tests
npm test

# Run tests with coverage
npm run test:coverage

# Run specific test file
npm test -- --grep "UserController"
```

## 📦 Deployment

### Docker Deployment
```bash
# Build image
docker build -t wardrope-ai-backend .

# Run container
docker run -p 3000:3000 --env-file .env wardrope-ai-backend
```

### Environment-Specific Configurations
- Development: Auto-reload with nodemon
- Staging: Reduced logging, performance monitoring
- Production: Optimized builds, health checks

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For support and questions:
- Create an issue on GitHub
- Check the [API documentation](API_ROUTES_DOCUMENTATION.md)
- Review the [Model Setup Guide](MODEL_SETUP_GUIDE.md)

## 🔄 Version History

- **v1.0.0** - Initial release with core wardrobe management
- **v1.1.0** - Added AI image generation with Google Imagen
- **v1.2.0** - Enhanced outfit visualization and user models
- **v1.3.0** - AWS S3 integration and performance improvements

---

Built with ❤️ for fashion enthusiasts and AI lovers
