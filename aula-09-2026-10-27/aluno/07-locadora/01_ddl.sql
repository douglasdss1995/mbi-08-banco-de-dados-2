-- Projeto 7 · Locadora de veículos · 01_ddl.sql (prova 1)
-- Estrutura do banco. Pode ser executado quantas vezes quiser: apaga o schema e recria.

DROP SCHEMA IF EXISTS locadora CASCADE;
CREATE SCHEMA locadora;
SET search_path TO locadora;

-- Valores que o negócio muda sem mexer no código (taxas e tolerância)
CREATE TABLE parametro (
    nome  varchar(40) PRIMARY KEY,
    valor numeric(10,2) NOT NULL
);

CREATE TABLE filial (
    id     integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome   varchar(60) NOT NULL UNIQUE,
    cidade varchar(60) NOT NULL
);

-- A diária e a caução são do GRUPO (não do modelo nem do veículo); a diária tem histórico em tarifa_grupo.
CREATE TABLE grupo (
    id      integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome    varchar(30) NOT NULL UNIQUE,
    caucao  numeric(8,2) NOT NULL CHECK (caucao >= 0),
    premium boolean NOT NULL DEFAULT false           -- exige CNH com 2 anos ou mais
);

CREATE TABLE tarifa_grupo (
    id              integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    grupo_id        integer NOT NULL REFERENCES grupo (id),
    diaria          numeric(8,2) NOT NULL CHECK (diaria > 0),
    vigencia_inicio date NOT NULL,
    UNIQUE (grupo_id, vigencia_inicio)
);

CREATE TABLE modelo (
    id       integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome     varchar(40) NOT NULL UNIQUE,
    grupo_id integer NOT NULL REFERENCES grupo (id)
);

-- O status do veículo é o ESTADO ATUAL. Saber se o carro está livre na semana que vem exige olhar locações e manutenções.
CREATE TABLE veiculo (
    id                  integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    placa               varchar(8) NOT NULL UNIQUE,
    modelo_id           integer NOT NULL REFERENCES modelo (id),
    filial_id           integer NOT NULL REFERENCES filial (id),
    status              varchar(12) NOT NULL DEFAULT 'disponivel' CHECK (status IN ('disponivel', 'alugado', 'manutencao', 'baixado')),
    km_atual            integer NOT NULL CHECK (km_atual >= 0),
    km_ultima_revisao   integer NOT NULL CHECK (km_ultima_revisao >= 0),
    data_ultima_revisao date NOT NULL,
    CHECK (km_ultima_revisao <= km_atual)
);

CREATE TABLE cliente (
    id                   integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome                 varchar(100) NOT NULL,
    nascimento           date NOT NULL CHECK (nascimento <= CURRENT_DATE),
    cnh_numero           varchar(15) NOT NULL UNIQUE,
    cnh_validade         date NOT NULL,
    cnh_primeira_emissao date NOT NULL,
    CHECK (cnh_primeira_emissao >= nascimento)
);

-- A reserva é de um GRUPO, não de um carro. Ao retirar, a reserva vira 'retirada' e nasce a locação.
CREATE TABLE reserva (
    id                  integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cliente_id          integer NOT NULL REFERENCES cliente (id),
    grupo_id            integer NOT NULL REFERENCES grupo (id),
    filial_retirada_id  integer NOT NULL REFERENCES filial (id),
    retirada_prevista   timestamp NOT NULL,
    devolucao_prevista  timestamp NOT NULL,
    criada_em           timestamp NOT NULL DEFAULT LOCALTIMESTAMP,
    status              varchar(10) NOT NULL DEFAULT 'ativa' CHECK (status IN ('ativa', 'retirada', 'cancelada', 'noshow')),
    taxa_cobrada        numeric(8,2) NOT NULL DEFAULT 0 CHECK (taxa_cobrada >= 0),
    CHECK (devolucao_prevista > retirada_prevista)
);

