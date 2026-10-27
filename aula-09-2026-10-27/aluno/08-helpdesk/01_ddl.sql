-- Projeto 8 · Sistema de chamados (helpdesk) · 01_ddl.sql (prova 1)
-- Estrutura do banco. Pode ser executado quantas vezes quiser: apaga o schema e recria.

DROP SCHEMA IF EXISTS helpdesk CASCADE;
CREATE SCHEMA helpdesk;
SET search_path TO helpdesk;

CREATE TABLE setor (
    id   integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome varchar(40) NOT NULL UNIQUE
);

CREATE TABLE solicitante (
    id       integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome     varchar(100) NOT NULL,
    email    varchar(100) NOT NULL UNIQUE,
    setor_id integer NOT NULL REFERENCES setor (id)
);

CREATE TABLE categoria (
    id   integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome varchar(40) NOT NULL UNIQUE
);

-- Cada categoria tem uma fila em cada nível: N1 (triagem) e N2 (especialistas).
-- Escalar um chamado é trocar o fila_id do chamado de N1 para N2 (regra descrita, sem rotina: D-22).
CREATE TABLE fila (
    id           integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    categoria_id integer NOT NULL REFERENCES categoria (id),
    nivel        varchar(2) NOT NULL CHECK (nivel IN ('N1', 'N2')),
    UNIQUE (categoria_id, nivel)
);

CREATE TABLE atendente (
    id    integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome  varchar(100) NOT NULL,
    nivel varchar(2) NOT NULL CHECK (nivel IN ('N1', 'N2'))
);

-- Um atendente pode atender mais de uma fila
CREATE TABLE atendente_fila (
    atendente_id integer NOT NULL REFERENCES atendente (id),
    fila_id      integer NOT NULL REFERENCES fila (id),
    PRIMARY KEY (atendente_id, fila_id)
);

-- Os prazos de SLA (em horas corridas) mudam com o tempo: cada linha vale a partir de vigencia_inicio.
CREATE TABLE sla (
    id               integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    prioridade       varchar(8) NOT NULL CHECK (prioridade IN ('baixa', 'media', 'alta', 'critica')),
    horas_resposta   integer NOT NULL CHECK (horas_resposta > 0),
    horas_resolucao  integer NOT NULL CHECK (horas_resolucao >= horas_resposta),
    vigencia_inicio  date NOT NULL,
    UNIQUE (prioridade, vigencia_inicio)
);

CREATE TABLE ativo (
    id         integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    patrimonio varchar(12) NOT NULL UNIQUE,
    tipo       varchar(20) NOT NULL,
    modelo     varchar(40) NOT NULL,
    setor_id   integer NOT NULL REFERENCES setor (id)
);

