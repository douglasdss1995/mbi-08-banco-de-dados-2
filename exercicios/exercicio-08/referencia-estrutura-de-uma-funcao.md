# Referência de pesquisa — A estrutura de uma função

Banco de Dados 2 · Turma MBI-08 · Aulas 17 e 18

SQL: *Structured Query Language*. PL/pgSQL: *Procedural Language/PostgreSQL* (a linguagem de programação do PostgreSQL).

Esta referência explica **cada parte** de uma função: o que ela recebe, o que ela devolve e que tipos de variável você pode criar. Use-a para estudar e para pesquisar.
O que está marcado como **leitura extra** não é pedido nos exercícios nem cai na prova. Serve para você ir além.

Todos os exemplos rodam na base da Loja Virtual (`SET search_path TO loja;`).

## 1. A estrutura completa

```sql
CREATE OR REPLACE FUNCTION nome_da_funcao(      -- 1. o nome
    p_parametro tipo,                           -- 2. os parâmetros: o que ela recebe
    ...
)
RETURNS tipo                                    -- 3. o que ela devolve
LANGUAGE sql | plpgsql                          -- 4. a linguagem do corpo
IMMUTABLE | STABLE | VOLATILE                   -- 5. se ela lê ou muda dados (opcional)
AS $$
    ...                                         -- 6. o corpo
$$;
```

| Parte | O que é | Exemplo |
|---|---|---|
| 1. Nome | Como você chama a função. Use letras minúsculas e `_` | `calcular_frete` |
| 2. Parâmetros | O que a função recebe, cada um com um **tipo** | `(p_uf char, p_valor numeric)` |
| 3. `RETURNS` | O **tipo** do que ela devolve | `RETURNS numeric` |
| 4. `LANGUAGE` | `sql`: uma consulta. `plpgsql`: um programa, com variável e `IF` | `LANGUAGE plpgsql` |
| 5. Volatilidade | Diz ao banco o que a função faz com os dados (seção 5) | `STABLE` |
| 6. Corpo | Entre `$$` e `$$` | `SELECT ...;` ou `BEGIN ... END;` |

## 2. Os tipos que uma função recebe e devolve

Um parâmetro e o `RETURNS` aceitam **qualquer tipo** do PostgreSQL. Estes são os que a Loja Virtual usa:

| Tipo | O que guarda | Exemplo na loja |
|---|---|---|
| `integer` | Número inteiro | o `id` do pedido, a quantidade |
| `bigint` | Número inteiro grande | o resultado de `COUNT(*)` |
| `numeric` | Número com casas decimais, exato. Bom para dinheiro | o `total`, o frete |
| `text` | Texto de qualquer tamanho | uma mensagem, uma situação |
| `varchar` | Texto. Na tabela, com limite: `varchar(20)` | o código do cupom, o status |
| `char` | Texto de tamanho fixo: `char(2)` | a UF (Unidade Federativa) |
| `boolean` | `true` ou `false` | o produto está `ativo`? |
| `date` | Uma data | a validade do cupom |
| `timestamp` | Data e hora | quando o pedido foi fechado |
| `interval` | Um intervalo de tempo | `INTERVAL '48 hours'` |

- **No parâmetro, não escreva o tamanho.** Escreva `varchar`, e não `varchar(20)`: o tamanho é ignorado ali.
- O tipo do argumento tem de **combinar** com o do parâmetro. Se não combinar, o banco diz que a função não existe.

### Um parâmetro com valor padrão

O `DEFAULT` dá um valor ao parâmetro quando você não passa nada:

```sql
CREATE OR REPLACE FUNCTION valor_com_desconto(
    p_valor numeric,                            -- obrigatório
    p_percentual numeric DEFAULT 10)            -- se não passar, vale 10
RETURNS numeric
LANGUAGE sql IMMUTABLE AS $$
    SELECT ROUND(p_valor * (1 - p_percentual / 100), 2);
$$;

SELECT valor_com_desconto(200);                 -- 180.00 (usou os 10%)
SELECT valor_com_desconto(200, 25);             -- 150.00
```

Os parâmetros com `DEFAULT` ficam sempre **no fim** da lista.

## 3. O que uma função pode devolver

