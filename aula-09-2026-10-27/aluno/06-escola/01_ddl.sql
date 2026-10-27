-- Projeto 6 · Escola (notas e frequência) · 01_ddl.sql (prova 1)
-- Estrutura do banco. Pode ser executado quantas vezes quiser: apaga o schema e recria.

DROP SCHEMA IF EXISTS escola CASCADE;
CREATE SCHEMA escola;
SET search_path TO escola;

-- O ano letivo tem 4 bimestres; as datas definem o prazo de lançamento (15 dias depois do fim).
CREATE TABLE bimestre (
    id     integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ano    smallint NOT NULL,
    numero smallint NOT NULL CHECK (numero BETWEEN 1 AND 4),
    inicio date NOT NULL,
    fim    date NOT NULL,
    UNIQUE (ano, numero),
    CHECK (fim > inicio)
);

-- No aluno fica o que é permanente (a ficha, em JSONB); o que é do ano fica na matrícula.
CREATE TABLE aluno (
    id         integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome       varchar(100) NOT NULL,
    nascimento date NOT NULL CHECK (nascimento <= CURRENT_DATE),
    ficha      jsonb NOT NULL DEFAULT '{}'::jsonb
);

CREATE TABLE professor (
    id   integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome varchar(100) NOT NULL
);

CREATE TABLE disciplina (
    id   integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome varchar(60) NOT NULL UNIQUE
);

CREATE TABLE turma (
    id    integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome  varchar(30) NOT NULL,
    serie smallint NOT NULL CHECK (serie BETWEEN 1 AND 3),
    turno varchar(10) NOT NULL CHECK (turno IN ('manha', 'tarde', 'noite')),
    ano   smallint NOT NULL,
    UNIQUE (nome, ano)
);

-- Uma matrícula por aluno e ano. A turma NÃO fica aqui: a transferência é uma troca de linha em matricula_turma.
CREATE TABLE matricula (
    id       integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    numero   varchar(20) GENERATED ALWAYS AS ('MT-' || ano::text || '-' || LPAD(id::text, 6, '0')) STORED UNIQUE,
    aluno_id integer NOT NULL REFERENCES aluno (id),
    ano      smallint NOT NULL,
    status   varchar(12) NOT NULL DEFAULT 'ativa' CHECK (status IN ('ativa', 'cancelada', 'concluida')),
    UNIQUE (aluno_id, ano)
);

-- Em que turma o aluno esteve e quando (a transferência fecha uma linha e abre outra).
CREATE TABLE matricula_turma (
    id           integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    matricula_id integer NOT NULL REFERENCES matricula (id),
    turma_id     integer NOT NULL REFERENCES turma (id),
    inicio       date NOT NULL,
    fim          date,
    CHECK (fim IS NULL OR fim >= inicio)
);
CREATE UNIQUE INDEX uq_matricula_turma_aberta ON matricula_turma (matricula_id) WHERE fim IS NULL;

-- Oferta = disciplina dada em uma turma
CREATE TABLE oferta (
    id            integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    turma_id      integer NOT NULL REFERENCES turma (id),
    disciplina_id integer NOT NULL REFERENCES disciplina (id),
    aulas_semana  smallint NOT NULL CHECK (aulas_semana > 0),
    UNIQUE (turma_id, disciplina_id)
);

-- O professor da oferta tem período: trocar o professor no meio do ano fecha uma linha e abre outra (histórico preservado).
CREATE TABLE oferta_professor (
    id           integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    oferta_id    integer NOT NULL REFERENCES oferta (id),
    professor_id integer NOT NULL REFERENCES professor (id),
    inicio       date NOT NULL,
    fim          date,
    CHECK (fim IS NULL OR fim >= inicio)
);
CREATE UNIQUE INDEX uq_oferta_professor_atual ON oferta_professor (oferta_id) WHERE fim IS NULL;

