-- JALANKAN INI DI MYSQL WORKBENCH / CMD MYSQL ANDA
-- Perintah ini akan membuat user khusus yang kompatibel dengan Flutter

-- 1. Buat user 'sadana' dengan password 'sadana123' 
-- Menggunakan plugin 'mysql_native_password' agar bisa dibaca oleh Flutter
CREATE USER IF NOT EXISTS 'sadana'@'localhost' IDENTIFIED WITH mysql_native_password BY 'sadana123';

-- 2. Berikan izin akses penuh ke database sadana_db
GRANT ALL PRIVILEGES ON sadana_db.* TO 'sadana'@'localhost';

-- 3. Update perubahan
FLUSH PRIVILEGES;

-- 4. Pastikan database ada (jika belum)
CREATE DATABASE IF NOT EXISTS sadana_db;
