# 📚 API & Class Documentation

Dokumentasi lengkap untuk semua class, method, dan function dalam aplikasi.

---

## 📦 Models

### Reservation Class

**File:** `lib/models/reservation.dart`

**Deskripsi:** Model utama untuk data reservasi

```dart
class Reservation {
  final String id;              // UUID unik
  final String restaurantName;  // Nama restoran
  final String guestName;       // Nama tamu
  final String guestEmail;      // Email tamu
  final String guestPhone;      // Nomor telepon
  final DateTime reservationDate;    // Tanggal reservasi
  final TimeOfDay reservationTime;   // Waktu reservasi
  final int numberOfGuests;     // Jumlah tamu (1-20)
  final String specialRequests; // Catatan khusus
  final ReservationStatus status;    // Status reservasi
  final DateTime createdAt;     // Waktu pembuatan
}
```

**Methods:**

| Method | Parameter | Return | Deskripsi |
|--------|-----------|--------|-----------|
| `toMap()` | - | `Map<String, dynamic>` | Konversi ke JSON map |
| `fromMap()` | `Map<String, dynamic>` | `Reservation` | Konversi dari JSON map |
| `copyWith()` | Optional fields | `Reservation` | Buat copy dengan update fields |

**Constructor:**

```dart
Reservation({
  String? id,                              // Auto-generated jika null
  required String restaurantName,
  required String guestName,
  required String guestEmail,
  required String guestPhone,
  required DateTime reservationDate,
  required TimeOfDay reservationTime,
  required int numberOfGuests,
  String specialRequests = '',             // Optional
  ReservationStatus status = pending,      // Default pending
  DateTime? createdAt,                     // Auto-generated jika null
})
```

---

### ReservationStatus Enum

**File:** `lib/models/reservation.dart`

```dart
enum ReservationStatus {
  pending,      // Tertunda
  confirmed,    // Terkonfirmasi
  completed,    // Selesai
  cancelled,    // Dibatalkan
}
```

**Extensions:**

```dart
extension ReservationStatusExtension on ReservationStatus {
  String get displayName;  // Nama dalam Bahasa Indonesia
  Color get color;         // Warna untuk UI
}
```

---

### Restaurant Class

**File:** `lib/models/restaurant.dart`

**Deskripsi:** Model untuk data restoran (untuk future features)

```dart
class Restaurant {
  final String id;
  final String name;
  final String cuisine;
  final String address;
  final String phone;
  final double rating;
  final int reviews;
  final String imageUrl;
  final String description;
  final List<String> amenities;
  final int capacity;
  final String openTime;
  final String closeTime;
}
```

---

## 🔌 Providers

### ReservationProvider Class

**File:** `lib/providers/reservation_provider.dart`

**Extends:** `ChangeNotifier`

**Deskripsi:** State management untuk reservasi menggunakan Provider pattern

**Properties:**

```dart
List<Reservation> reservations  // Getter untuk list reservasi
bool isInitialized              // Getter untuk status inisialisasi
```

**Methods:**

| Method | Parameters | Return | Deskripsi |
|--------|-----------|--------|-----------|
| `init()` | - | `Future<void>` | Inisialisasi & load data |
| `addReservation()` | `Reservation` | `Future<void>` | Tambah reservasi baru |
| `updateReservation()` | `Reservation` | `Future<void>` | Update reservasi |
| `deleteReservation()` | `String id` | `Future<void>` | Hapus reservasi |
| `getReservationById()` | `String id` | `Reservation?` | Cari by ID |
| `getReservationsByStatus()` | `ReservationStatus` | `List<Reservation>` | Filter by status |
| `getReservationsByRestaurant()` | `String name` | `List<Reservation>` | Filter by restoran |
| `getUpcomingReservations()` | - | `List<Reservation>` | Ambil yang belum berlalu |
| `getReservationsByDate()` | `DateTime` | `List<Reservation>` | Filter by tanggal |

---

## 🎨 Screens

### HomeScreen

**File:** `lib/screens/home_screen.dart`

**Type:** `StatefulWidget`

**Deskripsi:** Dashboard utama dengan 3 tab

**Features:**
- Tab 1: Upcoming reservations
- Tab 2: All reservations
- Tab 3: Statistics

