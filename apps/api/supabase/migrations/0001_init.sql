-- Recally — skema awal (Drift tetap sumber kebenaran di perangkat).
--
-- Jalankan di Supabase SQL Editor, atau:
--   supabase db push
--
-- Semua tabel memakai user_id dan Row Level Security, sehingga anon key yang
-- dibundel di aplikasi tidak bisa membaca data pengguna lain.

create table if not exists public.decks (
  id          uuid primary key,
  user_id     uuid not null references auth.users (id) on delete cascade,
  name        text not null check (char_length(name) between 1 and 120),
  description text,
  created_at  timestamptz not null,
  updated_at  timestamptz not null,
  deleted_at  timestamptz
);

create table if not exists public.cards (
  id             uuid primary key,
  deck_id        uuid not null references public.decks (id) on delete cascade,
  user_id        uuid not null references auth.users (id) on delete cascade,
  front          text not null check (char_length(front) <= 5000),
  back           text not null check (char_length(back) <= 5000),
  due_at         timestamptz not null,
  interval_days  integer not null default 0 check (interval_days >= 0),
  ease           real not null default 2.5 check (ease between 1.3 and 3.0),
  reps           integer not null default 0,
  lapses         integer not null default 0,
  created_at     timestamptz not null,
  updated_at     timestamptz not null,
  deleted_at     timestamptz
);

-- Riwayat ulasan bersifat append-only: tidak ada policy update/delete.
create table if not exists public.reviews (
  id                  uuid primary key,
  card_id             uuid not null references public.cards (id) on delete cascade,
  user_id             uuid not null references auth.users (id) on delete cascade,
  rating              smallint not null check (rating between 0 and 2),
  reviewed_at         timestamptz not null,
  prev_interval_days  integer not null,
  new_interval_days   integer not null
);

create index if not exists decks_user_updated_idx
  on public.decks (user_id, updated_at);

create index if not exists cards_user_updated_idx
  on public.cards (user_id, updated_at);

create index if not exists cards_deck_idx
  on public.cards (deck_id);

create index if not exists reviews_user_reviewed_idx
  on public.reviews (user_id, reviewed_at);

alter table public.decks enable row level security;
alter table public.cards enable row level security;
alter table public.reviews enable row level security;

drop policy if exists "decks owned by user" on public.decks;
create policy "decks owned by user"
  on public.decks for all
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

drop policy if exists "cards owned by user" on public.cards;
create policy "cards owned by user"
  on public.cards for all
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

drop policy if exists "reviews readable by owner" on public.reviews;
create policy "reviews readable by owner"
  on public.reviews for select
  to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "reviews insertable by owner" on public.reviews;
create policy "reviews insertable by owner"
  on public.reviews for insert
  to authenticated
  with check ((select auth.uid()) = user_id);
