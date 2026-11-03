-- Projeto 3 · Loja virtual · 10_expansao_ddl.sql (expansão: a loja vira a empresa)
-- Estrutura dos módulos novos, em cima da base. Rode DEPOIS de 01_ddl.sql e 02_carga.sql.
-- Módulos: Compras e fornecedores · Entregas · Financeiro · Equipe e comissão · Devolução · Fidelidade.
-- Para repetir, rode TUDO de novo, na ordem, a partir de 01_ddl.sql (ele recria o schema). Rodar só este arquivo
-- de novo deixa sobras da carga nas tabelas da loja (cupons PTS-... e movimentos de estoque) e dá erro.
SET search_path TO loja;

-- ===== Limpeza (ordem inversa das dependências) =====
DROP TABLE IF EXISTS movimento_pontos, nivel_fidelidade, item_devolucao, devolucao, comissao, conta_pagar, conta_receber,
                     evento_remessa, remessa, transportadora_uf, transportadora,
                     item_pedido_compra, pedido_compra, produto_fornecedor, fornecedor CASCADE;
ALTER TABLE movimento_estoque DROP COLUMN IF EXISTS pedido_compra_id;
ALTER TABLE pedido DROP COLUMN IF EXISTS vendedor_id;
DROP TABLE IF EXISTS funcionario, cargo CASCADE;
ALTER TABLE produto DROP COLUMN IF EXISTS estoque_minimo, DROP COLUMN IF EXISTS custo_medio;

-- ===== Módulo 1 · Compras e fornecedores =====
-- O custo médio e o estoque mínimo ficam no produto: o preço de venda continua em preco_produto.
ALTER TABLE produto
    ADD COLUMN estoque_minimo integer NOT NULL DEFAULT 10 CHECK (estoque_minimo >= 0),
    ADD COLUMN custo_medio    numeric(10,2) NOT NULL DEFAULT 0 CHECK (custo_medio >= 0);

CREATE TABLE fornecedor (
    id                 integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome               varchar(100) NOT NULL,
    cnpj               char(14) NOT NULL UNIQUE,     -- fictício
    email              varchar(100) NOT NULL UNIQUE,
    prazo_entrega_dias integer NOT NULL CHECK (prazo_entrega_dias > 0),
    ativo              boolean NOT NULL DEFAULT true
);

-- Quem vende o quê e por quanto (N:N entre produto e fornecedor, com o custo como atributo da relação)
CREATE TABLE produto_fornecedor (
    produto_id     integer NOT NULL REFERENCES produto (id),
    fornecedor_id  integer NOT NULL REFERENCES fornecedor (id),
    custo_unitario numeric(10,2) NOT NULL CHECK (custo_unitario > 0),
    PRIMARY KEY (produto_id, fornecedor_id)
);

-- aberto → enviado ao fornecedor → recebido (ou cancelado). Os itens só mudam enquanto está aberto.
CREATE TABLE pedido_compra (
    id            integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    fornecedor_id integer NOT NULL REFERENCES fornecedor (id),
    status        varchar(10) NOT NULL DEFAULT 'aberto' CHECK (status IN ('aberto', 'enviado', 'recebido', 'cancelado')),
    criado_em     timestamp NOT NULL DEFAULT LOCALTIMESTAMP,
    previsto_para date,
    recebido_em   timestamp,
    CHECK ((status = 'recebido') = (recebido_em IS NOT NULL))
);

CREATE TABLE item_pedido_compra (
    pedido_compra_id integer NOT NULL REFERENCES pedido_compra (id),
    produto_id       integer NOT NULL REFERENCES produto (id),
    quantidade       integer NOT NULL CHECK (quantidade > 0),
    custo_unitario   numeric(10,2) NOT NULL CHECK (custo_unitario > 0),   -- custo da época, como o preço no item do pedido
    PRIMARY KEY (pedido_compra_id, produto_id)
);

-- A entrada de estoque de uma compra aponta para ela (a saída de venda já aponta para o pedido)
ALTER TABLE movimento_estoque ADD COLUMN pedido_compra_id integer REFERENCES pedido_compra (id);

