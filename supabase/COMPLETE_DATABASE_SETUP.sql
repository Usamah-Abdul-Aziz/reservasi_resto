-- =====================================================
-- COMPLETE DATABASE SETUP FOR RESERVASI RESTO APP
-- Run this SQL in Supabase SQL Editor
-- =====================================================

-- =====================================================
-- 1. RESERVATIONS TABLE (Update jika sudah ada)
-- =====================================================
DROP TABLE IF EXISTS table_reservations CASCADE;
DROP TABLE IF EXISTS admin_notifications CASCADE;
DROP TABLE IF EXISTS menu_availability CASCADE;
DROP TABLE IF EXISTS reservations CASCADE;
DROP TABLE IF EXISTS menu_items CASCADE;
DROP TABLE IF EXISTS restaurant_tables CASCADE;
DROP TABLE IF EXISTS restaurant_settings CASCADE;

CREATE TABLE reservations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "guestName" TEXT NOT NULL,
    "guestEmail" TEXT NOT NULL,
    "guestPhone" TEXT NOT NULL,
    "reservationDate" DATE NOT NULL,
    "reservationTime" TEXT NOT NULL,
    "numberOfGuests" INTEGER NOT NULL DEFAULT 1,
    "specialRequests" TEXT DEFAULT '',
    status INTEGER DEFAULT 0,
    "hasArrived" BOOLEAN DEFAULT FALSE,
    "tableId" TEXT,
    "orderedItems" JSONB DEFAULT '[]'::jsonb,
    "verificationCode" TEXT NOT NULL,
    rating DECIMAL(2,1),
    "createdAt" TIMESTAMPTZ DEFAULT NOW(),
    "updatedAt" TIMESTAMPTZ DEFAULT NOW()
);

-- Index untuk pencarian cepat
CREATE INDEX IF NOT EXISTS idx_reservations_date ON reservations("reservationDate");
CREATE INDEX IF NOT EXISTS idx_reservations_status ON reservations(status);
CREATE INDEX IF NOT EXISTS idx_reservations_verification ON reservations("verificationCode");

-- Enable RLS (Row Level Security)
ALTER TABLE reservations ENABLE ROW LEVEL SECURITY;

-- Policy untuk akses publik (untuk demo, sesuaikan untuk production)
DROP POLICY IF EXISTS "Allow all access to reservations" ON reservations;
CREATE POLICY "Allow all access to reservations" ON reservations
    FOR ALL USING (true) WITH CHECK (true);

-- =====================================================
-- 2. MENU ITEMS TABLE
-- =====================================================
CREATE TABLE menu_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT DEFAULT '',
    price DECIMAL(12,2) NOT NULL,
    category TEXT NOT NULL,
    "imageUrl" TEXT,
    "isAvailable" BOOLEAN DEFAULT TRUE,
    "isSoldOut" BOOLEAN DEFAULT FALSE,
    "preparationTime" INTEGER DEFAULT 15,
    "isSpicy" BOOLEAN DEFAULT FALSE,
    "isVegetarian" BOOLEAN DEFAULT FALSE,
    "isRecommended" BOOLEAN DEFAULT FALSE,
    "createdAt" TIMESTAMPTZ DEFAULT NOW(),
    "updatedAt" TIMESTAMPTZ DEFAULT NOW()
);

-- Index untuk pencarian menu
CREATE INDEX IF NOT EXISTS idx_menu_items_category ON menu_items(category);
CREATE INDEX IF NOT EXISTS idx_menu_items_available ON menu_items("isAvailable");

-- Enable RLS
ALTER TABLE menu_items ENABLE ROW LEVEL SECURITY;

-- Policy untuk akses publik
DROP POLICY IF EXISTS "Allow all access to menu_items" ON menu_items;
CREATE POLICY "Allow all access to menu_items" ON menu_items
    FOR ALL USING (true) WITH CHECK (true);

