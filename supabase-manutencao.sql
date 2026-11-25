-- ════════════════════════════════════════════════════════════════
-- MANUTENÇÃO: reparos por apartamento + estoque de peças
-- Rodar uma vez no SQL Editor do Supabase.
-- ════════════════════════════════════════════════════════════════

-- Peças do estoque de manutenção (tampa de privada, pilha, lâmpada...)
create table if not exists public.manut_itens (
  id          bigint generated always as identity primary key,
  nome        text not null unique,
  quantidade  integer not null default 0 check (quantidade >= 0),
  minimo      integer not null default 0 check (minimo >= 0),
  criado_em   timestamptz not null default now()
);

-- Reparos: o que precisa arrumar, quem pediu, quando, e quando foi resolvido
create table if not exists public.manutencoes (
  id             bigint generated always as identity primary key,
  hotel          text not null,
  apt            text not null,
  descricao      text not null,
  solicitado_por text not null,
  solicitado_em  date not null default current_date,
  resolvido_por  text,
  resolvido_em   date,
  obs_resolucao  text,
  item_id        bigint references public.manut_itens(id) on delete set null,
  item_qtd       integer not null default 0,
  criado_em      timestamptz not null default now()
);
create index if not exists manutencoes_pendentes_idx on public.manutencoes (resolvido_em, hotel, apt);

-- Mesmo modelo de acesso das outras tabelas do app (acesso pelo link)
alter table public.manut_itens enable row level security;
alter table public.manutencoes enable row level security;
drop policy if exists anon_all_manut_itens on public.manut_itens;
create policy anon_all_manut_itens on public.manut_itens for all to anon using (true) with check (true);
drop policy if exists anon_all_manutencoes on public.manutencoes;
create policy anon_all_manutencoes on public.manutencoes for all to anon using (true) with check (true);

-- Soma/subtrai peças sem deixar negativo (atômico)
create or replace function public.adjust_manut_item(p_id bigint, p_delta integer)
returns integer language plpgsql as $$
declare v integer;
begin
  update public.manut_itens set quantidade = greatest(0, quantidade + p_delta)
   where id = p_id returning quantidade into v;
  return v;
end; $$;

-- Marca como resolvido e, se usou peça, desconta do estoque (tudo junto)
create or replace function public.resolver_manutencao(
  p_id bigint, p_por text, p_em date, p_obs text, p_item bigint, p_qtd integer)
returns boolean language plpgsql as $$
begin
  update public.manutencoes
     set resolvido_por = p_por, resolvido_em = p_em, obs_resolucao = nullif(p_obs,''),
         item_id = p_item, item_qtd = coalesce(p_qtd,0)
   where id = p_id and resolvido_em is null;
  if not found then return false; end if;
  if p_item is not null and coalesce(p_qtd,0) > 0 then
    update public.manut_itens set quantidade = greatest(0, quantidade - p_qtd) where id = p_item;
  end if;
  return true;
end; $$;

-- Reabre um reparo e devolve a peça que tinha sido descontada
create or replace function public.reabrir_manutencao(p_id bigint)
returns boolean language plpgsql as $$
declare r public.manutencoes%rowtype;
begin
  select * into r from public.manutencoes where id = p_id and resolvido_em is not null;
  if not found then return false; end if;
  if r.item_id is not null and r.item_qtd > 0 then
    update public.manut_itens set quantidade = quantidade + r.item_qtd where id = r.item_id;
  end if;
  update public.manutencoes
     set resolvido_por = null, resolvido_em = null, obs_resolucao = null, item_id = null, item_qtd = 0
   where id = p_id;
  return true;
end; $$;

-- Itens iniciais
insert into public.manut_itens (nome) values
  ('Tampa de privada'), ('Pilha AA'), ('Pilha AAA'), ('Lâmpada'), ('Controle universal')
on conflict (nome) do nothing;

-- Tempo real
do $$ begin
  begin alter publication supabase_realtime add table public.manut_itens; exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table public.manutencoes; exception when duplicate_object then null; end;
end $$;

select 'ok' as status, (select count(*) from public.manut_itens) as itens;
