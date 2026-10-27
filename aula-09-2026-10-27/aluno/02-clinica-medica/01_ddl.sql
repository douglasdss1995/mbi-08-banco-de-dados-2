-- Projeto 2 · Clínica médica · 01_ddl.sql (prova 1)
-- Dois schemas: clinica (agenda e cadastro) e prontuario (dados sensíveis, separados de propósito).
-- Pode ser executado quantas vezes quiser: apaga os schemas e recria.

DROP SCHEMA IF EXISTS prontuario CASCADE;
DROP SCHEMA IF EXISTS clinica CASCADE;
CREATE SCHEMA clinica;
CREATE SCHEMA prontuario;
SET search_path TO clinica, prontuario;

CREATE TABLE especialidade (
    id   integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome varchar(60) NOT NULL UNIQUE
);

CREATE TABLE medico (
    id    integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome  varchar(100) NOT NULL,
    crm   varchar(15) NOT NULL UNIQUE,
    sexo  char(1) NOT NULL CHECK (sexo IN ('M', 'F')),   -- só para o título Dr./Dra.
    ativo boolean NOT NULL DEFAULT true
);

CREATE TABLE medico_especialidade (
    medico_id        integer NOT NULL REFERENCES medico (id),
    especialidade_id integer NOT NULL REFERENCES especialidade (id),
    PRIMARY KEY (medico_id, especialidade_id)
);

CREATE TABLE convenio (
    id                   integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome                 varchar(60) NOT NULL UNIQUE,
    percentual_cobertura numeric(5,2) NOT NULL CHECK (percentual_cobertura BETWEEN 0 AND 100)
);

CREATE TABLE paciente (
    id          integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome        varchar(100) NOT NULL,
    nascimento  date NOT NULL CHECK (nascimento <= CURRENT_DATE),
    convenio_id integer REFERENCES convenio (id)    -- NULL = particular
);

CREATE TABLE tipo_consulta (
    id          integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome        varchar(40) NOT NULL UNIQUE,
    duracao_min smallint NOT NULL CHECK (duracao_min > 0),
    valor       numeric(8,2) NOT NULL CHECK (valor >= 0)
);

-- Agenda semanal: um médico pode ter vários intervalos no mesmo dia (manhã e tarde).
CREATE TABLE horario_atendimento (
    id         integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    medico_id  integer NOT NULL REFERENCES medico (id),
    dia_semana smallint NOT NULL CHECK (dia_semana BETWEEN 0 AND 6),   -- 0 = domingo
    inicio     time NOT NULL,
    fim        time NOT NULL,
    CHECK (fim > inicio)
);

CREATE TABLE bloqueio_agenda (
    id        integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    medico_id integer NOT NULL REFERENCES medico (id),
    inicio    timestamp NOT NULL,
    fim       timestamp NOT NULL,
    motivo    varchar(80) NOT NULL,
    CHECK (fim > inicio)
);

-- A consulta é o horário marcado. Guarda o convênio e o valor de tabela do dia em que foi marcada
-- (o convênio do paciente e a tabela de valores podem mudar depois).
-- Conflito de horário: SEM restrição no banco (D-26); quem impede é a procedure agendar_consulta.
CREATE TABLE consulta (
    id             integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    protocolo      varchar(20) GENERATED ALWAYS AS
                   ('CL-' || EXTRACT(YEAR FROM inicio)::int::text || '-' || LPAD(id::text, 6, '0')) STORED UNIQUE,
    paciente_id    integer NOT NULL REFERENCES paciente (id),
    medico_id      integer NOT NULL REFERENCES medico (id),
    tipo_id        integer NOT NULL REFERENCES tipo_consulta (id),
    convenio_id    integer REFERENCES convenio (id),
    inicio         timestamp NOT NULL,
    fim            timestamp NOT NULL,
    valor_tabela   numeric(8,2) NOT NULL CHECK (valor_tabela >= 0),
    status         varchar(12) NOT NULL DEFAULT 'agendada'
                   CHECK (status IN ('agendada', 'confirmada', 'realizada', 'cancelada', 'faltou')),
    cancelada_em   timestamp,
    CHECK (fim > inicio),
    CHECK ((status = 'cancelada') = (cancelada_em IS NOT NULL))
);

CREATE TABLE pagamento (
    id             integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    consulta_id    integer NOT NULL UNIQUE REFERENCES consulta (id),
    valor_total    numeric(8,2) NOT NULL CHECK (valor_total >= 0),
    valor_convenio numeric(8,2) NOT NULL DEFAULT 0 CHECK (valor_convenio >= 0),
    valor_paciente numeric(8,2) NOT NULL CHECK (valor_paciente >= 0),
    situacao       varchar(10) NOT NULL DEFAULT 'pendente'
                   CHECK (situacao IN ('pendente', 'pago', 'isento')),
    CHECK (valor_convenio + valor_paciente = valor_total)
);

-- ===== schema prontuario: só o médico do atendimento vê o conteúdo completo (regra documentada no README) =====
CREATE TABLE prontuario.atendimento (
    id              integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    consulta_id     integer NOT NULL UNIQUE REFERENCES clinica.consulta (id),
    anamnese        text NOT NULL,
    diagnostico_cid varchar(10),
    dados_clinicos  jsonb NOT NULL DEFAULT '{}'::jsonb
);

CREATE TABLE prontuario.prescricao (
    id             integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    atendimento_id integer NOT NULL REFERENCES prontuario.atendimento (id),
    medicamento    varchar(80) NOT NULL,
    posologia      varchar(120) NOT NULL
);

CREATE TABLE prontuario.exame_solicitado (
    id             integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    atendimento_id integer NOT NULL REFERENCES prontuario.atendimento (id),
    exame          varchar(80) NOT NULL
);

CREATE TABLE prontuario.auditoria_atendimento (
    id             bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    atendimento_id integer NOT NULL,
    operacao       varchar(6) NOT NULL,
    usuario        text NOT NULL DEFAULT current_user,
    quando         timestamptz NOT NULL DEFAULT now(),
    antes          jsonb,
    depois         jsonb
);
