# Exercício 6 — Subconsultas e CTE

Banco de Dados 2 · Turma MBI-08 · Aula 14

SQL: *Structured Query Language*. CTE: *Common Table Expression* (consulta em etapas, cada etapa com um nome). View: uma consulta guardada com um nome.

| | |
|---|---|
| **Como fazer** | Em dupla, no banco da Loja Virtual |
| **Entrega** | Cada aluno entrega o arquivo `exercicio-06.sql` no Classroom |
| **Prazo** | Ideal: até o fim da aula 14. Vale até 18/11 |

## O que fazer

O Rafael, dono da loja, tem **10 perguntas** que uma consulta simples não responde. Cada uma precisa de uma **consulta dentro de outra** (subconsulta) ou de uma **consulta em etapas** (CTE).

Tudo vai em **um único arquivo**: `exercicio-06.sql`.

1. Abra o banco `loja` no seu cliente de banco de dados.
2. Crie o arquivo `exercicio-06.sql`.
3. Para cada consulta, nesta ordem:
   1. escreva um comentário com o número e a pergunta;
   2. escreva a consulta de dentro e **rode-a sozinha**;
   3. escreva a consulta inteira;
   4. crie a view com a mesma consulta e consulte a view.
4. Escreva um comentário em cada linha do SQL.
5. Rode o arquivo inteiro, do zero, antes de entregar.
6. Responda as 3 perguntas de «Para fixar», em comentários, no fim do arquivo.
7. Entregue no Classroom.

## Como o exercício ajuda você

A ajuda diminui a cada consulta. Assim você aprende a fazer sozinho.

| Consultas | O que você recebe |
|---|---|
| 1 | O exemplo **resolvido**. Digite, rode e reescreva os comentários com as suas palavras |
| 2 a 4 | A consulta com **lacunas** (`___`) |
| 5 a 7 | Só a **estrutura**, em comentários |
| 8 a 10 | Só a **pergunta** e os passos |

Palavras que usamos sempre com o mesmo sentido: **consulta de dentro** (a subconsulta, entre parênteses), **consulta de fora** (a que usa o resultado da de dentro) e **etapa** (cada parte nomeada de uma CTE).

## Regras

- Escreva um **comentário em cada linha** do SQL (`--`), dizendo o que a linha faz. Isso ajuda você a estudar.
- Rode a consulta de dentro (ou cada etapa) **sozinha** antes de montar a consulta inteira.
- Não use `LIMIT` para cortar o resultado. Só a consulta 10 usa `LIMIT 1`, dentro da consulta de dentro, porque faz parte da pergunta.
- Apoio: [referencia-subconsultas-cte.md](referencia-subconsultas-cte.md).


## Consulta 1 · Cupons que nunca foram usados

**Pergunta da loja:** «Quero saber quais cupons nunca foram usados em nenhum pedido.»

**O que mostrar:**

| codigo | valido_ate |
|---|---|
| FRETE50 | (data) |
| MINIMO500 | (data) |
| NATAL20 | (data) |
| ... | ... |

### Passo a passo

1. **Consulta de dentro.** Os cupons usados estão em `pedido.cupom_id`. Escreva `SELECT cupom_id FROM pedido`.
2. **Cuidado com o nulo.** Pedido sem cupom tem `cupom_id` nulo, e um nulo na lista faz o `NOT IN` não devolver nada. Acrescente `WHERE cupom_id IS NOT NULL`.
3. **Rode a consulta de dentro sozinha.** Ela devolve uma lista de números, com repetição.
4. **Consulta de fora.** Mostre `codigo` e `valido_ate` dos cupons cujo `id` **não está** na lista: `WHERE id NOT IN (...)`.
5. **Antes de rodar tudo**, escreva em um comentário quantas linhas você espera. Depois rode e compare.

### Exemplo resolvido

Digite (não cole), rode e reescreva os comentários com as suas palavras:

```sql
SELECT codigo, valido_ate
FROM cupom
WHERE id NOT IN (
  SELECT cupom_id FROM pedido
  WHERE cupom_id IS NOT NULL)
ORDER BY codigo;
```

