-- ============================================
-- JALANKAN SQL INI DI SUPABASE SQL EDITOR
-- ============================================

-- 1. Buat tabel admin_notifications
CREATE TABLE IF NOT EXISTS admin_notifications (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type INT DEFAULT 0,
  "reservationId" TEXT,
  "createdAt" TEXT DEFAULT NOW()::text,
  "isRead" BOOLEAN DEFAULT false
);

-- 2. Buat index untuk performa
CREATE INDEX IF NOT EXISTS idx_notifications_created ON admin_notifications("createdAt" DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_read ON admin_notifications("isRead");

-- 3. Enable realtime untuk notifikasi (agar notifikasi muncul real-time di app)
ALTER PUBLICATION supabase_realtime ADD TABLE admin_notifications;

-- 4. Buat trigger untuk notifikasi reservasi baru
CREATE OR REPLACE FUNCTION notify_new_reservation()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO admin_notifications (id, title, message, type, "reservationId", "createdAt", "isRead")
  VALUES (
    gen_random_uuid()::text,
    '🔔 Reservasi Baru!',
    NEW."guestName" || ' - ' || NEW."numberOfGuests" || ' orang' || E'\n' || 'Jam ' || NEW."reservationTime",
    0,
    NEW.id,
    NOW()::text,
    false
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 5. Buat trigger pada tabel reservations
DROP TRIGGER IF EXISTS on_new_reservation ON reservations;
CREATE TRIGGER on_new_reservation
  AFTER INSERT ON reservations
  FOR EACH ROW
  EXECUTE FUNCTION notify_new_reservation();

-- ============================================
-- SETUP CRON JOB UNTUK REMINDER OTOMATIS
-- ============================================

-- Aktifkan pg_cron extension
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Buat fungsi untuk memanggil Edge Function reminder
CREATE OR REPLACE FUNCTION call_reminder_function()
RETURNS void AS $$
BEGIN
  -- Panggil Edge Function via pg_net (jika tersedia)
  -- Atau gunakan metode lain untuk trigger
  PERFORM net.http_post(
    url := 'https://nudcvwuihchgwejrfayn.supabase.co/functions/v1/check_reminders',
    headers := '{"Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im51ZGN2d3VpaGNoZ3dlanJmYXluIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUxNzQ4MzYsImV4cCI6MjA4MDc1MDgzNn0.9vl9UOCjmowdFY-jMDVeb3sFiYxiD6XjCeJcqMSK1Z0", "Content-Type": "application/json"}'::jsonb,
    body := '{}'::jsonb
  );
END;
$$ LANGUAGE plpgsql;

-- Jadwalkan cron job setiap 15 menit
SELECT cron.schedule(
  'check-reservation-reminders',
  '*/15 * * * *',  -- Setiap 15 menit
  $$SELECT call_reminder_function()$$
);

-- Untuk melihat cron jobs yang terjadwal:
-- SELECT * FROM cron.job;

-- Untuk menghapus cron job:
-- SELECT cron.unschedule('check-reservation-reminders');