| Você quer devolver | Escreva | Como chamar | Visto em |
|---|---|---|---|
| **Um valor** | `RETURNS numeric` (ou outro tipo) | `SELECT calcular_frete('SP', 150);` | aula 17 |
| **Várias linhas**, com as colunas que você escolhe | `RETURNS TABLE (numero varchar, total numeric)` | `SELECT * FROM pedidos_do_cliente(25);` | aula 17, função 4 |
| **Uma linha inteira** de uma tabela | `RETURNS pedido` | `SELECT (pedido_pelo_numero('...')).status;` | leitura extra |
| **Várias linhas inteiras** de uma tabela | `RETURNS SETOF pedido` | `SELECT * FROM pedidos_aguardando();` | leitura extra |
| **Várias colunas numa linha só** | parâmetros `OUT` | `SELECT * FROM resumo_do_cliente(25);` | leitura extra |
| **Nada** | `RETURNS void` | `SELECT avisar('texto');` | leitura extra |
| A linha do gatilho | `RETURNS trigger` | o banco chama sozinho | aula 20 |

### Um valor (o mais comum)

```sql
CREATE OR REPLACE FUNCTION tem_estoque(p_produto integer)
RETURNS boolean                                 -- devolve true ou false
LANGUAGE sql STABLE AS $$
    SELECT estoque > 0 FROM produto WHERE id = p_produto;
$$;

SELECT tem_estoque(1);                          -- true
```

### Leitura extra: uma linha e várias linhas de uma tabela

```sql
CREATE OR REPLACE FUNCTION pedidos_aguardando()
RETURNS SETOF pedido                            -- várias linhas, com as colunas de pedido
LANGUAGE sql STABLE AS $$
    SELECT * FROM pedido WHERE status = 'aguardando_pagamento' ORDER BY id;
$$;

SELECT COUNT(*) FROM pedidos_aguardando();      -- 10 (com a base recém-carregada)
```

Com `RETURNS pedido` (sem `SETOF`), a função devolve **só a primeira linha** da consulta.

### Leitura extra: várias colunas numa linha (`OUT`)

```sql
CREATE OR REPLACE FUNCTION resumo_do_cliente(
    p_cliente integer,                          -- entra
    OUT pedidos bigint,                         -- sai: a 1ª coluna
    OUT gasto numeric)                          -- sai: a 2ª coluna
LANGUAGE sql STABLE AS $$
    SELECT COUNT(*), COALESCE(SUM(total), 0)
    FROM pedido
    WHERE cliente_id = p_cliente AND status IN ('pago', 'enviado', 'entregue');
$$;

SELECT * FROM resumo_do_cliente(25);            -- pedidos 2, gasto 3417.96
```

Com parâmetros `OUT`, não é preciso escrever `RETURNS`: o banco monta a linha com eles.

### Leitura extra: nada (`void`)

```sql
CREATE OR REPLACE FUNCTION avisar(p_texto text)
RETURNS void                                    -- não devolve nada
LANGUAGE plpgsql AS $$
BEGIN
    RAISE NOTICE 'Aviso: %', p_texto;           -- só mostra uma mensagem
END;
$$;
```

Para uma **ação** que grava dados, o certo é uma procedure (aula 19), e não uma função `void`.

## 4. As variáveis em PL/pgSQL

As variáveis só existem em `LANGUAGE plpgsql`. Elas ficam no `DECLARE`, antes do `BEGIN`, uma por linha: **nome, tipo e `;`**.

| Jeito de declarar | Exemplo | O que faz | Visto em |
|---|---|---|---|
| Só o tipo | `v_nome text;` | Começa vazia (`NULL`) | aula 17 |
| Com valor inicial | `v_contador integer := 0;` | Começa com 0 | leitura extra (o `:=` é da aula 18) |
| Com o tipo de uma coluna | `v_status pedido.status%TYPE;` | Copia o tipo da coluna `status` | leitura extra |
| A linha inteira de uma tabela | `p pedido%ROWTYPE;` | Guarda todas as colunas; leia com `p.total` | aula 18 |
| Constante | `c_taxa CONSTANT numeric := 0.10;` | Não pode mudar depois | leitura extra |
| Nunca vazia | `v_qtd integer NOT NULL := 1;` | Dá erro se ficar `NULL` | leitura extra |
| Qualquer linha | `r RECORD;` | Guarda a linha de qualquer consulta | leitura extra |
| Uma lista | `v_ids integer[] := ARRAY[1, 2, 3];` | Vários valores; `v_ids[2]` é o 2º | leitura extra |

