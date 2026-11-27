-- v8: chegadas de cada PDF (para saber quem está in-house)
create table if not exists public.entradas (
  id        bigint generated always as identity primary key,
  hotel     text not null,
  apt       text not null,
  dia       date not null,
  hospede   text,
  pessoas   integer,
  criado_em timestamptz not null default now(),
  unique (hotel, apt, dia)
);
alter table public.entradas enable row level security;
drop policy if exists anon_all_entradas on public.entradas;
create policy anon_all_entradas on public.entradas for all to anon using (true) with check (true);
do $$ begin
  begin alter publication supabase_realtime add table public.entradas; exception when duplicate_object then null; end;
end $$;
-- trocas.origem passa a ter também 'inhouse' (troca de enxoval a cada 3 dias com hóspede no apto)
select count(*) entradas from public.entradas;
