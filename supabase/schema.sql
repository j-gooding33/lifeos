-- Postgres mirror of the §23.3 SQLite schema, scoped to what M4 actually
-- needs (profiles, preferences) so the RLS pattern here is real and
-- test-shaped rather than speculative. The remaining 28 tables get their
-- Postgres mirror + RLS policy in the milestone that first syncs them —
-- see DECISIONS.md for why writing all 30 now, untested, wasn't the
-- right call.
--
-- Not deployed yet: this machine has no Supabase project. Run this in the
-- SQL editor (or `supabase db push`) once one exists, then M4's DoD
-- ("a second account cannot read the first's rows") becomes testable.

create table if not exists profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text,
  avatar_path text,
  timezone text not null default 'UTC',
  week_start integer not null default 1,
  currency text not null default 'GBP',
  date_format text not null default 'dmy',
  onboarded_at bigint,
  created_at bigint,
  updated_at bigint
);

alter table profiles enable row level security;

create policy "profiles_select_own" on profiles
  for select using (auth.uid() = id);
create policy "profiles_insert_own" on profiles
  for insert with check (auth.uid() = id);
create policy "profiles_update_own" on profiles
  for update using (auth.uid() = id);
create policy "profiles_delete_own" on profiles
  for delete using (auth.uid() = id);

create table if not exists preferences (
  user_id uuid not null references auth.users (id) on delete cascade,
  key text not null,
  value text,
  updated_at bigint,
  primary key (user_id, key)
);

alter table preferences enable row level security;

create policy "preferences_select_own" on preferences
  for select using (auth.uid() = user_id);
create policy "preferences_insert_own" on preferences
  for insert with check (auth.uid() = user_id);
create policy "preferences_update_own" on preferences
  for update using (auth.uid() = user_id);
create policy "preferences_delete_own" on preferences
  for delete using (auth.uid() = user_id);
