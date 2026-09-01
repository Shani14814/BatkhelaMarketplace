-- ==============================================================================
-- BATKHELA MARKETPLACE - PHASE 7B PRODUCTION DATABASE EXPANSION & SECURITY
-- Migration: 20260901000001_complete_marketplace_schema.sql
-- Description: Complete production schema expansion, RLS hardening, GPS privacy,
--              triggers for auth/orders/audit logs, and Batkhela initial seeds.
-- ==============================================================================

-- 1. UTILITY FUNCTIONS & TIMESTAMP TRIGGER
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. MARKETPLACE CATEGORIES (Global Marketplace Catalog)
CREATE TABLE IF NOT EXISTS public.marketplace_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    urdu_name TEXT,
    slug TEXT UNIQUE NOT NULL,
    description TEXT,
    icon TEXT NOT NULL DEFAULT 'storefront',
    image_url TEXT,
    accent_color TEXT DEFAULT '#0F766E',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    display_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trigger_marketplace_categories_updated_at
    BEFORE UPDATE ON public.marketplace_categories
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- Add marketplace_category_id FK to public.vendors and public.products if not present
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'vendors' AND column_name = 'marketplace_category_id') THEN
        ALTER TABLE public.vendors ADD COLUMN marketplace_category_id UUID REFERENCES public.marketplace_categories(id) ON DELETE SET NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'products' AND column_name = 'marketplace_category_id') THEN
        ALTER TABLE public.products ADD COLUMN marketplace_category_id UUID REFERENCES public.marketplace_categories(id) ON DELETE SET NULL;
    END IF;
END $$;

-- 3. SERVICE CITIES & REGIONAL EXPANSION
CREATE TABLE IF NOT EXISTS public.service_cities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    urdu_name TEXT,
    slug TEXT UNIQUE NOT NULL,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    radius_km DOUBLE PRECISION NOT NULL DEFAULT 15.0,
    is_active BOOLEAN NOT NULL DEFAULT FALSE,
    display_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trigger_service_cities_updated_at
    BEFORE UPDATE ON public.service_cities
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- 4. CUSTOMER SAVED ADDRESSES
CREATE TABLE IF NOT EXISTS public.customer_addresses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    label TEXT NOT NULL DEFAULT 'Home',
    recipient_name TEXT NOT NULL,
    phone TEXT NOT NULL,
    address TEXT NOT NULL,
    landmark TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    is_default BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trigger_customer_addresses_updated_at
    BEFORE UPDATE ON public.customer_addresses
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE INDEX IF NOT EXISTS idx_customer_addresses_customer ON public.customer_addresses(customer_id);

-- 5. RIDER PROFILES (Secure Verification & KYC Information)
CREATE TABLE IF NOT EXISTS public.rider_profiles (
    id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
    cnic_number TEXT UNIQUE NOT NULL,
    cnic_front_url TEXT,
    cnic_back_url TEXT,
    license_number TEXT,
    license_url TEXT,
    vehicle_type TEXT NOT NULL DEFAULT 'motorbike',
    vehicle_registration TEXT NOT NULL,
    approval_status TEXT NOT NULL DEFAULT 'pending' CHECK (approval_status IN ('pending', 'approved', 'rejected', 'suspended')),
    is_available BOOLEAN NOT NULL DEFAULT FALSE,
    rating NUMERIC(3,2) NOT NULL DEFAULT 5.00,
    total_deliveries INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trigger_rider_profiles_updated_at
    BEFORE UPDATE ON public.rider_profiles
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE INDEX IF NOT EXISTS idx_rider_profiles_status ON public.rider_profiles(approval_status, is_available);

-- 6. VENDOR-RIDER CONTRACTS / APPLICATIONS
CREATE TABLE IF NOT EXISTS public.vendor_rider_contracts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_id UUID NOT NULL REFERENCES public.vendors(id) ON DELETE CASCADE,
    rider_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'terminated')),
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT unique_vendor_rider_contract UNIQUE (vendor_id, rider_id)
);

CREATE TRIGGER trigger_vendor_rider_contracts_updated_at
    BEFORE UPDATE ON public.vendor_rider_contracts
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE INDEX IF NOT EXISTS idx_vendor_rider_vendor ON public.vendor_rider_contracts(vendor_id);
CREATE INDEX IF NOT EXISTS idx_vendor_rider_rider ON public.vendor_rider_contracts(rider_id);

