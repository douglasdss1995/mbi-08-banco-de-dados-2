# Projeto 3 — Loja virtual

Estrutura comum das entregas (GitHub, tags, notas): [00-estrutura-das-entregas.md](00-estrutura-das-entregas.md).
Projetos de referência já detalhados: [01-biblioteca.md](01-biblioteca.md) e [02-clinica-medica.md](02-clinica-medica.md).

## Cenário

Uma loja online vende **produtos de informática e acessórios** (periféricos, cabos, componentes, gadgets). Os clientes montam
o pedido, usam **cupons de desconto**, pagam e recebem em casa. A loja quer controlar **preço, estoque, pedidos, pagamentos
e frete**, e saber o que vende mais. Todos os dados do projeto são **fictícios**.

## Solicitação do usuário

**Solicitante:** Rafael, dono de uma loja online de informática com dois funcionários. Leia o relato como se ele tivesse
chamado você para fazer o sistema. O que ele não explicou, você pergunta ao professor (ele faz o papel do Rafael). A
modelagem é sua.

### O relato do Rafael

> Vendo periféricos, cabos, componentes e gadgets pela internet. Hoje a loja roda numa plataforma pronta, mas o estoque
> e os relatórios eu faço em planilha, e não bate nunca.
>
> **Meu dia começa** vendo os pedidos que entraram à noite e os que estão aguardando pagamento. Depois confiro o
> estoque do que mais vende e separo os pedidos pagos para enviar.
>
> **Cadastro de produto:** cada um tem um código próprio (SKU, *Stock Keeping Unit*), nome, categoria e preço. O preço
> muda toda hora, e o pedido antigo precisa continuar com o valor da época, senão meu relatório de vendas muda sozinho.
> Alguns produtos têm características diferentes (um teclado tem layout e conexão, uma memória RAM tem capacidade e
> frequência).
>
> **Estoque** nunca pode ficar negativo. Quando o pedido fecha, baixa. Se cancelar, volta.
>
> **Pedido:** um cliente, vários itens. O cliente tem vários endereços e eu preciso guardar o endereço que ele usou
> naquele pedido, mesmo que ele mude depois. O frete depende do estado de destino, e **pedido de R$ 300 ou mais, já
> com desconto, tem frete grátis**.
>
> **Cupom:** pode ser percentual ou valor fixo, tem validade, limite de usos, valor mínimo e cada cliente usa uma vez.
>
> **Pagamento:** pix, cartão ou boleto. Pedido não pago em 48 horas eu cancelo e devolvo o estoque. Só cancelo pedido que
> ainda não foi enviado.
>
> **Avaliação:** o cliente dá nota de 1 a 5, mas só se comprou o produto, e uma vez por produto.

### Minhas dificuldades hoje

1. **Estoque errado**: vendo o que não tenho, ou deixo de vender o que tenho.
2. Preciso saber **o que vende mais** (por produto e por categoria) e quanto faturei no mês.
3. **Pedidos parados** aguardando pagamento: quero que o sistema avise o cliente por e-mail e WhatsApp antes de vencer
   as 48 horas, e que eu saiba quem já foi avisado.
4. Não consigo ver **quais cupons** geraram mais venda.
5. Erro o total do pedido quando misturo cupom e frete.

### O que quero ver quando abrir o sistema

- Pedidos **aguardando pagamento** e há quanto tempo.
- Produtos com **estoque baixo**.
- **Mais vendidos** do mês e faturamento por categoria.
- O **total de cada pedido** (itens, desconto, frete).
- Uso de cada **cupom** (quantos usos faltam).

### O que guardo hoje

| Onde | O que tem |
|---|---|
| Planilha de produtos | SKU, nome, categoria, preço, quantidade |
| Plataforma de vendas | pedidos, clientes e endereços (só consigo exportar) |
| Planilha de cupons | código, tipo, valor, validade, usos |
| Planilha de frete | estado, valor |

### Perguntas para fazer ao Rafael

