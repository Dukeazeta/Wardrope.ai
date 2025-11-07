# Wardrope.ai Deployment Guide

## Backend Deployment (Vercel)

### Prerequisites
- Vercel account (free)
- GitHub account
- Google Gemini API key

### Steps to Deploy

1. **Install Vercel CLI**
   ```bash
   npm i -g vercel
   ```

2. **Login to Vercel**
   ```bash
   vercel login
   ```

3. **Configure Environment Variables**
   Create a `.env.production` file:
   ```
   GEMINI_API_KEY=your_gemini_api_key_here
   NODE_ENV=production
   ```

4. **Deploy to Vercel**
   ```bash
   cd wardrope_ai_backend
   vercel --prod
   ```

5. **Note your Vercel URL** (e.g., `https://wardrobe-ai-backend.vercel.app`)

### Configure Domain (Optional)
1. Go to Vercel dashboard
2. Select your project
3. Go to Settings → Domains
4. Add your custom domain

## Frontend Configuration

### Update Production URL
1. Open `lib/config/app_config.dart`
2. Set `_isDevelopment = false`
3. Update `_productionBaseUrl` with your Vercel URL:
   ```dart
   static const String _productionBaseUrl = 'https://your-vercel-app.vercel.app/api/simplified-ai';
   ```

### Test Production Build
```bash
cd wardrope_ai_frontend
flutter build apk --release
# or
flutter build ios --release
```

## Environment Variables

### Backend (.env)
```
GEMINI_API_KEY=your_gemini_api_key
PORT=3000
NODE_ENV=production
UPLOAD_MAX_SIZE=10485760
UPLOAD_DIR=uploads
CORS_ORIGIN=*
LOG_LEVEL=info
```

### Frontend Configuration
The frontend uses `lib/config/app_config.dart` for environment settings.

## Testing Checklist

### Backend Testing
- [ ] Health check: `https://your-app.vercel.app/health`
- [ ] API status: `https://your-app.vercel.app/api/simplified-ai/status`
- [ ] Test model upload endpoint
- [ ] Test clothing processing endpoint

### Frontend Testing
- [ ] Debug screen shows connection success
- [ ] Model upload works on physical device
- [ ] Image processing completes successfully
- [ ] Error handling works properly

## Troubleshooting

### Common Issues

1. **CORS Errors**
   - Backend CORS should be set to `origin: true` for development
   - For production, specify exact domains

2. **File Upload Issues**
   - Vercel has a 4.5MB limit for serverless functions
   - Consider using Vercel's Blob storage for larger files

3. **Database Issues**
   - SQLite works in Vercel but data resets on each deployment
   - For persistent storage, consider Vercel Postgres or external DB

4. **Timeout Issues**
   - Vercel functions have a max duration of 30 seconds (Pro plan: 60 seconds)
   - Optimize AI processing time or use background jobs

### Monitoring
- Check Vercel logs for errors
- Monitor function execution time
- Set up alerts for failures

## Production Optimizations

### Performance
- Enable caching headers
- Optimize image sizes
- Use CDN for static assets

### Security
- Implement rate limiting
- Add authentication
- Validate all inputs
- Use HTTPS (default on Vercel)

### Scaling
- Monitor usage metrics
- Consider edge functions for global distribution
- Implement proper error handling