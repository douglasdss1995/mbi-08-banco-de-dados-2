# UUID: chave primária que não depende de contador

Leitura de apoio da aula 3. Nos exemplos do curso, a chave primária que o banco numera é `integer GENERATED ALWAYS AS
IDENTITY` ([`referencia-identity-x-serial.md`](referencia-identity-x-serial.md)). Existe outra escolha muito usada: o
**UUID** (*Universally Unique Identifier*, identificador único universal). Este texto explica o que é, quando usar e mostra
as tabelas da **Oficina Mecânica**, o exemplo normalizado na aula 2, reescritas com UUID no lugar de `integer`.

## O que é um UUID

É um número de **128 bits** (16 bytes), escrito em 32 dígitos hexadecimais, separados por hífens em 5 grupos:

```text
019a14f8-40f0-78f6-a403-b839d25e8927
```

Ele é gerado de um jeito que torna a repetição **praticamente impossível**, sem precisar de um contador central. Por isso,
dois sistemas diferentes (ou dois bancos, ou o aplicativo e o banco) podem criar códigos ao mesmo tempo sem combinar nada.

O PostgreSQL tem o tipo `uuid`. Ele aceita o texto com ou sem hífens e em maiúsculas ou minúsculas, e recusa o que não é
um UUID:

```sql
SELECT 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid;    -- ok
SELECT 'A0EEBC999C0B4EF8BB6D6BB9BD380A11'::uuid;        -- ok, mesmo valor, sem hífens
SELECT 'abc'::uuid;
-- ERROR:  invalid input syntax for type uuid: "abc"
```

## As versões que importam

| Versão | Como é gerado | Função no PostgreSQL 18 | Característica |
|---|---|---|---|
| v4 | 122 bits aleatórios | `gen_random_uuid()` ou `uuidv4()` | Sem ordem nenhuma |
| v7 | Hora (milissegundos) + bits aleatórios | `uuidv7()` | **Cresce com o tempo** |

```sql
SELECT uuidv7(), uuidv4();
SELECT uuid_extract_version(uuidv7());       -- 7
SELECT uuid_extract_timestamp(uuidv7());     -- o momento em que foi gerado
SELECT uuidv7() < uuidv7();                  -- true: o segundo é maior
```

**No curso, prefira o v7.** A diferença aparece no índice da chave primária: um código que só cresce vai sempre para o final
do índice, como o `integer`; um código aleatório cai em qualquer ponto e obriga o banco a abrir espaço no meio. Medimos
500 mil linhas inseridas em cada tabela (PostgreSQL 18):

| Chave primária | Tamanho do índice | Tamanho da tabela |
|---|---|---|
| `integer` com `IDENTITY` | 11 MB | 17 MB |
| `uuid` v7 | 15 MB | 25 MB |
| `uuid` v4 | **19 MB** | 25 MB |

O v7 também respeita a ordem de criação: ao ordenar pelo código, todas as linhas aparecem na ordem em que foram inseridas.
No v4, só metade dos pares aparece em ordem (ou seja, é como sortear).

## UUID ou IDENTITY?

| | `integer IDENTITY` | `uuid` |
|---|---|---|
| Tamanho | 4 bytes | 16 bytes |
| Legibilidade | `cliente 42` | `019a14f8-40f0-78f6-...` |
| Quem gera | Só o banco | O banco, o aplicativo ou outro sistema |
| Dá para adivinhar o próximo? | Sim (43, 44...) | Não |
| Juntar dados de dois bancos | Códigos colidem | Sem colisão |
| Índices e chaves estrangeiras | Menores e mais rápidos | Maiores |
| Ordenar por criação | Sim | v7 sim, v4 não |

**Use UUID quando:**

- o código aparece em **endereços ou links** (`/pedido/42` deixa qualquer um tentar o 43; com UUID não há o que tentar);
- o código precisa ser criado **fora do banco** (pelo aplicativo, por um celular sem conexão), antes do `INSERT`;
- vai **juntar bancos** ou replicar dados entre sistemas;
- não quer revelar **quantos registros existem** (o número de pedidos da loja, por exemplo).

**Prefira `integer IDENTITY` quando:**

- o banco é **um só** e o código é interno;
- o código precisa ser **lido e digitado por pessoas** (número do chamado, do pedido);
- a tabela tem **muitas chaves estrangeiras** (cada FK repete o código: 16 bytes em vez de 4).

**UUID não é segurança.** Um UUID difícil de adivinhar não substitui a verificação de permissão. O v7 revela quando o
registro foi criado (a hora está nos primeiros bits), então não use v7 em um código que não deve expor a data.

## Como declarar

```sql
CREATE TABLE cliente (
    cod_cliente uuid PRIMARY KEY DEFAULT uuidv7(),
    nome        varchar(100) NOT NULL
);

CREATE TABLE pedido (
    cod_pedido  uuid PRIMARY KEY DEFAULT uuidv7(),
    cod_cliente uuid NOT NULL REFERENCES cliente (cod_cliente)
);
```

Três diferenças em relação ao `IDENTITY`:

1. **Não existe `GENERATED ALWAYS` para UUID.** O código vem de um `DEFAULT`, então o banco **aceita** um código digitado à
   mão. A proteção que o `IDENTITY` dava (recusar valor manual) não existe aqui.
2. **Não há sequência.** Sem `nextval`, sem `setval`, sem buracos para explicar ([`referencia-sequences.md`](referencia-sequences.md)).
3. **A chave estrangeira também é `uuid`.** Toda coluna que aponta para a chave precisa do mesmo tipo.

Como pegar o código de uma linha recém-criada, para usar em outra:

```sql
INSERT INTO cliente (nome) VALUES ('Lia Prado') RETURNING cod_cliente;
```

