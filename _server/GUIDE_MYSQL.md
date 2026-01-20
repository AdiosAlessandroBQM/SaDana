# Panduan Setup MySQL SADANA

Ikuti langkah-langkah berikut untuk mengaktifkan database MySQL untuk aplikasi SADANA:

## 1. Persiapan Software
Pastikan Anda memiliki salah satu dari software berikut terinstal di komputer Anda:
- **XAMPP** (Sangat disarankan untuk pemula)
- **WampServer**
- **Laragon**
- **MySQL Installer** (Standalone)

## 2. Aktifkan MySQL
1. Buka **XAMPP Control Panel**.
2. Klik tombol **Start** pada baris **MySQL** (dan Apache jika ingin menggunakan phpMyAdmin).
3. Pastikan indikator berubah menjadi warna hijau.

## 3. Import Database
### Menggunakan phpMyAdmin (Visual):
1. Buka browser dan akses `http://localhost/phpmyadmin`.
2. Klik tab **Import** di bagian atas.
3. Klik tombol **Choose File** dan pilih file:
   `c:\Users\Dino F Missingno\.gemini\antigravity\scratch\warung-stock-system\_server\database.sql`
4. Gulir ke bawah dan klik tombol **Go** atau **Import**.
5. Database `sadana_db` akan otomatis terbuat beserta semua tabel dan data contohnya.

### Menggunakan Command Line (Terminal):
1. Buka Command Prompt atau PowerShell.
2. Jalankan perintah:
   ```cmd
   mysql -u root -p -e "source c:\Users\Dino F Missingno\.gemini\antigravity\scratch\warung-stock-system\_server\database.sql"
   ```
   *(Tekan Enter saat diminta password jika Anda menggunakan pengaturan default XAMPP tanpa password)*

## 4. Konfigurasi Backend
Jika Anda menggunakan password untuk MySQL Anda (secara default kosong di XAMPP), buka file `_server/index.js` dan sesuaikan bagian ini:

```javascript
const db = mysql.createConnection({
    host: 'localhost',
    user: 'root', // Ganti jika berbeda
    password: '', // Masukkan password jika ada
    database: 'sadana_db'
});
```

---
*Database siap digunakan! Sekarang Anda bisa menjalankan server dengan `node index.js` di dalam folder `_server`.*
