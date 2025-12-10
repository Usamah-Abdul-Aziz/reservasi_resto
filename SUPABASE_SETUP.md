# Setup Supabase untuk Reservasi Resto

## 1. Buat Supabase Project

1. Buka https://supabase.com dan login/signup
2. Klik "New project"
3. Isi nama project: `reservasi_resto`
4. Pilih region terdekat
5. Tunggu project selesai dibuat

## 2. Dapatkan Credentials

1. Buka Settings → API
2. Copy `Project URL` dan `anon public key`
3. Update di `lib/config/supabase_config.dart`:
   ```dart
   static const String supabaseUrl = 'YOUR_SUPABASE_URL';
   static const String supabaseKey = 'YOUR_SUPABASE_ANON_KEY';
   ```

## 3. Buat Tabel Database

Buka SQL Editor di Supabase dan jalankan query ini:

```sql
-- Tabel Reservations
CREATE TABLE IF NOT EXISTS reservations (
  id TEXT PRIMARY KEY,
  "guestName" TEXT NOT NULL,
  "guestEmail" TEXT NOT NULL,
  "guestPhone" TEXT NOT NULL,
  "reservationDate" TEXT NOT NULL,
  "reservationTime" TEXT NOT NULL,
  "numberOfGuests" INT NOT NULL,
  "specialRequests" TEXT DEFAULT '',
  status INT DEFAULT 0,
  "hasArrived" BOOLEAN DEFAULT false,
  "tableId" TEXT,
  "orderedItems" JSONB,
  "verificationCode" TEXT NOT NULL,
  rating FLOAT,
  "createdAt" TEXT DEFAULT NOW()::text
);

-- Index untuk pencarian cepat
CREATE INDEX idx_reservations_date ON reservations("reservationDate");
CREATE INDEX idx_reservations_email ON reservations("guestEmail");
CREATE INDEX idx_reservations_status ON reservations(status);
```

**PENTING:** Jika sudah ada tabel sebelumnya, hapus dulu:
```sql
DROP TABLE IF EXISTS reservations;
```
Lalu jalankan CREATE TABLE di atas.

## 4. Setup Email Service dengan Supabase Functions

### 4a. Install Supabase CLI

```bash
npm install -g supabase
```

### 4b. Login ke Supabase

```bash
supabase login
```

### 4c. Buat Edge Function untuk Email

```bash
supabase functions new send_verification_email
```

Edit file `supabase/functions/send_verification_email/index.ts`:

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { Resend } from "https://cdn.jsdelivr.net/npm/resend@0.13.0/+esm"

const resend = new Resend(Deno.env.get("RESEND_API_KEY"))

serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 })
  }

  try {
    const {
      guestEmail,
      guestName,
      verificationCode,
      reservationDate,
      reservationTime,
    } = await req.json()

    const emailHtml = `
      <!DOCTYPE html>
      <html>
        <head>
          <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background-color: #6C3CE3; color: white; padding: 20px; border-radius: 5px; }
            .code { font-size: 32px; font-weight: bold; color: #6C3CE3; letter-spacing: 5px; text-align: center; padding: 20px; background-color: #f5f5f5; border-radius: 5px; margin: 20px 0; }
            .footer { color: #666; font-size: 12px; margin-top: 20px; }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h1>Verifikasi Reservasi Anda</h1>
            </div>
            
            <p>Halo ${guestName},</p>
            <p>Terima kasih atas reservasi Anda! Berikut adalah detail reservasi:</p>
            
            <ul>
              <li><strong>Tanggal:</strong> ${reservationDate}</li>
              <li><strong>Jam:</strong> ${reservationTime}</li>
            </ul>
            
            <p>Gunakan kode verifikasi berikut untuk melihat detail lengkap reservasi Anda:</p>
            
            <div class="code">${verificationCode}</div>
            
            <p>Kode ini hanya berlaku untuk Anda dan jangan dibagikan kepada orang lain.</p>
            
            <div class="footer">
              <p>Jika Anda tidak melakukan reservasi ini, abaikan email ini.</p>
            </div>
          </div>
        </body>
      </html>
    `

    const res = await resend.emails.send({
      from: "noreply@reservasi-resto.com",
      to: guestEmail,
      subject: "Kode Verifikasi Reservasi Anda",
      html: emailHtml,
    })

    return new Response(JSON.stringify(res), {
      headers: { "Content-Type": "application/json" },
      status: 200,
    })
  } catch (error) {
    console.error("Error:", error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { "Content-Type": "application/json" }, status: 400 }
    )
  }
})
```

### 4d. Setup Resend untuk Email

1. Buka https://resend.com dan buat akun
2. **PENTING - Batasan Domain Testing:**
   - Domain `onboarding@resend.dev` hanya bisa mengirim ke email yang SAMA dengan email akun Resend Anda
   - Contoh: Jika akun Resend Anda `john@gmail.com`, email hanya bisa dikirim ke `john@gmail.com`
   - Untuk mengirim ke email lain, Anda HARUS verify domain sendiri

3. Copy API Key dari Resend Dashboard
4. Simpan di Supabase Secrets (gunakan format tanpa spasi):
   ```bash
   supabase secrets set RESEND_API_KEY=re_xxxxxxxxxxxxxxxxxxxxx
   ```
   
   **Atau dengan quotes:**
   ```bash
   supabase secrets set "RESEND_API_KEY=re_xxxxxxxxxxxxxxxxxxxxx"
   ```

### 4e. Deploy Function

```bash
supabase functions deploy send_verification_email
```

## 5. Update Flutter App

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Update credentials di `lib/config/supabase_config.dart`

3. Run app:
   ```bash
   flutter run
   ```

## 6. Buat Edge Functions Lainnya

Buat juga edge functions untuk:
- `send_status_change_email` - Notifikasi status berubah
- `send_admin_notification` - Notifikasi untuk admin

## Testing

1. Buat reservasi di app
2. Cek inbox email untuk kode verifikasi
3. Gunakan kode untuk akses detail reservasi
4. Admin bisa melihat semua reservasi di database

## Troubleshooting

- **Email tidak terkirim**: Cek API key Resend di Supabase Secrets
- **Function error**: Lihat logs di Supabase → Functions
- **Database error**: Cek struktur tabel di Supabase → SQL Editor