- O preço de um produto pode mudar com o pedido ainda no carrinho? Vale o preço de quando?
- O cliente pode cancelar um item só, ou o pedido inteiro?
- Existe devolução de produto? Entra no escopo?
- Mesmo cupom pode valer para categorias específicas?

> O envio real de e-mail e WhatsApp é feito por outro sistema. **O banco de dados guarda o que precisa ser avisado e o que
> já foi avisado.**

## Regras de negócio

| Regra | Valor |
|---|---|
| Produto | Tem SKU único, categoria e preço. O **preço muda com o tempo** e o pedido antigo deve continuar com o valor da época |
| Estoque | Nunca fica negativo. A baixa acontece quando o pedido é fechado e o estoque volta se o pedido for cancelado |
| Pedido | Um cliente, vários itens. Status: carrinho, aguardando pagamento, pago, enviado, entregue, cancelado |
| Endereço de entrega | O cliente tem vários endereços. O pedido preserva o endereço usado, mesmo que o cliente o altere depois |
| Cupom | Percentual ou valor fixo, com validade, **limite de usos**, valor mínimo do pedido e um uso por cliente |
| Frete | Por UF de destino. Pedido de R$ 300,00 ou mais (já com desconto) tem frete grátis |
| Pagamento | Pix, cartão ou boleto. Pedido não pago em **48 horas** é cancelado e devolve o estoque, pela procedure `cancelar_pedidos_vencidos()`, **chamada à mão** (o banco não roda nada sozinho; D-24) |
| Cancelamento | Só antes de o pedido ser enviado |
| Avaliação | Nota de 1 a 5, **só de quem comprou** o produto, uma por cliente e produto |
| Total do pedido | Soma dos itens, menos o desconto do cupom, mais o frete |

## Modelo mínimo (a decidir pelo grupo; pelo menos 8 tabelas)

Categoria, produto, preço do produto (com vigência), movimento de estoque, cliente, endereço, cupom, pedido, item do pedido,
pagamento, frete por UF, avaliação. O grupo decide e **justifica** o desenho.

**Pontos que exigem decisão** (a prova cobra a justificativa):

1. Preço: uma coluna no produto, uma tabela de histórico com vigência, ou o valor gravado no item do pedido? Qual combinação?
2. Estoque: uma coluna `estoque` no produto ou uma tabela de movimentos (entradas e saídas) com saldo calculado?
3. Endereço de entrega: o pedido aponta para o endereço do cliente ou guarda uma cópia?
4. Total do pedido e desconto do cupom: guardar o valor calculado ou calcular sempre que consultar? Onde fica registrado o cupom usado?
5. Carrinho: é um pedido com status `carrinho` ou uma tabela à parte?
6. Avaliação: como o banco garante uma avaliação por cliente e produto? E que só quem comprou avalia?

## Dados de apoio

- Coluna `especificacoes` (`JSONB`) em produto: marca, voltagem, cor, garantia em meses, dimensões e outros campos que variam
  conforme a categoria (um teclado e uma memória RAM não têm os mesmos atributos).
- Número do pedido no formato `PD-2026-000123`, gerado com `LPAD`.

## Entrega 1 — Prova 1 (aula 12): modelo, DDL, carga e transações

Tag: `prova-1`. As transações são dadas na aula 11, um dia antes: a entrega é pequena e guiada pelo exercício do dia.

