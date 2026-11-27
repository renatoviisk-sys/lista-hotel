-- v4: quem registrou, histórico de ações, PIN e fotos dos reparos

-- de onde veio cada troca/limpeza (pdf ou manual) e quem registrou
alter table public.trocas   add column if not exists origem text default 'pdf';
alter table public.trocas   add column if not exists registrado_por text;
alter table public.limpezas add column if not exists origem text default 'pdf';
alter table public.limpezas add column if not exists registrado_por text;

-- fotos dos reparos (caminho no Storage)
alter table public.manutencoes add column if not exists foto_antes text;
alter table public.manutencoes add column if not exists foto_depois text;

-- histórico de ações (só inserir e ler; ninguém apaga pelo app)
create table if not exists public.registro_acoes (
  id      bigint generated always as identity primary key,
  quando  timestamptz not null default now(),
  quem    text,
  acao    text not null,
  detalhe text
);
alter table public.registro_acoes enable row level security;
drop policy if exists anon_ler_registro on public.registro_acoes;
create policy anon_ler_registro on public.registro_acoes for select to anon using (true);
drop policy if exists anon_inserir_registro on public.registro_acoes;
create policy anon_inserir_registro on public.registro_acoes for insert to anon with check (true);

-- configurações de texto (ex.: PIN guardado como hash)
create table if not exists public.config_texto (
  chave text primary key,
  valor text not null
);
alter table public.config_texto enable row level security;
drop policy if exists anon_all_config_texto on public.config_texto;
create policy anon_all_config_texto on public.config_texto for all to anon using (true) with check (true);

-- Storage: pasta pública para as fotos dos reparos
insert into storage.buckets (id, name, public) values ('reparos','reparos', true)
on conflict (id) do nothing;
drop policy if exists reparos_ler on storage.objects;
create policy reparos_ler on storage.objects for select to anon using (bucket_id = 'reparos');
drop policy if exists reparos_enviar on storage.objects;
create policy reparos_enviar on storage.objects for insert to anon with check (bucket_id = 'reparos');

select (select count(*) from information_schema.columns where table_name='trocas' and column_name in ('origem','registrado_por')) col_trocas,
       (select count(*) from storage.buckets where id='reparos') bucket;
