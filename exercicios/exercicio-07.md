# Exercício 7 — Window functions e view materializada

Banco de Dados 2 · Turma MBI-08 · Aula 15

SQL: *Structured Query Language*. CTE: *Common Table Expression* (consulta em etapas, cada etapa com um nome). View: uma consulta guardada com um nome. View materializada: uma view que guarda também o resultado.

| | |
|---|---|
| **Como fazer** | Em dupla, no banco da Loja Virtual |
| **Entrega** | Cada aluno entrega o arquivo `exercicio-07.sql` no Classroom |
| **Prazo** | Ideal: até o fim da aula 15. Vale até 18/11 |

## O que fazer

O Rafael, dono da loja, tem **10 perguntas** que pedem uma **posição** (quem ficou em 1º, em 2º...) ou uma **soma até aqui**. Para isso você usa uma **window function** (função de janela): ela olha as linhas vizinhas sem juntar as linhas.

Tudo vai em **um único arquivo**: `exercicio-07.sql`.

1. Abra o banco `loja` no seu cliente de banco de dados.
2. Crie o arquivo `exercicio-07.sql`.
3. Para cada consulta, nesta ordem:
   1. escreva um comentário com o número e a pergunta;
   2. escreva a etapa (a CTE) e **rode-a sozinha**;
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

Palavras que usamos sempre com o mesmo sentido: **etapa** (cada parte nomeada de uma CTE), **consulta de fora** (a que usa a etapa) e **posição** (o número que o `RANK` dá).

## Regras

- Escreva um **comentário em cada linha** do SQL (`--`), dizendo o que a linha faz. Isso ajuda você a estudar.
- Rode cada etapa **sozinha** antes de montar a consulta inteira.
- O `WHERE` não enxerga a posição na mesma consulta. Por isso a posição fica numa **etapa** e o filtro fica na consulta de fora.
- Empate recebe a mesma posição, e a posição seguinte pula (1, 1, 3).
- Não use `LIMIT` para cortar o resultado: o filtro é pela posição.
- Apoio: [referencia-window-functions.md](referencia-window-functions.md).

## Consulta 1 · Os 3 clientes que mais gastaram em cada estado

**Pergunta da loja:** «Quero ver os 3 clientes que mais gastaram em cada estado, para mandar um brinde.»

**O que mostrar:**

| uf | cliente | gasto | posicao |
|---|---|---|---|
| BA | Cliente 37 | 3417.96 | 1 |
| BA | Cliente 21 | 3361.47 | 2 |
| BA | Cliente 13 | 3248.49 | 3 |
| ... | ... | ... | ... |

### Passo a passo

1. **Etapa.** `gasto`: para cada cliente em cada UF (Unidade Federativa), a soma do `total` dos pedidos de venda.
2. **A posição.** Na etapa, acrescente `RANK() OVER (PARTITION BY dest_uf ORDER BY SUM(total) DESC)`. O `PARTITION BY` faz a contagem recomeçar em cada UF.
3. **Rode a etapa sozinha.** Termine com `SELECT * FROM gasto;`. Cada cliente tem uma posição.
4. **Consulta de fora.** Mostre só as linhas com `posicao <= 3`.
5. **Antes de rodar tudo**, escreva em um comentário quantas linhas você espera. Depois rode e compare.

### Exemplo resolvido

Digite (não cole), rode e reescreva os comentários com as suas palavras:

```sql
WITH gasto AS (
  SELECT p.dest_uf AS uf, c.nome AS cliente,
    SUM(p.total) AS gasto,
    RANK() OVER (PARTITION BY p.dest_uf
      ORDER BY SUM(p.total) DESC) AS posicao
  FROM pedido p
  JOIN cliente c ON c.id = p.cliente_id
  WHERE p.status IN ('pago', 'enviado', 'entregue')
  GROUP BY p.dest_uf, c.nome)
SELECT uf, cliente, gasto, posicao
FROM gasto
WHERE posicao <= 3
ORDER BY uf, posicao, cliente;
```

**Confira:** 25 linhas para 8 estados. Há empates: em `MG`, três clientes dividem o 1º lugar, e em `RS` quatro clientes entram no top 3.

### Agora a view

Logo depois da consulta, guarde-a com o nome `vw_top3_clientes_por_uf`:

```sql
CREATE OR REPLACE VIEW vw_top3_clientes_por_uf AS
___;   -- a consulta 1, sem o ponto e vírgula do fim

SELECT * FROM vw_top3_clientes_por_uf;
```

