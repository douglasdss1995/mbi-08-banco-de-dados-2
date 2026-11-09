# Exercício 8 — Funções em SQL e em PL/pgSQL

Banco de Dados 2 · Turma MBI-08 · Aulas 17 e 18

SQL: *Structured Query Language*. PL/pgSQL: *Procedural Language/PostgreSQL* (a linguagem de programação do PostgreSQL). Função: uma regra da loja guardada no banco, com nome e parâmetros. UF: Unidade Federativa (o estado).

| | |
|---|---|
| **Como fazer** | Em dupla, no banco da Loja Virtual |
| **Entrega** | Cada aluno entrega o arquivo `exercicio-08.sql` no Classroom |
| **Prazo** | Ideal: até o fim da aula 18. Vale até 18/11 |

## O que fazer

O Rafael, dono da loja, repete as mesmas contas em vários lugares: frete, desconto, comissão. Cada lugar dá um resultado diferente. Ele quer cada regra **num lugar só**: no banco, como **função**.

Você vai criar **10 funções**. A parte 1 (funções 1 a 4) usa `LANGUAGE sql`. A parte 2 (funções 5 a 10) usa `LANGUAGE plpgsql`, com variável, `IF` e mensagem de erro.

Tudo vai em **um único arquivo**: `exercicio-08.sql`.

1. Abra o banco `loja` no seu cliente de banco de dados.
2. Crie o arquivo `exercicio-08.sql`. Na primeira linha, escreva `SET search_path TO loja;`.
3. Para cada função, nesta ordem:
   1. escreva um comentário com o número e a pergunta;
   2. escreva a consulta de teste **sem a função** (com os valores escritos à mão) e rode-a;
   3. crie a função (`CREATE OR REPLACE FUNCTION`);
   4. **antes de rodar**, escreva em um comentário o que você espera da chamada;
   5. chame a função e compare com o que você esperava.
4. Escreva um comentário em cada linha do SQL.
5. Rode o arquivo inteiro, do zero, antes de entregar.
6. Responda as 3 perguntas de «Para fixar», em comentários, no fim do arquivo.
7. Entregue no Classroom.

## Como o exercício ajuda você

A ajuda diminui a cada função. Assim você aprende a fazer sozinho.

| Funções | O que você recebe |
|---|---|
| 1 | O exemplo **resolvido**. Digite, rode e reescreva os comentários com as suas palavras |
| 2 a 4 | A função com **lacunas** (`___`) |
| 5 e 6 | A função com **lacunas** (agora em `plpgsql`) |
| 7 e 8 | Só a **estrutura**, em comentários |
| 9 e 10 | Só a **pergunta** e os passos |

Palavras que usamos sempre com o mesmo sentido: **parâmetro** (o que a função recebe, com `p_` na frente), **variável** (o que a função guarda no meio do caminho, com `v_` na frente) e **chamar** (usar a função em um `SELECT`).

## Regras

- Escreva um **comentário em cada linha** do SQL (`--`), dizendo o que a linha faz. Isso ajuda você a estudar.
- Teste **dois casos** em cada função: um que dá certo e um que dá errado (ou vazio).
- A função **só calcula e devolve**. Ela não grava nada (`INSERT`, `UPDATE`, `DELETE` ficam para as procedures).
- Uma mensagem de erro diz o motivo com as palavras da loja: «Pedido 999 não existe».
- Não use `LIMIT` para cortar o resultado de uma função: cada pergunta é sobre todas as linhas.
- Apoio: [referencia-criar-funcoes.md](referencia-criar-funcoes.md).

# Parte 1 — Funções em SQL

Uma função em `LANGUAGE sql` é **uma consulta com nome e parâmetros**.

## Função 1 · O preço com desconto

### Pedido do Rafael

Toda promoção da loja tem um percentual de desconto, e cada tela faz essa conta de um jeito. Preciso de uma função que receba o preço e o percentual e devolva o preço final, com os centavos. Assim todo mundo usa a mesma conta.

