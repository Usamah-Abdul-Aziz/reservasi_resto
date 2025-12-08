# 🚀 Integrasi Supabase - Panduan Lengkap

## Mengapa Supabase?

Sebelumnya, app Anda hanya menyimpan data lokal (SharedPreferences). Dengan Supabase:

✅ Data tersimpan di cloud (aman & backup otomatis)
✅ Email terkirim otomatis ke guest saat reservasi
✅ Admin bisa akses dari mana saja
✅ Skalabel untuk ribuan reservasi
✅ Real-time sync antar devices

## Step 1: Buat Akun Supabase

1. Buka https://supabase.com
2. Klik "Sign Up"
3. Login dengan Google/GitHub
4. Klik "New Project"
5. Isi form:
   - **Name**: `reservasi_resto` (atau nama pilihan Anda)
   - **Database Password**: Isi dengan password yang aman
   - **Region**: Pilih yang terdekat (Asia-Southeast 1 untuk Indonesia)
6. Tunggu project selesai (2-5 menit)

## Step 2: Dapatkan Credentials

1. Di Supabase dashboard, klik menu ☰ → Settings
2. Pilih tab "API"
3. Copy bagian ini:
   - **Project URL** (contoh: `https://xxx.supabase.co`)
   - **anon public** key (contoh: `eyJhbGc...`)

## Step 3: Update Credentials di App

Buka file: `lib/config/supabase_config.dart`

```dart
static const String supabaseUrl = 'PASTE_YOUR_PROJECT_URL_HERE';
static const String supabaseKey = 'PASTE_YOUR_ANON_KEY_HERE';
```

Ganti dengan credentials yang sudah dicopy.

## Step 4: Setup Database Tabel

1. Di Supabase, pilih "SQL Editor"
2. Klik "+ New Query"
3. Copy-paste query ini:

```sql
-- Tabel untuk Reservasi
CREATE TABLE IF NOT EXISTS reservations (
  id TEXT PRIMARY KEY,
  guestName TEXT NOT NULL,
  guestEmail TEXT NOT NULL,
  guestPhone TEXT NOT NULL,
  reservationDate DATE NOT NULL,
  reservationTime TEXT NOT NULL,
  numberOfGuests INTEGER NOT NULL,
  specialRequests TEXT DEFAULT '',
  status INTEGER DEFAULT 0,
  hasArrived BOOLEAN DEFAULT false,
  tableId TEXT,
  orderedItems JSONB,
  verificationCode TEXT UNIQUE NOT NULL,
  rating DOUBLE PRECISION,
  createdAt TIMESTAMP DEFAULT NOW(),
  updatedAt TIMESTAMP DEFAULT NOW()
);

-- Index untuk performa
CREATE INDEX idx_reservations_date ON reservations(reservationDate);
CREATE INDEX idx_reservations_email ON reservations(guestEmail);
CREATE INDEX idx_reservations_code ON reservations(verificationCode);
```

4. Klik "Run"
5. Tunggu selesai

## Step 5: Setup Email Service

### Opsi A: Menggunakan Resend (REKOMENDASI)

#### 5a. Buat Akun Resend

1. Buka https://resend.com
2. Daftar dengan email
3. Verify email
4. Copy API Key Anda

#### 5b. Setup Supabase Edge Function

Di terminal lokal, jalankan:

```bash
# Install Supabase CLI (jika belum)
npm install -g supabase

# Login ke Supabase
supabase login
```

Buat function baru:

```bash
supabase functions new send_verification_email
```

