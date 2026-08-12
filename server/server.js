const express = require('express');
const pool = require('./database');
const bcrypt = require('bcrypt');
const cors = require('cors')
const http = require('http')
const { Server } = require('socket.io')

const app = express();
// Creating HTTP server
const server = http.createServer(app)

//Socket.io setup
const io = new Server(server, {
    cors: {
        origin: "*", // Allow all origins for now
    // Allows connections from ANY website/domain
    methods: ["GET", "POST"]//Only allow GET and POST requests
    }
})

const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

//Store online users
const onlineUsers = {};

io.on('connection', (socket) => {
    console.log('New client connected');

    //Getting user ID from query
    const userId = socket.handshake.query.userId;
    if (userId) {
        onlineUsers[userId] = socket.id;
        console.log(`User ${userId} connected`);
    }

  // Handle disconnection
  socket.on('disconnect', () => {
    if (userId) {
      delete onlineUsers[userId];
      console.log(`User ${userId} disconnected`);
    }
  });

  socket.on('sendMessage', async(data) => {
    query = `INSERT INTO messages (sender_id, receiver_id, text) VALUES ($1, $2, $3) RETURNING *`;
    const values = [data.senderId, data.receiverId, data.text];
    try {
      const result = await pool.query(query, values);
      console.log('Message saved to database:', result.rows[0]);

      // Emit message to both sender and receiver
      console.log('🚩Emitting message to both sender and receiver');
      io.to(data.senderId.toString()).emit('receiveMessage', result.rows[0]);
      io.to(data.receiverId.toString()).emit('receiveMessage', result.rows[0]);
    } catch (error) {
      console.error('Error saving message to database:', error);
    }
  })
});

app.get('/test', (req,res) => {
    console.log('Test done. Endpoint is working');
    res.send('Test done. Endpoint is working');
});

server.listen(PORT, () => {
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
        console.log('The value of user.id is:', user.rows[0].id)
        if (user.rows.length === 0 ) {
            return res.status(400).json({ error: 'Invalid username' })
        }
        //password comparison
        const validPassword = await bcrypt.compare(password, user.rows[0].password) 
        if (!validPassword) {
            return res.status(400).json({ error: 'Invalid password' })
        }
        const userId = user.rows[0].id;
        console.log(`User ${username} logged in successfully with userId: ${userId}`)
        res.status(200).json({ message: 'Login successful', userId: userId })
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

//--------------FETCH CHAT HISTORY----------------
app.get('/api/chat/:currentUserId/:receiverId', async (req, res) => {
    const { currentUserId, receiverId } = req.params;
    try {
        const chatHistory = await pool.query(`
            SELECT * FROM messages
            WHERE (sender_id = $1 AND receiver_id = $2) OR (sender_id = $2 AND receiver_id = $1)
            ORDER BY sent_at ASC
        `, [currentUserId, receiverId]);
        console.log(`Fetched chat history between user ${currentUserId} and user ${receiverId}`);
        res.status(200).json(chatHistory.rows);
    } catch (error) {
        console.error('Error fetching chat history:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

//-------------SHOW ALL MESSAGES----------------
app.get('/api/messages', async (req, res) => {
    try{
        const chats = await pool.query(`SELECT * FROM messages`)
        res.status(200).json(chats.rows);
    } catch (error) {
        console.error('Error fetching messages:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
})

//------------DELETE ALL MESSAEGS----------------
app.delete('/api/deleteMessages', async (req,res) => {
    try{
        const result = await pool.query('DELETE FROM messages')
        console.log('All messages deleted successfully');
        res.status(200).json({ message: 'All messages deleted successfully', deletedCount: result.rowCount })
    } catch (error) {
        console.error('Error deleting messages:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
})

//---------------DELETE A USER-----------------------
app.delete('/api/deleteUser', async (req,res) => {
    try {
        const {username} = req.body
        const result = await pool.query('DELETE FROM users WHERE username=$1', [username])
        
         // Check if any user was actually deleted
        if (result.rowCount === 0) {
            return res.status(404).json({ 
                error: 'User not found' 
            });
        }
        res.status(200).json({ message: 'Delete successful', deletedUser: username})
    } catch (e) {
        console.error('Error deleting user: ', e)
        res.status(500).json({error: 'Internal server error'})
    }
})

