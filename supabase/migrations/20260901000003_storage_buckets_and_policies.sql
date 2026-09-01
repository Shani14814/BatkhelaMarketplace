-- ==============================================================================
-- BATKHELA MARKETPLACE - PHASE 7F SUPABASE STORAGE BUCKETS & SECURITY POLICIES
-- Migration: 20260901000003_storage_buckets_and_policies.sql
-- Description: Additive configuration provisioning storage buckets and strict RLS
--              for avatars, store logos, store banners, products, and delivery proofs.
-- ==============================================================================

-- 1. Create Storage Buckets (if storage schema exists)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'storage') THEN
        -- user-avatars (Public Read)
        INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
        VALUES ('user-avatars', 'user-avatars', true, 2097152, ARRAY['image/jpeg', 'image/png', 'image/webp'])
        ON CONFLICT (id) DO UPDATE SET
            public = true,
            file_size_limit = 2097152,
            allowed_mime_types = ARRAY['image/jpeg', 'image/png', 'image/webp'];

        -- store-logos (Public Read)
        INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
        VALUES ('store-logos', 'store-logos', true, 3145728, ARRAY['image/jpeg', 'image/png', 'image/webp'])
        ON CONFLICT (id) DO UPDATE SET
            public = true,
            file_size_limit = 3145728,
            allowed_mime_types = ARRAY['image/jpeg', 'image/png', 'image/webp'];

        -- store-banners (Public Read)
        INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
        VALUES ('store-banners', 'store-banners', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp'])
        ON CONFLICT (id) DO UPDATE SET
            public = true,
            file_size_limit = 5242880,
            allowed_mime_types = ARRAY['image/jpeg', 'image/png', 'image/webp'];

        -- product-images (Public Read)
        INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
        VALUES ('product-images', 'product-images', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp'])
        ON CONFLICT (id) DO UPDATE SET
            public = true,
            file_size_limit = 5242880,
            allowed_mime_types = ARRAY['image/jpeg', 'image/png', 'image/webp'];

        -- delivery-proofs (PRIVATE READ ONLY - NEVER PUBLIC)
        INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
        VALUES ('delivery-proofs', 'delivery-proofs', false, 10485760, ARRAY['image/jpeg', 'image/png', 'image/webp'])
        ON CONFLICT (id) DO UPDATE SET
            public = false,
            file_size_limit = 10485760,
            allowed_mime_types = ARRAY['image/jpeg', 'image/png', 'image/webp'];
    END IF;
END $$;

-- 2. Storage Security / RLS Policies on storage.objects

-- A. USER AVATARS POLICIES
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'storage' AND table_name = 'objects') THEN
        DROP POLICY IF EXISTS "Public can view avatars" ON storage.objects;
        CREATE POLICY "Public can view avatars" ON storage.objects
            FOR SELECT USING (bucket_id = 'user-avatars');

        DROP POLICY IF EXISTS "Users can upload their own avatar" ON storage.objects;
        CREATE POLICY "Users can upload their own avatar" ON storage.objects
            FOR INSERT WITH CHECK (
                bucket_id = 'user-avatars' AND
                (storage.foldername(name))[1] = auth.uid()::text
            );

        DROP POLICY IF EXISTS "Users can update their own avatar" ON storage.objects;
        CREATE POLICY "Users can update their own avatar" ON storage.objects
            FOR UPDATE USING (
                bucket_id = 'user-avatars' AND
                (storage.foldername(name))[1] = auth.uid()::text
            );

        DROP POLICY IF EXISTS "Users can delete their own avatar" ON storage.objects;
        CREATE POLICY "Users can delete their own avatar" ON storage.objects
            FOR DELETE USING (
                bucket_id = 'user-avatars' AND
                (storage.foldername(name))[1] = auth.uid()::text
            );
    END IF;
END $$;

-- B. STORE LOGOS & BANNERS POLICIES
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'storage' AND table_name = 'objects') THEN
        DROP POLICY IF EXISTS "Public can view store logos" ON storage.objects;
        CREATE POLICY "Public can view store logos" ON storage.objects
            FOR SELECT USING (bucket_id = 'store-logos' OR bucket_id = 'store-banners');

        DROP POLICY IF EXISTS "Vendors and Admins can upload store media" ON storage.objects;
        CREATE POLICY "Vendors and Admins can upload store media" ON storage.objects
            FOR INSERT WITH CHECK (
                (bucket_id = 'store-logos' OR bucket_id = 'store-banners') AND
                (
                    EXISTS (
                        SELECT 1 FROM public.vendors v
                        WHERE v.id::text = (storage.foldername(name))[1]
                          AND (v.user_id = auth.uid() OR public.current_user_role() = 'super_admin')
                    )
                )
            );

        DROP POLICY IF EXISTS "Vendors and Admins can update store media" ON storage.objects;
        CREATE POLICY "Vendors and Admins can update store media" ON storage.objects
            FOR UPDATE USING (
                (bucket_id = 'store-logos' OR bucket_id = 'store-banners') AND
                (
                    EXISTS (
                        SELECT 1 FROM public.vendors v
                        WHERE v.id::text = (storage.foldername(name))[1]
                          AND (v.user_id = auth.uid() OR public.current_user_role() = 'super_admin')
                    )
                )
            );

        DROP POLICY IF EXISTS "Vendors and Admins can delete store media" ON storage.objects;
        CREATE POLICY "Vendors and Admins can delete store media" ON storage.objects
            FOR DELETE USING (
                (bucket_id = 'store-logos' OR bucket_id = 'store-banners') AND
                (
                    EXISTS (
                        SELECT 1 FROM public.vendors v
                        WHERE v.id::text = (storage.foldername(name))[1]
                          AND (v.user_id = auth.uid() OR public.current_user_role() = 'super_admin')
                    )
                )
            );
    END IF;
