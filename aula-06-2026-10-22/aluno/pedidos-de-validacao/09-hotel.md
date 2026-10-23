# Validação do banco — Hotel ou pousada

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

**Tipos de quarto:** Standard (até 2 hóspedes), Superior (até 3), Suíte (até 4).

**Quartos**

| Número | Andar | Tipo | Situação |
|---|---|---|---|
| 101 | 1 | Standard | livre |
| 102 | 1 | Standard | ocupado |
| 201 | 2 | Superior | livre |
| 202 | 2 | Superior | aguardando limpeza |
| 301 | 3 | Suíte | em manutenção |

**Temporadas:** alta, de daqui a 30 dias até daqui a 60 dias; feriado, de daqui a 90 dias até daqui a 92 dias. O que não está em nenhum período é **baixa temporada**.

**Tarifa** (desde 300 dias atrás; o adicional é por pessoa acima de 2, por noite)

| Tipo | Temporada | Diária | Adicional por pessoa |
|---|---|---|---|
| Standard | baixa | R$ 200,00 | R$ 40,00 |
| Standard | alta | R$ 300,00 | R$ 50,00 |
| Standard | feriado | R$ 400,00 | R$ 60,00 |
| Superior | baixa | R$ 300,00 | R$ 50,00 |
| Superior | alta | R$ 450,00 | R$ 60,00 |
| Suíte | baixa | R$ 500,00 | R$ 80,00 |

**Hóspedes** (o documento é único; CPF ou passaporte fictício)

| Hóspede | Documento | Idade |
|---|---|---|
| Ana Leal | DOC-0001 | 34 anos |
| Bruno Sá | DOC-0002 | 41 anos |
| Carol Dias | DOC-0003 | 29 anos |
| Dino Faria | DOC-0004 | 52 anos |
| Edu Mota | DOC-0005 | 38 anos |
| Fani Reis | DOC-0006 | 47 anos |

**Itens de consumo (preço):** Água mineral R$ 8,00; Refeição no restaurante R$ 60,00; Lavanderia (peça) R$ 35,00.

**Manutenção:** o quarto 301, de 3 dias atrás até daqui a 5 dias, por «Troca do ar-condicionado».

### Entrada 2 — Reservas e estadias antigas, com consumo e pagamento

A **reserva é de um tipo de quarto** (o quarto específico só aparece no check-in). Ela guarda o valor das diárias **da época** e um **sinal de 30%**.

| Hóspede | Tipo | Entrada | Saída | Hóspedes (crianças) | Situação | Valor das diárias | Sinal |
|---|---|---|---|---|---|---|---|
| Ana Leal | Standard | 30 dias atrás | 28 dias atrás | 2 (0) | check-in feito | R$ 400,00 (2 noites a R$ 200,00) | R$ 120,00 |
| Bruno Sá | Superior | 20 dias atrás | 17 dias atrás | 3 (1 criança de 4 anos, que não paga) | check-in feito | R$ 900,00 (3 noites a R$ 300,00) | R$ 270,00 |
| Carol Dias | Standard | 10 dias atrás | 7 dias atrás | 2 (0) | **cancelada** com mais de 7 dias de antecedência (sem custo) | R$ 660,00 (3 noites a R$ 220,00) | R$ 198,00 |
| Dino Faria | Standard | 5 dias atrás | 4 dias atrás | 2 (0) | **não compareceu** (*no-show*: paga 50% das diárias) | R$ 220,00 (1 noite) | R$ 66,00 |

**Estadias encerradas** (check-in às 14:00)

| Estadia | Quarto | Responsável (acompanhante) | Reserva | Check-in | Check-out | Valor final |
|---|---|---|---|---|---|---|
| E1 | 101 | Ana Leal | a da Ana | 30 dias atrás | 28 dias atrás, às 11:00 | R$ 451,00 (diárias R$ 400,00 + consumo R$ 51,00) |
| E2 | 201 | Bruno Sá (acompanhante: Carol Dias) | a do Bruno | 20 dias atrás | 17 dias atrás, às **17:00** | R$ 1.110,00 (diárias R$ 900,00 + **meia diária** de R$ 150,00, por sair entre 12:00 e 18:00, + consumo R$ 60,00) |
| E3 | 202 | Carol Dias | **sem reserva** (hóspede de balcão) | ontem, 14:00 | hoje, às 11:00 | R$ 300,00 (1 noite de Superior) |

**Consumo** (com o preço do dia): E1, 2 águas (R$ 8,00) e 1 lavanderia (R$ 35,00); E2, 1 refeição (R$ 60,00).

**Pagamento no check-out** (o sinal da reserva é abatido do valor final): E1, pix R$ 200,00 e cartão R$ 131,00 (451 − 120 de sinal); E2, dinheiro R$ 500,00 e
cartão R$ 340,00 (1.110 − 270 de sinal); E3, dinheiro R$ 300,00.

### Entrada 3 — Reajuste

A diária **Standard** na temporada baixa passa de R$ 200,00 para **R$ 220,00**, valendo desde 15 dias atrás. As reservas antigas continuam com o valor da época.

### Entrada 4 — Hospedagem em curso e reservas futuras

- **Estadia em curso (balcão, sem reserva):** quarto 102, check-in 3 dias atrás às 14:00, saída prevista amanhã, 2 hóspedes, diária de R$ 220,00. Responsável: Dino Faria; acompanhante: Fani Reis. Consumo: 2 águas (R$ 8,00).

**Reservas futuras (confirmadas)**

