# Validação do banco — Loja virtual

Banco de Dados 2

Você vai testar se o **banco de dados do seu projeto** consegue **guardar e devolver** o que o cliente do projeto precisa. O pedido
abaixo usa o cenário do seu projeto e traz dados de teste.

Ninguém aqui diz **como** o seu banco deve ser (nomes de tabelas e de colunas são seus). O pedido diz **o que entra** e **o que
tem que sair**. Se a sua consulta devolve o que está na tabela «O que sai», a sua estrutura está servindo. Se não devolve, a
estrutura tem um problema, e achar esse problema é o objetivo.

Siglas: **DML** (*Data Manipulation Language*, linguagem de manipulação de dados: `INSERT`, `UPDATE`, `DELETE`), **FK** (*Foreign
Key*, chave estrangeira), **PK** (*Primary Key*, chave primária).

## Como fazer

1. Use um **banco vazio**, só com a sua estrutura (as tabelas, sem nenhuma linha). Se o seu banco já tem dados de teste,
   crie um banco novo e rode só o seu script de estrutura. Os resultados abaixo só valem para os dados deste pedido.
2. Execute as **5 entradas** abaixo, **na ordem**. Escreva os comandos `INSERT`, `UPDATE` e `DELETE` no arquivo
   `entradas.sql`.
3. Escreva **uma consulta para cada pergunta** (C1 a C16) no arquivo `consultas.sql`. A consulta é sua.
4. Compare o que a sua consulta devolve com a coluna «O que sai».
5. Faça os 3 testes de recusa (R1 a R3).
6. Se alguma informação do pedido **não tem lugar** na sua estrutura, ou alguma consulta não consegue responder, **corrija a
   estrutura** (com `ALTER TABLE` ou refazendo a tabela), rode tudo de novo e anote o que mudou no arquivo `achados.md`.

**Como conferir:** os nomes das colunas e a ordem delas não importam. A ordem das linhas só importa quando o enunciado pedir
ordenação. Valores de dinheiro: `210` e `210,00` são iguais. Onde a resposta é «0», um campo vazio também vale.

**Datas:** as datas são dadas em relação a **hoje** (por exemplo, «10 dias atrás» ou «daqui a 2 dias»). Use a data de hoje do seu banco (`CURRENT_DATE`) para calcular, assim o resultado é o mesmo em qualquer dia.

## O que entra

### Entrada 1 — Cadastros

**Categorias:** Periféricos, Componentes, Cabos, Gadgets (esta ainda sem produtos).

**Produtos** (cada um com código SKU próprio, categoria, estoque inicial e preço)

| SKU | Produto | Categoria | Estoque inicial | Preço (desde 60 dias atrás) |
|---|---|---|---|---|
| TEC-001 | Teclado Mecânico | Periféricos | 20 | R$ 250,00 |
| MOU-001 | Mouse Sem Fio | Periféricos | 30 | R$ 80,00 |
| RAM-008 | Memória RAM 8 GB | Componentes | 15 | R$ 200,00 |
| CAB-HDMI | Cabo HDMI 2 m | Cabos | 50 | R$ 30,00 |
| SSD-240 | SSD 240 GB | Componentes | 10 | R$ 220,00 |
| CAM-HD | Webcam HD | Periféricos | **0** (esgotada) | R$ 150,00 |

**Clientes** (o CPF é fictício)

| Cliente | E-mail | CPF | Endereço(s) |
|---|---|---|---|
| Marcos Dias | marcos.dias@loja.example | 11111111101 | Rua das Flores, 100, São Paulo/SP, CEP 01000000; e Avenida Central, 500, Campinas/SP, CEP 13000000 |
| Luana Reis | luana.reis@loja.example | 11111111102 | Rua do Mar, 20, Rio de Janeiro/RJ, CEP 20000000 |
| Pedro Alves | pedro.alves@loja.example | 11111111103 | Rua da Serra, 35, Belo Horizonte/MG, CEP 30000000 |
| Sara Lima | sara.lima@loja.example | 11111111104 | Rua Nova, 7, São Paulo/SP, CEP 01100000 |
| Tiago Neves | tiago.neves@loja.example | 11111111105 | Rua do Porto, 88, Curitiba/PR, CEP 80000000 |

**Frete por estado de destino:** SP R$ 20,00 · RJ R$ 30,00 · MG R$ 35,00 · PR R$ 40,00. **Pedido de R$ 300,00 ou mais, já com o
desconto, tem frete grátis.**

**Cupons**

- PROMO10: 10% de desconto, válido até daqui a 30 dias, no máximo **2 usos**, pedido mínimo de R$ 100,00.
- FIXO20: R$ 20,00 de desconto, **vencido** (venceu há 30 dias), no máximo 5 usos.