-- 7. VENDOR OPERATING HOURS
CREATE TABLE IF NOT EXISTS public.vendor_operating_hours (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_id UUID NOT NULL REFERENCES public.vendors(id) ON DELETE CASCADE,
    day_of_week INT NOT NULL CHECK (day_of_week BETWEEN 0 AND 6), -- 0 = Sunday, 6 = Saturday
    open_time TIME NOT NULL DEFAULT '09:00:00',
    close_time TIME NOT NULL DEFAULT '23:00:00',
    is_closed BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT unique_vendor_day_hours UNIQUE (vendor_id, day_of_week)
);

CREATE INDEX IF NOT EXISTS idx_vendor_hours_vendor ON public.vendor_operating_hours(vendor_id);

-- 8. RIDER EARNINGS & PAYOUTS LEDGER
CREATE TABLE IF NOT EXISTS public.rider_earnings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    rider_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    delivery_id UUID NOT NULL REFERENCES public.deliveries(id) ON DELETE CASCADE,
    order_id UUID REFERENCES public.orders(id) ON DELETE SET NULL,
    base_amount NUMERIC(10,2) NOT NULL DEFAULT 0.00 CHECK (base_amount >= 0),
    tip_amount NUMERIC(10,2) NOT NULL DEFAULT 0.00 CHECK (tip_amount >= 0),
    fuel_allowance NUMERIC(10,2) NOT NULL DEFAULT 0.00 CHECK (fuel_allowance >= 0),
    platform_adjustment NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    net_amount NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    payout_status TEXT NOT NULL DEFAULT 'pending' CHECK (payout_status IN ('pending', 'processing', 'paid', 'failed')),
    paid_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trigger_rider_earnings_updated_at
    BEFORE UPDATE ON public.rider_earnings
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE INDEX IF NOT EXISTS idx_rider_earnings_rider ON public.rider_earnings(rider_id);
CREATE INDEX IF NOT EXISTS idx_rider_earnings_status ON public.rider_earnings(payout_status);

-- 9. ORDER STATUS LOGS (Audit Trail)
CREATE TABLE IF NOT EXISTS public.order_status_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    previous_status TEXT,
    new_status TEXT NOT NULL,
    changed_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    note TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_order_status_logs_order ON public.order_status_logs(order_id);

-- 10. STORE REVIEWS & RATINGS
CREATE TABLE IF NOT EXISTS public.store_reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    vendor_id UUID NOT NULL REFERENCES public.vendors(id) ON DELETE CASCADE,
    order_id UUID REFERENCES public.orders(id) ON DELETE SET NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT,
    reply_text TEXT,
    replied_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT unique_customer_order_review UNIQUE (customer_id, order_id)
);

CREATE TRIGGER trigger_store_reviews_updated_at
    BEFORE UPDATE ON public.store_reviews
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE INDEX IF NOT EXISTS idx_store_reviews_vendor ON public.store_reviews(vendor_id);

-- 11. PROMOTIONS & MARKETING BANNERS
CREATE TABLE IF NOT EXISTS public.promotions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    subtitle TEXT,
    tag TEXT,
    image_url TEXT,
    cta_label TEXT DEFAULT 'Explore Now',
    primary_color TEXT DEFAULT '#0F766E',
    accent_color TEXT DEFAULT '#2DD4BF',
    icon_name TEXT DEFAULT 'electric_moped',
    target_vendor_id UUID REFERENCES public.vendors(id) ON DELETE SET NULL,
    target_category_id UUID REFERENCES public.marketplace_categories(id) ON DELETE SET NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    display_order INT NOT NULL DEFAULT 0,
    start_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    end_date TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trigger_promotions_updated_at
    BEFORE UPDATE ON public.promotions
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE INDEX IF NOT EXISTS idx_promotions_active ON public.promotions(is_active, display_order);

-- 12. PLATFORM SETTINGS (Key-Value Config Store)
CREATE TABLE IF NOT EXISTS public.platform_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    key TEXT UNIQUE NOT NULL,
    value JSONB NOT NULL,
    description TEXT,
    updated_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trigger_platform_settings_updated_at
    BEFORE UPDATE ON public.platform_settings
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ==============================================================================
-- SECURITY FUNCTIONS & ADVANCED TRIGGERS
-- ==============================================================================

