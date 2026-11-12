# Exercício 10 — Triggers

Banco de Dados 2 · Turma MBI-08 · Aula 20 · Preparatório da prova 4

SQL: *Structured Query Language*. PL/pgSQL: *Procedural Language/PostgreSQL* (a linguagem de programação do PostgreSQL). Trigger (gatilho): uma função que o banco **roda sozinho** quando um dado muda.

| | |
|---|---|
| **Como fazer** | Em dupla, no banco da Loja Virtual |
| **Entrega** | Cada aluno entrega o arquivo `exercicio-10.sql` no Classroom |
| **Prazo** | Ideal: até o fim da aula 20. Vale até 18/11 |

## O que fazer

Na procedure, alguém precisa lembrar de chamar o `CALL`. No trigger, ninguém chama: o banco roda a regra sozinho a cada `INSERT` ou `UPDATE`. Assim, a regra vale para qualquer sistema que use a loja.

Você vai criar **7 triggers**. Tudo vai em **um único arquivo**: `exercicio-10.sql`.

1. **Carregue a base do zero**, nesta ordem: `01_ddl.sql`, `02_carga.sql`, `10_expansao_ddl.sql` e `11_expansao_carga.sql`. Os testes mudam os dados, e os números do «Confira» contam com a base nova.
2. Crie o arquivo `exercicio-10.sql`. Na primeira linha, escreva `SET search_path TO loja;`.
3. Para cada trigger, nesta ordem:
   1. escreva um comentário com o número e o pedido do Rafael;
   2. crie a **função** do trigger (`RETURNS trigger`);
   3. crie o **trigger** (`DROP TRIGGER IF EXISTS` e `CREATE TRIGGER`);
   4. **antes de rodar**, escreva em um comentário o que você espera de cada teste;
   5. rode o teste que **dispara** e confira com um `SELECT`;
   6. rode o segundo teste: o que **não dispara** (nos triggers `AFTER`) ou o que é **recusado** (nos triggers de regra). Comente a linha do teste recusado depois de ver o erro, para o arquivo rodar inteiro.
4. Escreva um comentário em cada linha do SQL.
5. Para rodar o arquivo inteiro de novo, carregue a base do zero antes.
6. Responda as 3 perguntas de «Para fixar», em comentários, no fim do arquivo.
7. Entregue no Classroom.

## Como o exercício ajuda você

A ajuda diminui a cada trigger. Assim você aprende a fazer sozinho.

| Triggers | Tipo | O que você recebe |
|---|---|---|
| 1 | `AFTER` | O exemplo **resolvido**. Digite, rode e reescreva os comentários com as suas palavras |
| 2 e 3 | `AFTER` | O trigger com **lacunas** (`___`) |
| 4 e 5 | `BEFORE` | Só a **estrutura**, em comentários |
| 6 e 7 | `BEFORE` | Só o **pedido** e os passos |

Palavras que usamos sempre com o mesmo sentido: **disparar** (o banco rodar o trigger), **`OLD`** (a linha antes da mudança) e **`NEW`** (a linha depois da mudança, ou a que está chegando).

## Regras

- Escreva um **comentário em cada linha** do SQL (`--`), dizendo o que a linha faz. Isso ajuda você a estudar.
- Todo trigger tem **duas partes**: a função (`RETURNS trigger`) e o `CREATE TRIGGER`, que liga a função à tabela e ao evento.
- **`AFTER` registra, `BEFORE` recusa ou corrige.** No `AFTER`, termine com `RETURN NULL;`. No `BEFORE`, termine com `RETURN NEW;`.
- Antes de cada `CREATE TRIGGER`, escreva `DROP TRIGGER IF EXISTS nome ON tabela;`. Assim o arquivo roda de novo sem erro.
- Uma mensagem de erro diz o motivo com as palavras da loja.
- Não use `LIMIT`: cada pergunta é sobre todas as linhas.
- Apoio: [referencia-criar-triggers.md](referencia-criar-triggers.md). Para `NEW`, `OLD`, `FOUND` e as funções prontas (`LOWER`, `TRIM`...): [referencia-funcoes-operadores-e-variaveis.md](referencia-funcoes-operadores-e-variaveis.md).

