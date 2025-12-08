# Changelog

Semua perubahan penting pada proyek ini akan didokumentasikan dalam file ini.

Format berdasarkan [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
dan project ini mengikuti [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-12-04

### Added
- ✨ Fitur membuat reservasi baru dengan form lengkap
- ✨ Fitur melihat detail reservasi
- ✨ Fitur mengedit reservasi yang sudah ada
- ✨ Fitur menghapus reservasi
- ✨ Sistem status reservasi (Tertunda, Terkonfirmasi, Selesai, Dibatalkan)
- ✨ Dashboard dengan 3 tab:
  - Tab Mendatang: Menampilkan reservasi yang belum berlalu
  - Tab Semua: Menampilkan semua riwayat reservasi
  - Tab Statistik: Menampilkan overview dalam bentuk kartu statistik
- ✨ Penyimpanan data lokal dengan SharedPreferences
- ✨ Calendar view untuk melihat reservasi per hari
- ✨ Input validation untuk semua field
- ✨ Localization Indonesia (id_ID)
- ✨ Dark/Light theme support
- ✨ Material Design 3 UI

### Components
- Reservation Model dengan serialization (toMap/fromMap)
- ReservationProvider untuk state management
- HomeScreen dengan 3 tabs
- NewReservationScreen untuk create/edit
- ReservationDetailScreen untuk melihat detail
- CalendarViewScreen untuk calendar view
- ReservationCard widget untuk display list

### Utilities
- DateTimeUtils untuk format tanggal/waktu
- ValidationUtils untuk validasi input
- StringUtils untuk manipulasi string
- PhoneUtils untuk format nomor telepon
- AppConstants untuk theme colors & spacing

### Documentation
- README.md dengan informasi lengkap
- GUIDE.md dengan panduan pengguna & developer
- CHANGELOG.md ini

## [Upcoming] - TBD

### Planned Features
- [ ] Cloud sync dengan Firebase Firestore
- [ ] Push notification untuk reminder
- [ ] Search & filter reservasi
- [ ] Export reservasi ke PDF
- [ ] Email confirmation ke tamu
- [ ] Multi-language support (English, Mandarin, dll)
- [ ] Dark theme yang lebih optimal
- [ ] Widget customization
- [ ] Analytics & reporting
- [ ] Rating sistem untuk restoran

### Improvements
- [ ] Improve calendar UI
- [ ] Add offline mode handling
- [ ] Better error messages
- [ ] Loading states improvement
- [ ] Accessibility enhancements

---

## Catatan Developer

### Versi Flutter
- Flutter: 3.9.2
- Dart: 3.0.0 atau lebih tinggi

### Dependencies Version
- provider: ^6.0.0
- intl: ^0.19.0
- shared_preferences: ^2.2.0
- uuid: ^4.0.0
- table_calendar: ^3.0.0
- cupertino_icons: ^1.0.8

### Testing Status
- ✅ Unit tests tersedia di `test/reservation_model_test.dart`
- ⏳ Widget tests (coming soon)
- ⏳ Integration tests (coming soon)

### Known Issues
- Tidak ada issue yang diketahui pada versi 1.0.0
