# Referência — funções SQL e view simples

Banco de Dados 2 · Aula 13 (03/11/2026)

SQL: *Structured Query Language*. Os exemplos rodam no banco da Loja Virtual. Antes, rode: `SET search_path TO loja;`

## Texto

| Função | Faz | Exemplo | Resultado |
|---|---|---|---|
| `LPAD(t, n, c)` | Completa à esquerda até `n` caracteres | `LPAD('7', 6, '0')` | `000007` |
| `UPPER`, `LOWER` | Maiúsculas, minúsculas | `UPPER('mouse')` | `MOUSE` |
| `INITCAP(t)` | Primeira letra de cada palavra maiúscula | `INITCAP('maria silva')` | `Maria Silva` |
| `TRIM(t)` | Tira os espaços das pontas | `TRIM('  Ana ')` | `Ana` |
| `REPLACE(t, de, para)` | Troca um trecho | `REPLACE('SKU-0001', 'SKU-', '')` | `0001` |
| `SUBSTRING(t FROM i FOR n)` | Pedaço do texto | `SUBSTRING('11111118919' FROM 1 FOR 3)` | `111` |
| `POSITION(p IN t)` | Posição de `p` em `t` | `POSITION('@' IN 'ana@x.test')` | `4` |
| `LEFT(t, n)`, `RIGHT(t, n)` | Os primeiros ou os últimos `n` caracteres | `RIGHT('01000311', 3)` | `311` |
| `a \|\| b` | Junta textos | `'PD-' \|\| '000001'` | `PD-000001` |

## Números

| Função | Faz | Exemplo | Resultado |
|---|---|---|---|
| `ROUND(x, n)` | Arredonda para `n` casas | `ROUND(71.866, 2)` | `71.87` |
| `CEIL(x)` | Arredonda para cima | `CEIL(71.87)` | `72` |
| `FLOOR(x)` | Arredonda para baixo | `FLOOR(71.87)` | `71` |

## Data e hora

| Função | Faz | Exemplo |
|---|---|---|
| `CURRENT_DATE` | Hoje | `SELECT CURRENT_DATE;` |
| `+ INTERVAL` | Soma um tempo | `fechado_em + INTERVAL '48 hours'` |
| `data - data` | Dias entre duas datas | `valido_ate - CURRENT_DATE` |
| `AGE(fim, inicio)` | Tempo entre duas datas | `AGE(entregue_em, criado_em)` |
| `DATE_TRUNC('month', d)` | Volta ao início do mês | `DATE_TRUNC('month', criado_em)::date` |
| `EXTRACT(campo FROM d)` | Um pedaço da data | `EXTRACT(DOW FROM criado_em)` (0 = domingo) |
| `TO_CHAR(d, formato)` | Data como texto | `TO_CHAR(criado_em, 'DD/MM/YYYY')` |

## Condição e nulo

| Função | Faz | Exemplo |
|---|---|---|
| `CASE WHEN ... THEN ... ELSE ... END` | Escolhe um valor por condição | `CASE WHEN total < 150 THEN 'pequeno' ELSE 'grande' END` |
| `COALESCE(a, b)` | O primeiro valor que não é nulo | `COALESCE(comentario, 'sem comentário')` |

## View simples

Uma view é uma consulta guardada com um nome. Ela **não guarda dados**: a consulta roda toda vez que você usa a view.

| Comando | Faz | Exemplo |
|---|---|---|
| `CREATE VIEW nome AS SELECT ...` | Guarda a consulta com um nome | `CREATE VIEW vw_pedidos_aguardando_pagamento AS SELECT ...` |
| `CREATE OR REPLACE VIEW nome AS SELECT ...` | Cria a view ou troca a consulta dela | `CREATE OR REPLACE VIEW vw_vendas_por_produto AS SELECT ...` |
| `SELECT ... FROM nome` | Usa a view como se fosse uma tabela | `SELECT * FROM vw_pedidos_aguardando_pagamento WHERE vencido;` |
| `DROP VIEW nome` | Apaga a view (as tabelas ficam como estão) | `DROP VIEW vw_pedidos_aguardando_pagamento;` |

Exemplo completo (os pedidos aguardando pagamento, com o prazo de 48 horas e se já venceu):

```sql
CREATE OR REPLACE VIEW vw_pedidos_aguardando_pagamento AS
SELECT p.id, p.numero, c.nome AS cliente, p.total, p.fechado_em,
       p.fechado_em + INTERVAL '48 hours' AS prazo,
       (p.fechado_em + INTERVAL '48 hours') < LOCALTIMESTAMP AS vencido
FROM pedido p
JOIN cliente c ON c.id = p.cliente_id
WHERE p.status = 'aguardando_pagamento';

SELECT numero, cliente, total, vencido
FROM vw_pedidos_aguardando_pagamento
ORDER BY fechado_em;
```

## Cuidados

- `NULL` com `||` dá `NULL`. Use `COALESCE` antes de juntar.
- `CREATE OR REPLACE VIEW` só deixa acrescentar colunas no fim. Para mudar o nome de uma coluna ou tirar uma coluna, use `DROP VIEW` e crie de novo.
- Use o prefixo `vw_` no nome da view.
- `DATE_TRUNC` devolve data e hora. Use `::date` para ver só a data.
- Data menos data dá dias. Data e hora menos data e hora dá um intervalo.