### Entrada 2 — Pedidos antigos, com itens e pagamento

O pedido guarda o endereço usado, o preço de cada item **da época**, o subtotal, o desconto, o frete e o total.

| Pedido | Cliente | Quando | Situação | Itens (quantidade, preço) | Cupom | Subtotal | Desconto | Frete | Total | Pagamento |
|---|---|---|---|---|---|---|---|---|---|---|
| P1 | Marcos Dias, Rua das Flores | 30 dias atrás | entregue | 1 Teclado (R$ 250,00), 2 Mouse (R$ 80,00) | PROMO10 | 410,00 | 41,00 | 0,00 | 369,00 | pix |
| P2 | Luana Reis | 20 dias atrás | entregue | 1 SSD (R$ 220,00) | nenhum | 220,00 | 0,00 | 30,00 | 250,00 | cartão |
| P3 | Pedro Alves | 10 dias atrás | enviado | 4 Cabo HDMI (R$ 30,00), 1 RAM (R$ 200,00) | PROMO10 | 320,00 | 32,00 | 35,00 | 323,00 | boleto |

Cada pedido fechado dá **baixa no estoque**.

### Entrada 3 — Reajuste e mudança de endereço

- O **Teclado Mecânico** passa de R$ 250,00 para **R$ 280,00**, valendo desde 5 dias atrás. Pedidos antigos continuam com o preço da época.
- O Marcos Dias corrigiu o número da casa: a Rua das Flores passa de **100 para 120**. Pedidos antigos continuam com o endereço que usaram.

### Entrada 4 — Pedidos recentes e avaliações

| Pedido | Cliente | Quando | Situação | Itens (quantidade, preço) | Subtotal | Frete | Total | Pagamento |
|---|---|---|---|---|---|---|---|---|
| P4 | Marcos Dias, Rua das Flores (agora 120) | 3 dias atrás | pago | 2 RAM (R$ 200,00), 1 Mouse (R$ 80,00) | 480,00 | 0,00 | 480,00 | pix |
| P5 | Tiago Neves | 2 dias atrás | aguardando pagamento | 1 Teclado (R$ 280,00), 1 Cabo HDMI (R$ 30,00) | 310,00 | 0,00 | 310,00 | nenhum ainda |
| P6 | Luana Reis | 1 dia atrás | **cancelado** (não pago em 48 horas) | 1 SSD (R$ 220,00) | 220,00 | 30,00 | 250,00 | nenhum |
| P7 | Sara Lima | hoje | aguardando pagamento | 2 Cabo HDMI (R$ 30,00) | 60,00 | 20,00 | 80,00 | nenhum ainda |

Os pedidos P4, P5 e P7 dão baixa no estoque. O P6 deu baixa e, ao ser cancelado, **o estoque voltou**.

**Avaliações** (nota de 1 a 5): Marcos Dias deu 5 ao Teclado Mecânico («Ótimo teclado») e 4 ao Mouse Sem Fio («Bom»); Luana Reis deu 4 ao
SSD («Rápido»); Pedro Alves deu 3 à Memória RAM («Funciona»).

### Entrada 5 — Correção

O pedido **P7**, da Sara Lima, foi criado **por engano**. Apague o pedido **e tudo o que pertence a ele**, e o estoque dos cabos volta.

## O que sai

Todas as consultas valem para o banco **depois das 5 entradas**.

