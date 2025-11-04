import { database } from '../libs/database';
import { v4 as uuidv4 } from 'uuid';

export interface UserAttributes {
  id?: string;
  email: string;
  password_hash?: string;
  first_name?: string;
  last_name?: string;
  profile_image_url?: string;
  onboarding_completed?: boolean;
  preferences?: any;
  is_active?: boolean;
  email_verified?: boolean;
  created_at?: Date;
  updated_at?: Date;
}

export class User {
  static tableName = 'users';

  /**
   * Create a new user
   */
  static async create(userData: UserAttributes): Promise<UserAttributes> {
    const user = {
      id: uuidv4(),
      ...userData,
      created_at: new Date(),
      updated_at: new Date(),
    };

    const query = `
      INSERT INTO users (id, email, password_hash, first_name, last_name, profile_image_url, onboarding_completed, preferences, created_at, updated_at)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
      RETURNING *
    `;

    const values = [
      user.id,
      user.email,
      user.password_hash,
      user.first_name,
      user.last_name,
      user.profile_image_url,
      user.onboarding_completed || false,
      JSON.stringify(user.preferences || {}),
      user.created_at,
      user.updated_at,
    ];

    const result = await database.query(query, values);
    return result.rows[0];
  }

  /**
   * Find user by ID
   */
  static async findById(id: string): Promise<UserAttributes | null> {
    const result = await database.query(
      'SELECT * FROM users WHERE id = $1',
      [id]
    );
    return result.rows[0] || null;
  }

  /**
   * Find user by email
   */
  static async findByEmail(email: string): Promise<UserAttributes | null> {
    const result = await database.query(
      'SELECT * FROM users WHERE email = $1',
      [email]
    );
    return result.rows[0] || null;
  }

  /**
   * Update user
   */
  static async update(id: string, userData: Partial<UserAttributes>): Promise<UserAttributes> {
    const fields = [];
    const values = [];
    let paramCount = 1;

    // Build dynamic update query
    for (const [key, value] of Object.entries(userData)) {
      if (value !== undefined) {
        fields.push(`${key} = $${paramCount + 1}`);
        values.push(key === 'preferences' ? JSON.stringify(value) : value);
        paramCount++;
      }
    }

    if (fields.length === 0) {
      throw new Error('No fields to update');
    }

    const query = `
      UPDATE users 
      SET ${fields.join(', ')}, updated_at = CURRENT_TIMESTAMP
      WHERE id = $1
      RETURNING *
    `;

    const result = await database.query(query, [id, ...values]);
    return result.rows[0];
  }

  /**
   * Delete user
   */
  static async delete(id: string): Promise<boolean> {
    const result = await database.query(
      'DELETE FROM users WHERE id = $1',
      [id]
    );
    return (result.rowCount || 0) > 0;
  }

  /**
   * Check if user exists by email
   */
  static async existsByEmail(email: string): Promise<boolean> {
    const result = await database.query(
      'SELECT EXISTS(SELECT 1 FROM users WHERE email = $1)',
      [email]
    );
    return result.rows[0].exists;
  }

  /**
   * Get all users with pagination
   */
  static async findAll(limit: number = 10, offset: number = 0): Promise<UserAttributes[]> {
    const result = await database.query(
      'SELECT * FROM users ORDER BY created_at DESC LIMIT $1 OFFSET $2',
      [limit, offset]
    );
    return result.rows;
  }

  /**
   * Count total users
   */
  static async count(): Promise<number> {
    const result = await database.query('SELECT COUNT(*) FROM users');
    return parseInt(result.rows[0].count);
  }

  /**
   * Verify user email
   */
  static async verifyEmail(userId: string): Promise<UserAttributes | null> {
    const result = await database.query(
      'UPDATE users SET email_verified = true, updated_at = CURRENT_TIMESTAMP WHERE id = $1 RETURNING *',
      [userId]
    );
    return result.rows[0] || null;
  }

  /**
   * Convert user data to safe JSON (removes password hash)
   */
  static toSafeJSON(user: UserAttributes): any {
    const { password_hash, ...safeUser } = user;
    return safeUser;
  }
}