-- A. Automatic New User Profile Provisioning Trigger
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (
        id,
        phone,
        full_name,
        avatar_url,
        role,
        is_active
    ) VALUES (
        NEW.id,
        COALESCE(NEW.phone, NEW.raw_user_meta_data->>'phone', ''),
        COALESCE(NEW.raw_user_meta_data->>'full_name', 'Marketplace User'),
        NEW.raw_user_meta_data->>'avatar_url',
        'customer', -- Enforce safe default role
        TRUE
    )
    ON CONFLICT (id) DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Safe trigger attachment to auth.users if available
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'auth' AND table_name = 'users') THEN
        DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
        CREATE TRIGGER on_auth_user_created
            AFTER INSERT ON auth.users
            FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
    END IF;
END $$;

-- B. Privilege Escalation Prevention Trigger (Users cannot make themselves admin)
CREATE OR REPLACE FUNCTION public.prevent_role_escalation()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.role != OLD.role THEN
        -- Only existing super_admin or admin can change user roles
        IF NOT public.is_admin(auth.uid()) THEN
            RAISE EXCEPTION 'Privilege Escalation Blocked: Unauthorized role modification attempt.';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_prevent_role_escalation ON public.profiles;
CREATE TRIGGER trigger_prevent_role_escalation
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.prevent_role_escalation();

-- C. Server-Side Order Total Validation & Verification
CREATE OR REPLACE FUNCTION public.validate_order_totals()
RETURNS TRIGGER AS $$
BEGIN
    -- Ensure financial numbers are non-negative
    IF NEW.subtotal < 0 OR NEW.delivery_fee < 0 OR NEW.platform_fee < 0 THEN
        RAISE EXCEPTION 'Invalid Order: Subtotal, delivery fee, and platform fee must be non-negative.';
    END IF;

    -- Ensure calculated total equals the sum of components
    NEW.total_amount := NEW.subtotal + NEW.delivery_fee + NEW.platform_fee;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_validate_order_totals ON public.orders;
CREATE TRIGGER trigger_validate_order_totals
    BEFORE INSERT OR UPDATE ON public.orders
    FOR EACH ROW EXECUTE FUNCTION public.validate_order_totals();

