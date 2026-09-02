-- =============================================================================
-- Migration: Auto-create public.user_profile on auth.users INSERT
-- =============================================================================
-- This trigger fires whenever a new user is created via Supabase Auth.
-- It creates the corresponding public.user_profile row using the same UUID,
-- preventing orphaned auth users when Flutter-side profile creation fails.
--
-- Run this in the Supabase SQL Editor (Dashboard → SQL Editor → New query).
-- =============================================================================

-- 1. Trigger function
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.user_profile (
    id,
    full_name,
    email,
    phone,
    role,
    address,
    city,
    state,
    pincode,
    profile_image,
    created_at
  )
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    COALESCE(NEW.email, ''),
    COALESCE(NEW.raw_user_meta_data->>'phone', ''),
    -- Safety: only allow known, non-privileged roles from metadata.
    -- Admin accounts must be granted manually; a signup cannot self-assign admin.
    CASE
      WHEN NEW.raw_user_meta_data->>'role' IN ('customer', 'worker') THEN NEW.raw_user_meta_data->>'role'
      ELSE 'customer'
    END,
    '',   -- address
    '',   -- city
    '',   -- state
    '',   -- pincode
    '',   -- profile_image
    NOW()
  )
  ON CONFLICT (id) DO NOTHING;  -- Idempotent: never overwrite existing profiles

  RETURN NEW;
END;
$$;

-- 2. Attach trigger to auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();


-- =============================================================================
-- Row Level Security (RLS) policies for public.user_profile
-- =============================================================================
-- Ensure RLS is enabled and only the owning user can read/update their profile.

ALTER TABLE public.user_profile ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to read their own profile
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename  = 'user_profile'
      AND policyname = 'user_profile_select_own'
  ) THEN
    CREATE POLICY user_profile_select_own
      ON public.user_profile
      FOR SELECT
      TO authenticated
      USING (auth.uid() = id);
  END IF;
END
$$;

-- Allow authenticated users to update their own profile
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename  = 'user_profile'
      AND policyname = 'user_profile_update_own'
  ) THEN
    CREATE POLICY user_profile_update_own
      ON public.user_profile
      FOR UPDATE
      TO authenticated
      USING (auth.uid() = id)
      WITH CHECK (auth.uid() = id);
  END IF;
END
$$;

-- Allow the service role (used by triggers / server-side operations) to insert
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename  = 'user_profile'
      AND policyname = 'user_profile_insert_own'
  ) THEN
    CREATE POLICY user_profile_insert_own
      ON public.user_profile
      FOR INSERT
      TO authenticated
      WITH CHECK (auth.uid() = id);
  END IF;
END
$$;
