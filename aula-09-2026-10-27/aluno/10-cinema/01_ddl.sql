-- Projeto 10 · Cinema · 01_ddl.sql (prova 1)
-- Estrutura do banco. Pode ser executado quantas vezes quiser: apaga o schema e recria.

DROP SCHEMA IF EXISTS cinema CASCADE;
CREATE SCHEMA cinema;
SET search_path TO cinema;

CREATE TABLE genero (
    id   integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome varchar(30) NOT NULL UNIQUE
);

CREATE TABLE filme (
    id            integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    titulo        varchar(100) NOT NULL,
    genero_id     integer NOT NULL REFERENCES genero (id),
    duracao_min   smallint NOT NULL CHECK (duracao_min > 0),
    classificacao varchar(5) NOT NULL CHECK (classificacao IN ('livre', '10', '12', '14', '16', '18')),
    idioma        varchar(20) NOT NULL,
    ficha_tecnica jsonb NOT NULL DEFAULT '{}'::jsonb
);

CREATE TABLE sala (
    id   integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome varchar(20) NOT NULL UNIQUE,
    tipo varchar(3) NOT NULL CHECK (tipo IN ('2D', '3D', 'VIP'))
);

-- O assento é da SALA (fileira e número); o ingresso liga assento e sessão.
CREATE TABLE assento (
    id       integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sala_id  integer NOT NULL REFERENCES sala (id),
    fileira  char(1) NOT NULL,
    numero   smallint NOT NULL CHECK (numero > 0),
    especial varchar(10) CHECK (especial IN ('cadeirante', 'casal')),
    UNIQUE (sala_id, fileira, numero)
);

-- O fim da sessão (início + duração do filme + 20 minutos de limpeza) é GUARDADO: o trigger do arquivo 09 o calcula
-- e impede duas sessões da mesma sala com períodos que se sobrepõem.
CREATE TABLE sessao (
    id      integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    filme_id integer NOT NULL REFERENCES filme (id),
    sala_id  integer NOT NULL REFERENCES sala (id),
    inicio   timestamp NOT NULL,
    fim      timestamp NOT NULL,
    formato  varchar(10) NOT NULL CHECK (formato IN ('dublado', 'legendado')),
    status   varchar(10) NOT NULL DEFAULT 'aberta' CHECK (status IN ('aberta', 'esgotada', 'cancelada', 'encerrada')),
    CHECK (fim > inicio),
    UNIQUE (sala_id, inicio)
);

-- Preço da inteira por tipo de sala e tipo de dia (a quarta-feira é promocional), com vigência: o histórico fica.
CREATE TABLE preco (
    id              integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tipo_sala       varchar(3) NOT NULL CHECK (tipo_sala IN ('2D', '3D', 'VIP')),
    dia             varchar(6) NOT NULL CHECK (dia IN ('normal', 'quarta')),
    valor           numeric(8,2) NOT NULL CHECK (valor > 0),
    vigencia_inicio date NOT NULL,
    UNIQUE (tipo_sala, dia, vigencia_inicio)
);

-- Tipo de ingresso com o percentual do valor da inteira (inteira 100, meia 50)
CREATE TABLE tipo_ingresso (
    id         integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome       varchar(20) NOT NULL UNIQUE,
    percentual numeric(5,2) NOT NULL CHECK (percentual > 0 AND percentual <= 100)
);

CREATE TABLE cliente (
    id         integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome       varchar(100) NOT NULL,
    email      varchar(100) NOT NULL UNIQUE,
    nascimento date NOT NULL CHECK (nascimento <= CURRENT_DATE)
);

-- A compra é tudo ou nada: de 1 a 3 ingressos da mesma sessão. Se for cancelada, os ingressos ficam «cancelado» (o assento volta).
CREATE TABLE compra (
    id            integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cliente_id    integer NOT NULL REFERENCES cliente (id),
    sessao_id     integer NOT NULL REFERENCES sessao (id),
    status        varchar(10) NOT NULL DEFAULT 'paga' CHECK (status IN ('pendente', 'paga', 'cancelada')),
    criada_em     timestamp NOT NULL DEFAULT LOCALTIMESTAMP,
    valor_total   numeric(8,2) NOT NULL CHECK (valor_total >= 0),
    cancelada_em  timestamp,
    reembolso     numeric(8,2) CHECK (reembolso >= 0),
    CHECK ((status = 'cancelada') = (cancelada_em IS NOT NULL))
);

-- A sessão fica no ingresso (redundante com a compra) para o banco poder garantir que o MESMO ASSENTO não é vendido duas
-- vezes na mesma sessão: UNIQUE parcial em (sessao_id, assento_id) enquanto o ingresso não está cancelado.
CREATE TABLE ingresso (
    id               integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    codigo           varchar(12) GENERATED ALWAYS AS ('CN-' || LPAD(id::text, 6, '0')) STORED UNIQUE,
    compra_id        integer NOT NULL REFERENCES compra (id),
    sessao_id        integer NOT NULL REFERENCES sessao (id),
    assento_id       integer NOT NULL REFERENCES assento (id),
    tipo_ingresso_id integer NOT NULL REFERENCES tipo_ingresso (id),
    valor_pago       numeric(8,2) NOT NULL CHECK (valor_pago > 0),      -- valor calculado e gravado no dia da compra
    situacao         varchar(10) NOT NULL DEFAULT 'vendido' CHECK (situacao IN ('vendido', 'cancelado'))
);
CREATE UNIQUE INDEX uq_assento_por_sessao ON ingresso (sessao_id, assento_id) WHERE situacao = 'vendido';
CREATE INDEX idx_ingresso_compra ON ingresso (compra_id);

-- Reserva temporária (10 minutos) de quem escolheu o assento e ainda vai pagar. Uma ativa por assento e sessão.
-- Quem libera as vencidas é a procedure liberar_reservas_vencidas(), chamada à mão (D-23).
CREATE TABLE reserva_assento (
    id          integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sessao_id   integer NOT NULL REFERENCES sessao (id),
    assento_id  integer NOT NULL REFERENCES assento (id),
    cliente_id  integer NOT NULL REFERENCES cliente (id),
    criada_em   timestamp NOT NULL DEFAULT LOCALTIMESTAMP,
    expira_em   timestamp NOT NULL,
    situacao    varchar(10) NOT NULL DEFAULT 'ativa' CHECK (situacao IN ('ativa', 'convertida', 'expirada')),
    CHECK (expira_em > criada_em)
);
CREATE UNIQUE INDEX uq_reserva_ativa ON reserva_assento (sessao_id, assento_id) WHERE situacao = 'ativa';

CREATE TABLE pagamento (
    id         integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    compra_id  integer NOT NULL UNIQUE REFERENCES compra (id),
    forma      varchar(10) NOT NULL CHECK (forma IN ('pix', 'cartao')),
    valor      numeric(8,2) NOT NULL CHECK (valor > 0),
    pago_em    timestamp NOT NULL DEFAULT LOCALTIMESTAMP
);

CREATE TABLE auditoria_compra (
    id             bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    compra_id      integer NOT NULL,
    status_antes   varchar(10),
    status_depois  varchar(10),
    usuario        text NOT NULL DEFAULT current_user,
    quando         timestamptz NOT NULL DEFAULT now()
);