**Confira:** a view mostra as mesmas 25 linhas da consulta 1.

## Consulta 2 · Os 3 produtos mais vendidos de cada categoria

**Pergunta da loja:** «Quero ver os 3 produtos mais vendidos de cada categoria.»

**O que mostrar:**

| categoria | produto | unidades | posicao |
|---|---|---|---|
| Armazenamento | Gaveta HD Max | 30 | 1 |
| Armazenamento | HD externo Pro | 30 | 1 |
| Armazenamento | Pen drive Max | 30 | 1 |
| ... | ... | ... | ... |

### Passo a passo

1. **Etapa.** `ranking`: a soma de `quantidade` de cada produto, com a posição dentro da categoria. Ligue `item_pedido`, `pedido`, `produto` e `categoria`, só nas vendas.
2. **Rode a etapa sozinha.** Cada produto vendido aparece uma vez, com a posição dele.
3. **Consulta de fora.** Mostre as linhas com `posicao` até 3.
4. **Antes de rodar tudo**, escreva em um comentário quantas linhas você espera.

### Monte a consulta

Troque cada `___` e comente cada linha:

```sql
WITH ranking AS (
  SELECT cat.nome AS categoria, pr.nome AS produto,
    SUM(i.quantidade) AS unidades,
    RANK() OVER (PARTITION BY ___ ORDER BY SUM(i.quantidade) ___) AS posicao
  FROM item_pedido i
  JOIN pedido p ON ___
  JOIN produto pr ON ___
  JOIN categoria cat ON ___
  WHERE p.status IN (___)
  GROUP BY cat.nome, pr.nome)
SELECT categoria, produto, unidades, posicao
FROM ranking
WHERE posicao <= ___
ORDER BY categoria, posicao, produto;
```

**Confira:** 11 linhas (só 11 produtos foram vendidos, e nenhuma categoria passa de 3). Em `Armazenamento`, três produtos empatam no 1º lugar.

### Agora a view

Logo depois da consulta, guarde-a com o nome `vw_top3_produtos_por_categoria`:

```sql
CREATE OR REPLACE VIEW vw_top3_produtos_por_categoria AS
___;   -- a consulta 2, sem o ponto e vírgula do fim

SELECT * FROM vw_top3_produtos_por_categoria;
```

**Confira:** a view mostra as mesmas linhas da consulta 2.

## Consulta 3 · O primeiro pedido de cada cliente

**Pergunta da loja:** «Quero saber qual foi o primeiro pedido de venda de cada cliente.»

**O que mostrar:**

| nome | numero | dia |
|---|---|---|
| Cliente 01 | PD-2026-000040 | (data) |
| Cliente 02 | PD-2026-000081 | (data) |
| Cliente 03 | PD-2026-000002 | (data) |
| ... | ... | ... |

### Passo a passo

1. **Etapa.** `ranking`: os pedidos de venda com a posição de cada um na história do cliente. O mais antigo fica em 1º: ordene pela data do pedido, do mais antigo para o mais novo.
2. **Rode a etapa sozinha.** Cada cliente tem uma posição 1.
3. **Consulta de fora.** Junte com `cliente` e mostre só a posição 1. Para mostrar só o dia, use `criado_em::date`.
4. **Antes de rodar tudo**, escreva em um comentário quantas linhas você espera.

### Monte a consulta

Troque cada `___` e comente cada linha:

```sql
WITH ranking AS (
  SELECT cliente_id, numero, criado_em,
    RANK() OVER (PARTITION BY ___ ORDER BY ___) AS posicao
  FROM pedido
  WHERE status IN (___))
SELECT c.nome, r.numero, r.criado_em::date AS dia
FROM ranking r
JOIN cliente c ON ___
WHERE r.posicao = ___
ORDER BY c.nome;
```

**Confira:** 40 linhas, uma para cada cliente; a primeira é `Cliente 01`, pedido `PD-2026-000040`. O dia depende de quando você carregou a base.

### Agora a view

Logo depois da consulta, guarde-a com o nome `vw_primeiro_pedido_cliente`:

```sql
CREATE OR REPLACE VIEW vw_primeiro_pedido_cliente AS
___;   -- a consulta 3, sem o ponto e vírgula do fim

SELECT * FROM vw_primeiro_pedido_cliente;
```

**Confira:** a view mostra as mesmas linhas da consulta 3.

## Consulta 4 · Os 2 pedidos mais recentes de cada estado

**Pergunta da loja:** «Quero ver os 2 pedidos de venda mais recentes de cada estado.»

