# Exercício 9 — Procedures

Banco de Dados 2 · Turma MBI-08 · Aula 19

SQL: *Structured Query Language*. PL/pgSQL: *Procedural Language/PostgreSQL* (a linguagem de programação do PostgreSQL). Procedure: uma **ação** da loja guardada no banco, com nome e parâmetros. UF: Unidade Federativa (o estado).

| | |
|---|---|
| **Como fazer** | Em dupla, no banco da Loja Virtual |
| **Entrega** | Cada aluno entrega o arquivo `exercicio-09.sql` no Classroom |
| **Prazo** | Ideal: até o fim da aula 19. Vale até 18/11 |

## O que fazer

No exercício 8, as funções **respondiam** perguntas: quanto é o frete, quanto o cliente gastou. Agora o Rafael quer que o banco **faça** coisas: dar entrada no estoque, mudar um preço, cancelar pedidos. Isso é uma **procedure**.

Você vai criar **7 procedures**. Tudo vai em **um único arquivo**: `exercicio-09.sql`.

1. **Carregue a base do zero**, nesta ordem: `01_ddl.sql`, `02_carga.sql`, `10_expansao_ddl.sql` e `11_expansao_carga.sql`. As procedures mudam os dados, e os números do «Confira» contam com a base nova.
2. Crie o arquivo `exercicio-09.sql`. Na primeira linha, escreva `SET search_path TO loja;`.
3. Para cada procedure, nesta ordem:
   1. escreva um comentário com o número e o pedido do Rafael;
   2. crie a procedure (`CREATE OR REPLACE PROCEDURE`);
   3. **antes de rodar**, escreva em um comentário o que você espera de cada teste;
   4. rode o teste que **dá certo** (`CALL`) e confira com um `SELECT`;
   5. rode o teste que **falha** e confira a mensagem de erro. Depois, comente a linha do teste que falha, para o arquivo rodar inteiro.
4. Escreva um comentário em cada linha do SQL.
5. Para rodar o arquivo inteiro de novo, carregue a base do zero antes.
6. Responda as 3 perguntas de «Para fixar», em comentários, no fim do arquivo.
7. Entregue no Classroom.

## Como o exercício ajuda você

A ajuda diminui a cada procedure. Assim você aprende a fazer sozinho.

| Procedures | O que você recebe |
|---|---|
| 1 | O exemplo **resolvido**. Digite, rode e reescreva os comentários com as suas palavras |
| 2 e 3 | A procedure com **lacunas** (`___`) |
| 4 | Só a **estrutura**, em comentários |
| 5 a 7 | Só o **pedido** e os passos |

Palavras que usamos sempre com o mesmo sentido: **parâmetro** (o que a procedure recebe, com `p_` na frente), **variável** (o que ela guarda no meio do caminho, com `v_` na frente) e **chamar** (rodar a procedure com `CALL`).

## Regras

- Escreva um **comentário em cada linha** do SQL (`--`), dizendo o que a linha faz. Isso ajuda você a estudar.
- Teste **dois casos** em cada procedure: um que dá certo e um que falha.
- A procedure **não mostra nada**. Depois de cada `CALL`, confira o resultado com um `SELECT`.
- **Primeiro as regras, depois a ação.** Teste tudo com `IF` e `RAISE EXCEPTION` antes do `INSERT` ou do `UPDATE`.
- Uma mensagem de erro diz o motivo com as palavras da loja: «Pedido 999 não existe».
- Não use `LIMIT`: cada pergunta é sobre todas as linhas.
- Apoio: [referencia-criar-procedures.md](referencia-criar-procedures.md) e, para `DECLARE`, `IF` e `%ROWTYPE`, a `referencia-criar-funcoes.md` do exercício 8. Para o que já vem pronto no banco (`FOUND`, `EXISTS`, `LOCALTIMESTAMP`, `AND`, `IN`...): [referencia-funcoes-operadores-e-variaveis.md](referencia-funcoes-operadores-e-variaveis.md).

## Procedure 1 · Dar entrada no estoque

### Pedido do Rafael

Chegou mercadoria do fornecedor, e hoje alguém soma o estoque à mão. Quero uma procedure que receba o produto e a quantidade que chegou, some no estoque e registre a entrada no histórico de movimentos. Quantidade zero ou negativa não entra.

| Recebe | O que faz |
|---|---|
| `p_produto` (o id do produto) e `p_quantidade` (número) | soma a quantidade no `estoque` do produto e grava uma linha em `movimento_estoque`, do tipo `entrada` |

