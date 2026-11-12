# Referência — Funções, operadores e variáveis do sistema

Banco de Dados 2 · Turma MBI-08 · Aulas 17 a 21

SQL: *Structured Query Language*. PL/pgSQL: *Procedural Language/PostgreSQL* (a linguagem de programação do PostgreSQL).

Tudo o que aparece nos slides, nos exercícios 8, 9 e 10 e na prática da aula 21 sem ter sido criado por você está explicado aqui: as variáveis que o banco cria sozinho, as funções prontas e os operadores.
Os resultados foram testados na base da Loja Virtual (`SET search_path TO loja;`).

## 1. Variáveis que o PL/pgSQL cria sozinho

Você **não declara** estas variáveis: elas já existem.

| Variável | Onde existe | O que guarda | Onde aparece |
|---|---|---|---|
| `FOUND` | Em toda função, procedure e bloco `plpgsql` | `true` se o último comando achou ou mudou pelo menos uma linha; `false` se não | aula 18 em diante |
| `NEW` | Na função de um trigger | A linha nova: a que está chegando (`INSERT`) ou como ela fica (`UPDATE`) | aula 20 |
| `OLD` | Na função de um trigger | A linha antes da mudança (`UPDATE`). No `INSERT`, não existe | aula 20 |

### Como o `FOUND` muda

- Começa `false` a cada chamada da função.
- **`SELECT ... INTO`**: achou uma linha, `true`; não achou, `false` (e as variáveis ficam vazias, `NULL`).
- **`UPDATE`, `INSERT` e `DELETE`**: mudaram pelo menos uma linha, `true`; nenhuma, `false`.
- Cada comando desses troca o valor. Por isso, teste `IF NOT FOUND` **logo na linha seguinte**.
- Não existe em `LANGUAGE sql`.

```sql
DO $$
DECLARE v numeric;                                         -- uma variável para o teste
BEGIN
    RAISE NOTICE 'antes: %', FOUND;                        -- f: começa false
    SELECT valor INTO v FROM frete_uf WHERE uf = 'SP';     -- SP existe
    RAISE NOTICE 'SP: %', FOUND;                           -- t
    SELECT valor INTO v FROM frete_uf WHERE uf = 'AM';     -- AM não existe
    RAISE NOTICE 'AM: % e v = %', FOUND, v;                -- f e v = <NULL>
END $$;
```

Na mensagem, `true` aparece como `t` e `false` como `f`.

## 2. Funções prontas

### Valores

| Função | O que faz | Exemplo | Resultado | Onde aparece |
|---|---|---|---|---|
| `COALESCE(a, b)` | Devolve o primeiro valor que não é vazio (`NULL`) | `COALESCE(NULL, 0)` | `0` | exercício 8 (funções 2, 3 e 8) |
| `LEAST(a, b, ...)` | Devolve o **menor** dos valores. Ignora o vazio | `LEAST(50, 30)` | `30` | aula 18, exercício 8 (função 6) |
| `GREATEST(a, b, ...)` | Devolve o **maior** dos valores (leitura extra) | `GREATEST(50, 30)` | `50` | — |
| `ROUND(valor, casas)` | Arredonda para o número de casas | `ROUND(10.456, 2)` | `10.46` | exercício 8 e prática da aula 21 |

### Contas sobre várias linhas (agregação)

| Função | O que faz | Exemplo na loja | Resultado |
|---|---|---|---|
| `COUNT(*)` | Conta as linhas | `SELECT COUNT(*) FROM pedido;` | `120` |
| `COUNT(coluna)` | Conta só as linhas em que a coluna não é vazia | `SELECT COUNT(subtotal) FROM pedido;` | `110` (o carrinho não tem `subtotal`) |
| `SUM(coluna)` | Soma | `SELECT SUM(total) FROM pedido;` | `86087.46` |
| `AVG(coluna)` | Média | `SELECT ROUND(AVG(total), 2) FROM pedido;` | `782.61` |
| `MIN(coluna)` e `MAX(coluna)` | Menor e maior | `MIN(total)` e `MAX(total)` | `79.26` e `2018.07` |

`SUM` e `AVG` sem nenhuma linha devolvem vazio (`NULL`), e não `0`. Por isso aparecem junto com `COALESCE`.

### Texto

| Função ou operador | O que faz | Exemplo | Resultado | Onde aparece |
|---|---|---|---|---|
| `UPPER(t)` e `LOWER(t)` | Maiúsculas e minúsculas | `UPPER('vip25')` | `VIP25` | aula 13, aula 20 |
| `TRIM(t)` | Tira os espaços das pontas | `TRIM('  vip25 ')` | `vip25` | aula 13, aula 20 |
| `LPAD(t, n, c)` | Completa à esquerda até `n` caracteres | `LPAD('7', 6, '0')` | `000007` | aula 13 e prática da aula 21 |
| `TO_CHAR(data, formato)` | Data como texto | `TO_CHAR(DATE '2026-11-10', 'DD/MM/YYYY')` | `10/11/2026` | aula 13, aula 18 |
| `\|\|` | Junta textos (e números) | `'Entregue em ' \|\| 3` | `Entregue em 3` | aula 18 |

### Data e hora

