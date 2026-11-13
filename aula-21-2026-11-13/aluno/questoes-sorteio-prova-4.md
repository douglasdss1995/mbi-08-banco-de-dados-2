# Questões do sorteio da prova 4

Banco de Dados 2 · Turma MBI-08

Na prova 4, o professor sorteia **1 número de 1 a 34**, e a dupla faz essa questão na mesa do professor.

| Números | Exercício | Assunto |
|---|---|---|
| 1 a 10 | Exercício 7 | Window functions e views (consultas 1 a 10) |
| 11 a 20 | Exercício 8 | Funções (funções 1 a 10) |
| 21 a 27 | Exercício 9 | Procedures (procedures 1 a 7) |
| 28 a 34 | Exercício 10 | Triggers (triggers 1 a 7) |

**Na mesa:** a dupla lê a questão, escreve a resposta no cliente de banco de dados (DBeaver ou DataGrip), roda e explica cada linha. Pode consultar **só as questões dos exercícios 7 a 10 já respondidas pela dupla**. Não vale o banco de perguntas, anotações, internet nem IA (inteligência artificial).

Este arquivo traz **só as questões**, como nos exercícios. Deixe todas respondidas: as suas respostas podem ir com você à mesa.

SQL: *Structured Query Language*. PL/pgSQL: *Procedural Language/PostgreSQL*. UF: Unidade Federativa (o estado).

## 1 · Exercício 7, consulta 1 · Os 3 clientes que mais gastaram em cada estado

**Pergunta da loja:** «Quero ver os 3 clientes que mais gastaram em cada estado, para mandar um brinde.»

**O que mostrar:**

| uf | cliente | gasto | posicao |
|---|---|---|---|
| BA | Cliente 37 | 3417.96 | 1 |
| BA | Cliente 21 | 3361.47 | 2 |
| BA | Cliente 13 | 3248.49 | 3 |
| ... | ... | ... | ... |

## 2 · Exercício 7, consulta 2 · Os 3 produtos mais vendidos de cada categoria

**Pergunta da loja:** «Quero ver os 3 produtos mais vendidos de cada categoria.»

**O que mostrar:**

| categoria | produto | unidades | posicao |
|---|---|---|---|
| Armazenamento | Gaveta HD Max | 30 | 1 |
| Armazenamento | HD externo Pro | 30 | 1 |
| Armazenamento | Pen drive Max | 30 | 1 |
| ... | ... | ... | ... |

## 3 · Exercício 7, consulta 3 · O primeiro pedido de cada cliente

**Pergunta da loja:** «Quero saber qual foi o primeiro pedido de venda de cada cliente.»

**O que mostrar:**

| nome | numero | dia |
|---|---|---|
| Cliente 01 | PD-2026-000040 | (data) |
| Cliente 02 | PD-2026-000081 | (data) |
| Cliente 03 | PD-2026-000002 | (data) |
| ... | ... | ... |

## 4 · Exercício 7, consulta 4 · Os 2 pedidos mais recentes de cada estado

**Pergunta da loja:** «Quero ver os 2 pedidos de venda mais recentes de cada estado.»

**O que mostrar:**

| uf | numero | dia | posicao |
|---|---|---|---|
| BA | PD-2026-000116 | (data) | 1 |
| BA | PD-2026-000100 | (data) | 2 |
| DF | PD-2026-000006 | (data) | 1 |
| ... | ... | ... | ... |

## 5 · Exercício 7, consulta 5 · Quanto a loja recebeu por mês, e a soma até ali

**Pergunta da loja:** «Quero ver quanto a loja recebeu em cada mês e quanto já somou desde o primeiro mês.»

**O que mostrar:**

| mes | recebido | acumulado |
|---|---|---|
| (1º mês) | (valor) | (o mesmo valor) |
| (2º mês) | (valor) | (soma dos dois) |
| ... | ... | ... |

## 6 · Exercício 7, consulta 6 · O faturamento de cada categoria, mês a mês, com o acumulado

**Pergunta da loja:** «Quero ver o faturamento de cada categoria em cada mês e quanto cada categoria já somou.»

**O que mostrar:**

| categoria | mes | faturamento | acumulado |
|---|---|---|---|
| Armazenamento | (mês) | (valor) | (soma até ali) |
| Armazenamento | (mês) | (valor) | (soma até ali) |
| ... | ... | ... | ... |

