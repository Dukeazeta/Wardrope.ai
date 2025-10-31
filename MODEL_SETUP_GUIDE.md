# Model Feature Setup Guide

This guide will help you set up and test the complete model functionality including AI-powered model processing and virtual try-on features.

## 🎯 Overview

The model feature includes:
- **AI-powered model processing**: Upload and process user model images with background removal and enhancement
- **Virtual try-on**: Apply clothing items to user models
- **Full-screen model display**: Optimized for mobile viewing down to the navbar
- **BLoC state management**: Robust state management for model operations

## 📋 Prerequisites

### Backend Requirements
- Node.js 18+ installed
- Google Gemini API key (for AI processing)
- TypeScript installed globally

### Frontend Requirements
- Flutter SDK installed
- Existing Flutter project setup
- Required dependencies already added

## 🚀 Backend Setup

### 1. Install Dependencies

```bash
cd wardrope_ai_backend
npm install
```

### 2. Environment Configuration

Create a `.env` file in the `wardrope_ai_backend` directory:

```env
# Google Gemini AI API Key (required)
GEMINI_API_KEY=your_gemini_api_key_here

# Server Configuration
PORT=3000
NODE_ENV=development

# Optional: CORS Configuration
CORS_ORIGIN=http://localhost:3000
```

**Get your Gemini API Key:**
1. Go to [Google AI Studio](https://aistudio.google.com/)
2. Create a new API key
3. Copy the key and add it to your `.env` file

### 3. Start the Backend Server

```bash
# Development mode with auto-reload
npm run dev

# Or build and run
npm run build
npm start
```

The server should start on `http://localhost:3000`

### 4. Verify Backend Services

Test the following endpoints:

```bash
# Health check
curl http://localhost:3000/health

# Image processing status
curl http://localhost:3000/api/image/status

# Model processing status
curl http://localhost:3000/api/model/status
```

## 📱 Frontend Setup

### 1. Install Flutter Dependencies

The required dependencies are already in your `pubspec.yaml`:

```yaml
dependencies:
  flutter_bloc: ^8.1.6
  equatable: ^2.0.5
  http: ^1.1.0
  image_picker: ^1.0.4
  flutter_screenutil: ^5.9.0
```

Run:

```bash
cd wardrope_ai_frontend
flutter pub get
```

### 2. Backend Configuration

The frontend is configured to connect to `http://localhost:3000` by default. If your backend is running on a different port, update:

```dart
// lib/services/model_service.dart
static const String baseUrl = 'http://localhost:3000/api';
```

## 🧪 Testing the Complete Flow

### 1. Start Backend Server

```bash
cd wardrope_ai_backend
npm run dev
```

### 2. Start Flutter App

```bash
cd wardrope_ai_frontend
flutter run
```

### 3. Test Model Upload Flow

1. **Navigate to Model Screen** (bottom nav item #2)
2. **Take a Photo** or **Upload from Gallery**
3. **Observe AI Processing**:
   - Loading indicator appears
   - Image is sent to backend for AI processing
   - Model appears with background removed and enhanced
4. **Verify Full-Screen Display**: Model should fill the screen down to the navbar

### 4. Test Virtual Try-On Flow

1. **Navigate to Wardrobe Screen** (bottom nav item #1)
2. **Long press on any clothing item** to open options
3. **Tap "Add to Model"** (blue button, only appears if model exists)
4. **Observe Processing**:
   - Loading message appears
   - Navigation switches to Model screen
   - Outfit is applied to model using AI
5. **Verify Result**: Model should be shown wearing the selected clothing
6. **Clear Outfit**: Tap "Remove Outfit" to return to base model

## 🔧 Key Features & Implementation

### AI Model Processing
- **Full-body extraction**: Removes background and isolates the person
- **Pose standardization**: Ensures natural standing pose
- **Size normalization**: Optimizes for 9:16 mobile aspect ratio
- **Quality enhancement**: Improves image quality while maintaining natural appearance

### Virtual Try-On
- **Realistic outfit application**: AI applies clothing with proper sizing and positioning
- **Seamless integration**: Natural draping and shadow effects
- **Lighting consistency**: Matches lighting and shadows to the model

### State Management
- **Model BLoC**: Handles all model-related state
- **Error handling**: Comprehensive error handling with user feedback
- **Loading states**: Proper loading indicators for all operations

## 🐛 Troubleshooting

### Common Issues

1. **"GEMINI_API_KEY is not configured"**
   - Solution: Add your Gemini API key to the `.env` file
   - Get API key from [Google AI Studio](https://aistudio.google.com/)

2. **"Model service unavailable"**
   - Solution: Ensure backend server is running on port 3000
   - Check firewall settings

3. **"Failed to process image"**
   - Solution: Check image size (max 10MB) and format (JPG, PNG, WebP)
   - Verify Gemini API key is valid and has quota

4. **Frontend can't connect to backend**
   - Solution: Update `baseUrl` in `model_service.dart` to match your backend URL
   - Check if backend is running and accessible

5. **Build errors related to missing imports**
   - Solution: Run `flutter pub get` to ensure all dependencies are installed
   - Check that all import paths are correct

### Debug Mode

Enable detailed logging:

```bash
# Backend debug mode
DEBUG=* npm run dev

# Flutter debug mode
flutter run --debug
```

## 📊 API Endpoints

### Model Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/model/upload` | Upload and process model image |
| GET | `/api/model/:userId` | Get user's models |
| POST | `/api/model/apply-outfit` | Apply outfit to model |
| DELETE | `/api/model/:modelId` | Delete a model |
| GET | `/api/model/status` | Check service status |

### Request/Response Examples

**Upload Model:**
```bash
curl -X POST \
  http://localhost:3000/api/model/upload \
  -H 'Content-Type: multipart/form-data' \
  -F 'modelImage=@path/to/image.jpg' \
  -F 'userId=user123' \
  -F 'modelType=user'
```

**Apply Outfit:**
```bash
curl -X POST \
  http://localhost:3000/api/model/apply-outfit \
  -H 'Content-Type: application/json' \
  -d '{
    "modelId": "model-uuid",
    "clothingItemId": "item-uuid",
    "outfitData": {
      "category": "Shirts",
      "name": "Blue Shirt",
      "imageUrl": "data:image/jpeg;base64,..."
    }
  }'
```

## 🎯 Next Steps

### Production Considerations

1. **Database Integration**: Replace in-memory storage with a proper database
2. **Authentication**: Implement user authentication and model ownership
3. **Cloud Storage**: Store processed images in cloud storage (AWS S3, Google Cloud Storage)
4. **API Rate Limiting**: Add rate limiting for AI processing endpoints
5. **Image Optimization**: Implement CDN for faster image delivery

### Performance Optimizations

1. **Caching**: Cache processed models and outfit results
2. **Background Processing**: Use message queues for heavy AI processing
3. **Image Compression**: Optimize image sizes for mobile networks
4. **Progressive Loading**: Load low-res previews first, then high-res

## 📞 Support

If you encounter issues:

1. Check the console logs for detailed error messages
2. Verify all environment variables are set correctly
3. Ensure the backend server is running and accessible
4. Test with different image formats and sizes

The model feature is now ready for testing! 🎉