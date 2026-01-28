/**
 * User Routes
 * GET  /api/user/me
 * PUT  /api/user/update
 * GET  /api/user/preferences
 * PUT  /api/user/preferences
 * GET  /api/user/app-state
 * PUT  /api/user/app-state
 */

const express = require('express');
const db = require('../db');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// All routes require authentication
router.use(authenticateToken);

// ═══════════════════════════════════════════════════════════════
// GET CURRENT USER
// ═══════════════════════════════════════════════════════════════

router.get('/me', async (req, res, next) => {
    try {
        const result = await db.query(
            `SELECT id, email, name, avatar_url, auth_provider, created_at, last_login, metadata
       FROM users WHERE id = $1`,
            [req.user.userId]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'User not found',
            });
        }

        res.json({
            success: true,
            ...result.rows[0],
        });

    } catch (error) {
        next(error);
    }
});

// ═══════════════════════════════════════════════════════════════
// UPDATE USER PROFILE
// ═══════════════════════════════════════════════════════════════

router.put('/update', async (req, res, next) => {
    try {
        const { name, avatar_url, metadata } = req.body;

        const result = await db.query(
            `UPDATE users 
       SET name = COALESCE($1, name),
           avatar_url = COALESCE($2, avatar_url),
           metadata = COALESCE($3, metadata)
       WHERE id = $4
       RETURNING id, email, name, avatar_url, metadata`,
            [name, avatar_url, metadata ? JSON.stringify(metadata) : null, req.user.userId]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'User not found',
            });
        }

        res.json({
            success: true,
            user: result.rows[0],
        });

    } catch (error) {
        next(error);
    }
});

// ═══════════════════════════════════════════════════════════════
// GET USER PREFERENCES
// ═══════════════════════════════════════════════════════════════

router.get('/preferences', async (req, res, next) => {
    try {
        const result = await db.query(
            `SELECT theme_mode, notifications_enabled, email_notifications, last_active_route
       FROM user_preferences WHERE user_id = $1`,
            [req.user.userId]
        );

        if (result.rows.length === 0) {
            // Create default preferences if not exists
            const insertResult = await db.query(
                `INSERT INTO user_preferences (user_id) 
         VALUES ($1) 
         RETURNING theme_mode, notifications_enabled, email_notifications, last_active_route`,
                [req.user.userId]
            );

            return res.json({
                success: true,
                ...insertResult.rows[0],
            });
        }

        res.json({
            success: true,
            ...result.rows[0],
        });

    } catch (error) {
        next(error);
    }
});

// ═══════════════════════════════════════════════════════════════
// UPDATE USER PREFERENCES
// ═══════════════════════════════════════════════════════════════

router.put('/preferences', async (req, res, next) => {
    try {
        const { theme_mode, notifications_enabled, email_notifications, last_active_route } = req.body;

        const result = await db.query(
            `UPDATE user_preferences 
       SET theme_mode = COALESCE($1, theme_mode),
           notifications_enabled = COALESCE($2, notifications_enabled),
           email_notifications = COALESCE($3, email_notifications),
           last_active_route = COALESCE($4, last_active_route),
           updated_at = CURRENT_TIMESTAMP
       WHERE user_id = $5
       RETURNING theme_mode, notifications_enabled, email_notifications, last_active_route`,
            [theme_mode, notifications_enabled, email_notifications, last_active_route, req.user.userId]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'User preferences not found',
            });
        }

        res.json({
            success: true,
            ...result.rows[0],
        });

    } catch (error) {
        next(error);
    }
});

// ═══════════════════════════════════════════════════════════════
// GET APP STATE (for background restoration)
// ═══════════════════════════════════════════════════════════════

router.get('/app-state', async (req, res, next) => {
    try {
        const result = await db.query(
            `SELECT last_active_route, app_state
       FROM user_preferences WHERE user_id = $1`,
            [req.user.userId]
        );

        if (result.rows.length === 0) {
            return res.json({
                success: true,
                last_route: null,
                app_state: {},
            });
        }

        res.json({
            success: true,
            last_route: result.rows[0].last_active_route,
            app_state: result.rows[0].app_state || {},
        });

    } catch (error) {
        next(error);
    }
});

// ═══════════════════════════════════════════════════════════════
// SAVE APP STATE
// ═══════════════════════════════════════════════════════════════

router.put('/app-state', async (req, res, next) => {
    try {
        const { last_route, app_state } = req.body;

        await db.query(
            `UPDATE user_preferences 
       SET last_active_route = COALESCE($1, last_active_route),
           app_state = COALESCE($2, app_state),
           updated_at = CURRENT_TIMESTAMP
       WHERE user_id = $3`,
            [last_route, app_state ? JSON.stringify(app_state) : null, req.user.userId]
        );

        res.json({
            success: true,
            message: 'App state saved',
        });

    } catch (error) {
        next(error);
    }
});

module.exports = router;
