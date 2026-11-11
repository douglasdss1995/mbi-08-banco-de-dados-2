# Referência — Criar procedures

Banco de Dados 2 · Turma MBI-08 · Aula 19

SQL: *Structured Query Language*. PL/pgSQL: *Procedural Language/PostgreSQL*. Procedure: uma **ação** da loja guardada no banco, com nome e parâmetros.

## Função ou procedure?

| | Função | Procedure |
|---|---|---|
| Para quê | **Responde** uma pergunta: «quanto é o frete?» | **Faz** uma ação: «registre o pagamento» |
| Devolve valor? | Sim (`RETURNS` e `RETURN`) | Não. Não tem `RETURNS` |
| Muda dados? | Não (só calcula) | Sim (`INSERT`, `UPDATE`, `DELETE`) |
| Como chamar | Dentro de um `SELECT`: `SELECT calcular_frete('SP', 150);` | Com `CALL`: `CALL registrar_pagamento(61, 'pix', 1002.60);` |

## As partes de uma procedure

```sql
CREATE OR REPLACE PROCEDURE marcar_como_entregue(p_pedido integer)  -- nome e parâmetros
LANGUAGE plpgsql AS $$                                     -- a linguagem do corpo (sem RETURNS)
DECLARE                                                    -- variáveis, como na função
    v_status varchar;                                      -- guarda o status
BEGIN                                                      -- começa o corpo
    SELECT status INTO v_status FROM pedido WHERE id = p_pedido;  -- 1) busca
    IF NOT FOUND THEN                                      -- 2) as regras, antes da ação
        RAISE EXCEPTION 'Pedido % não existe', p_pedido;   -- para e diz o motivo
    END IF;                                                -- fim do teste
    UPDATE pedido SET status = 'entregue' WHERE id = p_pedido;  -- 3) a ação
END;                                                       -- fim do corpo
$$;                                                        -- fim da procedure
```

A ordem é sempre a mesma: **buscar**, **testar as regras** e só então **gravar**.

## Chamar e conferir

```sql
CALL marcar_como_entregue(5);                              -- a procedure faz e não mostra nada
SELECT status, entregue_em FROM pedido WHERE id = 5;       -- quem mostra é o SELECT seguinte
```

- Procedure sem parâmetro leva os parênteses vazios, na criação e no `CALL`: `CALL cancelar_pedidos_vencidos();`.
- Para mostrar um recado no meio do caminho, use `RAISE NOTICE '% pedido(s) cancelado(s)', v_quantos;`. Ele aparece na aba de saída do cliente (no DBeaver, `Ctrl+Shift+O`).

## O erro desfaz tudo

Se a procedure para com `RAISE EXCEPTION`, **nada do que aquela chamada fez fica gravado**, nem o `INSERT` que já tinha rodado. Os dados continuam como estavam antes do `CALL`.

Por isso o erro protege a loja: um pagamento pela metade nunca fica no banco.

## Testar se uma linha existe

| Jeito | Quando usar |
|---|---|
| `SELECT ... INTO` e depois `IF NOT FOUND` | Você precisa dos valores da linha (o status, o total) |
| `IF NOT EXISTS (SELECT 1 FROM ... WHERE ...)` | Você só quer saber se existe; não precisa guardar nada |
| `IF EXISTS (SELECT 1 FROM ... WHERE ...)` | Existe algo que impede a ação (o produto está em um carrinho aberto) |

## Erros comuns

- Esquecer o `CALL` e escrever `SELECT marcar_como_entregue(5);`: dá erro, porque procedure não é função.
- Gravar antes de testar as regras. O erro desfaz, mas o código fica confuso: teste primeiro.
- Rodar o arquivo inteiro duas vezes: o teste que dava certo passa a falhar, porque os dados já mudaram. Carregue a base do zero antes.
- Esquecer o `;` depois do `END` ou depois do `$$`.