-- =====================================================
-- 3. MENU AVAILABILITY TABLE (per hari)
-- =====================================================
CREATE TABLE menu_availability (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "menuItemId" UUID REFERENCES menu_items(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    "isAvailable" BOOLEAN DEFAULT TRUE,
    "isSoldOut" BOOLEAN DEFAULT FALSE,
    "quantityAvailable" INTEGER DEFAULT -1,
    "createdAt" TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE("menuItemId", date)
);

-- Index
CREATE INDEX IF NOT EXISTS idx_menu_availability_date ON menu_availability(date);

-- Enable RLS
ALTER TABLE menu_availability ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow all access to menu_availability" ON menu_availability;
CREATE POLICY "Allow all access to menu_availability" ON menu_availability
    FOR ALL USING (true) WITH CHECK (true);

-- =====================================================
-- 4. RESTAURANT TABLES TABLE
-- =====================================================
CREATE TABLE restaurant_tables (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "tableNumber" TEXT NOT NULL UNIQUE,
    capacity INTEGER NOT NULL DEFAULT 4,
    location TEXT DEFAULT 'indoor',
    status TEXT DEFAULT 'available',
    description TEXT DEFAULT '',
    "isActive" BOOLEAN DEFAULT TRUE,
    "createdAt" TIMESTAMPTZ DEFAULT NOW(),
    "updatedAt" TIMESTAMPTZ DEFAULT NOW()
);

-- Index
CREATE INDEX IF NOT EXISTS idx_tables_status ON restaurant_tables(status);
CREATE INDEX IF NOT EXISTS idx_tables_capacity ON restaurant_tables(capacity);

-- Enable RLS
ALTER TABLE restaurant_tables ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow all access to restaurant_tables" ON restaurant_tables;
CREATE POLICY "Allow all access to restaurant_tables" ON restaurant_tables
    FOR ALL USING (true) WITH CHECK (true);

-- =====================================================
-- 5. TABLE RESERVATIONS (Relasi meja-reservasi)
-- =====================================================
CREATE TABLE table_reservations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "tableId" UUID REFERENCES restaurant_tables(id) ON DELETE CASCADE,
    "reservationId" UUID REFERENCES reservations(id) ON DELETE CASCADE,
    "startTime" TIMESTAMPTZ NOT NULL,
    "endTime" TIMESTAMPTZ NOT NULL,
    "createdAt" TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE("tableId", "reservationId")
);

-- Index
CREATE INDEX IF NOT EXISTS idx_table_reservations_time ON table_reservations("startTime", "endTime");

-- Enable RLS
ALTER TABLE table_reservations ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow all access to table_reservations" ON table_reservations;
CREATE POLICY "Allow all access to table_reservations" ON table_reservations
    FOR ALL USING (true) WITH CHECK (true);

-- =====================================================
-- 6. ADMIN NOTIFICATIONS TABLE
-- =====================================================
CREATE TABLE admin_notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type TEXT NOT NULL,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    "reservationId" UUID REFERENCES reservations(id) ON DELETE SET NULL,
    "isRead" BOOLEAN DEFAULT FALSE,
    "createdAt" TIMESTAMPTZ DEFAULT NOW()
);

-- Index
CREATE INDEX IF NOT EXISTS idx_notifications_read ON admin_notifications("isRead");
CREATE INDEX IF NOT EXISTS idx_notifications_created ON admin_notifications("createdAt" DESC);

-- Enable RLS
ALTER TABLE admin_notifications ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow all access to admin_notifications" ON admin_notifications;
CREATE POLICY "Allow all access to admin_notifications" ON admin_notifications
    FOR ALL USING (true) WITH CHECK (true);

-- =====================================================
-- 7. RESTAURANT SETTINGS TABLE
-- =====================================================
CREATE TABLE restaurant_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    key TEXT NOT NULL UNIQUE,
    value JSONB NOT NULL,
    description TEXT,
    "updatedAt" TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE restaurant_settings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow all access to restaurant_settings" ON restaurant_settings;
CREATE POLICY "Allow all access to restaurant_settings" ON restaurant_settings
    FOR ALL USING (true) WITH CHECK (true);

