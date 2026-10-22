-- Oficina Mecânica · 01_ddl.sql
-- Exemplo guiado da aula 6: o professor cria ao vivo, a partir do dicionário de dados simples.
-- Pode ser executado quantas vezes quiser: apaga o schema e recria.
-- Depois da aula, copie este arquivo para aluno/ (exemplo guiado, regra 2 do CLAUDE.md).

DROP SCHEMA IF EXISTS oficina CASCADE;
CREATE SCHEMA oficina;
SET search_path TO oficina;

-- ===== 1. Tabelas que não dependem de nenhuma outra =====

CREATE TABLE cliente (
    id       integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome     varchar(100) NOT NULL,
    telefone varchar(20)  NOT NULL
);

CREATE TABLE modelo (
    id    integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome  varchar(50) NOT NULL,
    marca varchar(50) NOT NULL
);

CREATE TABLE mecanico (
    id           integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome         varchar(100) NOT NULL,
    especialidade varchar(50)
);

CREATE TABLE servico (
    id        integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    descricao varchar(100) NOT NULL UNIQUE,
    valor     numeric(10,2) NOT NULL    -- preço de tabela de hoje (o valor cobrado fica no item da OS)
);

-- ===== 2. Tabelas que dependem das de cima (a ordem importa por causa das chaves estrangeiras) =====

CREATE TABLE veiculo (
    id         integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    placa      char(7) NOT NULL UNIQUE,
    modelo_id  integer NOT NULL REFERENCES modelo (id),
    cliente_id integer NOT NULL REFERENCES cliente (id)
);

CREATE TABLE ordem_servico (
    id            integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    numero        integer NOT NULL UNIQUE,      -- número da OS, do negócio (1001, 1002...)
    data_abertura date NOT NULL DEFAULT CURRENT_DATE,
    veiculo_id    integer NOT NULL REFERENCES veiculo (id),
    mecanico_id   integer NOT NULL REFERENCES mecanico (id)
);

-- ===== 3. Tabela de ligação (N:N entre ordem_servico e servico) =====
-- Guarda também o valor cobrado, porque o preço de tabela muda com o tempo.

CREATE TABLE item_servico (
    ordem_servico_id integer NOT NULL REFERENCES ordem_servico (id),
    servico_id       integer NOT NULL REFERENCES servico (id),
    valor_cobrado    numeric(10,2) NOT NULL,
    PRIMARY KEY (ordem_servico_id, servico_id)
);
