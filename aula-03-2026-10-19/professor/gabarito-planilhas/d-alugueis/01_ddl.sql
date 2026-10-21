-- Planilha D · Aluguéis (equipamentos) · estrutura do banco (aula 3, gabarito do professor)
-- Pode ser executado quantas vezes quiser: apaga e recria as tabelas.

DROP TABLE IF EXISTS item_contrato;
DROP TABLE IF EXISTS contrato;
DROP TABLE IF EXISTS equipamento;
DROP TABLE IF EXISTS cliente;

CREATE TABLE cliente (
    cod_cliente integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome        varchar(100) NOT NULL,
    telefone    varchar(20)
);

CREATE TABLE equipamento (
    cod_equipamento integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    descricao       varchar(100)  NOT NULL,
    diaria          numeric(10,2) NOT NULL
);

CREATE TABLE contrato (
    numero      varchar(10) PRIMARY KEY,
    retirada    date        NOT NULL DEFAULT CURRENT_DATE,
    devolucao   date        NOT NULL,
    cod_cliente integer     NOT NULL REFERENCES cliente (cod_cliente)
);

CREATE TABLE item_contrato (
    numero          varchar(10)   NOT NULL REFERENCES contrato (numero),
    cod_equipamento integer       NOT NULL REFERENCES equipamento (cod_equipamento),
    diaria_cobrada  numeric(10,2) NOT NULL,
    PRIMARY KEY (numero, cod_equipamento)
);

ALTER TABLE cliente     ADD COLUMN email varchar(100);
ALTER TABLE contrato    ADD COLUMN observacao text;
ALTER TABLE equipamento ADD COLUMN ativo boolean NOT NULL DEFAULT true;
