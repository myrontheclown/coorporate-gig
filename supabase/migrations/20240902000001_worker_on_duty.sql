-- =============================================================================
-- Migration: Add is_on_duty and on_duty_updated_at to worker_profile
-- =============================================================================
-- Adds a boolean duty-status flag and its last-toggled timestamp.
-- Workers default to off-duty (false).
-- A targeted RLS policy is added so a worker may update their own
-- is_on_duty / on_duty_updated_at columns. Existing policies are untouched.
-- The handle_new_user trigger and existing migration are not modified.
-- =============================================================================

ALTER TABLE public.worker_profile
  ADD COLUMN IF NOT EXISTS is_on_duty         boolean     NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS on_duty_updated_at timestamptz NULL;

-- Index for fast client-side "show only on-duty workers" queries
CREATE INDEX IF NOT EXISTS idx_worker_profile_is_on_duty
  ON public.worker_profile (is_on_duty);

-- =============================================================================
-- RLS: allow a worker to update their own is_on_duty / on_duty_updated_at
-- =============================================================================
-- Only a new policy is added; no existing policies are altered or dropped.

ALTER TABLE public.worker_profile ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename  = 'worker_profile'
      AND policyname = 'worker_profile_update_own_duty'
  ) THEN
    CREATE POLICY worker_profile_update_own_duty
      ON public.worker_profile
      FOR UPDATE
      TO authenticated
      USING   (user_id = auth.uid())
      WITH CHECK (user_id = auth.uid());
  END IF;
END
$$;
