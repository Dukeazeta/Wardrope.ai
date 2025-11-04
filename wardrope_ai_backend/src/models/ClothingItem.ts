import { database } from '../libs/database';
import { v4 as uuidv4 } from 'uuid';

export interface ClothingItemAttributes {
  id?: string;
  user_id: string;
  name: string;
  category: string;
  subcategory?: string;
  color: string;
  size?: string;
  brand?: string;
  image_url?: string;
  tags?: string[];
  season?: string[];
  purchase_date?: Date;
  price?: number;
  metadata?: any;
  created_at?: Date;
  updated_at?: Date;
}

export class ClothingItem {
  static tableName = 'clothing_items';

  /**
   * Create a new clothing item
   */
  static async create(itemData: ClothingItemAttributes): Promise<ClothingItemAttributes> {
    const item = {
      id: uuidv4(),
      ...itemData,
      created_at: new Date(),
      updated_at: new Date(),
    };

    const query = `
      INSERT INTO clothing_items (id, user_id, name, category, subcategory, color, size, brand, image_url, tags, metadata, created_at, updated_at)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
      RETURNING *
    `;

    const values = [
      item.id,
      item.user_id,
      item.name,
      item.category,
      item.subcategory,
      item.color,
      item.size,
      item.brand,
      item.image_url,
      JSON.stringify(item.tags || []),
      JSON.stringify(item.metadata || {}),
      item.created_at,
      item.updated_at,
    ];

    const result = await database.query(query, values);
    return result.rows[0];
  }

  /**
   * Find clothing item by ID
   */
  static async findById(id: string): Promise<ClothingItemAttributes | null> {
    const result = await database.query(
      'SELECT * FROM clothing_items WHERE id = $1',
      [id]
    );
    return result.rows[0] || null;
  }

  /**
   * Find clothing items by user ID
   */
  static async findByUserId(userId: string, limit: number = 50, offset: number = 0): Promise<ClothingItemAttributes[]> {
    const result = await database.query(
      'SELECT * FROM clothing_items WHERE user_id = $1 ORDER BY created_at DESC LIMIT $2 OFFSET $3',
      [userId, limit, offset]
    );
    return result.rows;
  }

  /**
   * Find clothing items by category
   */
  static async findByCategory(userId: string, category: string): Promise<ClothingItemAttributes[]> {
    const result = await database.query(
      'SELECT * FROM clothing_items WHERE user_id = $1 AND category = $2 ORDER BY created_at DESC',
      [userId, category]
    );
    return result.rows;
  }

  /**
   * Search clothing items
   */
  static async search(userId: string, searchTerm: string): Promise<ClothingItemAttributes[]> {
    const result = await database.query(
      `SELECT * FROM clothing_items 
       WHERE user_id = $1 AND (
         name ILIKE $2 OR 
         category ILIKE $2 OR 
         subcategory ILIKE $2 OR 
         color ILIKE $2 OR 
         brand ILIKE $2
       )
       ORDER BY created_at DESC`,
      [userId, `%${searchTerm}%`]
    );
    return result.rows;
  }

  /**
   * Update clothing item
   */
  static async update(id: string, itemData: Partial<ClothingItemAttributes>): Promise<ClothingItemAttributes> {
    const fields = [];
    const values = [];
    let paramCount = 1;

    // Build dynamic update query
    for (const [key, value] of Object.entries(itemData)) {
      if (value !== undefined) {
        fields.push(`${key} = $${paramCount + 1}`);
        if (key === 'tags' || key === 'metadata') {
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
      UPDATE clothing_items 
      SET ${fields.join(', ')}, updated_at = CURRENT_TIMESTAMP
      WHERE id = $1
      RETURNING *
    `;

    const result = await database.query(query, [id, ...values]);
    return result.rows[0];
  }

  /**
   * Delete clothing item
   */
  static async delete(id: string): Promise<boolean> {
    const result = await database.query(
      'DELETE FROM clothing_items WHERE id = $1',
      [id]
    );
    return (result.rowCount || 0) > 0;
  }

  /**
   * Get clothing items by tags
   */
  static async findByTags(userId: string, tags: string[]): Promise<ClothingItemAttributes[]> {
    const result = await database.query(
      'SELECT * FROM clothing_items WHERE user_id = $1 AND tags ?| $2 ORDER BY created_at DESC',
      [userId, tags]
    );
    return result.rows;
  }

  /**
   * Get categories for user
   */
  static async getCategoriesByUser(userId: string): Promise<string[]> {
    const result = await database.query(
      'SELECT DISTINCT category FROM clothing_items WHERE user_id = $1 ORDER BY category',
      [userId]
    );
    return result.rows.map(row => row.category);
  }

  /**
   * Count clothing items by user
   */
  static async countByUser(userId: string): Promise<number> {
    const result = await database.query(
      'SELECT COUNT(*) FROM clothing_items WHERE user_id = $1',
      [userId]
    );
    return parseInt(result.rows[0].count);
  }
}
