const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const mysql = require('mysql2/promise');

const app = express();
const PORT = process.env.PORT || 3003;

// Middleware
app.use(cors());
app.use(morgan('combined'));
app.use(express.json());

// MySQL Connection Pool
const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || 'password',
  database: process.env.DB_NAME || 'orders_db',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// Initialize Database
async function initDatabase() {
  try {
    const connection = await pool.getConnection();
    await connection.execute(`
      CREATE TABLE IF NOT EXISTS orders (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        product_id INT NOT NULL,
        quantity INT NOT NULL,
        total_price DECIMAL(10, 2) NOT NULL,
        status VARCHAR(50) DEFAULT 'pending',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    connection.release();
    console.log('Database initialized');
  } catch (error) {
    console.error('Database initialization error:', error);
  }
}

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'UP', service: 'order-service' });
});

// Get all orders
app.get('/orders', async (req, res) => {
  try {
    const connection = await pool.getConnection();
    const [orders] = await connection.execute('SELECT * FROM orders');
    connection.release();
    res.json(orders);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get order by ID
app.get('/orders/:id', async (req, res) => {
  try {
    const connection = await pool.getConnection();
    const [orders] = await connection.execute('SELECT * FROM orders WHERE id = ?', [req.params.id]);
    connection.release();
    
    if (orders.length === 0) {
      return res.status(404).json({ error: 'Order not found' });
    }
    res.json(orders[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Create order
app.post('/orders', async (req, res) => {
  const { user_id, product_id, quantity, total_price } = req.body;
  
  if (!user_id || !product_id || !quantity || !total_price) {
    return res.status(400).json({ error: 'All fields are required' });
  }

  try {
    const connection = await pool.getConnection();
    const [result] = await connection.execute(
      'INSERT INTO orders (user_id, product_id, quantity, total_price, status) VALUES (?, ?, ?, ?, ?)',
      [user_id, product_id, quantity, total_price, 'pending']
    );
    connection.release();
    
    res.status(201).json({ 
      id: result.insertId, 
      user_id, 
      product_id, 
      quantity, 
      total_price, 
      status: 'pending' 
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Update order status
app.put('/orders/:id', async (req, res) => {
  const { status } = req.body;
  
  if (!status) {
    return res.status(400).json({ error: 'Status is required' });
  }

  try {
    const connection = await pool.getConnection();
    await connection.execute(
      'UPDATE orders SET status = ? WHERE id = ?',
      [status, req.params.id]
    );
    connection.release();
    
    res.json({ id: req.params.id, status });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Delete order
app.delete('/orders/:id', async (req, res) => {
  try {
    const connection = await pool.getConnection();
    await connection.execute('DELETE FROM orders WHERE id = ?', [req.params.id]);
    connection.release();
    
    res.json({ message: 'Order deleted' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Start server
initDatabase().then(() => {
  app.listen(PORT, () => {
    console.log(`Order Service running on port ${PORT}`);
    console.log(`Database: ${process.env.DB_NAME || 'orders_db'}`);
  });
});
