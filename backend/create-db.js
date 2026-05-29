require('dotenv').config();
const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

async function setupDatabase() {
  // Connect to default 'postgres' database to create new one
  const client = new Client({
    user: process.env.DB_USER,
    host: process.env.DB_HOST,
    database: 'postgres',
    password: process.env.DB_PASSWORD,
    port: process.env.DB_PORT,
  });

  try {
    await client.connect();
    
    // Check if database exists
    const res = await client.query("SELECT datname FROM pg_catalog.pg_database WHERE datname = 'community_app'");
    if (res.rowCount === 0) {
      console.log('Creating database community_app...');
      await client.query('CREATE DATABASE community_app');
      console.log('Database created.');
    } else {
      console.log('Database community_app already exists.');
    }
  } catch (err) {
    console.error('Error creating database:', err);
    process.exit(1);
  } finally {
    await client.end();
  }

  // Connect to the new community_app database and run schema.sql
  const appClient = new Client({
    user: process.env.DB_USER,
    host: process.env.DB_HOST,
    database: process.env.DB_NAME,
    password: process.env.DB_PASSWORD,
    port: process.env.DB_PORT,
  });

  try {
    await appClient.connect();
    const schemaSql = fs.readFileSync(path.join(__dirname, '..', 'schema.sql')).toString();
    console.log('Executing schema.sql...');
    await appClient.query(schemaSql);
    console.log('Schema successfully applied!');
  } catch (err) {
    console.error('Error executing schema.sql:', err);
  } finally {
    await appClient.end();
  }
}

setupDatabase();
