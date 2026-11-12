# Referência — Criar triggers

Banco de Dados 2 · Turma MBI-08 · Aula 20

SQL: *Structured Query Language*. PL/pgSQL: *Procedural Language/PostgreSQL*. Trigger (gatilho): uma função que o banco **roda sozinho** quando um dado muda.

## Função, procedure ou trigger?

| | Função | Procedure | Trigger |
|---|---|---|---|
| Para quê | Responde | Faz uma ação | Reage a uma mudança |
| Quem chama | Um `SELECT` | Um `CALL` | **O banco, sozinho**, no `INSERT` ou `UPDATE` |

## Sempre duas partes

```sql
-- 1ª parte: a função do trigger
CREATE OR REPLACE FUNCTION fn_auditar_status_pedido()     -- sem parâmetros
RETURNS trigger                                            -- o tipo especial «trigger»
LANGUAGE plpgsql AS $$                                     -- corpo em PL/pgSQL
BEGIN                                                      -- começa o corpo
    INSERT INTO auditoria_pedido (pedido_id, status_antes, status_depois)  -- o que fazer
    VALUES (NEW.id, OLD.status, NEW.status);               -- a linha antes (OLD) e depois (NEW)
    RETURN NULL;                                           -- AFTER: devolve NULL
END;                                                       -- fim do corpo
$$;

-- 2ª parte: o trigger liga a função à tabela e ao evento
DROP TRIGGER IF EXISTS trg_auditar_status_pedido ON pedido;  -- apaga se já existe
CREATE TRIGGER trg_auditar_status_pedido                   -- o nome
AFTER UPDATE OF status ON pedido                           -- quando: depois de mudar o status
FOR EACH ROW                                               -- uma vez para cada linha mudada
EXECUTE FUNCTION fn_auditar_status_pedido();               -- o que rodar
```

## Quando o trigger dispara

| Escreva | Dispara |
|---|---|
| `AFTER INSERT ON pagamento` | Depois de cada linha nova em `pagamento` |
| `AFTER UPDATE OF status ON pedido` | Depois de um `UPDATE` que mexe na coluna `status` |
| `BEFORE INSERT ON item_pedido` | Antes de gravar cada item novo |
| `BEFORE INSERT OR UPDATE ON cliente` | Antes de gravar, no cadastro e na alteração |

## `OLD` e `NEW`

| | No `INSERT` | No `UPDATE` |
|---|---|---|
| `OLD` | Não existe | A linha **antes** da mudança |
| `NEW` | A linha que está chegando | A linha **depois** da mudança |

Leia as colunas com ponto: `NEW.pedido_id`, `OLD.status`.

## `AFTER` ou `BEFORE`?

| | `AFTER` | `BEFORE` |
|---|---|---|
| Quando roda | Depois de gravar | Antes de gravar |
| Serve para | **Registrar** (histórico) ou mudar **outra** tabela | **Recusar** o dado ou **corrigir** o dado |
| Termina com | `RETURN NULL;` | `RETURN NEW;` |

- **Recusar:** `RAISE EXCEPTION 'motivo'`. A linha não entra, e nada do comando fica gravado.
- **Corrigir:** troque o valor antes de gravar: `NEW.email := LOWER(TRIM(NEW.email));`.

## Testar se o `SELECT ... INTO` achou

- `IF NOT FOUND THEN` ... : não achou nenhuma linha.
- `IF FOUND THEN` ... : achou. Use para fazer algo só quando a linha existe.

## Erros comuns

- Criar a função e esquecer o `CREATE TRIGGER`: nada acontece.
- `RETURN NULL` num `BEFORE`: a linha some sem erro. No `BEFORE`, devolva `NEW`.
- Esquecer o `DROP TRIGGER IF EXISTS`: o arquivo dá erro na segunda vez que roda.
- Procurar o trigger para chamar: ninguém chama. Faça o `INSERT` ou o `UPDATE` e confira com um `SELECT`.
