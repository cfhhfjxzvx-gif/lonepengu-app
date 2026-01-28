/**
 * LonePengu Backend API Server
 * Express + PostgreSQL
 */

require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');

const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/user');
const { errorHandler, notFoundHandler } = require('./middleware/errorHandler');

const app = express();
const PORT = process.env.PORT || 3000;

// ═══════════════════════════════════════════════════════════════
// MIDDLEWARE
// ═══════════════════════════════════════════════════════════════

// Security headers
app.use(helmet());

// CORS
app.use(cors({
    origin: process.env.CORS_ORIGIN?.split(',') || '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-App-Version', 'X-Platform'],
    credentials: true,
}));

// Rate limiting
const limiter = rateLimit({
    windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000,
    max: parseInt(process.env.RATE_LIMIT_MAX) || 100,
    message: { error: 'Too many requests, please try again later.' }
});
app.use('/api/', limiter);

// Body parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Logging
if (process.env.NODE_ENV !== 'test') {
    app.use(morgan('combined'));
}

// ═══════════════════════════════════════════════════════════════
// ROUTES
// ═══════════════════════════════════════════════════════════════

// Health check
app.get('/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// API routes
app.use('/api/auth', authRoutes);
app.use('/api/user', userRoutes);

// ═══════════════════════════════════════════════════════════════
// ERROR HANDLING
// ═══════════════════════════════════════════════════════════════

// 404 handler
app.use(notFoundHandler);

// Global error handler
app.use(errorHandler);

// ═══════════════════════════════════════════════════════════════
// START SERVER
// ═══════════════════════════════════════════════════════════════

app.listen(PORT, () => {
    console.log(`
  ╔═══════════════════════════════════════════════════════════════╗
  ║                                                               ║
  ║   🐧 LonePengu API Server                                     ║
  ║                                                               ║
  ║   Status: Running                                             ║
  ║   Port: ${PORT}                                                  ║
  ║   Environment: ${process.env.NODE_ENV || 'development'}                              ║
  ║                                                               ║
  ║   Endpoints:                                                  ║
  ║   - POST /api/auth/login                                      ║
  ║   - POST /api/auth/logout                                     ║
  ║   - GET  /api/auth/validate                                   ║
  ║   - POST /api/auth/refresh                                    ║
  ║   - GET  /api/user/me                                         ║
  ║   - PUT  /api/user/update                                     ║
  ║   - GET  /api/user/preferences                                ║
  ║   - PUT  /api/user/preferences                                ║
  ║   - GET  /api/user/app-state                                  ║
  ║   - PUT  /api/user/app-state                                  ║
  ║                                                               ║
  ╚═══════════════════════════════════════════════════════════════╝
  `);
});

module.exports = app;
