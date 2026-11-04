# Referência — Subconsultas e CTE

Banco de Dados 2 · Turma MBI-08 · Aula 14

SQL: *Structured Query Language*. CTE: *Common Table Expression*.

## O que cada uma devolve

| A consulta de dentro devolve | Use na consulta de fora | Exemplo |
|---|---|---|
| Uma **lista** | `IN` ou `NOT IN` | `WHERE id NOT IN (SELECT cupom_id FROM pedido ...)` |
| Um **valor** | `>`, `<`, `=` | `WHERE valor > (SELECT AVG(valor) FROM pagamento)` |
| Um valor, na **lista de colunas** | `total - (SELECT AVG(total) ...)` | Diferença para a média |

## Como montar, em 4 passos

1. Escreva a consulta de dentro.
2. Rode ela **sozinha**.
3. Coloque ela entre parênteses, no `WHERE` (ou nas colunas).
4. Rode a consulta inteira.

## Funções novas deste exercício

| Função | O que faz | Exemplo |
|---|---|---|
| `AVG(coluna)` | Média | `SELECT AVG(valor) FROM pagamento;` |
| `MAX(coluna)` | Maior valor | `SELECT MAX(preco_unitario) FROM item_pedido;` |
| `IS NOT NULL` | Testa se há valor | `WHERE cupom_id IS NOT NULL` |

## Cuidado com o nulo

`NULL` é «sem valor». Se a lista do `NOT IN` tiver um `NULL`, o `NOT IN` não devolve nenhuma linha.

```sql
SELECT 7 NOT IN (1, 5, 9);     -- true
SELECT 7 NOT IN (1, 5, NULL);  -- nulo (não é true)
```

Solução: filtre o nulo na consulta de dentro (`WHERE coluna IS NOT NULL`).

## CTE

```sql
WITH etapa1 AS (        -- WITH abre a primeira etapa e dá um nome a ela
  SELECT ...
),                      -- uma vírgula separa as etapas; o WITH aparece uma vez só
etapa2 AS (             -- a etapa 2 pode usar a etapa 1 como se fosse uma tabela
  SELECT ... FROM etapa1
)
SELECT ... FROM etapa2; -- a consulta de fora usa as etapas
```

Para conferir uma etapa, termine com `SELECT * FROM` o nome dela.

## View

```sql
CREATE OR REPLACE VIEW vw_nome AS
SELECT ...;             -- a consulta, sem LIMIT
SELECT * FROM vw_nome;  -- usa a view como uma tabela
```
