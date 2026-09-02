-- =============================================================================
-- Migration: Let authenticated customers CREATE jobs and read their own.
-- =============================================================================
-- The client request flow (RequestServicePhotosScreen / OtpVerificationScreen)
-- inserts into public.jobs. Without an INSERT RLS policy the authenticated
-- customer's insert is rejected, so the app reports "job creation failed" and
-- no row is persisted.
--
-- We grant:
--   - INSERT for the authenticated role (customers create their own jobs)
--   - SELECT for the authenticated role on THEIR OWN rows (customer_id = auth.uid())
--
-- We do NOT grant UPDATE/DELETE broadly here. Job lifecycle updates are
-- intentionally left to worker/cooperative flows.
-- =============================================================================

ALTER TABLE public.jobs ENABLE ROW LEVEL SECURITY;

-- Customer may insert a job row (they set customer_id to their own uid).
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename  = 'jobs'
      AND policyname = 'jobs_insert_own'
  ) THEN
    CREATE POLICY jobs_insert_own
      ON public.jobs
      FOR INSERT
      TO authenticated
      WITH CHECK (auth.uid() = customer_id);
  END IF;
END
$$;

-- Customer may read their own jobs.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename  = 'jobs'
      AND policyname = 'jobs_select_own'
  ) THEN
    CREATE POLICY jobs_select_own
      ON public.jobs
      FOR SELECT
      TO authenticated
      USING (auth.uid() = customer_id);
  END IF;
END
$$;

-- Customer may update their own jobs (e.g. to attach photo URLs).
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename  = 'jobs'
      AND policyname = 'jobs_update_own'
  ) THEN
    CREATE POLICY jobs_update_own
      ON public.jobs
      FOR UPDATE
      TO authenticated
      USING (auth.uid() = customer_id)
      WITH CHECK (auth.uid() = customer_id);
  END IF;
END
$$;

-- =============================================================================
-- Storage: job-photos bucket
-- =============================================================================
-- The client uploads photos with uploadBinary() and displays them via
-- getPublicUrl(). For that to work:
--   1) authenticated users can INSERT/UPDATE objects in the 'job-photos' bucket
--   2) the objects are publicly readable (the <img> fetch sends no auth header)
--
-- The 'job-photos' bucket already exists in the project; these policies only
-- control access to the objects inside it.
-- =============================================================================

-- INSERT: authenticated users may upload into job-photos.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'storage'
      AND tablename  = 'objects'
      AND policyname = 'job_photos_insert'
  ) THEN
    CREATE POLICY job_photos_insert
      ON storage.objects
      FOR INSERT
      TO authenticated
      WITH CHECK (bucket_id = 'job-photos');
  END IF;
END
$$;

-- UPDATE: authenticated users may overwrite job-photos objects (upsert).
-- No owner check — keeps photo attachment reliable regardless of how the
-- storage owner column is populated.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'storage'
      AND tablename  = 'objects'
      AND policyname = 'job_photos_update'
  ) THEN
    CREATE POLICY job_photos_update
      ON storage.objects
      FOR UPDATE
      TO authenticated
      USING (bucket_id = 'job-photos')
      WITH CHECK (bucket_id = 'job-photos');
  END IF;
END
$$;

-- SELECT: public read so getPublicUrl() URLs render in <img> tags.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'storage'
      AND tablename  = 'objects'
      AND policyname = 'job_photos_select_public'
  ) THEN
    CREATE POLICY job_photos_select_public
      ON storage.objects
      FOR SELECT
      USING (bucket_id = 'job-photos');
  END IF;
END
$$;
