/**
 * Authentication Routes
 * POST /api/auth/login
 * POST /api/auth/logout
 * GET  /api/auth/validate
 * POST /api/auth/refresh
 */

const express = require('express');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');
const db = require('../db');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// ═══════════════════════════════════════════════════════════════
// LOGIN
// ═══════════════════════════════════════════════════════════════

router.post('/login', async (req, res, next) => {
    try {
        const { email, name, auth_provider, provider_id, avatar_url, device_info } = req.body;

        // Validate required fields
        if (!email || !auth_provider) {
            return res.status(400).json({
                success: false,
                message: 'Email and auth_provider are required',
            });
        }

        // Validate auth provider
        const validProviders = ['google', 'email', 'apple'];
        if (!validProviders.includes(auth_provider)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid auth provider',
            });
        }

        // Use transaction for user upsert + session creation
        const result = await db.transaction(async (client) => {
            // Check if user exists
            const existingUser = await client.query(
                'SELECT id, email, name FROM users WHERE email = $1',
                [email]
            );

            let userId;
            let isNewUser = false;

            if (existingUser.rows.length === 0) {
                // Insert new user
                const insertResult = await client.query(
                    `INSERT INTO users (email, name, auth_provider, provider_id, avatar_url, last_login)
           VALUES ($1, $2, $3, $4, $5, CURRENT_TIMESTAMP)
           RETURNING id`,
                    [email, name, auth_provider, provider_id, avatar_url]
                );
                userId = insertResult.rows[0].id;
                isNewUser = true;

                // Create default preferences
                await client.query(
                    'INSERT INTO user_preferences (user_id) VALUES ($1)',
                    [userId]
                );
            } else {
                // Update existing user
                userId = existingUser.rows[0].id;
                await client.query(
                    `UPDATE users 
           SET last_login = CURRENT_TIMESTAMP,
               name = COALESCE($1, name),
               avatar_url = COALESCE($2, avatar_url)
           WHERE id = $3`,
                    [name, avatar_url, userId]
                );
            }

            // Generate tokens
            const accessToken = jwt.sign(
                { userId, email },
                process.env.JWT_SECRET,
                { expiresIn: process.env.JWT_EXPIRES_IN || '30d' }
            );

            const refreshToken = jwt.sign(
                { userId, email, type: 'refresh' },
                process.env.JWT_SECRET,
                { expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '90d' }
            );

            // Calculate expiry
            const expiresAt = new Date();
            expiresAt.setDate(expiresAt.getDate() + 30);

            // Create session
            await client.query(
                `INSERT INTO sessions (user_id, access_token, refresh_token, device_info, ip_address, expires_at)
         VALUES ($1, $2, $3, $4, $5, $6)`,
                [userId, accessToken, refreshToken, device_info, req.ip, expiresAt]
            );

            return {
                userId,
                isNewUser,
                accessToken,
                refreshToken,
                expiresAt: expiresAt.toISOString(),
            };
        });

        res.json({
            success: true,
            user_id: result.userId,
            is_new_user: result.isNewUser,
            access_token: result.accessToken,
            refresh_token: result.refreshToken,
            expires_at: result.expiresAt,
            user: {
                id: result.userId,
                email,
                name,
            },
        });

    } catch (error) {
        next(error);
    }
});

// ═══════════════════════════════════════════════════════════════
// LOGOUT
// ═══════════════════════════════════════════════════════════════

router.post('/logout', authenticateToken, async (req, res, next) => {
    try {
        const token = req.headers.authorization?.split(' ')[1];

        if (token) {
            await db.query(
                'UPDATE sessions SET is_valid = FALSE WHERE access_token = $1',
                [token]
            );
        }

        res.json({
            success: true,
            message: 'Logged out successfully',
        });

    } catch (error) {
        next(error);
    }
});

// ═══════════════════════════════════════════════════════════════
// VALIDATE SESSION
// ═══════════════════════════════════════════════════════════════

router.get('/validate', authenticateToken, async (req, res, next) => {
    try {
        const token = req.headers.authorization?.split(' ')[1];

        // Check session in database
        const result = await db.query(
            `SELECT s.is_valid, s.expires_at, u.id, u.email, u.name
       FROM sessions s
       JOIN users u ON s.user_id = u.id
       WHERE s.access_token = $1`,
            [token]
        );

        if (result.rows.length === 0) {
            return res.json({ valid: false });
        }

        const session = result.rows[0];
        const isValid = session.is_valid && new Date(session.expires_at) > new Date();

        if (isValid) {
            // Update last used
            await db.query(
                'UPDATE sessions SET last_used_at = CURRENT_TIMESTAMP WHERE access_token = $1',
                [token]
            );
        }

        res.json({
            valid: isValid,
            user: isValid ? {
                id: session.id,
                email: session.email,
                name: session.name,
            } : null,
        });

    } catch (error) {
        next(error);
    }
});

// ═══════════════════════════════════════════════════════════════
// REFRESH TOKEN
// ═══════════════════════════════════════════════════════════════

router.post('/refresh', async (req, res, next) => {
    try {
        const { refresh_token } = req.body;

        if (!refresh_token) {
            return res.status(400).json({
                success: false,
                message: 'Refresh token is required',
            });
        }

        // Verify refresh token
        let decoded;
        try {
            decoded = jwt.verify(refresh_token, process.env.JWT_SECRET);
        } catch (err) {
            return res.status(401).json({
                success: false,
                message: 'Invalid refresh token',
            });
        }

        if (decoded.type !== 'refresh') {
            return res.status(401).json({
                success: false,
                message: 'Invalid token type',
            });
        }

        // Check session exists
        const sessionResult = await db.query(
            `SELECT s.id, s.user_id, u.email
       FROM sessions s
       JOIN users u ON s.user_id = u.id
       WHERE s.refresh_token = $1 AND s.is_valid = TRUE`,
            [refresh_token]
        );

        if (sessionResult.rows.length === 0) {
            return res.status(401).json({
                success: false,
                message: 'Session not found or expired',
            });
        }

        const session = sessionResult.rows[0];

        // Generate new access token
        const newAccessToken = jwt.sign(
            { userId: session.user_id, email: session.email },
            process.env.JWT_SECRET,
            { expiresIn: process.env.JWT_EXPIRES_IN || '30d' }
        );

        // Calculate new expiry
        const expiresAt = new Date();
        expiresAt.setDate(expiresAt.getDate() + 30);

        // Update session
        await db.query(
            `UPDATE sessions 
       SET access_token = $1, expires_at = $2, last_used_at = CURRENT_TIMESTAMP
       WHERE id = $3`,
            [newAccessToken, expiresAt, session.id]
        );

        res.json({
            success: true,
            access_token: newAccessToken,
            expires_at: expiresAt.toISOString(),
        });

    } catch (error) {
        next(error);
    }
});

module.exports = router;
