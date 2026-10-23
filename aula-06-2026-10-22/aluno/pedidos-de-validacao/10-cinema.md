# Validação do banco — Cinema

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

**Gêneros:** Ação, Animação, Drama, Terror (este ainda sem filmes).

**Filmes**

| Filme | Gênero | Duração | Classificação indicativa | Idioma |
|---|---|---|---|---|
| Aventura Estelar | Ação | 120 min | 12 | Inglês |
| Pequeno Dragão | Animação | 90 min | livre | Português |
| Noite Silenciosa | Drama | 100 min | 16 | Francês |
| Sombras do Passado | Drama | 110 min | 18 | Português |

**Salas e assentos** (o assento é da sala: fileira e número)

| Sala | Tipo | Assentos |
|---|---|---|
| Sala 1 | 2D | A1, A2, A3 (**cadeirante**), B1, B2, B3 (**casal**) |
| Sala 2 | 3D | A1, A2, A3, A4 |
| Sala VIP | VIP | A1, A2, A3 |

**Preço da inteira** (por tipo de sala e tipo de dia; a **quarta-feira** é promocional; valores desde 300 dias atrás)

| Tipo de sala | Dia normal | Quarta-feira |
|---|---|---|
| 2D | R$ 30,00 | R$ 20,00 |
| 3D | R$ 40,00 | R$ 30,00 |
| VIP | R$ 60,00 | R$ 50,00 |

**Tipos de ingresso:** inteira (100% do valor) e meia (50%).

**Clientes**

| Cliente | E-mail | Idade |
|---|---|---|
| Gabi Pinto | gabi.pinto@cinema.example | 30 anos |
| Hélio Cunha | helio.cunha@cinema.example | 65 anos |
| Ivo Lemos | ivo.lemos@cinema.example | 15 anos |
| Jussara Rocha | jussara.rocha@cinema.example | 28 anos |
| Kauê Brito | kaue.brito@cinema.example | 20 anos |

### Entrada 2 — Sessões e compras antigas

O fim da sessão é o início mais a duração do filme mais **20 minutos de limpeza**. Duas sessões da mesma sala não podem se sobrepor.

| Sessão | Filme | Sala | Quando | Formato | Situação |
|---|---|---|---|---|---|
| S1 | Aventura Estelar | Sala 2 | 20 dias atrás, 19:00 | legendado | encerrada |
| S2 | Pequeno Dragão | Sala 1 | 10 dias atrás, 15:00 | dublado | encerrada |
| S3 | Pequeno Dragão | Sala 1 | 9 dias atrás, 15:00 | dublado | encerrada |

**Compras pagas** (cada ingresso guarda o valor pago no dia)

| Cliente | Sessão | Compra feita | Ingressos | Total | Pagamento |
|---|---|---|---|---|---|
| Gabi Pinto | S1 | 21 dias atrás | A1 inteira R$ 40,00; A2 meia R$ 20,00 | R$ 60,00 | pix |
| Hélio Cunha | S2 | 11 dias atrás | A1 meia R$ 15,00 (idoso) | R$ 15,00 | cartão |
| Ivo Lemos | S3 | 12 dias atrás | A1 meia R$ 15,00 (estudante) | R$ 15,00 | pix |

### Entrada 3 — Reajuste

A inteira **2D em dia normal** passa de R$ 30,00 para **R$ 35,00**, valendo desde 10 dias atrás. Os ingressos já vendidos continuam com o valor que tinham.

### Entrada 4 — Sessões futuras, compras, cancelamentos e uma reserva de assento

| Sessão | Filme | Sala | Quando | Formato | Situação |
|---|---|---|---|---|---|
| S4 | Noite Silenciosa | Sala VIP | amanhã, 21:00 | legendado | **esgotada** |
| S5 | Aventura Estelar | Sala 2 | daqui a 2 dias, 19:00 | legendado | aberta |
| S6 | Pequeno Dragão | Sala 1 | daqui a 3 dias, 14:00 | dublado | **cancelada** pelo cinema |
| S7 | Pequeno Dragão | Sala 1 | daqui a 4 dias, 16:00 | dublado | aberta |

**Compras**

| Cliente | Sessão | Quando | Ingressos | Total | Situação |
|---|---|---|---|---|---|
| Gabi Pinto | S4 | 30 horas atrás | A1 inteira R$ 60,00; A2 inteira R$ 60,00; A3 meia R$ 30,00 | R$ 150,00 | paga, cartão (a sessão esgotou) |
| Kauê Brito | S5 | 26 horas atrás | A1 meia R$ 20,00 (estudante); A2 inteira R$ 40,00 | R$ 60,00 | paga, pix |
| Kauê Brito | S5 | 25 horas atrás | A3 inteira R$ 40,00 | R$ 40,00 | **cancelada pelo cliente** com mais de 2 horas de antecedência: reembolso total de R$ 40,00; o ingresso fica cancelado e o assento volta a ficar livre |
| Hélio Cunha | S6 | 24 horas atrás | A3 meia R$ 17,50 | R$ 17,50 | **cancelada** porque o cinema cancelou a sessão: reembolso total de R$ 17,50 |

