-- =============================================================================
-- Wellbeing RLS + constraint tests (DO blocks + ASSERT, rolled back).
-- UNTESTED. Run after `supabase db reset`:
--   psql "<local db url>" -f supabase/tests/wellbeing_test.sql
-- =============================================================================
begin;

insert into auth.users (id, instance_id, aud, role, email) values
  ('00000000-0000-0000-0000-0000000000d1', '00000000-0000-0000-0000-000000000000',
   'authenticated', 'authenticated', 'd1@test.local'),
  ('00000000-0000-0000-0000-0000000000d2', '00000000-0000-0000-0000-000000000000',
   'authenticated', 'authenticated', 'd2@test.local');

create or replace function pg_temp.as_user(p uuid) returns void language plpgsql as $$
begin
  perform set_config('request.jwt.claims',
    json_build_object('sub', p, 'role', 'authenticated')::text, true);
  execute 'set local role authenticated';
end $$;

-- ---- User 1 writes ----
select pg_temp.as_user('00000000-0000-0000-0000-0000000000d1');
insert into public.mood_entries (level, feelings) values (2, array['lonely','tired']);
insert into public.journal_entries (kind, body) values ('letter', 'Private words.');
insert into public.no_contact_attempts (goal_days) values (30);

do $$ begin
  assert (select count(*) from public.mood_entries) = 1, 'owner sees own mood';
  assert (select user_id from public.journal_entries limit 1) = auth.uid(), 'user_id defaults to auth.uid()';
  -- Only one active run.
  begin
    insert into public.no_contact_attempts (goal_days) values (7);
    assert false, 'second active run must fail';
  exception when unique_violation then null;
  end;
  -- Constraints.
  begin
    insert into public.mood_entries (level) values (6);
    assert false, 'level 6 must fail';
  exception when check_violation then null;
  end;
  begin
    insert into public.mood_entries (level, feelings) values (3, array['ecstatic']);
    assert false, 'unknown feeling must fail';
  exception when check_violation then null;
  end;
end $$;

-- ---- User 2 sees nothing of user 1 ----
select pg_temp.as_user('00000000-0000-0000-0000-0000000000d2');
do $$ begin
  assert (select count(*) from public.mood_entries) = 0, 'RLS hides other moods';
  assert (select count(*) from public.journal_entries) = 0, 'RLS hides other journals';
  assert (select count(*) from public.no_contact_attempts) = 0, 'RLS hides other attempts';
end $$;
-- Writing as someone else is refused.
do $$ begin
  begin
    insert into public.journal_entries (user_id, body)
    values ('00000000-0000-0000-0000-0000000000d1', 'spoof');
    assert false, 'insert for another user must fail';
  exception when insufficient_privilege then null;
  end;
end $$;

rollback;
