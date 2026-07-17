const express = require('express');
const pool = require('./database');
const bcrypt = require('bcrypt');
const cors = require('cors')
const app = express();

const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.get('/test', (req,res) => {
    console.log('Test done. Endpoint is working');
    res.send('Test done. Endpoint is working');
});

app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});

app.post('/api/signup', async (req, res) => {
    try {
    const {username, password} = req.body
    // Hash the password before storing it
    const hashedPassword = await bcrypt.hash(password, 10)
    //Check if user already exists
     const userExists = await pool.query(
      'SELECT * FROM users WHERE username = $1',
      [username]
    )

    if (userExists.rows.length > 0) {
      return res.status(400).json({ error: 'User already exists' })
    }
    //Insert new user into the database
    const newUser = await pool.query(
        `INSERT INTO users (username, password) VALUES ($1, $2) RETURNING id, username`,
        [username, hashedPassword]
    )
    console.log('New user signed up:', username)
    res.status(201).json(newUser.rows[0])
} catch (error) {
    console.error('Error signing up user:', error)
    res.status(500).json({ error: 'Internal server error' })
}
});

//---------------LOGIN ENDPOINT----------------
app.post('/api/login', async (req,res) => {
    try{
        const {username, password} = req.body
        //Check if user exists
        const user = await pool.query(
            'SELECT * FROM users WHERE username = $1',
            [username]
        )
        if (user.rows.length === 0 ) {
            return res.status(400).json({ error: 'Invalid username' })
        }
        //password comparison
        const validPassword = await bcrypt.compare(password, user.rows[0].password)
        if (!validPassword) {
            return res.status(400).json({ error: 'Invalid password' })
        }
        console.log('User logged in:', username)
        res.status(200).json({ message: 'Login successful' })
    } catch (error) {
        console.error('Error logging in user:', error) 
        res.status(500).json({ error: 'Internal server error' })
    }
})

//--------------FETCH USERS ENDPOINT----------------
app.get('/api/users', async (req, res) => {
    try {
        const users = await pool.query('SELECT id, username FROM users ORDER BY username')
        console.log('Fetched users:', users.rows)
        res.status(200).json({ users: users.rows })
    } catch (error) {
        console.error('Error fetching users:', error)
        res.status(500).json({ error: 'Internal server error' })
    }
})

