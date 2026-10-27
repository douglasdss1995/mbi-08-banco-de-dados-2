-- Projeto 5 · Delivery de comida · 01_ddl.sql (prova 1)
-- Estrutura do banco. Pode ser executado quantas vezes quiser: apaga o schema e recria.

DROP SCHEMA IF EXISTS delivery CASCADE;
CREATE SCHEMA delivery;
SET search_path TO delivery;

CREATE TABLE categoria_culinaria (
    id   integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome varchar(40) NOT NULL UNIQUE
);

-- A comissão padrão é de 15% dos itens; cada restaurante pode ter a sua.
CREATE TABLE restaurante (
    id             integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome           varchar(80) NOT NULL,
    categoria_id   integer NOT NULL REFERENCES categoria_culinaria (id),
    pedido_minimo  numeric(8,2) NOT NULL DEFAULT 0 CHECK (pedido_minimo >= 0),
    comissao_pct   numeric(5,2) NOT NULL DEFAULT 15 CHECK (comissao_pct BETWEEN 0 AND 100),
    preparo_min    smallint NOT NULL DEFAULT 30 CHECK (preparo_min > 0),   -- preparo estimado, em minutos
    ativo          boolean NOT NULL DEFAULT true
);

-- Horário por dia da semana. Quem fecha depois da meia-noite tem fecha MENOR que abre
-- (por exemplo, abre 18:00 e fecha 02:00 na sexta: o horário pertence ao dia em que abriu).
CREATE TABLE horario_funcionamento (
    id             integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    restaurante_id integer NOT NULL REFERENCES restaurante (id),
    dia_semana     smallint NOT NULL CHECK (dia_semana BETWEEN 0 AND 6),   -- 0 = domingo
    abre           time NOT NULL,
    fecha          time NOT NULL,
    CHECK (abre <> fecha),
    UNIQUE (restaurante_id, dia_semana, abre)
);

CREATE TABLE item_cardapio (
    id             integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    restaurante_id integer NOT NULL REFERENCES restaurante (id),
    nome           varchar(80) NOT NULL,
    disponivel     boolean NOT NULL DEFAULT true,
    detalhes       jsonb NOT NULL DEFAULT '{}'::jsonb,
    UNIQUE (restaurante_id, nome)
);

-- O preço NÃO fica no item: está aqui, com vigência, e o item do pedido copia o preço da época.
CREATE TABLE preco_item (
    id               integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    item_id          integer NOT NULL REFERENCES item_cardapio (id),
    preco            numeric(8,2) NOT NULL CHECK (preco > 0),
    vigencia_inicio  timestamp NOT NULL,
    UNIQUE (item_id, vigencia_inicio)
);

CREATE TABLE cliente (
    id       integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome     varchar(100) NOT NULL,
    email    varchar(100) NOT NULL UNIQUE,
    telefone varchar(20)
);

-- A distância (km) é um dado do endereço (D-27): o curso não usa geolocalização.
CREATE TABLE endereco (
    id           integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cliente_id   integer NOT NULL REFERENCES cliente (id),
    logradouro   varchar(120) NOT NULL,
    numero       varchar(10) NOT NULL,
    bairro       varchar(60) NOT NULL,
    distancia_km numeric(4,1) NOT NULL CHECK (distancia_km >= 0)
);

-- Faixas da taxa de entrega: até km_ate. A última faixa (km_ate NULL) vale para qualquer distância maior.
CREATE TABLE faixa_taxa (
    id     integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    km_ate numeric(4,1) UNIQUE,
    taxa   numeric(6,2) NOT NULL CHECK (taxa >= 0)
);

CREATE TABLE entregador (
    id     integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome   varchar(100) NOT NULL,
    status varchar(12) NOT NULL DEFAULT 'offline' CHECK (status IN ('disponivel', 'em_entrega', 'offline'))
);

