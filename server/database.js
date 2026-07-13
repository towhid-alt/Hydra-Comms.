require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
    user: 'postgres', //database username
    host: 'localhost',
    database: 'postgres', // Use default database first
    password: process.env.DB_PASSWORD,
    port: 5432,
})

// Test the connection
pool.on('connect', () => {
    console.log('Database connected successfully');
});

pool.on('error', (err) => {
    console.error('Database connection error:', err);
});

module.exports = pool;//This makes the pool available for other files to use.