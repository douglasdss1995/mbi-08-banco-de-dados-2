# Validação do banco — Delivery de comida

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

**Categorias culinárias:** Pizza, Japonesa, Lanches, Doces (esta com um restaurante inativo).

**Restaurantes**

| Restaurante | Categoria | Pedido mínimo | Comissão da plataforma | Preparo estimado | Situação |
|---|---|---|---|---|---|
| Pizzaria Forno | Pizza | R$ 30,00 | 15% | 40 min | ativo |
| Sushi Kai | Japonesa | R$ 25,00 | 18% | 35 min | ativo |
| Lanches do Zé | Lanches | R$ 20,00 | 15% | 20 min | ativo |
| Café Aurora | Doces | sem mínimo | 15% | 15 min | **inativo** |

**Horários de funcionamento:** Pizzaria Forno abre na **sexta das 18:00 às 02:00** (fecha só na madrugada seguinte); Sushi Kai abre no
sábado das 12:00 às 15:00 e das 18:00 às 23:00; Lanches do Zé abre na segunda das 10:00 às 22:00.

**Cardápio e preço** (desde 60 dias atrás)

| Restaurante | Item | Preço | Situação |
|---|---|---|---|
| Pizzaria Forno | Pizza Margherita | R$ 50,00 | disponível |
| Pizzaria Forno | Pizza Calabresa | R$ 55,00 | disponível |
| Pizzaria Forno | Refrigerante 2 L | R$ 12,00 | **indisponível** |
| Sushi Kai | Combo 20 peças | R$ 90,00 | disponível |
| Sushi Kai | Temaki Salmão | R$ 28,00 | disponível |
| Lanches do Zé | X-Burger | R$ 22,00 | disponível |
| Lanches do Zé | Batata Frita | R$ 15,00 | disponível |
| Lanches do Zé | Milkshake | R$ 18,00 | disponível |

**Clientes e endereços** (a distância até o restaurante, em km, é um dado do endereço)

| Cliente | E-mail | Telefone | Endereço(s) |
|---|---|---|---|
| Rafa Gomes | rafa.gomes@delivery.example | (47) 98800-0001 | Rua A, 10, Centro, 2,0 km; e Rua B, 200, Jardim, 7,5 km |
| Sílvia Neto | silvia.neto@delivery.example | (47) 98800-0002 | Avenida Sul, 55, bairro Sul, 4,5 km |
| Tomás Braga | tomas.braga@delivery.example | sem telefone | Rua C, 3, Norte, 1,0 km |
| Úrsula Dias | ursula.dias@delivery.example | (47) 98800-0004 | Rua D, 9, Leste, 5,0 km |
| Vitor Ramos | vitor.ramos@delivery.example | (47) 98800-0005 | Rua E, 80, Oeste, 3,0 km |

**Taxa de entrega por distância:** até 3 km (inclusive), R$ 5,00; acima de 3 e até 6 km, R$ 8,00; acima de 6 km, R$ 12,00.
**Pedido de R$ 80,00 ou mais só em itens tem taxa grátis.**

**Entregadores:** Wagner Lopes (disponível), Yara Costa (offline), Zeca Moura (offline).

### Entrada 2 — Pedidos antigos

O pedido guarda o endereço usado, os preços **da época**, a taxa, o total e a **comissão do restaurante naquele dia**.

| Pedido | Cliente (endereço) | Restaurante | Quando | Situação | Itens (quantidade, preço) | Taxa | Total | Prometido para | Entregue |
|---|---|---|---|---|---|---|---|---|---|
| D1 | Rafa, Rua A, 10 | Pizzaria Forno | 20 dias atrás | entregue | 2 Margherita (R$ 50,00), 1 Calabresa (R$ 55,00) = R$ 155,00 | grátis | R$ 155,00 | 60 min | 50 min depois |
| D2 | Sílvia | Sushi Kai | 15 dias atrás | entregue | 1 Temaki (R$ 28,00) | R$ 8,00 | R$ 36,00 | 50 min | 75 min depois (**atrasado**) |
| D3 | Tomás | Lanches do Zé | 10 dias atrás | entregue | 2 X-Burger (R$ 22,00) com a observação **«sem cebola»**, 1 Batata (R$ 15,00) = R$ 59,00 | R$ 5,00 | R$ 64,00 | 40 min | 30 min depois |
| D4 | Rafa, Rua A, 10 | Sushi Kai | 8 dias atrás | **cancelado pelo cliente** depois de aceito | 1 Combo (R$ 90,00) | grátis | R$ 90,00 | 50 min | cancelado; cobrados 50% dos itens (R$ 45,00) |

