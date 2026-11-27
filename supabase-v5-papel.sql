-- v5: quantidade de papel higiênico em cada apto
create table if not exists public.apto_itens (
  id             bigint generated always as identity primary key,
  hotel          text not null,
  apt            text not null,
  item           text not null default 'papel_higienico',
  quantidade     integer not null default 0 check (quantidade >= 0),
  atualizado_por text,
  atualizado_em  timestamptz not null default now(),
  unique (hotel, apt, item)
);
alter table public.apto_itens enable row level security;
drop policy if exists anon_all_apto_itens on public.apto_itens;
create policy anon_all_apto_itens on public.apto_itens for all to anon using (true) with check (true);
insert into public.config (chave, valor) values ('papel_minimo', 2) on conflict (chave) do nothing;
do $$ begin
  begin alter publication supabase_realtime add table public.apto_itens; exception when duplicate_object then null; end;
end $$;
select (select count(*) from public.apto_itens) itens, (select valor from public.config where chave='papel_minimo') minimo;