| Hóspede | Tipo | Entrada | Saída | Hóspedes | Valor das diárias | Sinal |
|---|---|---|---|---|---|---|
| Bruno Sá | Suíte | daqui a 10 dias | daqui a 12 dias | 2 | R$ 1.000,00 (2 noites a R$ 500,00) | R$ 300,00 |
| Ana Leal | Superior | daqui a 35 dias | daqui a 38 dias | 2 | R$ 1.350,00 (3 noites na alta temporada, R$ 450,00) | R$ 405,00 |
| Edu Mota | Standard | daqui a 2 dias | daqui a 3 dias | 2 | R$ 220,00 | R$ 66,00 |

### Entrada 5 — Correção

A reserva do **Edu Mota** foi lançada **por engano**. Apague a reserva. O Edu continua cadastrado como hóspede.

## O que sai

Todas as consultas valem para o banco **depois das 5 entradas**.

| # | Pergunta | O que sai |
|---|---|---|
| C1 | Quantas reservas, estadias, hóspedes e quartos existem? | 6 reservas, 4 estadias, 6 hóspedes, 5 quartos |
| C2 | Quantos quartos em cada situação? | livre 2 · aguardando limpeza 1 · em manutenção 1 · ocupado 1 |
| C3 | Para as reservas Standard: hóspede, noites, valor das diárias, valor por noite e a diária Standard (baixa) de hoje. | Ana, 2 noites, R$ 400, R$ 200 por noite · Carol, 3 noites, R$ 660, R$ 220 · Dino, 1 noite, R$ 220, R$ 220 · diária de hoje: R$ 220 |
| C4 | Quantas reservas em cada situação? | check-in 2 · confirmada 2 · cancelada 1 · não compareceu 1 |
| C5 | Quais as reservas futuras (confirmadas)? Hóspede, tipo, entrada e saída (em dias a partir de hoje), valor e sinal. | Bruno, Suíte, daqui a 10 dias até daqui a 12, R$ 1.000, sinal R$ 300 · Ana, Superior, daqui a 35 até daqui a 38, R$ 1.350, sinal R$ 405 |
| C6 | Quais hóspedes nunca estiveram em uma reserva nem em uma estadia? | Edu Mota (só ele) |
| C7 | Quem está hospedado agora? Quarto, responsável e acompanhantes. | Quarto 102: Dino Faria (responsável), Fani Reis (acompanhante) |
| C8 | Qual o faturamento (soma do valor final das estadias encerradas)? | R$ 1.861,00 |
| C9 | Na estadia do Bruno Sá: diárias, meia diária, consumo, valor final, sinal e quanto foi pago no check-out. | Diárias R$ 900 · meia diária R$ 150 · consumo R$ 60 · valor final R$ 1.110 · sinal R$ 270 · pago no check-out R$ 840 |
| C10 | Qual o consumo total de cada estadia (por quarto)? Estadia sem consumo = 0. | 101: R$ 51 · 102: R$ 16 · 201: R$ 60 · 202: R$ 0 |
| C11 | Quantos pagamentos e quanto por forma de pagamento? | dinheiro 2, R$ 800 · cartão 2, R$ 471 · pix 1, R$ 200 |
| C12 | Por tipo de quarto: quantos quartos e quantos livres agora? **Todo tipo aparece.** | Standard 2 quartos, 1 livre · Superior 2 quartos, 1 livre · Suíte 1 quarto, 0 livres |
| C13 | Quais quartos estão em manutenção? Número, motivo, início e fim (em dias a partir de hoje). | 301, Troca do ar-condicionado, 3 dias atrás até daqui a 5 dias |
| C14 | Quais reservas foram canceladas ou não compareceram, e quanto cada hóspede deve? (cancelada com mais de 7 dias de antecedência: nada; *no-show*: 50% das diárias) | Carol Dias, cancelada, R$ 0 · Dino Faria, não compareceu, R$ 110 |
| C15 | Qual a tarifa vigente hoje, por tipo e temporada? | Standard: baixa R$ 220, alta R$ 300, feriado R$ 400 · Suíte: baixa R$ 500 · Superior: baixa R$ 300, alta R$ 450 |
| C16 | Para cada estadia: o quarto, o responsável e quantos acompanhantes. | 101 Ana, 0 · 102 Dino, 1 · 201 Bruno, 1 · 202 Carol, 0 |

## Testes de recusa

Estes três comandos **precisam dar erro**. Se o banco aceitar, falta uma regra na estrutura (se não souber como criá-la, anote como
achado). Copie a mensagem de erro de cada um no `achados.md`.

| # | Tente | O que sai |
|---|---|---|
| R1 | Fazer uma reserva para um hóspede que não existe | Erro de chave estrangeira (FK) |
| R2 | Apagar o tipo de quarto Standard, que tem quartos | Erro: o banco não deixa apagar o que ainda é usado em outra tabela |
| R3 | Cadastrar outro hóspede com o documento DOC-0001, que já é da Ana Leal | Erro de valor duplicado |

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

- O valor das diárias da reserva ficou o **da época** (C3), mesmo depois do reajuste da tarifa? Onde ficou guardado?
- A **reserva** é de um tipo de quarto e a **estadia** é a hospedagem de fato num quarto específico (C7, C16)? O hóspede de balcão (sem reserva) cabe no seu banco?
- O hóspede **responsável** e os **acompanhantes** (C7, C16) estão numa tabela de ligação, com o papel de cada um?
- O consumo (C10) guarda o preço do dia do lançamento? O valor final (C8, C9) é guardado ou calculado a partir das diárias, da meia diária e do consumo?
- A tarifa por tipo e temporada (C15) tem **vigência**? Como o seu banco sabe qual vale hoje?
- Um quarto em manutenção (C13) e a situação de cada quarto (C2) estão registrados?
- Um hóspede, tipo de quarto ou estadia **sem nada ligado** sumiu do resultado (C6, C10, C12)? Isso costuma ser `JOIN` no lugar de `LEFT JOIN`.
- Faltou algum lugar para guardar uma informação do pedido?