**Comissão do dia:** D1 e D3, 15%; D2 e D4, 18% (a do Sushi Kai na época).

**Histórico de status** (com a hora, em minutos depois da criação do pedido): D1: criado (0), aceito (3), em preparo (5), pronto (35), a caminho (38), entregue (50).
D4: criado (0), aceito (4), cancelado (9).

**Entregas:** D1 e D2 pelo Wagner Lopes, D3 pela Yara Costa (todas concluídas).
**Pagamentos (pagos):** D1 por pix (R$ 155,00), D2 por cartão (R$ 36,00), D3 em dinheiro (R$ 64,00).
**Avaliações** (nota do restaurante, nota do entregador): D1 5 e 4 («Chegou quente»); D2 3 e 2 («Demorou»); D3 5 e 5.

### Entrada 3 — Reajuste, nova comissão e mudança de endereço

- A **Pizza Margherita** passa de R$ 50,00 para **R$ 56,00**, valendo desde 7 dias atrás.
- O **Sushi Kai** passa a cobrar **20% de comissão** (antes 18%). Os pedidos antigos continuam com a comissão da época.
- A Rafa corrigiu o número da Rua A: de **10 para 12**. Os pedidos antigos continuam com o endereço que usaram.

### Entrada 4 — Pedidos recentes

| Pedido | Cliente (endereço) | Restaurante | Quando | Situação | Itens | Taxa | Total | Comissão do dia |
|---|---|---|---|---|---|---|---|---|
| D5 | Vitor, Rua E, 3,0 km | Pizzaria Forno | 2 dias atrás | entregue (40 min depois; prometido em 60 min) | 1 Margherita (R$ 56,00), 1 Calabresa (R$ 55,00) = R$ 111,00 | grátis | R$ 111,00 | 15% |
| D6 | Rafa, Rua B, 7,5 km | Lanches do Zé | agora | a caminho (prometido em 40 min) | 1 X-Burger (R$ 22,00), 1 Milkshake (R$ 18,00) = R$ 40,00 | R$ 12,00 | R$ 52,00 | 15% |
| D7 | Sílvia | Pizzaria Forno | agora | em preparo (prometido em 60 min) | 1 Calabresa (R$ 55,00) | R$ 8,00 | R$ 63,00 | 15% |
| D8 | Tomás | Sushi Kai | agora | criado | 1 Temaki (R$ 28,00) | R$ 5,00 | R$ 33,00 | 20% |

**Entregas do D5:** primeiro foi atribuída ao **Zeca Moura**, que **desistiu**; depois a **Yara Costa** assumiu e concluiu.
**Entrega do D6:** a Yara Costa está a caminho (entrega ativa); a Yara fica «em entrega» e o Wagner Lopes «disponível».
**Pagamento do D5:** pix, R$ 111,00, pago. **Avaliação do D5:** restaurante 4, entregador 5 («Ótima»).

### Entrada 5 — Correção

O pedido **D8** (Tomás Braga, Sushi Kai) foi lançado **por engano**. Apague o pedido **e tudo o que pertence a ele**.

## O que sai

Todas as consultas valem para o banco **depois das 5 entradas**.

