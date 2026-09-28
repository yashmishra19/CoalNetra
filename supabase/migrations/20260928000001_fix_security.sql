-- 1. Role-stamping: copies role and scope onto each login
create or replace function public.sync_user_claims()
returns trigger
language plpgsql
security definer
set search_path = public, auth
as $$
begin
  update auth.users
  set raw_app_meta_data = coalesce(raw_app_meta_data, '{}'::jsonb) || jsonb_build_object(
    'role', NEW.role::text,
    'scope_type', NEW.scope_type::text,
    'scope_id', NEW.scope_id
  )
  where id = NEW.id;
  return NEW;
end;
$$;

drop trigger if exists on_user_role_change on public.users;

create trigger on_user_role_change
after insert or update of role, scope_type, scope_id on public.users
for each row execute function public.sync_user_claims();

-- 2. Mine scope: only mine managers and field officers of that mine
create or replace function public.in_mine_scope(target_mine_id uuid)
returns boolean
language plpgsql
stable
security definer
set search_path = public
as $function$
begin
  if is_mine_manager() or is_field_officer() then
    return auth_scope_type() = 'MINE' and auth_scope_id() = target_mine_id;
  end if;
  return false;
end;
$function$;

-- 3. Regulators cannot read observations, CAPAs or their photos
alter policy "CAPAs select by scope" on public.capas using (in_mine_scope (mine_id));

alter policy "Observations select by scope" on public.observations using (in_mine_scope (mine_id));

alter policy "CAPA after photos select by parent CAPA scope" on public.capa_after_photos using (
    exists (
        select 1
        from public.capas c
        where
            c.id = capa_after_photos.capa_id
            and in_mine_scope (c.mine_id)
    )
);

alter policy "Observation photos select by parent observation scope" on public.observation_photos using (
    exists (
        select 1
        from public.observations o
        where
            o.id = observation_photos.observation_id
            and in_mine_scope (o.mine_id)
    )
);

-- 4. Regulators cannot fetch photo files
alter policy "Storage media read policy by role scope" on storage.objects
  using (
    bucket_id = 'koylanetra-media'
    and in_mine_scope(((storage.foldername(name))[1])::uuid)
  );
-- 5. Regulators cannot read sections (QR/NFC tag codes)
drop policy if exists "Sections read policy by role scope" on public.sections;

drop policy if exists "Sections select by mine scope" on public.sections;

create policy "Sections select by mine scope" on public.sections for
select to authenticated using (in_mine_scope (mine_id));