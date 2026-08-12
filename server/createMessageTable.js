const pool = require('./database');

async function createMessageTable() {
    try {
        await pool.query(`
            CREATE TABLE IF NOT EXISTS messages (
                id SERIAL PRIMARY KEY,
                sender_id INT REFERENCES users(id),
                receiver_id INT REFERENCES users(id),
                text TEXT NOT NULL,
                sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        `);
        console.log('Messages table created successfully');
    } catch (e) {
        console.log('Error creating messages table:', e);
    }
}
createMessageTable();