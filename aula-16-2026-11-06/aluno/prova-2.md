	# Prova 2 — Loja Virtual

Banco de Dados 2 · Turma MBI-08 · **sexta-feira, 06/11/2026**

SQL: *Structured Query Language*.

| | |
|---|---|
| **Como fazer** | Em dupla, no banco da Loja Virtual |
| **Entrega** | Cada aluno entrega um `.zip` com o arquivo `prova-2.sql` e **um print do resultado de cada questão** (10 imagens) |
| **Nome do `.zip`** | `Nome completo - 2.zip` (exemplo: `Ana Souza - 2.zip`) |
| **Prazo** | Até o fim da aula de 06/11/2026, na atividade «Prova 2» do Classroom |
| **Nota** | 0 a 10: cada questão vale 1 ponto |

## O que fazer

1. Abra o banco da Loja Virtual. Se precisar, rode de novo, nesta ordem: `01_ddl.sql`, `02_carga.sql`, `10_expansao_ddl.sql` e `11_expansao_carga.sql`.
2. Crie o arquivo `prova-2.sql`. Na primeira linha, escreva os nomes da dupla em um comentário.
3. Para cada questão, escreva um comentário com o número e a pergunta, e depois a consulta.
4. Rode a consulta e compare com o «Confira».
5. Tire um **print do resultado de cada questão** logo depois de rodá-la e salve com o nome `questao-01.png`, `questao-02.png`, até `questao-10.png`.
6. No fim, rode o arquivo inteiro do zero, coloque o `prova-2.sql` e os 10 prints no mesmo `.zip` e entregue.

## Regras

- Consulta e IA (inteligência artificial) liberadas.
- Sem `LIMIT`: cada pergunta é sobre todas as linhas.
- Questão que dá erro ou não bate com o «Confira» vale 0. Certa, com um detalhe errado (coluna ou ordem), vale 0,5.
- O arquivo inteiro precisa rodar sem erro.

## Os prints

- **Um print por questão**, com o nome do arquivo `questao-NN.png` (`NN` com dois dígitos: `questao-01.png`, `questao-10.png`). Pode ser `.jpg`.
- O print mostra **o resultado da consulta** na tela do cliente de banco de dados, com as colunas e as primeiras linhas.
- **O print precisa ser legível:** tire só a área do resultado, sem cortar as colunas, e confira ao abrir a imagem se dá para ler os nomes e os valores. Foto da tela do celular não vale.
- Na questão 10, o print é da consulta feita na view.
- Todas as imagens ficam no mesmo `.zip` do `prova-2.sql`, sem pastas dentro.

## Questão 1 · Rastreio das remessas

A loja quer mandar ao cliente o rastreio da entrega, sem mostrar o código inteiro.

Cada remessa tem uma transportadora, um código de rastreio e um prazo previsto. Mostre uma linha por remessa, escondendo o começo do código para o cliente não ver o código completo.

| O que mostrar | Como |
|---|---|
| Transportadora | O nome em maiúsculas |
| Rastreio | `*****` seguido dos 5 últimos caracteres do código |
| Prazo | O prazo previsto no formato `DD/MM/AAAA` |

Ordem: do prazo mais antigo ao mais novo. **Confira:** 60 linhas. A primeira é `TRANSEXPRESS`, `*****007LJ`.

Exemplo de como a saída deve ficar. Os dados são só um exemplo da estrutura (colunas e formato); o seu resultado pode ter outros valores, e as datas mudam conforme o dia em que você carregou a base:

| transportadora | rastreio | prazo |
|---|---|---|
| TRANSEXPRESS | *****007LJ | 03/08/2026 |
| TRANSEXPRESS | *****008LJ | 05/08/2026 |
| LOGMAIS | *****009LJ | 07/08/2026 |


## Questão 2 · Tempo de casa da equipe

O RH (Recursos Humanos) quer saber há quanto tempo cada pessoa está na empresa.

Os funcionários têm uma data de admissão e um cargo, e alguns já foram desligados. Mostre todos, ativos e desligados, com o tempo de casa contado até a data de hoje.

| O que mostrar | Como |
|---|---|
| Nome | O nome do funcionário |
| Cargo | O nome do cargo |
| Tempo de casa | Da admissão até hoje, em anos, meses e dias |
| Situação | `ativo` ou `desligado` |

Ordem: do mais antigo na empresa ao mais novo. **Confira:** 8 linhas. A primeira é `Ana Teixeira`; só `Elisa Prado` está `desligado`.

Exemplo de como a saída deve ficar. Os dados são só um exemplo da estrutura (colunas e formato); o seu resultado pode ter outros valores, e as datas mudam conforme o dia em que você carregou a base (o tempo de casa sai no formato do banco, como `3 years 9 mons 5 days`):

