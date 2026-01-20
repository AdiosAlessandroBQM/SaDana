const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const app = express();
app.use(cors());
app.use(express.json());

const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'sadana_db'
});

db.connect(err => {
    if (err) {
        console.error('CRITICAL: Database connection failed!');
        console.error('Make sure XAMPP MySQL is START and "sadana_db" exists.');
        console.error('Error Details:', err.message);
    } else {
        console.log('✅ Connected to MySQL (sadana_db)');
    }
});

// --- API ---

app.post('/api/auth/register', async (req, res) => {
    const { username, password, full_name } = req.body;
    try {
        const hash = await bcrypt.hash(password, 10);
        db.query('INSERT INTO users (username, password, full_name) VALUES (?, ?, ?)', [username, hash, full_name], (err) => {
            if (err) {
                console.error('Register Error:', err.sqlMessage || err.message);
                // Jika error duplicate entry
                if (err.code === 'ER_DUP_ENTRY') {
                    return res.status(400).json({ message: 'Username sudah digunakan' });
                }
                // Jika error tabel tidak ada
                if (err.code === 'ER_NO_SUCH_TABLE') {
                    return res.status(500).json({ message: 'Database belum siap (Tabel users tidak ada)' });
                }
                return res.status(500).json({ message: 'Gagal mendaftar: ' + (err.sqlMessage || 'Server error') });
            }
            res.status(201).json({ message: 'Success' });
        });
    } catch (e) {
        res.status(500).json({ message: 'Server error' });
    }
});

app.post('/api/auth/login', (req, res) => {
    const { username, password } = req.body;
    db.query('SELECT * FROM users WHERE username = ?', [username], async (err, results) => {
        if (err) {
            console.error('Login Query Error:', err.message);
            return res.status(500).json({ message: 'Database error' });
        }
        
        if (results.length === 0) return res.status(401).json({ message: 'Username tidak ditemukan' });
        
        const match = await bcrypt.compare(password, results[0].password);
        if (!match) return res.status(401).json({ message: 'Password salah' });
        
        const token = jwt.sign({ id: results[0].id }, 'secret', { expiresIn: '1d' });
        res.json({ token, user: { id: results[0].id, username: results[0].username, full_name: results[0].full_name } });
    });
});

app.get('/api/products', (req, res) => {
    db.query('SELECT * FROM products', (err, results) => {
        if (err) return res.status(500).json(err);
        res.json(results);
    });
});

app.post('/api/products', (req, res) => {
    const { name, category, price, stock } = req.body;
    db.query('INSERT INTO products (name, category, price, stock) VALUES (?, ?, ?, ?)', [name, category, price, stock], (err, r) => {
        if (err) return res.status(500).json(err);
        res.status(201).json({ message: 'Success', id: r.insertId });
    });
});

app.put('/api/products/:id', (req, res) => {
    const { name, category, price, stock } = req.body;
    db.query('UPDATE products SET name = ?, category = ?, price = ?, stock = ? WHERE id = ?', [name, category, price, stock, req.params.id], (err) => {
        if (err) return res.status(500).json(err);
        res.json({ message: 'Success' });
    });
});

app.delete('/api/products/:id', (req, res) => {
    db.query('DELETE FROM products WHERE id = ?', [req.params.id], (err) => {
        if (err) return res.status(500).json(err);
        res.json({ message: 'Success' });
    });
});

app.post('/api/transactions', (req, res) => {
    const { user_id, total_amount, items } = req.body;
    db.query('INSERT INTO transactions (user_id, total_amount) VALUES (?, ?)', [user_id, total_amount], (err, r) => {
        if (err) return res.status(500).json(err);
        const tid = r.insertId;
        items.forEach(i => {
            db.query('INSERT INTO transaction_items (transaction_id, product_id, quantity, price_at_transaction) VALUES (?, ?, ?, ?)', [tid, i.product_id, i.quantity, i.price_at_transaction]);
            db.query('UPDATE products SET stock = stock - ? WHERE id = ?', [i.quantity, i.product_id]);
        });
        res.status(201).json({ message: 'Success', id: tid });
    });
});

app.get('/api/transactions', (req, res) => {
    db.query('SELECT * FROM transactions ORDER BY transaction_date DESC', (err, results) => {
        if (err) return res.status(500).json(err);
        res.json(results);
    });
});

app.listen(3000, () => console.log('🚀 SADANA API listening on 3000'));