# Parte 1 — Triggers AFTER: registrar o que mudou

## Trigger 1 · O histórico de e-mail do cliente

### Pedido do Rafael

Um cliente trocou o e-mail e depois disse que não foi ele. Não tive como saber qual era o e-mail antigo nem quando mudou. Quero que toda troca de e-mail fique guardada: o antigo, o novo e o momento.

| Tabela e evento | O que faz |
|---|---|
| `AFTER UPDATE OF email ON cliente` | grava em `historico_email` o cliente, o e-mail antigo (`OLD.email`) e o novo (`NEW.email`) |

**Exemplo de retorno** do histórico depois de mudar o e-mail do cliente 1:

| cliente_id | email_antes | email_depois |
|---|---|---|
| 1 | cliente01@exemplo.test | cliente01@novo.test |

Depois de mudar só o nome, `SELECT COUNT(*) FROM historico_email;` continua `1`.

### Passo a passo

1. **A tabela do histórico.** Crie `historico_email` (o código está no exemplo).
2. **A função.** Um `INSERT` com `OLD.email` e `NEW.email`, e `RETURN NULL`.
3. **O trigger.** `AFTER UPDATE OF email`: dispara só quando o `UPDATE` mexe no e-mail.
4. **Antes de rodar**, escreva quantas linhas o histórico vai ter depois de cada teste.

### Exemplo resolvido

Digite (não cole), rode e reescreva os comentários com as suas palavras:

```sql
CREATE TABLE IF NOT EXISTS historico_email (
    id           integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cliente_id   integer NOT NULL REFERENCES cliente (id),
    email_antes  varchar(100),
    email_depois varchar(100),
    mudou_em     timestamp NOT NULL DEFAULT LOCALTIMESTAMP
);

CREATE OR REPLACE FUNCTION fn_historico_email()
RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO historico_email (cliente_id, email_antes, email_depois)
    VALUES (NEW.id, OLD.email, NEW.email);
    RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS trg_historico_email ON cliente;
CREATE TRIGGER trg_historico_email
AFTER UPDATE OF email ON cliente
FOR EACH ROW EXECUTE FUNCTION fn_historico_email();

UPDATE cliente SET email = 'cliente01@novo.test' WHERE id = 1;
SELECT cliente_id, email_antes, email_depois FROM historico_email;

UPDATE cliente SET nome = 'Cliente 01 Silva' WHERE id = 1;
SELECT COUNT(*) FROM historico_email;
```

**Confira:** depois do primeiro `UPDATE`, o histórico tem 1 linha: cliente `1`, de `cliente01@exemplo.test` para `cliente01@novo.test`. O segundo `UPDATE` muda só o nome, e o histórico continua com 1 linha.

## Trigger 2 · O pagamento marca o pedido como pago

### Pedido do Rafael

Hoje o sistema grava o pagamento e, em outra tela, alguém muda o pedido para pago. Às vezes esquecem, e o cliente pagou mas o pedido não anda. Quero que, assim que um pagamento for gravado, o pedido vire pago sozinho.

| Tabela e evento | O que faz |
|---|---|
| `AFTER INSERT ON pagamento` | muda para `pago` o `status` do pedido do pagamento (`NEW.pedido_id`) |

**Exemplo de retorno** depois do `INSERT` do pagamento do pedido 61:

| id | status |
|---|---|
| 61 | pago |

| pedidos pagos |
|---|
| 31 |

### Passo a passo

1. **A função.** Um `UPDATE` em `pedido`, usando o `NEW.pedido_id` do pagamento que acabou de entrar.
2. **O trigger.** `AFTER INSERT ON pagamento`.
3. **Antes de rodar**, escreva o status que o pedido 61 vai ter.