**Confira:** 7 cupons (entre eles `FRETE50`, `MINIMO500` e `NATAL20`; os dois `PTS-...` são da troca de pontos).

### Agora a view

Logo depois da consulta, guarde-a com o nome `vw_cupom_nunca_usado`:

```sql
CREATE OR REPLACE VIEW vw_cupom_nunca_usado AS
___;   -- a consulta 1, sem o ponto e vírgula do fim

SELECT * FROM vw_cupom_nunca_usado;
```

**Confira:** a view mostra as mesmas linhas da consulta 1.

## Consulta 2 · Pagamentos acima da média

**Pergunta da loja:** «Quero ver os pagamentos de valor maior que o valor médio dos pagamentos.»

**O que mostrar:**

| pedido_id | forma | valor |
|---|---|---|
| 64 | cartao | 2018.07 |
| 76 | cartao | 2018.07 |
| 88 | cartao | 2018.07 |
| ... | ... | ... |

### Passo a passo

1. **Consulta de dentro.** Ela devolve **um valor**: a média dos pagamentos (`AVG(valor)`), na tabela `pagamento`.
2. **Rode a consulta de dentro sozinha.** Deve aparecer um único número, perto de `811.73`.
3. **Consulta de fora.** Mostre `pedido_id`, `forma` e `valor` dos pagamentos com `valor >` a consulta de dentro, entre parênteses.
4. **Ordem.** Do maior valor para o menor; no empate, pelo `pedido_id`.
5. **Antes de rodar tudo**, escreva em um comentário quantas linhas você espera.

### Monte a consulta

Troque cada `___` e comente cada linha:

```sql
SELECT pedido_id, forma, valor
FROM ___
WHERE valor > (SELECT ___(valor) FROM pagamento)
ORDER BY ___ DESC, pedido_id;
```

**Confira:** 47 linhas; a primeira é o pedido `64`, `cartao`, `2018.07`.

### Agora a view

Logo depois da consulta, guarde-a com o nome `vw_pagamento_acima_media`:

```sql
CREATE OR REPLACE VIEW vw_pagamento_acima_media AS
___;   -- a consulta 2, sem o ponto e vírgula do fim

SELECT * FROM vw_pagamento_acima_media;
```

**Confira:** a view mostra as mesmas linhas da consulta 2.

## Consulta 3 · Quanto cada cliente já gastou

**Pergunta da loja:** «Quero saber quanto cada cliente já gastou nas compras feitas (pedidos pagos, enviados e entregues).»

**O que mostrar:**

| nome | gasto |
|---|---|
| Cliente 25 | 3417.96 |
| Cliente 37 | 3417.96 |
| Cliente 09 | 3361.47 |
| ... | ... |

### Passo a passo

1. **Etapa 1 (CTE).** Dê o nome `gasto` à etapa que soma o `total` dos pedidos de cada cliente: `SUM(total)` com `GROUP BY cliente_id`, só nas vendas.
2. **Rode a etapa sozinha.** Termine com `SELECT * FROM gasto;`. Deve ter uma linha por cliente.
3. **Consulta de fora.** Junte a etapa com `cliente` para mostrar o `nome` e o gasto.
4. **Ordem.** Do maior gasto para o menor; no empate, pelo nome.
5. **Antes de rodar tudo**, escreva em um comentário quantas linhas você espera.

### Monte a consulta

Troque cada `___` e comente cada linha:

```sql
WITH gasto AS (
  SELECT cliente_id, SUM(___) AS gasto
  FROM pedido
  WHERE status IN (___)
  GROUP BY ___)
SELECT c.nome, g.gasto
FROM gasto g JOIN cliente c ON ___
ORDER BY g.gasto DESC, c.nome;
```

**Confira:** 40 linhas (todos os clientes compraram); a primeira é `Cliente 25` com `3417.96`.

### Agora a view

Logo depois da consulta, guarde-a com o nome `vw_gasto_cliente`:

```sql
CREATE OR REPLACE VIEW vw_gasto_cliente AS
___;   -- a consulta 3, sem o ponto e vírgula do fim

SELECT * FROM vw_gasto_cliente;
```