| # | Pergunta | O que sai |
|---|---|---|
| C1 | Quantos pedidos, produtos e clientes existem? | 6 pedidos, 6 produtos, 5 clientes |
| C2 | Quantos pedidos há em cada situação? | entregue 2 · aguardando pagamento 1 · cancelado 1 · enviado 1 · pago 1 |
| C3 | Qual o estoque atual de cada produto? | Cabo HDMI 45 · Memória RAM 12 · Mouse 27 · SSD 9 · Teclado 18 · Webcam 0 |
| C4 | Quais produtos nunca apareceram em nenhum pedido? | Webcam HD (só ela) |
| C5 | Quanto o Teclado Mecânico foi cobrado em cada pedido, e qual é o preço de hoje? | 30 dias atrás R$ 250,00 · 2 dias atrás R$ 280,00 · preço de hoje R$ 280,00 |
| C6 | Mostre cada pedido: quando, cliente, subtotal, desconto, frete e total. | 30 dias, Marcos, 410 / 41 / 0 / 369 · 20 dias, Luana, 220 / 0 / 30 / 250 · 10 dias, Pedro, 320 / 32 / 35 / 323 · 3 dias, Marcos, 480 / 0 / 0 / 480 · 2 dias, Tiago, 310 / 0 / 0 / 310 · 1 dia, Luana, 220 / 0 / 30 / 250 |
| C7 | Qual o faturamento (soma do total dos pedidos pagos, enviados e entregues)? | R$ 1.422,00 |
| C8 | Quantas unidades cada categoria vendeu (pedidos pagos, enviados e entregues)? **Toda categoria aparece.** | Cabos 4 · Componentes 4 · Periféricos 4 · Gadgets 0 |
| C9 | Ranking de produtos por unidades vendidas (mesmos pedidos), todos os produtos, empate em ordem alfabética. | Cabo HDMI 4 · Memória RAM 3 · Mouse 3 · SSD 1 · Teclado 1 · Webcam 0 |
| C10 | Quais pedidos tiveram frete grátis? | Marcos (30 dias atrás, R$ 369,00) · Marcos (3 dias atrás, R$ 480,00) · Tiago (2 dias atrás, R$ 310,00) |
| C11 | Para cada pedido do Marcos Dias: o endereço de entrega usado e o endereço dele hoje na Rua das Flores. | 30 dias atrás: entregue na Rua das Flores, 100 · 3 dias atrás: Rua das Flores, 120 · endereço hoje: Rua das Flores, 120 |
| C12 | Quantos usos válidos (de pedidos não cancelados) cada cupom teve, e qual o limite? | FIXO20 0 de 5 · PROMO10 2 de 2 |
| C13 | Quais pedidos usaram cupom? Mostre cliente, cupom e desconto. | Marcos, PROMO10, R$ 41,00 · Pedro, PROMO10, R$ 32,00 |
| C14 | Quais clientes nunca fizeram um pedido? | Sara Lima (só ela) |
| C15 | Qual a média das notas de cada produto? **Todo produto aparece.** | Teclado 5,0 · Mouse 4,0 · SSD 4,0 · Memória RAM 3,0 · Cabo HDMI sem avaliação · Webcam sem avaliação |
| C16 | Quantos pagamentos e quanto em dinheiro por forma de pagamento? | pix 2 pagamentos, R$ 849,00 · boleto 1, R$ 323,00 · cartão 1, R$ 250,00 |

## Testes de recusa

Estes três comandos **precisam dar erro**. Se o banco aceitar, falta uma regra na estrutura (se não souber como criá-la, anote como
achado). Copie a mensagem de erro de cada um no `achados.md`.

| # | Tente | O que sai |
|---|---|---|
| R1 | Criar um pedido para um cliente que não existe | Erro de chave estrangeira (FK) |
| R2 | Apagar o produto Mouse Sem Fio, que já foi vendido | Erro: o banco não deixa apagar o que ainda é usado em outra tabela |
| R3 | Dar baixa de 1 unidade na Webcam HD, que está com estoque 0 | Erro: o estoque não pode ficar negativo |

## O que entregar

Entregue **todos os arquivos abaixo pelo Google Classroom, na atividade indicada pelo professor**:

| Arquivo | Conteúdo |
|---|---|
| `entradas.sql` | Só os comandos das 5 entradas (sem o script de criação das tabelas) |
| `consultas.sql` | As 16 consultas, C1 a C16, cada uma com um comentário com o seu número |
| `resultados.md` | O resultado de cada consulta (texto copiado ou print) |
| `achados.md` | As mensagens de erro de R1 a R3 e o que não bateu: **por que não bateu** e o que você mudou na estrutura. Se tudo bateu de primeira, escreva isso |
| `uso-de-ia.md` | Se usou IA: qual e para quê. Se não usou, escreva que não usou |

## Se uma consulta não bateu

Antes de mexer na consulta, pergunte se é a **estrutura** que não deixa a resposta sair certa:

- O pedido antigo do Teclado ficou com o preço da época (C5) quando o preço mudou? Onde o preço pago ficou guardado?
- O pedido do Marcos mostra o endereço **que ele usou** (C11), mesmo depois de o endereço do cadastro mudar?
- O estoque (C3) ficou certo depois de vendas, de um pedido cancelado e de um pedido apagado? Ele é uma coluna ou é calculado?
- O desconto, o frete e o total do pedido (C6) estão guardados ou dá para calcular? O frete grátis (C10) saiu da regra de R$ 300?
- Um produto, cliente ou categoria **sem nenhum pedido** sumiu do resultado (C4, C8, C9, C14, C15)? Isso costuma ser `JOIN` no lugar de `LEFT JOIN`.
- O uso do cupom (C12) é contado nos pedidos ou guardado numa coluna? O que acontece com o cupom de um pedido cancelado?
- Faltou algum lugar para guardar uma informação do pedido?