| # | Item | Arquivo | O que entregar |
|---|---|---|---|
| 1 | Modelo | `diagrama/` | Diagrama no ERD Concepts (conceitual e lógico) com cardinalidades, e a imagem exportada |
| 2 | Estrutura | `sql/01_ddl.sql` | Schema `loja`, 8 ou mais tabelas, `PK`, `FK`, `UNIQUE`, `CHECK` e `DEFAULT` para as regras que o banco consegue garantir (estoque não negativo, nota de 1 a 5, avaliação única por cliente e produto) |
| 3 | Normalização | `README.md` | Justificar até a 3FN e dizer uma desnormalização feita de propósito, se houver |
| 4 | Carga | `sql/02_carga.sql` | 30 produtos em 5 categorias (alguns com mais de um preço ao longo do tempo), 40 clientes com 60 endereços, 8 cupons (válido, vencido, esgotado), 120 pedidos em todos os status, com itens e pagamentos. Dados que **exercitam as regras** (produto com 1 unidade em estoque, pedido aguardando pagamento há mais de 48 horas, cupom no último uso) |
| 5 | Transações | `sql/03_transacoes.sql` | Fechamento do pedido como transação (inserir o pedido e os itens com o preço do momento, baixar o estoque, tudo ou nada), com `ROLLBACK` quando faltar estoque |
| 6 | Concorrência | `sql/03_transacoes.sql` + `evidencias/` | **Duas sessões comprando a última unidade do mesmo produto**: mostrar o problema (estoque negativo ou venda dupla), a solução (bloqueio de linha ou isolamento) e explicar por quê |
| 7 | Decisões | `README.md` | As respostas dos 6 pontos de decisão acima, por que a transação protege o que protege, divisão do trabalho e uso de IA |

Dado na aula: modelagem (9), análise de bancos (10), transações e ACID (11), DDL e normalização (revisão, aulas 2 e 3).

## Entrega 2 — Prova 2 (aula 16): funções SQL, subconsultas/CTE, `JSONB`, window functions e views

Tag: `prova-2`.

| # | Item | Arquivo | O que entregar |
|---|---|---|---|
| 1 | Funções SQL | `sql/04_consultas.sql` | 10 consultas, entre elas: número do pedido com `LPAD`, nome do cliente com `INITCAP` e `TRIM`, CPF fictício mascarado (`SUBSTRING`, `REPLACE`), prazo de pagamento (`data + intervalo` de 48 horas), tempo entre pedido e entrega (`AGE`), pedidos por mês (`DATE_TRUNC`), dia da semana com mais vendas (`EXTRACT` ou `TO_CHAR`), ticket médio (`ROUND`), faixa do pedido (`CASE`: pequeno, médio, grande), `COALESCE` para "sem cupom" |
| 2 | Subconsultas e CTE | `sql/04_consultas.sql` | 3 ou mais: produtos nunca vendidos, clientes com pedidos acima do ticket médio, faturamento por categoria feito com CTE em etapas |
| 3 | `JSONB` | `sql/04_consultas.sql` | 3 consultas sobre `especificacoes` (produtos com garantia acima de 12 meses, produtos de uma voltagem, listar as marcas) |
| 4 | Window functions | `sql/05_janelas_views.sql` | 2 consultas: produtos mais vendidos por categoria (`RANK`) e faturamento acumulado por mês |
| 5 | Views | `sql/05_janelas_views.sql` | `vw_pedidos_aguardando_pagamento` e uma view materializada com faturamento mensal por categoria, com atualização |
| 6 | Decisões | `README.md` | Decisões, o que a IA errou, divisão do trabalho |

Dado na aula: funções SQL (13), subconsultas, CTE e `JSONB` (14), window functions e views (15).

## Entrega 3 — Prova 3 (aula 21): índice, funções, procedures e triggers

Tag: `prova-3`. Com o bloco de `PL/pgSQL` em três dias (aulas 18 a 20, com 40 min de projeto por dia), a entrega pede
**mais rotinas e testadas**, e a parte de índice segue enxuta.