**Confira:** a view mostra as mesmas linhas da consulta 3.

## Consulta 4 · Clientes que compraram periféricos

**Pergunta da loja:** «Quero a lista dos clientes que já compraram algum produto da categoria Periféricos.»

**O que mostrar:**

| nome |
|---|
| Cliente 01 |
| Cliente 02 |
| Cliente 04 |
| ... |

### Passo a passo

1. **Consulta de dentro.** Devolve uma **lista**: o `cliente_id` dos pedidos de venda que têm um produto da categoria `Periféricos`. Ligue `pedido`, `item_pedido`, `produto` e `categoria`.
2. **Rode a consulta de dentro sozinha.** Ela devolve números de clientes, com repetição.
3. **Consulta de fora.** Mostre o `nome` dos clientes cujo `id` **está** na lista: `WHERE id IN (...)`.
4. **Ordem.** Pelo nome.
5. **Antes de rodar tudo**, escreva em um comentário quantas linhas você espera.

### Monte a consulta

Troque cada `___` e comente cada linha:

```sql
SELECT nome
FROM cliente
WHERE id IN (
  SELECT p.cliente_id FROM pedido p
  JOIN item_pedido i ON ___
  JOIN produto pr ON ___
  JOIN categoria cat ON ___
  WHERE cat.nome = '___' AND p.status IN (___))
ORDER BY ___;
```

**Confira:** 30 clientes; o primeiro é `Cliente 01`.

### Agora a view

Logo depois da consulta, guarde-a com o nome `vw_cliente_periferico`:

```sql
CREATE OR REPLACE VIEW vw_cliente_periferico AS
___;   -- a consulta 4, sem o ponto e vírgula do fim

SELECT * FROM vw_cliente_periferico;
```

**Confira:** a view mostra as mesmas linhas da consulta 4.

## Consulta 5 · Pedidos acima ou abaixo do ticket médio

**Pergunta da loja:** «Quero ver cada pedido de venda com a diferença entre o total dele e o ticket médio.»

**O que mostrar:**

| numero | total | diferenca |
|---|---|---|
| PD-2026-000002 | 1295.40 | 483.67 |
| PD-2026-000003 | 121.80 | -689.93 |
| PD-2026-000004 | 1848.60 | 1036.87 |
| ... | ... | ... |

### Passo a passo

1. **Consulta de dentro.** O ticket médio: `AVG(total)` nos pedidos de venda. Devolve **um valor**.
2. **Rode a consulta de dentro sozinha.** Deve dar perto de `811.73`.
3. **Consulta de fora.** Desta vez a subconsulta fica **na lista de colunas**: `total - (consulta de dentro)`. Arredonde com `ROUND(..., 2)`.
4. **Filtro e ordem.** Só pedidos de venda, pelo `id`.
5. **Antes de rodar tudo**, escreva em um comentário quantas linhas você espera.

### Estrutura

Escreva a consulta a partir destes comentários:

```sql
-- consulta de dentro: o ticket médio, AVG(total), só dos pedidos de venda
-- consulta de fora: numero, total e a diferença (total menos a consulta de dentro, com ROUND de 2 casas)
-- WHERE: só pedidos de venda; ORDER BY: o id
```

**Confira:** 90 linhas; a primeira é `PD-2026-000002`, total `1295.40`, diferença `483.67`.

### Agora a view

Logo depois da consulta, guarde-a com o nome `vw_pedido_diferenca_media`:

```sql
CREATE OR REPLACE VIEW vw_pedido_diferenca_media AS
___;   -- a consulta 5, sem o ponto e vírgula do fim

SELECT * FROM vw_pedido_diferenca_media;
```

**Confira:** a view mostra as mesmas linhas da consulta 5.

## Consulta 6 · Categorias acima da média

**Pergunta da loja:** «Quero ver as categorias que faturaram mais que a média das categorias.»

**O que mostrar:**

| categoria | faturamento |
|---|---|
| Componentes | 36949.29 |
| Armazenamento | 14977.35 |

