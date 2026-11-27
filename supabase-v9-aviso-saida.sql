-- v9: permite dispensar o aviso de 'possível saída não registrada'
alter table public.entradas add column if not exists sem_saida_ok boolean not null default false;