## 7 · Exercício 7, consulta 7 · Os clientes do que mais gastou ao que menos gastou, com a soma até cada um

**Pergunta da loja:** «Quero ver os clientes do que mais gastou ao que menos gastou, com a soma dos gastos até cada um.»

**O que mostrar:**

| nome | gasto | acumulado |
|---|---|---|
| Cliente 25 | 3417.96 | 3417.96 |
| Cliente 37 | 3417.96 | 6835.92 |
| Cliente 09 | 3361.47 | 10197.39 |
| ... | ... | ... |

## 8 · Exercício 7, consulta 8 · Todos os produtos em um só ranking

**Pergunta da loja:** «Quero ver todos os produtos vendidos em um só ranking, do que vendeu mais ao que vendeu menos.»

**O que mostrar:**

| produto | unidades | posicao |
|---|---|---|
| Caixa de som Lite | 60 | 1 |
| Webcam Plus | 50 | 2 |
| Placa-mãe Pro | 40 | 3 |
| ... | ... | ... |

## 9 · Exercício 7, consulta 9 · O recebido por mês, guardado (view materializada)

**Pergunta da loja:** «O relatório do recebido por mês abre devagar. Quero guardar o resultado pronto.»

**O que mostrar:**

| mes | recebido |
|---|---|
| (mês) | (valor) |
| ... | ... |

## 10 · Exercício 7, consulta 10 · Os 2 produtos que mais faturaram nas categorias fortes

**Pergunta da loja:** «Quero ver os 2 produtos que mais faturaram em cada categoria que faturou mais que a média das categorias.»

**O que mostrar:**

| categoria | produto | faturamento | posicao |
|---|---|---|---|
| Armazenamento | Pen drive Max | 7497.00 | 1 |
| ... | ... | ... | ... |

## 11 · Exercício 8, função 1 · O preço com desconto

Toda promoção da loja tem um percentual de desconto, e cada tela faz essa conta de um jeito. Preciso de uma função que receba o preço e o percentual e devolva o preço final, com os centavos. Assim todo mundo usa a mesma conta.

| Recebe | Devolve |
|---|---|
| `p_valor` (número) e `p_percentual` (número) | o valor com o desconto, em 2 casas |

**Exemplo de retorno:**

| Chamada | Retorno |
|---|---|
| `valor_com_desconto(200, 10)` | `180.00` |
| `valor_com_desconto(59.90, 15)` | `50.92` |

## 12 · Exercício 8, função 2 · O subtotal de um pedido

Quando abro um pedido, quero saber quanto custam os itens dele, antes do desconto e do frete. Faça uma função que receba o pedido e some a quantidade vezes o preço de cada item. Se o pedido não tiver item, quero ver zero.

| Recebe                      | Devolve                                           |
| --------------------------- | ------------------------------------------------- |
| `p_pedido` (o id do pedido) | a soma de `quantidade * preco_unitario` dos itens |

**Exemplo de retorno:**

| Chamada | Retorno |
|---|---|
| `subtotal_do_pedido(1)` | `1002.60` |
| `subtotal_do_pedido(999999)` | `0` (o pedido não existe: nenhum item) |

## 13 · Exercício 8, função 3 · Quanto um cliente gastou

Quero saber quanto cada cliente já gastou comigo. Conte só o que virou venda: pedido pago, enviado ou entregue. Carrinho, pedido aguardando pagamento e pedido cancelado não contam. Se o cliente nunca comprou, quero ver zero.

| Recebe                        | Devolve                                                                            |
| ----------------------------- | ---------------------------------------------------------------------------------- |
| `p_cliente` (o id do cliente) | a soma do `total` das vendas (`pago`, `enviado`, `entregue`); `0` se nunca comprou |

**Exemplo de retorno:**

| Chamada | Retorno |
|---|---|
| `gasto_do_cliente(25)` | `3417.96` |
| `gasto_do_cliente(1)` | `2693.91` |

Na consulta com todos os clientes:

| nome | gasto |
|---|---|
| Cliente 25 | 3417.96 |
| Cliente 37 | 3417.96 |
| Cliente 09 | 3361.47 |
| ... | ... |

## 14 · Exercício 8, função 4 · Os pedidos de um cliente

O cliente liga no atendimento e pergunta pelos pedidos dele. Quero uma função que receba o cliente e devolva a lista dos pedidos, com o número, a situação e o total de cada um. Mostre do mais antigo ao mais novo.

