# Validação do banco — Locadora de veículos

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

**Filiais:** Centro (Joinville), Aeroporto (Florianópolis), Norte (Blumenau).

**Grupos de veículos** (diária desde 300 dias atrás)

| Grupo | Diária | Caução | Premium (exige CNH com 2 anos ou mais) |
|---|---|---|---|
| Econômico | R$ 100,00 | R$ 500,00 | não |
| Sedã | R$ 150,00 | R$ 800,00 | não |
| SUV | R$ 250,00 | R$ 1.500,00 | sim |
| Utilitário | R$ 220,00 | R$ 1.200,00 | sim |

**Modelos:** Onix e Mobi (Econômico), Corolla (Sedã), Compass (SUV), Strada (Utilitário).

**Veículos**

| Placa | Modelo | Filial | Situação | Km atual | Km da última revisão | Última revisão |
|---|---|---|---|---|---|---|
| ABC1A11 | Onix | Centro | disponível | 30.000 | 25.000 | 100 dias atrás |
| DEF2B22 | Mobi | Centro | disponível | 15.000 | 10.000 | 50 dias atrás |
| GHI3C33 | Corolla | Aeroporto | disponível | 18.000 | 9.000 | 60 dias atrás |
| JKL4D44 | Compass | Aeroporto | em manutenção | 20.000 | 15.000 | 200 dias atrás |
| MNO5E55 | Onix | Norte | disponível | 41.000 | 30.000 | 90 dias atrás |

**Clientes** (a CNH é a carteira de habilitação)

| Cliente | Idade | CNH | Validade da CNH | CNH emitida há |
|---|---|---|---|---|
| Lúcio Prado | 35 anos | CNH-0001 | daqui a 400 dias | 10 anos |
| Mônica Reis | 28 anos | CNH-0002 | daqui a 300 dias | 1 ano |
| Nando Cruz | 40 anos | CNH-0003 | daqui a 20 dias | 15 anos |
| Olga Silva | 50 anos | CNH-0004 | daqui a 800 dias | 25 anos |
| Pablo Dias | 26 anos | CNH-0005 | daqui a 500 dias | 5 anos |

**Adicionais (valor por diária):** Seguro R$ 30,00, Cadeirinha R$ 15,00, GPS R$ 20,00, Motorista adicional R$ 25,00.

### Entrada 2 — Reservas e locações antigas (encerradas)

**Reservas** (de um **grupo**, não de um carro; datas em dias a partir de hoje, sempre às 10:00)

| Cliente | Grupo | Filial de retirada | Retirada | Devolução | Situação |
|---|---|---|---|---|---|
| Mônica Reis | Econômico | Centro | 40 dias atrás | 30 dias atrás | retirada (virou a locação abaixo) |
| Nando Cruz | SUV | Aeroporto | 25 dias atrás | 22 dias atrás | cancelada |
| Lúcio Prado | Econômico | Centro | 90 dias atrás | 88 dias atrás | não compareceu (*no-show*) |
| Lúcio Prado | Sedã | Centro | daqui a 3 dias | daqui a 6 dias | ativa |

**Locações encerradas** (retirada às 09:00; o carro específico é escolhido na retirada; a diária e a caução são as da época)

| Cliente | Veículo | Retirada | Devolução (prevista = real) | Devolvido em | Diária | Valor final |
|---|---|---|---|---|---|---|
| Lúcio Prado | ABC1A11 | 60 dias atrás, Centro | 55 dias atrás | Centro | R$ 100,00 | R$ 650,00 (5 diárias + Seguro) |
| Mônica Reis (da reserva acima) | DEF2B22 | 40 dias atrás, Centro | 30 dias atrás | **Aeroporto** (outra filial) | R$ 100,00 | R$ 1.200,00 (10 diárias com 10% de desconto + Cadeirinha + R$ 150,00 da devolução em outra filial) |
| Lúcio Prado | GHI3C33 | 12 dias atrás, Aeroporto | 5 dias atrás | Aeroporto | R$ 150,00 | R$ 1.085,00 (7 diárias com 10% de desconto + GPS) |

**Adicionais usados:** Seguro (R$ 30,00 por diária) na locação do ABC1A11; Cadeirinha (R$ 15,00) na do DEF2B22; GPS (R$ 20,00) na do GHI3C33.

**Vistorias** (km e combustível em quartos de tanque)

| Veículo | Tipo | Km | Quando | Combustível | Avarias |
|---|---|---|---|---|---|
| ABC1A11 | retirada | 25.000 | 60 dias atrás | 4 quartos | — |
| ABC1A11 | devolução | 25.800 | 55 dias atrás | 3 quartos | arranhão no para-choque |
| DEF2B22 | retirada | 14.000 | 40 dias atrás | 4 quartos | — |
| DEF2B22 | devolução | 15.000 | 30 dias atrás | 4 quartos | — |

### Entrada 3 — Reajuste

A diária do grupo **Econômico** passa de R$ 100,00 para **R$ 120,00**, valendo desde 20 dias atrás. As locações antigas continuam com o valor da época.

### Entrada 4 — Locações em andamento, manutenção e multas

| Cliente | Veículo | Retirada (09:00) | Devolução prevista (09:00) | Diária | Situação |
|---|---|---|---|---|---|
| Nando Cruz | DEF2B22 | 3 dias atrás | daqui a 4 dias | R$ 120,00 | em andamento (o veículo fica «alugado») |
| Pablo Dias | MNO5E55 | 1 dia atrás | daqui a 2 dias | R$ 120,00 | em andamento (o veículo fica «alugado») |

**Manutenção:** o Compass (JKL4D44) está em revisão de 2 dias atrás, às 08:00, até daqui a 3 dias, às 18:00, com 20.000 km.

