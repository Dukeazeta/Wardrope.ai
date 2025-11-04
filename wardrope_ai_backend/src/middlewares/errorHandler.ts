import { Request, Response, NextFunction } from 'express';

export interface ApiError extends Error {
  statusCode?: number;
  status?: string;
  isOperational?: boolean;
}

export const errorHandler = (
  err: ApiError,
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  let error = { ...err };
  error.message = err.message;

  // Log error
  console.error(err);

  // PostgreSQL errors
  if (err.name === 'QueryResultError') {
    const message = 'Database query error';
    error = createError(message, 400);
  }

  // PostgreSQL duplicate key error (unique constraint violation)
  if ((err as any).code === '23505') {
    const message = 'Duplicate entry - resource already exists';
    error = createError(message, 409);
  }

  // PostgreSQL foreign key constraint violation
  if ((err as any).code === '23503') {
    const message = 'Referenced resource does not exist';
    error = createError(message, 400);
  }

  // PostgreSQL not null constraint violation
  if ((err as any).code === '23502') {
    const message = 'Required field is missing';
    error = createError(message, 400);
  }

  // PostgreSQL invalid input syntax
  if ((err as any).code === '22P02') {
    const message = 'Invalid input format';
    error = createError(message, 400);
  }

  // PostgreSQL connection errors
  if ((err as any).code === 'ECONNREFUSED' || (err as any).code === 'ENOTFOUND') {
    const message = 'Database connection error';
    error = createError(message, 503);
  }

  // JWT errors
  if (err.name === 'JsonWebTokenError') {
    const message = 'Invalid token';
    error = createError(message, 401);
  }

  if (err.name === 'TokenExpiredError') {
    const message = 'Token expired';
    error = createError(message, 401);
  }

  // Multer errors
  if (err.name === 'MulterError') {
    let message = 'File upload error';
    if ((err as any).code === 'LIMIT_FILE_SIZE') {
      message = 'File too large';
    }
    error = createError(message, 400);
  }

  res.status(error.statusCode || 500).json({
    success: false,
    error: error.message || 'Server Error',
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
  });
};

const createError = (message: string, statusCode: number): ApiError => {
  const error = new Error(message) as ApiError;
  error.statusCode = statusCode;
  error.isOperational = true;
  return error;
};

export { createError };
