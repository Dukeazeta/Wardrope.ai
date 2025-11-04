import { database } from '../libs/database';
import { v4 as uuidv4 } from 'uuid';

export interface OutfitAttributes {
  id?: string;
  user_id: string;
  name: string;
  description?: string;
  clothing_item_ids: string[];
  style_tags?: string[];
  tags?: string[];
  occasion?: string;
  season?: string;
  weather_conditions?: string[];
  favorite?: boolean;
  is_favorite?: boolean;
  generated_image_url?: string;
  ai_metadata?: any;
  metadata?: any;
  created_at?: Date;
  updated_at?: Date;
}

export class Outfit {
  static tableName = 'outfits';

  /**
   * Create a new outfit
   */
  static async create(outfitData: OutfitAttributes): Promise<OutfitAttributes> {
    const outfit = {
      id: uuidv4(),
      ...outfitData,
      favorite: outfitData.favorite || false,
      created_at: new Date(),
      updated_at: new Date(),
    };

    const query = `
      INSERT INTO outfits (id, user_id, name, clothing_item_ids, style_tags, occasion, season, weather_conditions, favorite, metadata, created_at, updated_at)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
      RETURNING *
    `;

    const values = [
      outfit.id,
      outfit.user_id,
      outfit.name,
      JSON.stringify(outfit.clothing_item_ids),
      JSON.stringify(outfit.style_tags || []),
      outfit.occasion,
      outfit.season,
      JSON.stringify(outfit.weather_conditions || []),
      outfit.favorite,
      JSON.stringify(outfit.metadata || {}),
      outfit.created_at,
      outfit.updated_at,
    ];

    const result = await database.query(query, values);
    return result.rows[0];
  }

  /**
   * Find outfit by ID
   */
  static async findById(id: string): Promise<OutfitAttributes | null> {
    const result = await database.query(
      'SELECT * FROM outfits WHERE id = $1',
      [id]
    );
    return result.rows[0] || null;
  }

  /**
   * Find outfits by user ID
   */
  static async findByUserId(userId: string, limit: number = 20, offset: number = 0): Promise<OutfitAttributes[]> {
    const result = await database.query(
      'SELECT * FROM outfits WHERE user_id = $1 ORDER BY created_at DESC LIMIT $2 OFFSET $3',
      [userId, limit, offset]
    );
    return result.rows;
  }

  /**
   * Find favorite outfits by user
   */
  static async findFavoritesByUserId(userId: string): Promise<OutfitAttributes[]> {
    const result = await database.query(
      'SELECT * FROM outfits WHERE user_id = $1 AND favorite = true ORDER BY created_at DESC',
      [userId]
    );
    return result.rows;
  }

  /**
   * Find outfits by occasion
   */
  static async findByOccasion(userId: string, occasion: string): Promise<OutfitAttributes[]> {
    const result = await database.query(
      'SELECT * FROM outfits WHERE user_id = $1 AND occasion = $2 ORDER BY created_at DESC',
      [userId, occasion]
    );
    return result.rows;
  }

  /**
   * Find outfits by season
   */
  static async findBySeason(userId: string, season: string): Promise<OutfitAttributes[]> {
    const result = await database.query(
      'SELECT * FROM outfits WHERE user_id = $1 AND season = $2 ORDER BY created_at DESC',
      [userId, season]
    );
    return result.rows;
  }

  /**
   * Search outfits
   */
  static async search(userId: string, searchTerm: string): Promise<OutfitAttributes[]> {
    const result = await database.query(
      `SELECT * FROM outfits 
       WHERE user_id = $1 AND (
         name ILIKE $2 OR 
         occasion ILIKE $2 OR 
         season ILIKE $2
       )
       ORDER BY created_at DESC`,
      [userId, `%${searchTerm}%`]
    );
    return result.rows;
  }

  /**
   * Find outfits containing specific clothing item
   */
  static async findByClothingItem(userId: string, clothingItemId: string): Promise<OutfitAttributes[]> {
    const result = await database.query(
      'SELECT * FROM outfits WHERE user_id = $1 AND clothing_item_ids::jsonb ? $2 ORDER BY created_at DESC',
      [userId, clothingItemId]
    );
    return result.rows;
  }

  /**
   * Update outfit
   */
  static async update(id: string, outfitData: Partial<OutfitAttributes>): Promise<OutfitAttributes> {
    const fields = [];
    const values = [];
    let paramCount = 1;

    // Build dynamic update query
    for (const [key, value] of Object.entries(outfitData)) {
      if (value !== undefined) {
        fields.push(`${key} = $${paramCount + 1}`);
        if (key === 'clothing_item_ids' || key === 'style_tags' || key === 'weather_conditions' || key === 'metadata') {
          values.push(JSON.stringify(value));
        } else {
          values.push(value);
        }
        paramCount++;
      }
    }

    if (fields.length === 0) {
      throw new Error('No fields to update');
    }

    const query = `
      UPDATE outfits 
      SET ${fields.join(', ')}, updated_at = CURRENT_TIMESTAMP
      WHERE id = $1
      RETURNING *
    `;

    const result = await database.query(query, [id, ...values]);
    return result.rows[0];
  }

  /**
   * Toggle favorite status
   */
  static async toggleFavorite(id: string): Promise<OutfitAttributes> {
    const result = await database.query(
      'UPDATE outfits SET favorite = NOT favorite, updated_at = CURRENT_TIMESTAMP WHERE id = $1 RETURNING *',
      [id]
    );
    return result.rows[0];
  }

  /**
   * Delete outfit
   */
  static async delete(id: string): Promise<boolean> {
    const result = await database.query(
      'DELETE FROM outfits WHERE id = $1',
      [id]
    );
    return (result.rowCount || 0) > 0;
  }

  /**
   * Get outfit with clothing items details
   */
  static async findWithClothingItems(id: string): Promise<any> {
    const query = `
      SELECT 
        o.*,
        COALESCE(
          json_agg(
            json_build_object(
              'id', ci.id,
              'name', ci.name,
              'category', ci.category,
              'color', ci.color,
              'image_url', ci.image_url
            )
          ) FILTER (WHERE ci.id IS NOT NULL), 
          '[]'
        ) as clothing_items
      FROM outfits o
      LEFT JOIN clothing_items ci ON ci.id = ANY(
        SELECT jsonb_array_elements_text(o.clothing_item_ids::jsonb)::text
      )
      WHERE o.id = $1
      GROUP BY o.id
    `;

    const result = await database.query(query, [id]);
    return result.rows[0] || null;
  }

  /**
   * Count outfits by user
   */
  static async countByUser(userId: string): Promise<number> {
    const result = await database.query(
      'SELECT COUNT(*) FROM outfits WHERE user_id = $1',
      [userId]
    );
    return parseInt(result.rows[0].count);
  }

  /**
   * Get outfit statistics for user
   */
  static async getStatsByUser(userId: string): Promise<any> {
    const result = await database.query(
      `SELECT 
         COUNT(*) as total_outfits,
         COUNT(CASE WHEN favorite = true THEN 1 END) as favorite_outfits,
         COUNT(DISTINCT occasion) as unique_occasions,
         COUNT(DISTINCT season) as unique_seasons
       FROM outfits 
       WHERE user_id = $1`,
      [userId]
    );
    return result.rows[0];
  }
}
