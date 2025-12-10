-- ============================================
-- TABEL ADMIN NOTIFICATIONS
-- ============================================

-- Buat tabel untuk notifikasi admin
CREATE TABLE IF NOT EXISTS admin_notifications (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type INT DEFAULT 0,
  "reservationId" TEXT,
  "createdAt" TEXT DEFAULT NOW()::text,
  "isRead" BOOLEAN DEFAULT false
);

-- Index untuk performa
CREATE INDEX IF NOT EXISTS idx_notifications_created ON admin_notifications("createdAt" DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_read ON admin_notifications("isRead");

-- Enable realtime untuk notifikasi
ALTER PUBLICATION supabase_realtime ADD TABLE admin_notifications;

-- ============================================
-- FUNGSI UNTUK REMINDER OTOMATIS (H-3 JAM)
-- ============================================

-- Fungsi untuk mengecek dan membuat reminder
CREATE OR REPLACE FUNCTION check_and_create_reminders()
RETURNS void AS $$
DECLARE
  reservation_record RECORD;
  reminder_time TIMESTAMP;
  notification_exists BOOLEAN;
BEGIN
  -- Loop semua reservasi yang akan datang dalam 3 jam
  FOR reservation_record IN 
    SELECT * FROM reservations 
    WHERE status = 1  -- confirmed
    AND "reservationDate"::date = CURRENT_DATE
  LOOP
    -- Parse waktu reservasi
    reminder_time := (reservation_record."reservationDate"::date || ' ' || reservation_record."reservationTime")::timestamp;
    
    -- Cek apakah dalam rentang 3 jam dari sekarang
    IF reminder_time > NOW() AND reminder_time <= NOW() + INTERVAL '3 hours' THEN
      -- Cek apakah reminder sudah ada
      SELECT EXISTS(
        SELECT 1 FROM admin_notifications 
        WHERE "reservationId" = reservation_record.id 
        AND type = 2  -- reminder type
        AND "createdAt"::date = CURRENT_DATE
      ) INTO notification_exists;
      
      -- Buat notifikasi reminder jika belum ada
      IF NOT notification_exists THEN
        INSERT INTO admin_notifications (id, title, message, type, "reservationId", "createdAt", "isRead")
        VALUES (
          gen_random_uuid()::text,
          '⏰ Reminder Reservasi',
          reservation_record."guestName" || ' akan datang dalam 3 jam! Jam ' || reservation_record."reservationTime",
          2,  -- reminder type
          reservation_record.id,
          NOW()::text,
          false
        );
      END IF;
    END IF;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- TRIGGER UNTUK NOTIFIKASI RESERVASI BARU
-- ============================================

-- Fungsi trigger untuk reservasi baru
CREATE OR REPLACE FUNCTION notify_new_reservation()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO admin_notifications (id, title, message, type, "reservationId", "createdAt", "isRead")
  VALUES (
    gen_random_uuid()::text,
    '🔔 Reservasi Baru!',
    NEW."guestName" || ' - ' || NEW."numberOfGuests" || ' orang' || E'\n' || 'Jam ' || NEW."reservationTime",
    0,  -- new reservation type
    NEW.id,
    NOW()::text,
    false
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Buat trigger
DROP TRIGGER IF EXISTS on_new_reservation ON reservations;
CREATE TRIGGER on_new_reservation
  AFTER INSERT ON reservations
  FOR EACH ROW
  EXECUTE FUNCTION notify_new_reservation();

-- ============================================
-- SCHEDULED JOB UNTUK REMINDER (pg_cron)
-- ============================================

-- Aktifkan pg_cron extension (jalankan sebagai superuser)
-- CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Jadwalkan pengecekan reminder setiap 15 menit
-- SELECT cron.schedule('check-reminders', '*/15 * * * *', 'SELECT check_and_create_reminders()');

-- CATATAN: pg_cron mungkin tidak tersedia di semua plan Supabase
-- Alternatif: Gunakan Supabase Edge Function dengan cron

-- ============================================
-- MANUAL: Jalankan fungsi reminder secara manual
-- ============================================
-- SELECT check_and_create_reminders();