### Passo a passo

1. **Etapa 1 (CTE).** `por_categoria`: o faturamento de cada categoria (`quantidade * preco_unitario`, somado), só nas vendas. Ligue `item_pedido`, `pedido`, `produto` e `categoria`.
2. **Rode a etapa sozinha.** Deve ter 5 linhas.
3. **Consulta de fora.** Mostre as categorias com `faturamento >` a média dos faturamentos. A média é uma **subconsulta sobre a própria etapa**.
4. **Ordem.** Do maior faturamento para o menor.
5. **Antes de rodar tudo**, escreva em um comentário quantas linhas você espera.

### Estrutura

Escreva a consulta a partir destes comentários:

```sql
-- etapa 1: por_categoria = nome da categoria e a soma de quantidade * preco_unitario das vendas (GROUP BY categoria)
-- consulta de fora: categoria e faturamento da etapa 1
-- WHERE: faturamento maior que (SELECT AVG(faturamento) FROM por_categoria); ORDER BY: faturamento, maior primeiro
```

**Confira:** 2 categorias: `Componentes` (`36949.29`) e `Armazenamento` (`14977.35`).

### Agora a view

Logo depois da consulta, guarde-a com o nome `vw_categoria_acima_media`:

```sql
CREATE OR REPLACE VIEW vw_categoria_acima_media AS
___;   -- a consulta 6, sem o ponto e vírgula do fim

SELECT * FROM vw_categoria_acima_media;
```

**Confira:** a view mostra as mesmas linhas da consulta 6.

## Consulta 7 · Clientes que nunca avaliaram

**Pergunta da loja:** «Quero saber quais clientes nunca avaliaram nenhum produto.»

**O que mostrar:**

| nome |
|---|
| Cliente 02 |
| Cliente 04 |
| Cliente 06 |
| ... |

### Passo a passo

1. **Consulta de dentro.** Uma **lista**: o `cliente_id` de todas as linhas de `avaliacao`.
2. **Rode a consulta de dentro sozinha.** Veja a lista de números.
3. **Nulo?** `avaliacao.cliente_id` é obrigatório, então a lista não tem nulo. Confira olhando a lista.
4. **Consulta de fora.** Os clientes cujo `id` **não está** na lista (`NOT IN`).
5. **Antes de rodar tudo**, escreva em um comentário quantas linhas você espera.

### Estrutura

Escreva a consulta a partir destes comentários:

```sql
-- consulta de dentro: o cliente_id de todas as avaliações
-- consulta de fora: o nome dos clientes cujo id NÃO está na lista (NOT IN); ORDER BY: o nome
```

**Confira:** 20 clientes; o primeiro é `Cliente 02`.

### Agora a view

Logo depois da consulta, guarde-a com o nome `vw_cliente_sem_avaliacao`:

```sql
CREATE OR REPLACE VIEW vw_cliente_sem_avaliacao AS
___;   -- a consulta 7, sem o ponto e vírgula do fim

SELECT * FROM vw_cliente_sem_avaliacao;
```

**Confira:** a view mostra as mesmas linhas da consulta 7.

## Consulta 8 · O item de maior preço

**Pergunta da loja:** «Em quais pedidos aparece o item de maior preço unitário?»

**O que mostrar:**

| numero | preco_unitario |
|---|---|
| PD-2026-000012 | 621.39 |
| PD-2026-000024 | 621.39 |
| PD-2026-000036 | 621.39 |
| ... | ... |

### Passo a passo

1. **Consulta de dentro.** Devolve **um valor**: o maior `preco_unitario` da tabela `item_pedido` (`MAX`).
2. **Rode a consulta de dentro sozinha.** Anote o número.
3. **Consulta de fora.** Mostre o número do pedido e o preço dos itens com `preco_unitario =` a consulta de dentro. Ligue `item_pedido` a `pedido`.
4. **Ordem.** Pelo número do pedido.
5. **Antes de rodar tudo**, escreva em um comentário quantas linhas você espera.

**Confira:** 21 linhas; a primeira é `PD-2026-000012`, `621.39`.

