import sqlite3 from 'sqlite3';
import { open, Database } from 'sqlite';
import path from 'path';
import fs from 'fs';

export interface User {
  id: string;
  name: string;
  email?: string;
  preferences: any;
  settings: any;
  created_at: string;
  updated_at: string;
}

export interface ClothingItem {
  id: string;
  user_id: string;
  name: string;
  category: string;
  style: string;
  colors: string[];
  material?: string;
  size?: string;
  brand?: string;
  original_image_url: string;
  processed_image_url?: string;
  metadata: any;
  quality_score?: number;
  created_at: string;
  updated_at: string;
}

export interface Outfit {
  id: string;
  user_id: string;
  name: string;
  description?: string;
  occasion: string;
  style: string;
  season?: string;
  clothing_item_ids: string[];
  model_image_url?: string;
  visualization_url?: string;
  metadata: any;
  is_favorite: boolean;
  created_at: string;
  updated_at: string;
}

export interface UserModel {
  id: string;
  user_id: string;
  name: string;
  original_image_url: string;
  processed_image_url?: string;
  model_type: string;
  status: string;
  metadata: any;
  created_at: string;
  updated_at: string;
}

class HybridSQLiteService {
  private db: Database | null = null;
  private dbPath: string;

  constructor() {
    // Determine database path based on environment
    // In Vercel/serverless, use /tmp (only writable directory)
    // In local development, use ./data directory
    const isVercel = process.env.VERCEL === '1' || 
                     process.env.VERCEL_ENV !== undefined ||
                     process.cwd().startsWith('/var/task');
    
    if (isVercel) {
      // Use /tmp for Vercel serverless (only writable directory)
      this.dbPath = '/tmp/wardrobe_hybrid.db';
      console.log('Using Vercel serverless mode: database will be stored in /tmp');
    } else {
      // Use local data directory for development
      this.dbPath = path.join(process.cwd(), 'data', 'wardrobe_hybrid.db');
      console.log(`Using local development mode: database will be stored at ${this.dbPath}`);
    }
  }

  /**
   * Initialize database connection and create tables
   */
  async initialize(): Promise<void> {
    try {
      // Ensure directory exists for local development (not needed for /tmp in Vercel)
      const isVercel = process.env.VERCEL === '1' || process.env.NODE_ENV === 'production';
      if (!isVercel) {
        const dbDir = path.dirname(this.dbPath);
        if (!fs.existsSync(dbDir)) {
          try {
            fs.mkdirSync(dbDir, { recursive: true });
          } catch (dirError: any) {
            // If directory creation fails, log but continue (might already exist)
            console.warn(`Warning: Could not create directory ${dbDir}:`, dirError.message);
          }
        }
      }

      // Open database connection
      this.db = await open({
        filename: this.dbPath,
        driver: sqlite3.Database
      });

      await this.createTables();
      console.log(`SQLite database initialized successfully at: ${this.dbPath}`);
    } catch (error) {
      console.error('Failed to initialize SQLite database:', error);
      throw error;
    }
  }

  /**
   * Create necessary tables
   */
  private async createTables(): Promise<void> {
    if (!this.db) throw new Error('Database not initialized');

    // Users table
    await this.db.exec(`
      CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT,
        preferences TEXT,
        settings TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    `);

    // Clothing items table
    await this.db.exec(`
      CREATE TABLE IF NOT EXISTS clothing_items (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        style TEXT NOT NULL,
        colors TEXT,
        material TEXT,
        size TEXT,
        brand TEXT,
        original_image_url TEXT NOT NULL,
        processed_image_url TEXT,
        metadata TEXT,
        quality_score INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    `);

    // Outfits table
    await this.db.exec(`
      CREATE TABLE IF NOT EXISTS outfits (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        occasion TEXT NOT NULL,
        style TEXT NOT NULL,
        season TEXT,
        clothing_item_ids TEXT,
        model_image_url TEXT,
        visualization_url TEXT,
        metadata TEXT,
        is_favorite BOOLEAN DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    `);

    // User models table
    await this.db.exec(`
      CREATE TABLE IF NOT EXISTS user_models (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        original_image_url TEXT NOT NULL,
        processed_image_url TEXT,
        model_type TEXT NOT NULL,
        status TEXT NOT NULL,
        metadata TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    `);

    // Create indexes for better performance
    await this.db.exec(`
      CREATE INDEX IF NOT EXISTS idx_clothing_user_id ON clothing_items (user_id);
      CREATE INDEX IF NOT EXISTS idx_clothing_category ON clothing_items (category);
      CREATE INDEX IF NOT EXISTS idx_outfits_user_id ON outfits (user_id);
      CREATE INDEX IF NOT EXISTS idx_outfits_occasion ON outfits (occasion);
      CREATE INDEX IF NOT EXISTS idx_user_models_user_id ON user_models (user_id);
      CREATE INDEX IF NOT EXISTS idx_user_models_status ON user_models (status);
    `);
  }

