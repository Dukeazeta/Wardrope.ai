# Wardrobe.ai Backend API Routes

## Overview
Complete API route structure based on the Flutter frontend analysis, organized by feature modules.

## Route Structure

### 🔐 Authentication Routes (`/api/auth`)
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/register` | Register new user |
| POST | `/login` | User login |
| POST | `/logout` | User logout |
| POST | `/refresh` | Refresh access token |
| POST | `/verify-email` | Verify email address |
| POST | `/resend-verification` | Resend verification email |
| POST | `/forgot-password` | Request password reset |
| POST | `/reset-password` | Reset password with token |
| PUT | `/change-password` | Change password (authenticated) |
| POST | `/google` | Google OAuth authentication |
| POST | `/facebook` | Facebook OAuth authentication |
| POST | `/apple` | Apple OAuth authentication |
| GET | `/me` | Get current user |
| DELETE | `/sessions` | Revoke all sessions |

### 👤 User Management Routes (`/api/users`)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/:userId` | Get user profile |
| PUT | `/:userId` | Update user profile |
| POST | `/` | Create new user |
| DELETE | `/:userId` | Delete user account |
| GET | `/:userId/wardrobe` | Get user's wardrobe items |

### 👗 Wardrobe Management Routes (`/api/wardrobe`)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/:userId` | Get user's wardrobe |
| POST | `/:userId/items` | Add new clothing item |
| GET | `/:userId/items/:itemId` | Get specific clothing item |
| PUT | `/:userId/items/:itemId` | Update clothing item |
| DELETE | `/:userId/items/:itemId` | Delete clothing item |
| GET | `/:userId/categories` | Get available categories |
| GET | `/:userId/categories/:category` | Get items by category |
| GET | `/:userId/favorites` | Get favorite items |
| POST | `/:userId/items/:itemId/favorite` | Toggle favorite status |
| GET | `/:userId/tags` | Get all tags |
| GET | `/:userId/search` | Search items |
| POST | `/:userId/items/:itemId/tags` | Add tags to item |
| DELETE | `/:userId/items/:itemId/tags` | Remove tags from item |
| GET | `/:userId/stats` | Get wardrobe statistics |
| GET | `/:userId/most-worn` | Get most worn items |
| POST | `/:userId/items/:itemId/wear` | Increment wear count |

### 🖼️ Image Processing Routes (`/api/image`)
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/process` | Process clothing image |
| GET | `/status` | Get service status |
| POST | `/remove-background` | Remove image background |
| POST | `/enhance` | Enhance image quality |

### 🧑‍🎨 3D Model Routes (`/api/model`)
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/upload` | Upload and process model image |
| GET | `/:userId` | Get user's models |
| GET | `/:userId/primary` | Get primary model |
| PUT | `/:modelId/primary` | Set model as primary |
| GET | `/:modelId/status` | Get processing status |
| POST | `/:modelId/apply-outfit` | Apply outfit to model |
| DELETE | `/:modelId` | Delete model |
| POST | `/:modelId/regenerate` | Regenerate model |
| GET | `/:modelId/progress` | Get processing progress |

### 👔 Outfit Management Routes (`/api/outfits`)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/:userId` | Get user's outfits |
| POST | `/:userId` | Create new outfit |
| GET | `/:userId/:outfitId` | Get specific outfit |
| PUT | `/:userId/:outfitId` | Update outfit |
| DELETE | `/:userId/:outfitId` | Delete outfit |
| GET | `/:userId/favorites` | Get favorite outfits |
| POST | `/:userId/:outfitId/favorite` | Toggle favorite status |
| POST | `/:userId/:outfitId/share` | Share outfit |
| GET | `/shared/:shareId` | Get shared outfit |
| POST | `/:userId/generate` | Generate outfit image |
| POST | `/:userId/:outfitId/variations` | Get outfit variations |
| GET | `/:userId/stats` | Get outfit statistics |
| POST | `/:userId/:outfitId/worn` | Mark outfit as worn |

