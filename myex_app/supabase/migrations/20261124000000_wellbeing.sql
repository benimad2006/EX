-- =============================================================================
-- Wellbeing: mood check-ins, journal, no-contact attempts.
-- All three are private user data: RLS limits every row to its owner, there is
-- no server-side read by Edge Functions, and analytics never sees text.
-- Accounts deleted in auth.users cascade.
-- UNTESTED: written without the Supabase CLI. Run `supabase db reset` locally
-- and supabase/tests/wellbeing_test.sql before pushing.
-- =============================================================================

-- ---- Mood check-ins ---------------------------------------------------------
create table if not exists public.mood_entries (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null default auth.uid() references auth.users on delete cascade,
  level      smallint not null check (level between 1 and 5),
  feelings   text[] not null default '{}'
             check (cardinality(feelings) <= 12
                    and feelings <@ array['heartbroken','lonely','angry','anxious','numb','confused',
                                          'tired','hopeful','calm','relieved','proud','grateful']::text[]),
  note       text check (note is null or length(note) <= 280),
  created_at timestamptz not null default now()
);
create index if not exists mood_entries_user_idx on public.mood_entries (user_id, created_at desc);

alter table public.mood_entries enable row level security;
drop policy if exists mood_select_own on public.mood_entries;
create policy mood_select_own on public.mood_entries for select to authenticated
  using ((select auth.uid()) = user_id);
drop policy if exists mood_insert_own on public.mood_entries;
create policy mood_insert_own on public.mood_entries for insert to authenticated
  with check ((select auth.uid()) = user_id);
drop policy if exists mood_delete_own on public.mood_entries;
create policy mood_delete_own on public.mood_entries for delete to authenticated
  using ((select auth.uid()) = user_id);

-- ---- Journal ----------------------------------------------------------------
create table if not exists public.journal_entries (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null default auth.uid() references auth.users on delete cascade,
  kind       text not null default 'reflection'
             check (kind in ('reflection','letter','gratitude','list')),
  prompt     text check (prompt is null or length(prompt) <= 200),
  body       text not null check (length(btrim(body)) between 1 and 10000),
  mood_level smallint check (mood_level is null or mood_level between 1 and 5),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists journal_entries_user_idx on public.journal_entries (user_id, created_at desc);

drop trigger if exists journal_entries_touch on public.journal_entries;
create trigger journal_entries_touch before update on public.journal_entries
  for each row execute function public.touch_updated_at();   -- from 20261118000000_onboarding

alter table public.journal_entries enable row level security;
drop policy if exists journal_select_own on public.journal_entries;
create policy journal_select_own on public.journal_entries for select to authenticated
  using ((select auth.uid()) = user_id);
drop policy if exists journal_insert_own on public.journal_entries;
create policy journal_insert_own on public.journal_entries for insert to authenticated
  with check ((select auth.uid()) = user_id);
drop policy if exists journal_update_own on public.journal_entries;
create policy journal_update_own on public.journal_entries for update to authenticated
  using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
drop policy if exists journal_delete_own on public.journal_entries;
create policy journal_delete_own on public.journal_entries for delete to authenticated
  using ((select auth.uid()) = user_id);

-- ---- No-contact attempts ----------------------------------------------------
-- One row per run. At most one active run (ended_on is null) per user.
-- profiles.no_contact_since mirrors the active run's start (the trial recap
-- in 20261118000300_lifecycle reads it); the client keeps them in sync.
create table if not exists public.no_contact_attempts (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null default auth.uid() references auth.users on delete cascade,
  started_on date not null default current_date,
  ended_on   date check (ended_on is null or ended_on >= started_on),
  goal_days  smallint not null default 30 check (goal_days in (7, 30, 60, 90)),
  reflection text check (reflection is null or length(reflection) <= 500),
  created_at timestamptz not null default now()
);
create index if not exists no_contact_user_idx on public.no_contact_attempts (user_id, started_on desc);
create unique index if not exists no_contact_one_active
  on public.no_contact_attempts (user_id) where ended_on is null;

alter table public.no_contact_attempts enable row level security;
drop policy if exists nc_select_own on public.no_contact_attempts;
create policy nc_select_own on public.no_contact_attempts for select to authenticated
  using ((select auth.uid()) = user_id);
drop policy if exists nc_insert_own on public.no_contact_attempts;
create policy nc_insert_own on public.no_contact_attempts for insert to authenticated
  with check ((select auth.uid()) = user_id);
drop policy if exists nc_update_own on public.no_contact_attempts;
create policy nc_update_own on public.no_contact_attempts for update to authenticated
  using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);

-- Backfill: an existing streak becomes the first (active) attempt.
insert into public.no_contact_attempts (user_id, started_on)
select p.id, p.no_contact_since
from public.profiles p
where p.no_contact_since is not null
  and not exists (select 1 from public.no_contact_attempts a where a.user_id = p.id);
