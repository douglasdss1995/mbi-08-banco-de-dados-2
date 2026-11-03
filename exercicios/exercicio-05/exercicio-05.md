# Exercício 5 — Funções SQL e view simples

Banco de Dados 2 · Turma MBI-08 · Aula 13 (03/11/2026)

SQL: *Structured Query Language*. SKU: *Stock Keeping Unit* (código interno do produto). CEP: *Código de Endereçamento Postal*. UF: *Unidade Federativa* (o estado). View: uma consulta guardada com um nome.

| | |
|---|---|
| **Como fazer** | Em dupla, no banco da Loja Virtual |
| **Entrega** | Cada aluno entrega o arquivo `exercicio-05.sql` no Classroom |
| **Prazo** | Ideal: até o fim da aula 13. Vale até 18/11 |

## O que fazer

O Rafael, dono da loja, tem **10 perguntas** sobre o negócio. Para cada pergunta, você escreve uma **consulta** em SQL, usando funções do SQL. Logo depois de cada consulta, você guarda a mesma consulta como **view**.

Tudo vai em **um único arquivo**: `exercicio-05.sql`.

1. Abra o banco `loja` no seu cliente de banco de dados.
2. Crie o arquivo `exercicio-05.sql`.
3. Para cada consulta, nesta ordem:
   1. escreva um comentário com o número e a pergunta;
   2. escreva a consulta e confira o resultado;
   3. crie a view com a mesma consulta;
   4. consulte a view e confira que o resultado é igual.
4. Escreva um comentário em cada linha do SQL.
5. Rode o arquivo inteiro, do zero, antes de entregar.
6. Entregue no Classroom.

## Regras

- Escreva um **comentário em cada linha** do SQL (`--`), dizendo o que a linha faz. Isso ajuda você a estudar.
- Antes de cada consulta, um comentário com o número e a pergunta.
- Em cada consulta: primeiro a **consulta**, logo depois a **view** com a mesma consulta, e uma consulta que usa a view.
- Não use `LIMIT`: cada pergunta é sobre todas as linhas.
- Apoio: [referencia-funcoes-sql.md](referencia-funcoes-sql.md).


## Consulta 1 · Nome e código dos produtos

**Pergunta da loja:** «Quero imprimir etiquetas. Preciso do nome de cada produto em letras maiúsculas e do código sem o `SKU-`.»

**O que mostrar:**

| produto | codigo |
|---|---|
| TECLADO PLUS | 0001 |
| MOUSE LITE | 0002 |
| HEADSET MAX | 0003 |
| ... | ... |

### Passo a passo

1. **Onde estão os dados?** Na tabela `produto`, nas colunas `nome` e `sku`.
2. **Nome em maiúsculas.** `UPPER` deixa o texto em maiúsculas. Teste com um valor solto: `SELECT UPPER('Teclado Plus');` mostra `TECLADO PLUS`.
3. **Código sem prefixo.** `REPLACE(texto, trecho, novo)` troca um trecho por outro. Para tirar o `SKU-`, troque-o por um texto vazio (`''`): `SELECT REPLACE('SKU-0001', 'SKU-', '');` mostra `0001`.
4. **Nome das colunas.** `AS` dá o nome da coluna no resultado: `produto` e `codigo`.
5. **Ordem.** `ORDER BY id` faz a lista sair sempre igual.
6. **Sem `LIMIT`.** A pergunta é sobre todos os produtos.

### Monte a consulta

Troque cada `___` e comente cada linha:

```sql
SELECT ___ AS produto,
       ___ AS codigo
FROM ___
ORDER BY ___;
```

**Confira:** 30 linhas; a primeira é `TECLADO PLUS` com `0001`.

### Agora a view

Logo depois da consulta, guarde-a com o nome `vw_produto_codigo`:

```sql
CREATE OR REPLACE VIEW vw_produto_codigo AS
___;   -- a consulta 1, sem o ponto e vírgula do fim

SELECT * FROM vw_produto_codigo;
```

**Confira:** a view mostra as mesmas linhas da consulta 1.

## Consulta 2 · Login de cada cliente

**Pergunta da loja:** «Quero criar o login de cada cliente. O login é o que vem antes do `@` no e-mail.»

**O que mostrar:**

| nome | usuario |
|---|---|
| Cliente 01 | cliente01 |
| Cliente 02 | cliente02 |
| Cliente 03 | cliente03 |
| ... | ... |

### Passo a passo

