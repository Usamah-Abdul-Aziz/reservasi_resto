# 🍽️ Aplikasi Reservasi Restoran Flutter

Aplikasi mobile profesional untuk mengelola reservasi restoran dengan antarmuka yang user-friendly dan fitur lengkap.

## ✨ Fitur Utama

### 1. **Manajemen Reservasi**
- ✅ Buat reservasi baru dengan detail lengkap
- ✅ Edit reservasi yang sudah ada
- ✅ Hapus reservasi
- ✅ Tampilkan daftar reservasi mendatang
- ✅ Riwayat semua reservasi

### 2. **Status Reservasi**
- 📅 **Tertunda** - Reservasi baru yang belum dikonfirmasi
- ✓ **Terkonfirmasi** - Reservasi yang sudah dikonfirmasi
- ✅ **Selesai** - Reservasi yang telah selesai
- ❌ **Dibatalkan** - Reservasi yang dibatalkan

### 3. **Informasi Lengkap**
- 🏪 Nama restoran
- 👤 Nama tamu
- 📧 Email tamu
- 📱 Nomor telepon
- 📅 Tanggal dan waktu reservasi
- 👥 Jumlah tamu (1-20 orang)
- 📝 Catatan/permintaan khusus

### 4. **Dashboard & Statistik**
- 📊 Total jumlah reservasi
- 📈 Statistik per status
- 👥 Total tamu yang dipesan
- 📅 Tampilan reservasi mendatang

### 5. **Penyimpanan Data**
- 💾 Data disimpan secara lokal menggunakan SharedPreferences
- 🔄 Sinkronisasi otomatis
- 📱 Tidak memerlukan internet untuk operasi lokal

## 🏗️ Struktur Proyek

```
lib/
├── main.dart                          # Entry point aplikasi
├── screens/
│   ├── home_screen.dart              # Halaman utama dengan 3 tab
│   ├── new_reservation_screen.dart   # Form pembuatan/edit reservasi
│   └── reservation_detail_screen.dart # Detail reservasi
├── models/
│   ├── reservation.dart              # Model data reservasi
│   └── restaurant.dart               # Model data restoran
├── providers/
│   └── reservation_provider.dart     # State management dengan Provider
└── widgets/
    └── reservation_card.dart         # Widget kartu reservasi
```

## 📦 Dependensi

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  intl: ^0.19.0                    # Untuk format tanggal lokal (Indonesia)
  provider: ^6.0.0                 # State management
  table_calendar: ^3.0.0           # Calendar widget
  shared_preferences: ^2.2.0       # Local storage
  uuid: ^4.0.0                     # Generate unique ID
```

## 🚀 Cara Menjalankan

### Prerequisites
- Flutter SDK >= 3.9.2
- Android SDK / Xcode (untuk iOS)
- Dart SDK

### Instalasi

1. **Klone atau buka project:**
```bash
cd reservasi_resto
```

2. **Install dependencies:**
```bash
flutter pub get
```

3. **Jalankan aplikasi:**
```bash
flutter run
```

Atau dengan device spesifik:
```bash
flutter run -d <device-id>
```

## 📱 Cara Penggunaan

### Membuat Reservasi Baru
1. Tap tombol **"Reservasi Baru"** di layar utama
2. Isi form dengan informasi:
   - Nama restoran
   - Nama tamu
   - Email
   - Nomor telepon
   - Pilih tanggal dan waktu
   - Tentukan jumlah tamu
   - (Opsional) Tambahkan catatan khusus
3. Tap **"Buat Reservasi"**

### Melihat Detail Reservasi
1. Tap pada kartu reservasi di daftar
2. Lihat semua detail reservasi
3. Gunakan menu untuk edit atau hapus

### Mengubah Status Reservasi
1. Buka detail reservasi
2. Tap tombol **"Ubah Status"**
3. Pilih status baru (Tertunda, Terkonfirmasi, Selesai, Dibatalkan)

### Melihat Statistik
1. Tap tab **"Statistik"** di bottom navigation
2. Lihat ringkasan semua reservasi dalam bentuk kartu statistik

## 🎨 Desain & UI/UX

### Warna Tema
- **Primary Color**: Deep Purple (#673AB7)
- **Secondary Colors**: Orange, Green, Blue, Red (untuk status)

### Fitur UI
- Material Design 3
- Bottom navigation bar untuk navigasi antar tab
- Floating action button untuk aksi cepat
- Card-based layout untuk informasi
- Gradient backgrounds untuk visual menarik
- Icons dari Material Icons
- Responsive design

## 🔧 Teknologi & Architecture

### State Management
- **Provider Pattern** - Untuk mengelola state aplikasi dengan mudah

### Data Storage
- **SharedPreferences** - Penyimpanan data lokal secara persistent
- **JSON Serialization** - Konversi model ke/dari JSON

### Localization
- **Intl Package** - Format tanggal dalam bahasa Indonesia (id_ID)

### Architecture Pattern
- **Model-View-Provider** - Separation of concerns yang jelas
- **Reusable Widgets** - Komponen UI yang dapat digunakan kembali

## ⚡ Fitur Lanjutan

### Date & Time Picker
- Calendar date picker untuk memilih tanggal
- Time picker untuk memilih waktu
- Validasi tanggal (tidak bisa reservasi tanggal lampau)
- Format tanggal lokal Indonesia

### Input Validation
- Validasi semua field yang wajib
- Email validation
- Nomor telepon validation

### Data Management
- Unique ID untuk setiap reservasi (UUID)
- Timestamp untuk waktu pembuatan
- Sorting otomatis untuk reservasi mendatang
- Filter berdasarkan status dan tanggal

## 📄 License

MIT License

## 👨‍💻 Developer

**Usamah Abdul Aziz** (3337230079)

---

**Dibuat dengan ❤️ menggunakan Flutter**

Untuk pertanyaan atau saran, silakan buat issue atau pull request.
