-- v7: fotos do enxoval entregue (todos os hotéis menos o Go Inn)
alter table public.hoteis add column if not exists foto_enxoval boolean not null default true;
update public.hoteis set foto_enxoval = false where nome = 'Go Inn';

create table if not exists public.enxoval_fotos (
  id          bigint generated always as identity primary key,
  hotel       text not null,
  apt         text not null,
  dia         date not null,
  path        text not null,
  enviado_por text,
  criado_em   timestamptz not null default now()
);
create index if not exists enxoval_fotos_dia_idx on public.enxoval_fotos (dia, hotel, apt);
alter table public.enxoval_fotos enable row level security;
drop policy if exists anon_all_enxoval_fotos on public.enxoval_fotos;
create policy anon_all_enxoval_fotos on public.enxoval_fotos for all to anon using (true) with check (true);
do $$ begin
  begin alter publication supabase_realtime add table public.enxoval_fotos; exception when duplicate_object then null; end;
end $$;

-- pasta das fotos (pode ler, enviar e apagar: o app apaga depois de baixar o .zip do mês)
insert into storage.buckets (id, name, public) values ('enxoval','enxoval', true) on conflict (id) do nothing;
drop policy if exists enxoval_ler on storage.objects;
create policy enxoval_ler on storage.objects for select to anon using (bucket_id = 'enxoval');
drop policy if exists enxoval_enviar on storage.objects;
create policy enxoval_enviar on storage.objects for insert to anon with check (bucket_id = 'enxoval');
drop policy if exists enxoval_apagar on storage.objects;
create policy enxoval_apagar on storage.objects for delete to anon using (bucket_id = 'enxoval');

select nome, foto_enxoval from public.hoteis order by ordem;