| # | Item | Arquivo | O que entregar |
|---|---|---|---|
| 1 | Índice | `sql/06_indices.sql` + `evidencias/` | Carga em volume (100 mil pedidos ou mais, com `generate_series`), **1 consulta lenta** (pedidos de um cliente em um período), `EXPLAIN` antes e depois do índice e explicação |
| 2 | Funções | `sql/07_funcoes.sql` | 3 ou mais: `calcular_total(pedido)` (itens, cupom e frete), `calcular_frete(uf, valor)` e `cupom_valido(cupom, cliente, valor)` (validade, usos, valor mínimo, retornando o motivo). Cada uma com chamada de teste e resultado em `evidencias/` |
| 3 | Procedures | `sql/08_procedures.sql` | 3, mais `cancelar_pedidos_vencidos()` (cancela os pedidos não pagos há mais de 48 horas e devolve o estoque, chamada à mão): `fechar_pedido(pedido)` (confere o estoque, aplica o cupom, grava o total e baixa o estoque), `registrar_pagamento(pedido, forma, valor)` (muda o status para `pago`) e `cancelar_pedido(pedido)` (só antes do envio). Erros com `RAISE EXCEPTION` e mensagens claras, cada uma com um teste que dá certo e um que falha |
| 4 | Triggers | `sql/09_triggers.sql` | 2: **auditoria** das mudanças de status do pedido (quem, quando, antes e depois) e **regra de negócio** (ao cancelar o pedido, os itens voltam ao estoque), com um teste de cada |
| 5 | Decisões | `README.md` | Onde cada regra ficou (função, procedure, trigger ou `CHECK`) e por quê, divisão do trabalho, uso de IA |

Dado na aula: índices e `generate_series` (17), funções (18), procedures (19), triggers (20).

## Entrega final — Prova 4 (aulas 23 e 24): apresentação

Tag: `final`.

- **Demonstração (6 min):** um cenário de ponta a ponta: o cliente monta o pedido com um cupom, o sistema recusa a compra
  acima do estoque, o pagamento é registrado, um pedido é cancelado e o estoque volta, e o relatório mostra o faturamento
  por categoria. Executado ao vivo por uma procedure.
- **Desenvolvimento do projeto (4 min):** linha do tempo, decisões difíceis, dificuldades, o que a IA errou e o que o grupo aprendeu.
- **Entrega:** repositório com `instalar.sql` que recria o banco do zero e `README.md` final.

## Rubrica (parte do grupo, 10 pontos por prova)

| Prova | Item | Pontos |
|---|---|---|
| 1 | Modelo e justificativas (itens 1, 3 e 7) | 3,0 |
| 1 | DDL com regras no banco (item 2) | 2,5 |
| 1 | Carga que exercita as regras (item 4) | 1,5 |
| 1 | Transação e concorrência, com explicação (itens 5 e 6) | 3,0 |
| 2 | Funções SQL (item 1) | 2,5 |
| 2 | Subconsultas e CTE (item 2) | 2,0 |
| 2 | `JSONB` (item 3) | 1,0 |
| 2 | Window functions e views (itens 4 e 5) | 3,0 |
| 2 | Decisões e uso de IA (item 6) | 1,5 |
| 3 | Índice com `EXPLAIN` e análise (item 1) | 2,0 |
| 3 | Funções (item 2) | 2,0 |
| 3 | Procedures (item 3) | 2,0 |
| 3 | Triggers (item 4) | 2,5 |
| 3 | Decisões e uso de IA (item 5) | 1,5 |
| 4 | Demonstração: cenário de ponta a ponta, regras de negócio funcionando ao vivo | 4,0 |
| 4 | Desenvolvimento do projeto: linha do tempo, decisões e dificuldades | 2,5 |
| 4 | Uso de IA: o que a IA errou e o que o grupo corrigiu | 1,5 |
| 4 | Entrega: `instalar.sql` que recria o banco do zero, `README.md` e divisão do trabalho | 2,0 |

Penalidade: entrega que não roda do zero, sem `README.md` ou sem divisão do trabalho perde até 2 pontos.
Na prova 4 não há penalidade à parte: o critério «Entrega» já cobre `instalar.sql`, `README.md` e divisão do trabalho. As perguntas do professor entram na parte individual (40%).
A nota do aluno é 60% desta parte (grupo) e 40% individual (20% a parte apresentada e 20% a pergunta individual, D-36).

## Diferenças em relação à biblioteca e à clínica

- O ponto forte é o **estoque sob concorrência**: a última unidade vendida duas vezes (prova 1) e a baixa e a devolução do
  estoque nas rotinas e no trigger (prova 3).
- O **preço e o endereço mudam com o tempo**: o pedido precisa guardar o que valia na hora da compra.
- O **cupom** concentra várias regras de validação, bom para a função `cupom_valido`.
- O `JSONB` guarda atributos que variam por categoria de produto.
