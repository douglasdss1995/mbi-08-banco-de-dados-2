-- Planilha A · Pedidos (papelaria) · estrutura do banco (aula 3, gabarito do professor)
-- Pode ser executado quantas vezes quiser: apaga e recria as tabelas.

DROP TABLE IF EXISTS item_pedido;
DROP TABLE IF EXISTS pedido;
DROP TABLE IF EXISTS produto;
DROP TABLE IF EXISTS vendedor;
DROP TABLE IF EXISTS cliente;
DROP TABLE IF EXISTS cidade;

CREATE TABLE cidade (
    cod_cidade integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome       varchar(60) NOT NULL,
    estado     char(2)     NOT NULL
);

CREATE TABLE cliente (
    cod_cliente integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome        varchar(100) NOT NULL,
    cod_cidade  integer      NOT NULL REFERENCES cidade (cod_cidade)
);

CREATE TABLE vendedor (
    cod_vendedor integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome         varchar(100) NOT NULL
);

CREATE TABLE produto (
    cod_produto integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    descricao   varchar(100)  NOT NULL,
    preco       numeric(10,2) NOT NULL
);

CREATE TABLE pedido (
    numero       integer PRIMARY KEY,
    data         date    NOT NULL DEFAULT CURRENT_DATE,
    cod_cliente  integer NOT NULL REFERENCES cliente (cod_cliente),
    cod_vendedor integer NOT NULL REFERENCES vendedor (cod_vendedor)
);

CREATE TABLE item_pedido (
    numero         integer       NOT NULL REFERENCES pedido (numero),
    cod_produto    integer       NOT NULL REFERENCES produto (cod_produto),
    quantidade     integer       NOT NULL,
    preco_cobrado  numeric(10,2) NOT NULL,
    PRIMARY KEY (numero, cod_produto)
);

ALTER TABLE cliente  ADD COLUMN email varchar(100);
ALTER TABLE pedido   ADD COLUMN observacao text;
ALTER TABLE vendedor ADD COLUMN ativo boolean NOT NULL DEFAULT true;
