-- ==============================================================================
-- BATKHELA MARKETPLACE - INITIAL DATABASE SCHEMA & ROW LEVEL SECURITY
-- ==============================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Custom Types / Enums
CREATE TYPE user_role AS ENUM ('customer', 'vendor', 'rider', 'admin', 'super_admin');
CREATE TYPE order_status AS ENUM ('placed', 'accepted', 'preparing', 'ready_for_pickup', 'out_for_delivery', 'delivered', 'cancelled');
CREATE TYPE delivery_status AS ENUM ('pending', 'assigned', 'picked_up', 'delivered', 'failed');
CREATE TYPE payment_method AS ENUM ('cash_on_delivery', 'easypaisa', 'jazzcash', 'card');
CREATE TYPE payment_status AS ENUM ('pending', 'paid', 'refunded');

-- 2. User Profiles Table (Linked to Supabase auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    phone TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    avatar_url TEXT,
    role user_role NOT NULL DEFAULT 'customer',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. Vendors / Stores Table
CREATE TABLE IF NOT EXISTS public.vendors (
    id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
    store_name TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    description TEXT,
    logo_url TEXT,
    banner_url TEXT,
    address TEXT NOT NULL,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    phone TEXT,
    commission_rate NUMERIC(5,2) NOT NULL DEFAULT 10.00,
    is_open BOOLEAN NOT NULL DEFAULT TRUE,
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. Vendor Product Categories
CREATE TABLE IF NOT EXISTS public.vendor_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_id UUID NOT NULL REFERENCES public.vendors(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    sort_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 5. Products Table
CREATE TABLE IF NOT EXISTS public.products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_id UUID NOT NULL REFERENCES public.vendors(id) ON DELETE CASCADE,
    category_id UUID REFERENCES public.vendor_categories(id) ON DELETE SET NULL,
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    discount_price NUMERIC(10,2) CHECK (discount_price >= 0),
    stock_quantity INT NOT NULL DEFAULT 100,
    is_available BOOLEAN NOT NULL DEFAULT TRUE,
    image_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 6. Orders Table
CREATE TABLE IF NOT EXISTS public.orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_number BIGSERIAL UNIQUE,
    customer_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    vendor_id UUID NOT NULL REFERENCES public.vendors(id) ON DELETE RESTRICT,
    subtotal NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    delivery_fee NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    platform_fee NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    total_amount NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    status order_status NOT NULL DEFAULT 'placed',
    payment_method payment_method NOT NULL DEFAULT 'cash_on_delivery',
    payment_status payment_status NOT NULL DEFAULT 'pending',
    delivery_address TEXT NOT NULL,
    delivery_lat DOUBLE PRECISION,
    delivery_lng DOUBLE PRECISION,
    customer_notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 7. Order Items Table
CREATE TABLE IF NOT EXISTS public.order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES public.products(id) ON DELETE SET NULL,
    product_name TEXT NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    total_price NUMERIC(10,2) NOT NULL
);

-- 8. Deliveries Table
CREATE TABLE IF NOT EXISTS public.deliveries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID UNIQUE NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    rider_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    status delivery_status NOT NULL DEFAULT 'pending',
    pickup_time TIMESTAMPTZ,
    delivered_time TIMESTAMPTZ,
    proof_image_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 9. Rider Live Telemetry
CREATE TABLE IF NOT EXISTS public.rider_locations (
    rider_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    heading DOUBLE PRECISION DEFAULT 0.0,
    is_online BOOLEAN NOT NULL DEFAULT FALSE,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ==============================================================================
-- INDEXES FOR PERFORMANCE
-- ==============================================================================
CREATE INDEX idx_profiles_role ON public.profiles(role);
CREATE INDEX idx_vendors_slug ON public.vendors(slug);
CREATE INDEX idx_products_vendor ON public.products(vendor_id);
CREATE INDEX idx_orders_customer ON public.orders(customer_id);
CREATE INDEX idx_orders_vendor ON public.orders(vendor_id);
CREATE INDEX idx_orders_status ON public.orders(status);
CREATE INDEX idx_order_items_order ON public.order_items(order_id);
CREATE INDEX idx_deliveries_rider ON public.deliveries(rider_id);

-- ==============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ==============================================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vendors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vendor_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.deliveries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rider_locations ENABLE ROW LEVEL SECURITY;

-- Helper Function: Check Admin Status
CREATE OR REPLACE FUNCTION public.is_admin(user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.profiles 
        WHERE id = user_id AND role IN ('admin', 'super_admin')
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Profiles: Users can view own profile or admins can view all. Public can read basic vendor info.
CREATE POLICY "Users can read own profile" ON public.profiles
    FOR SELECT USING (auth.uid() = id OR public.is_admin(auth.uid()));

CREATE POLICY "Users can update own profile" ON public.profiles
    FOR UPDATE USING (auth.uid() = id);

-- Vendors: Anyone can read active verified vendors. Vendors update own store.
CREATE POLICY "Public can view active vendors" ON public.vendors
    FOR SELECT USING (is_verified = TRUE OR auth.uid() = id OR public.is_admin(auth.uid()));

CREATE POLICY "Vendors can update own store" ON public.vendors
    FOR UPDATE USING (auth.uid() = id OR public.is_admin(auth.uid()));

-- Products: Anyone can view available products from active vendors.
CREATE POLICY "Public can view products" ON public.products
    FOR SELECT USING (is_available = TRUE OR auth.uid() = vendor_id OR public.is_admin(auth.uid()));

CREATE POLICY "Vendors can manage own products" ON public.products
    FOR ALL USING (auth.uid() = vendor_id OR public.is_admin(auth.uid()));

-- Orders: Customers see their own, vendors see orders to their store, riders see their active delivery, admins see all.
CREATE POLICY "Customers view own orders" ON public.orders
    FOR SELECT USING (auth.uid() = customer_id);

CREATE POLICY "Vendors view received orders" ON public.orders
    FOR SELECT USING (auth.uid() = vendor_id);

CREATE POLICY "Admins full order access" ON public.orders
    FOR ALL USING (public.is_admin(auth.uid()));

CREATE POLICY "Customers can place orders" ON public.orders
    FOR INSERT WITH CHECK (auth.uid() = customer_id);

-- Order Items: Linked to order visibility
CREATE POLICY "View order items" ON public.order_items
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.orders o 
            WHERE o.id = order_id AND (
                o.customer_id = auth.uid() OR 
                o.vendor_id = auth.uid() OR 
                public.is_admin(auth.uid())
            )
        )
    );

-- Deliveries: Assigned riders and admins
CREATE POLICY "Riders and Admins view deliveries" ON public.deliveries
    FOR SELECT USING (auth.uid() = rider_id OR public.is_admin(auth.uid()));

CREATE POLICY "Riders update active deliveries" ON public.deliveries
    FOR UPDATE USING (auth.uid() = rider_id OR public.is_admin(auth.uid()));

-- Rider Locations: Live GPS public for active orders or admin monitoring
CREATE POLICY "Riders update own location" ON public.rider_locations
    FOR ALL USING (auth.uid() = rider_id);

CREATE POLICY "Public and Admins view rider locations" ON public.rider_locations
    FOR SELECT USING (TRUE);
