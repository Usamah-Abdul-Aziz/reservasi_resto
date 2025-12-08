# 🚀 QUICK START GUIDE

## Installation & Run dalam 5 Menit

```bash
# 1. Navigate ke project
cd reservasi_resto

# 2. Get dependencies
flutter pub get

# 3. Run aplikasi
flutter run

# Done! ✅
```

---

## 🎯 Fitur Utama Dalam Sekejap

### Dashboard (Home Screen)
- 📅 **Tab 1**: Reservasi Mendatang
- 📋 **Tab 2**: Semua Reservasi  
- 📊 **Tab 3**: Statistik

### Aksi Cepat
```
✅ Buat Reservasi  → Tap FAB (Floating Action Button)
✅ Lihat Detail    → Tap kartu reservasi
✅ Edit Reservasi  → Detail → Menu ⋮ → Edit
✅ Hapus Reservasi → Detail → Tombol Hapus
✅ Ubah Status     → Detail → Tombol "Ubah Status"
```

---

## 📝 Form Reservasi (Field Wajib)

```
[✓] Nama Restoran      (Wajib)
[✓] Nama Tamu          (Wajib)
[✓] Email              (Wajib - harus valid)
[✓] Nomor Telepon      (Wajib)
[✓] Tanggal            (Wajib - minimal hari ini)
[✓] Waktu              (Wajib)
[✓] Jumlah Tamu        (Wajib - 1-20)
[ ] Catatan Khusus     (Opsional)
```

---

## 🎨 UI Navigation

```
┌─────────────────────────────────┐
│      App Bar (Dark Purple)      │
│        "Reservasi Restoran"     │
└─────────────────────────────────┘
│                                 │
│   ┌───────────────────────────┐ │
│   │ [Reservasi Card 1]        │ │
│   │ [Tap untuk lihat detail]  │ │
│   └───────────────────────────┘ │
│                                 │
│   ┌───────────────────────────┐ │
│   │ [Reservasi Card 2]        │ │
│   └───────────────────────────┘ │
│                                 │
│   [Scroll untuk lihat lebih]    │
│                                 │
├─────────────────────────────────┤
│ [FAB] Reservasi Baru            │
│       (Floating Action Button)   │
└─────────────────────────────────┘
│ 📅 Tab │ 📋 Tab │ 📊 Tab       │
└─────────────────────────────────┘
```

---

## 🔄 Status Workflow

```
Buat Reservasi
        ↓
  Tertunda (🟠)
        ↓
  Terkonfirmasi (🟢)
        ↓
  Selesai (🔵)
        
OR

  Dibatalkan (🔴)
     [Anytime]
```

---

## 📱 Screen Breakdown

### 1. Home Screen
```
Layout:
- AppBar dengan title
- 3 Tab Navigation
- List of Reservation Cards
- FAB untuk buat reservasi
```

### 2. New Reservation Screen
```
Layout:
- AppBar dengan title
- ScrollView dengan form
- Multiple TextFields
- Date/Time Pickers
- Submit Button
```

### 3. Reservation Detail Screen
```
Layout:
- Header dengan status badge
- Info sections dengan icons
- Action buttons
- Popup menu untuk edit/hapus
```

---

## 🔑 Key Functionalities

### Data Operations
```
CREATE  → addReservation()
READ    → getReservations(), getReservationById()
UPDATE  → updateReservation()
DELETE  → deleteReservation()
```

### Filtering & Sorting
```
getUpcomingReservations()  → Hanya belum berlalu
getReservationsByDate()    → Per tanggal
getReservationsByStatus()  → Per status
getReservationsByRestaurant() → Per restoran
```

---

## 💾 Data Storage

```
SharedPreferences (Local)
    ↓
Serialization: toMap() ↔ fromMap()
    ↓
JSON Format
    ↓
Persistent Storage (Non-volatile)
```

---

## 🎯 Architecture

```
Provider Pattern
│
├─ UI Layer (Screens & Widgets)
│  ├─ HomeScreen
│  ├─ NewReservationScreen
│  ├─ ReservationDetailScreen
│  └─ ReservationCard
│
├─ State Layer (Providers)
│  └─ ReservationProvider
│      ├─ _reservations: List
│      ├─ _prefs: SharedPreferences
│      └─ Methods: CRUD + Queries
│
└─ Data Layer (Models)
   ├─ Reservation (Model + Serialization)
   ├─ Restaurant (Model)
   └─ ReservationStatus (Enum)
```

---

## ✨ Special Features

### Date & Time
- 📅 Date Picker (future dates only)
- ⏰ Time Picker (24-hour format)
- 🌍 Localization Indonesia

### Validation
- Email format check
- Phone number validation
- Name validation (min 3 chars)
- Required field checks

### UI/UX
- Material Design 3
- Gradient backgrounds
- Smooth animations
- Responsive layout
- Icon indicators

---

## 🐛 Common Issues & Fix

| Issue | Solution |
|-------|----------|
| App crash on start | `flutter clean && flutter pub get` |
| Data not saving | Check SharedPreferences permission |
| UI looks weird | Check device orientation |
| Slow performance | Restart emulator/device |

---

## 📊 Project Stats

```
Total Files     : 16+
Total Code      : ~2500 lines
Main Features   : 5 major
Screens         : 4 screens
Widgets         : 1 custom (ReservationCard)
Models          : 2 models
Providers       : 1 provider
Utils           : 3 utility files
Tests           : Unit tests included
```

---

## 🚀 Next Steps

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Run App**
   ```bash
   flutter run
   ```

3. **Test Features**
   - Create reservation
   - View details
   - Edit/delete
   - Check statistics

4. **Explore**
   - Try all 3 tabs
   - Check calendar view
   - Test validations
   - Review data persistence

---

## 📞 Need Help?

1. Read GUIDE.md untuk panduan lengkap
2. Check SUMMARY.md untuk overview
3. Review code dalam lib/screens untuk logika
4. Run tests: `flutter test`

---

## ✅ Checklist Before Production

- [ ] Run `flutter test`
- [ ] Run `flutter analyze`
- [ ] Test on real device
- [ ] Check all validations
- [ ] Verify data persistence
- [ ] Test all status transitions
- [ ] Check UI on different screens
- [ ] Test performance
- [ ] Review error messages
- [ ] Add analytics (optional)

---

**Happy Coding! 🎉 Aplikasi sudah siap digunakan!**

*Last Updated: December 4, 2024*