**Multas de trânsito** (sempre às 14:00): GHI3C33, 8 dias atrás, R$ 195,00, excesso de velocidade; ABC1A11, 57 dias atrás, R$ 130,00, estacionamento
proibido; DEF2B22, 20 dias atrás, R$ 88,00, farol apagado. A multa vai para o **cliente que estava com o carro naquele dia e hora**.

### Entrada 5 — Correção

Hoje foi lançada, **por engano**, uma locação do ABC1A11 para a Olga Silva, com GPS e a vistoria de retirada (30.000 km). **Apague essa locação e tudo o
que pertence a ela**, e deixe o veículo **disponível** de novo.

## O que sai

Todas as consultas valem para o banco **depois das 5 entradas**.

| # | Pergunta | O que sai |
|---|---|---|
| C1 | Quantas locações, veículos e clientes existem? | 5 locações, 5 veículos, 5 clientes |
| C2 | Quantos veículos em cada situação? | alugado 2 · disponível 2 · em manutenção 1 |
| C3 | Para cada locação encerrada com vistoria: placa, quilômetros rodados, combustível na retirada e na devolução, e avarias. | ABC1A11, 800 km, combustível 4 → 3 quartos, «arranhão no para-choque» · DEF2B22, 1.000 km, 4 → 4 quartos, sem avarias |
| C4 | Quais locações estão em andamento? Mostre cliente, placa e a devolução prevista (em dias a partir de hoje). | Pablo, MNO5E55, daqui a 2 dias · Nando, DEF2B22, daqui a 4 dias |
| C5 | Qual a diária de cada locação do grupo Econômico, e qual é a diária de hoje do grupo? | 60 dias atrás R$ 100 · 40 dias atrás R$ 100 · 3 dias atrás R$ 120 · 1 dia atrás R$ 120 · diária de hoje: R$ 120 |
| C6 | Qual o valor final de cada locação encerrada? | Lúcio, ABC1A11, R$ 650 · Mônica, DEF2B22, R$ 1.200 · Lúcio, GHI3C33, R$ 1.085 |
| C7 | Qual o faturamento (soma do valor final das locações encerradas)? | R$ 2.935,00 |
| C8 | Quantas locações cada grupo teve? **Todo grupo aparece.** | Econômico 4 · Sedã 1 · SUV 0 · Utilitário 0 |
| C9 | Quais locações foram devolvidas em outra filial? | Mônica Reis, retirada no Centro, devolvida no Aeroporto (só ela) |
| C10 | Quais veículos precisam de revisão (10.000 km ou mais desde a última, ou mais de 6 meses)? Diga o motivo. | JKL4D44 (tempo) · MNO5E55 (quilometragem) |
| C11 | Para cada multa de trânsito: placa, dias atrás, valor e o cliente que estava com o carro (vazio se ninguém). | ABC1A11, 57 dias, R$ 130, Lúcio · DEF2B22, 20 dias, R$ 88, **ninguém** · GHI3C33, 8 dias, R$ 195, Lúcio |
| C12 | Quais clientes nunca alugaram? | Olga Silva (só ela) |
| C13 | Quais clientes têm a CNH vencendo nos próximos 30 dias? | Nando Cruz, em 20 dias (só ele) |
| C14 | Quais clientes podem alugar um grupo premium (CNH com 2 anos ou mais)? | Lúcio, Nando, Olga, Pablo (a Mônica não: CNH com 1 ano) |
| C15 | Quantas reservas em cada situação? | ativa 1 · cancelada 1 · não compareceu 1 · retirada 1 |
| C16 | Quantas vezes cada adicional foi usado, com o valor de hoje e o valor cobrado na locação? **Todo adicional aparece.** | Cadeirinha 1 (hoje R$ 15, cobrado R$ 15) · GPS 1 (hoje R$ 20, cobrado R$ 20) · Seguro 1 (hoje R$ 30, cobrado R$ 30) · Motorista adicional 0 (hoje R$ 25) |

## Testes de recusa

Estes três comandos **precisam dar erro**. Se o banco aceitar, falta uma regra na estrutura (se não souber como criá-la, anote como
achado). Copie a mensagem de erro de cada um no `achados.md`.

| # | Tente | O que sai |
|---|---|---|
| R1 | Registrar uma locação de um veículo que não existe | Erro de chave estrangeira (FK) |
| R2 | Apagar o grupo Econômico, que tem modelos e veículos | Erro: o banco não deixa apagar o que ainda é usado em outra tabela |
| R3 | Cadastrar outro cliente com a CNH CNH-0001, que já é do Lúcio Prado | Erro de valor duplicado |

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

- A diária de uma locação ficou a **da época** (C5), mesmo depois do reajuste do grupo? E o valor do adicional (C16)?
- A reserva é de um **grupo**, e o carro específico só aparece na locação (C15)? Como o seu banco liga a reserva à locação?
- A **vistoria** de retirada e a de devolução (C3) são duas linhas da mesma locação? Onde ficaram o combustível e as avarias?
- A multa de trânsito (C11) guarda só o veículo e o momento? Como você descobre o cliente que estava com o carro?
- Um veículo, grupo ou cliente **sem nenhuma locação** sumiu do resultado (C8, C12, C16)? Isso costuma ser `JOIN` no lugar de `LEFT JOIN`.
- A necessidade de revisão (C10) é guardada ou calculada? Onde ficam a quilometragem e a data da última revisão?
- Uma locação de um veículo apagada por engano (Entrada 5) deixou o carro disponível de novo (C2)?
- Faltou algum lugar para guardar uma informação do pedido?