### Agora a view

Logo depois da consulta, guarde-a com o nome `vw_pedido_item_mais_caro`:

```sql
CREATE OR REPLACE VIEW vw_pedido_item_mais_caro AS
___;   -- a consulta 8, sem o ponto e vírgula do fim

SELECT * FROM vw_pedido_item_mais_caro;
```

**Confira:** a view mostra as mesmas linhas da consulta 8.

## Consulta 9 · Clientes que gastaram mais que a média

**Pergunta da loja:** «Quero ver os clientes que gastaram mais que o gasto médio dos clientes.»

**O que mostrar:**

| nome | gasto |
|---|---|
| Cliente 25 | 3417.96 |
| Cliente 37 | 3417.96 |
| Cliente 09 | 3361.47 |
| ... | ... |

### Passo a passo

1. **Etapa 1 (CTE).** `gasto`: o total gasto por cliente, como na consulta 3.
2. **Etapa 2 (CTE).** `media`: a média da coluna `gasto` da etapa 1 (`AVG(gasto)`). Uma etapa pode usar a anterior.
3. **Rode cada etapa sozinha**, terminando com `SELECT * FROM` o nome dela.
4. **Consulta de fora.** Junte `gasto` com `media` (`ON g.gasto > m.valor`) e com `cliente`, para mostrar o nome.
5. **Ordem.** Do maior gasto para o menor; no empate, pelo nome.
6. **Antes de rodar tudo**, escreva em um comentário quantas linhas você espera.

**Confira:** 20 clientes; o primeiro é `Cliente 25` com `3417.96`.

### Agora a view

Logo depois da consulta, guarde-a com o nome `vw_cliente_acima_media`:

```sql
CREATE OR REPLACE VIEW vw_cliente_acima_media AS
___;   -- a consulta 9, sem o ponto e vírgula do fim

SELECT * FROM vw_cliente_acima_media;
```

**Confira:** a view mostra as mesmas linhas da consulta 9.

## Consulta 10 · Pedidos do cliente que mais gastou

**Pergunta da loja:** «Quero ver todos os pedidos do cliente que mais gastou.»

**O que mostrar:**

| numero | status | total |
|---|---|---|
| PD-2026-000024 | carrinho | (vazio) |
| PD-2026-000064 | pago | 2018.07 |
| PD-2026-000104 | entregue | 1399.89 |

### Passo a passo

1. **Consulta de dentro.** Devolve **um valor**: o `cliente_id` que mais gastou. Some o `total` por cliente nos pedidos de venda (`GROUP BY cliente_id`), ordene do maior para o menor e fique só com a primeira linha (`LIMIT 1`). No empate, o menor `cliente_id`.
2. **Rode a consulta de dentro sozinha.** Deve aparecer um número só.
3. **Consulta de fora.** Mostre `numero`, `status` e `total` de **todos** os pedidos desse cliente (`cliente_id =` a consulta de dentro), mesmo os que não são venda.
4. **Ordem.** Pelo `id`.
5. **Antes de rodar tudo**, escreva em um comentário quantas linhas você espera.
6. **Atenção.** Aqui o `LIMIT 1` faz parte da pergunta, dentro da consulta de dentro.

**Confira:** 3 pedidos, do cliente `25`; o primeiro é `PD-2026-000024` (um carrinho, sem total).

### Agora a view

Logo depois da consulta, guarde-a com o nome `vw_pedido_melhor_cliente`:

```sql
CREATE OR REPLACE VIEW vw_pedido_melhor_cliente AS
___;   -- a consulta 10, sem o ponto e vírgula do fim

SELECT * FROM vw_pedido_melhor_cliente;
```

**Confira:** a view mostra as mesmas linhas da consulta 10.

## Para fixar (sem nota)

Responda em comentários, no fim do arquivo, **sem olhar o material**:

1. A consulta de dentro devolve uma lista ou um valor? Dê um exemplo de cada, tirado deste exercício.
2. Por que rodar a consulta de dentro sozinha antes de montar a consulta inteira?
3. Quando você usaria uma CTE em vez de uma subconsulta?