| Recebe | Devolve |
|---|---|
| `p_valor` (número) e `p_percentual` (número) | o valor com o desconto, em 2 casas |

### Passo a passo

1. **Consulta sem função.** Rode `SELECT ROUND(200 * (1 - 10 / 100.0), 2);`. Devolve `180.00`.
2. **Troque os valores escritos à mão pelos parâmetros.** `200` vira `p_valor`. `10` vira `p_percentual`.
3. **Crie a função.** O corpo é a consulta do passo 1.
4. **Antes de rodar**, escreva em um comentário quanto dá `valor_com_desconto(59.90, 15)`.

### Exemplo resolvido

Digite (não cole), rode e reescreva os comentários com as suas palavras:

```sql
CREATE OR REPLACE FUNCTION valor_com_desconto(p_valor numeric, p_percentual numeric)
RETURNS numeric
LANGUAGE sql IMMUTABLE AS $$
    SELECT ROUND(p_valor * (1 - p_percentual / 100), 2);
$$;

SELECT valor_com_desconto(200, 10);
SELECT valor_com_desconto(59.90, 15);
```

**Confira:** a primeira chamada devolve `180.00`. A segunda devolve `50.92`.

## Função 2 · O subtotal de um pedido

### Pedido do Rafael

Quando abro um pedido, quero saber quanto custam os itens dele, antes do desconto e do frete. Faça uma função que receba o pedido e some a quantidade vezes o preço de cada item. Se o pedido não tiver item, quero ver zero.

| Recebe                      | Devolve                                           |
| --------------------------- | ------------------------------------------------- |
| `p_pedido` (o id do pedido) | a soma de `quantidade * preco_unitario` dos itens |

### Passo a passo

1. **Consulta sem função.** Some `quantidade * preco_unitario` de `item_pedido` onde `pedido_id = 1`. Rode.
2. **Troque o `1` pelo parâmetro** `p_pedido`.
3. **Pedido sem item.** O `SUM` devolve vazio (`NULL`). Use `COALESCE(..., 0)` para devolver `0`.
4. **Antes de rodar**, escreva em um comentário quanto você espera para um pedido que não existe.

### Monte a função

Troque cada `___` e comente cada linha:

```sql
CREATE OR REPLACE FUNCTION subtotal_do_pedido(p_pedido ___)
RETURNS ___
LANGUAGE sql STABLE AS $$
    SELECT COALESCE(SUM(___ * ___), 0)
    FROM ___
    WHERE ___ = p_pedido;
$$;

SELECT subtotal_do_pedido(1);
SELECT subtotal_do_pedido(999999);
```

**Confira:** `subtotal_do_pedido(1)` devolve `1002.60`. `subtotal_do_pedido(999999)` devolve `0`.

## Função 3 · Quanto um cliente gastou

### Pedido do Rafael

Quero saber quanto cada cliente já gastou comigo. Conte só o que virou venda: pedido pago, enviado ou entregue. Carrinho, pedido aguardando pagamento e pedido cancelado não contam. Se o cliente nunca comprou, quero ver zero.

| Recebe                        | Devolve                                                                            |
| ----------------------------- | ---------------------------------------------------------------------------------- |
| `p_cliente` (o id do cliente) | a soma do `total` das vendas (`pago`, `enviado`, `entregue`); `0` se nunca comprou |

### Passo a passo

1. **Consulta sem função.** Some o `total` de `pedido` do cliente 25, só nas vendas. Rode.
2. **Troque o `25` pelo parâmetro** `p_cliente`.
3. **Cliente sem compra.** Devolva `0`, não vazio.
4. **Use a função dentro de uma consulta.** Liste `nome` e `gasto_do_cliente(id)` de todos os clientes, do que mais gastou ao que menos gastou.

### Monte a função

Troque cada `___` e comente cada linha:

```sql
CREATE OR REPLACE FUNCTION gasto_do_cliente(p_cliente integer)
RETURNS numeric
LANGUAGE sql STABLE AS $$
    SELECT COALESCE(SUM(___), 0)
    FROM ___
    WHERE ___ = p_cliente
      AND status IN (___);
$$;

SELECT gasto_do_cliente(25);
SELECT nome, gasto_do_cliente(id) AS gasto
FROM cliente
ORDER BY gasto DESC, nome;
```

**Confira:** `gasto_do_cliente(25)` devolve `3417.96`. O cliente 1 gastou `2693.91`. A lista tem 40 linhas; as três primeiras são `Cliente 25`, `Cliente 37` (os dois com `3417.96`) e `Cliente 09` (`3361.47`).

## Função 4 · Os pedidos de um cliente

### Pedido do Rafael

O cliente liga no atendimento e pergunta pelos pedidos dele. Quero uma função que receba o cliente e devolva a lista dos pedidos, com o número, a situação e o total de cada um. Mostre do mais antigo ao mais novo.

Aqui a função devolve **várias linhas**. Em vez de `RETURNS numeric`, você usa `RETURNS TABLE (...)`: uma tabela com as colunas que você listar.

| Recebe | Devolve |
|---|---|
| `p_cliente` (o id do cliente) | uma tabela com `numero`, `status` e `total` de cada pedido, do mais antigo ao mais novo |

### Passo a passo

1. **Consulta sem função.** Liste `numero`, `status` e `total` de `pedido` do cliente 25, ordenado pelo `id`. Rode.
2. **Troque o `25` pelo parâmetro.**
3. **Declare as colunas** em `RETURNS TABLE (numero varchar, status varchar, total numeric)`. A ordem é a mesma do `SELECT`.
4. **Chame com `SELECT * FROM`**, porque a função devolve uma tabela.
5. **Antes de rodar**, escreva em um comentário quantas linhas você espera para o cliente 25.

### Monte a função

Troque cada `___` e comente cada linha:

```sql
CREATE OR REPLACE FUNCTION pedidos_do_cliente(p_cliente integer)
RETURNS ___ (numero varchar, status varchar, total numeric)
LANGUAGE sql STABLE AS $$
    SELECT p.___, p.___, p.___
    FROM ___ p
    WHERE p.___ = p_cliente
    ORDER BY p.___;
$$;

SELECT * FROM pedidos_do_cliente(25);
```

**Confira:** 3 linhas. A primeira é um `carrinho` (sem `total`), a segunda é um `pago` de `2018.07` e a terceira é um `entregue` de `1399.89`.

# Parte 2 — Funções em PL/pgSQL

Uma função em `LANGUAGE plpgsql` pode **guardar valores em variáveis**, **decidir com `IF`** e **parar com uma mensagem de erro**.

Partes novas:

| Parte | Para que serve |
|---|---|
| `DECLARE` | Cria as variáveis (`v_estoque integer;`) |
| `SELECT ... INTO` | Guarda o resultado da consulta em variáveis |
| `IF NOT FOUND` | Testa se o `SELECT ... INTO` achou alguma linha |
| `IF ... ELSIF ... ELSE` | Escolhe um caminho |
| `RAISE EXCEPTION 'texto %', valor` | Para a função com uma mensagem (o `%` recebe o valor) |
| `RETURN` | Devolve o resultado e encerra a função |

## Função 5 · A situação do estoque

### Pedido do Rafael

Não quero descobrir que um produto acabou só quando o cliente reclama. Quero uma função que olhe o estoque de um produto e diga se está bom, se pede atenção ou se preciso repor. Se eu passar um produto que não existe, quero uma mensagem clara.

| Recebe | Devolve |
|---|---|
| `p_produto` (o id do produto) | `repor` (estoque abaixo do mínimo), `atenção` (abaixo de 4 vezes o mínimo) ou `ok` |

Se o produto não existe, a função para com a mensagem `Produto 999 não existe`.

### Passo a passo