### Monte o trigger

Troque cada `___` e comente cada linha:

```sql
CREATE OR REPLACE FUNCTION fn_pagamento_marca_pago()
RETURNS ___
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE pedido SET status = '___'
    WHERE id = NEW.___;
    RETURN ___;
END;
$$;

DROP TRIGGER IF EXISTS trg_pagamento_marca_pago ON pagamento;
CREATE TRIGGER trg_pagamento_marca_pago
___ INSERT ON ___
FOR EACH ROW EXECUTE FUNCTION fn_pagamento_marca_pago();

INSERT INTO pagamento (pedido_id, forma, valor) VALUES (61, 'pix', 1002.60);
SELECT id, status FROM pedido WHERE id = 61;
SELECT COUNT(*) FROM pedido WHERE status = 'pago';
```

**Confira:** o pedido 61 passa de `aguardando_pagamento` para `pago`, e a loja fica com 31 pedidos pagos (eram 30). Teste também o que não dispara: um `UPDATE` em `pagamento` não muda nenhum pedido, porque o trigger é só de `INSERT`.

## Trigger 3 · Cancelar tira os pontos do cliente

### Pedido do Rafael

Cada compra dá pontos de fidelidade ao cliente. Mas, se o pedido for cancelado, ele não pode ficar com os pontos. Quero que, ao cancelar, o estorno dos pontos seja lançado sozinho no extrato. Pedido que não deu pontos, como um carrinho, não estorna nada.

| Tabela e evento | O que faz |
|---|---|
| `AFTER UPDATE OF status ON pedido` | se o pedido acabou de ser cancelado e tinha crédito de pontos, grava em `movimento_pontos` um `estorno` com os mesmos pontos, negativos |

**Exemplo de retorno** do extrato do pedido 3 depois de cancelar:

| pedido_id | tipo | pontos |
|---|---|---|
| 3 | credito | 9 |
| 3 | estorno | -9 |

Depois de cancelar o carrinho 12, `SELECT COUNT(*) FROM movimento_pontos WHERE tipo = 'estorno';` continua `1`.

### Passo a passo

1. **Acabou de ser cancelado?** Compare `NEW.status = 'cancelado'` e `OLD.status <> 'cancelado'`.
2. **Quantos pontos o pedido deu?** `SELECT pontos INTO v_pontos` do crédito (`tipo = 'credito'`) deste pedido.
3. **Tinha crédito?** Use `IF FOUND`: só grava o estorno se achou o crédito.
4. **O estorno.** Um `INSERT` em `movimento_pontos` com `-v_pontos`.
5. **Antes de rodar**, escreva o extrato de pontos do pedido 3 depois do cancelamento.

### Monte o trigger

Troque cada `___` e comente cada linha:

```sql
CREATE OR REPLACE FUNCTION fn_estornar_pontos()
RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE
    v_pontos ___;
BEGIN
    IF NEW.status = 'cancelado' AND ___.status <> 'cancelado' THEN
        SELECT pontos INTO ___
        FROM movimento_pontos
        WHERE pedido_id = NEW.id AND tipo = '___';
        IF ___ THEN
            INSERT INTO movimento_pontos (cliente_id, pedido_id, tipo, pontos)
            VALUES (NEW.cliente_id, NEW.id, 'estorno', -___);
        END IF;
    END IF;
    RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS trg_estornar_pontos ON pedido;
CREATE TRIGGER trg_estornar_pontos
AFTER UPDATE OF ___ ON pedido
FOR EACH ROW EXECUTE FUNCTION fn_estornar_pontos();

UPDATE pedido SET status = 'cancelado' WHERE id = 3;
SELECT pedido_id, tipo, pontos FROM movimento_pontos
WHERE pedido_id = 3 ORDER BY id;

UPDATE pedido SET status = 'cancelado' WHERE id = 12;
SELECT COUNT(*) FROM movimento_pontos WHERE tipo = 'estorno';
```