Mensagens de erro: `Quantidade deve ser maior que zero` e `Produto 999 não existe`.

**Exemplo de retorno** dos `SELECT` depois de `CALL dar_entrada_estoque(3, 20);`:

| id | estoque |
|---|---|
| 3 | 280 |

| tipo | quantidade |
|---|---|
| entrada | 200 |
| entrada | 60 |
| entrada | 20 |

Os testes que falham:

| Chamada | Mensagem de erro |
|---|---|
| `CALL dar_entrada_estoque(3, 0);` | `Quantidade deve ser maior que zero` |

### Passo a passo

1. **A regra primeiro.** Se a quantidade for zero ou menos, pare com `RAISE EXCEPTION`.
2. **O produto existe?** Busque o estoque com `SELECT ... INTO` e teste `IF NOT FOUND`.
3. **A ação.** Some a quantidade com `UPDATE` e grave o movimento com `INSERT`.
4. **Antes de rodar**, escreva em um comentário quanto o estoque do produto 3 vai ficar.

### Exemplo resolvido

Digite (não cole), rode e reescreva os comentários com as suas palavras:

```sql
CREATE OR REPLACE PROCEDURE dar_entrada_estoque(p_produto integer, p_quantidade integer)
LANGUAGE plpgsql AS $$
DECLARE
    v_estoque integer;
BEGIN
    IF p_quantidade <= 0 THEN
        RAISE EXCEPTION 'Quantidade deve ser maior que zero';
    END IF;
    SELECT estoque INTO v_estoque
    FROM produto WHERE id = p_produto;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Produto % não existe', p_produto;
    END IF;
    UPDATE produto
    SET estoque = estoque + p_quantidade
    WHERE id = p_produto;
    INSERT INTO movimento_estoque (produto_id, tipo, quantidade)
    VALUES (p_produto, 'entrada', p_quantidade);
END;
$$;

CALL dar_entrada_estoque(3, 20);
SELECT id, estoque FROM produto WHERE id = 3;
SELECT tipo, quantidade FROM movimento_estoque
WHERE produto_id = 3 AND tipo = 'entrada' ORDER BY id;

CALL dar_entrada_estoque(3, 0);
```

**Confira:** o estoque do produto 3 passa de `260` para `280`. A consulta dos movimentos mostra 3 entradas: `200` e `60`, que já vinham da carga, e a nova, de `20`. O último `CALL` para com o erro `Quantidade deve ser maior que zero`, e o estoque continua `280`.

## Procedure 2 · Mudar o preço de um produto

### Pedido do Rafael

Quando o fornecedor aumenta o custo, eu mudo o preço de venda. Mas não quero perder o preço antigo: os pedidos já feitos guardam o preço da época. Quero uma procedure que grave o preço novo, valendo a partir de agora. Preço zero ou negativo não vale.

| Recebe | O que faz |
|---|---|
| `p_produto` (o id do produto) e `p_preco` (número) | grava uma linha nova em `preco_produto`, com `vigencia_inicio` igual a agora (`LOCALTIMESTAMP`). O preço antigo continua na tabela |

Mensagens de erro: `Preço deve ser maior que zero` e `Produto 999 não existe`.

**Exemplo de retorno** do `SELECT` depois de `CALL mudar_preco(5, 49.90);`:

| preco |
|---|
| 45.90 |
| 49.90 |

Os testes que falham:

| Chamada | Mensagem de erro |
|---|---|
| `CALL mudar_preco(5, 0);` | `Preço deve ser maior que zero` |
| `CALL mudar_preco(999999, 10);` | `Produto 999999 não existe` |

### Passo a passo

1. **A regra do preço.** Se o preço for zero ou menos, pare.
2. **O produto existe?** Use `IF NOT EXISTS (SELECT 1 FROM produto WHERE id = p_produto)`. Aqui não é preciso guardar nada em variável.
3. **A ação.** Um `INSERT` em `preco_produto`.
4. **Antes de rodar**, escreva em um comentário quantas linhas de preço o produto 5 vai ter.

### Monte a procedure

Troque cada `___` e comente cada linha:

```sql
CREATE OR REPLACE PROCEDURE mudar_preco(p_produto integer, p_preco ___)
LANGUAGE ___ AS $$
BEGIN
    IF p_preco <= ___ THEN
        RAISE EXCEPTION 'Preço deve ser maior que zero';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM ___ WHERE id = p_produto) THEN
        RAISE ___ 'Produto % não existe', p_produto;
    END IF;
    INSERT INTO preco_produto (produto_id, preco, vigencia_inicio)
    VALUES (p_produto, ___, LOCALTIMESTAMP);
END;
$$;

CALL mudar_preco(5, 49.90);
SELECT preco FROM preco_produto
WHERE produto_id = 5 ORDER BY vigencia_inicio;

CALL mudar_preco(5, 0);
```

**Confira:** o produto 5 passa a ter 2 preços: `45.90`, o antigo, e `49.90`, o novo. O `CALL` com preço `0` para com o erro `Preço deve ser maior que zero`. Teste também o produto `999999`.

## Procedure 3 · Trocar o endereço de entrega

### Pedido do Rafael

O cliente fechou o pedido e lembrou que quer receber em outro endereço, que já está no cadastro dele. Se o pedido ainda não saiu da loja, a gente troca. Mas não pode usar o endereço de outro cliente.

| Recebe | O que faz |
|---|---|
| `p_pedido` (o id do pedido) e `p_endereco` (o id do endereço) | copia rua, número, cidade, UF e CEP do endereço para as colunas `dest_` do pedido |

Mensagens de erro: `Pedido 999 não existe`, `Pedido 5 está enviado e não pode mudar de endereço` (vale para `enviado`, `entregue` e `cancelado`) e `Endereço 7 não é do cliente do pedido 2`.

**Exemplo de retorno** do `SELECT` depois de `CALL trocar_endereco_do_pedido(2, 6);`:

| dest_cidade | dest_uf |
|---|---|
| Porto Alegre | RS |

Os testes que falham:

| Chamada | Mensagem de erro |
|---|---|
| `CALL trocar_endereco_do_pedido(2, 7);` | `Endereço 7 não é do cliente do pedido 2` |
| `CALL trocar_endereco_do_pedido(5, 10);` | `Pedido 5 está enviado e não pode mudar de endereço` |

### Passo a passo

1. **Duas linhas inteiras.** Declare `p pedido%ROWTYPE` e `e endereco%ROWTYPE`.
2. **O pedido.** Busque, teste se existe e teste o status.
3. **O endereço.** Busque e teste duas coisas juntas: não existe **ou** é de outro cliente (`e.cliente_id <> p.cliente_id`).
4. **A ação.** Um `UPDATE` no pedido, com as cinco colunas `dest_`.
5. **Antes de rodar**, escreva a cidade e a UF que o pedido 2 vai ter.

### Monte a procedure

Troque cada `___` e comente cada linha:

```sql
CREATE OR REPLACE PROCEDURE trocar_endereco_do_pedido(p_pedido integer, p_endereco integer)
LANGUAGE plpgsql AS $$
DECLARE
    p pedido%ROWTYPE;
    e ___%ROWTYPE;
BEGIN
    SELECT * INTO p FROM pedido WHERE id = ___;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Pedido % não existe', p_pedido;
    END IF;
    IF p.status IN ('enviado', '___', 'cancelado') THEN
        RAISE EXCEPTION 'Pedido % está % e não pode mudar de endereço', p_pedido, p.___;
    END IF;
    SELECT * INTO e FROM endereco WHERE id = p_endereco;
    IF NOT FOUND OR e.cliente_id <> p.___ THEN
        RAISE EXCEPTION 'Endereço % não é do cliente do pedido %', p_endereco, p_pedido;
    END IF;
    UPDATE pedido
    SET dest_logradouro = e.logradouro,
        dest_numero     = e.numero,
        dest_cidade     = e.___,
        dest_uf         = e.uf,
        dest_cep        = e.cep
    WHERE id = ___;
END;
$$;

CALL trocar_endereco_do_pedido(2, 6);
SELECT dest_cidade, dest_uf FROM pedido WHERE id = 2;

CALL trocar_endereco_do_pedido(2, 7);
```

**Confira:** o pedido 2 era para Curitiba (PR) e passa para `Porto Alegre`, `RS`, o outro endereço do cliente 3. O `CALL` com o endereço 7 para com o erro `Endereço 7 não é do cliente do pedido 2`. Teste também `trocar_endereco_do_pedido(5, 10)`: o pedido 5 já foi enviado.

## Procedure 4 · Marcar o pedido como entregue

### Pedido do Rafael

A transportadora avisou que entregou o pedido. Quero uma procedure que marque o pedido como entregue e guarde o momento da entrega. Só pedido que já saiu da loja pode ser entregue: um pedido só pago ainda está aqui.