**O que mostrar:**

| uf | numero | dia | posicao |
|---|---|---|---|
| BA | PD-2026-000116 | (data) | 1 |
| BA | PD-2026-000100 | (data) | 2 |
| DF | PD-2026-000006 | (data) | 1 |
| ... | ... | ... | ... |

### Passo a passo

1. **Etapa.** `ranking`: os pedidos de venda com a posição de cada um dentro da UF. O mais novo fica em 1º: ordene pela data, do mais novo para o mais antigo.
2. **Rode a etapa sozinha.** Cada UF tem uma posição 1.
3. **Consulta de fora.** Mostre as linhas com `posicao` até 2.
4. **Antes de rodar tudo**, escreva em um comentário quantas linhas você espera.

### Monte a consulta

Troque cada `___` e comente cada linha:

```sql
WITH ranking AS (
  SELECT dest_uf AS uf, numero, criado_em,
    RANK() OVER (PARTITION BY ___ ORDER BY criado_em ___) AS posicao
  FROM pedido
  WHERE status IN (___))
SELECT uf, numero, criado_em::date AS dia, posicao
FROM ranking
WHERE posicao <= ___
ORDER BY uf, posicao;
```

**Confira:** 16 linhas (2 para cada um dos 8 estados); a primeira é `BA`, `PD-2026-000116`, posição 1.

### Agora a view

Logo depois da consulta, guarde-a com o nome `vw_pedidos_recentes_por_uf`:

```sql
CREATE OR REPLACE VIEW vw_pedidos_recentes_por_uf AS
___;   -- a consulta 4, sem o ponto e vírgula do fim

SELECT * FROM vw_pedidos_recentes_por_uf;
```

**Confira:** a view mostra as mesmas linhas da consulta 4.

## Consulta 5 · Quanto a loja recebeu por mês, e a soma até ali

**Pergunta da loja:** «Quero ver quanto a loja recebeu em cada mês e quanto já somou desde o primeiro mês.»

**O que mostrar:**

| mes | recebido | acumulado |
|---|---|---|
| (1º mês) | (valor) | (o mesmo valor) |
| (2º mês) | (valor) | (soma dos dois) |
| ... | ... | ... |

### Passo a passo

1. **Etapa.** `por_mes`: o mês de `pago_em` (`DATE_TRUNC('month', pago_em)::date`) e a soma de `valor` dos pagamentos.
2. **Rode a etapa sozinha.** Uma linha por mês, com o recebido só daquele mês.
3. **Consulta de fora.** Mostre `mes` e `recebido` e acrescente `SUM(recebido) OVER (ORDER BY mes)` como `acumulado`.
4. **Ordem.** Pelo mês.
5. **Antes de rodar tudo**, escreva em um comentário quantas linhas você espera.

### Estrutura

Escreva a consulta a partir destes comentários:

```sql
-- etapa: por_mes = o mês do pagamento (DATE_TRUNC) e a soma de valor (GROUP BY 1)
-- consulta de fora: mes, recebido e SUM(recebido) OVER (ORDER BY mes) AS acumulado
-- ORDER BY: mes
```

**Confira:** uma linha por mês. Na primeira linha, o `acumulado` é igual ao `recebido`. Na última linha, o `acumulado` é `73055.92`, o total de todos os pagamentos. O número de meses depende de quando você carregou a base.

### Agora a view

Logo depois da consulta, guarde-a com o nome `vw_recebido_acumulado`:

```sql
CREATE OR REPLACE VIEW vw_recebido_acumulado AS
___;   -- a consulta 5, sem o ponto e vírgula do fim

SELECT * FROM vw_recebido_acumulado;
```

**Confira:** a view mostra as mesmas linhas da consulta 5.

## Consulta 6 · O faturamento de cada categoria, mês a mês, com o acumulado

**Pergunta da loja:** «Quero ver o faturamento de cada categoria em cada mês e quanto cada categoria já somou.»

**O que mostrar:**

| categoria | mes | faturamento | acumulado |
|---|---|---|---|
| Armazenamento | (mês) | (valor) | (soma até ali) |
| Armazenamento | (mês) | (valor) | (soma até ali) |
| ... | ... | ... | ... |

### Passo a passo

