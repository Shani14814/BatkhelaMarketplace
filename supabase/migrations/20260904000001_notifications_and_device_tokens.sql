-- ==============================================================================
-- BATKHELA MARKETPLACE — PHASE 7H NOTIFICATIONS & DEVICE TOKENS MIGRATION
-- Additive migration for user notifications, device push tokens, and RLS policies
-- ==============================================================================

-- 1. Create user_device_tokens Table
CREATE TABLE IF NOT EXISTS public.user_device_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    device_token TEXT NOT NULL,
    device_type TEXT NOT NULL DEFAULT 'android' CHECK (device_type IN ('android', 'ios', 'web')),
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    CONSTRAINT uq_user_device_token UNIQUE (user_id, device_token)
);

-- 2. Create notifications Table
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    type TEXT NOT NULL DEFAULT 'system_alert',
    priority TEXT NOT NULL DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
    target_role TEXT CHECK (target_role IN ('customer', 'vendor', 'rider', 'admin')),
    order_id UUID REFERENCES public.orders(id) ON DELETE SET NULL,
    delivery_id UUID REFERENCES public.deliveries(id) ON DELETE SET NULL,
    payload JSONB NOT NULL DEFAULT '{}'::jsonb,
    is_read BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    read_at TIMESTAMPTZ
);

-- Indexes for high-performance notification query and unread count filtering
CREATE INDEX IF NOT EXISTS idx_user_device_tokens_user_id ON public.user_device_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id_is_read ON public.notifications(user_id, is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON public.notifications(created_at DESC);

-- Enable Row Level Security (RLS)
ALTER TABLE public.user_device_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- 3. RLS Policies for user_device_tokens
-- Users can view their own registered tokens
CREATE POLICY "Users can view own device tokens"
    ON public.user_device_tokens FOR SELECT
    USING (auth.uid() = user_id);

-- Users can register their own device tokens
CREATE POLICY "Users can insert own device tokens"
    ON public.user_device_tokens FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Users can update their own device tokens (e.g. toggle active)
CREATE POLICY "Users can update own device tokens"
    ON public.user_device_tokens FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Users can delete their own device tokens
CREATE POLICY "Users can delete own device tokens"
    ON public.user_device_tokens FOR DELETE
    USING (auth.uid() = user_id);

-- 4. RLS Policies for notifications
-- Users can read their own notifications
CREATE POLICY "Users can view own notifications"
    ON public.notifications FOR SELECT
    USING (auth.uid() = user_id);

-- Users can update read state on their own notifications
CREATE POLICY "Users can update own notifications"
    ON public.notifications FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Users can delete their own notifications
CREATE POLICY "Users can delete own notifications"
    ON public.notifications FOR DELETE
    USING (auth.uid() = user_id);

-- 5. Add notifications to Supabase Realtime Publication
ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