-- ===== Módulo 2 · Entregas e logística =====
CREATE TABLE transportadora (
    id    integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome  varchar(80) NOT NULL UNIQUE,
    cnpj  char(14) NOT NULL UNIQUE,                  -- fictício
    ativa boolean NOT NULL DEFAULT true
);

-- Em quais UFs cada transportadora entrega e em quantos dias
CREATE TABLE transportadora_uf (
    transportadora_id integer NOT NULL REFERENCES transportadora (id),
    uf                char(2) NOT NULL REFERENCES frete_uf (uf),
    prazo_dias        integer NOT NULL CHECK (prazo_dias > 0),
    PRIMARY KEY (transportadora_id, uf)
);

-- Um pedido tem no máximo uma remessa
CREATE TABLE remessa (
    id                integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    pedido_id         integer NOT NULL UNIQUE REFERENCES pedido (id),
    transportadora_id integer NOT NULL REFERENCES transportadora (id),
    codigo_rastreio   varchar(20) NOT NULL UNIQUE,
    despachada_em     timestamp NOT NULL DEFAULT LOCALTIMESTAMP,
    prazo_previsto    date NOT NULL
);

-- Rastreio: cada passo da entrega vira uma linha; o status do pedido muda quando a entrega acontece
CREATE TABLE evento_remessa (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    remessa_id  integer NOT NULL REFERENCES remessa (id),
    tipo        varchar(20) NOT NULL CHECK (tipo IN ('coletado', 'em_transito', 'saiu_para_entrega', 'entregue', 'extraviado')),
    local       varchar(80),
    ocorrido_em timestamp NOT NULL DEFAULT LOCALTIMESTAMP
);

-- ===== Módulo 4 · Equipe e comissão (vem antes do Financeiro porque a conta a pagar aponta para o funcionário) =====
CREATE TABLE cargo (
    id                  integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome                varchar(40) NOT NULL UNIQUE,
    salario_base        numeric(10,2) NOT NULL CHECK (salario_base > 0),
    comissao_percentual numeric(4,2) NOT NULL DEFAULT 0 CHECK (comissao_percentual BETWEEN 0 AND 20)
);

CREATE TABLE funcionario (
    id          integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome        varchar(100) NOT NULL,
    cpf         char(11) NOT NULL UNIQUE,            -- fictício
    cargo_id    integer NOT NULL REFERENCES cargo (id),
    admitido_em date NOT NULL DEFAULT CURRENT_DATE,
    ativo       boolean NOT NULL DEFAULT true
);

-- O vendedor é opcional: pedido feito direto no site não tem vendedor, venda assistida (telefone, WhatsApp) tem.
ALTER TABLE pedido ADD COLUMN vendedor_id integer REFERENCES funcionario (id);

-- Uma comissão por pedido; competência = primeiro dia do mês em que o pedido foi entregue
CREATE TABLE comissao (
    id             integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    funcionario_id integer NOT NULL REFERENCES funcionario (id),
    pedido_id      integer NOT NULL UNIQUE REFERENCES pedido (id),
    competencia    date NOT NULL CHECK (competencia = date_trunc('month', competencia)::date),
    valor          numeric(10,2) NOT NULL CHECK (valor >= 0),
    gerada_em      timestamp NOT NULL DEFAULT LOCALTIMESTAMP
);

-- ===== Módulo 5 · Devolução (pós-venda) =====
CREATE TABLE devolucao (
    id              integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    pedido_id       integer NOT NULL REFERENCES pedido (id),
    motivo          varchar(120) NOT NULL,
    status          varchar(10) NOT NULL DEFAULT 'solicitada' CHECK (status IN ('solicitada', 'concluida', 'recusada')),
    solicitada_em   timestamp NOT NULL DEFAULT LOCALTIMESTAMP,
    concluida_em    timestamp,
    valor_reembolso numeric(10,2) CHECK (valor_reembolso >= 0),
    CHECK ((status = 'concluida') = (concluida_em IS NOT NULL))
);