-- O pedido guarda uma CÓPIA do endereço (dest_*) e os valores da época (subtotal, taxa, comissão), calculados ao criar.
CREATE TABLE pedido (
    id                  integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    numero              varchar(20) GENERATED ALWAYS AS
                        ('DL-' || EXTRACT(YEAR FROM criado_em)::int::text || '-' || LPAD(id::text, 6, '0')) STORED UNIQUE,
    cliente_id          integer NOT NULL REFERENCES cliente (id),
    restaurante_id      integer NOT NULL REFERENCES restaurante (id),
    status              varchar(12) NOT NULL DEFAULT 'criado'
                        CHECK (status IN ('criado', 'aceito', 'em_preparo', 'pronto', 'a_caminho', 'entregue', 'cancelado')),
    criado_em           timestamp NOT NULL DEFAULT LOCALTIMESTAMP,
    prometido_ate       timestamp NOT NULL,
    entregue_em         timestamp,
    dest_logradouro     varchar(120) NOT NULL,
    dest_numero         varchar(10) NOT NULL,
    dest_bairro         varchar(60) NOT NULL,
    dest_distancia_km   numeric(4,1) NOT NULL,
    subtotal            numeric(8,2) NOT NULL CHECK (subtotal >= 0),
    taxa_entrega        numeric(6,2) NOT NULL CHECK (taxa_entrega >= 0),
    total               numeric(8,2) NOT NULL CHECK (total >= 0),
    comissao_pct        numeric(5,2) NOT NULL,                 -- comissão do restaurante NO DIA do pedido
    cancelado_por       varchar(12) CHECK (cancelado_por IN ('cliente', 'restaurante')),
    cobranca_cancelamento numeric(8,2) CHECK (cobranca_cancelamento >= 0),
    CHECK (total = subtotal + taxa_entrega),
    CHECK ((status = 'cancelado') = (cancelado_por IS NOT NULL)),
    CHECK ((status = 'entregue') = (entregue_em IS NOT NULL))
);

-- opcoes (JSONB): «sem cebola», «queijo extra» e observações, que variam de item para item
CREATE TABLE item_pedido (
    pedido_id      integer NOT NULL REFERENCES pedido (id),
    item_id        integer NOT NULL REFERENCES item_cardapio (id),
    quantidade     integer NOT NULL CHECK (quantidade > 0),
    preco_unitario numeric(8,2) NOT NULL CHECK (preco_unitario > 0),
    opcoes         jsonb NOT NULL DEFAULT '{}'::jsonb,
    PRIMARY KEY (pedido_id, item_id)
);

-- Entrega é uma tabela à parte: se o entregador desiste e outro assume, o pedido ganha outra linha.
CREATE TABLE entrega (
    id            integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    pedido_id     integer NOT NULL REFERENCES pedido (id),
    entregador_id integer NOT NULL REFERENCES entregador (id),
    atribuida_em  timestamp NOT NULL DEFAULT LOCALTIMESTAMP,
    concluida_em  timestamp,
    status        varchar(10) NOT NULL DEFAULT 'ativa' CHECK (status IN ('ativa', 'concluida', 'desistiu', 'cancelada'))
);
-- Um pedido só tem uma entrega ativa, e um entregador só tem uma entrega ativa por vez (última barreira contra a corrida)
CREATE UNIQUE INDEX uq_entrega_ativa_por_pedido ON entrega (pedido_id) WHERE status = 'ativa';
CREATE UNIQUE INDEX uq_entrega_ativa_por_entregador ON entrega (entregador_id) WHERE status = 'ativa';

CREATE TABLE pagamento (
    id        integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    pedido_id integer NOT NULL UNIQUE REFERENCES pedido (id),
    forma     varchar(10) NOT NULL CHECK (forma IN ('pix', 'cartao', 'dinheiro')),
    valor     numeric(8,2) NOT NULL CHECK (valor >= 0),
    situacao  varchar(10) NOT NULL DEFAULT 'pendente' CHECK (situacao IN ('pendente', 'pago')),
    pago_em   timestamp
);

-- Uma avaliação por pedido entregue (UNIQUE em pedido_id); a nota do restaurante e a do entregador vão juntas.
CREATE TABLE avaliacao (
    id                integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    pedido_id         integer NOT NULL UNIQUE REFERENCES pedido (id),
    nota_restaurante  smallint NOT NULL CHECK (nota_restaurante BETWEEN 1 AND 5),
    nota_entregador   smallint NOT NULL CHECK (nota_entregador BETWEEN 1 AND 5),
    comentario        varchar(200)
);

-- Histórico: cada mudança de status com a hora (o tempo de cada etapa sai da diferença entre linhas)
CREATE TABLE historico_status (
    id            bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    pedido_id     integer NOT NULL REFERENCES pedido (id),
    status_antes  varchar(12),
    status_depois varchar(12) NOT NULL,
    usuario       text NOT NULL DEFAULT current_user,
    quando        timestamp NOT NULL DEFAULT LOCALTIMESTAMP
);