**Key Widgets:**
- AppBar dengan title
- BottomNavigationBar (3 items)
- FloatingActionButton
- ListView dengan ReservationCard

---

### NewReservationScreen

**File:** `lib/screens/new_reservation_screen.dart`

**Type:** `StatefulWidget`

**Deskripsi:** Form untuk create/edit reservasi

**Parameters:**

```dart
const NewReservationScreen({
  Key? key,
  Reservation? reservationToEdit,  // Optional, untuk edit mode
})
```

**Form Fields:**
- restaurantName (TextFormField)
- guestName (TextFormField)
- guestEmail (TextFormField)
- guestPhone (TextFormField)
- reservationDate (DatePicker)
- reservationTime (TimePicker)
- numberOfGuests (Counter)
- specialRequests (TextFormField)

**Validation:**
- Email format check
- Phone number validation
- Required field validation
- Date future validation

---

### ReservationDetailScreen

**File:** `lib/screens/reservation_detail_screen.dart`

**Type:** `StatelessWidget`

**Deskripsi:** Detail view dengan aksi untuk edit/hapus/status

**Parameters:**

```dart
const ReservationDetailScreen({
  Key? key,
  required Reservation reservation,
})
```

**Features:**
- Header dengan status badge
- Info sections dengan icons
- "Ubah Status" button
- "Hapus Reservasi" button
- Popup menu untuk edit

---

### CalendarViewScreen

**File:** `lib/screens/calendar_view_screen.dart`

**Type:** `StatefulWidget`

**Deskripsi:** Calendar view untuk melihat reservasi per hari

**Features:**
- Calendar grid (7x7 untuk bulan)
- Highlight tanggal dengan reservasi
- Select tanggal untuk lihat detail
- List reservasi di bawah calendar

---

## 🧩 Widgets

### ReservationCard

**File:** `lib/widgets/reservation_card.dart`

**Type:** `StatelessWidget`

**Parameters:**

```dart
const ReservationCard({
  Key? key,
  required Reservation reservation,
})
```

**Layout:**
```
┌─ Header (Restoran + Status) ─┐
│ Nama Restoran    [Status]    │
│ Nama Tamu                    │
├─────────────────────────────┤
│ 📅 Tanggal & Waktu          │
│ 👥 Jumlah Tamu              │
└─────────────────────────────┘
```

---

## 🛠️ Utilities

### DateTimeUtils

**File:** `lib/utils/helpers.dart`

**Static Methods:**

| Method | Parameters | Return | Deskripsi |
|--------|-----------|--------|-----------|
| `formatDate()` | `DateTime` | `String` | Format ke "EEEE, dd MMMM yyyy" |
| `formatDateShort()` | `DateTime` | `String` | Format ke "dd MMM yyyy" |
| `formatTime24Hour()` | `TimeOfDay` | `String` | Format ke "HH:mm" |
| `formatDateTime()` | `DateTime, TimeOfDay` | `String` | Combine format |
| `isDatePassed()` | `DateTime` | `bool` | Check if tanggal sudah lewat |
| `getDaysFromNow()` | `DateTime` | `int` | Hitung selisih hari |
| `formatTimeUntil()` | `DateTime` | `String` | Format "Dalam X hari" |

### ValidationUtils

**File:** `lib/utils/helpers.dart`

**Static Methods:**

| Method | Parameters | Return | Deskripsi |
|--------|-----------|--------|-----------|
| `isValidEmail()` | `String` | `bool` | Validasi format email |
| `isValidPhoneNumber()` | `String` | `bool` | Validasi nomor telepon ID |
| `isValidName()` | `String` | `bool` | Validasi nama (min 3 char) |
| `isNotEmpty()` | `String` | `bool` | Check tidak kosong |
| `isValidGuestCount()` | `int` | `bool` | Check 1-20 tamu |

### StringUtils

**File:** `lib/utils/helpers.dart`

**Static Methods:**

| Method | Parameters | Return | Deskripsi |
|--------|-----------|--------|-----------|
| `capitalize()` | `String` | `String` | Capitalize kata pertama |
| `capitalizeEachWord()` | `String` | `String` | Capitalize setiap kata |
| `truncate()` | `String, maxLength` | `String` | Potong dengan ellipsis |
| `formatNumber()` | `int` | `String` | Format dengan separator ribuan |