1. **Onde estão os dados?** Na tabela `cliente`, nas colunas `nome` e `email`.
2. **Achar o `@`.** `POSITION('@' IN texto)` diz em que posição do texto está o `@`. Teste: `SELECT POSITION('@' IN 'ana@exemplo.test');` mostra `4`.
3. **Cortar o texto.** `SUBSTRING(texto FROM 1 FOR n)` pega `n` letras a partir da 1ª. Teste: `SELECT SUBSTRING('ana@exemplo.test' FROM 1 FOR 3);` mostra `ana`.
4. **Quantas letras pegar?** Todas as que vêm antes do `@`: a posição do `@` menos 1.
5. **Nome da coluna e ordem.** `AS usuario` e `ORDER BY id`.
6. **Sem `LIMIT`.** A pergunta é sobre todos os clientes.

### Monte a consulta

Troque cada `___` e comente cada linha:

```sql
SELECT nome,
       SUBSTRING(email FROM 1 FOR ___) AS usuario
FROM ___
ORDER BY ___;
```

**Confira:** 40 linhas; a primeira é `Cliente 01` com `cliente01`.

### Agora a view

Logo depois da consulta, guarde-a com o nome `vw_cliente_usuario`:

```sql
CREATE OR REPLACE VIEW vw_cliente_usuario AS
___;   -- a consulta 2, sem o ponto e vírgula do fim

SELECT * FROM vw_cliente_usuario;
```

**Confira:** a view mostra as mesmas linhas da consulta 2.

## Consulta 3 · CEP no formato certo

**Pergunta da loja:** «Quero imprimir o endereço de entrega com o CEP no formato `01000-311`.»

**O que mostrar:**

| cidade | uf | cep |
|---|---|---|
| Rio de Janeiro | RJ | 01000-311 |
| Belo Horizonte | MG | 01000-312 |
| Belo Horizonte | MG | 01000-622 |
| ... | ... | ... |

### Passo a passo

1. **Onde estão os dados?** Na tabela `endereco`, nas colunas `cidade`, `uf` e `cep`. O `cep` está guardado sem traço: `01000311`.
2. **Primeiras letras.** `LEFT(texto, n)` pega as `n` primeiras. Teste: `SELECT LEFT('01000311', 5);` mostra `01000`.
3. **Últimas letras.** `RIGHT(texto, n)` pega as `n` últimas. Teste: `SELECT RIGHT('01000311', 3);` mostra `311`.
4. **Juntar.** `||` junta textos: `LEFT(cep, 5) || '-' || RIGHT(cep, 3)`.
5. **Nome da coluna e ordem.** `AS cep` e `ORDER BY id`.
6. **Sem `LIMIT`.** A pergunta é sobre todos os endereços.

### Monte a consulta

Troque cada `___` e comente cada linha:

```sql
SELECT cidade, uf,
       ___ AS cep
FROM ___
ORDER BY ___;
```

**Confira:** 60 linhas; a primeira é `Rio de Janeiro`, `RJ`, `01000-311`.

### Agora a view

Logo depois da consulta, guarde-a com o nome `vw_endereco_cep`:

```sql
CREATE OR REPLACE VIEW vw_endereco_cep AS
___;   -- a consulta 3, sem o ponto e vírgula do fim

SELECT * FROM vw_endereco_cep;
```

**Confira:** a view mostra as mesmas linhas da consulta 3.

## Consulta 4 · Parcelas em 3 vezes

**Pergunta da loja:** «Quero mostrar quanto fica cada parcela se o cliente parcelar em 3 vezes: com centavos e arredondada para cima, em reais inteiros.»

**O que mostrar:**

| pedido_id | valor | parcela | parcela_inteira |
|---|---|---|---|
| 31 | 215.60 | 71.87 | 72 |
| 55 | 221.89 | 73.96 | 74 |
| 79 | 221.89 | 73.96 | 74 |
| ... | ... | ... | ... |

### Passo a passo

1. **Onde estão os dados?** Na tabela `pagamento`, nas colunas `pedido_id` e `valor`.
2. **Dividir.** A parcela é `valor / 3`.
3. **Duas casas.** `ROUND(número, 2)` arredonda para 2 casas. Teste: `SELECT ROUND(100 / 3.0, 2);` mostra `33.33`.
4. **Para cima.** `CEIL(número)` arredonda para cima, para um número inteiro. Teste: `SELECT CEIL(100 / 3.0);` mostra `34`.
5. **Nome das colunas e ordem.** `AS parcela`, `AS parcela_inteira` e `ORDER BY id`.
6. **Sem `LIMIT`.** A pergunta é sobre todos os pagamentos.

### Monte a consulta

Troque cada `___` e comente cada linha:

```sql
SELECT pedido_id, valor,
       ___ AS parcela,
       ___ AS parcela_inteira
FROM ___
ORDER BY ___;
```

