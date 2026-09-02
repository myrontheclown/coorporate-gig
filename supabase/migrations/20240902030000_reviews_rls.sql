  -- =============================================================================
  -- Migration: Let authenticated customers submit reviews and read their own.
  -- =============================================================================
  -- The client feedback flow (FeedbackRatingScreen) inserts into public.reviews.
  -- Without an INSERT RLS policy the authenticated customer's insert is
  -- rejected, so the app reports "Failed to submit review" and no row persists.
  --
  -- We grant:
  --   - INSERT for authenticated customers (customer_id = auth.uid())
  --   - SELECT for authenticated customers on THEIR OWN reviews
  --   - SELECT for authenticated workers on reviews referencing their profile
  --     (worker_profile.user_id = auth.uid()), so the future worker module can
  --     read their own ratings.
  --
  -- No destructive changes; only RLS policies are added.
  -- =============================================================================

  ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

  -- Customer may submit a review for a job (they are the reviewer).
  DO $$
  BEGIN
    IF NOT EXISTS (
      SELECT 1 FROM pg_policies
      WHERE schemaname = 'public'
        AND tablename  = 'reviews'
        AND policyname = 'reviews_insert_own'
    ) THEN
      CREATE POLICY reviews_insert_own
        ON public.reviews
        FOR INSERT
        TO authenticated
        WITH CHECK (auth.uid() = customer_id);
    END IF;
  END
  $$;

  -- Customer may read their own reviews.
  DO $$
  BEGIN
    IF NOT EXISTS (
      SELECT 1 FROM pg_policies
      WHERE schemaname = 'public'
        AND tablename  = 'reviews'
        AND policyname = 'reviews_select_own_customer'
    ) THEN
      CREATE POLICY reviews_select_own_customer
        ON public.reviews
        FOR SELECT
        TO authenticated
        USING (auth.uid() = customer_id);
    END IF;
  END
  $$;

  -- Worker may read reviews written about them (via their worker_profile).
  DO $$
  BEGIN
    IF NOT EXISTS (
      SELECT 1 FROM pg_policies
      WHERE schemaname = 'public'
        AND tablename  = 'reviews'
        AND policyname = 'reviews_select_own_worker'
    ) THEN
      CREATE POLICY reviews_select_own_worker
        ON public.reviews
        FOR SELECT
        TO authenticated
        USING (
          worker_id IN (
            SELECT id FROM public.worker_profile WHERE user_id = auth.uid()
          )
        );
    END IF;
  END
  $$;
