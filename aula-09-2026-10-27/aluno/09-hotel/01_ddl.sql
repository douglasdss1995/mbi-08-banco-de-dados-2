-- Projeto 9 · Hotel ou pousada · 01_ddl.sql (prova 1)
-- Estrutura do banco. Pode ser executado quantas vezes quiser: apaga o schema e recria.

DROP SCHEMA IF EXISTS hotel CASCADE;
CREATE SCHEMA hotel;
SET search_path TO hotel;

CREATE TABLE tipo_quarto (
    id         integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome       varchar(20) NOT NULL UNIQUE,
    capacidade smallint NOT NULL CHECK (capacidade > 0)
);

-- O status do quarto é o estado ATUAL (livre, ocupado, aguardando limpeza, manutenção); a ocupação futura vem das estadias.
CREATE TABLE quarto (
    id      integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    numero  varchar(6) NOT NULL UNIQUE,
    andar   smallint NOT NULL,
    tipo_id integer NOT NULL REFERENCES tipo_quarto (id),
    status  varchar(20) NOT NULL DEFAULT 'livre' CHECK (status IN ('livre', 'ocupado', 'aguardando_limpeza', 'manutencao'))
);

-- Calendário de temporadas: o que não está em nenhum período é «baixa».
CREATE TABLE temporada (
    id     integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome   varchar(10) NOT NULL CHECK (nome IN ('alta', 'feriado')),
    inicio date NOT NULL,
    fim    date NOT NULL,
    CHECK (fim >= inicio)
);

-- Tarifa por tipo e temporada, com vigência (os valores mudam e o histórico fica).
CREATE TABLE tarifa (
    id               integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tipo_id          integer NOT NULL REFERENCES tipo_quarto (id),
    temporada        varchar(10) NOT NULL CHECK (temporada IN ('baixa', 'alta', 'feriado')),
    diaria           numeric(8,2) NOT NULL CHECK (diaria > 0),
    adicional_pessoa numeric(8,2) NOT NULL CHECK (adicional_pessoa >= 0),   -- por pessoa acima de 2, por noite
    vigencia_inicio  date NOT NULL,
    UNIQUE (tipo_id, temporada, vigencia_inicio)
);

CREATE TABLE hospede (
    id          integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome        varchar(100) NOT NULL,
    documento   varchar(20) NOT NULL UNIQUE,          -- CPF ou passaporte (fictício)
    nascimento  date NOT NULL CHECK (nascimento <= CURRENT_DATE),
    preferencias jsonb NOT NULL DEFAULT '{}'::jsonb
);

-- A reserva é de um TIPO de quarto; o quarto só aparece no check-in (estadia). Ao fazer o check-in a reserva vira 'checkin'.
CREATE TABLE reserva (
    id             integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    numero         varchar(20) GENERATED ALWAYS AS ('HT-' || EXTRACT(YEAR FROM entrada)::int::text || '-' || LPAD(id::text, 6, '0')) STORED UNIQUE,
    hospede_id     integer NOT NULL REFERENCES hospede (id),
    tipo_id        integer NOT NULL REFERENCES tipo_quarto (id),
    entrada        date NOT NULL,
    saida          date NOT NULL,
    num_hospedes   smallint NOT NULL CHECK (num_hospedes > 0),
    num_criancas   smallint NOT NULL DEFAULT 0 CHECK (num_criancas >= 0),    -- até 5 anos: não pagam adicional
    status         varchar(10) NOT NULL DEFAULT 'confirmada' CHECK (status IN ('confirmada', 'checkin', 'cancelada', 'noshow')),
    valor_diarias  numeric(10,2) NOT NULL CHECK (valor_diarias >= 0),        -- valor da época, gravado na reserva
    sinal          numeric(10,2) NOT NULL DEFAULT 0 CHECK (sinal >= 0),      -- 30% das diárias
    criada_em      timestamp NOT NULL DEFAULT LOCALTIMESTAMP,
    CHECK (saida > entrada),
    CHECK (num_criancas < num_hospedes)
);

