# 🗄️ Panduan Setup Database Supabase

## Langkah 1: Jalankan SQL Setup

1. Buka **Supabase Dashboard** → Project Anda
2. Pergi ke **SQL Editor**
3. Copy dan paste isi file `supabase/COMPLETE_DATABASE_SETUP.sql`
4. Klik **Run** untuk menjalankan

## Langkah 2: Aktifkan Realtime

Setelah menjalankan SQL, pastikan Realtime aktif:

1. Pergi ke **Database** → **Replication**
2. Aktifkan tabel-tabel berikut untuk realtime:
   - `reservations`
   - `menu_items`
   - `restaurant_tables`
   - `admin_notifications`

## Tabel yang Dibuat

### 1. `reservations` - Data Reservasi
| Kolom | Tipe | Deskripsi |
|-------|------|-----------|
| id | UUID | Primary key |
| guestName | TEXT | Nama tamu |
| guestEmail | TEXT | Email tamu |
| guestPhone | TEXT | No. telepon |
| reservationDate | DATE | Tanggal reservasi |
| reservationTime | TEXT | Jam reservasi (HH:MM) |
| numberOfGuests | INTEGER | Jumlah tamu |
| specialRequests | TEXT | Permintaan khusus |
| status | INTEGER | 0=pending, 1=confirmed, 2=cancelled, 3=completed |
| hasArrived | BOOLEAN | Sudah datang atau belum |
| tableId | TEXT | ID meja |
| orderedItems | JSONB | Menu yang dipesan |
| verificationCode | TEXT | Kode verifikasi 6 digit |
| rating | DECIMAL | Rating 1-5 |
| createdAt | TIMESTAMPTZ | Waktu dibuat |

### 2. `menu_items` - Data Menu
| Kolom | Tipe | Deskripsi |
|-------|------|-----------|
| id | UUID | Primary key |
| name | TEXT | Nama menu |
| description | TEXT | Deskripsi |
| price | DECIMAL | Harga |
| category | TEXT | appetizer, main_course, dessert, beverage, side_dish, sauce |
| imageUrl | TEXT | URL gambar |
| isAvailable | BOOLEAN | Tersedia/tidak |
| preparationTime | INTEGER | Waktu masak (menit) |
| isSpicy | BOOLEAN | Pedas/tidak |
| isVegetarian | BOOLEAN | Vegetarian/tidak |

### 3. `restaurant_tables` - Data Meja
| Kolom | Tipe | Deskripsi |
|-------|------|-----------|
| id | UUID | Primary key |
| tableNumber | TEXT | Nomor meja (A1, B2, VIP1) |
| capacity | INTEGER | Kapasitas kursi |
| location | TEXT | indoor, outdoor, vip, private |
| status | TEXT | available, occupied, reserved, maintenance |
| description | TEXT | Deskripsi meja |
| isActive | BOOLEAN | Aktif/tidak |

### 4. `admin_notifications` - Notifikasi Admin
| Kolom | Tipe | Deskripsi |
|-------|------|-----------|
| id | UUID | Primary key |
| type | TEXT | new_reservation, status_change, reminder |
| title | TEXT | Judul notifikasi |
| message | TEXT | Isi pesan |
| reservationId | UUID | ID reservasi terkait |
| isRead | BOOLEAN | Sudah dibaca/belum |

### 5. `menu_availability` - Ketersediaan Menu Per Hari
| Kolom | Tipe | Deskripsi |
|-------|------|-----------|
| menuItemId | UUID | FK ke menu_items |
| date | DATE | Tanggal |
| isAvailable | BOOLEAN | Tersedia/tidak |
| isSoldOut | BOOLEAN | Habis/tidak |
| quantityAvailable | INTEGER | Stok tersisa |

## Sample Data

SQL sudah termasuk sample data untuk:
- ✅ 22 menu items (appetizer, main course, beverage, dessert)
- ✅ 14 meja restoran (indoor, outdoor, VIP, private)
- ✅ Pengaturan restoran

## Trigger Otomatis

1. **Auto Notification** - Setiap reservasi baru otomatis buat notifikasi admin
2. **Auto Timestamp** - Field `updatedAt` otomatis diupdate

## Troubleshooting

### Data tidak muncul di Flutter?
1. Pastikan RLS Policy sudah aktif (Allow all access)
2. Cek koneksi Supabase di `lib/config/supabase_config.dart`
3. Restart aplikasi Flutter

### Realtime tidak jalan?
1. Aktifkan table di Database → Replication
2. Pastikan Row Level Security (RLS) sudah di-enable

## Selesai! 🎉

Setelah menjalankan SQL, data dari Supabase akan otomatis dimuat saat aplikasi Flutter dijalankan.