Edit file `supabase/functions/send_verification_email/index.ts`:

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req: Request) => {
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

    const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY")
    if (!RESEND_API_KEY) {
      throw new Error("RESEND_API_KEY not configured")
    }

    const emailHtml = `
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; border-radius: 8px 8px 0 0; text-align: center; }
          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px; }
          .code-box { background: white; border: 2px solid #667eea; border-radius: 8px; padding: 20px; margin: 20px 0; text-align: center; }
          .code { font-size: 36px; font-weight: bold; color: #667eea; letter-spacing: 8px; font-family: monospace; }
          .details { background: white; padding: 15px; border-radius: 5px; margin: 15px 0; }
          .footer { color: #999; font-size: 12px; margin-top: 20px; text-align: center; border-top: 1px solid #ddd; padding-top: 10px; }
          h1 { margin: 0; }
          p { margin: 10px 0; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>✓ Reservasi Diterima!</h1>
          </div>
          <div class="content">
            <p>Halo <strong>${guestName}</strong>,</p>
            <p>Terima kasih telah melakukan reservasi di restoran kami. Berikut adalah detail reservasi Anda:</p>
            
            <div class="details">
              <p><strong>📅 Tanggal:</strong> ${reservationDate}</p>
              <p><strong>⏰ Jam:</strong> ${reservationTime}</p>
            </div>
            
            <p>Untuk melihat detail lengkap reservasi Anda, gunakan kode verifikasi ini:</p>
            
            <div class="code-box">
              <div class="code">${verificationCode}</div>
              <p style="color: #999; font-size: 12px; margin-top: 10px;">Kode 6 digit</p>
            </div>
            
            <p style="color: #666; font-size: 14px;">
              📱 Buka aplikasi kami → Lihat reservasi Anda → Klik tombol "Kode" → Masukkan kode di atas
            </p>
            
            <p style="color: #999; font-size: 12px;">
              ⚠️ Jangan bagikan kode ini kepada orang lain
            </p>
            
            <div class="footer">
              <p>Jika Anda tidak melakukan reservasi ini, abaikan email ini.</p>
              <p>&copy; 2025 Reservasi Resto. All rights reserved.</p>
            </div>
          </div>
        </div>
      </body>
      </html>
    `

    const response = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        Authorization: \`Bearer \${RESEND_API_KEY}\`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        from: "noreply@reservasi-resto.com", // Ganti dengan domain Anda
        to: guestEmail,
        subject: "Kode Verifikasi Reservasi Anda",
        html: emailHtml,
      }),
    })

    const data = await response.json()

    if (!response.ok) {
      throw new Error(\`Resend error: \${data.message}\`)
    }

    return new Response(JSON.stringify({ success: true, id: data.id }), {
      headers: { "Content-Type": "application/json" },
      status: 200,
    })
  } catch (error) {
    console.error("Error:", error)
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { "Content-Type": "application/json" },
      status: 400,
    })
  }
})
```

Deploy function:

```bash
supabase functions deploy send_verification_email
```

#### 5c. Set Secret di Supabase

```bash
supabase secrets set RESEND_API_KEY "your_resend_api_key_here"
```

### Opsi B: Menggunakan Gmail (Alternatif Sederhana)

Jika tidak ingin setup edge function, bisa gunakan Gmail SMTP:

1. Buka `lib/services/email_service.dart`
2. Implementasi menggunakan package `mailer`
3. Ini lebih sederhana tapi email kirim dari client-side (tidak ideal untuk production)

## Step 6: Test Email

1. Buka app Flutter
2. Update app (rebuild)
3. Buat reservasi baru
4. Cek email yang Anda daftarkan
5. Harus ada email berisi kode verifikasi

## Step 7: Verifikasi Reservasi

1. Lihat list reservasi di home screen
2. Tap salah satu reservasi
3. Masukkan kode dari email
4. Jika kode benar, bisa lihat detail

## Troubleshooting

### Email tidak terkirim

1. **Cek Supabase Logs**:
   - Supabase → Functions → send_verification_email
   - Lihat bagian "Logs"
   - Cari error message

2. **Cek Resend Status**:
   - https://resend.com/emails
   - Lihat history email yang dikirim

3. **Cek Credentials**:
   - RESEND_API_KEY valid?
   - Supabase URL dan Key benar?

### Database Error

1. Buka Supabase → Table Editor
2. Pastikan tabel `reservations` sudah ada
3. Pastikan field sesuai dengan schema

### Function Not Found

```bash
# List deployed functions
supabase functions list

# Deploy ulang
supabase functions deploy send_verification_email
```

## Next: Tambahkan Email untuk Admin

Buat juga function untuk notifikasi admin:

```bash
supabase functions new send_admin_notification
```

Implementasi mirip dengan verification email, tapi:
- To: admin email
- Subject: "Reservasi Baru dari [Guest Name]"
- Content: Detail reservasi

## Setup Domain Email (Optional)

Untuk email lebih profesional:

1. Verifikasi domain di Resend
2. Setup DNS records
3. Update `from` di email function

Contoh: `noreply@reservasi-resto.com` instead of `noreply@resend.com`

## Kesimpulan

Setelah setup selesai:
✅ Reservasi disimpan di cloud
✅ Email otomatis terkirim ke guest
✅ Admin bisa akses dari mana saja
✅ Data aman dan backup otomatis

Pertanyaan? Cek dokumentasi Supabase di https://supabase.com/docs