-- O peso fica na avaliação (decisão 5): prova, trabalho ou participação, por oferta e bimestre.
CREATE TABLE avaliacao (
    id          integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    oferta_id   integer NOT NULL REFERENCES oferta (id),
    bimestre_id integer NOT NULL REFERENCES bimestre (id),
    nome        varchar(40) NOT NULL,
    tipo        varchar(14) NOT NULL CHECK (tipo IN ('prova', 'trabalho', 'participacao')),
    peso        numeric(4,2) NOT NULL CHECK (peso > 0),
    UNIQUE (oferta_id, bimestre_id, nome)
);

-- A nota é sobrescrita na correção; o histórico fica em historico_nota (trigger).
-- justificativa é preenchida na correção (obrigatória depois do fechamento).
CREATE TABLE nota (
    id            integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    avaliacao_id  integer NOT NULL REFERENCES avaliacao (id),
    matricula_id  integer NOT NULL REFERENCES matricula (id),
    valor         numeric(4,2) NOT NULL CHECK (valor BETWEEN 0 AND 10),
    lancada_em    timestamp NOT NULL DEFAULT LOCALTIMESTAMP,
    justificativa text,
    UNIQUE (avaliacao_id, matricula_id)
);

CREATE TABLE historico_nota (
    id            bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nota_id       integer NOT NULL,
    avaliacao_id  integer NOT NULL,
    matricula_id  integer NOT NULL,
    valor_antes   numeric(4,2),
    valor_depois  numeric(4,2),
    justificativa text,
    usuario       text NOT NULL DEFAULT current_user,
    quando        timestamp NOT NULL DEFAULT LOCALTIMESTAMP
);

-- Uma aula = uma chamada. O professor da aula fica gravado (o da oferta pode mudar).
-- A grade: o professor não pode ter duas aulas no mesmo dia e horário (última barreira no banco).
CREATE TABLE aula (
    id           integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    oferta_id    integer NOT NULL REFERENCES oferta (id),
    professor_id integer NOT NULL REFERENCES professor (id),
    data         date NOT NULL,
    horario      time NOT NULL,
    UNIQUE (oferta_id, data, horario),
    UNIQUE (professor_id, data, horario)
);

-- Uma linha por aluno e por aula (presente, ausente ou falta justificada). A justificada não conta na frequência.
CREATE TABLE frequencia (
    aula_id      integer NOT NULL REFERENCES aula (id),
    matricula_id integer NOT NULL REFERENCES matricula (id),
    situacao     varchar(12) NOT NULL CHECK (situacao IN ('presente', 'ausente', 'justificada')),
    PRIMARY KEY (aula_id, matricula_id)
);

-- O fechamento é da turma e do bimestre: depois dele, a nota só muda com justificativa.
CREATE TABLE fechamento (
    turma_id    integer NOT NULL REFERENCES turma (id),
    bimestre_id integer NOT NULL REFERENCES bimestre (id),
    fechado_em  timestamp NOT NULL DEFAULT LOCALTIMESTAMP,
    PRIMARY KEY (turma_id, bimestre_id)
);

-- Média gravada no fechamento (a nota corrigida depois atualiza esta linha pela procedure corrigir_nota).
-- A linha nasce na matrícula, «aberta» (fechado_em NULL, sem média), e é fechada por fechar_bimestre.
CREATE TABLE resultado_bimestre (
    id           integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    matricula_id integer NOT NULL REFERENCES matricula (id),
    oferta_id    integer NOT NULL REFERENCES oferta (id),
    bimestre_id  integer NOT NULL REFERENCES bimestre (id),
    media        numeric(4,2) CHECK (media BETWEEN 0 AND 10),
    completo     boolean NOT NULL DEFAULT false,
    fechado_em   timestamp,
    UNIQUE (matricula_id, oferta_id, bimestre_id)
);

-- Alerta de risco por frequência abaixo de 75% (gerado por trigger)
CREATE TABLE alerta_risco (
    id             integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    matricula_id   integer NOT NULL REFERENCES matricula (id),
    oferta_id      integer NOT NULL REFERENCES oferta (id),
    frequencia_pct numeric(5,1) NOT NULL,
    criado_em      timestamp NOT NULL DEFAULT LOCALTIMESTAMP,
    resolvido      boolean NOT NULL DEFAULT false
);
CREATE UNIQUE INDEX uq_alerta_aberto ON alerta_risco (matricula_id, oferta_id) WHERE NOT resolvido;