-- Os prazos são GRAVADOS no chamado na abertura (com o SLA vigente naquele dia) e empurrados quando o chamado fica
-- aguardando o solicitante. Mudar a regra do SLA depois não muda chamados já abertos.
-- Reabertura: o próprio chamado volta a «em_atendimento»; depois de 5 dias abre-se um novo, ligado pelo chamado_origem_id.
CREATE TABLE chamado (
    id                  integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    numero              varchar(20) GENERATED ALWAYS AS
                        ('CH-' || EXTRACT(YEAR FROM aberto_em)::int::text || '-' || LPAD(id::text, 6, '0')) STORED UNIQUE,
    solicitante_id      integer NOT NULL REFERENCES solicitante (id),
    categoria_id        integer NOT NULL REFERENCES categoria (id),
    fila_id             integer NOT NULL REFERENCES fila (id),
    atendente_id        integer REFERENCES atendente (id),
    ativo_id            integer REFERENCES ativo (id),
    chamado_origem_id   integer REFERENCES chamado (id),
    descricao           varchar(300) NOT NULL,
    dados_extras        jsonb NOT NULL DEFAULT '{}'::jsonb,
    prioridade_sugerida varchar(8) NOT NULL CHECK (prioridade_sugerida IN ('baixa', 'media', 'alta', 'critica')),
    prioridade          varchar(8) NOT NULL CHECK (prioridade IN ('baixa', 'media', 'alta', 'critica')),
    status              varchar(24) NOT NULL DEFAULT 'aberto'
                        CHECK (status IN ('aberto', 'em_atendimento', 'aguardando_solicitante', 'resolvido', 'fechado', 'cancelado')),
    aberto_em           timestamp NOT NULL DEFAULT LOCALTIMESTAMP,
    primeira_resposta_em timestamp,
    resolvido_em        timestamp,
    fechado_em          timestamp,
    prazo_resposta      timestamp NOT NULL,
    prazo_resolucao     timestamp NOT NULL,
    aguardando_desde    timestamp,                       -- preenchido enquanto está aguardando o solicitante
    tempo_pausado       interval NOT NULL DEFAULT '0',   -- soma das pausas já encerradas
    CHECK (prazo_resolucao >= prazo_resposta),
    CHECK (resolvido_em IS NULL OR resolvido_em >= aberto_em),
    CHECK (primeira_resposta_em IS NULL OR primeira_resposta_em >= aberto_em),
    CHECK ((status = 'aguardando_solicitante') = (aguardando_desde IS NOT NULL))
);

-- Índices das chaves estrangeiras que mais se consultam (o PostgreSQL NÃO cria índice para FK). O chamado_origem_id também evita
-- que apagar chamados (como a carga em volume faz) vire uma varredura da tabela inteira para cada linha apagada.
CREATE INDEX idx_chamado_origem ON chamado (chamado_origem_id);

-- Comentário público (o solicitante vê) ou interno (só atendentes). Interno exige autor atendente.
CREATE TABLE comentario (
    id             integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    chamado_id     integer NOT NULL REFERENCES chamado (id),
    atendente_id   integer REFERENCES atendente (id),
    solicitante_id integer REFERENCES solicitante (id),
    interno        boolean NOT NULL DEFAULT false,
    texto          varchar(500) NOT NULL,
    criado_em      timestamp NOT NULL DEFAULT LOCALTIMESTAMP,
    CHECK ((atendente_id IS NULL) <> (solicitante_id IS NULL)),     -- ou atendente ou solicitante
    CHECK (NOT interno OR atendente_id IS NOT NULL)
);
CREATE INDEX idx_comentario_chamado ON comentario (chamado_id);

-- Toda mudança de status com a hora e o autor (preenchida por trigger, arquivo 09)
CREATE TABLE historico_status (
    id            bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    chamado_id    integer NOT NULL REFERENCES chamado (id),
    status_antes  varchar(24),
    status_depois varchar(24) NOT NULL,
    usuario       text NOT NULL DEFAULT current_user,
    quando        timestamp NOT NULL DEFAULT LOCALTIMESTAMP
);
CREATE INDEX idx_historico_status_chamado ON historico_status (chamado_id, quando);

-- Troca de prioridade pelo atendente, com a justificativa
CREATE TABLE historico_prioridade (
    id             integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    chamado_id     integer NOT NULL REFERENCES chamado (id),
    atendente_id   integer NOT NULL REFERENCES atendente (id),
    de             varchar(8) NOT NULL,
    para           varchar(8) NOT NULL,
    justificativa  varchar(200) NOT NULL CHECK (btrim(justificativa) <> ''),
    quando         timestamp NOT NULL DEFAULT LOCALTIMESTAMP
);

-- Uma pesquisa por chamado, nota de 1 a 5. É só um dado (D-22): nada impede, no banco, avaliar antes de resolver.
CREATE TABLE pesquisa_satisfacao (
    chamado_id   integer PRIMARY KEY REFERENCES chamado (id),
    nota         smallint NOT NULL CHECK (nota BETWEEN 1 AND 5),
    comentario   varchar(200),
    respondida_em timestamp NOT NULL DEFAULT LOCALTIMESTAMP
);
