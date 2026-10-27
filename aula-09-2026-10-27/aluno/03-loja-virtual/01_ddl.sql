-- Projeto 3 · Loja virtual · 01_ddl.sql (prova 1)
-- Estrutura do banco. Pode ser executado quantas vezes quiser: apaga o schema e recria.

DROP SCHEMA IF EXISTS loja CASCADE;
CREATE SCHEMA loja;
SET search_path TO loja;

CREATE TABLE categoria (
    id   integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome varchar(50) NOT NULL UNIQUE
);

-- O preço NÃO fica no produto: está em preco_produto (com vigência) e é copiado para o item do pedido.
-- O estoque é uma coluna (com CHECK >= 0, a última barreira) e cada mudança também vira um movimento (histórico).
CREATE TABLE produto (
    id             integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sku            varchar(20) NOT NULL UNIQUE,
    nome           varchar(120) NOT NULL,
    categoria_id   integer NOT NULL REFERENCES categoria (id),
    estoque        integer NOT NULL DEFAULT 0 CHECK (estoque >= 0),
    ativo          boolean NOT NULL DEFAULT true,
    especificacoes jsonb NOT NULL DEFAULT '{}'::jsonb
);

CREATE TABLE preco_produto (
    id               integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    produto_id       integer NOT NULL REFERENCES produto (id),
    preco            numeric(10,2) NOT NULL CHECK (preco > 0),
    vigencia_inicio  timestamp NOT NULL,
    UNIQUE (produto_id, vigencia_inicio)
);

CREATE TABLE cliente (
    id    integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome  varchar(100) NOT NULL,
    email varchar(100) NOT NULL UNIQUE,
    cpf   char(11) NOT NULL UNIQUE      -- fictício
);

CREATE TABLE endereco (
    id         integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cliente_id integer NOT NULL REFERENCES cliente (id),
    logradouro varchar(120) NOT NULL,
    numero     varchar(10) NOT NULL,
    cidade     varchar(60) NOT NULL,
    uf         char(2) NOT NULL,
    cep        char(8) NOT NULL
);

CREATE TABLE frete_uf (
    uf    char(2) PRIMARY KEY,
    valor numeric(8,2) NOT NULL CHECK (valor >= 0)
);

-- Cupom: o número de usos NÃO é uma coluna; conta-se nos pedidos que usaram o cupom e não foram cancelados.
CREATE TABLE cupom (
    id           integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    codigo       varchar(20) NOT NULL UNIQUE,
    tipo         varchar(10) NOT NULL CHECK (tipo IN ('percentual', 'fixo')),
    valor        numeric(8,2) NOT NULL CHECK (valor > 0),
    valido_ate   date NOT NULL,
    limite_usos  integer NOT NULL CHECK (limite_usos > 0),
    valor_minimo numeric(10,2) NOT NULL DEFAULT 0 CHECK (valor_minimo >= 0),
    CHECK (tipo <> 'percentual' OR valor <= 100)
);

-- O carrinho é um pedido com status 'carrinho'. O endereço é COPIADO para o pedido (dest_*),
-- então mudar o endereço do cliente depois não altera pedidos antigos.
-- subtotal, desconto, frete e total são gravados ao fechar o pedido (valor da época).
CREATE TABLE pedido (
    id              integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    numero          varchar(20) GENERATED ALWAYS AS
                    ('PD-' || EXTRACT(YEAR FROM criado_em)::int::text || '-' || LPAD(id::text, 6, '0')) STORED UNIQUE,
    cliente_id      integer NOT NULL REFERENCES cliente (id),
    status          varchar(20) NOT NULL DEFAULT 'carrinho'
                    CHECK (status IN ('carrinho', 'aguardando_pagamento', 'pago', 'enviado', 'entregue', 'cancelado')),
    criado_em       timestamp NOT NULL DEFAULT LOCALTIMESTAMP,
    fechado_em      timestamp,
    enviado_em      timestamp,
    entregue_em     timestamp,
    cupom_id        integer REFERENCES cupom (id),
    dest_logradouro varchar(120) NOT NULL,
    dest_numero     varchar(10) NOT NULL,
    dest_cidade     varchar(60) NOT NULL,
    dest_uf         char(2) NOT NULL REFERENCES frete_uf (uf),
    dest_cep        char(8) NOT NULL,
    subtotal        numeric(10,2) CHECK (subtotal >= 0),
    desconto        numeric(10,2) CHECK (desconto >= 0),
    frete           numeric(10,2) CHECK (frete >= 0),
    total           numeric(10,2) CHECK (total >= 0)
);

-- Um cliente usa cada cupom uma vez (pedido cancelado não conta)
CREATE UNIQUE INDEX uq_cupom_por_cliente ON pedido (cliente_id, cupom_id)
    WHERE cupom_id IS NOT NULL AND status <> 'cancelado';

CREATE TABLE item_pedido (
    pedido_id      integer NOT NULL REFERENCES pedido (id),
    produto_id     integer NOT NULL REFERENCES produto (id),
    quantidade     integer NOT NULL CHECK (quantidade > 0),
    preco_unitario numeric(10,2) NOT NULL CHECK (preco_unitario > 0),   -- preço da época
    PRIMARY KEY (pedido_id, produto_id)
);

CREATE TABLE pagamento (
    id          integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    pedido_id   integer NOT NULL UNIQUE REFERENCES pedido (id),
    forma       varchar(10) NOT NULL CHECK (forma IN ('pix', 'cartao', 'boleto')),
    valor       numeric(10,2) NOT NULL CHECK (valor > 0),
    pago_em     timestamp NOT NULL DEFAULT LOCALTIMESTAMP
);

-- Histórico do estoque: entrada, saida (pedido fechado), estorno (pedido cancelado) e ajuste
CREATE TABLE movimento_estoque (
    id         bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    produto_id integer NOT NULL REFERENCES produto (id),
    tipo       varchar(10) NOT NULL CHECK (tipo IN ('entrada', 'saida', 'estorno', 'ajuste')),
    quantidade integer NOT NULL CHECK (quantidade <> 0),   -- negativo = saída
    pedido_id  integer REFERENCES pedido (id),
    criado_em  timestamp NOT NULL DEFAULT LOCALTIMESTAMP
);

-- Nota de 1 a 5; uma avaliação por cliente e produto. «Só quem comprou» é um trigger (arquivo 09).
CREATE TABLE avaliacao (
    id         integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cliente_id integer NOT NULL REFERENCES cliente (id),
    produto_id integer NOT NULL REFERENCES produto (id),
    nota       smallint NOT NULL CHECK (nota BETWEEN 1 AND 5),
    comentario varchar(200),
    criada_em  timestamp NOT NULL DEFAULT LOCALTIMESTAMP,
    UNIQUE (cliente_id, produto_id)
);

-- Auditoria das mudanças de status do pedido (preenchida por trigger, arquivo 09)
CREATE TABLE auditoria_pedido (
    id             bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    pedido_id      integer NOT NULL,
    status_antes   varchar(20),
    status_depois  varchar(20),
    usuario        text NOT NULL DEFAULT current_user,
    quando         timestamptz NOT NULL DEFAULT now()
);