1. **Consulta sem função.** Veja `estoque` e `estoque_minimo` do produto 3. Rode.
2. **Variáveis.** Declare `v_estoque` e `v_minimo`. Guarde as duas colunas com `SELECT ... INTO`.
3. **Produto que não existe.** Logo depois do `SELECT ... INTO`, teste `IF NOT FOUND` e pare com `RAISE EXCEPTION`.
4. **Decida.** Use `IF ... ELSIF ... ELSE` e devolva o texto com `RETURN`.
5. **Teste dois casos:** o produto 3 e o produto 1. Escreva antes o que você espera de cada um.

### Monte a função

Troque cada `___` e comente cada linha:

```sql
CREATE OR REPLACE FUNCTION classificar_estoque(p_produto integer)
RETURNS text
LANGUAGE plpgsql STABLE AS $$
DECLARE
    v_estoque integer;
    v_minimo  ___;
BEGIN
    SELECT estoque, estoque_minimo INTO ___, ___
    FROM produto WHERE id = p_produto;
    IF NOT ___ THEN
        RAISE EXCEPTION 'Produto % não existe', p_produto;
    END IF;
    IF v_estoque < v_minimo THEN
        RETURN '___';
    ELSIF v_estoque < v_minimo * ___ THEN
        RETURN 'atenção';
    ELSE
        RETURN 'ok';
    END IF;
END;
$$;

SELECT classificar_estoque(3);
SELECT classificar_estoque(1);
SELECT classificar_estoque(id) AS situacao, COUNT(*)
FROM produto GROUP BY 1 ORDER BY 1;
```

**Confira:** `classificar_estoque(3)` devolve `repor`. `classificar_estoque(1)` devolve `ok`. A última consulta mostra `atenção` 5, `ok` 15 e `repor` 10.

## Função 6 · O desconto de um cupom

### Pedido do Rafael

O cliente digita o código do cupom no carrinho, e eu preciso saber de quanto é o desconto. Tenho cupom de percentual e cupom de valor fixo. O desconto nunca pode passar do valor da compra.

| Recebe | Devolve |
|---|---|
| `p_codigo` (o código do cupom) e `p_subtotal` (número) | cupom `percentual`: o percentual do subtotal, em 2 casas. Cupom `fixo`: o valor do cupom, mas nunca mais que o subtotal |

Se o cupom não existe, a função para com a mensagem `Cupom XYZ não existe`.

### Passo a passo

1. **Variável de linha inteira.** `c cupom%ROWTYPE;` guarda a linha inteira do cupom. Você lê as colunas com `c.tipo` e `c.valor`.
2. **Busque o cupom** com `SELECT * INTO c FROM cupom WHERE codigo = p_codigo;`.
3. **Cupom que não existe.** Teste `IF NOT FOUND` e pare com `RAISE EXCEPTION`.
4. **Cupom percentual.** Devolva `ROUND(p_subtotal * c.valor / 100, 2)`.
5. **Cupom fixo.** Devolva o menor entre o valor do cupom e o subtotal: `LEAST(c.valor, p_subtotal)`.
6. **Teste três casos:** `NATAL20` com 200, `FRETE50` com 30 e `XYZ` com 100. Escreva antes o que você espera.

### Monte a função

Troque cada `___` e comente cada linha:

```sql
CREATE OR REPLACE FUNCTION desconto_do_cupom(p_codigo varchar, p_subtotal numeric)
RETURNS numeric
LANGUAGE plpgsql STABLE AS $$
DECLARE
    c ___%ROWTYPE;
BEGIN
    SELECT * INTO c FROM cupom WHERE codigo = ___;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Cupom % não existe', p_codigo;
    END IF;
    IF c.tipo = '___' THEN
        RETURN ROUND(p_subtotal * c.valor / 100, 2);
    END IF;
    RETURN LEAST(c.valor, ___);
END;
$$;

SELECT desconto_do_cupom('NATAL20', 200);
SELECT desconto_do_cupom('FRETE50', 30);
SELECT desconto_do_cupom('XYZ', 100);
```

