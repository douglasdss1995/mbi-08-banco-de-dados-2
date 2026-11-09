# Referência — Criar funções

Banco de Dados 2 · Turma MBI-08 · Aulas 17 e 18

SQL: *Structured Query Language*. PL/pgSQL: *Procedural Language/PostgreSQL*. Função: uma regra guardada no banco, com nome e parâmetros.

## Antes da função: o bloco anônimo

Um bloco anônimo roda **uma vez** e some. Não tem nome, não recebe parâmetro e não devolve valor. Serve para testar um trecho de `PL/pgSQL`.

```sql
DO $$                                                      -- abre o bloco
DECLARE                                                    -- aqui ficam as variáveis
    v_frete numeric;                                       -- guarda o frete
BEGIN                                                      -- começa o corpo
    SELECT valor INTO v_frete FROM frete_uf WHERE uf = 'SP';  -- guarda o resultado na variável
    RAISE NOTICE 'Frete de SP: %', v_frete;                -- mostra a mensagem (o % recebe o valor)
END;                                                       -- fim do corpo
$$;                                                        -- fecha o bloco
```

- A mensagem do `RAISE NOTICE` aparece na aba de saída do cliente, não na tabela de resultados.
- Quer outra UF? Edite o bloco e rode de novo. Quer usar o frete dentro de uma consulta? Precisa de uma **função**.

## As partes de uma função

```sql
CREATE OR REPLACE FUNCTION valor_com_desconto(p_valor numeric, p_percentual numeric)  -- nome e parâmetros
RETURNS numeric                                            -- o tipo do que a função devolve
LANGUAGE sql IMMUTABLE AS $$                               -- a linguagem do corpo
    SELECT ROUND(p_valor * (1 - p_percentual / 100), 2);   -- o corpo: uma consulta
$$;                                                        -- fim do corpo
```

| Parte | O que é |
|---|---|
| `CREATE OR REPLACE FUNCTION` | Cria a função. Se ela já existe, troca pelo corpo novo |
| `valor_com_desconto(...)` | O nome e os parâmetros, cada um com o tipo |
| `RETURNS numeric` | O tipo do resultado |
| `LANGUAGE sql` ou `plpgsql` | A linguagem do corpo |
| `$$ ... $$` | O corpo da função, entre dois `$$` |

## Chamar uma função

```sql
SELECT valor_com_desconto(200, 10);                -- sozinha: devolve um valor
SELECT nome, gasto_do_cliente(id) FROM cliente;    -- dentro de uma consulta: uma vez para cada linha
SELECT * FROM pedidos_do_cliente(25);              -- função que devolve tabela: use FROM
```

## Parâmetros e variáveis

- Parâmetro começa com `p_`: `p_pedido`, `p_valor`.
- Variável começa com `v_`: `v_estoque`, `v_gasto`.
- Assim você não confunde com o nome de uma coluna.

## `LANGUAGE sql`: uma consulta com nome

- O corpo é **uma consulta**, terminada em `;`.
- O resultado da consulta é o resultado da função.
- Para devolver **várias linhas**, use `RETURNS TABLE (coluna tipo, ...)`.
- Para devolver `0` no lugar de vazio, use `COALESCE(valor, 0)`.

## `LANGUAGE plpgsql`: com variável, `IF` e erro

```sql
CREATE OR REPLACE FUNCTION classificar_estoque(p_produto integer)
RETURNS text
LANGUAGE plpgsql STABLE AS $$
DECLARE                                                    -- aqui ficam as variáveis
    v_estoque integer;                                     -- uma variável do tipo integer
    v_minimo  integer;
BEGIN                                                      -- começa o corpo
    SELECT estoque, estoque_minimo                         -- busca duas colunas
    INTO v_estoque, v_minimo                               -- e guarda nas variáveis, na mesma ordem
    FROM produto WHERE id = p_produto;
    IF NOT FOUND THEN                                      -- a busca não achou nenhuma linha
        RAISE EXCEPTION 'Produto % não existe', p_produto; -- para a função com uma mensagem
    END IF;
    IF v_estoque < v_minimo THEN                           -- primeiro caminho
        RETURN 'repor';                                    -- devolve e encerra
    ELSIF v_estoque < v_minimo * 4 THEN                    -- segundo caminho
        RETURN 'atenção';
    ELSE                                                   -- todo o resto
        RETURN 'ok';
    END IF;
END;                                                       -- fim do corpo
$$;
```

| Parte | Para que serve |
|---|---|
| `DECLARE` | Cria as variáveis, antes do `BEGIN` |
| `:=` | Dá um valor a uma variável: `v_gasto := gasto_do_cliente(p_cliente);` |
| `SELECT ... INTO` | Guarda o resultado da consulta em variáveis |
| `NOT FOUND` | Fica verdadeiro quando o `SELECT ... INTO` não achou linha |
| `tabela%ROWTYPE` | Variável que guarda uma linha inteira da tabela (`c cupom%ROWTYPE;` e `c.valor`) |
| `IF ... ELSIF ... ELSE ... END IF` | Escolhe um caminho |
| `RAISE EXCEPTION 'texto %', valor` | Para a função com uma mensagem; o `%` recebe o valor |
| `RETURN valor` | Devolve o valor e encerra a função |

## Erros comuns

| Sintoma | Causa provável |
|---|---|
| `a relação "pedido" não existe` | Falta rodar `SET search_path TO loja;` |
| `a coluna "p_pedido" não existe` | O nome do parâmetro está diferente do nome do `CREATE FUNCTION` |
| `a função ... não existe` ao chamar | Os tipos dos argumentos não batem com os parâmetros |
| `RETURN` sem valor ou sem `RETURN` | A função `plpgsql` terminou sem devolver nada |
| A função devolve vazio no lugar de `0` | Falta o `COALESCE(..., 0)` |
| Falta `;` depois de `END IF` ou `END` | Cada `END IF;` e o `END;` final terminam em `;` |

## Trocar uma função que já existe

- `CREATE OR REPLACE` troca o corpo se os **parâmetros e o tipo do `RETURNS` forem os mesmos**.
- Mudou os parâmetros ou o `RETURNS`? Apague antes: `DROP FUNCTION nome(tipo_do_parametro);`.