-- =====================================================
-- 8. ENABLE REALTIME FOR ALL TABLES
-- =====================================================
ALTER PUBLICATION supabase_realtime ADD TABLE reservations;
ALTER PUBLICATION supabase_realtime ADD TABLE menu_items;
ALTER PUBLICATION supabase_realtime ADD TABLE menu_availability;
ALTER PUBLICATION supabase_realtime ADD TABLE restaurant_tables;
ALTER PUBLICATION supabase_realtime ADD TABLE admin_notifications;

-- =====================================================
-- 9. TRIGGER: Auto-create notification on new reservation
-- =====================================================
CREATE OR REPLACE FUNCTION notify_new_reservation()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO admin_notifications (type, title, message, "reservationId")
    VALUES (
        'new_reservation',
        'Reservasi Baru!',
        'Reservasi baru dari ' || NEW."guestName" || ' untuk ' || NEW."numberOfGuests" || ' orang pada ' || NEW."reservationDate" || ' ' || NEW."reservationTime",
        NEW.id
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS on_new_reservation ON reservations;
CREATE TRIGGER on_new_reservation
    AFTER INSERT ON reservations
    FOR EACH ROW
    EXECUTE FUNCTION notify_new_reservation();

-- =====================================================
-- 10. TRIGGER: Update timestamp on update
-- =====================================================
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW."updatedAt" = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_reservations_timestamp ON reservations;
CREATE TRIGGER update_reservations_timestamp
    BEFORE UPDATE ON reservations
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS update_menu_items_timestamp ON menu_items;
CREATE TRIGGER update_menu_items_timestamp
    BEFORE UPDATE ON menu_items
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS update_tables_timestamp ON restaurant_tables;
CREATE TRIGGER update_tables_timestamp
    BEFORE UPDATE ON restaurant_tables
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

-- =====================================================
-- 11. INSERT SAMPLE DATA - MENU ITEMS
-- =====================================================
INSERT INTO menu_items (name, description, price, category, "isAvailable", "isRecommended", "isSpicy", "isVegetarian", "preparationTime")
VALUES 
    -- Appetizers
    ('Lumpia Goreng', 'Lumpia isi sayuran dengan saus manis pedas', 25000, 'appetizer', true, true, false, true, 10),
    ('Sate Ayam', 'Sate ayam dengan bumbu kacang khas', 35000, 'appetizer', true, true, false, false, 15),
    ('Tahu Crispy', 'Tahu goreng crispy dengan sambal kecap', 20000, 'appetizer', true, false, true, true, 10),
    ('Sup Jagung', 'Sup jagung manis hangat', 22000, 'appetizer', true, false, false, true, 12),
    
    -- Main Course
    ('Nasi Goreng Spesial', 'Nasi goreng dengan telur, ayam, dan sayuran', 45000, 'main_course', true, true, true, false, 15),
    ('Ayam Bakar Madu', 'Ayam bakar dengan bumbu madu special', 55000, 'main_course', true, true, false, false, 25),
    ('Rendang Sapi', 'Rendang sapi empuk dengan bumbu rempah', 65000, 'main_course', true, true, true, false, 30),
    ('Ikan Bakar Sambal Matah', 'Ikan bakar dengan sambal matah Bali', 60000, 'main_course', true, false, true, false, 25),
    ('Mie Goreng Seafood', 'Mie goreng dengan udang, cumi, dan sayuran', 50000, 'main_course', true, false, false, false, 15),
    ('Gado-Gado', 'Salad sayur Indonesia dengan bumbu kacang', 35000, 'main_course', true, false, false, true, 15),
    ('Nasi Campur Bali', 'Nasi dengan berbagai lauk khas Bali', 55000, 'main_course', true, true, true, false, 20),
    
    -- Beverages
    ('Es Teh Manis', 'Teh manis dingin segar', 10000, 'beverage', true, false, false, true, 3),
    ('Es Jeruk', 'Jeruk peras segar dengan es', 15000, 'beverage', true, false, false, true, 3),
    ('Jus Alpukat', 'Jus alpukat creamy', 20000, 'beverage', true, true, false, true, 5),
    ('Es Kelapa Muda', 'Kelapa muda segar dengan es', 18000, 'beverage', true, false, false, true, 3),
    ('Kopi Susu', 'Kopi dengan susu creamy', 22000, 'beverage', true, true, false, true, 5),
    ('Teh Tarik', 'Teh tarik ala Malaysia', 18000, 'beverage', true, false, false, true, 5),
    
    -- Desserts
    ('Es Cendol', 'Cendol dengan santan dan gula merah', 18000, 'dessert', true, true, false, true, 5),
    ('Pisang Goreng', 'Pisang goreng crispy dengan madu', 15000, 'dessert', true, false, false, true, 10),
    ('Es Krim Kelapa', 'Es krim rasa kelapa homemade', 20000, 'dessert', true, false, false, true, 3),
    ('Kolak Pisang', 'Kolak pisang hangat dengan santan', 18000, 'dessert', true, false, false, true, 15),
    ('Puding Coklat', 'Puding coklat lembut dengan vla', 15000, 'dessert', true, true, false, true, 5)
ON CONFLICT DO NOTHING;

-- =====================================================
-- 12. INSERT SAMPLE DATA - RESTAURANT TABLES
-- =====================================================
INSERT INTO restaurant_tables ("tableNumber", capacity, location, status, description)
VALUES 
    -- Indoor Tables
    ('A1', 2, 'indoor', 'available', 'Meja romantis untuk 2 orang dekat jendela'),
    ('A2', 2, 'indoor', 'available', 'Meja untuk 2 orang'),
    ('A3', 4, 'indoor', 'available', 'Meja keluarga kecil'),
    ('A4', 4, 'indoor', 'available', 'Meja dekat dapur'),
    ('A5', 6, 'indoor', 'available', 'Meja besar untuk grup'),
    
    -- Outdoor Tables
    ('B1', 2, 'outdoor', 'available', 'Meja outdoor dengan pemandangan taman'),
    ('B2', 4, 'outdoor', 'available', 'Meja outdoor untuk keluarga'),
    ('B3', 4, 'outdoor', 'available', 'Meja outdoor dengan payung'),
    ('B4', 6, 'outdoor', 'available', 'Meja besar outdoor'),
    
    -- VIP Tables
    ('VIP1', 4, 'vip', 'available', 'Ruang VIP dengan privasi'),
    ('VIP2', 6, 'vip', 'available', 'Ruang VIP untuk meeting'),
    ('VIP3', 8, 'vip', 'available', 'Ruang VIP besar untuk acara'),
    
    -- Private Room
    ('P1', 10, 'private', 'available', 'Ruang private untuk acara keluarga'),
    ('P2', 12, 'private', 'available', 'Ruang private untuk pesta')
ON CONFLICT ("tableNumber") DO NOTHING;

-- =====================================================
-- 13. INSERT SAMPLE DATA - RESTAURANT SETTINGS
-- =====================================================
INSERT INTO restaurant_settings (key, value, description)
VALUES 
    ('operating_hours', '{"monday": {"open": "10:00", "close": "22:00"}, "tuesday": {"open": "10:00", "close": "22:00"}, "wednesday": {"open": "10:00", "close": "22:00"}, "thursday": {"open": "10:00", "close": "22:00"}, "friday": {"open": "10:00", "close": "23:00"}, "saturday": {"open": "09:00", "close": "23:00"}, "sunday": {"open": "09:00", "close": "22:00"}}', 'Jam operasional restoran'),
    ('reservation_settings', '{"maxGuests": 20, "minAdvanceHours": 2, "maxAdvanceDays": 30, "defaultDurationMinutes": 120, "allowSameDay": true}', 'Pengaturan reservasi'),
    ('contact_info', '{"phone": "+62 21 1234567", "email": "info@enak-nih.com", "address": "Jl. Kuliner No. 123, Jakarta", "whatsapp": "+62 812 3456 7890"}', 'Informasi kontak restoran'),
    ('notification_settings', '{"emailEnabled": true, "reminderHours": 3, "adminEmail": "admin@enak-nih.com"}', 'Pengaturan notifikasi')
ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value, "updatedAt" = NOW();

-- =====================================================
-- DONE! Database setup complete.
-- =====================================================
