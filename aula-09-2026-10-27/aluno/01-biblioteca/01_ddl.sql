-- Projeto 1 · Biblioteca escolar · 01_ddl.sql (prova 1)
-- Estrutura do banco. Pode ser executado quantas vezes quiser: apaga o schema e recria.

DROP SCHEMA IF EXISTS biblioteca CASCADE;
CREATE SCHEMA biblioteca;
SET search_path TO biblioteca;

CREATE TABLE editora (
    id   integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome varchar(80) NOT NULL UNIQUE
);

CREATE TABLE autor (
    id   integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome varchar(80) NOT NULL
);

CREATE TABLE categoria (
    id   integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome varchar(50) NOT NULL UNIQUE
);

-- O livro é o título (a obra); o exemplar é a cópia física, com o estado.
CREATE TABLE livro (
    id           integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    titulo       varchar(150) NOT NULL,
    editora_id   integer NOT NULL REFERENCES editora (id),
    categoria_id integer NOT NULL REFERENCES categoria (id),
    metadados    jsonb NOT NULL DEFAULT '{}'::jsonb
);

-- N:N com a ordem dos autores (1 = autor principal).
CREATE TABLE livro_autor (
    livro_id integer NOT NULL REFERENCES livro (id),
    autor_id integer NOT NULL REFERENCES autor (id),
    ordem    smallint NOT NULL CHECK (ordem >= 1),
    PRIMARY KEY (livro_id, autor_id),
    UNIQUE (livro_id, ordem)
);

CREATE TABLE exemplar (
    id       integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    livro_id integer NOT NULL REFERENCES livro (id),
    -- tombo EX-000123, derivado do id (LPAD)
    tombo    varchar(12) GENERATED ALWAYS AS ('EX-' || LPAD(id::text, 6, '0')) STORED UNIQUE,
    estado   varchar(15) NOT NULL DEFAULT 'disponivel'
             CHECK (estado IN ('disponivel', 'emprestado', 'manutencao', 'perdido'))
);

CREATE TABLE tipo_leitor (
    id                integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome              varchar(20) NOT NULL UNIQUE,
    prazo_dias        smallint NOT NULL CHECK (prazo_dias > 0),
    limite_emprestimos smallint NOT NULL CHECK (limite_emprestimos > 0)
);

-- A tarifa muda com o tempo: cada linha vale a partir de vigencia_inicio (histórico preservado).
CREATE TABLE tarifa_multa (
    id              integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tipo_leitor_id  integer NOT NULL REFERENCES tipo_leitor (id),
    valor_dia       numeric(6,2) NOT NULL CHECK (valor_dia >= 0),
    vigencia_inicio date NOT NULL,
    UNIQUE (tipo_leitor_id, vigencia_inicio)
);

-- Contato do leitor: a bibliotecária cobra por telefone e quer avisar por e-mail e WhatsApp.
-- registro = matrícula (aluno) ou registro funcional (professor e funcionário).
CREATE TABLE leitor (
    id             integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome           varchar(100) NOT NULL,
    registro       varchar(20) NOT NULL UNIQUE,
    email          varchar(100) NOT NULL UNIQUE,
    telefone       varchar(20) NOT NULL,
    tipo_leitor_id integer NOT NULL REFERENCES tipo_leitor (id)
);

CREATE TABLE emprestimo (
    id              integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    leitor_id       integer NOT NULL REFERENCES leitor (id),
    exemplar_id     integer NOT NULL REFERENCES exemplar (id),
    data_emprestimo date NOT NULL DEFAULT CURRENT_DATE,
    data_prevista   date NOT NULL,
    data_devolucao  date,
    renovado        boolean NOT NULL DEFAULT false,
    CHECK (data_prevista >= data_emprestimo),
    CHECK (data_devolucao IS NULL OR data_devolucao >= data_emprestimo)
);

-- Um exemplar não pode ter dois empréstimos abertos ao mesmo tempo (última barreira contra a corrida).
CREATE UNIQUE INDEX uq_emprestimo_aberto_por_exemplar
    ON emprestimo (exemplar_id) WHERE data_devolucao IS NULL;

-- Fila de reservas: a ordem é criada_em (e id); aguardando -> disponivel (exemplar separado) -> atendida/expirada/cancelada.
CREATE TABLE reserva (
    id          integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    leitor_id   integer NOT NULL REFERENCES leitor (id),
    livro_id    integer NOT NULL REFERENCES livro (id),
    criada_em   timestamptz NOT NULL DEFAULT now(),
    situacao    varchar(12) NOT NULL DEFAULT 'aguardando'
                CHECK (situacao IN ('aguardando', 'disponivel', 'atendida', 'expirada', 'cancelada')),
    exemplar_id integer REFERENCES exemplar (id),
    valida_ate  date,
    -- exemplar e validade só existem quando a reserva está 'disponivel' (ou já foi atendida/expirada)
    CHECK (situacao = 'aguardando' OR situacao = 'cancelada' OR exemplar_id IS NOT NULL)
);

-- Um leitor não fica duas vezes na fila do mesmo livro.
CREATE UNIQUE INDEX uq_reserva_ativa
    ON reserva (leitor_id, livro_id) WHERE situacao IN ('aguardando', 'disponivel');

-- Valor guardado no momento da devolução (a tarifa pode mudar depois).
CREATE TABLE multa (
    id            integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    emprestimo_id integer NOT NULL UNIQUE REFERENCES emprestimo (id),
    dias_atraso   integer NOT NULL CHECK (dias_atraso > 0),
    valor         numeric(8,2) NOT NULL CHECK (valor >= 0),
    paga          boolean NOT NULL DEFAULT false,
    gerada_em     date NOT NULL DEFAULT CURRENT_DATE
);

-- Aviso de cobrança. O envio de e-mail e WhatsApp é de outro sistema: o banco guarda o que precisa ser avisado
-- (pendente) e o que já foi avisado (enviada ou falhou). O destino é copiado, porque o contato do leitor pode mudar.
-- Um aviso por empréstimo, canal e dia: a bibliotecária não cobra duas vezes sem querer.
CREATE TABLE notificacao (
    id              bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    emprestimo_id   integer NOT NULL REFERENCES emprestimo (id),
    canal           varchar(10) NOT NULL CHECK (canal IN ('email', 'whatsapp')),
    destino         varchar(100) NOT NULL,
    mensagem        text NOT NULL,
    situacao        varchar(10) NOT NULL DEFAULT 'pendente'
                    CHECK (situacao IN ('pendente', 'enviada', 'falhou')),
    data_referencia date NOT NULL DEFAULT CURRENT_DATE,
    criada_em       timestamptz NOT NULL DEFAULT now(),
    enviada_em      timestamptz,
    UNIQUE (emprestimo_id, canal, data_referencia),
    CHECK ((situacao = 'enviada') = (enviada_em IS NOT NULL))
);

-- Auditoria dos empréstimos (preenchida por trigger, arquivo 09)
CREATE TABLE auditoria_emprestimo (
    id            bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    emprestimo_id integer NOT NULL,
    operacao      varchar(6) NOT NULL,
    usuario       text NOT NULL DEFAULT current_user,
    quando        timestamptz NOT NULL DEFAULT now(),
    antes         jsonb,
    depois        jsonb
);
