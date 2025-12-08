# Backend Integration Summary

## Arsitektur Backend

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter App                              │
│         (Reservation Form, Detail Screen, etc)              │
└──────────────────────┬──────────────────────────────────────┘
                       │
         ┌─────────────┴─────────────┐
         │                           │
    ┌────▼──────────┐         ┌─────▼──────────┐
    │ Email Service │         │ Database      │
    │  (send email) │         │ Service       │
    └────┬──────────┘         └─────┬──────────┘
         │                           │
         │   ┌───────────────────────┘
         │   │
    ┌────▼───▼──────────────────┐
    │   Supabase                │
    ├───────────────────────────┤
    │ • Database (PostgreSQL)   │
    │ • Edge Functions          │
    │ • Authentication          │
    │ • Real-time Updates       │
    └─────────┬──────────────────┘
              │
    ┌─────────┴─────────┐
    │                   │
┌───▼────────┐   ┌──────▼──────┐
│ Resend API │   │ Email Queue │
└────────────┘   └──────────────┘
```

## Workflow: Membuat Reservasi

1. **User Input** → Fill form di New Reservation Screen
2. **Generate Code** → Verification code auto-generated
3. **Save to DB** → `NewReservationScreen` → `ReservationProvider.addReservation()`
4. **Trigger Email** → `SupabaseReservationProvider.addReservation()` calls `EmailService.sendVerificationEmail()`
5. **Email Function** → Supabase Function `send_verification_email` execute
6. **Resend API** → Kirim email via Resend.com
7. **User Gets Email** → Email berisi kode verifikasi

## Workflow: Verifikasi Reservasi

1. **User Opens App** → Lihat list reservasi di Home Screen
2. **User Taps Reservation** → Navigasi ke `ReservationDetailScreen` dengan `isAdminView: false`
3. **Show Verification** → `_buildVerificationScreen()` tampil
4. **Enter Code** → User input kode dari email
5. **Validate Code** → Cek `widget.reservation.verificationCode` dengan input
6. **Show Details** → `setState(() { _isVerified = true; })` → Show `_buildDetailScreen()`

## Workflow: Admin Manages Reservations

1. **Admin Opens App** → Select Role → Admin Dashboard
2. **View Reservations** → Tab "Reservasi" → See today's reservations
3. **Mark Arrived** → Click "Tandai Datang" button
4. **Update Status** → Click "Update Status" → Select new status
5. **View Details** → Click "Detail" button → See full details (no verification needed)
6. **Send Notification** → Status change triggers email to guest

## File Structure

```
lib/
├── config/
│   └── supabase_config.dart          # Supabase initialization
├── services/
│   ├── email_service.dart            # Email sending logic
│   └── reservation_database_service.dart  # Database operations
├── providers/
│   ├── reservation_provider.dart      # Local state (deprecated, keep for local backup)
│   └── supabase_reservation_provider.dart  # Cloud state with Supabase
├── models/
│   └── reservation.dart              # Data model
└── screens/
    ├── new_reservation_screen.dart    # Form entry
    ├── home_screen.dart               # User view
    ├── reservation_detail_screen.dart # Detail view with verification
    └── admin_dashboard_screen.dart    # Admin view
```

## Key Changes

### 1. Supabase Setup
- Initialize in `main()` before running app
- Credentials in `lib/config/supabase_config.dart`

### 2. Email Service
- Abstraction layer for sending emails
- Uses Supabase Edge Functions
- Resend.com for actual email delivery

### 3. Database Service
- CRUD operations for reservations
- Real-time listeners available
- Error handling and logging

### 4. Provider Updates
- New `SupabaseReservationProvider` with cloud sync
- Keeps old `ReservationProvider` for local fallback
- Both can be used simultaneously

### 5. Email Flow
1. User creates reservation
2. App calls `SupabaseReservationProvider.addReservation()`
3. Provider saves to DB via `ReservationDatabaseService`
4. Provider calls `EmailService.sendVerificationEmail()`
5. Email service invokes Supabase Function
6. Function sends email via Resend API
7. User receives email with verification code

## Benefits

✅ **Automatic Email Sending** - No manual copy-paste of codes
✅ **Secure Verification** - Codes sent via verified email
✅ **Admin Notifications** - Status changes notify guests
✅ **Cloud Backup** - All data in Supabase PostgreSQL
✅ **Real-time Sync** - Multiple devices stay in sync
✅ **Scalable** - Can handle many reservations
✅ **Professional** - Branded emails from custom domain

## Next Steps

1. Setup Supabase account
2. Create database tables
3. Setup Resend for email
4. Create Edge Functions
5. Update credentials in app
6. Test email flow
7. Deploy to production

See `SUPABASE_SETUP.md` for detailed setup instructions.