| Recebe | O que faz |
|---|---|
| `p_pedido` (o id do pedido) | muda o `status` para `entregue` e grava `entregue_em` com o momento de agora (`LOCALTIMESTAMP`) |

Mensagens de erro: `Pedido 999 não existe` e `Pedido 2 está pago: só pedido enviado pode ser entregue`.

**Exemplo de retorno** de `SELECT status, entregue_em FROM pedido WHERE id = 5;` depois de `CALL marcar_como_entregue(5);`:

| status | entregue_em |
|---|---|
| entregue | a data e a hora em que você rodou |

Os testes que falham:

| Chamada | Mensagem de erro |
|---|---|
| `CALL marcar_como_entregue(2);` | `Pedido 2 está pago: só pedido enviado pode ser entregue` |

### Estrutura

Escreva a procedure a partir destes comentários:

```sql
-- nome: marcar_como_entregue, recebe p_pedido integer, LANGUAGE plpgsql
-- DECLARE: v_status varchar
-- 1) SELECT status INTO v_status FROM pedido do p_pedido
-- 2) se não achou o pedido: RAISE EXCEPTION 'Pedido % não existe'
-- 3) se v_status for diferente de 'enviado': RAISE EXCEPTION 'Pedido % está %: só pedido enviado pode ser entregue'
-- 4) UPDATE pedido: status 'entregue' e entregue_em = LOCALTIMESTAMP, só do p_pedido
-- testes: CALL marcar_como_entregue(5); depois um SELECT; e CALL marcar_como_entregue(2);
```

**Confira:** o pedido 5 passa de `enviado` para `entregue`, com `entregue_em` preenchido. O `CALL` com o pedido 2 para com o erro `Pedido 2 está pago: só pedido enviado pode ser entregue`.

## Procedure 5 · Tirar um produto da vitrine

### Pedido do Rafael

Vou parar de vender alguns produtos. Não quero apagar nada, porque os pedidos antigos precisam deles: só quero tirar da vitrine. Mas, se o produto estiver no carrinho de algum cliente, espere: ele ainda pode comprar.

| Recebe | O que faz |
|---|---|
| `p_produto` (o id do produto) | muda `ativo` para `false` |

Mensagens de erro: `Produto 999 não existe`, `Produto 5 já está fora da vitrine` e `Produto 12 está em um carrinho aberto`.

**Exemplo de retorno** dos `SELECT` depois de `CALL tirar_da_vitrine(5);`:

| id | ativo |
|---|---|
| 5 | false |

| produtos na vitrine |
|---|
| 29 |

Os testes que falham:

| Chamada | Mensagem de erro |
|---|---|
| `CALL tirar_da_vitrine(5);` (de novo) | `Produto 5 já está fora da vitrine` |
| `CALL tirar_da_vitrine(12);` | `Produto 12 está em um carrinho aberto` |

### Passo a passo

1. Busque o `ativo` do produto com `SELECT ... INTO` e trate o produto que não existe.
2. Se ele já está fora da vitrine, pare.
3. **Carrinho aberto.** Use `IF EXISTS (...)` com uma consulta que liga `item_pedido` a `pedido` e procura este produto em pedido com status `carrinho`.
4. **A ação.** Um `UPDATE` no produto.
5. **Teste:** tire o produto 5 da vitrine. Depois, tente o produto 5 de novo e o produto 12. Escreva antes o que você espera.

**Confira:** depois do primeiro `CALL`, o produto 5 fica com `ativo` igual a `false`, e 29 dos 30 produtos continuam na vitrine. O segundo `CALL` com o produto 5 para com `Produto 5 já está fora da vitrine`. O produto 12 para com `Produto 12 está em um carrinho aberto`.

## Procedure 6 · Aplicar um cupom ao carrinho

### Pedido do Rafael

O cliente digita o código do cupom no carrinho. Antes de aceitar, confira tudo: o pedido ainda é carrinho, o cupom existe, ainda vale, e o cliente não usou esse cupom antes. Pedido cancelado não conta como uso. Se estiver tudo certo, grave o cupom no pedido.

| Recebe | O que faz |
|---|---|
| `p_pedido` (o id do pedido) e `p_codigo` (o código do cupom) | grava o `cupom_id` no pedido |

Mensagens de erro: `Pedido 999 não existe`, `Pedido 2 está pago e não aceita cupom`, `Cupom XYZ não existe`, `Cupom VENCIDO15 está vencido` e `Cliente 33 já usou o cupom BEMVINDO10`.

