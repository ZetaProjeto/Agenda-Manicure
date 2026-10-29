-- Execute UMA vez no SQL Editor do Supabase.
-- Horários de 1 hora, segunda a sábado, 09:00-17:00 (último início).
create table if not exists public.agendamentos (
 id uuid primary key default gen_random_uuid(),
 data date not null,
 horario time without time zone not null,
 nome varchar(90) not null,
 telefone varchar(13) not null,
 servico varchar(90) not null,
 observacao varchar(250) not null default '',
 criado_em timestamptz not null default now(),
 constraint agendamento_unico unique(data,horario)
);
alter table public.agendamentos enable row level security;
revoke all on public.agendamentos from anon, authenticated;
-- Somente horários são expostos; os dados pessoais continuam privados.
create or replace function public.horarios_ocupados(p_data date)
returns table(horario text)
language sql security definer set search_path = '' stable
as $$ select to_char(a.horario, 'HH24:MI') as horario
 from public.agendamentos a where a.data = p_data order by a.horario $$;
revoke all on function public.horarios_ocupados(date) from public;
grant execute on function public.horarios_ocupados(date) to anon, authenticated;

create or replace function public.criar_agendamento(
 p_data date,p_horario text,p_nome text,p_telefone text,p_servico text,p_observacao text default ''
) returns uuid
language plpgsql security definer set search_path = ''
as $$
declare v_id uuid;v_today date;v_hora time;
begin
 v_today := (now() at time zone 'America/Sao_Paulo')::date;
 if p_data is null or p_data < v_today or p_data > v_today + 60 or extract(isodow from p_data)=7 then
  raise exception 'DATA_INVALIDA';
 end if;
 if p_horario !~ '^(09|10|11|12|13|14|15|16|17):00$' then raise exception 'HORARIO_INVALIDO'; end if;
 v_hora:=p_horario::time;
 if p_data=v_today and v_hora <= (now() at time zone 'America/Sao_Paulo')::time then
  raise exception 'HORARIO_PASSADO';
 end if;
 if length(btrim(coalesce(p_nome,''))) not between 3 and 90
 or coalesce(p_telefone,'') !~ '^[0-9]{10,13}$'
 or length(btrim(coalesce(p_servico,''))) not between 2 and 90
 or length(coalesce(p_observacao,''))>250 then raise exception 'DADOS_INVALIDOS';end if;
 begin
 insert into public.agendamentos(data,horario,nome,telefone,servico,observacao)
 values(p_data,v_hora,btrim(p_nome),p_telefone,btrim(p_servico),coalesce(p_observacao,'')) returning id into v_id;
 exception when unique_violation then raise exception 'HORARIO_OCUPADO';end;
 return v_id;
end;$$;
revoke all on function public.criar_agendamento(date,text,text,text,text,text) from public;
grant execute on function public.criar_agendamento(date,text,text,text,text,text) to anon, authenticated;
-- Para consultar e gerenciar dados completos: use o Table Editor no painel Supabase,
-- nunca distribua uma chave service_role no site público.
