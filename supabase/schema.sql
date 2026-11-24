-- Ascend account, cloud-save, and friends schema
-- Run this in the SQL Editor of the SEPARATE Ascend Supabase project.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text not null unique,
  display_name text not null default '',
  total_xp bigint not null default 0 check (total_xp >= 0),
  rank_name text not null default 'Starter',
  rank_division text not null default 'I' check (rank_division in ('I','II','III','IV')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint username_format check (username = lower(username) and username ~ '^[a-z0-9_]{3,20}$')
);

create table if not exists public.player_data (
  user_id uuid primary key references auth.users(id) on delete cascade,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

create table if not exists public.friend_requests (
  id uuid primary key default gen_random_uuid(),
  sender_id uuid not null references auth.users(id) on delete cascade,
  receiver_id uuid not null references auth.users(id) on delete cascade,
  status text not null default 'pending' check (status in ('pending','accepted','declined','cancelled')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint no_self_friend_request check (sender_id <> receiver_id)
);

create unique index if not exists friend_requests_one_pending_pair
  on public.friend_requests (least(sender_id, receiver_id), greatest(sender_id, receiver_id))
  where status = 'pending';

create table if not exists public.friendships (
  user_a uuid not null references auth.users(id) on delete cascade,
  user_b uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_a, user_b),
  constraint friendship_order check (user_a < user_b)
);

create index if not exists profiles_username_lookup on public.profiles (username);
create index if not exists friend_requests_receiver_status on public.friend_requests (receiver_id, status);
create index if not exists friend_requests_sender_status on public.friend_requests (sender_id, status);

create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at before update on public.profiles
for each row execute function public.set_updated_at();

drop trigger if exists player_data_set_updated_at on public.player_data;
create trigger player_data_set_updated_at before update on public.player_data
for each row execute function public.set_updated_at();

drop trigger if exists friend_requests_set_updated_at on public.friend_requests;
create trigger friend_requests_set_updated_at before update on public.friend_requests
for each row execute function public.set_updated_at();

-- Create a profile automatically when someone signs up.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  requested_username text;
begin
  requested_username := lower(coalesce(new.raw_user_meta_data ->> 'username', ''));
  if requested_username !~ '^[a-z0-9_]{3,20}$' then
    requested_username := 'player_' || substr(replace(new.id::text, '-', ''), 1, 12);
  end if;

  insert into public.profiles (id, username, display_name)
  values (new.id, requested_username, coalesce(new.raw_user_meta_data ->> 'display_name', ''));

  insert into public.player_data (user_id, data) values (new.id, '{}'::jsonb);
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

-- When a request is accepted, create a canonical friendship pair.
create or replace function public.sync_accepted_friendship()
returns trigger language plpgsql security definer set search_path = ''
as $$
begin
  if new.status = 'accepted' and old.status is distinct from 'accepted' then
    insert into public.friendships (user_a, user_b)
    values (least(new.sender_id, new.receiver_id), greatest(new.sender_id, new.receiver_id))
    on conflict do nothing;
  elsif new.status in ('declined','cancelled') and old.status = 'accepted' then
    delete from public.friendships
    where user_a = least(new.sender_id, new.receiver_id)
      and user_b = greatest(new.sender_id, new.receiver_id);
  end if;
  return new;
end;
$$;

drop trigger if exists friend_request_sync_friendship on public.friend_requests;
create trigger friend_request_sync_friendship
after update of status on public.friend_requests
for each row execute function public.sync_accepted_friendship();

alter table public.profiles enable row level security;
alter table public.player_data enable row level security;
alter table public.friend_requests enable row level security;
alter table public.friendships enable row level security;

-- Authenticated users can find profiles by username and see only public rank fields.
grant select (id, username, display_name, total_xp, rank_name, rank_division, created_at)
on public.profiles to authenticated;
grant insert (id, username, display_name)
on public.profiles to authenticated;
grant update (username, display_name)
on public.profiles to authenticated;
grant select, insert, update, delete on public.player_data to authenticated;
grant select, insert, update, delete on public.friend_requests to authenticated;
grant select, delete on public.friendships to authenticated;

drop policy if exists "Signed-in users can find public profiles" on public.profiles;
create policy "Signed-in users can find public profiles"
on public.profiles for select to authenticated using (true);

drop policy if exists "Users can create their own profile" on public.profiles;
create policy "Users can create their own profile"
on public.profiles for insert to authenticated with check (auth.uid() = id);

drop policy if exists "Users can edit their own profile" on public.profiles;
create policy "Users can edit their own profile"
on public.profiles for update to authenticated
using (auth.uid() = id) with check (auth.uid() = id);

drop policy if exists "Users can read their own player data" on public.player_data;
create policy "Users can read their own player data"
on public.player_data for select to authenticated using (auth.uid() = user_id);

drop policy if exists "Users can create their own player data" on public.player_data;
create policy "Users can create their own player data"
on public.player_data for insert to authenticated with check (auth.uid() = user_id);

drop policy if exists "Users can update their own player data" on public.player_data;
create policy "Users can update their own player data"
on public.player_data for update to authenticated
using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "Users can delete their own player data" on public.player_data;
create policy "Users can delete their own player data"
on public.player_data for delete to authenticated using (auth.uid() = user_id);

drop policy if exists "Users can read requests they participate in" on public.friend_requests;
create policy "Users can read requests they participate in"
on public.friend_requests for select to authenticated
using (auth.uid() = sender_id or auth.uid() = receiver_id);

drop policy if exists "Users can send requests as themselves" on public.friend_requests;
create policy "Users can send requests as themselves"
on public.friend_requests for insert to authenticated
with check (auth.uid() = sender_id and sender_id <> receiver_id and status = 'pending');

drop policy if exists "Receiver can respond to a pending request" on public.friend_requests;
create policy "Receiver can respond to a pending request"
on public.friend_requests for update to authenticated
using (auth.uid() = receiver_id and status = 'pending')
with check (auth.uid() = receiver_id and status in ('accepted','declined'));

drop policy if exists "Sender can cancel a pending request" on public.friend_requests;
create policy "Sender can cancel a pending request"
on public.friend_requests for update to authenticated
using (auth.uid() = sender_id and status = 'pending')
with check (auth.uid() = sender_id and status = 'cancelled');

drop policy if exists "Friends can view their friendship rows" on public.friendships;
create policy "Friends can view their friendship rows"
on public.friendships for select to authenticated
using (auth.uid() = user_a or auth.uid() = user_b);

drop policy if exists "Either friend can remove the friendship" on public.friendships;
create policy "Either friend can remove the friendship"
on public.friendships for delete to authenticated
using (auth.uid() = user_a or auth.uid() = user_b);

-- No direct client insert/update policy on friendships: acceptance trigger owns creation.
