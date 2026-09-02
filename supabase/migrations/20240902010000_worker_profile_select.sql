-- =============================================================================
-- Migration: Let authenticated customers READ workers for the client map.
-- =============================================================================
-- The client Home map reads real workers from public.worker_profile and
-- renders their location using worker_profile.latitude / longitude.
--
-- worker_profile has NO full_name column — the worker's name lives in
-- public.user_profile, matched via worker_profile.user_id -> user_profile.id.
-- The Flutter service batches that lookup independently, so this policy file
-- only needs to grant READ access.
--
-- We only grant SELECT. Customers must NOT be able to UPDATE/DELETE
-- worker_profile rows (that belongs to the worker / cooperative admin).
-- =============================================================================

ALTER TABLE public.worker_profile ENABLE ROW LEVEL SECURITY;

-- Authenticated customers can SELECT any worker row (verified, available, or
-- otherwise). The app filters for verified + available + valid coordinates in
-- the client query. No distance / viewport / location filtering here.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename  = 'worker_profile'
      AND policyname = 'worker_profile_select_all'
  ) THEN
    CREATE POLICY worker_profile_select_all
      ON public.worker_profile
      FOR SELECT
      TO authenticated
      USING (true);
  END IF;
END
$$;

-- Workers own their own profile row (so they can update availability later).
-- Not strictly required by the map, but kept consistent and non-intrusive.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename  = 'worker_profile'
      AND policyname = 'worker_profile_update_own'
  ) THEN
    CREATE POLICY worker_profile_update_own
      ON public.worker_profile
      FOR UPDATE
      TO authenticated
      USING (auth.uid() = user_id)
      WITH CHECK (auth.uid() = user_id);
  END IF;
END
$$;

-- The joined cooperative name shown on the worker card / marker.
ALTER TABLE public.cooperative_profile ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename  = 'cooperative_profile'
      AND policyname = 'cooperative_profile_select_all'
  ) THEN
    CREATE POLICY cooperative_profile_select_all
      ON public.cooperative_profile
      FOR SELECT
      TO authenticated
      USING (true);
  END IF;
END
$$;