END $$;

-- C. PRODUCT IMAGES POLICIES
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'storage' AND table_name = 'objects') THEN
        DROP POLICY IF EXISTS "Public can view product images" ON storage.objects;
        CREATE POLICY "Public can view product images" ON storage.objects
            FOR SELECT USING (bucket_id = 'product-images');

        DROP POLICY IF EXISTS "Vendors and Admins can manage product images" ON storage.objects;
        CREATE POLICY "Vendors and Admins can manage product images" ON storage.objects
            FOR ALL USING (
                bucket_id = 'product-images' AND
                (
                    EXISTS (
                        SELECT 1 FROM public.vendors v
                        WHERE v.id::text = (storage.foldername(name))[1]
                          AND (v.user_id = auth.uid() OR public.current_user_role() = 'super_admin')
                    )
                )
            );
    END IF;
END $$;

-- D. DELIVERY PROOF POLICIES (Strictly Private - No Public Access)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'storage' AND table_name = 'objects') THEN
        -- Only assigned rider, relevant customer/vendor, and admin can view proof
        DROP POLICY IF EXISTS "Authorized users can view delivery proofs" ON storage.objects;
        CREATE POLICY "Authorized users can view delivery proofs" ON storage.objects
            FOR SELECT USING (
                bucket_id = 'delivery-proofs' AND
                (
                    public.current_user_role() = 'super_admin' OR
                    EXISTS (
                        SELECT 1 FROM public.deliveries d
                        JOIN public.orders o ON d.order_id = o.id
                        WHERE d.id::text = (storage.foldername(name))[1]
                          AND (
                              d.rider_id = auth.uid() OR
                              o.customer_id = auth.uid() OR
                              EXISTS (SELECT 1 FROM public.vendors v WHERE v.id = o.vendor_id AND v.user_id = auth.uid())
                          )
                    )
                )
            );

        -- Only the assigned rider or admin can upload delivery proof
        DROP POLICY IF EXISTS "Assigned rider can upload delivery proof" ON storage.objects;
        CREATE POLICY "Assigned rider can upload delivery proof" ON storage.objects
            FOR INSERT WITH CHECK (
                bucket_id = 'delivery-proofs' AND
                (
                    public.current_user_role() = 'super_admin' OR
                    EXISTS (
                        SELECT 1 FROM public.deliveries d
                        WHERE d.id::text = (storage.foldername(name))[1]
                          AND d.rider_id = auth.uid()
                    )
                )
            );
    END IF;
END $$;