1. **Etapa.** `por_mes`: o mês do pedido, a categoria e a soma de `quantidade * preco_unitario`, só nas vendas. Ligue `item_pedido`, `pedido`, `produto` e `categoria`.
2. **Rode a etapa sozinha.** Uma linha para cada categoria em cada mês com venda.
3. **Consulta de fora.** Acrescente `SUM(faturamento) OVER (PARTITION BY categoria ORDER BY mes)`. O `PARTITION BY` faz a soma recomeçar em cada categoria.
4. **Ordem.** Pela categoria e pelo mês.
5. **Antes de rodar tudo**, escreva em um comentário o que você espera na última linha de cada categoria.

### Estrutura

Escreva a consulta a partir destes comentários:

```sql
-- etapa: por_mes = mes (DATE_TRUNC do criado_em), categoria e SUM(quantidade * preco_unitario) das vendas
-- consulta de fora: categoria, mes, faturamento e SUM(faturamento) OVER (PARTITION BY categoria ORDER BY mes) AS acumulado
-- ORDER BY: categoria, mes
```

**Confira:** na última linha de `Componentes`, o `acumulado` é `36949.29`; na de `Armazenamento`, é `14977.35`.

### Agora a view

Logo depois da consulta, guarde-a com o nome `vw_faturamento_acumulado_categoria`:

```sql
CREATE OR REPLACE VIEW vw_faturamento_acumulado_categoria AS
___;   -- a consulta 6, sem o ponto e vírgula do fim

SELECT * FROM vw_faturamento_acumulado_categoria;
```

**Confira:** a view mostra as mesmas linhas da consulta 6.

## Consulta 7 · Os clientes do que mais gastou ao que menos gastou, com a soma até cada um

**Pergunta da loja:** «Quero ver os clientes do que mais gastou ao que menos gastou, com a soma dos gastos até cada um.»

**O que mostrar:**

| nome | gasto | acumulado |
|---|---|---|
| Cliente 25 | 3417.96 | 3417.96 |
| Cliente 37 | 3417.96 | 6835.92 |
| Cliente 09 | 3361.47 | 10197.39 |
| ... | ... | ... |

### Passo a passo

1. **Etapa.** `gasto`: o gasto de cada cliente (a soma do `total` dos pedidos de venda), como na consulta 3 do exercício 6.
2. **Rode a etapa sozinha.** Uma linha por cliente.
3. **Consulta de fora.** Junte com `cliente` e acrescente `SUM(gasto) OVER (ORDER BY gasto DESC, nome)`. Aqui não há `PARTITION BY`: a soma é uma só, para a loja inteira.
4. **Ordem.** Do maior gasto para o menor; no empate, pelo nome.
5. **Antes de rodar tudo**, escreva em um comentário quantas linhas você espera.

### Estrutura

Escreva a consulta a partir destes comentários:

```sql
-- etapa: gasto = o cliente_id e a soma de total dos pedidos de venda (GROUP BY cliente_id)
-- consulta de fora: nome, gasto e SUM(gasto) OVER (ORDER BY gasto DESC, nome) AS acumulado
-- JOIN com cliente; ORDER BY: gasto, maior primeiro, e depois o nome
```

**Confira:** 40 linhas; a primeira é `Cliente 25`, `3417.96`, acumulado `3417.96`. Na última linha, `Cliente 40`, o acumulado é `73055.92`.

### Agora a view

Logo depois da consulta, guarde-a com o nome `vw_gasto_acumulado_clientes`:

```sql
CREATE OR REPLACE VIEW vw_gasto_acumulado_clientes AS
___;   -- a consulta 7, sem o ponto e vírgula do fim

SELECT * FROM vw_gasto_acumulado_clientes;
```

**Confira:** a view mostra as mesmas linhas da consulta 7.

## Consulta 8 · Todos os produtos em um só ranking

**Pergunta da loja:** «Quero ver todos os produtos vendidos em um só ranking, do que vendeu mais ao que vendeu menos.»

**O que mostrar:**

| produto | unidades | posicao |
|---|---|---|
| Caixa de som Lite | 60 | 1 |
| Webcam Plus | 50 | 2 |
| Placa-mãe Pro | 40 | 3 |
| ... | ... | ... |

### Passo a passo

1. **A soma.** Some a `quantidade` de cada produto nas vendas (`GROUP BY` no nome do produto).
2. **A posição.** Acrescente `RANK() OVER (ORDER BY SUM(quantidade) DESC)`. **Sem `PARTITION BY`**: o ranking é um só, para a loja inteira.
3. **Ordem.** Pela posição e, no empate, pelo nome do produto.
4. **Antes de rodar tudo**, escreva em um comentário quantas linhas você espera.

