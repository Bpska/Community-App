const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

// Database configuration
const pool = new Pool({
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432,
    database: process.env.DB_NAME || 'propoly',
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD,
});

async function testConnection() {
    console.log('\n🔍 Testing database connection...\n');
    console.log('Configuration:');
    console.log(`  Host: ${process.env.DB_HOST}`);
    console.log(`  Port: ${process.env.DB_PORT}`);
    console.log(`  Database: ${process.env.DB_NAME}`);
    console.log(`  User: ${process.env.DB_USER}\n`);

    try {
        // Test connection
        const client = await pool.connect();
        console.log('✅ Successfully connected to PostgreSQL!\n');

        // Get database version
        const versionResult = await client.query('SELECT version();');
        console.log('📊 PostgreSQL Version:');
        console.log(`  ${versionResult.rows[0].version}\n`);

        // Check if tables exist
        const tablesResult = await client.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public' 
      ORDER BY table_name;
    `);

        if (tablesResult.rows.length > 0) {
            console.log('📋 Existing Tables:');
            tablesResult.rows.forEach(row => {
                console.log(`  ✓ ${row.table_name}`);
            });
        } else {
            console.log('⚠️  No tables found in database. Need to run initialization script.\n');
            console.log('To initialize tables, you can:');
            console.log('  1. Run: psql -U postgres -d propoly -f init_db.sql');
            console.log('  2. Or manually execute the SQL in init_db.sql\n');
        }

        client.release();
        console.log('\n✨ Database connection test completed successfully!\n');
        process.exit(0);
    } catch (err) {
        console.error('❌ Database connection failed:', err.message);
        console.error('\nPossible issues:');
        console.error('  • PostgreSQL server is not running');
        console.error('  • Database "propoly" does not exist');
        console.error('  • Wrong credentials in .env file');
        console.error('  • PostgreSQL is not accepting connections\n');
        process.exit(1);
    }
}

testConnection();
