-- Planilha E · Estoque (depósitos) · estrutura do banco (aula 3, gabarito do professor)
-- Pode ser executado quantas vezes quiser: apaga e recria as tabelas.

DROP TABLE IF EXISTS estoque;
DROP TABLE IF EXISTS produto;
DROP TABLE IF EXISTS deposito;
DROP TABLE IF EXISTS fornecedor;

CREATE TABLE fornecedor (
    cod_fornecedor integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome           varchar(100) NOT NULL,
    fone           varchar(20)
);

CREATE TABLE produto (
    cod_produto    integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome           varchar(100)  NOT NULL,
    categoria      varchar(50)   NOT NULL,
    custo_unit     numeric(10,2) NOT NULL,
    cod_fornecedor integer       NOT NULL REFERENCES fornecedor (cod_fornecedor)
);

CREATE TABLE deposito (
    cod_deposito integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome         varchar(60) NOT NULL,
    cidade       varchar(60) NOT NULL
);

CREATE TABLE estoque (
    cod_produto  integer NOT NULL REFERENCES produto (cod_produto),
    cod_deposito integer NOT NULL REFERENCES deposito (cod_deposito),
    quantidade   integer NOT NULL DEFAULT 0,
    PRIMARY KEY (cod_produto, cod_deposito)
);

ALTER TABLE fornecedor ADD COLUMN email varchar(100);
ALTER TABLE estoque    ADD COLUMN observacao text;
ALTER TABLE deposito   ADD COLUMN ativo boolean NOT NULL DEFAULT true;