**Confira:** 90 linhas; a primeira é o pedido `31`, valor `215.60`, parcela `71.87` e parcela inteira `72`.

### Agora a view

Logo depois da consulta, guarde-a com o nome `vw_pagamento_parcelas`:

```sql
CREATE OR REPLACE VIEW vw_pagamento_parcelas AS
___;   -- a consulta 4, sem o ponto e vírgula do fim

SELECT * FROM vw_pagamento_parcelas;
```

**Confira:** a view mostra as mesmas linhas da consulta 4.

## Consulta 5 · Situação dos cupons

**Pergunta da loja:** «Quero ver cada cupom com os dias que faltam para vencer e a situação: `vencido`, `vence em até 30 dias` ou `válido`.»

**O que mostrar:**

| codigo | valido_ate | dias | situacao |
|---|---|---|---|
| VENCIDO15 | (30 dias atrás) | -30 | vencido |
| ULTIMO30 | (daqui a 30 dias) | 30 | vence em até 30 dias |
| VIP25 | (daqui a 45 dias) | 45 | válido |
| ... | ... | ... | ... |

### Passo a passo

1. **Onde estão os dados?** Na tabela `cupom`, nas colunas `codigo` e `valido_ate`.
2. **Dia de hoje.** `CURRENT_DATE` é a data de hoje.
3. **Dias que faltam.** Data menos data dá o número de dias: `valido_ate - CURRENT_DATE`. Teste: `SELECT (CURRENT_DATE + 10) - CURRENT_DATE;` mostra `10`.
4. **Situação.** `CASE WHEN condição THEN resultado ... ELSE resultado END` escolhe um texto. As condições são testadas **na ordem**: a primeira verdadeira vence.
5. **Ordem das condições.** Primeiro «já venceu» (`valido_ate < CURRENT_DATE`), depois «faltam 30 dias ou menos», e o resto é `válido`.
6. **Nome das colunas e ordem.** `AS dias`, `AS situacao` e `ORDER BY valido_ate`.

### Monte a consulta

Troque cada `___` e comente cada linha:

```sql
SELECT codigo, valido_ate,
       valido_ate - CURRENT_DATE AS dias,
       CASE WHEN ___ THEN 'vencido'
            WHEN ___ THEN 'vence em até 30 dias'
            ELSE 'válido' END AS situacao
FROM ___
ORDER BY ___;
```

**Confira:** uma linha para cada cupom; `VENCIDO15` é o único `vencido`, e `NATAL20` e `BEMVINDO10` estão `válido`.

### Agora a view

Logo depois da consulta, guarde-a com o nome `vw_cupom_situacao`:

```sql
CREATE OR REPLACE VIEW vw_cupom_situacao AS
___;   -- a consulta 5, sem o ponto e vírgula do fim

SELECT * FROM vw_cupom_situacao;
```

**Confira:** a view mostra as mesmas linhas da consulta 5.

## Consulta 6 · Avaliações em texto

**Pergunta da loja:** «Quero ler as avaliações em palavras: a nota como `ruim`, `regular` ou `boa`, e o comentário (ou `sem comentário`, quando o cliente não escreveu).»

**O que mostrar:**

| produto_id | nota | avaliacao | comentario |
|---|---|---|---|
| 6 | 2 | ruim | Chegou rápido. |
| 12 | 3 | regular | Chegou rápido. |
| 23 | 4 | boa | Chegou rápido. |
| ... | ... | ... | ... |

### Passo a passo

1. **Onde estão os dados?** Na tabela `avaliacao`, nas colunas `produto_id`, `nota` e `comentario`.
2. **Nota em palavras.** `CASE`: notas 1 e 2 são `ruim`, a 3 é `regular` e o resto (4 e 5) é `boa`.
3. **Comentário vazio.** Quando o cliente não escreve, o comentário é `NULL` (nulo, «sem valor»). `COALESCE(a, b)` devolve `a`, ou `b` se `a` for nulo. Teste: `SELECT COALESCE(NULL, 'sem comentário');` mostra `sem comentário`.
4. **Nome das colunas e ordem.** `AS avaliacao`, `AS comentario` e `ORDER BY id`.
5. **Sem `LIMIT`.** A pergunta é sobre todas as avaliações.

### Monte a consulta

Troque cada `___` e comente cada linha:

```sql
SELECT produto_id, nota,
       CASE WHEN ___ THEN 'ruim'
            WHEN ___ THEN 'regular'
            ELSE 'boa' END AS avaliacao,
       COALESCE(___, 'sem comentário') AS comentario
FROM ___
ORDER BY ___;
```

