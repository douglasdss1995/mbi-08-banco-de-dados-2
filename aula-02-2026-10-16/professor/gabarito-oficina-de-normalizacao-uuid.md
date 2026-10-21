# Gabarito — Oficina de normalização (planilhas A a E) com UUID

Versão do [`gabarito-oficina-de-normalizacao.md`](gabarito-oficina-de-normalizacao.md) com **toda chave primária e
estrangeira em `uuid`** (UUID: *Universally Unique Identifier*), para quem quiser comparar com o `integer`. Este arquivo é do
professor: **não vai para o Classroom** (é a solução do exercício, e não do exemplo guiado). O exemplo guiado, a Oficina Mecânica, está
em [`../../aula-03-2026-10-19/aluno/referencia-uuid.md`](../../aula-03-2026-10-19/aluno/referencia-uuid.md).

Regras aplicadas:

- Chave primária simples: `uuid PRIMARY KEY DEFAULT uuidv7()`.
- Chave composta (tabelas de ligação): continua composta, só que de duas colunas `uuid` (`PRIMARY KEY (cod_pedido, cod_produto)`).
- Código de negócio (`P-101`, `T-ING1`, `L-01`, número da consulta): fica como coluna com `UNIQUE`.
- Outros dados: tipos escolhidos pelo que o dado é (dinheiro em `numeric(10,2)`, data em `date`).

Os scripts foram testados no PostgreSQL 18, bloco a bloco: para rodar mais de um no mesmo banco, apague as tabelas antes,
porque `cliente` e `produto` se repetem em planilhas diferentes.

## A · Pedidos (papelaria)

```sql
CREATE TABLE cidade (
    cod_cidade uuid PRIMARY KEY DEFAULT uuidv7(),
    nome       varchar(80) NOT NULL,
    estado     char(2)     NOT NULL
);

CREATE TABLE cliente (
    cod_cliente uuid PRIMARY KEY DEFAULT uuidv7(),
    nome        varchar(100) NOT NULL,
    cod_cidade  uuid NOT NULL REFERENCES cidade (cod_cidade)
);

CREATE TABLE vendedor (
    cod_vendedor uuid PRIMARY KEY DEFAULT uuidv7(),
    nome         varchar(100) NOT NULL
);

CREATE TABLE produto (
    cod_produto uuid PRIMARY KEY DEFAULT uuidv7(),
    descricao   varchar(100) NOT NULL,
    preco       numeric(10,2) NOT NULL
);

CREATE TABLE pedido (
    cod_pedido   uuid PRIMARY KEY DEFAULT uuidv7(),
    numero       varchar(10) NOT NULL UNIQUE,          -- P-101
    data         date NOT NULL,
    cod_cliente  uuid NOT NULL REFERENCES cliente (cod_cliente),
    cod_vendedor uuid NOT NULL REFERENCES vendedor (cod_vendedor)
);

CREATE TABLE item_pedido (
    cod_pedido    uuid NOT NULL REFERENCES pedido (cod_pedido),
    cod_produto   uuid NOT NULL REFERENCES produto (cod_produto),
    quantidade    integer NOT NULL CHECK (quantidade > 0),
    preco_cobrado numeric(10,2) NOT NULL,
    PRIMARY KEY (cod_pedido, cod_produto)
);
```

## B · Matrículas (escola de idiomas)

```sql
CREATE TABLE aluno (
    cod_aluno uuid PRIMARY KEY DEFAULT uuidv7(),
    nome      varchar(100) NOT NULL
);

CREATE TABLE professor (
    cod_professor uuid PRIMARY KEY DEFAULT uuidv7(),
    nome          varchar(100) NOT NULL,
    fone          varchar(20)
);

CREATE TABLE turma (
    cod_turma     uuid PRIMARY KEY DEFAULT uuidv7(),
    codigo        varchar(10) NOT NULL UNIQUE,         -- T-ING1
    idioma        varchar(30) NOT NULL,
    nivel         varchar(30) NOT NULL,
    cod_professor uuid NOT NULL REFERENCES professor (cod_professor),
    sala          varchar(20),
    dia_semana    varchar(20),
    horario       time
);

CREATE TABLE matricula (
    cod_aluno      uuid NOT NULL REFERENCES aluno (cod_aluno),
    cod_turma      uuid NOT NULL REFERENCES turma (cod_turma),
    data_matricula date NOT NULL,
    nota_final     numeric(3,1),
    PRIMARY KEY (cod_aluno, cod_turma)
);
```