Ou deixe o banco ligar tudo com uma consulta, sem copiar o código à mão:

```sql
INSERT INTO pedido (cod_cliente)
SELECT cod_cliente FROM cliente WHERE nome = 'Lia Prado';
```

## Chave de negócio continua existindo

Na Oficina, o veículo era identificado pela placa (`ABC1D23`) e a ordem de serviço pelo número (`1001`). Esses códigos têm **significado para as
pessoas**. Ao trocar a chave primária por UUID, o código de negócio vira uma coluna comum, com `UNIQUE`, para ninguém
repetir:

```sql
numero  varchar(10) NOT NULL UNIQUE
```

A escolha entre chave natural e chave substituta é o tema da aula 9; aqui basta lembrar: **UUID é uma chave substituta**, e o
dado do negócio precisa de `UNIQUE`.

---

# A Oficina Mecânica com UUID

Abaixo, as 7 tabelas da Oficina Mecânica, o exemplo que normalizamos juntos na aula 2 (veja
[`gabarito-oficina-mecanica.md`](../../aula-02-2026-10-16/aluno/gabarito-oficina-mecanica.md)), com **toda chave primária e
estrangeira em `uuid`**. Use como referência para ver o que muda ao trocar o tipo da chave. Regras aplicadas:

- Chave primária simples: `uuid PRIMARY KEY DEFAULT uuidv7()`.
- Chave composta (tabela de ligação): continua composta, só que de duas colunas (`PRIMARY KEY (cod_os, cod_servico)`).
- Dado de negócio que era a chave (a **placa** do veículo e o **número** da OS): vira coluna comum com `UNIQUE`.
- Outros dados: tipos escolhidos pelo que o dado é (dinheiro em `numeric(10,2)`, data em `date`, placa em `char(7)`).

O script foi testado no PostgreSQL 18; a ordem de criação importa (a tabela referenciada vem antes).

```sql
CREATE TABLE cliente (
    cod_cliente uuid PRIMARY KEY DEFAULT uuidv7(),
    nome        varchar(100) NOT NULL,
    telefone    varchar(20)
);

CREATE TABLE modelo (
    cod_modelo uuid PRIMARY KEY DEFAULT uuidv7(),
    nome       varchar(50) NOT NULL,
    marca      varchar(50) NOT NULL
);

CREATE TABLE veiculo (
    cod_veiculo uuid PRIMARY KEY DEFAULT uuidv7(),
    placa       char(7) NOT NULL UNIQUE,
    cod_modelo  uuid NOT NULL REFERENCES modelo (cod_modelo),
    cod_cliente uuid NOT NULL REFERENCES cliente (cod_cliente)
);

CREATE TABLE mecanico (
    cod_mecanico  uuid PRIMARY KEY DEFAULT uuidv7(),
    nome          varchar(100) NOT NULL,
    especialidade varchar(50)
);

CREATE TABLE servico (
    cod_servico uuid PRIMARY KEY DEFAULT uuidv7(),
    descricao   varchar(100) NOT NULL,
    valor       numeric(10,2) NOT NULL
);

CREATE TABLE ordem_servico (
    cod_os       uuid PRIMARY KEY DEFAULT uuidv7(),
    numero       integer NOT NULL UNIQUE,
    data         date NOT NULL DEFAULT CURRENT_DATE,
    cod_veiculo  uuid NOT NULL REFERENCES veiculo (cod_veiculo),
    cod_mecanico uuid NOT NULL REFERENCES mecanico (cod_mecanico)
);

CREATE TABLE item_servico (
    cod_os        uuid NOT NULL REFERENCES ordem_servico (cod_os),
    cod_servico   uuid NOT NULL REFERENCES servico (cod_servico),
    valor_cobrado numeric(10,2) NOT NULL,
    PRIMARY KEY (cod_os, cod_servico)
);
```

Como inserir sem copiar um UUID à mão: use `RETURNING` e `SELECT`, deixando o banco ligar as chaves:

```sql
WITH c AS (INSERT INTO cliente (nome) VALUES ('Ana Souza') RETURNING cod_cliente),
     m AS (INSERT INTO modelo (nome, marca) VALUES ('Gol', 'Volkswagen') RETURNING cod_modelo)
INSERT INTO veiculo (placa, cod_modelo, cod_cliente)
SELECT 'ABC1D23', cod_modelo, cod_cliente FROM c, m;
```

Depois, as consultas continuam iguais: só se escreve `JOIN ... USING (cod_veiculo)` no lugar do número.

## O que mudou em relação à versão com `integer`

- **Nada na normalização.** As tabelas, as colunas e as relações são as mesmas. Só o tipo da chave mudou.
- **O código de negócio ganhou `UNIQUE`** (a placa do veículo e o número da OS). Antes ele era a própria chave.
- **As chaves estrangeiras ocupam mais espaço:** 16 bytes em vez de 4, em todas as tabelas de ligação.
- **A ordem de criação continua importando:** cria-se primeiro a tabela referenciada (`cidade` antes de `cliente`).

## Resumo

- UUID é um código de 128 bits, gerado sem contador central, com tipo próprio (`uuid`) no PostgreSQL.
- No PostgreSQL 18, use `uuidv7()`: ele cresce com o tempo e mantém o índice compacto. O v4 (`gen_random_uuid()`) é
  aleatório e deixa o índice maior.
- Compensa quando o código aparece em links, é gerado fora do banco ou o dado será juntado com outro banco. Para um banco
  único, com código interno, o `integer IDENTITY` é menor e mais simples.
- UUID não tem `GENERATED ALWAYS`: o banco aceita código digitado, e o código de negócio continua pedindo `UNIQUE`.