**Confira:** o pedido 3 fica com 2 linhas no extrato: `credito` de `9` e `estorno` de `-9`. O pedido 12 era um carrinho e não tinha crédito: nada é estornado, e a loja continua com 1 estorno só.

# Parte 2 — Triggers BEFORE: recusar ou corrigir o dado

## Trigger 4 · Produto fora da vitrine não entra no carrinho

### Pedido do Rafael

Tirei alguns produtos da vitrine, mas um sistema antigo ainda deixa colocar esses produtos no carrinho. Quero que o banco recuse: produto fora da vitrine não entra em pedido nenhum, venha de onde vier.

| Tabela e evento | O que faz |
|---|---|
| `BEFORE INSERT ON item_pedido` | se o produto do item (`NEW.produto_id`) está com `ativo` igual a `false`, recusa com `Produto 5 está fora da vitrine e não pode entrar no carrinho` |

**Exemplo de retorno** dos itens do carrinho 24 depois do teste que passa:

| pedido_id | produto_id |
|---|---|
| 24 | 1 |
| 24 | 12 |

O teste recusado: `Produto 5 está fora da vitrine e não pode entrar no carrinho`.

### Estrutura

Escreva o trigger a partir destes comentários:

```sql
-- função: fn_item_so_produto_ativo(), RETURNS trigger, LANGUAGE plpgsql
-- DECLARE: v_ativo boolean
-- 1) SELECT ativo INTO v_ativo FROM produto do NEW.produto_id
-- 2) se NOT v_ativo: RAISE EXCEPTION 'Produto % está fora da vitrine e não pode entrar no carrinho', NEW.produto_id
-- 3) RETURN NEW
-- trigger: trg_item_so_produto_ativo, BEFORE INSERT ON item_pedido, FOR EACH ROW
-- preparo do teste: UPDATE produto SET ativo = false WHERE id = 5;
-- teste que passa: INSERT INTO item_pedido (pedido_id, produto_id, quantidade, preco_unitario) VALUES (24, 1, 1, 141.90);
-- teste recusado:  INSERT INTO item_pedido (pedido_id, produto_id, quantidade, preco_unitario) VALUES (24, 5, 1, 45.90);
```

**Confira:** o produto 1 entra no carrinho 24, que passa a ter 2 itens (os produtos `1` e `12`). O produto 5 é recusado com `Produto 5 está fora da vitrine e não pode entrar no carrinho`.

## Trigger 5 · E-mail sempre em minúsculas e sem espaços

### Pedido do Rafael

Cada atendente digita o e-mail de um jeito: com maiúscula, com espaço no fim. Depois o cliente não acha o próprio cadastro. Quero que o banco guarde o e-mail sempre em minúsculas e sem espaços nas pontas, no cadastro e em qualquer alteração.

| Tabela e evento | O que faz |
|---|---|
| `BEFORE INSERT OR UPDATE ON cliente` | troca o e-mail que vai ser gravado por `LOWER(TRIM(NEW.email))` |

**Exemplo de retorno** dos e-mails depois dos dois testes:

| cliente | email |
|---|---|
| 2 | cliente.dois@exemplo.test |
| o novo (CPF 99999999941) | cliente41@exemplo.test |

E o `historico_email`, que o trigger 1 continua gravando:

| cliente_id | email_depois |
|---|---|
| 1 | cliente01@novo.test |
| 2 | cliente.dois@exemplo.test |

### Estrutura

Escreva o trigger a partir destes comentários:

```sql
-- função: fn_email_padrao(), RETURNS trigger, LANGUAGE plpgsql
-- 1) NEW.email := LOWER(TRIM(NEW.email));   (corrige o valor antes de gravar)
-- 2) RETURN NEW   (devolve a linha corrigida)
-- trigger: trg_email_padrao, BEFORE INSERT OR UPDATE ON cliente, FOR EACH ROW
-- teste 1: UPDATE cliente SET email = '  Cliente.Dois@Exemplo.TEST ' WHERE id = 2;  e confira o e-mail do cliente 2
-- teste 2: INSERT INTO cliente (nome, email, cpf) VALUES ('Cliente 41', 'CLIENTE41@EXEMPLO.TEST', '99999999941');  e confira
-- depois: veja o historico_email do trigger 1
```

**Confira:** o cliente 2 fica com `cliente.dois@exemplo.test`, e o cliente novo com `cliente41@exemplo.test`. O `historico_email` passa a ter 2 linhas, e a segunda já mostra o e-mail corrigido: o `BEFORE` roda antes do `AFTER`.

## Trigger 6 · Pedido cancelado não volta

### Pedido do Rafael

Alguém reativou um pedido cancelado, e a loja enviou um produto que o cliente não queria mais. Quero uma regra: pedido cancelado fica cancelado. Qualquer outra mudança de status continua valendo.

| Tabela e evento | O que faz |
|---|---|
| `BEFORE UPDATE OF status ON pedido` | se o status antigo é `cancelado` e o novo é outro, recusa com `Pedido 11 está cancelado e não pode voltar para pago` |

**Exemplo de retorno** depois do teste que passa:

| id | status |
|---|---|
| 6 | entregue |

O teste recusado: `Pedido 11 está cancelado e não pode voltar para pago`.

### Passo a passo

1. A regra compara a linha antes e depois: `OLD.status` e `NEW.status`.
2. Se não for o caso da regra, termine com `RETURN NEW`: a mudança acontece.
3. **Teste que passa:** o pedido 6, `enviado`, vira `entregue` (mude também o `entregue_em`).
4. **Teste recusado:** o pedido 11, `cancelado`, tenta voltar para `pago`.

**Confira:** o pedido 6 fica `entregue`. O pedido 11 é recusado com `Pedido 11 está cancelado e não pode voltar para pago`.

## Trigger 7 · Pagamento só do valor certo

### Pedido do Rafael

Já gravaram pagamento com o valor errado e até pagamento de pedido que já estava pago. Quero que o banco só aceite um pagamento se o pedido estiver esperando o pagamento e se o valor for igual ao total do pedido.

| Tabela e evento | O que faz |
|---|---|
| `BEFORE INSERT ON pagamento` | recusa se o pedido não está `aguardando_pagamento` (`Pedido 2 está pago e não aceita pagamento`) ou se o valor é diferente do total (`Pagamento de 500.00 diferente do total do pedido 73 (1002.60)`) |

**Exemplo de retorno** depois do pagamento do pedido 85:

| id | status |
|---|---|
| 85 | pago |

Os testes recusados:

| Pagamento | Mensagem de erro |
|---|---|
| 73, `500` | `Pagamento de 500.00 diferente do total do pedido 73 (1002.60)` |
| 2, `1295.40` | `Pedido 2 está pago e não aceita pagamento` |

### Passo a passo

1. Busque o `status` e o `total` do pedido do pagamento (`NEW.pedido_id`) com `SELECT ... INTO`.
2. Teste o status e depois o valor, cada um com `IF` e `RAISE EXCEPTION`.
3. Termine com `RETURN NEW`.
4. **Teste que passa:** um pagamento de `1002.60` para o pedido 85, no cartão.
5. **Testes recusados:** `500` para o pedido 73, e `1295.40` para o pedido 2.

**Confira:** o pagamento do pedido 85 entra, e o pedido fica `pago`, porque o trigger 2 também dispara. Os dois testes recusados param com as mensagens da tabela.

## Para fixar (sem nota)

Responda em comentários, no fim do arquivo, **sem olhar o material**:

1. O que `OLD` e `NEW` guardam?
2. `BEFORE` ou `AFTER`: qual pode recusar o dado? Por quê?
3. Quem chama o trigger?
