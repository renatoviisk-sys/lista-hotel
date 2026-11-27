-- v6: quantos controles cada apto deveria ter (TV e ar). 0 no ar = apto sem ar.
alter table public.aptos add column if not exists controles_tv integer not null default 1 check (controles_tv >= 0);
alter table public.aptos add column if not exists controles_ar integer not null default 1 check (controles_ar >= 0);
-- a contagem de controles presentes fica em apto_itens (itens 'controle_tv' e 'controle_ar')
select count(*) aptos, sum(controles_tv) tv, sum(controles_ar) ar from public.aptos;