Aqui a função devolve **várias linhas**. Em vez de `RETURNS numeric`, você usa `RETURNS TABLE (...)`: uma tabela com as colunas que você listar.

| Recebe | Devolve |
|---|---|
| `p_cliente` (o id do cliente) | uma tabela com `numero`, `status` e `total` de cada pedido, do mais antigo ao mais novo |

**Exemplo de retorno** de `SELECT * FROM pedidos_do_cliente(25);` (o ano do número muda conforme o dia em que você carregou a base):

| numero | status | total |
|---|---|---|
| PD-2026-000024 | carrinho | |
| PD-2026-000064 | pago | 2018.07 |
| PD-2026-000104 | entregue | 1399.89 |

## 15 · Exercício 8, função 5 · A situação do estoque

Não quero descobrir que um produto acabou só quando o cliente reclama. Quero uma função que olhe o estoque de um produto e diga se está bom, se pede atenção ou se preciso repor. Se eu passar um produto que não existe, quero uma mensagem clara.

| Recebe | Devolve |
|---|---|
| `p_produto` (o id do produto) | `repor` (estoque abaixo do mínimo), `atenção` (abaixo de 4 vezes o mínimo) ou `ok` |

Se o produto não existe, a função para com a mensagem `Produto 999 não existe`.

**Exemplo de retorno:**

| Chamada | Retorno |
|---|---|
| `classificar_estoque(3)` | `repor` |
| `classificar_estoque(1)` | `ok` |
| `classificar_estoque(999)` | erro: `Produto 999 não existe` |

Na consulta que conta os produtos de cada situação:

| situacao | count |
|---|---|
| atenção | 5 |
| ok | 15 |
| repor | 10 |

## 16 · Exercício 8, função 6 · O desconto de um cupom

O cliente digita o código do cupom no carrinho, e eu preciso saber de quanto é o desconto. Tenho cupom de percentual e cupom de valor fixo. O desconto nunca pode passar do valor da compra.

| Recebe | Devolve |
|---|---|
| `p_codigo` (o código do cupom) e `p_subtotal` (número) | cupom `percentual`: o percentual do subtotal, em 2 casas. Cupom `fixo`: o valor do cupom, mas nunca mais que o subtotal |

Se o cupom não existe, a função para com a mensagem `Cupom XYZ não existe`.

**Exemplo de retorno:**

| Chamada | Retorno |
|---|---|
| `desconto_do_cupom('NATAL20', 200)` | `40.00` (20% de 200) |
| `desconto_do_cupom('FRETE50', 30)` | `30` (o fixo é 50, mas a compra é só 30) |
| `desconto_do_cupom('XYZ', 100)` | erro: `Cupom XYZ não existe` |

## 17 · Exercício 8, função 7 · A comissão de um pedido

Meus vendedores ganham comissão em cada venda, e o percentual depende do cargo de cada um. Quero uma função que receba o pedido e diga quanto o vendedor ganha. Pedido sem vendedor não paga comissão.

| Recebe | Devolve |
|---|---|
| `p_pedido` (o id do pedido) | o percentual do cargo do vendedor sobre (`subtotal` menos `desconto`), em 2 casas. `0` se o pedido não tem vendedor ou não tem `subtotal` |

Se o pedido não existe, a função para com a mensagem `Pedido 999 não existe`.

**Exemplo de retorno:**

| Chamada | Retorno |
|---|---|
| `comissao_do_pedido(1)` | `30.08` (3% de 1002.60) |
| `comissao_do_pedido(2)` | `0` (o pedido não tem vendedor) |
| `comissao_do_pedido(999999)` | erro: `Pedido 999999 não existe` |

## 18 · Exercício 8, função 8 · Quanto ainda dá para devolver

O cliente comprou 3 unidades de um produto e já pediu para devolver 1. Quantas ele ainda pode devolver? Quero essa conta para qualquer pedido e produto. A devolução que eu recusei não conta.

| Recebe | Devolve |
|---|---|
| `p_pedido` e `p_produto` (os dois ids) | a quantidade comprada menos a quantidade já em devolução (`solicitada` ou `concluida`; a `recusada` não conta) |

**Exemplo de retorno:**

| Chamada | Retorno |
|---|---|
| `quantidade_devolvivel(8, 6)` | `2` (comprou 3 e já pediu para devolver 1) |
| `quantidade_devolvivel(20, 6)` | `3` (nada em devolução) |
| `quantidade_devolvivel(9, 19)` | `1` |

