-- Projeto 4 · Academia · 01_ddl.sql (prova 1)
-- Estrutura do banco. Pode ser executado quantas vezes quiser: apaga o schema e recria.

DROP SCHEMA IF EXISTS academia CASCADE;
CREATE SCHEMA academia;
SET search_path TO academia;

CREATE TABLE modalidade (
    id   integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome varchar(40) NOT NULL UNIQUE
);

CREATE TABLE plano (
    id    integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome  varchar(40) NOT NULL UNIQUE,
    meses smallint NOT NULL CHECK (meses IN (1, 3, 12))       -- mensal, trimestral ou anual
);

-- Quais modalidades cada plano inclui: o básico só musculação, o completo também as aulas coletivas.
CREATE TABLE plano_modalidade (
    plano_id      integer NOT NULL REFERENCES plano (id),
    modalidade_id integer NOT NULL REFERENCES modalidade (id),
    PRIMARY KEY (plano_id, modalidade_id)
);

-- O valor MENSAL do plano muda com o tempo: cada linha vale a partir de vigencia_inicio (histórico preservado).
CREATE TABLE preco_plano (
    id              integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    plano_id        integer NOT NULL REFERENCES plano (id),
    valor_mensal    numeric(8,2) NOT NULL CHECK (valor_mensal > 0),
    vigencia_inicio date NOT NULL,
    UNIQUE (plano_id, vigencia_inicio)
);

CREATE TABLE aluno (
    id              integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome            varchar(100) NOT NULL,
    email           varchar(100) NOT NULL UNIQUE,
    nascimento      date NOT NULL CHECK (nascimento <= CURRENT_DATE),
    dia_vencimento  smallint NOT NULL DEFAULT 10 CHECK (dia_vencimento BETWEEN 1 AND 28)
);

-- Aluno e matrícula são tabelas separadas: o aluno pode voltar depois com uma NOVA matrícula (o histórico fica).
-- O valor mensal é gravado na matrícula (valor do dia em que se matriculou).
CREATE TABLE matricula (
    id             integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    numero         varchar(10) GENERATED ALWAYS AS ('AC-' || LPAD(id::text, 6, '0')) STORED UNIQUE,
    aluno_id       integer NOT NULL REFERENCES aluno (id),
    plano_id       integer NOT NULL REFERENCES plano (id),
    valor_mensal   numeric(8,2) NOT NULL CHECK (valor_mensal > 0),
    inicio         date NOT NULL,
    fim            date NOT NULL,
    status         varchar(10) NOT NULL DEFAULT 'ativa'
                   CHECK (status IN ('ativa', 'trancada', 'vencida', 'cancelada')),
    dias_trancados smallint NOT NULL DEFAULT 0 CHECK (dias_trancados BETWEEN 0 AND 30),
    CHECK (fim > inicio)
);

-- Um aluno só tem uma matrícula ativa ou trancada por vez
CREATE UNIQUE INDEX uq_matricula_aberta_por_aluno ON matricula (aluno_id) WHERE status IN ('ativa', 'trancada');

-- Todas as mensalidades são geradas na matrícula (uma por mês). A inadimplência NÃO é uma coluna:
-- calcula-se a partir do vencimento e da existência do pagamento.
CREATE TABLE mensalidade (
    id           integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    matricula_id integer NOT NULL REFERENCES matricula (id),
    competencia  date NOT NULL CHECK (EXTRACT(DAY FROM competencia) = 1),
    vencimento   date NOT NULL,
    valor        numeric(8,2) NOT NULL CHECK (valor > 0),
    UNIQUE (matricula_id, competencia)
);

CREATE TABLE pagamento (
    id            integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    mensalidade_id integer NOT NULL UNIQUE REFERENCES mensalidade (id),
    pago_em       date NOT NULL,
    valor_base    numeric(8,2) NOT NULL CHECK (valor_base > 0),
    multa         numeric(8,2) NOT NULL DEFAULT 0 CHECK (multa >= 0),
    juros         numeric(8,2) NOT NULL DEFAULT 0 CHECK (juros >= 0),
    valor_pago    numeric(8,2) NOT NULL,
    forma         varchar(10) NOT NULL DEFAULT 'pix' CHECK (forma IN ('pix', 'cartao', 'dinheiro')),
    CHECK (valor_pago = valor_base + multa + juros)
);

CREATE TABLE instrutor (
    id   integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome varchar(100) NOT NULL,
    cref varchar(20) NOT NULL UNIQUE
);

CREATE TABLE instrutor_modalidade (
    instrutor_id  integer NOT NULL REFERENCES instrutor (id),
    modalidade_id integer NOT NULL REFERENCES modalidade (id),
    PRIMARY KEY (instrutor_id, modalidade_id)
);

CREATE TABLE turma (
    id            integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    modalidade_id integer NOT NULL REFERENCES modalidade (id),
    instrutor_id  integer NOT NULL REFERENCES instrutor (id),
    dia_semana    smallint NOT NULL CHECK (dia_semana BETWEEN 0 AND 6),   -- 0 = domingo
    hora_inicio   time NOT NULL,
    duracao_min   smallint NOT NULL DEFAULT 50 CHECK (duracao_min > 0),
    capacidade    smallint NOT NULL CHECK (capacidade > 0)
);

-- Reserva por data da aula. As vagas ocupadas NÃO são uma coluna: contam-se as reservas confirmadas.
-- A lista de espera é a ordem de criada_em (e id) entre as reservas 'espera' da mesma turma e data.
CREATE TABLE reserva (
    id         integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    aluno_id   integer NOT NULL REFERENCES aluno (id),
    turma_id   integer NOT NULL REFERENCES turma (id),
    data_aula  date NOT NULL,
    criada_em  timestamp NOT NULL DEFAULT LOCALTIMESTAMP,
    situacao   varchar(10) NOT NULL DEFAULT 'confirmada'
               CHECK (situacao IN ('confirmada', 'espera', 'cancelada', 'presente', 'faltou'))
);

-- Uma reserva por aluno, turma e data (a cancelada não conta, para o aluno poder reservar de novo)
CREATE UNIQUE INDEX uq_reserva_ativa ON reserva (aluno_id, turma_id, data_aula) WHERE situacao <> 'cancelada';

-- Um registro por visita (entrada e saída); quem está dentro agora tem saida NULL.
CREATE TABLE acesso (
    id        bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    aluno_id  integer NOT NULL REFERENCES aluno (id),
    entrada   timestamp NOT NULL DEFAULT LOCALTIMESTAMP,
    saida     timestamp,
    CHECK (saida IS NULL OR saida > entrada)
);

-- O IMC não é gravado: calcula-se de peso e altura.
CREATE TABLE avaliacao_fisica (
    id              integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    aluno_id        integer NOT NULL REFERENCES aluno (id),
    data            date NOT NULL DEFAULT CURRENT_DATE,
    peso_kg         numeric(5,2) NOT NULL CHECK (peso_kg > 0),
    altura_m        numeric(3,2) NOT NULL CHECK (altura_m BETWEEN 0.5 AND 2.5),
    dados_avaliacao jsonb NOT NULL DEFAULT '{}'::jsonb
);

-- Auditoria do status da matrícula (preenchida por trigger, arquivo 09)
CREATE TABLE auditoria_matricula (
    id             bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    matricula_id   integer NOT NULL,
    status_antes   varchar(10),
    status_depois  varchar(10),
    usuario        text NOT NULL DEFAULT current_user,
    quando         timestamptz NOT NULL DEFAULT now()
);