## C · Consultas (clínica)

```sql
CREATE TABLE convenio (
    cod_convenio uuid PRIMARY KEY DEFAULT uuidv7(),
    nome         varchar(50) NOT NULL,
    desconto     numeric(4,2) NOT NULL                 -- 0,30 = 30%
);

CREATE TABLE paciente (
    cod_paciente uuid PRIMARY KEY DEFAULT uuidv7(),
    nome         varchar(100) NOT NULL,
    cod_convenio uuid REFERENCES convenio (cod_convenio)   -- pode não ter convênio
);

CREATE TABLE especialidade (
    cod_especialidade uuid PRIMARY KEY DEFAULT uuidv7(),
    nome              varchar(50) NOT NULL,
    valor_base        numeric(10,2) NOT NULL
);

CREATE TABLE medico (
    cod_medico        uuid PRIMARY KEY DEFAULT uuidv7(),
    nome              varchar(100) NOT NULL,
    cod_especialidade uuid NOT NULL REFERENCES especialidade (cod_especialidade)
);

CREATE TABLE consulta (
    cod_consulta uuid PRIMARY KEY DEFAULT uuidv7(),
    numero       integer NOT NULL UNIQUE,
    data         date NOT NULL,
    cod_paciente uuid NOT NULL REFERENCES paciente (cod_paciente),
    cod_medico   uuid NOT NULL REFERENCES medico (cod_medico)
);
```

O valor final da consulta (`valor_base × (1 − desconto)`) é **derivado**: calcula-se na consulta, não se guarda.

## D · Aluguéis (equipamentos)

```sql
CREATE TABLE cliente (
    cod_cliente uuid PRIMARY KEY DEFAULT uuidv7(),
    nome        varchar(100) NOT NULL,
    telefone    varchar(20)
);

CREATE TABLE equipamento (
    cod_equipamento uuid PRIMARY KEY DEFAULT uuidv7(),
    descricao       varchar(100) NOT NULL,
    diaria          numeric(10,2) NOT NULL
);

CREATE TABLE contrato (
    cod_contrato uuid PRIMARY KEY DEFAULT uuidv7(),
    numero       varchar(10) NOT NULL UNIQUE,          -- L-01
    retirada     date NOT NULL,
    devolucao    date NOT NULL CHECK (devolucao >= retirada),
    cod_cliente  uuid NOT NULL REFERENCES cliente (cod_cliente)
);

CREATE TABLE item_contrato (
    cod_contrato    uuid NOT NULL REFERENCES contrato (cod_contrato),
    cod_equipamento uuid NOT NULL REFERENCES equipamento (cod_equipamento),
    diaria_cobrada  numeric(10,2) NOT NULL,
    PRIMARY KEY (cod_contrato, cod_equipamento)
);
```

`dias` e `total` são derivados (de `retirada` e `devolucao` e das diárias): ficam de fora. `contrato` e `equipamento` são
N:N (muitos para muitos), resolvido por `item_contrato`.

## E · Estoque (depósitos)

```sql
CREATE TABLE fornecedor (
    cod_fornecedor uuid PRIMARY KEY DEFAULT uuidv7(),
    nome           varchar(100) NOT NULL,
    fone           varchar(20)
);

CREATE TABLE produto (
    cod_produto    uuid PRIMARY KEY DEFAULT uuidv7(),
    nome           varchar(100) NOT NULL,
    categoria      varchar(50),
    custo_unit     numeric(10,2) NOT NULL,
    cod_fornecedor uuid NOT NULL REFERENCES fornecedor (cod_fornecedor)
);

CREATE TABLE deposito (
    cod_deposito uuid PRIMARY KEY DEFAULT uuidv7(),
    nome         varchar(100) NOT NULL,
    cidade       varchar(80)
);

CREATE TABLE estoque (
    cod_produto  uuid NOT NULL REFERENCES produto (cod_produto),
    cod_deposito uuid NOT NULL REFERENCES deposito (cod_deposito),
    quantidade   integer NOT NULL CHECK (quantidade >= 0),
    PRIMARY KEY (cod_produto, cod_deposito)
);
```

`estoque` é a tabela associativa N:N entre produto e depósito; a `quantidade` é atributo do **relacionamento**.