| nome | cargo | tempo_de_casa | situacao |
|---|---|---|---|
| Ana Teixeira | Gerente de vendas | 3 years 9 mons 5 days | ativo |
| Bruno Carvalho | Vendedor sênior | 3 years 4 mons 21 days | ativo |
| Fábio Rocha | Estoquista | 3 years 2 mons 5 days | ativo |


## Questão 3 · Contas a pagar por situação

O financeiro quer ver o que já pagou e o que ainda deve.

Cada conta a pagar tem um vencimento e, se já foi paga, uma data de pagamento. Classifique cada conta em uma das três situações e mostre uma linha por situação, com a quantidade e o valor somado.

| O que mostrar | Como |
|---|---|
| Situação | `paga` (tem data de pagamento), `vencida` (não paga e já venceu) ou `a vencer` |
| Contas | Quantas contas em cada situação |
| Total | A soma dos valores |

Ordem: do maior total para o menor. **Confira:** `paga` e `a vencer` aparecem sempre; `vencida` só aparece se houver conta não paga e já vencida. A quantidade de contas de cada situação muda conforme o dia em que a base foi carregada.

Exemplo de como a saída deve ficar. Os dados são só um exemplo da estrutura (colunas e formato); o seu resultado pode ter outros valores (aqui não havia conta vencida):

| situacao | contas | total |
|---|---|---|
| paga | 14 | 162378.80 |
| a vencer | 3 | 45569.40 |


## Questão 4 · Produtos nunca vendidos

A loja quer saber quais produtos ainda não saíram. Um produto foi vendido se aparece em algum pedido que não é carrinho.

Os produtos estão em `produto`, e os itens vendidos em `item_pedido`, ligados ao `pedido`. Mostre só os produtos que não aparecem em nenhum pedido que não seja carrinho.

| O que mostrar | Como |
|---|---|
| Nome | O nome do produto |

Ordem: alfabética. **Confira:** 18 linhas. A primeira é `Adaptador VGA Max`.

Exemplo de como a saída deve ficar. Os dados são só um exemplo da estrutura (colunas e formato); o seu resultado pode ter outros valores:

| nome |
|---|
| Adaptador VGA Max |
| Cabo USB-C Lite |
| Cabo de rede Plus |


## Questão 5 · Margem de cada produto vendido

O dono quer saber quanto do preço de cada produto vendido é lucro.

Cada produto vendido tem um preço de venda, que pode variar de pedido para pedido, e pode ter mais de um fornecedor, cada um com o seu custo. Mostre só os produtos que foram vendidos, comparando o preço médio de venda com o menor custo.

| O que mostrar | Como |
|---|---|
| Produto | O nome |
| Preço médio | A média do preço cobrado nos pedidos pagos, enviados e entregues, com 2 casas |
| Custo | O menor custo entre os fornecedores do produto |
| Margem | `(preço médio - custo) / preço médio * 100`, com 1 casa |

Ordem: da maior margem para a menor. **Confira:** 11 linhas. A primeira é `Hub USB Pro`, com margem `43.4`.

Exemplo de como a saída deve ficar. Os dados são só um exemplo da estrutura (colunas e formato); o seu resultado pode ter outros valores:

| produto | preco_medio | custo | margem_pct |
|---|---|---|---|
| Hub USB Pro | 66.67 | 37.74 | 43.4 |
| Placa-mãe Pro | 595.97 | 338.94 | 43.1 |
| HD externo Pro | 95.45 | 54.54 | 42.9 |


## Questão 6 · Comissões acima da média

O gerente quer ver as comissões maiores que a comissão média.

Cada comissão é de um vendedor, em um pedido. Calcule a comissão média de todas as comissões e mostre só as que ficaram acima dela.

| O que mostrar | Como |
|---|---|
| Vendedor | O nome do funcionário |
| Pedido | O número (`id`) do pedido |
| Valor | O valor da comissão |

Ordem: da maior comissão para a menor. **Confira:** poucas linhas (3 ou 4), e a primeira é de `Bruno Carvalho`, a maior comissão. Os valores e a quantidade de linhas mudam conforme o dia em que a base foi carregada.

Exemplo de como a saída deve ficar. Os dados são só um exemplo da estrutura (colunas e formato); o seu resultado pode ter outros valores:

| vendedor | pedido_id | valor |
|---|---|---|
| Bruno Carvalho | 20 | 40.30 |
| Elisa Prado | 56 | 25.20 |
| Diego Farias | 10 | 17.47 |


## Questão 7 · O fornecedor mais barato de cada produto