**Confira:** 50 linhas; a primeira é o produto `6`, nota `2`, `ruim`.

### Agora a view

Logo depois da consulta, guarde-a com o nome `vw_avaliacao_texto`:

```sql
CREATE OR REPLACE VIEW vw_avaliacao_texto AS
___;   -- a consulta 6, sem o ponto e vírgula do fim

SELECT * FROM vw_avaliacao_texto;
```

**Confira:** a view mostra as mesmas linhas da consulta 6.

## Consulta 7 · Total recebido por mês

**Pergunta da loja:** «Quero saber quanto a loja recebeu em cada mês: quantos pagamentos e o total, com o mês escrito como `10/2026`.»

**O que mostrar:**

| mes | pagamentos | total |
|---|---|---|
| 07/2026 | 7 | 6178.14 |
| 08/2026 | 24 | 20639.82 |
| 09/2026 | 21 | 19121.63 |
| ... | ... | ... |

### Passo a passo

1. **Onde estão os dados?** Na tabela `pagamento`, nas colunas `valor` e `pago_em` (a data e a hora do pagamento).
2. **Início do mês.** `DATE_TRUNC('month', data)` corta a data no início do mês. Teste: `SELECT DATE_TRUNC('month', CURRENT_DATE);`.
3. **Mês escrito.** `TO_CHAR(data, 'MM/YYYY')` escreve a data como texto. Teste: `SELECT TO_CHAR(CURRENT_DATE, 'MM/YYYY');`.
4. **Somar e contar por mês.** `SUM(valor)` soma e `COUNT(*)` conta as linhas. Com `GROUP BY` o banco faz isso **uma vez para cada mês**.
5. **Ordem.** `ORDER BY` o início do mês, para os meses saírem em ordem de calendário.
6. **Regra do `GROUP BY`.** O que está no `SELECT` fora de `SUM` e `COUNT` tem de estar no `GROUP BY`.

### Monte a consulta

Troque cada `___` e comente cada linha:

```sql
SELECT TO_CHAR(DATE_TRUNC('month', pago_em), 'MM/YYYY') AS mes,
       ___ AS pagamentos,
       ___ AS total
FROM ___
GROUP BY ___
ORDER BY ___;
```

**Confira:** a soma da coluna `total` é igual a `SELECT SUM(valor) FROM pagamento;` (no exemplo da carga, `73055.92`), e o total dos pagamentos é `90`.

### Agora a view

Logo depois da consulta, guarde-a com o nome `vw_recebido_por_mes`:

```sql
CREATE OR REPLACE VIEW vw_recebido_por_mes AS
___;   -- a consulta 7, sem o ponto e vírgula do fim

SELECT * FROM vw_recebido_por_mes;
```

**Confira:** a view mostra as mesmas linhas da consulta 7.

## Consulta 8 · Carrinhos parados

**Pergunta da loja:** «Quero chamar os clientes que deixaram o carrinho parado. Preciso saber há quantas horas cada carrinho está parado.»

**O que mostrar:**

| id | criado_em | horas |
|---|---|---|
| 120 | (30 horas atrás) | 32 |
| 108 | ... | 29 |
| 96 | ... | 26 |
| ... | ... | ... |

### Passo a passo

1. **Onde estão os dados?** Na tabela `pedido`: carrinho é um pedido com `status = 'carrinho'`. As colunas são `id` e `criado_em`.
2. **Filtrar.** `WHERE status = 'carrinho'` deixa só os carrinhos.
3. **Agora menos antes.** `LOCALTIMESTAMP - criado_em` dá o tempo parado (um intervalo).
4. **Em segundos.** `EXTRACT(EPOCH FROM intervalo)` converte o intervalo em segundos. Teste: `SELECT EXTRACT(EPOCH FROM INTERVAL '2 hours');` mostra `7200`.
5. **Em horas.** Divida por 3600 (segundos em uma hora) e arredonde com `ROUND`.
6. **Ordem.** `ORDER BY criado_em`: o carrinho mais antigo primeiro.

### Monte a consulta

Troque cada `___` e comente cada linha:

```sql
SELECT id, criado_em,
       ROUND(___ / 3600) AS horas
FROM ___
WHERE ___
ORDER BY ___;
```

**Confira:** 10 carrinhos; o primeiro é o mais antigo (cerca de 32 horas no dia da carga).

### Agora a view

Logo depois da consulta, guarde-a com o nome `vw_carrinho_parado`:

```sql
CREATE OR REPLACE VIEW vw_carrinho_parado AS
___;   -- a consulta 8, sem o ponto e vírgula do fim

SELECT * FROM vw_carrinho_parado;
```