  // User Management Methods
  async createUser(userData: Omit<User, 'id' | 'created_at' | 'updated_at'>): Promise<User> {
    if (!this.db) throw new Error('Database not initialized');

    const user: User = {
      id: this.generateId(),
      ...userData,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };

    await this.db.run(
      `INSERT INTO users (id, name, email, preferences, settings, created_at, updated_at)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [
        user.id,
        user.name,
        user.email || null,
        JSON.stringify(user.preferences),
        JSON.stringify(user.settings),
        user.created_at,
        user.updated_at
      ]
    );

    return user;
  }

  async getUser(userId: string): Promise<User | null> {
    if (!this.db) throw new Error('Database not initialized');

    const row = await this.db.get(
      'SELECT * FROM users WHERE id = ?',
      [userId]
    );

    if (!row) return null;

    return {
      ...row,
      preferences: JSON.parse(row.preferences || '{}'),
      settings: JSON.parse(row.settings || '{}')
    };
  }

  async updateUser(userId: string, updates: Partial<Omit<User, 'id' | 'created_at'>>): Promise<User | null> {
    if (!this.db) throw new Error('Database not initialized');

    const updateFields: string[] = [];
    const updateValues: any[] = [];

    if (updates.name) {
      updateFields.push('name = ?');
      updateValues.push(updates.name);
    }
    if (updates.email !== undefined) {
      updateFields.push('email = ?');
      updateValues.push(updates.email);
    }
    if (updates.preferences) {
      updateFields.push('preferences = ?');
      updateValues.push(JSON.stringify(updates.preferences));
    }
    if (updates.settings) {
      updateFields.push('settings = ?');
      updateValues.push(JSON.stringify(updates.settings));
    }

    if (updateFields.length === 0) return null;

    updateFields.push('updated_at = ?');
    updateValues.push(new Date().toISOString());
    updateValues.push(userId);

    await this.db.run(
      `UPDATE users SET ${updateFields.join(', ')} WHERE id = ?`,
      updateValues
    );

    return this.getUser(userId);
  }

  // Clothing Item Management Methods
  async createClothingItem(itemData: Omit<ClothingItem, 'id' | 'created_at' | 'updated_at'>): Promise<ClothingItem> {
    if (!this.db) throw new Error('Database not initialized');

    const item: ClothingItem = {
      id: this.generateId(),
      ...itemData,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };

    await this.db.run(
      `INSERT INTO clothing_items (
        id, user_id, name, category, style, colors, material, size, brand,
        original_image_url, processed_image_url, metadata, quality_score, created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        item.id,
        item.user_id,
        item.name,
        item.category,
        item.style,
        JSON.stringify(item.colors),
        item.material || null,
        item.size || null,
        item.brand || null,
        item.original_image_url,
        item.processed_image_url || null,
        JSON.stringify(item.metadata),
        item.quality_score || null,
        item.created_at,
        item.updated_at
      ]
    );

    return item;
  }

  async getClothingItems(userId: string, filters?: {
    category?: string;
    style?: string;
    color?: string;
  }): Promise<ClothingItem[]> {
    if (!this.db) throw new Error('Database not initialized');

    let query = 'SELECT * FROM clothing_items WHERE user_id = ?';
    const params: any[] = [userId];

    if (filters?.category) {
      query += ' AND category = ?';
      params.push(filters.category);
    }
    if (filters?.style) {
      query += ' AND style = ?';
      params.push(filters.style);
    }
    if (filters?.color) {
      query += " AND colors LIKE ?";
      params.push(`%"${filters.color}"%`);
    }

    query += ' ORDER BY created_at DESC';

    const rows = await this.db.all(query, params);

    return rows.map(row => ({
      ...row,
      colors: JSON.parse(row.colors || '[]'),
      metadata: JSON.parse(row.metadata || '{}')
    }));
  }