| # | Pergunta | O que sai |
|---|---|---|
| C1 | Quantos pedidos, restaurantes e clientes existem? | 7 pedidos, 4 restaurantes, 5 clientes |
| C2 | Quantos pedidos há em cada situação? | entregue 4 · a caminho 1 · cancelado 1 · em preparo 1 |
| C3 | Quanto a Pizza Margherita foi cobrada em cada pedido, e qual é o preço de hoje? | 20 dias atrás R$ 50,00 · 2 dias atrás R$ 56,00 · preço de hoje R$ 56,00 |
| C4 | Quais pedidos entregues chegaram **depois** do prometido? Mostre o restaurante e os minutos de atraso. | Sushi Kai, 25 minutos (só esse) |
| C5 | Liste todos os pedidos: quando, cliente, restaurante, distância, subtotal, taxa de entrega e total. | 20 dias, Rafa, Forno, 2,0 km, 155 / 0 / 155 · 15 dias, Sílvia, Sushi Kai, 4,5 km, 28 / 8 / 36 · 10 dias, Tomás, Lanches, 1,0 km, 59 / 5 / 64 · 8 dias, Rafa, Sushi Kai, 2,0 km, 90 / 0 / 90 · 2 dias, Vitor, Forno, 3,0 km, 111 / 0 / 111 · hoje, Rafa, Lanches, 7,5 km, 40 / 12 / 52 · hoje, Sílvia, Forno, 4,5 km, 55 / 8 / 63 |
| C6 | Por restaurante, nos pedidos **entregues**: itens vendidos, comissão da plataforma (com a comissão do dia de cada pedido) e repasse. **Todo restaurante aparece.** | Café Aurora 0 / 0 / 0 · Lanches do Zé 59,00 / 8,85 / 50,15 · Pizzaria Forno 266,00 / 39,90 / 226,10 · Sushi Kai 28,00 / 5,04 / 22,96 |
| C7 | Quais restaurantes não têm nenhum pedido? | Café Aurora (só ele) |
| C8 | Quais itens do cardápio estão indisponíveis? | Refrigerante 2 L, da Pizzaria Forno |
| C9 | Quais horários passam da meia-noite? | Pizzaria Forno, sexta, das 18:00 às 02:00 |
| C10 | Qual o histórico de status do pedido da Rafa na Pizzaria Forno? Mostre de qual status para qual e os minutos desde o início. | (início) → criado, 0 · criado → aceito, 3 · aceito → em preparo, 5 · em preparo → pronto, 35 · pronto → a caminho, 38 · a caminho → entregue, 50 |
| C11 | Para cada entregador: situação atual, entregas concluídas e desistências. **Todo entregador aparece.** | Wagner, disponível, 2 concluídas, 0 · Yara, em entrega, 2 concluídas, 0 · Zeca, offline, 0 concluídas, 1 desistência |
| C12 | Quais itens de pedido têm observação? | Tomás Braga, X-Burger, «sem cebola» (só esse) |
| C13 | Qual a média das notas do restaurante? **Todo restaurante aparece.** | Lanches do Zé 5,0 · Pizzaria Forno 4,5 · Sushi Kai 3,0 · Café Aurora sem avaliação |
| C14 | Quais pedidos foram cancelados? Mostre cliente, restaurante, quem cancelou e quanto foi cobrado. | Rafa Gomes, Sushi Kai, cancelado pelo cliente, R$ 45,00 |
| C15 | Para cada pedido da Rafa: o endereço usado e o endereço dela hoje na Rua A. | 20 dias atrás: Rua A 10 · 8 dias atrás: Rua A 10 · hoje: Rua B 200 · endereço de hoje da Rua A: Rua A 12 |
| C16 | Quantos pagamentos e quanto em dinheiro por forma de pagamento? | pix 2, R$ 266,00 · dinheiro 1, R$ 64,00 · cartão 1, R$ 36,00 |

## Testes de recusa

Estes três comandos **precisam dar erro**. Se o banco aceitar, falta uma regra na estrutura (se não souber como criá-la, anote como
achado). Copie a mensagem de erro de cada um no `achados.md`.

| # | Tente | O que sai |
|---|---|---|
| R1 | Criar um pedido para um cliente que não existe | Erro de chave estrangeira (FK) |
| R2 | Apagar o restaurante Pizzaria Forno, que tem pedidos | Erro: o banco não deixa apagar o que ainda é usado em outra tabela |
| R3 | Dar à Yara Costa uma segunda entrega ativa, quando ela já está a caminho com o pedido D6 | Erro: um entregador só tem uma entrega ativa por vez |

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

- O preço cobrado de um item ficou o da época (C3), mesmo depois de o cardápio mudar? E a **comissão** do pedido ficou a do dia (C6), mesmo depois de o restaurante mudar a dela?
- O pedido do Rafa mostra o endereço **que ele usou** (C15), mesmo depois de o cadastro mudar?
- Uma entrega é uma linha **à parte** do pedido (C11)? Um pedido consegue ter duas tentativas de entrega, uma que desistiu e outra concluída?
- Um horário que **passa da meia-noite** (C9) cabe no seu banco? Como você sabe que ele fecha no dia seguinte?
- A taxa, o subtotal e o total do pedido (C5) estão guardados ou dá para calcular? A taxa grátis (R$ 80 em itens) e o limite de 3 km saíram certos?
- A observação «sem cebola» (C12) tem onde ficar? Cada item do pedido consegue ter a sua?
- Cada mudança de status (C10) guarda a **hora**? Um restaurante **sem nenhum pedido** sumiu do resultado (C6, C7, C13)? Isso costuma ser `JOIN` no lugar de `LEFT JOIN`.
- Faltou algum lugar para guardar uma informação do pedido?

