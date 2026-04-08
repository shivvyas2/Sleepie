-- Slipie — complete database schema
-- Run via: supabase db push
-- Or paste into Supabase Dashboard > SQL Editor > Run

-- gen_random_uuid() is built into Supabase/Postgres 13+ — no extension needed

-- ─── Users ────────────────────────────────────────────────────────────────────

create table if not exists public.users (
  id           uuid primary key references auth.users on delete cascade,
  email        text,
  display_name text,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

-- Auto-create a user row the moment someone signs up
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.users (id, email)
  values (new.id, new.email)
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ─── Soundscapes ──────────────────────────────────────────────────────────────

create table if not exists public.soundscapes (
  id             text primary key,
  name           text not null,
  description    text,
  noise_color    text not null check (noise_color in ('pink', 'brown', 'white')),
  base_frequency float not null default 80,
  reverb_preset  int   not null default 4,
  oscillator_mix float not null default 0.3
);

-- Seed all 8 built-in soundscapes
insert into public.soundscapes (id, name, description, noise_color, base_frequency, reverb_preset, oscillator_mix)
values
  ('rain',         'Rain',         'Gentle rainfall on glass',              'pink',  80,  4, 0.30),
  ('ocean',        'Ocean',        'Deep ocean waves',                      'brown', 60,  6, 0.40),
  ('white_noise',  'White Noise',  'Pure white noise for focus and sleep',  'white', 100, 2, 0.10),
  ('forest',       'Forest',       'Night forest with gentle wind',         'pink',  110, 5, 0.50),
  ('space',        'Space',        'Vast cosmic ambience',                  'brown', 40,  8, 0.70),
  ('arctic',       'Arctic Wind',  'Cold wind across frozen tundra',        'white', 90,  7, 0.20),
  ('cave',         'Cave',         'Deep cave resonance and dripping water','brown', 55,  9, 0.60),
  ('desert_night', 'Desert Night', 'Warm desert stillness under stars',     'pink',  70,  3, 0.35)
on conflict (id) do nothing;

-- ─── Sleep Sessions ───────────────────────────────────────────────────────────

create table if not exists public.sleep_sessions (
  id               uuid primary key default gen_random_uuid(),
  user_id          uuid not null references public.users (id) on delete cascade,
  soundscape_id    text references public.soundscapes (id),
  started_at       timestamptz not null,
  ended_at         timestamptz,
  duration_minutes int generated always as (
    extract(epoch from (ended_at - started_at)) / 60
  ) stored,
  avg_hr           float,
  avg_hrv          float,
  avg_spo2         float,
  sleep_score      int check (sleep_score between 0 and 100),
  created_at       timestamptz not null default now()
);

create index if not exists sleep_sessions_user_id_started_at
  on public.sleep_sessions (user_id, started_at desc);

-- ─── Sleep Stages ─────────────────────────────────────────────────────────────

create table if not exists public.sleep_stages (
  id               uuid primary key default gen_random_uuid(),
  session_id       uuid not null references public.sleep_sessions (id) on delete cascade,
  stage            text not null check (stage in ('awake', 'light', 'deep', 'rem')),
  started_at       timestamptz not null,
  ended_at         timestamptz,
  duration_seconds int generated always as (
    extract(epoch from (ended_at - started_at))
  ) stored
);

create index if not exists sleep_stages_session_id
  on public.sleep_stages (session_id);

-- ─── Biometric Events ─────────────────────────────────────────────────────────

create table if not exists public.biometric_events (
  id               uuid primary key default gen_random_uuid(),
  session_id       uuid not null references public.sleep_sessions (id) on delete cascade,
  recorded_at      timestamptz not null,
  hr               float,
  hrv              float,
  spo2             float,
  respiratory_rate float,
  motion_intensity float
);

create index if not exists biometric_events_session_id_recorded_at
  on public.biometric_events (session_id, recorded_at);

-- ─── Row Level Security ───────────────────────────────────────────────────────

alter table public.users            enable row level security;
alter table public.sleep_sessions   enable row level security;
alter table public.sleep_stages     enable row level security;
alter table public.biometric_events enable row level security;
alter table public.soundscapes      enable row level security;

-- Users: own their own row only
create policy "users: select own" on public.users
  for select using (auth.uid() = id);
create policy "users: update own" on public.users
  for update using (auth.uid() = id);

-- Sleep sessions: full CRUD on own sessions
create policy "sessions: select own" on public.sleep_sessions
  for select using (auth.uid() = user_id);
create policy "sessions: insert own" on public.sleep_sessions
  for insert with check (auth.uid() = user_id);
create policy "sessions: update own" on public.sleep_sessions
  for update using (auth.uid() = user_id);
create policy "sessions: delete own" on public.sleep_sessions
  for delete using (auth.uid() = user_id);

-- Sleep stages: access via session ownership
create policy "stages: select own" on public.sleep_stages
  for select using (
    session_id in (select id from public.sleep_sessions where user_id = auth.uid())
  );
create policy "stages: insert own" on public.sleep_stages
  for insert with check (
    session_id in (select id from public.sleep_sessions where user_id = auth.uid())
  );
create policy "stages: delete own" on public.sleep_stages
  for delete using (
    session_id in (select id from public.sleep_sessions where user_id = auth.uid())
  );

-- Biometric events: access via session ownership
create policy "biometrics: select own" on public.biometric_events
  for select using (
    session_id in (select id from public.sleep_sessions where user_id = auth.uid())
  );
create policy "biometrics: insert own" on public.biometric_events
  for insert with check (
    session_id in (select id from public.sleep_sessions where user_id = auth.uid())
  );
create policy "biometrics: delete own" on public.biometric_events
  for delete using (
    session_id in (select id from public.sleep_sessions where user_id = auth.uid())
  );

-- Soundscapes: public read (no auth required to browse), no writes from app
create policy "soundscapes: public read" on public.soundscapes
  for select using (true);