-- D. Automatic Order Status Transition Audit Logger
CREATE OR REPLACE FUNCTION public.log_order_status_transition()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status IS DISTINCT FROM NEW.status THEN
        INSERT INTO public.order_status_logs (
            order_id,
            previous_status,
            new_status,
            changed_by,
            note
        ) VALUES (
            NEW.id,
            OLD.status::TEXT,
            NEW.status::TEXT,
            auth.uid(),
            'Order transitioned to ' || NEW.status::TEXT
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_log_order_status_transition ON public.orders;
CREATE TRIGGER trigger_log_order_status_transition
    AFTER UPDATE ON public.orders
    FOR EACH ROW EXECUTE FUNCTION public.log_order_status_transition();

-- ==============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES & HARDENING
-- ==============================================================================

ALTER TABLE public.marketplace_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.service_cities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customer_addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rider_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vendor_rider_contracts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vendor_operating_hours ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rider_earnings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_status_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.store_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.promotions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.platform_settings ENABLE ROW LEVEL SECURITY;

-- 1. FIX RIDER LOCATIONS PRIVACY (Drop insecure policy)
DROP POLICY IF EXISTS "Public and Admins view rider locations" ON public.rider_locations;

-- Secure Rider Locations Policies
CREATE POLICY "Riders manage own location" ON public.rider_locations
    FOR ALL USING (auth.uid() = rider_id);

CREATE POLICY "Authorized participants view rider location" ON public.rider_locations
    FOR SELECT USING (
        public.is_admin(auth.uid()) OR
        auth.uid() = rider_id OR
        -- Customer with active delivery assigned to this rider
        EXISTS (
            SELECT 1 FROM public.deliveries d
            JOIN public.orders o ON d.order_id = o.id
            WHERE d.rider_id = public.rider_locations.rider_id
              AND o.customer_id = auth.uid()
              AND d.status IN ('assigned', 'picked_up')
        ) OR
        -- Vendor with active order assigned to this rider
        EXISTS (
            SELECT 1 FROM public.deliveries d
            JOIN public.orders o ON d.order_id = o.id
            WHERE d.rider_id = public.rider_locations.rider_id
              AND o.vendor_id = auth.uid()
              AND d.status IN ('assigned', 'picked_up')
        )
    );

-- 2. Marketplace Categories RLS
CREATE POLICY "Public view active categories" ON public.marketplace_categories
    FOR SELECT USING (is_active = TRUE OR public.is_admin(auth.uid()));

CREATE POLICY "Admins manage categories" ON public.marketplace_categories
    FOR ALL USING (public.is_admin(auth.uid()));

-- 3. Service Cities RLS
CREATE POLICY "Public view active cities" ON public.service_cities
    FOR SELECT USING (is_active = TRUE OR public.is_admin(auth.uid()));

CREATE POLICY "Admins manage cities" ON public.service_cities
    FOR ALL USING (public.is_admin(auth.uid()));

-- 4. Customer Addresses RLS
CREATE POLICY "Customers manage own addresses" ON public.customer_addresses
    FOR ALL USING (auth.uid() = customer_id OR public.is_admin(auth.uid()));

-- 5. Rider Profiles RLS (Protects sensitive CNIC/KYC)
CREATE POLICY "Riders view own profile" ON public.rider_profiles
    FOR SELECT USING (auth.uid() = id OR public.is_admin(auth.uid()));

CREATE POLICY "Riders update own availability" ON public.rider_profiles
    FOR UPDATE USING (auth.uid() = id OR public.is_admin(auth.uid()));

CREATE POLICY "Admins manage rider profiles" ON public.rider_profiles
    FOR ALL USING (public.is_admin(auth.uid()));

-- 6. Vendor-Rider Contracts RLS
CREATE POLICY "Vendors and Riders view contracts" ON public.vendor_rider_contracts
    FOR SELECT USING (auth.uid() = vendor_id OR auth.uid() = rider_id OR public.is_admin(auth.uid()));

CREATE POLICY "Vendors manage rider contracts" ON public.vendor_rider_contracts
    FOR ALL USING (auth.uid() = vendor_id OR public.is_admin(auth.uid()));

-- 7. Vendor Operating Hours RLS
CREATE POLICY "Public view vendor hours" ON public.vendor_operating_hours
    FOR SELECT USING (TRUE);

CREATE POLICY "Vendors manage own hours" ON public.vendor_operating_hours
    FOR ALL USING (auth.uid() = vendor_id OR public.is_admin(auth.uid()));

-- 8. Rider Earnings RLS
CREATE POLICY "Riders view own earnings" ON public.rider_earnings
    FOR SELECT USING (auth.uid() = rider_id OR public.is_admin(auth.uid()));

CREATE POLICY "Admins manage earnings" ON public.rider_earnings
    FOR ALL USING (public.is_admin(auth.uid()));

-- 9. Order Status Logs RLS
CREATE POLICY "Order participants view status logs" ON public.order_status_logs
    FOR SELECT USING (
        public.is_admin(auth.uid()) OR
        EXISTS (
            SELECT 1 FROM public.orders o
            WHERE o.id = order_id AND (o.customer_id = auth.uid() OR o.vendor_id = auth.uid())
        ) OR
        EXISTS (
            SELECT 1 FROM public.deliveries d
            WHERE d.order_id = order_status_logs.order_id AND d.rider_id = auth.uid()
        )
    );

-- 10. Store Reviews RLS
CREATE POLICY "Public view store reviews" ON public.store_reviews
    FOR SELECT USING (TRUE);

CREATE POLICY "Customers write reviews" ON public.store_reviews
    FOR INSERT WITH CHECK (auth.uid() = customer_id);

CREATE POLICY "Vendors reply to reviews" ON public.store_reviews
    FOR UPDATE USING (auth.uid() = vendor_id OR public.is_admin(auth.uid()));

-- 11. Promotions RLS
CREATE POLICY "Public view active promotions" ON public.promotions
    FOR SELECT USING (is_active = TRUE OR public.is_admin(auth.uid()));

CREATE POLICY "Admins manage promotions" ON public.promotions
    FOR ALL USING (public.is_admin(auth.uid()));

-- 12. Platform Settings RLS
CREATE POLICY "Public read platform settings" ON public.platform_settings
    FOR SELECT USING (TRUE);

CREATE POLICY "Admins manage platform settings" ON public.platform_settings
    FOR ALL USING (public.is_admin(auth.uid()));

-- ==============================================================================
-- INITIAL BATKHELA SEED DATA
-- ==============================================================================

-- A. 6 Primary Marketplace Categories
INSERT INTO public.marketplace_categories (name, urdu_name, slug, description, icon, accent_color, display_order)
VALUES
    ('Restaurants & BBQ', 'ریستوران و تکہ', 'restaurants', 'Authentic Karahi, BBQ skewers, Kababs, Burgers and Fast Food', 'restaurant_outlined', '#0F766E', 1),
    ('Fresh Grocery', 'کریانہ و راشن', 'grocery', 'Flour, rice, cooking oils, dairy, pulses and daily pantry essentials', 'shopping_basket_outlined', '#4338CA', 2),
    ('Pharmacy & Health', 'فارمیسی و ادویات', 'pharmacy', 'Medicines, first-aid, infant care, and healthcare supplies', 'local_pharmacy_outlined', '#E11D48', 3),
    ('Fruits & Vegetables', 'تازہ پھل اور سبزیاں', 'produce', 'Daily fresh mountain apples, mangoes, seasonal farm vegetables and herbs', 'eco_outlined', '#16A34A', 4),
    ('Bakery & Sweets', 'مٹھائی اور بیکری', 'bakery', 'Traditional Batkhela Gulab Jamun, Barfi, fresh bread, biscuits and cakes', 'cake_outlined', '#D97706', 5),
    ('General Stores', 'جنرل اسٹور', 'general', 'Household cleaning, detergents, shampoo, soaps and utilities', 'storefront_outlined', '#4338CA', 6)
ON CONFLICT (slug) DO NOTHING;

-- B. Service Cities (Batkhela Active, Expansion Cities Prepared)
INSERT INTO public.service_cities (name, urdu_name, slug, latitude, longitude, radius_km, is_active, display_order)
VALUES
    ('Batkhela', 'بٹ خیلہ', 'batkhela', 34.6156, 71.9723, 15.0, TRUE, 1),
    ('Thana', 'تھانہ', 'thana', 34.6361, 72.0722, 12.0, FALSE, 2),
    ('Chakdara', 'چکدرہ', 'chakdara', 34.6560, 72.0310, 15.0, FALSE, 3),
    ('Timergara', 'تیمرگرہ', 'timergara', 34.8281, 71.8415, 20.0, FALSE, 4),
    ('Mingora / Swat', 'مینگورہ سوات', 'swat', 34.7717, 72.3602, 25.0, FALSE, 5)
ON CONFLICT (slug) DO NOTHING;

-- C. Platform Settings Defaults
INSERT INTO public.platform_settings (key, value, description)
VALUES
    ('marketplace_general', '{"name": "Batkhela Marketplace", "tagline": "Batkhela Local Express Delivery", "support_phone": "+92 345 0000000", "currency": "PKR", "currency_symbol": "Rs"}'::JSONB, 'General marketplace details and branding'),
    ('marketplace_fees', '{"base_delivery_fee": 40.0, "platform_fee": 20.0, "default_commission_rate": 10.0, "free_delivery_threshold": 2500.0}'::JSONB, 'Platform fee rules, commission rates and delivery fee calculation'),
    ('marketplace_operations', '{"is_accepting_orders": true, "auto_cancel_minutes": 15, "rider_dispatch_radius_km": 10.0, "emergency_mode": false}'::JSONB, 'Real-time operational switches and dispatch radius limits')
ON CONFLICT (key) DO NOTHING;

-- D. Initial Promotional Banners
INSERT INTO public.promotions (title, subtitle, tag, cta_label, primary_color, accent_color, icon_name, is_active, display_order)
VALUES
    ('Batkhela Local Express', 'Free delivery on your first 3 orders across Batkhela & Thana bazaar', 'SPECIAL PROMO', 'Explore Stores', '#0F766E', '#2DD4BF', 'electric_moped', TRUE, 1),
    ('Shinwari BBQ & Karahi Festival', 'Flat 20% OFF on all Mutton & Chicken Karahi and BBQ platters this weekend', 'WEEKEND SPECIAL', 'Order Feast', '#4338CA', '#F87171', 'local_fire_department', TRUE, 2),
    ('Farm Fresh Sabzi Mandi Deals', 'Directly sourced from Malakand green farms with same-day express doorstep dispatch', 'ORGANIC FRESH', 'Shop Produce', '#15803D', '#86EFAC', 'eco', TRUE, 3),
    ('Batkhela Central Pharmacy Care', 'Genuine prescription medicines, vitamins & first-aid essentials delivered in 20 mins', 'HEALTH FIRST', 'Order Meds', '#BE123C', '#FECDD3', 'medical_services_outlined', TRUE, 4)
ON CONFLICT DO NOTHING;
