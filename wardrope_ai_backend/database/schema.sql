-- Wardrope.ai Database Schema
-- PostgreSQL Database Schema for Wardrope.ai Backend

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create custom types
CREATE TYPE user_status AS ENUM ('active', 'inactive', 'suspended');
CREATE TYPE clothing_category AS ENUM ('tops', 'bottoms', 'shoes', 'accessories', 'outerwear', 'underwear', 'activewear', 'formal', 'casual');
CREATE TYPE clothing_subcategory AS ENUM ('shirt', 'blouse', 'sweater', 'jacket', 'coat', 'jeans', 'pants', 'shorts', 'skirt', 'dress', 'sneakers', 'boots', 'sandals', 'heels', 'bag', 'jewelry', 'hat', 'scarf', 'belt', 'watch');
CREATE TYPE clothing_color AS ENUM ('red', 'blue', 'green', 'yellow', 'orange', 'purple', 'pink', 'brown', 'black', 'white', 'gray', 'navy', 'beige', 'cream', 'gold', 'silver', 'multicolor');
CREATE TYPE clothing_size AS ENUM ('XS', 'S', 'M', 'L', 'XL', 'XXL', 'XXXL', '0', '2', '4', '6', '8', '10', '12', '14', '16', '18', '20');
CREATE TYPE clothing_condition AS ENUM ('new', 'excellent', 'good', 'fair', 'poor');
CREATE TYPE weather_type AS ENUM ('sunny', 'cloudy', 'rainy', 'snowy', 'windy', 'hot', 'cold', 'mild');
CREATE TYPE season_type AS ENUM ('spring', 'summer', 'fall', 'winter');
CREATE TYPE occasion_type AS ENUM ('casual', 'business', 'formal', 'party', 'sport', 'vacation', 'date', 'work');

-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    date_of_birth DATE,
    gender VARCHAR(20),
    phone VARCHAR(20),
    profile_image_url TEXT,
    bio TEXT,
    location VARCHAR(255),
    status user_status DEFAULT 'active',
    preferences JSONB DEFAULT '{}',
    settings JSONB DEFAULT '{}',
    email_verified BOOLEAN DEFAULT FALSE,
    last_login_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Clothing items table
CREATE TABLE clothing_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category clothing_category NOT NULL,
    subcategory clothing_subcategory,
    brand VARCHAR(100),
    color clothing_color[],
    size clothing_size,
    condition clothing_condition DEFAULT 'good',
    price DECIMAL(10,2),
    purchase_date DATE,
    tags TEXT[],
    image_url TEXT,
    image_public_id VARCHAR(255),
    care_instructions TEXT,
    material VARCHAR(255),
    season season_type[],
    weather weather_type[],
    occasions occasion_type[],
    favorite BOOLEAN DEFAULT FALSE,
    wear_count INTEGER DEFAULT 0,
    last_worn_date DATE,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User models table (for virtual try-on)
CREATE TABLE user_models (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    image_url TEXT NOT NULL,
    image_public_id VARCHAR(255),
    body_measurements JSONB DEFAULT '{}',
    skin_tone VARCHAR(50),
    hair_color VARCHAR(50),
    eye_color VARCHAR(50),
    is_default BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Outfits table
CREATE TABLE outfits (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    clothing_item_ids UUID[],
    user_model_id UUID REFERENCES user_models(id) ON DELETE SET NULL,
    occasion occasion_type[],
    season season_type[],
    weather weather_type[],
    color_scheme VARCHAR(100),
    style_tags TEXT[],
    image_url TEXT,
    generated_image_url TEXT,
    image_public_id VARCHAR(255),
    is_favorite BOOLEAN DEFAULT FALSE,
    is_public BOOLEAN DEFAULT FALSE,
    wear_count INTEGER DEFAULT 0,
    last_worn_date DATE,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- AI recommendations table
CREATE TABLE ai_recommendations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL, -- 'outfit', 'purchase', 'styling'
    title VARCHAR(255) NOT NULL,
    description TEXT,
    recommended_items JSONB DEFAULT '[]',
    suggested_outfits JSONB DEFAULT '[]',
    confidence_score DECIMAL(3,2) CHECK (confidence_score >= 0 AND confidence_score <= 1),
    context JSONB DEFAULT '{}', -- weather, occasion, season, etc.
    user_feedback INTEGER CHECK (user_feedback >= 1 AND user_feedback <= 5),
    is_applied BOOLEAN DEFAULT FALSE,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User activities table (for tracking user interactions)
CREATE TABLE user_activities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    activity_type VARCHAR(50) NOT NULL, -- 'login', 'upload', 'create_outfit', 'wear_item', etc.
    entity_type VARCHAR(50), -- 'clothing_item', 'outfit', 'user_model'
    entity_id UUID,
    description TEXT,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User sessions table (for authentication)
CREATE TABLE user_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_token VARCHAR(255) UNIQUE NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Image processing jobs table
CREATE TABLE image_processing_jobs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    job_type VARCHAR(50) NOT NULL, -- 'background_removal', 'color_analysis', 'style_detection'
    status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'processing', 'completed', 'failed'
    result JSONB DEFAULT '{}',
    error_message TEXT,
    processing_started_at TIMESTAMP WITH TIME ZONE,
    processing_completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_clothing_items_user_id ON clothing_items(user_id);
CREATE INDEX idx_clothing_items_category ON clothing_items(category);
CREATE INDEX idx_clothing_items_tags ON clothing_items USING GIN(tags);
CREATE INDEX idx_clothing_items_favorite ON clothing_items(favorite);
CREATE INDEX idx_user_models_user_id ON user_models(user_id);
CREATE INDEX idx_user_models_default ON user_models(is_default);
CREATE INDEX idx_outfits_user_id ON outfits(user_id);
CREATE INDEX idx_outfits_favorite ON outfits(is_favorite);
CREATE INDEX idx_outfits_public ON outfits(is_public);
CREATE INDEX idx_ai_recommendations_user_id ON ai_recommendations(user_id);
CREATE INDEX idx_ai_recommendations_type ON ai_recommendations(type);
CREATE INDEX idx_user_activities_user_id ON user_activities(user_id);
CREATE INDEX idx_user_activities_type ON user_activities(activity_type);
CREATE INDEX idx_user_sessions_token ON user_sessions(session_token);
CREATE INDEX idx_image_processing_jobs_user_id ON image_processing_jobs(user_id);
CREATE INDEX idx_image_processing_jobs_status ON image_processing_jobs(status);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply updated_at triggers to tables
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_clothing_items_updated_at BEFORE UPDATE ON clothing_items FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_models_updated_at BEFORE UPDATE ON user_models FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_outfits_updated_at BEFORE UPDATE ON outfits FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_ai_recommendations_updated_at BEFORE UPDATE ON ai_recommendations FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_sessions_updated_at BEFORE UPDATE ON user_sessions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_image_processing_jobs_updated_at BEFORE UPDATE ON image_processing_jobs FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