## 19 · Exercício 8, função 9 · A devolução é permitida?

O cliente pede para devolver um pedido, e o atendente precisa responder na hora se pode ou não. Quero uma função que diga se a devolução está liberada ou, se não estiver, o motivo, com as palavras da loja.

Regras da loja: só o pedido `entregue` pode ser devolvido, e até 7 dias depois da entrega.

| Recebe | Devolve |
|---|---|
| `p_pedido` (o id do pedido) | `ok`, ou o motivo da recusa: `Pedido ainda não foi entregue` ou `Prazo de 7 dias vencido` |

Se o pedido não existe, a função para com a mensagem `Pedido 999 não existe`.

**Exemplo de retorno** da consulta que conta as respostas por status (a divisão entre `ok` e `Prazo de 7 dias vencido` muda conforme o dia em que você carregou a base):

| status | resposta | count |
|---|---|---|
| aguardando_pagamento | Pedido ainda não foi entregue | 10 |
| cancelado | Pedido ainda não foi entregue | 10 |
| carrinho | Pedido ainda não foi entregue | 10 |
| entregue | Prazo de 7 dias vencido | 37 |
| entregue | ok | 3 |
| enviado | Pedido ainda não foi entregue | 20 |
| pago | Pedido ainda não foi entregue | 30 |

## 20 · Exercício 8, função 10 · A faixa do cliente

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

**Exemplo de retorno:**

| Chamada | Retorno |
|---|---|
| `faixa_do_cliente(25)` | `ouro` |
| `faixa_do_cliente(1)` | `prata` |
| `faixa_do_cliente(999)` | erro: `Cliente 999 não existe` |

Na consulta que conta os clientes de cada faixa:

| faixa | count |
|---|---|
| bronze | 20 |
| ouro | 9 |
| prata | 11 |

## 21 · Exercício 9, procedure 1 · Dar entrada no estoque

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

## 22 · Exercício 9, procedure 2 · Mudar o preço de um produto

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

## 23 · Exercício 9, procedure 3 · Trocar o endereço de entrega

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

## 24 · Exercício 9, procedure 4 · Marcar o pedido como entregue

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

## 25 · Exercício 9, procedure 5 · Tirar um produto da vitrine

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

## 26 · Exercício 9, procedure 6 · Aplicar um cupom ao carrinho

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

## 27 · Exercício 9, procedure 7 · Cancelar os pedidos vencidos

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

## 28 · Exercício 10, trigger 1 · O histórico de e-mail do cliente

Um cliente trocou o e-mail e depois disse que não foi ele. Não tive como saber qual era o e-mail antigo nem quando mudou. Quero que toda troca de e-mail fique guardada: o antigo, o novo e o momento.

| Tabela e evento | O que faz |
|---|---|
| `AFTER UPDATE OF email ON cliente` | grava em `historico_email` o cliente, o e-mail antigo (`OLD.email`) e o novo (`NEW.email`) |

**Exemplo de retorno** do histórico depois de mudar o e-mail do cliente 1:

| cliente_id | email_antes | email_depois |
|---|---|---|
| 1 | cliente01@exemplo.test | cliente01@novo.test |

Depois de mudar só o nome, `SELECT COUNT(*) FROM historico_email;` continua `1`.

## 29 · Exercício 10, trigger 2 · O pagamento marca o pedido como pago

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

## 30 · Exercício 10, trigger 3 · Cancelar tira os pontos do cliente

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

## 31 · Exercício 10, trigger 4 · Produto fora da vitrine não entra no carrinho

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

## 32 · Exercício 10, trigger 5 · E-mail sempre em minúsculas e sem espaços

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

## 33 · Exercício 10, trigger 6 · Pedido cancelado não volta

Alguém reativou um pedido cancelado, e a loja enviou um produto que o cliente não queria mais. Quero uma regra: pedido cancelado fica cancelado. Qualquer outra mudança de status continua valendo.

| Tabela e evento | O que faz |
|---|---|
| `BEFORE UPDATE OF status ON pedido` | se o status antigo é `cancelado` e o novo é outro, recusa com `Pedido 11 está cancelado e não pode voltar para pago` |

**Exemplo de retorno** depois do teste que passa:

| id | status |
|---|---|
| 6 | entregue |

O teste recusado: `Pedido 11 está cancelado e não pode voltar para pago`.

## 34 · Exercício 10, trigger 7 · Pagamento só do valor certo

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