### PhoneUtils

**File:** `lib/utils/helpers.dart`

**Static Methods:**

| Method | Parameters | Return | Deskripsi |
|--------|-----------|--------|-----------|
| `formatPhoneNumber()` | `String` | `String` | Format ke +62 format |
| `toLocalFormat()` | `String` | `String` | Format ke 0 format |

---

## 🎨 Constants

### AppColors

**File:** `lib/constants/app_constants.dart`

```dart
class AppColors {
  static const Color primary = Color(0xFF673AB7);
  static const Color primaryLight = Color(0xFF9575CD);
  static const Color primaryDark = Color(0xFF512DA8);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA500);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  // ... more colors
}
```

### AppTextStyles

**File:** `lib/constants/app_constants.dart`

```dart
class AppTextStyles {
  static const TextStyle headingLarge;
  static const TextStyle headingMedium;
  static const TextStyle bodyLarge;
  static const TextStyle bodyMedium;
  static const TextStyle bodySmall;
}
```

### AppSpacing

**File:** `lib/constants/app_constants.dart`

```dart
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}
```

---

## 📝 Extension Methods

### TimeOfDay Extension

**File:** `lib/models/reservation.dart`

```dart
extension TimeOfDayExtension on TimeOfDay {
  String to24hourFormat() // Returns "HH:mm" format
}
```

---

## 📊 Data Flow Diagram

```
┌──────────────────────────────┐
│     User Interaction         │
└──────────────┬───────────────┘
               ↓
┌──────────────────────────────┐
│    Screen/Widget Event       │
└──────────────┬───────────────┘
               ↓
┌──────────────────────────────┐
│   Provider Method Call       │
│  (e.g., addReservation())    │
└──────────────┬───────────────┘
               ↓
┌──────────────────────────────┐
│   Model Creation/Update      │
│   Validation & Processing    │
└──────────────┬───────────────┘
               ↓
┌──────────────────────────────┐
│   SharedPreferences Save     │
│   JSON Serialization         │
└──────────────┬───────────────┘
               ↓
┌──────────────────────────────┐
│   notifyListeners()          │
└──────────────┬───────────────┘
               ↓
┌──────────────────────────────┐
│   UI Rebuild (Consumer)      │
│   New State Displayed        │
└──────────────────────────────┘
```

---

## 🔐 Error Handling

### Try-Catch Examples

```dart
// Di Provider
try {
  final reservation = Reservation.fromMap(jsonData);
  _reservations.add(reservation);
  await _saveReservations();
  notifyListeners();
} catch (e) {
  print('Error: $e');
  // Show error to user
}

// Di Screen
try {
  if (!_formKey.currentState!.validate()) return;
  // Process form
} on Exception catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: $e')),
  );
}
```

---

## 🧪 Testing

### Test File

**File:** `test/reservation_model_test.dart`

**Test Groups:**
1. Reservation Model Tests
2. TimeOfDay Extension Tests

**Sample Test:**

```dart
test('Reservation creation with valid data', () {
  final reservation = Reservation(
    restaurantName: 'Test Restaurant',
    guestName: 'John Doe',
    // ...
  );
  
  expect(reservation.restaurantName, 'Test Restaurant');
  expect(reservation.numberOfGuests, 4);
});
```

---

## 🎯 Best Practices

### Do's ✅
```dart
✅ Gunakan const untuk immutable widgets
✅ Use Provider untuk state management
✅ Validate input sebelum submit
✅ Handle errors dengan gracefully
✅ Use named parameters
✅ Write meaningful comments
✅ Test critical functions
✅ Use consistent naming conventions
```

### Don'ts ❌
```dart
❌ Don't use setState() dengan Provider
❌ Don't hardcode values
❌ Don't skip validation
❌ Don't ignore exceptions
❌ Don't create nested providers
❌ Don't modify state directly
❌ Don't use deprecated widgets
❌ Don't forget to dispose resources
```

---

**Documentation Updated:** December 4, 2024  
**Version:** 1.0.0