  async getClothingItem(itemId: string): Promise<ClothingItem | null> {
    if (!this.db) throw new Error('Database not initialized');

    const row = await this.db.get(
      'SELECT * FROM clothing_items WHERE id = ?',
      [itemId]
    );

    if (!row) return null;

    return {
      ...row,
      colors: JSON.parse(row.colors || '[]'),
      metadata: JSON.parse(row.metadata || '{}')
    };
  }

  async updateClothingItem(itemId: string, updates: Partial<Omit<ClothingItem, 'id' | 'user_id' | 'created_at'>>): Promise<ClothingItem | null> {
    if (!this.db) throw new Error('Database not initialized');

    const updateFields: string[] = [];
    const updateValues: any[] = [];

    if (updates.name) {
      updateFields.push('name = ?');
      updateValues.push(updates.name);
    }
    if (updates.category) {
      updateFields.push('category = ?');
      updateValues.push(updates.category);
    }
    if (updates.style) {
      updateFields.push('style = ?');
      updateValues.push(updates.style);
    }
    if (updates.colors) {
      updateFields.push('colors = ?');
      updateValues.push(JSON.stringify(updates.colors));
    }
    if (updates.material) {
      updateFields.push('material = ?');
      updateValues.push(updates.material);
    }
    if (updates.size) {
      updateFields.push('size = ?');
      updateValues.push(updates.size);
    }
    if (updates.brand) {
      updateFields.push('brand = ?');
      updateValues.push(updates.brand);
    }
    if (updates.original_image_url) {
      updateFields.push('original_image_url = ?');
      updateValues.push(updates.original_image_url);
    }
    if (updates.processed_image_url !== undefined) {
      updateFields.push('processed_image_url = ?');
      updateValues.push(updates.processed_image_url);
    }
    if (updates.metadata) {
      updateFields.push('metadata = ?');
      updateValues.push(JSON.stringify(updates.metadata));
    }
    if (updates.quality_score !== undefined) {
      updateFields.push('quality_score = ?');
      updateValues.push(updates.quality_score);
    }

    if (updateFields.length === 0) return null;

    updateFields.push('updated_at = ?');
    updateValues.push(new Date().toISOString());
    updateValues.push(itemId);

    await this.db.run(
      `UPDATE clothing_items SET ${updateFields.join(', ')} WHERE id = ?`,
      updateValues
    );

    return this.getClothingItem(itemId);
  }

  async deleteClothingItem(itemId: string): Promise<boolean> {
    if (!this.db) throw new Error('Database not initialized');

    const result = await this.db.run(
      'DELETE FROM clothing_items WHERE id = ?',
      [itemId]
    );

    return (result.changes || 0) > 0;
  }