Uma variável pode ter **qualquer tipo** da tabela da seção 2: `integer`, `numeric`, `text`, `boolean`, `date`, `timestamp`...

### Todos os jeitos num bloco só

Rode e veja a mensagem na aba de saída:

```sql
DO $$
DECLARE
    v_contador integer := 0;                    -- com valor inicial
    c_taxa     CONSTANT numeric := 0.10;        -- constante
    v_status   pedido.status%TYPE;              -- o mesmo tipo da coluna status
    p          pedido%ROWTYPE;                  -- a linha inteira do pedido
    r          RECORD;                          -- qualquer linha
    v_ids      integer[] := ARRAY[1, 2, 3];     -- uma lista de inteiros
BEGIN
    SELECT status INTO v_status FROM pedido WHERE id = 2;      -- guarda uma coluna
    SELECT * INTO p FROM pedido WHERE id = 2;                  -- guarda a linha toda
    SELECT nome, email INTO r FROM cliente WHERE id = 1;       -- guarda duas colunas
    v_contador := v_contador + 1;                              -- := muda o valor
    RAISE NOTICE 'status % · total % · nome % · 2º id % · taxa % · contador %',
        v_status, p.total, r.nome, v_ids[2], c_taxa, v_contador;
END $$;
```

**Confira:** `status pago · total 1295.40 · nome Cliente 01 · 2º id 2 · taxa 0.10 · contador 1`.

### Dar um valor a uma variável

| Jeito | Exemplo |
|---|---|
| `:=` com um valor ou uma conta | `v_contador := v_contador + 1;` |
| `:=` com outra função | `v_gasto := gasto_do_cliente(p_cliente);` |
| `SELECT ... INTO` | `SELECT estoque INTO v_estoque FROM produto WHERE id = p_produto;` |

Se você tentar mudar uma `CONSTANT`, o banco recusa: `variable "c_taxa" is declared CONSTANT`.

## 5. Volatilidade: o que a função faz com os dados

| Palavra | Quer dizer | Exemplo |
|---|---|---|
| `IMMUTABLE` | Só faz contas com os parâmetros. Não lê tabela. O mesmo argumento dá sempre o mesmo resultado | `valor_com_desconto(200, 10)` |
| `STABLE` | Lê tabelas, mas não muda nada | `calcular_frete`, `gasto_do_cliente` |
| `VOLATILE` | Pode mudar dados, ou dar resultado diferente a cada chamada. É o padrão, se você não escrever nada | uma função que grava |

Na dúvida, não escreva nada: o banco usa `VOLATILE`, que sempre funciona. `IMMUTABLE` e `STABLE` ajudam o banco a ganhar velocidade.

## 6. Para pesquisar

Perguntas para pesquisar (no manual ou com IA), testando a resposta no banco da loja:

1. Qual a diferença entre `numeric` e `real` para guardar dinheiro? Por que a loja usa `numeric`?
2. O que acontece se você chamar `calcular_frete(150, 'SP')`, com os argumentos trocados?
3. Quando usar `RETURNS TABLE (...)` e quando usar `RETURNS SETOF tabela`?
4. Qual a diferença entre `%TYPE` e `%ROWTYPE`? Por que copiar o tipo da coluna ajuda se a tabela mudar?
5. Uma função `IMMUTABLE` pode ler uma tabela? O que pode dar errado se você mentir para o banco?

O manual oficial do PostgreSQL, em inglês:

| Assunto | Endereço |
|---|---|
| `CREATE FUNCTION`: todas as partes | https://www.postgresql.org/docs/current/sql-createfunction.html |
| Os tipos de dados | https://www.postgresql.org/docs/current/datatype.html |
| Funções em `LANGUAGE sql` | https://www.postgresql.org/docs/current/xfunc-sql.html |
| As declarações do PL/pgSQL (`DECLARE`, `%TYPE`, `%ROWTYPE`, `RECORD`) | https://www.postgresql.org/docs/current/plpgsql-declarations.html |
| Volatilidade (`IMMUTABLE`, `STABLE`, `VOLATILE`) | https://www.postgresql.org/docs/current/xfunc-volatility.html |