-- Os períodos de um mesmo veículo NÃO podem se sobrepor; o banco não impede isso sozinho (ver README e 03_transacoes.sql):
-- quem impede é a procedure retirar_veiculo (com trava) e, como alternativa fora do curso, uma restrição EXCLUDE.
-- diaria_valor e caucao são gravados: valem os da época da retirada.
CREATE TABLE locacao (
    id                   integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    numero               varchar(20) GENERATED ALWAYS AS
                         ('LC-' || EXTRACT(YEAR FROM retirada)::int::text || '-' || LPAD(id::text, 6, '0')) STORED UNIQUE,
    reserva_id           integer UNIQUE REFERENCES reserva (id),
    cliente_id           integer NOT NULL REFERENCES cliente (id),
    veiculo_id           integer NOT NULL REFERENCES veiculo (id),
    grupo_id             integer NOT NULL REFERENCES grupo (id),
    filial_retirada_id   integer NOT NULL REFERENCES filial (id),
    filial_devolucao_id  integer REFERENCES filial (id),
    retirada             timestamp NOT NULL,
    devolucao_prevista   timestamp NOT NULL,
    devolucao_real       timestamp,
    diaria_valor         numeric(8,2) NOT NULL CHECK (diaria_valor > 0),
    caucao               numeric(8,2) NOT NULL CHECK (caucao >= 0),
    valor_final          numeric(10,2) CHECK (valor_final >= 0),
    status               varchar(12) NOT NULL DEFAULT 'em_andamento' CHECK (status IN ('em_andamento', 'encerrada')),
    CHECK (devolucao_prevista > retirada),
    CHECK (devolucao_real IS NULL OR devolucao_real > retirada),
    CHECK ((status = 'encerrada') = (devolucao_real IS NOT NULL))
);

-- Vistoria de retirada e de devolução (uma de cada). km e combustível são usados nas contas;
-- avarias, acessórios e observações variam de vistoria para vistoria (JSONB).
CREATE TABLE vistoria (
    id             integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    locacao_id     integer NOT NULL REFERENCES locacao (id),
    tipo           varchar(10) NOT NULL CHECK (tipo IN ('retirada', 'devolucao')),
    km             integer NOT NULL CHECK (km >= 0),
    feita_em       timestamp NOT NULL DEFAULT LOCALTIMESTAMP,
    dados_vistoria jsonb NOT NULL DEFAULT '{}'::jsonb,       -- combustivel_quartos (0 a 4), avarias, acessorios, observacoes
    UNIQUE (locacao_id, tipo)
);

CREATE TABLE adicional (
    id            integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome          varchar(40) NOT NULL UNIQUE,
    valor_diaria  numeric(8,2) NOT NULL CHECK (valor_diaria >= 0)
);

-- O valor por diária da época fica na locação (um adicional novo ou mais caro não muda locações antigas).
CREATE TABLE adicional_locacao (
    locacao_id    integer NOT NULL REFERENCES locacao (id),
    adicional_id  integer NOT NULL REFERENCES adicional (id),
    valor_diaria  numeric(8,2) NOT NULL CHECK (valor_diaria >= 0),
    PRIMARY KEY (locacao_id, adicional_id)
);

-- Manutenção bloqueia o veículo no período.
CREATE TABLE manutencao (
    id         integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    veiculo_id integer NOT NULL REFERENCES veiculo (id),
    tipo       varchar(10) NOT NULL CHECK (tipo IN ('revisao', 'reparo')),
    inicio     timestamp NOT NULL,
    fim        timestamp NOT NULL,
    km         integer,
    CHECK (fim > inicio)
);

-- A multa guarda só o veículo e o momento: o cliente se descobre pela locação que cobria aquele momento.
CREATE TABLE multa_transito (
    id           integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    veiculo_id   integer NOT NULL REFERENCES veiculo (id),
    ocorrida_em  timestamp NOT NULL,
    valor        numeric(8,2) NOT NULL CHECK (valor > 0),
    descricao    varchar(100) NOT NULL
);

CREATE TABLE auditoria_veiculo (
    id             bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    veiculo_id     integer NOT NULL,
    status_antes   varchar(12),
    status_depois  varchar(12),
    usuario        text NOT NULL DEFAULT current_user,
    quando         timestamptz NOT NULL DEFAULT now()
);