-- Estadia = a hospedagem de fato, em um quarto específico. reserva_id é NULL para hóspedes de balcão.
CREATE TABLE estadia (
    id               integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    reserva_id       integer UNIQUE REFERENCES reserva (id),
    quarto_id        integer NOT NULL REFERENCES quarto (id),
    checkin_em       timestamp NOT NULL,
    saida_prevista   date NOT NULL,
    checkout_em      timestamp,
    num_hospedes     smallint NOT NULL CHECK (num_hospedes > 0),
    num_criancas     smallint NOT NULL DEFAULT 0 CHECK (num_criancas >= 0),
    diaria_valor     numeric(8,2) NOT NULL CHECK (diaria_valor > 0),
    adicional_valor  numeric(8,2) NOT NULL DEFAULT 0 CHECK (adicional_valor >= 0),
    valor_final      numeric(10,2) CHECK (valor_final >= 0),
    status           varchar(10) NOT NULL DEFAULT 'em_curso' CHECK (status IN ('em_curso', 'encerrada')),
    CHECK (saida_prevista > checkin_em::date),
    CHECK (checkout_em IS NULL OR checkout_em > checkin_em),
    CHECK ((status = 'encerrada') = (checkout_em IS NOT NULL))
);

-- Responsável e acompanhantes: N:N com o papel de cada um
CREATE TABLE estadia_hospede (
    estadia_id integer NOT NULL REFERENCES estadia (id),
    hospede_id integer NOT NULL REFERENCES hospede (id),
    papel      varchar(12) NOT NULL CHECK (papel IN ('responsavel', 'acompanhante')),
    PRIMARY KEY (estadia_id, hospede_id)
);
CREATE INDEX idx_estadia_hospede_hospede ON estadia_hospede (hospede_id);
CREATE UNIQUE INDEX uq_responsavel_por_estadia ON estadia_hospede (estadia_id) WHERE papel = 'responsavel';

CREATE TABLE item_consumo (
    id    integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome  varchar(40) NOT NULL UNIQUE,
    preco numeric(8,2) NOT NULL CHECK (preco > 0)
);

-- O preço do dia fica no lançamento (o preço do item pode mudar depois).
CREATE TABLE consumo (
    id             integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    estadia_id     integer NOT NULL REFERENCES estadia (id),
    item_id        integer NOT NULL REFERENCES item_consumo (id),
    quantidade     smallint NOT NULL CHECK (quantidade > 0),
    preco_unitario numeric(8,2) NOT NULL CHECK (preco_unitario > 0),
    lancado_em     timestamp NOT NULL DEFAULT LOCALTIMESTAMP
);
CREATE INDEX idx_consumo_estadia ON consumo (estadia_id);

CREATE TABLE manutencao_quarto (
    id        integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    quarto_id integer NOT NULL REFERENCES quarto (id),
    inicio    date NOT NULL,
    fim       date NOT NULL,
    motivo    varchar(60) NOT NULL,
    CHECK (fim >= inicio)
);

CREATE TABLE pagamento (
    id         integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    estadia_id integer NOT NULL REFERENCES estadia (id),
    forma      varchar(10) NOT NULL CHECK (forma IN ('dinheiro', 'cartao', 'pix')),
    valor      numeric(10,2) NOT NULL CHECK (valor > 0),
    pago_em    timestamp NOT NULL DEFAULT LOCALTIMESTAMP
);
CREATE INDEX idx_pagamento_estadia ON pagamento (estadia_id);

CREATE TABLE auditoria_status (
    id             bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tabela         varchar(10) NOT NULL,
    registro_id    integer NOT NULL,
    status_antes   varchar(20),
    status_depois  varchar(20),
    usuario        text NOT NULL DEFAULT current_user,
    quando         timestamptz NOT NULL DEFAULT now()
);