**Confira:** 11 linhas; a primeira é `Caixa de som Lite`, 60 unidades, posição 1. Seis produtos empatam na posição 4, e o próximo é o `Mouse Lite`, na posição 10.

### Agora a view

Logo depois da consulta, guarde-a com o nome `vw_ranking_produtos`:

```sql
CREATE OR REPLACE VIEW vw_ranking_produtos AS
___;   -- a consulta 8, sem o ponto e vírgula do fim

SELECT * FROM vw_ranking_produtos;
```

**Confira:** a view mostra as mesmas linhas da consulta 8.

## Consulta 9 · O recebido por mês, guardado (view materializada)

**Pergunta da loja:** «O relatório do recebido por mês abre devagar. Quero guardar o resultado pronto.»

**O que mostrar:**

| mes | recebido |
|---|---|
| (mês) | (valor) |
| ... | ... |

### Passo a passo

1. **Crie a view materializada** `mv_recebido_mensal` (prefixo `mv_`): o mês de `pago_em` e a soma de `valor`, como a etapa da consulta 5.
2. **Veja o total guardado:** `SELECT SUM(recebido) FROM mv_recebido_mensal;`. Deve dar `73055.92`.
3. **Registre um pagamento de teste** e compare. Escreva em um comentário o que você espera em cada total **antes de rodar**:

```sql
INSERT INTO pagamento (pedido_id, forma, valor)
SELECT id, 'pix', 100.00 FROM pedido
WHERE status = 'aguardando_pagamento'
ORDER BY id LIMIT 1;

SELECT SUM(valor) FROM pagamento;
SELECT SUM(recebido) FROM mv_recebido_mensal;
```

4. **Atualize** a view materializada com `REFRESH MATERIALIZED VIEW mv_recebido_mensal;` e some de novo.
5. **Desfaça o teste**, para a base voltar ao que era:

```sql
DELETE FROM pagamento
WHERE forma = 'pix' AND valor = 100.00
  AND pedido_id IN (SELECT id FROM pedido WHERE status = 'aguardando_pagamento');
REFRESH MATERIALIZED VIEW mv_recebido_mensal;
```

**Confira:** depois do `INSERT`, a tabela soma `73155.92` e a view materializada ainda soma `73055.92`. Depois do `REFRESH`, as duas somam `73155.92`. Depois de desfazer, voltam a `73055.92`.

## Consulta 10 · Os 2 produtos que mais faturaram nas categorias fortes

**Pergunta da loja:** «Quero ver os 2 produtos que mais faturaram em cada categoria que faturou mais que a média das categorias.»

**O que mostrar:**

| categoria | produto | faturamento | posicao |
|---|---|---|---|
| Armazenamento | Pen drive Max | 7497.00 | 1 |
| ... | ... | ... | ... |

### Passo a passo

1. **Etapa 1.** `por_produto`: o faturamento de cada produto (`quantidade * preco_unitario`, somado), com a categoria, só nas vendas.
2. **Etapa 2.** `por_categoria`: o faturamento de cada categoria, somando a etapa 1.
3. **Etapa 3.** `ranking`: a posição de cada produto dentro da categoria dele, a partir da etapa 1.
4. **Consulta de fora.** Mostre as linhas com `posicao` até 2, só das categorias com faturamento maior que a média da etapa 2. Essa média é uma **subconsulta**, como na consulta 6 do exercício 6.
5. **Rode cada etapa sozinha**, terminando com `SELECT * FROM` o nome dela.
6. **Antes de rodar tudo**, escreva em um comentário quantas linhas você espera.

**Confira:** 4 linhas, de 2 categorias: `Armazenamento` (`Pen drive Max`, `7497.00`, e `Gaveta HD Max`, `4617.00`) e `Componentes` (`Placa-mãe Pro`, `23782.29`, e `Placa de vídeo Plus`, `13167.00`).

### Agora a view

Logo depois da consulta, guarde-a com o nome `vw_top2_produtos_categorias_fortes`:

```sql
CREATE OR REPLACE VIEW vw_top2_produtos_categorias_fortes AS
___;   -- a consulta 10, sem o ponto e vírgula do fim

SELECT * FROM vw_top2_produtos_categorias_fortes;
```

**Confira:** a view mostra as mesmas linhas da consulta 10.

## Para fixar (sem nota)

Responda em comentários, no fim do arquivo, **sem olhar o material**:

1. O `OVER` junta as linhas como o `GROUP BY`? O que ele faz?
2. Para que serve o `PARTITION BY` dentro do `OVER`?
3. Quando a view materializada mostra um dado novo?