### 🤖 AI Stylist Routes (`/api/ai-stylist`)
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/:userId/recommendations` | Get outfit recommendations |
| POST | `/:userId/style-analysis` | Analyze personal style |
| POST | `/:userId/outfit-suggestions` | Get outfit suggestions |
| GET | `/:userId/seasonal/:season` | Get seasonal recommendations |
| POST | `/:userId/occasion/:occasion` | Get occasion-based outfits |
| GET | `/:userId/style-profile` | Get style profile |
| PUT | `/:userId/style-profile` | Update style profile |
| POST | `/:userId/feedback` | Submit outfit feedback |
| GET | `/trends/current` | Get current trends |
| POST | `/:userId/trends/personalized` | Get personalized trends |
| POST | `/:userId/color-analysis` | Analyze color palette |
| POST | `/:userId/color-match` | Get color matching items |

## Request/Response Formats

### Standard Response Format
```json
{
  "success": boolean,
  "data": object | array,
  "message": string,
  "pagination": {
    "limit": number,
    "offset": number,
    "total": number
  }
}
```

### Error Response Format
```json
{
  "success": false,
  "message": string,
  "error": string (optional)
}
```

## File Upload Support

### Supported Endpoints
- `POST /api/image/process` - Single image upload
- `POST /api/image/remove-background` - Single image upload
- `POST /api/image/enhance` - Single image upload
- `POST /api/model/upload` - Single model image upload
- `POST /api/wardrobe/:userId/items` - Single clothing image upload

### File Specifications
- **Max Size**: 10MB (15MB for model images)
- **Formats**: JPEG, PNG, WebP
- **Field Name**: `image` (or `modelImage` for models)

## Authentication

### Required Headers
```
Authorization: Bearer <access_token>
```

### Public Endpoints
- Health check endpoints
- Authentication endpoints
- Shared outfit viewing

## Frontend Integration

### Flutter App Integration Points

#### 1. **Onboarding Flow**
- `POST /api/auth/register` - User registration
- `POST /api/model/upload` - Initial model upload

#### 2. **Main Wardrobe Screen**
- `GET /api/wardrobe/:userId` - Load wardrobe items
- `POST /api/wardrobe/:userId/items` - Add new items
- `GET /api/wardrobe/:userId/categories/:category` - Filter by category

#### 3. **Add Clothing Screen**
- `POST /api/image/process` - Process captured/selected image
- `POST /api/wardrobe/:userId/items` - Save processed item

#### 4. **Model Screen**
- `GET /api/users/:userId/primary` - Get primary model
- `POST /api/model/apply-outfit` - Apply clothing to model
- `GET /api/model/:modelId/status` - Check processing status

#### 5. **AI Stylist Screen**
- `POST /api/ai-stylist/:userId/recommendations` - Get AI recommendations
- `POST /api/ai-stylist/:userId/style-analysis` - Analyze user style
- `GET /api/ai-stylist/trends/current` - Get current trends

#### 6. **Profile Screen**
- `GET /api/auth/me` - Get current user
- `PUT /api/users/:userId` - Update profile
- `GET /api/wardrobe/:userId/stats` - Get wardrobe stats

## Database Integration

### Primary Models
- **Users** - User profiles and authentication
- **ClothingItems** - Individual wardrobe pieces
- **UserModels** - 3D avatar models
- **Outfits** - Clothing combinations

### Storage Integration
- **Supabase Storage** for image files
- **PostgreSQL** for structured data
- **JSONB** fields for flexible metadata

## Security Features

- JWT-based authentication via Supabase Auth
- File upload validation and sanitization
- User isolation (users can only access their own data)
- Input validation and SQL injection prevention
- Rate limiting and CORS configuration

## Performance Optimizations

- Database indexes on frequently queried fields
- Image processing and optimization
- Pagination for large datasets
- Connection pooling for database
- Efficient query patterns with minimal N+1 problems

## Development Status

✅ **Complete**
- Route structure defined
- Controller classes implemented
- Database models created
- Basic authentication flow
- File upload handling

🚧 **In Progress**
- AI integration for recommendations
- Advanced image processing
- Social features (sharing, following)
- Real-time outfit generation

📋 **Planned**
- WebSocket support for real-time updates
- Advanced analytics and insights
- Integration with fashion APIs
- Mobile app push notifications
