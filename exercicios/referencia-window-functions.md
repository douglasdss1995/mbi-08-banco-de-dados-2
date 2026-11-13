# Referência — Window functions e view materializada

Banco de Dados 2 · Turma MBI-08 · Aula 15

SQL: *Structured Query Language*. CTE: *Common Table Expression*. UF: Unidade Federativa.

## GROUP BY ou OVER?

| | `GROUP BY` | `OVER` (window function) |
|---|---|---|
| Linhas do resultado | **Uma por grupo** | **Todas**, com uma coluna a mais |
| Serve para | «Quanto vendeu cada categoria?» | «Qual a posição deste produto na categoria?» |

## As duas window functions desta aula

| Função | O que faz | Exemplo |
|---|---|---|
| `RANK() OVER (...)` | Dá a **posição** de cada linha. Empate recebe a mesma posição, e a seguinte pula | `RANK() OVER (PARTITION BY dest_uf ORDER BY SUM(total) DESC)` |
| `SUM(x) OVER (...)` | Soma **até a linha atual** (a soma acumulada) | `SUM(faturamento) OVER (ORDER BY mes)` |

## Dentro do OVER

| Parte | O que faz | Sem ela |
|---|---|---|
| `PARTITION BY coluna` | Separa as linhas em **grupos**. A conta recomeça em cada grupo | Um grupo só, para a tabela inteira |
| `ORDER BY coluna` | Diz **quem vem primeiro** dentro do grupo. Com `DESC`, o maior fica em 1º | O `RANK` não tem como ordenar. No `SUM`, o resultado vira o total em todas as linhas |

## Como montar, em 4 passos

1. Escreva a consulta com `GROUP BY` (uma linha por produto, por cliente...). Rode.
2. Acrescente a coluna com `RANK() OVER (...)` ou `SUM() OVER (...)`. Rode: as linhas continuam as mesmas, só ganham a coluna.
3. Coloque essa consulta numa **etapa** de uma CTE (`WITH`).
4. Na consulta de fora, filtre pela posição (`WHERE posicao <= 3`).

## Por que o filtro fica de fora

O `WHERE` roda **antes** do `RANK`. Ele não enxerga a posição na mesma consulta. Por isso a posição vira uma etapa, e o filtro fica na consulta de fora.

```sql
WITH ranking AS (          -- a etapa calcula a posição
  SELECT categoria, produto,
    RANK() OVER (PARTITION BY categoria ORDER BY unidades DESC) AS posicao
  FROM vendas)
SELECT categoria, produto   -- a consulta de fora filtra
FROM ranking
WHERE posicao = 1;
```

## Soma acumulada

```sql
SELECT mes, faturamento,
  SUM(faturamento) OVER (ORDER BY mes) AS acumulado   -- soma o mês e todos os anteriores
FROM por_mes
ORDER BY mes;
```

Com `PARTITION BY categoria`, a soma recomeça em cada categoria.

## View e view materializada

| | View | View materializada |
|---|---|---|
| Guarda | A **consulta** | A consulta e o **resultado** |
| Mostra | Sempre o dado de agora | O dado da última atualização |
| Atualiza | Sozinha | Só com `REFRESH MATERIALIZED VIEW nome;` |
| Nome | `vw_...` | `mv_...` |
| Criar | `CREATE OR REPLACE VIEW vw_nome AS SELECT ...;` | `CREATE MATERIALIZED VIEW mv_nome AS SELECT ...;` |

Use a materializada quando a conta é pesada e o dado pode esperar a próxima atualização, como um relatório mensal.

## Cuidados

- Empate: dois produtos em 1º lugar, o próximo é o 3º (1, 1, 3).
- `RANK() OVER (ORDER BY ...)` sem `PARTITION BY` faz um ranking só, para a tabela inteira.
- O `ORDER BY` de dentro do `OVER` não ordena o resultado. Para ordenar o resultado, use o `ORDER BY` no fim da consulta.
