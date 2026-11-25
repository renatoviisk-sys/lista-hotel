-- CADASTRO: hoteis, aptos e precos (antes ficavam escritos no codigo)
create table if not exists public.hoteis (
  nome            text primary key,
  ordem           integer not null default 99,
  sigla           text not null default '',
  pdf_nome        text not null default '',
  pdf_regex       text not null default '',
  sem_rosto       boolean not null default false,
  limpeza_propria boolean not null default false,
  ativo           boolean not null default true,
  criado_em       timestamptz not null default now()
);
create table if not exists public.aptos (
  id        bigint generated always as identity primary key,
  hotel     text not null references public.hoteis(nome) on update cascade,
  apt       text not null,
  config    text not null default 'c' check (config in ('c','2s','cs')),
  king      boolean not null default false,
  rotulo    text,
  ativo     boolean not null default true,
  criado_em timestamptz not null default now(),
  unique (hotel, apt)
);
create table if not exists public.config (
  chave text primary key,
  valor numeric not null
);
create table if not exists public.ajustes_mes (
  id     bigint generated always as identity primary key,
  mes    text not null,
  hotel  text not null,
  apt    text not null,
  valor  numeric not null default 0,
  obs    text,
  atualizado_em timestamptz not null default now(),
  unique (mes, hotel, apt)
);

alter table public.hoteis enable row level security;
drop policy if exists anon_all_hoteis on public.hoteis;
create policy anon_all_hoteis on public.hoteis for all to anon using (true) with check (true);
alter table public.aptos enable row level security;
drop policy if exists anon_all_aptos on public.aptos;
create policy anon_all_aptos on public.aptos for all to anon using (true) with check (true);
alter table public.config enable row level security;
drop policy if exists anon_all_config on public.config;
create policy anon_all_config on public.config for all to anon using (true) with check (true);
alter table public.ajustes_mes enable row level security;
drop policy if exists anon_all_ajustes_mes on public.ajustes_mes;
create policy anon_all_ajustes_mes on public.ajustes_mes for all to anon using (true) with check (true);

-- Dados atuais
insert into public.hoteis (nome,ordem,sigla,pdf_nome,pdf_regex,sem_rosto,limpeza_propria) values
  ('Comf',1,'Comf DF','Comf','\bcomf\b',false,true),
  ('Lets',2,'Lets DF','Lets','\blets\b',false,false),
  ('Kubit',3,'KUB','Kubit','\bkubit\b',false,false),
  ('Bona',4,'BON','Bona','\bbona\b',false,false),
  ('Saint',5,'STP','Saint','\bsaint\b',false,false),
  ('Ramada',6,'RAMADA','Ramada','\bramada\b',false,false),
  ('Tryp',7,'TRYP','Tryp','\btryp\b',false,false),
  ('Comft',8,'COMF TG','Comf T','comf\s*t\b|comft\b',true,false),
  ('Go Inn',9,'GO INN TG','Go Inn','go\s*inn?',true,false)
on conflict (nome) do nothing;
insert into public.aptos (hotel,apt,config,king,rotulo) values
  ('Comf','109','2s',false,null),
  ('Comf','202','cs',false,null),
  ('Comf','207','cs',false,null),
  ('Comf','811','c',false,null),
  ('Comf','1014','cs',false,null),
  ('Comf','1102','c',false,null),
  ('Comf','1111','c',false,null),
  ('Comf','1301','cs',false,null),
  ('Lets','506','c',true,null),
  ('Lets','913','2s',false,null),
  ('Lets','1301','c',true,null),
  ('Lets','1407','c',false,null),
  ('Kubit','113','c',false,null),
  ('Kubit','117','c',false,null),
  ('Kubit','305','c',false,null),
  ('Kubit','519','c',false,'KUB 519 + 306'),
  ('Bona','618','c',false,null),
  ('Bona','702','c',false,null),
  ('Saint','411','cs',false,null),
  ('Saint','815','c',false,null),
  ('Saint','1215','c',false,null),
  ('Ramada','517','2s',false,null),
  ('Ramada','1214','2s',false,null),
  ('Tryp','06','c',true,null),
  ('Tryp','105','c',true,null),
  ('Tryp','207','c',true,null),
  ('Tryp','1210','2s',false,null),
  ('Tryp','1302','2s',false,null),
  ('Tryp','1304','2s',false,null),
  ('Tryp','1308','c',false,null),
  ('Comft','106','c',false,null),
  ('Comft','109','cs',false,null),
  ('Comft','111','2s',false,null),
  ('Comft','114','c',false,null),
  ('Comft','206','c',true,null),
  ('Comft','305','cs',false,null),
  ('Comft','310','c',false,null),
  ('Comft','311','2s',false,null),
  ('Comft','316','c',false,null),
  ('Comft','407','2s',false,null),
  ('Comft','607','2s',false,null),
  ('Comft','614','c',false,null),
  ('Comft','705','c',true,null),
  ('Comft','710','c',false,null),
  ('Comft','803','c',false,null),
  ('Comft','809','c',false,null),
  ('Comft','810','cs',false,null),
  ('Comft','1007','cs',false,null),
  ('Go Inn','101','c',false,null),
  ('Go Inn','114','c',false,null),
  ('Go Inn','117','2s',false,null),
  ('Go Inn','119','c',false,null),
  ('Go Inn','207','2s',false,null),
  ('Go Inn','210','2s',false,null),
  ('Go Inn','305','cs',false,null),
  ('Go Inn','308','2s',false,null),
  ('Go Inn','310','2s',false,null),
  ('Go Inn','313','2s',false,null),
  ('Go Inn','408','2s',false,null),
  ('Go Inn','411','c',false,null),
  ('Go Inn','413','cs',false,null),
  ('Go Inn','418','c',false,null),
  ('Go Inn','503','c',false,null),
  ('Go Inn','506','c',false,null),
  ('Go Inn','509','c',false,null),
  ('Go Inn','512','c',false,null),
  ('Go Inn','515','2s',false,null),
  ('Go Inn','516','c',false,null),
  ('Go Inn','517','c',false,null),
  ('Go Inn','519','c',false,null),
  ('Go Inn','603','c',false,null),
  ('Go Inn','605','cs',false,null),
  ('Go Inn','609','cs',false,null),
  ('Go Inn','610','2s',false,null),
  ('Go Inn','611','c',false,null),
  ('Go Inn','617','c',false,null),
  ('Go Inn','703','cs',false,null),
  ('Go Inn','708','c',false,null),
  ('Go Inn','715','c',false,null),
  ('Go Inn','806','c',false,null),
  ('Go Inn','815','c',false,null),
  ('Go Inn','906','c',false,null),
  ('Go Inn','909','c',false,null),
  ('Go Inn','913','2s',false,null),
  ('Go Inn','914','c',false,null)
on conflict (hotel,apt) do nothing;
insert into public.config (chave,valor) values ('admin_por_apto',230),('troca_enxoval',8.5),('limpeza',25)
on conflict (chave) do nothing;
do $$ begin
  begin alter publication supabase_realtime add table public.hoteis; exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table public.aptos; exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table public.config; exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table public.ajustes_mes; exception when duplicate_object then null; end;
end $$;
select (select count(*) from public.hoteis) hoteis, (select count(*) from public.aptos) aptos, (select count(*) from public.config) config;
