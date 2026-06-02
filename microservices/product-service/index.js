const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const mysql = require('mysql2/promise');

const app = express();
const PORT = process.env.PORT || 3002;

// Middleware
app.use(cors());
app.use(morgan('combined'));
app.use(express.json());

// MySQL Connection Pool
const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || 'password',
  database: process.env.DB_NAME || 'products_db',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// Initialize Database
async function initDatabase() {
  try {
    const connection = await pool.getConnection();
    await connection.execute(`
      CREATE TABLE IF NOT EXISTS products (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        description TEXT,
        price DECIMAL(10, 2) NOT NULL,
        stock INT DEFAULT 0,
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
  res.json({ status: 'UP', service: 'product-service' });
});

// Get all products
app.get('/products', async (req, res) => {
  try {
    const connection = await pool.getConnection();
    const [products] = await connection.execute('SELECT * FROM products');
    connection.release();
    res.json(products);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get product by ID
app.get('/products/:id', async (req, res) => {
  try {
    const connection = await pool.getConnection();
    const [products] = await connection.execute('SELECT * FROM products WHERE id = ?', [req.params.id]);
    connection.release();
    
    if (products.length === 0) {
      return res.status(404).json({ error: 'Product not found' });
    }
    res.json(products[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Create product
app.post('/products', async (req, res) => {
  const { name, description, price, stock } = req.body;
  
  if (!name || !price) {
    return res.status(400).json({ error: 'Name and price are required' });
  }

  try {
    const connection = await pool.getConnection();
    const [result] = await connection.execute(
      'INSERT INTO products (name, description, price, stock) VALUES (?, ?, ?, ?)',
      [name, description || null, price, stock || 0]
    );
    connection.release();
    
    res.status(201).json({ id: result.insertId, name, description, price, stock });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Update product
app.put('/products/:id', async (req, res) => {
  const { name, description, price, stock } = req.body;
  
  try {
    const connection = await pool.getConnection();
    await connection.execute(
      'UPDATE products SET name = ?, description = ?, price = ?, stock = ? WHERE id = ?',
      [name, description, price, stock, req.params.id]
    );
    connection.release();
    
    res.json({ id: req.params.id, name, description, price, stock });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Delete product
app.delete('/products/:id', async (req, res) => {
  try {
    const connection = await pool.getConnection();
    await connection.execute('DELETE FROM products WHERE id = ?', [req.params.id]);
    connection.release();
    
    res.json({ message: 'Product deleted' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Start server
initDatabase().then(() => {
  app.listen(PORT, () => {
    console.log(`Product Service running on port ${PORT}`);
    console.log(`Database: ${process.env.DB_NAME || 'products_db'}`);
  });
});
