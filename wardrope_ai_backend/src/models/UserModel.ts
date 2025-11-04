import { database } from '../libs/database';
import { v4 as uuidv4 } from 'uuid';

export interface UserModelAttributes {
  id?: string;
  user_id: string;
  model_name?: string;
  model_type?: string;
  model_image_url?: string;
  original_image_url?: string;
  processed_model_url?: string;
  model_data_url?: string;
  measurements?: any;
  is_primary?: boolean;
  processing_status?: 'pending' | 'processing' | 'completed' | 'failed';
  processing_progress?: number;
  error_message?: string;
  metadata?: any;
  created_at?: Date;
  updated_at?: Date;
}

export class UserModel {
  static tableName = 'user_models';

  /**
   * Create a new user model
   */
  static async create(modelData: UserModelAttributes): Promise<UserModelAttributes> {
    const model = {
      id: uuidv4(),
      ...modelData,
      processing_status: modelData.processing_status || 'pending',
      processing_progress: modelData.processing_progress || 0,
      is_primary: modelData.is_primary || false,
      created_at: new Date(),
      updated_at: new Date(),
    };

    const query = `
      INSERT INTO user_models (id, user_id, model_name, model_image_url, model_data_url, measurements, is_primary, processing_status, processing_progress, metadata, created_at, updated_at)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
      RETURNING *
    `;

    const values = [
      model.id,
      model.user_id,
      model.model_name,
      model.model_image_url,
      model.model_data_url,
      JSON.stringify(model.measurements || {}),
      model.is_primary,
      model.processing_status,
      model.processing_progress,
      JSON.stringify(model.metadata || {}),
      model.created_at,
      model.updated_at,
    ];

    const result = await database.query(query, values);
    return result.rows[0];
  }

  /**
   * Find user model by ID
   */
  static async findById(id: string): Promise<UserModelAttributes | null> {
    const result = await database.query(
      'SELECT * FROM user_models WHERE id = $1',
      [id]
    );
    return result.rows[0] || null;
  }

  /**
   * Find models by user ID
   */
  static async findByUserId(userId: string): Promise<UserModelAttributes[]> {
    const result = await database.query(
      'SELECT * FROM user_models WHERE user_id = $1 ORDER BY created_at DESC',
      [userId]
    );
    return result.rows;
  }

  /**
   * Get primary model for user
   */
  static async getPrimaryModel(userId: string): Promise<UserModelAttributes | null> {
    const result = await database.query(
      'SELECT * FROM user_models WHERE user_id = $1 AND is_primary = true',
      [userId]
    );
    return result.rows[0] || null;
  }

  /**
   * Set primary model for user
   */
  static async setPrimaryModel(userId: string, modelId: string): Promise<UserModelAttributes> {
    // First, unset all primary models for this user
    await database.query(
      'UPDATE user_models SET is_primary = false WHERE user_id = $1',
      [userId]
    );

    // Then set the specified model as primary
    const result = await database.query(
      'UPDATE user_models SET is_primary = true, updated_at = CURRENT_TIMESTAMP WHERE id = $1 AND user_id = $2 RETURNING *',
      [modelId, userId]
    );

    return result.rows[0];
  }

  /**
   * Update model processing status
   */
  static async updateProcessingStatus(
    id: string, 
    status: 'pending' | 'processing' | 'completed' | 'failed',
    progress?: number
  ): Promise<UserModelAttributes> {
    const fields = ['processing_status = $2'];
    const values: any[] = [id, status];

    if (progress !== undefined) {
      fields.push('processing_progress = $3');
      values.push(progress);
    }

    const query = `
      UPDATE user_models 
      SET ${fields.join(', ')}, updated_at = CURRENT_TIMESTAMP
      WHERE id = $1
      RETURNING *
    `;

    const result = await database.query(query, values);
    return result.rows[0];
  }

  /**
   * Update user model
   */
  static async update(id: string, modelData: Partial<UserModelAttributes>): Promise<UserModelAttributes> {
    const fields = [];
    const values = [];
    let paramCount = 1;

    // Build dynamic update query
    for (const [key, value] of Object.entries(modelData)) {
      if (value !== undefined) {
        fields.push(`${key} = $${paramCount + 1}`);
        if (key === 'measurements' || key === 'metadata') {
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
      UPDATE user_models 
      SET ${fields.join(', ')}, updated_at = CURRENT_TIMESTAMP
      WHERE id = $1
      RETURNING *
    `;

    const result = await database.query(query, [id, ...values]);
    return result.rows[0];
  }

  /**
   * Delete user model
   */
  static async delete(id: string): Promise<boolean> {
    const result = await database.query(
      'DELETE FROM user_models WHERE id = $1',
      [id]
    );
    return (result.rowCount || 0) > 0;
  }

  /**
   * Get models by processing status
   */
  static async findByProcessingStatus(status: string): Promise<UserModelAttributes[]> {
    const result = await database.query(
      'SELECT * FROM user_models WHERE processing_status = $1 ORDER BY created_at ASC',
      [status]
    );
    return result.rows;
  }

  /**
   * Count models by user
   */
  static async countByUser(userId: string): Promise<number> {
    const result = await database.query(
      'SELECT COUNT(*) FROM user_models WHERE user_id = $1',
      [userId]
    );
    return parseInt(result.rows[0].count);
  }

  /**
   * Unset primary model for user
   */
  static async unsetPrimary(userId: string): Promise<void> {
    await database.query(
      'UPDATE user_models SET is_primary = false, updated_at = CURRENT_TIMESTAMP WHERE user_id = $1',
      [userId]
    );
  }
}