**Confira:** a primeira chamada devolve `40.00`. A segunda devolve `30` (o cupom fixo é de 50, mas o subtotal é só 30). A terceira para com o erro `Cupom XYZ não existe`. Comente a terceira linha depois de ver o erro, para o arquivo rodar inteiro.

## Função 7 · A comissão de um pedido

### Pedido do Rafael

Meus vendedores ganham comissão em cada venda, e o percentual depende do cargo de cada um. Quero uma função que receba o pedido e diga quanto o vendedor ganha. Pedido sem vendedor não paga comissão.

| Recebe | Devolve |
|---|---|
| `p_pedido` (o id do pedido) | o percentual do cargo do vendedor sobre (`subtotal` menos `desconto`), em 2 casas. `0` se o pedido não tem vendedor ou não tem `subtotal` |

Se o pedido não existe, a função para com a mensagem `Pedido 999 não existe`.

### Passo a passo

1. **Consulta sem função.** Veja o `subtotal`, o `desconto` e o `vendedor_id` do pedido 1. Veja o `comissao_percentual` do cargo desse vendedor (ligue `funcionario` e `cargo`). Rode.
2. **Variáveis.** Uma para a base (`subtotal - desconto`), uma para o vendedor, uma para o percentual.
3. **Pedido que não existe:** `IF NOT FOUND` e `RAISE EXCEPTION`.
4. **Sem vendedor ou sem `subtotal`:** devolva `0`.
5. **Busque o percentual** com um segundo `SELECT ... INTO`.
6. **Devolva** a base vezes o percentual dividido por 100, em 2 casas.
7. **Teste:** o pedido 1 (tem vendedor), o pedido 2 (não tem) e o pedido 999999.

### Estrutura

Escreva a função a partir destes comentários:

```sql
-- nome: comissao_do_pedido, recebe p_pedido integer, RETURNS numeric, LANGUAGE plpgsql STABLE
-- DECLARE: v_base numeric, v_vendedor integer, v_pct numeric
-- 1) SELECT subtotal - desconto, vendedor_id INTO v_base, v_vendedor FROM pedido do p_pedido
-- 2) se não achou o pedido: RAISE EXCEPTION 'Pedido % não existe'
-- 3) se v_vendedor ou v_base for NULL: RETURN 0
-- 4) SELECT comissao_percentual INTO v_pct (funcionario ligado a cargo, do vendedor)
-- 5) RETURN ROUND(v_base * v_pct / 100, 2)
```

**Confira:** a comissão do pedido 1 é `30.08` (3% de `1002.60`). A do pedido 2, sem vendedor, é `0`. A do pedido 999999 para com o erro `Pedido 999999 não existe`.

## Função 8 · Quanto ainda dá para devolver

### Pedido do Rafael

O cliente comprou 3 unidades de um produto e já pediu para devolver 1. Quantas ele ainda pode devolver? Quero essa conta para qualquer pedido e produto. A devolução que eu recusei não conta.

| Recebe | Devolve |
|---|---|
| `p_pedido` e `p_produto` (os dois ids) | a quantidade comprada menos a quantidade já em devolução (`solicitada` ou `concluida`; a `recusada` não conta) |

### Passo a passo

1. **Duas variáveis:** `v_comprada` e `v_devolvida`.
2. **Comprada.** Some a `quantidade` de `item_pedido` daquele pedido e produto. Use `COALESCE(..., 0)`: se o cliente não comprou, é `0`.
3. **Devolvida.** Some a `quantidade` de `item_devolucao`, ligada a `devolucao`, daquele pedido e produto, só nas devoluções `solicitada` ou `concluida`. Use `COALESCE(..., 0)`.
4. **Devolva** a diferença.
5. **Teste:** o pedido 8 com o produto 6 e o pedido 20 com o produto 6. Escreva antes o que você espera.

### Estrutura

Escreva a função a partir destes comentários:

```sql
-- nome: quantidade_devolvivel, recebe p_pedido integer e p_produto integer, RETURNS integer, LANGUAGE plpgsql STABLE
-- DECLARE: v_comprada integer, v_devolvida integer
-- 1) SELECT COALESCE(SUM(quantidade), 0) INTO v_comprada FROM item_pedido (pedido e produto recebidos)
-- 2) SELECT COALESCE(SUM(...), 0) INTO v_devolvida FROM item_devolucao JOIN devolucao (pedido e produto recebidos; status solicitada ou concluida)
-- 3) RETURN v_comprada - v_devolvida
```

**Confira:** `quantidade_devolvivel(8, 6)` devolve `2` (o cliente comprou 3). `quantidade_devolvivel(20, 6)` devolve `3`. `quantidade_devolvivel(9, 19)` devolve `1`.

## Função 9 · A devolução é permitida?

### Pedido do Rafael

O cliente pede para devolver um pedido, e o atendente precisa responder na hora se pode ou não. Quero uma função que diga se a devolução está liberada ou, se não estiver, o motivo, com as palavras da loja.

Regras da loja: só o pedido `entregue` pode ser devolvido, e até 7 dias depois da entrega.

| Recebe | Devolve |
|---|---|
| `p_pedido` (o id do pedido) | `ok`, ou o motivo da recusa: `Pedido ainda não foi entregue` ou `Prazo de 7 dias vencido` |

Se o pedido não existe, a função para com a mensagem `Pedido 999 não existe`.

### Passo a passo

1. Busque o `status` e o `entregue_em` do pedido com `SELECT ... INTO`.
2. Trate o pedido que não existe.
3. Trate cada recusa, na ordem das regras, com `IF` e `RETURN`.
4. Se passou por tudo, devolva `ok`.
5. Para contar dias, subtraia datas: `CURRENT_DATE - 7` é a data de 7 dias atrás. `entregue_em::date` tira a hora.
6. **Teste** com uma consulta que chama a função para todos os pedidos e conta quantos recebem cada resposta.

**Confira:** os 80 pedidos que não estão `entregue` recebem `Pedido ainda não foi entregue`. Os 40 pedidos `entregue` se dividem entre `ok` e `Prazo de 7 dias vencido`. A divisão depende do dia em que você carregou a base.

## Função 10 · A faixa do cliente

### Pedido do Rafael

Quero premiar quem mais compra na loja. Cada cliente fica numa faixa pelo quanto já gastou: ouro, prata ou bronze. Quem nunca comprou fica numa faixa à parte.

| Gasto | Faixa |
|---|---|
| 3000 ou mais | `ouro` |
| de 1500 a menos de 3000 | `prata` |
| mais que 0 e menos de 1500 | `bronze` |
| nunca comprou | `sem compras` |

| Recebe | Devolve |
|---|---|
| `p_cliente` (o id do cliente) | o nome da faixa |

Se o cliente não existe, a função para com a mensagem `Cliente 999 não existe`.

### Passo a passo

1. **Reaproveite.** Use a função 3 (`gasto_do_cliente`) dentro desta função e guarde o resultado em uma variável (`v_gasto := gasto_do_cliente(p_cliente);`).
2. **Cliente que não existe.** Teste com `IF NOT EXISTS (SELECT 1 FROM cliente WHERE id = p_cliente)`.
3. **Decida a faixa** com `IF ... ELSIF ...`, da maior para a menor.
4. **Cliente sem compra.** Devolva `sem compras` depois dos testes.
5. **Teste:** o cliente 25, o cliente 1 e o cliente 999. Depois conte quantos clientes há em cada faixa.

**Confira:** o cliente 25 é `ouro` e o cliente 1 é `prata`. O cliente 999 para com o erro `Cliente 999 não existe`. A contagem: `bronze` 20, `ouro` 9 e `prata` 11.

## Para fixar (sem nota)

Responda em comentários, no fim do arquivo, **sem olhar o material**:

1. O que vai no `RETURNS` de uma função? E o que o `RETURN` faz?
2. Para que serve o `DECLARE`? Onde o `SELECT ... INTO` guarda o resultado?
3. O que o `RAISE EXCEPTION` faz com a função?