| Item | O que faz | Exemplo | Resultado | Onde aparece |
|---|---|---|---|---|
| `CURRENT_DATE` | A data de hoje | `CURRENT_DATE` | a data do dia | aula 13, exercícios 8 e 9 |
| `LOCALTIMESTAMP` | A data e a hora de agora | `LOCALTIMESTAMP` | data e hora do momento | aulas 19 e 20 |
| `INTERVAL '...'` | Um intervalo de tempo | `fechado_em + INTERVAL '48 hours'` | o momento 48 horas depois | aula 13, aula 19 |
| data `+` número | Soma dias a uma data | `DATE '2026-11-10' + 5` | `2026-11-15` | prática da aula 21 |
| data `-` número | Tira dias de uma data | `CURRENT_DATE - 7` | a data de 7 dias atrás | exercício 8 (função 9) |
| `::date` | Converte para data, tirando a hora | `'2026-11-10 14:30'::timestamp::date` | `2026-11-10` | exercício 8 (função 9) |
| `current_user` | O nome do usuário do banco que está conectado | `current_user` | `postgres` | a coluna `usuario` da `auditoria_pedido` |
| `now()` | A data e a hora de agora, com o fuso horário | `now()` | data, hora e fuso do momento | a coluna `quando` da `auditoria_pedido` (aula 20) |

## 3. Operadores de comparação

O resultado é sempre `true`, `false` ou vazio (`NULL`).

| Operador | Quer dizer | Exemplo | Resultado |
|---|---|---|---|
| `=` | Igual | `status = 'pago'` | `true` se o status é pago |
| `<>` | Diferente | `p_valor <> p.total` | `true` se o valor é outro |
| `<`, `>`, `<=`, `>=` | Menor, maior, menor ou igual, maior ou igual | `p_valor >= 300` | `true` a partir de 300 |
| `BETWEEN a AND b` | Entre `a` e `b`, incluindo os dois | `5 BETWEEN 1 AND 5` | `true` |
| `IN (...)` | Está na lista | `'PE' IN ('BA', 'PE')` | `true` |
| `NOT IN (...)` | Não está na lista | `status NOT IN ('carrinho', 'cancelado')` | `true` para os outros status |
| `IS NULL` e `IS NOT NULL` | Está vazio, não está vazio | `v_vendedor IS NULL` | `true` se não há vendedor |
| `= ANY(lista)` | Está numa lista (array) — leitura extra | `2 = ANY(ARRAY[1, 2, 3])` | `true` |

**Cuidado com o vazio:** `NULL = NULL` não dá `true`, dá vazio. Para testar se algo está vazio, use sempre `IS NULL`.

## 4. Operadores lógicos

Juntam ou invertem condições. Aparecem no `WHERE`, no `IF` e no `CASE`.

| Operador | Dá `true` quando | Exemplo |
|---|---|---|
| `AND` | As **duas** condições são verdadeiras | `cliente_id = p_cliente AND status = 'pago'` |
| `OR` | **Pelo menos uma** é verdadeira | `IF NOT FOUND OR e.cliente_id <> p.cliente_id THEN` |
| `NOT` | A condição é falsa | `IF NOT v_ativo THEN` |

| `a` | `b` | `a AND b` | `a OR b` | `NOT a` |
|---|---|---|---|---|
| `true` | `true` | `true` | `true` | `false` |
| `true` | `false` | `false` | `true` | `false` |
| `false` | `false` | `false` | `false` | `true` |
| `NULL` | `false` | `false` | `NULL` | `NULL` |
| `NULL` | `true` | `NULL` | `true` | `NULL` |

Ordem: primeiro o `NOT`, depois o `AND`, por último o `OR`. Na dúvida, use parênteses: `(a OR b) AND c`.

## 5. Testar se uma linha existe

| Jeito | Quando usar | Onde aparece |
|---|---|---|
| `SELECT ... INTO` e depois `IF NOT FOUND` | Você precisa dos valores da linha | aulas 18 e 19 |
| `IF NOT EXISTS (SELECT 1 FROM ... WHERE ...)` | Só quer saber se existe; não guarda nada | aula 18 (bloco 4), exercício 8 (função 10) |
| `IF EXISTS (SELECT 1 FROM ... WHERE ...)` | Existe algo que impede a ação | exercício 9 (procedures 5 e 6) |

O `SELECT 1` não importa: o `EXISTS` só olha se a consulta devolve alguma linha.

## 6. Palavras do PL/pgSQL

| Palavra | O que faz | Exemplo |
|---|---|---|
| `:=` | Dá um valor a uma variável | `v_frete := calcular_frete(v_uf, v_valor);` |
| `INTO` | Guarda o resultado do `SELECT` nas variáveis, na ordem das colunas | `SELECT status, total INTO v_status, v_total` |
| `RETURN` | Na função: devolve o valor e encerra. No trigger: `RETURN NEW` ou `RETURN NULL` | `RETURN 'ok';` |
| `RAISE NOTICE` | Mostra uma mensagem na aba de saída; a rotina continua | `RAISE NOTICE 'Frete: %', v_frete;` |
| `RAISE EXCEPTION` | Para a rotina com um erro; nada do que ela fez fica gravado | `RAISE EXCEPTION 'Pedido % não existe', p_pedido;` |
| `%` na mensagem | É trocado pelos valores, na ordem | `'Pedido % está %', p_pedido, p.status` |
| `%ROWTYPE` | Variável com a linha inteira de uma tabela | `p pedido%ROWTYPE;` |
| `CALL` | Chama uma procedure | `CALL registrar_pagamento(61, 'pix', 1002.60);` |

Mais detalhes sobre a estrutura de uma função e os tipos de variável: [referencia-estrutura-de-uma-funcao.md](referencia-estrutura-de-uma-funcao.md).
