/**
 * PostgreSQL Database Connection Pool
 */

const { Pool } = require('pg');

// Create connection pool
const pool = new Pool({
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT) || 5432,
    database: process.env.DB_NAME || 'lonepengu_db',
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD,
    ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : false,
    max: 20, // Maximum connections
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 2000,
});

// Test connection on startup
pool.on('connect', () => {
    console.log('📦 Database connected');
});

pool.on('error', (err) => {
    console.error('❌ Database error:', err);
});

/**
 * Execute a query with parameters
 * @param {string} text - SQL query
 * @param {Array} params - Query parameters
 * @returns {Promise<QueryResult>}
 */
const query = async (text, params) => {
    const start = Date.now();
    try {
        const result = await pool.query(text, params);
        const duration = Date.now() - start;
        console.log('Executed query', { text: text.substring(0, 50), duration, rows: result.rowCount });
        return result;
    } catch (error) {
        console.error('Query error:', error.message);
        throw error;
    }
};

/**
 * Get a client from the pool for transactions
 * @returns {Promise<PoolClient>}
 */
const getClient = async () => {
    const client = await pool.connect();
    const originalQuery = client.query.bind(client);
    const originalRelease = client.release.bind(client);

    // Set a timeout of 5 seconds on idle
    const timeout = setTimeout(() => {
        console.error('Client has been checked out for too long');
        client.release();
    }, 5000);

    client.query = (...args) => {
        clearTimeout(timeout);
        return originalQuery(...args);
    };

    client.release = () => {
        clearTimeout(timeout);
        return originalRelease();
    };

    return client;
};

/**
 * Execute a transaction
 * @param {Function} callback - Async function receiving client
 * @returns {Promise<any>}
 */
const transaction = async (callback) => {
    const client = await pool.connect();
    try {
        await client.query('BEGIN');
        const result = await callback(client);
        await client.query('COMMIT');
        return result;
    } catch (error) {
        await client.query('ROLLBACK');
        throw error;
    } finally {
        client.release();
    }
};

module.exports = {
    query,
    getClient,
    transaction,
    pool,
};
