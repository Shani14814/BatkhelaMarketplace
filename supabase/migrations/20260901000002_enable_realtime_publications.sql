-- ==============================================================================
-- BATKHELA MARKETPLACE - PHASE 7E REALTIME REPLICATION & PUBLICATION SETUP
-- Migration: 20260901000002_enable_realtime_publications.sql
-- Description: Additive configuration enabling tables for Supabase Realtime CDC
--              while preserving existing tables, security, and RLS policies.
-- ==============================================================================

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
        -- Orders & Deliveries Realtime
        IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'orders') THEN
            ALTER PUBLICATION supabase_realtime ADD TABLE public.orders;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'deliveries') THEN
            ALTER PUBLICATION supabase_realtime ADD TABLE public.deliveries;
        END IF;

        -- Rider Telemetry Realtime (Secured by RLS)
        IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'rider_locations') THEN
            ALTER PUBLICATION supabase_realtime ADD TABLE public.rider_locations;
        END IF;

        -- Vendor & Catalog Realtime
        IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'vendors') THEN
            ALTER PUBLICATION supabase_realtime ADD TABLE public.vendors;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'products') THEN
            ALTER PUBLICATION supabase_realtime ADD TABLE public.products;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'rider_profiles') THEN
            ALTER PUBLICATION supabase_realtime ADD TABLE public.rider_profiles;
        END IF;

        -- Platform & Admin Realtime
        IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'marketplace_categories') THEN
            ALTER PUBLICATION supabase_realtime ADD TABLE public.marketplace_categories;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'promotions') THEN
            ALTER PUBLICATION supabase_realtime ADD TABLE public.promotions;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'service_cities') THEN
            ALTER PUBLICATION supabase_realtime ADD TABLE public.service_cities;
        END IF;
    END IF;
END $$;