O comprador quer saber de quem comprar cada produto pelo menor custo.

Um produto pode ser vendido por vários fornecedores, cada um com um custo. Para cada produto, mostre só o fornecedor de menor custo; se houver empate, mostre os empatados.

| O que mostrar | Como |
|---|---|
| Produto | O nome do produto |
| Fornecedor | O nome do fornecedor mais barato para esse produto |
| Custo | O custo desse fornecedor |

Use `RANK`. Ordem: alfabética pelo produto. **Confira:** 30 linhas. A primeira é `Adaptador VGA Max`, `Alfa Distribuidora`, `15.54`.

Exemplo de como a saída deve ficar. Os dados são só um exemplo da estrutura (colunas e formato); o seu resultado pode ter outros valores:

| produto | fornecedor | custo_unitario |
|---|---|---|
| Adaptador VGA Max | Alfa Distribuidora | 15.54 |
| Cabo HDMI Plus | Delta Tech | 25.14 |
| Cabo USB-C Lite | Ômega Componentes | 47.34 |


## Questão 8 · Extrato de pontos

O programa de fidelidade quer mostrar ao cliente o saldo de pontos depois de cada movimento.

Cada movimento de pontos é um crédito ou um resgate de um cliente. Mostre todos os movimentos, e em cada linha o saldo que o cliente tinha depois dele, somando os movimentos dele do primeiro até esse.

| O que mostrar | Como |
|---|---|
| Cliente | O `cliente_id` |
| Data | Quando o movimento aconteceu |
| Tipo | `credito` ou `resgate` |
| Pontos | Os pontos do movimento (o resgate já vem negativo) |
| Saldo | A soma dos pontos do cliente até esse movimento |

Ordem: por cliente e pela data. **Confira:** 92 linhas. O cliente 1 termina com saldo `268`; o cliente 25 termina com `240`, depois de um resgate.

Exemplo de como a saída deve ficar. Os dados são só um exemplo da estrutura (colunas e formato); o seu resultado pode ter outros valores, e as datas mudam conforme o dia em que você carregou a base:

| cliente_id | criado_em | tipo | pontos | saldo |
|---|---|---|---|---|
| 1 | 2026-08-27 05:40:00 | credito | 129 | 129 |
| 1 | 2026-09-27 21:40:00 | credito | 139 | 268 |
| 2 | 2026-09-28 16:40:00 | credito | 49 | 49 |


## Questão 9 · Recebido por mês e acumulado

O financeiro quer ver quanto recebeu em cada mês e quanto já somou.

As parcelas a receber têm uma data de recebimento quando já foram pagas. Some o que entrou em cada mês e, ao lado, mostre o total recebido desde o primeiro mês até aquele.

| O que mostrar | Como |
|---|---|
| Mês | O mês do recebimento |
| Recebido | A soma das parcelas recebidas no mês |
| Acumulado | A soma de todos os meses até esse |

Só as parcelas já recebidas. Ordem: do mês mais antigo ao mais novo. **Confira:** o acumulado da última linha é `57059.79`, o total recebido.

Exemplo de como a saída deve ficar. Os dados são só um exemplo da estrutura (colunas e formato); o seu resultado pode ter outros valores, e as datas mudam conforme o dia em que você carregou a base (os meses e os valores de cada mês mudam; o total não):

| mes | recebido | acumulado |
|---|---|---|
| 2026-07-01 | 1417.20 | 1417.20 |
| 2026-08-01 | 10581.60 | 11998.80 |
| 2026-09-01 | 15244.36 | 27243.16 |


## Questão 10 · Compras por fornecedor em uma view

O comprador quer um resumo pronto das compras, sem refazer a conta toda vez.

Uma view guarda uma consulta com um nome, e você a usa depois como se fosse uma tabela. Aqui ela vai resumir, por fornecedor, as compras que já chegaram.

Crie a view `vw_compras_por_fornecedor`, só com as compras **recebidas**:

| O que mostrar | Como |
|---|---|
| Fornecedor | O nome |
| Compras | Quantas compras recebidas |
| Unidades | Quantas unidades chegaram |
| Custo total | Quantidade vezes custo, somado |

Depois, consulte a view, do maior custo total para o menor. **Confira:** 5 linhas. A primeira é `Gama Atacado`, com `78492.60`.

Exemplo de como a saída deve ficar. Os dados são só um exemplo da estrutura (colunas e formato); o seu resultado pode ter outros valores:

| fornecedor | compras | unidades | custo_total |
|---|---|---|---|
| Gama Atacado | 2 | 290 | 78492.60 |
| Ômega Componentes | 2 | 310 | 47777.40 |
| Beta Importadora | 2 | 330 | 40708.20 |

