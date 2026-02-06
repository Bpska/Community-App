const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

const pool = new Pool({
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432,
    database: process.env.DB_NAME || 'propoly',
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD,
});

async function initializeDatabase() {
    console.log('\n🚀 Initializing Community Chat Database...\n');

    try {
        const client = await pool.connect();

        // Read and execute SQL file
        const sqlFile = path.join(__dirname, 'init_db.sql');
        const sql = fs.readFileSync(sqlFile, 'utf8');

        console.log('📝 Executing database schema...\n');
        await client.query(sql);

        // Verify tables
        const result = await client.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public' 
      AND table_name IN ('users', 'communities', 'messages', 'community_members', 'notifications')
      ORDER BY table_name;
    `);

        console.log('✅ Community Chat tables created successfully:\n');
        result.rows.forEach(row => {
            console.log(`  ✓ ${row.table_name}`);
        });

        // Get table counts
        console.log('\n📊 Table Statistics:\n');
        for (const row of result.rows) {
            const countResult = await client.query(`SELECT COUNT(*) FROM ${row.table_name}`);
            console.log(`  ${row.table_name}: ${countResult.rows[0].count} records`);
        }

        client.release();
        console.log('\n✨ Database initialization completed!\n');
        process.exit(0);
    } catch (err) {
        console.error('❌ Database initialization failed:', err.message);
        console.error(err);
        process.exit(1);
    }
}

initializeDatabase();