-- Que produtos voltam e quantos. «Não devolve mais do que comprou» depende de outras tabelas (um CHECK não vê outras linhas).
CREATE TABLE item_devolucao (
    devolucao_id integer NOT NULL REFERENCES devolucao (id),
    produto_id   integer NOT NULL REFERENCES produto (id),
    quantidade   integer NOT NULL CHECK (quantidade > 0),
    PRIMARY KEY (devolucao_id, produto_id)
);

-- ===== Módulo 3 · Financeiro =====
-- Contas a receber: uma linha por parcela. O cartão cai 30 dias depois (repasse da operadora), o pix na hora,
-- o boleto em 2 dias. Se o cliente parcelar, a parcela única vira várias.
CREATE TABLE conta_receber (
    id             integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    pedido_id      integer NOT NULL REFERENCES pedido (id),
    parcela        smallint NOT NULL CHECK (parcela > 0),
    total_parcelas smallint NOT NULL CHECK (total_parcelas > 0),
    valor          numeric(10,2) NOT NULL CHECK (valor > 0),
    vencimento     date NOT NULL,
    recebido_em    timestamp,
    UNIQUE (pedido_id, parcela),
    CHECK (parcela <= total_parcelas)
);

-- Contas a pagar: compra de fornecedor, comissão, estorno de devolução e despesa avulsa.
-- Cada categoria exige a sua origem preenchida (o CHECK confere).
CREATE TABLE conta_pagar (
    id               integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    categoria        varchar(10) NOT NULL CHECK (categoria IN ('compra', 'comissao', 'estorno', 'despesa')),
    descricao        varchar(120) NOT NULL,
    valor            numeric(10,2) NOT NULL CHECK (valor > 0),
    vencimento       date NOT NULL,
    pago_em          timestamp,
    pedido_compra_id integer REFERENCES pedido_compra (id),
    devolucao_id     integer REFERENCES devolucao (id),
    funcionario_id   integer REFERENCES funcionario (id),
    competencia      date,
    CHECK (   (categoria = 'compra'   AND pedido_compra_id IS NOT NULL)
           OR (categoria = 'estorno'  AND devolucao_id IS NOT NULL)
           OR (categoria = 'comissao' AND funcionario_id IS NOT NULL AND competencia IS NOT NULL)
           OR (categoria = 'despesa'))
);
CREATE UNIQUE INDEX uq_conta_pagar_compra   ON conta_pagar (pedido_compra_id) WHERE pedido_compra_id IS NOT NULL;
CREATE UNIQUE INDEX uq_conta_pagar_estorno  ON conta_pagar (devolucao_id) WHERE devolucao_id IS NOT NULL;
CREATE UNIQUE INDEX uq_conta_pagar_comissao ON conta_pagar (funcionario_id, competencia) WHERE categoria = 'comissao';

-- ===== Módulo 6 · Fidelidade =====
CREATE TABLE nivel_fidelidade (
    id             integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome           varchar(20) NOT NULL UNIQUE,
    pontos_minimos integer NOT NULL UNIQUE CHECK (pontos_minimos >= 0),
    multiplicador  numeric(3,1) NOT NULL CHECK (multiplicador > 0)
);

-- O saldo de pontos NÃO é coluna: soma-se o extrato (como os usos do cupom). O sinal tem que combinar com o tipo.
CREATE TABLE movimento_pontos (
    id         bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cliente_id integer NOT NULL REFERENCES cliente (id),
    pedido_id  integer REFERENCES pedido (id),
    tipo       varchar(10) NOT NULL CHECK (tipo IN ('credito', 'resgate', 'estorno')),
    pontos     integer NOT NULL CHECK (pontos <> 0),
    criado_em  timestamp NOT NULL DEFAULT LOCALTIMESTAMP,
    CHECK ((tipo = 'credito' AND pontos > 0) OR (tipo IN ('resgate', 'estorno') AND pontos < 0))
);
-- Um pedido gera no máximo um crédito e um estorno
CREATE UNIQUE INDEX uq_pontos_credito_pedido ON movimento_pontos (pedido_id) WHERE tipo = 'credito';
CREATE UNIQUE INDEX uq_pontos_estorno_pedido ON movimento_pontos (pedido_id) WHERE tipo = 'estorno';
