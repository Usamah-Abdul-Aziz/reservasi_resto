# 📋 Panduan Lengkap Aplikasi Reservasi Restoran

## Daftar Isi
1. [Instalasi & Setup](#instalasi--setup)
2. [Fitur Aplikasi](#fitur-aplikasi)
3. [Panduan Pengguna](#panduan-pengguna)
4. [Struktur Kode](#struktur-kode)
5. [Troubleshooting](#troubleshooting)
6. [Tips & Trik](#tips--trik)

---

## Instalasi & Setup

### Persyaratan Sistem
- **Flutter SDK**: >= 3.9.2
- **Dart SDK**: >= 3.0.0
- **Android Studio** atau **Xcode** (untuk emulator)
- **Minimal 2GB RAM**

### Langkah-Langkah Instalasi

#### 1. Setup Flutter
```bash
# Download dan install Flutter dari: https://flutter.dev

# Verifikasi instalasi
flutter --version
dart --version
```

#### 2. Clone/Buka Project
```bash
cd reservasi_resto
```

#### 3. Install Dependencies
```bash
flutter pub get
```

#### 4. Jalankan Aplikasi
```bash
# Di emulator default
flutter run

# Di device spesifik
flutter run -d <device-id>

# List available devices
flutter devices
```

#### 5. Mode Release (Optional)
```bash
flutter run --release
```

---

## Fitur Aplikasi

### 1. **Home Screen (3 Tab)**

#### Tab 1: Reservasi Mendatang
- Menampilkan hanya reservasi yang belum lewat
- Otomatis terurut berdasarkan tanggal
- Tampilan kartu dengan info ringkas
- Tap untuk melihat detail lengkap

#### Tab 2: Semua Reservasi
- Menampilkan seluruh riwayat reservasi
- Termasuk reservasi yang sudah selesai/dibatalkan
- Pencarian manual (tap kartu untuk detail)
- Akses cepat ke edit/hapus

#### Tab 3: Statistik
- **Total Reservasi**: Jumlah seluruh pemesanan
- **Tertunda**: Belum dikonfirmasi
- **Terkonfirmasi**: Sudah dikonfirmasi
- **Selesai**: Reservasi yang sudah terlaksana
- **Dibatalkan**: Reservasi yang dibatalkan
- **Total Tamu**: Jumlah orang dari semua reservasi

### 2. **Buat Reservasi Baru**
```
Informasi yang diperlukan:
├─ Nama Restoran
├─ Nama Tamu
├─ Email Tamu
├─ Nomor Telepon
├─ Tanggal Reservasi
├─ Jam Reservasi
├─ Jumlah Tamu (1-20)
└─ Catatan Khusus (Opsional)
```

### 3. **Detail Reservasi**
- Tampilan lengkap semua informasi
- Status reservasi dengan warna berbeda
- Timeline pembuatan reservasi
- Tombol ubah status dan hapus
- Menu edit (via popup)

### 4. **Status Management**
Status dapat diubah melalui:
1. Buka detail reservasi
2. Tap "Ubah Status"
3. Pilih status baru

Status tersedia:
- 🟠 **Tertunda** (Orange) - Default untuk reservasi baru
- 🟢 **Terkonfirmasi** (Green) - Reservasi dikonfirmasi
- 🔵 **Selesai** (Blue) - Sudah terlaksana
- 🔴 **Dibatalkan** (Red) - Pembatalan pemesanan

---

## Panduan Pengguna

### Workflow Umum

#### A. Membuat Reservasi
```
1. Tap "Reservasi Baru" (FAB di kanan bawah)
   ↓
2. Isi form dengan data lengkap
   - Gunakan icon untuk navigasi antar field
   - Tap field tanggal/waktu untuk date/time picker
   - Gunakan +/- untuk jumlah tamu
   ↓
3. Validasi otomatis (jangan kosong)
   ↓
4. Tap "Buat Reservasi"
   ↓
5. Notifikasi sukses muncul
```

#### B. Melihat Detail Reservasi
```
1. Di Home Screen, tap salah satu kartu reservasi
   ↓
2. Lihat detail lengkap:
   - Header dengan nama restoran & status
   - Informasi tamu (nama, email, telepon)
   - Detail reservasi (tanggal, waktu, jumlah tamu)
   - Catatan khusus (jika ada)
   - Waktu pembuatan
   ↓
3. Aksi yang bisa dilakukan:
   - Ubah Status (tombol besar)
   - Hapus Reservasi (tombol outline)
   - Edit (menu 3 dots)
```

#### C. Mengubah Reservasi
```
1. Buka detail reservasi
2. Tap menu 3 dots (⋮) → Edit
   ↓
3. Form muncul dengan data terisi
   ↓
4. Edit data yang ingin diubah
   ↓
5. Tap "Perbarui Reservasi"
```

#### D. Menghapus Reservasi
```
Metode 1: Via Detail Screen
├─ Buka detail → Tap "Hapus Reservasi"
└─ Konfirmasi penghapusan

Metode 2: Via Detail Screen Menu
├─ Buka detail → Menu 3 dots → Hapus
└─ Konfirmasi penghapusan
```

#### E. Ubah Status Reservasi
```
1. Buka detail reservasi
2. Tap "Ubah Status"
3. Dialog muncul dengan 4 pilihan:
   - Tertunda
   - Terkonfirmasi
   - Selesai
   - Dibatalkan
4. Tap pilihan status
5. Notifikasi sukses muncul
```

### Tips Penggunaan

#### 💡 Input Validasi
- **Email**: Harus mengandung @
- **Nomor Telepon**: Format Indonesia (0xxxxxxxxx atau +62x)
- **Nama Tamu**: Minimal 3 karakter
- **Tanggal**: Tidak bisa tanggal lampau

#### 📱 Tips Interface
- **Swipe**di beberapa area untuk navigasi (bergantung device)
- **Long Press** di kartu untuk aksi cepat (jika diimplementasi)
- **Scroll** di form untuk melihat semua field
- **Tab navigation** di bawah untuk ganti halaman

#### 📅 Date/Time Picker
- **Kalender**: Swipe atau tap tanda panah
- **Waktu**: Gunakan spinner atau drag
- **Validasi**: Sistem auto-validasi tanggal

---

## Struktur Kode

### Direktori & File

```
lib/
├── main.dart
│   ├─ Entry point aplikasi
│   ├─ Setup provider
│   └─ Konfigurasi tema
│
├── screens/
│   ├── home_screen.dart
│   │   ├─ Menampilkan 3 tab
│   │   ├─ Reservasi mendatang
│   │   ├─ Semua reservasi
│   │   └─ Statistik
│   │
│   ├── new_reservation_screen.dart
│   │   ├─ Form create/edit
│   │   ├─ Validasi input
│   │   └─ Submit data
│   │
│   ├── reservation_detail_screen.dart
│   │   ├─ Tampil detail
│   │   ├─ Ubah status
│   │   ├─ Hapus
│   │   └─ Edit
│   │
│   └── calendar_view_screen.dart
│       ├─ Kalender bulanan
│       ├─ Tampil per hari
│       └─ Navigasi bulan
│
├── models/
│   ├── reservation.dart
│   │   ├─ Class Reservation
│   │   ├─ Enum ReservationStatus
│   │   └─ Serialization
│   │
│   └── restaurant.dart
│       └─ Class Restaurant (untuk future)
│
├── providers/
│   └── reservation_provider.dart
│       ├─ State management
│       ├─ CRUD operations
│       ├─ SharedPreferences
│       └─ Filtering & sorting
│
├── widgets/
│   └── reservation_card.dart
│       ├─ Reusable card widget
│       ├─ Info ringkas
│       └─ Status badge
│
├── utils/
│   ├── helpers.dart
│   │   ├─ DateTimeUtils
│   │   ├─ ValidationUtils
│   │   ├─ StringUtils
│   │   └─ PhoneUtils
│   │
│   └── sample_data.dart
│       └─ Generate dummy data
│
└── constants/
    └── app_constants.dart
        ├─ AppColors
        ├─ AppTextStyles
        ├─ AppSpacing
        └─ AppRadius
```

### Class Diagram

```
┌─────────────────────────────┐
│     Reservation Model       │
├─────────────────────────────┤
│ - id (UUID)                 │
│ - restaurantName            │
│ - guestName                 │
│ - guestEmail                │
│ - guestPhone                │
│ - reservationDate           │
│ - reservationTime           │
│ - numberOfGuests            │
│ - specialRequests           │
│ - status (enum)             │
│ - createdAt                 │
├─────────────────────────────┤
│ + toMap()                   │
│ + fromMap()                 │
│ + copyWith()                │
└─────────────────────────────┘

┌─────────────────────────────┐
│  ReservationProvider        │
├─────────────────────────────┤
│ - _reservations: List       │
│ - _prefs: SharedPreferences │
├─────────────────────────────┤
│ + addReservation()          │
│ + updateReservation()       │
│ + deleteReservation()       │
│ + getReservationById()      │
│ + getUpcomingReservations() │
│ + getReservationsByDate()   │
└─────────────────────────────┘
```

---

## Troubleshooting

### Error Umum & Solusi

#### 1. "Failed to resolve: provider"
```bash
# Solusi:
flutter pub get
flutter clean
flutter pub get
flutter run
```

#### 2. "No device found"
```bash
# Cek device tersedia:
flutter devices

# Jika tidak ada, buat emulator:
# - Android Studio > AVD Manager
# - Atau gunakan physical device (debug enabled)
```

#### 3. "Gradle build failed"
```bash
# Clean project:
cd android
./gradlew clean
cd ..

# Rebuild:
flutter clean
flutter pub get
flutter run
```

#### 4. "SharedPreferences error"
```bash
# Kemungkinan permission issue:
# - Android: Check AndroidManifest.xml
# - iOS: Check Info.plist
# - Reinstall app di emulator
```

#### 5. "Hot reload tidak bekerja"
```bash
# Gunakan hot restart:
# - Ketik 'R' di terminal
# Atau gunakan cold restart:
flutter run
```

### Debug Tips

#### Logging
```dart
// Tambahkan di kode untuk debug
print('Debug: $variableName');

// Atau gunakan untuk provider
if (kDebugMode) {
  print('Provider state: $reservations');
}
```

#### Inspector
```bash
# Buka Flutter Inspector
flutter pub global activate devtools
devtools
```

---

## Tips & Trik

### 🚀 Optimization Tips

#### 1. Performance
- Menggunakan `const` untuk widget yang tidak berubah
- Meminimalkan rebuild dengan provider yang tepat
- Lazy load untuk list besar

#### 2. Code Quality
```dart
// ✅ BAIK
const SizedBox(height: 16)

// ❌ KURANG BAIK
SizedBox(height: 16)
```

### 🎨 Customization

#### Mengubah Tema Warna
File: `lib/main.dart`
```dart
colorScheme: ColorScheme.fromSeed(
  seedColor: Colors.deepPurple, // Ubah ini
),
```

#### Mengubah Font
File: `pubspec.yaml`
```yaml
flutter:
  fonts:
    - family: CustomFont
      fonts:
        - asset: assets/fonts/CustomFont-Regular.ttf
```

### 📦 Expand Fitur

#### Tambah Fitur Backup Cloud
1. Tambah firebase_core
2. Implement Firestore sync
3. Add authentication

#### Tambah Notifikasi
1. Tambah flutter_local_notifications
2. Schedule reminder sebelum reservasi
3. Push notification dari server

#### Tambah Search
```dart
// Di HomeScreen
TextFormField(
  onChanged: (value) {
    setState(() => searchQuery = value);
  },
)

// Filter list berdasarkan query
filteredList = reservations
  .where((r) => r.restaurantName.contains(searchQuery))
  .toList()
```

### 🔐 Security Best Practices

1. **Validasi Input**: Selalu validasi sebelum submit
2. **Secure Storage**: Gunakan flutter_secure_storage untuk data sensitif
3. **Error Handling**: Handle semua exception dengan graceful

### 📊 Testing

#### Unit Test Contoh
```dart
void main() {
  group('Reservation Model', () {
    test('copyWith updates fields correctly', () {
      final reservation = Reservation(
        // ...
      );
      final updated = reservation.copyWith(
        numberOfGuests: 5,
      );
      expect(updated.numberOfGuests, 5);
    });
  });
}
```

---

## Kontak & Support

Untuk pertanyaan atau issue:
1. Buka GitHub issue
2. Attach screenshot atau log
3. Jelaskan langkah reproduksi

---

**Happy Reserving! 🍽️**