  // Outfit Management Methods
  async createOutfit(outfitData: Omit<Outfit, 'id' | 'created_at' | 'updated_at'>): Promise<Outfit> {
    if (!this.db) throw new Error('Database not initialized');

    const outfit: Outfit = {
      id: this.generateId(),
      ...outfitData,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };

    await this.db.run(
      `INSERT INTO outfits (
        id, user_id, name, description, occasion, style, season, clothing_item_ids,
        model_image_url, visualization_url, metadata, is_favorite, created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        outfit.id,
        outfit.user_id,
        outfit.name,
        outfit.description || null,
        outfit.occasion,
        outfit.style,
        outfit.season || null,
        JSON.stringify(outfit.clothing_item_ids),
        outfit.model_image_url || null,
        outfit.visualization_url || null,
        JSON.stringify(outfit.metadata),
        outfit.is_favorite ? 1 : 0,
        outfit.created_at,
        outfit.updated_at
      ]
    );

    return outfit;
  }

  async getOutfits(userId: string, filters?: {
    occasion?: string;
    style?: string;
    season?: string;
    favorite?: boolean;
  }): Promise<Outfit[]> {
    if (!this.db) throw new Error('Database not initialized');

    let query = 'SELECT * FROM outfits WHERE user_id = ?';
    const params: any[] = [userId];

    if (filters?.occasion) {
      query += ' AND occasion = ?';
      params.push(filters.occasion);
    }
    if (filters?.style) {
      query += ' AND style = ?';
      params.push(filters.style);
    }
    if (filters?.season) {
      query += ' AND season = ?';
      params.push(filters.season);
    }
    if (filters?.favorite !== undefined) {
      query += ' AND is_favorite = ?';
      params.push(filters.favorite ? 1 : 0);
    }

    query += ' ORDER BY created_at DESC';

    const rows = await this.db.all(query, params);

    return rows.map(row => ({
      ...row,
      clothing_item_ids: JSON.parse(row.clothing_item_ids || '[]'),
      metadata: JSON.parse(row.metadata || '{}'),
      is_favorite: row.is_favorite === 1
    }));
  }

  async getOutfit(outfitId: string): Promise<Outfit | null> {
    if (!this.db) throw new Error('Database not initialized');

    const row = await this.db.get(
      'SELECT * FROM outfits WHERE id = ?',
      [outfitId]
    );

    if (!row) return null;

    return {
      ...row,
      clothing_item_ids: JSON.parse(row.clothing_item_ids || '[]'),
      metadata: JSON.parse(row.metadata || '{}'),
      is_favorite: row.is_favorite === 1
    };
  }

  async updateOutfit(outfitId: string, updates: Partial<Omit<Outfit, 'id' | 'user_id' | 'created_at'>>): Promise<Outfit | null> {
    if (!this.db) throw new Error('Database not initialized');

    const updateFields: string[] = [];
    const updateValues: any[] = [];

    if (updates.name) {
      updateFields.push('name = ?');
      updateValues.push(updates.name);
    }
    if (updates.description !== undefined) {
      updateFields.push('description = ?');
      updateValues.push(updates.description);
    }
    if (updates.occasion) {
      updateFields.push('occasion = ?');
      updateValues.push(updates.occasion);
    }
    if (updates.style) {
      updateFields.push('style = ?');
      updateValues.push(updates.style);
    }
    if (updates.season) {
      updateFields.push('season = ?');
      updateValues.push(updates.season);
    }
    if (updates.clothing_item_ids) {
      updateFields.push('clothing_item_ids = ?');
      updateValues.push(JSON.stringify(updates.clothing_item_ids));
    }
    if (updates.model_image_url !== undefined) {
      updateFields.push('model_image_url = ?');
      updateValues.push(updates.model_image_url);
    }
    if (updates.visualization_url !== undefined) {
      updateFields.push('visualization_url = ?');
      updateValues.push(updates.visualization_url);
    }
    if (updates.metadata) {
      updateFields.push('metadata = ?');
      updateValues.push(JSON.stringify(updates.metadata));
    }
    if (updates.is_favorite !== undefined) {
      updateFields.push('is_favorite = ?');
      updateValues.push(updates.is_favorite ? 1 : 0);
    }

    if (updateFields.length === 0) return null;

    updateFields.push('updated_at = ?');
    updateValues.push(new Date().toISOString());
    updateValues.push(outfitId);

    await this.db.run(
      `UPDATE outfits SET ${updateFields.join(', ')} WHERE id = ?`,
      updateValues
    );

    return this.getOutfit(outfitId);
  }

  async deleteOutfit(outfitId: string): Promise<boolean> {
    if (!this.db) throw new Error('Database not initialized');

    const result = await this.db.run(
      'DELETE FROM outfits WHERE id = ?',
      [outfitId]
    );

    return (result.changes || 0) > 0;
  }

  // User Model Management Methods
  async createUserModel(modelData: Omit<UserModel, 'id' | 'created_at' | 'updated_at'>): Promise<UserModel> {
    if (!this.db) throw new Error('Database not initialized');

    const model: UserModel = {
      id: this.generateId(),
      ...modelData,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };

    await this.db.run(
      `INSERT INTO user_models (
        id, user_id, name, original_image_url, processed_image_url, model_type, status, metadata, created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        model.id,
        model.user_id,
        model.name,
        model.original_image_url,
        model.processed_image_url || null,
        model.model_type,
        model.status,
        JSON.stringify(model.metadata),
        model.created_at,
        model.updated_at
      ]
    );

    return model;
  }

