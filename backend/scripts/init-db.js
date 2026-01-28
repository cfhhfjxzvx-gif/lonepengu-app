/**
 * Database Initialization Script
 * Run with: npm run db:init
 */

require('dotenv').config();
const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');

async function initDatabase() {
    console.log('🔧 Initializing LonePengu Database...\n');

    const pool = new Pool({
        host: process.env.DB_HOST || 'localhost',
        port: parseInt(process.env.DB_PORT) || 5432,
        database: process.env.DB_NAME || 'lonepengu_db',
        user: process.env.DB_USER || 'postgres',
        password: process.env.DB_PASSWORD,
        ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : false,
    });

    try {
        // Test connection
        await pool.query('SELECT NOW()');
        console.log('✅ Connected to PostgreSQL\n');

        // Read schema file
        const schemaPath = path.join(__dirname, '..', '..', 'database', 'schema.sql');

        if (!fs.existsSync(schemaPath)) {
            throw new Error(`Schema file not found at: ${schemaPath}`);
        }

        const schema = fs.readFileSync(schemaPath, 'utf8');

        // Execute schema
        console.log('📦 Executing schema...\n');
        await pool.query(schema);

        console.log('✅ Schema created successfully!\n');

        // Verify tables
        const tables = await pool.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public' 
      AND table_type = 'BASE TABLE'
      ORDER BY table_name
    `);

        console.log('📋 Created tables:');
        tables.rows.forEach(row => {
            console.log(`   - ${row.table_name}`);
        });

        console.log('\n✅ Database initialization complete!\n');

    } catch (error) {
        console.error('❌ Error initializing database:', error.message);
        console.error('\nMake sure:');
        console.error('  1. PostgreSQL is running');
        console.error('  2. Database "lonepengu_db" exists');
        console.error('  3. .env file has correct credentials');
        console.error('\nTo create the database manually:');
        console.error('  CREATE DATABASE lonepengu_db;');
        process.exit(1);
    } finally {
        await pool.end();
    }
}

initDatabase();