**Exemplo de retorno** do `SELECT` depois de `CALL aplicar_cupom(12, 'BEMVINDO10');`:

| id | codigo |
|---|---|
| 12 | BEMVINDO10 |

Os testes que falham:

| Chamada | Mensagem de erro |
|---|---|
| `CALL aplicar_cupom(2, 'BEMVINDO10');` | `Pedido 2 está pago e não aceita cupom` |
| `CALL aplicar_cupom(24, 'VENCIDO15');` | `Cupom VENCIDO15 está vencido` |
| `CALL aplicar_cupom(72, 'BEMVINDO10');` | `Cliente 33 já usou o cupom BEMVINDO10` |

### Passo a passo

1. Declare uma linha inteira para o pedido e outra para o cupom (`%ROWTYPE`).
2. Trate cada regra na ordem do pedido do Rafael, cada uma com `IF` e `RAISE EXCEPTION`.
3. **Já usou?** Use `IF EXISTS (...)` com uma consulta em `pedido`: o mesmo cliente, o mesmo cupom, status diferente de `cancelado` e **outro** pedido (`id <> p_pedido`).
4. **A ação.** Um `UPDATE` no pedido.
5. **Teste:** o pedido 12 com `BEMVINDO10` (dá certo). Depois, os que falham: o pedido 2 com `BEMVINDO10`, o pedido 24 com `VENCIDO15` e o pedido 72 com `BEMVINDO10`.

**Confira:** o pedido 12 fica com o cupom `BEMVINDO10`. Os três testes que falham param com `Pedido 2 está pago e não aceita cupom`, `Cupom VENCIDO15 está vencido` e `Cliente 33 já usou o cupom BEMVINDO10`.

## Procedure 7 · Cancelar os pedidos vencidos

### Pedido do Rafael

O cliente tem 48 horas para pagar depois de fechar o pedido. Passou disso, o pedido é cancelado. Hoje alguém procura esses pedidos à mão, um por um. Quero uma procedure que cancele todos de uma vez e me diga quantos foram. Se não houver nenhum, quero saber.

| Recebe | O que faz |
|---|---|
| nada | cancela todos os pedidos `aguardando_pagamento` fechados há mais de 48 horas e mostra quantos foram, com `RAISE NOTICE` |

Mensagem de erro: `Nenhum pedido vencido para cancelar`.

**Exemplo de retorno** da primeira chamada (a quantidade conta a partir do dia em que você carregou a base). Na aba de saída: `5 pedido(s) cancelado(s)`. Depois, contando os pedidos por status:

| status | count |
|---|---|
| aguardando_pagamento | 5 |
| cancelado | 15 |

Os testes que falham:

| Chamada | Mensagem de erro |
|---|---|
| `CALL cancelar_pedidos_vencidos();` (de novo) | `Nenhum pedido vencido para cancelar` |

### Passo a passo

1. **Sem parâmetro.** A procedure é `cancelar_pedidos_vencidos()`, com os parênteses vazios. A chamada também: `CALL cancelar_pedidos_vencidos();`.
2. **Conte antes.** Guarde em uma variável quantos pedidos estão vencidos (`SELECT COUNT(*) INTO`). Vencido: `fechado_em + INTERVAL '48 hours' < LOCALTIMESTAMP`.
3. **Nenhum?** Se a contagem for `0`, pare com `RAISE EXCEPTION`.
4. **A ação.** Um único `UPDATE` com o mesmo filtro da contagem cancela todos de uma vez.
5. **Avise.** Mostre a contagem com `RAISE NOTICE`. A mensagem aparece na aba de saída do cliente.
6. **Teste:** chame duas vezes seguidas. Escreva antes o que você espera de cada chamada.

**Confira:** a primeira chamada mostra `5 pedido(s) cancelado(s)`. Depois dela, ficam 5 pedidos `aguardando_pagamento` (os que ainda estão no prazo) e 15 `cancelado` (eram 10). A segunda chamada para com `Nenhum pedido vencido para cancelar`. Se você carregou a base num dia e rodou o exercício em outro, a contagem pode ser maior: os prazos contam a partir do dia da carga.

## Para fixar (sem nota)

Responda em comentários, no fim do arquivo, **sem olhar o material**:

1. Função ou procedure: qual devolve um valor? Como se chama cada uma?
2. Depois de um `CALL`, como você confere o que a procedure fez?
3. O que acontece com os dados se a procedure para com `RAISE EXCEPTION` no meio do caminho?