**Reserva de assento (10 minutos):** a Jussara Rocha segurou o assento **A4 da S5** há 3 minutos e ainda não pagou; a reserva expira em 7 minutos.

### Entrada 5 — Correção

A sessão **S7** foi criada **por engano**. Apague a sessão.

## O que sai

Todas as consultas valem para o banco **depois das 5 entradas**.

| # | Pergunta | O que sai |
|---|---|---|
| C1 | Quantos filmes, sessões, compras e ingressos existem? | 4 filmes, 6 sessões, 7 compras, 11 ingressos |
| C2 | Quantas sessões em cada situação? | encerrada 3 · aberta 1 · cancelada 1 · esgotada 1 |
| C3 | Quais as sessões futuras? Filme, sala, dia (a partir de hoje), hora, formato e situação. | Noite Silenciosa, Sala VIP, amanhã, 21:00, legendado, esgotada · Aventura Estelar, Sala 2, daqui a 2 dias, 19:00, legendado, aberta · Pequeno Dragão, Sala 1, daqui a 3 dias, 14:00, dublado, cancelada |
| C4 | Na sessão S5 (Aventura Estelar, daqui a 2 dias): qual a situação de cada assento da sala (vendido, reservado ou livre)? | A1 vendido · A2 vendido · A3 livre · A4 reservado |
| C5 | Quais assentos são especiais? | Sala 1, A3, cadeirante · Sala 1, B3, casal |
| C6 | Qual o faturamento (soma do total das compras pagas)? | R$ 300,00 |
| C7 | Quantos ingressos vendidos (não cancelados) de cada tipo e quanto valem? | inteira 4, R$ 200,00 · meia 5, R$ 100,00 |
| C8 | Na Sala 1: cada ingresso com o cliente, o valor pago e a situação; e quanto custa hoje a inteira 2D em dia normal. | Ivo, R$ 15,00, vendido · Hélio, R$ 15,00, vendido · Hélio, R$ 17,50, cancelado · inteira 2D de hoje: R$ 35,00 |
| C9 | Quantas compras em cada situação? | paga 5 · cancelada 2 |
| C10 | Quais compras tiveram reembolso e de quanto? | Hélio Cunha, R$ 17,50 · Kauê Brito, R$ 40,00 |
| C11 | Quais sessões estão esgotadas? Filme, sala, assentos da sala e assentos vendidos. | Noite Silenciosa, Sala VIP, 3 assentos, 3 vendidos |
| C12 | Quais filmes não têm nenhuma sessão e quais gêneros não têm nenhum filme? | Filme: Sombras do Passado · Gênero: Terror |
| C13 | Quantos ingressos vendidos (não cancelados) cada filme tem? **Todo filme aparece.** | Aventura Estelar 4 · Noite Silenciosa 3 · Pequeno Dragão 2 · Sombras do Passado 0 |
| C14 | Quais clientes nunca compraram? | Jussara Rocha (só ela) |
| C15 | Quais reservas de assento estão ativas? Cliente, filme, assento e quantos minutos faltam para expirar. | Jussara Rocha, Aventura Estelar, A4, 7 minutos |
| C16 | Quantos assentos cada sala tem, e quantos são especiais? **Toda sala aparece.** | Sala 1 (2D): 6 assentos, 2 especiais · Sala 2 (3D): 4, 0 · Sala VIP: 3, 0 |

## Testes de recusa

Estes três comandos **precisam dar erro**. Se o banco aceitar, falta uma regra na estrutura (se não souber como criá-la, anote como
achado). Copie a mensagem de erro de cada um no `achados.md`.

| # | Tente | O que sai |
|---|---|---|
| R1 | Fazer uma compra para uma sessão que não existe | Erro de chave estrangeira (FK) |
| R2 | Apagar o filme Aventura Estelar, que tem sessões | Erro: o banco não deixa apagar o que ainda é usado em outra tabela |
| R3 | Vender de novo o assento A1 da S5 (já vendido ao Kauê) | Erro: o mesmo assento não pode ser vendido duas vezes na mesma sessão |

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

- O assento é da **sala**, e o ingresso liga o assento à **sessão** (C4, C16)? Como o seu banco impede o mesmo assento em duas vendas da mesma sessão (R3)?
- O valor pago em cada ingresso ficou o da época (C8), mesmo depois do reajuste do preço? E o ingresso cancelado ainda aparece, sem ocupar o assento?
- O reembolso (C10) e a situação da compra (C9) estão guardados? Uma compra cancelada devolve o assento?
- A reserva de assento por 10 minutos (C15) guarda a hora em que expira?
- Uma sessão esgotada (C11) é uma situação guardada ou o banco calcula pelos ingressos?
- Um filme sem sessão, um gênero sem filme ou um cliente sem compra sumiu do resultado (C12, C13, C14, C16)? Isso costuma ser `JOIN` no lugar de `LEFT JOIN`.
- Duas sessões na mesma sala: o fim da sessão (início, duração do filme e 20 minutos de limpeza) é guardado ou calculado?
- Faltou algum lugar para guardar uma informação do pedido?

