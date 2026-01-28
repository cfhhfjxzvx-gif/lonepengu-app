/**
 * Authentication Middleware
 * Validates JWT tokens
 */

const jwt = require('jsonwebtoken');

/**
 * Middleware to authenticate JWT token
 */
const authenticateToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

    if (!token) {
        return res.status(401).json({
            success: false,
            message: 'Access token required',
            code: 'NO_TOKEN',
        });
    }

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.user = decoded;
        next();
    } catch (error) {
        if (error.name === 'TokenExpiredError') {
            return res.status(401).json({
                success: false,
                message: 'Token expired',
                code: 'TOKEN_EXPIRED',
            });
        }

        return res.status(403).json({
            success: false,
            message: 'Invalid token',
            code: 'INVALID_TOKEN',
        });
    }
};

/**
 * Optional authentication - sets user if token exists, continues if not
 */
const optionalAuth = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) {
        req.user = null;
        return next();
    }

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.user = decoded;
    } catch (error) {
        req.user = null;
    }

    next();
};

module.exports = {
    authenticateToken,
    optionalAuth,
};