  async getUserModels(userId: string): Promise<UserModel[]> {
    if (!this.db) throw new Error('Database not initialized');

    const rows = await this.db.all(
      'SELECT * FROM user_models WHERE user_id = ? ORDER BY created_at DESC',
      [userId]
    );

    return rows.map(row => ({
      ...row,
      metadata: JSON.parse(row.metadata || '{}')
    }));
  }

  async getUserModel(modelId: string): Promise<UserModel | null> {
    if (!this.db) throw new Error('Database not initialized');

    const row = await this.db.get(
      'SELECT * FROM user_models WHERE id = ?',
      [modelId]
    );

    if (!row) return null;

    return {
      ...row,
      metadata: JSON.parse(row.metadata || '{}')
    };
  }

  async updateUserModel(modelId: string, updates: Partial<Omit<UserModel, 'id' | 'user_id' | 'created_at'>>): Promise<UserModel | null> {
    if (!this.db) throw new Error('Database not initialized');

    const updateFields: string[] = [];
    const updateValues: any[] = [];

    if (updates.name) {
      updateFields.push('name = ?');
      updateValues.push(updates.name);
    }
    if (updates.original_image_url) {
      updateFields.push('original_image_url = ?');
      updateValues.push(updates.original_image_url);
    }
    if (updates.processed_image_url !== undefined) {
      updateFields.push('processed_image_url = ?');
      updateValues.push(updates.processed_image_url);
    }
    if (updates.model_type) {
      updateFields.push('model_type = ?');
      updateValues.push(updates.model_type);
    }
    if (updates.status) {
      updateFields.push('status = ?');
      updateValues.push(updates.status);
    }
    if (updates.metadata) {
      updateFields.push('metadata = ?');
      updateValues.push(JSON.stringify(updates.metadata));
    }

    if (updateFields.length === 0) return null;

    updateFields.push('updated_at = ?');
    updateValues.push(new Date().toISOString());
    updateValues.push(modelId);

    await this.db.run(
      `UPDATE user_models SET ${updateFields.join(', ')} WHERE id = ?`,
      updateValues
    );

    return this.getUserModel(modelId);
  }

  async deleteUserModel(modelId: string): Promise<boolean> {
    if (!this.db) throw new Error('Database not initialized');

    const result = await this.db.run(
      'DELETE FROM user_models WHERE id = ?',
      [modelId]
    );

    return (result.changes || 0) > 0;
  }

  // Utility Methods
  private generateId(): string {
    return Date.now().toString(36) + Math.random().toString(36).substr(2);
  }

  async getWardrobeStats(userId: string): Promise<any> {
    if (!this.db) throw new Error('Database not initialized');

    const clothingCount = await this.db.get(
      'SELECT COUNT(*) as count FROM clothing_items WHERE user_id = ?',
      [userId]
    );

    const outfitCount = await this.db.get(
      'SELECT COUNT(*) as count FROM outfits WHERE user_id = ?',
      [userId]
    );

    const modelCount = await this.db.get(
      'SELECT COUNT(*) as count FROM user_models WHERE user_id = ?',
      [userId]
    );

    const categoryStats = await this.db.all(
      'SELECT category, COUNT(*) as count FROM clothing_items WHERE user_id = ? GROUP BY category',
      [userId]
    );

    const occasionStats = await this.db.all(
      'SELECT occasion, COUNT(*) as count FROM outfits WHERE user_id = ? GROUP BY occasion',
      [userId]
    );

    return {
      total_clothing_items: clothingCount.count,
      total_outfits: outfitCount.count,
      total_models: modelCount.count,
      category_breakdown: categoryStats,
      occasion_breakdown: occasionStats,
      last_updated: new Date().toISOString()
    };
  }

  async close(): Promise<void> {
    if (this.db) {
      await this.db.close();
      this.db = null;
    }
  }
}

export const hybridSQLiteService = new HybridSQLiteService();