**Confira:** a view mostra as mesmas linhas da consulta 8.

## Consulta 9 · Histórico de preços

**Pergunta da loja:** «Quero ver todos os preços que cada produto já teve: o preço escrito como `R$ 141.90`, desde que dia vale (dia/mês/ano) e quanto ficaria com 10% de desconto.»

**O que mostrar:**

| produto | preco | desde | preco_promocional |
|---|---|---|---|
| Teclado Plus | R$ 141.90 | 01/01/2025 | 127.71 |
| Mouse Lite | R$ 252.90 | 01/01/2025 | 227.61 |
| Headset Max | R$ 93.90 | 01/01/2025 | 84.51 |
| ... | ... | ... | ... |

### Passo a passo

1. **Onde estão os dados?** Os preços estão em `preco_produto` (`preco` e `vigencia_inicio`), e o nome do produto em `produto`.
2. **Ligar as tabelas.** `JOIN produto ... ON produto.id = preco_produto.produto_id` traz o nome do produto para cada preço.
3. **Preço com «R$».** `TO_CHAR(preco, 'FM999990.00')` escreve o número com 2 casas. Junte com `'R$ ' || ...`. Teste: `SELECT 'R$ ' || TO_CHAR(28.9, 'FM999990.00');` mostra `R$ 28.90`.
4. **Data escrita.** `TO_CHAR(data, 'DD/MM/YYYY')`: dia, mês e ano.
5. **Promoção.** 10% de desconto é multiplicar por `0.9`: `ROUND(preco * 0.9, 2)`.
6. **Ordem.** Por produto e, dentro dele, pela data em que o preço começou.

### Monte a consulta

Troque cada `___` e comente cada linha:

```sql
SELECT pr.nome AS produto,
       ___ AS preco,
       ___ AS desde,
       ___ AS preco_promocional
FROM preco_produto pp
JOIN ___ pr ON ___
ORDER BY ___;
```

**Confira:** 37 linhas (30 produtos, e 7 deles com um segundo preço); a primeira é `Teclado Plus`, `R$ 141.90`, `01/01/2025`, `127.71`.

### Agora a view

Logo depois da consulta, guarde-a com o nome `vw_preco_historico`:

```sql
CREATE OR REPLACE VIEW vw_preco_historico AS
___;   -- a consulta 9, sem o ponto e vírgula do fim

SELECT * FROM vw_preco_historico;
```

**Confira:** a view mostra as mesmas linhas da consulta 9.

## Consulta 10 · Percentual de desconto

**Pergunta da loja:** «Quero saber quantos por cento do pedido foram desconto, só nos pedidos que usaram cupom.»

**O que mostrar:**

| id | subtotal | desconto | percentual |
|---|---|---|---|
| 7 | 200.60 | 20.06 | 10.0 |
| 14 | 1295.40 | 5.00 | 0.4 |
| 15 | 91.80 | 5.00 | 5.4 |
| ... | ... | ... | ... |

### Passo a passo

1. **Onde estão os dados?** Na tabela `pedido`: `id`, `subtotal`, `desconto` e `cupom_id`.
2. **Só com cupom.** `WHERE cupom_id IS NOT NULL` deixa só os pedidos que usaram cupom. Para testar nulo, use `IS NULL` ou `IS NOT NULL` (nunca `= NULL`).
3. **Percentual.** `desconto * 100.0 / subtotal`. O `100.0` (com ponto decimal) evita que a divisão perca as casas.
4. **Divisão por zero.** `NULLIF(a, b)` devolve nulo se `a` for igual a `b`. Com `NULLIF(subtotal, 0)`, um subtotal zero dá nulo em vez de erro. Teste: `SELECT 10 / NULLIF(0, 0);` mostra nulo.
5. **Uma casa.** `ROUND(..., 1)`.
6. **Nome da coluna e ordem.** `AS percentual` e `ORDER BY id`.

### Monte a consulta

Troque cada `___` e comente cada linha:

```sql
SELECT id, subtotal, desconto,
       ROUND(desconto * 100.0 / ___, 1) AS percentual
FROM ___
WHERE ___
ORDER BY ___;
```

**Confira:** 21 pedidos; o primeiro é o `7`, subtotal `200.60`, desconto `20.06`, percentual `10.0`.

### Agora a view

Logo depois da consulta, guarde-a com o nome `vw_desconto_pedido`:

```sql
CREATE OR REPLACE VIEW vw_desconto_pedido AS
___;   -- a consulta 10, sem o ponto e vírgula do fim

SELECT * FROM vw_desconto_pedido;
```

**Confira:** a view mostra as mesmas linhas da consulta 10.
