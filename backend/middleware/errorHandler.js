/**
 * Error Handler Middleware
 * Centralized error handling
 */

/**
 * 404 Not Found Handler
 */
const notFoundHandler = (req, res, next) => {
    res.status(404).json({
        success: false,
        message: `Route ${req.method} ${req.originalUrl} not found`,
        code: 'NOT_FOUND',
    });
};

/**
 * Global Error Handler
 */
const errorHandler = (err, req, res, next) => {
    console.error('Error:', err);

    // PostgreSQL errors
    if (err.code) {
        switch (err.code) {
            case '23505': // Unique violation
                return res.status(409).json({
                    success: false,
                    message: 'Resource already exists',
                    code: 'DUPLICATE_ENTRY',
                });
            case '23503': // Foreign key violation
                return res.status(400).json({
                    success: false,
                    message: 'Referenced resource not found',
                    code: 'FOREIGN_KEY_VIOLATION',
                });
            case '22P02': // Invalid input syntax
                return res.status(400).json({
                    success: false,
                    message: 'Invalid input format',
                    code: 'INVALID_INPUT',
                });
            case 'ECONNREFUSED':
                return res.status(503).json({
                    success: false,
                    message: 'Database connection failed',
                    code: 'DB_CONNECTION_ERROR',
                });
        }
    }

    // JWT errors
    if (err.name === 'JsonWebTokenError') {
        return res.status(401).json({
            success: false,
            message: 'Invalid token',
            code: 'INVALID_TOKEN',
        });
    }

    if (err.name === 'TokenExpiredError') {
        return res.status(401).json({
            success: false,
            message: 'Token expired',
            code: 'TOKEN_EXPIRED',
        });
    }

    // Validation errors
    if (err.name === 'ValidationError') {
        return res.status(400).json({
            success: false,
            message: err.message,
            code: 'VALIDATION_ERROR',
        });
    }

    // Default error
    const statusCode = err.statusCode || err.status || 500;
    const message = process.env.NODE_ENV === 'production'
        ? 'An unexpected error occurred'
        : err.message || 'Internal Server Error';

    res.status(statusCode).json({
        success: false,
        message,
        code: 'INTERNAL_ERROR',
        ...(process.env.NODE_ENV !== 'production' && { stack: err.stack }),
    });
};

module.exports = {
    notFoundHandler,
    errorHandler,
};
