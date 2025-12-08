# Fitur Tabel Restoran dan Assignment Otomatis

## Ringkasan
Telah mengimplementasikan sistem manajemen tabel restoran dengan assignment otomatis ke tamu saat melakukan reservasi.

## Fitur Utama

### 1. Model Tabel Restoran (RestaurantTable)
- **File**: `lib/models/restaurant_table.dart`
- **Fitur**:
  - Nomor meja (1, 2, 3, dst)
  - Kapasitas kursi (2, 4, 6, dst)
  - Status meja (tersedia, terisi, direservasi, pemeliharaan)
  - ID reservasi jika sedang direservasi
  - Tracking waktu dibuat dan diupdate

### 2. TableProvider (State Management)
- **File**: `lib/providers/table_provider.dart`
- **Fitur CRUD**:
  - ✅ Tambah meja baru
  - ✅ Edit nomor dan kapasitas meja
  - ✅ Hapus meja
  - ✅ View semua meja

- **Fitur Khusus**:
  - `findAvailableTable(numberOfGuests)` - Cari meja kosong yang cocok untuk jumlah tamu
  - `reserveTable(tableId, reservationId)` - Reserve tabel untuk reservasi
  - `releaseTable(tableId)` - Lepas/kosongkan tabel (saat reservasi dibatalkan)
  - `markTableAsOccupied(tableId)` - Ubah status ke "Terisi"
  - `markTableAsAvailable(tableId)` - Ubah status ke "Tersedia"

- **Default Setup**:
  - Meja 1-5: 2 kursi
  - Meja 6-10: 4 kursi
  - Meja 11-15: 6 kursi
  - Dapat dikustomisasi melalui admin dashboard

### 3. Admin Dashboard - Tab Tabel
- **File**: `lib/screens/admin_dashboard_screen.dart` (class `_TableManagementTab`)
- **Fitur**:
  - 📊 Statistik meja real-time (Total, Tersedia, Terisi)
  - ➕ Tambah meja baru dengan dialog input
  - ✏️ Edit meja (nomor dan kapasitas)
  - 🗑️ Hapus meja
  - 🎨 Visual grid dengan status emoji dan warna
  - Status indicators: ✅ Tersedia, 🔴 Terisi, 🟡 Direservasi, 🔧 Pemeliharaan

### 4. Update Model Reservation
- **File**: `lib/models/reservation.dart`
- **Field Baru**:
  - `tableId` - ID meja yang di-assign untuk reservasi
  - `orderedItems` - List menu items yang dipesan (siap untuk pengembangan)

### 5. Otomatis Assignment Tabel
- **File**: `lib/screens/new_reservation_screen.dart`
- **Cara Kerja**:
  1. Tamu mengisi form reservasi (nama, email, phone, tanggal, jam, jumlah tamu)
  2. Saat klik "Simpan", sistem otomatis mencari tabel kosong yang cocok
  3. Sistem mencari tabel dengan kapasitas >= jumlah tamu, diprioritaskan kapasitas terkecil
  4. Tabel otomatis di-reserve untuk reservasi tersebut
  5. Nomor meja ditampilkan di snackbar sukses: "Reservasi berhasil dibuat - Meja 3"
  6. Jika tidak ada tabel tersedia, tampil pesan: "Tidak ada meja yang tersedia"

### 6. Detail Reservasi - Tampilan Tabel
- **File**: `lib/screens/reservation_detail_screen.dart`
- **Fitur**:
  - Menampilkan nomor meja dan kapasitas yang di-assign
  - Format: "Meja 3 (4 kursi)"
  - Jika tidak ada tabel, tampil: "Tidak tersedia"
  - Saat menghapus reservasi, tabel otomatis di-lepas kembali

## Alur Workflow

### Untuk Admin
1. Buka Admin Dashboard
2. Klik tab "Meja"
3. Lihat statistik meja real-time
4. Tambah, edit, atau hapus meja sesuai kebutuhan
5. Setiap perubahan otomatis tersimpan

### Untuk Tamu
1. Tamu membuat reservasi baru
2. Isi informasi tamu, tanggal, jam, dan **jumlah tamu** (PENTING)
3. Klik "Simpan"
4. Sistem otomatis mencari dan assign tabel
5. Tamu melihat nomor meja yang di-assign
6. Saat check-in, tamu pergi ke meja yang telah di-assign

## Fitur Lanjutan (Opsional untuk Pengembangan)

- Integrasi dengan menu ordering (field `orderedItems` sudah ada)
- Tracking status "Hadir"/"Belum Hadir" saat tamu datang
- Auto-release tabel setelah waktu reservasi berlalu
- Laporan occupancy rate per jam
- Push notification saat tamu tiba
- QR code untuk meja

## Testing

Struktur sudah siap untuk testing:
- ✅ Model validation
- ✅ Provider logic (cari tabel, reserve, release)
- ✅ UI components dengan Consumer
- ✅ Error handling (tidak ada tabel tersedia)

## Catatan Teknis

- Menggunakan SharedPreferences untuk persistent storage
- TableProvider terintegrasi di MultiProvider (main.dart)
- Automatic table creation dengan default setup saat app pertama kali dijalankan
- Error handling untuk invalid inputs
- Sorted by table number untuk better UX
