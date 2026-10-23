# Validação do banco — Oficina Mecânica

Banco de Dados 2

Você vai testar se um banco de dados consegue **guardar e devolver** o que um cliente real precisa. Aqui o teste é feito na
**Oficina Mecânica**, com o modelo que o professor mostrou. Depois você repete o mesmo caminho no **banco do seu projeto**.

Ninguém aqui diz **como** o seu banco deve ser (nomes de tabelas e de colunas são seus). O pedido diz **o que entra** e **o que
tem que sair**. Se a sua consulta devolve o que está na tabela «O que sai», a sua estrutura está servindo. Se não devolve, a
estrutura tem um problema, e achar esse problema é o objetivo.

Siglas: **DML** (*Data Manipulation Language*, linguagem de manipulação de dados: `INSERT`, `UPDATE`, `DELETE`), **FK** (*Foreign
Key*, chave estrangeira), **PK** (*Primary Key*, chave primária), **OS** (ordem de serviço).

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

**Datas:** o pedido dá só o **dia**. Escolha um mês e use o mesmo mês em todas as datas (por exemplo, o mês atual).

## O que entra

### Entrada 1 — Cadastros

**Clientes**

- Ana Souza, telefone (47) 99111-0001.
- Bruno Reis, telefone (47) 99222-0002.
- Carla Dias, telefone (47) 99333-0003.
- Davi Lopes, telefone (47) 99444-0004.
- Eva Costa, telefone (47) 99555-0005.
- Fábio Mendes, telefone (47) 99666-0006. Ainda **não tem veículo** cadastrado.

**Veículos**

- Gol da Volkswagen, placa ABC1D23, da Ana.
- Uno da Fiat, placa DEF4G56, também da Ana.
- Onix da Chevrolet, placa XYZ9K88, do Bruno.
- Onix da Chevrolet, placa QWE4R56, da Carla.
- Civic da Honda, placa HND2E45, do Davi.
- Corolla da Toyota, placa TYT7F90, da Eva.

**Mecânicos**

- Carlos Lima, especialidade Motor.
- Marta Alves, especialidade Suspensão.
- Paulo Neri, **sem especialidade** informada.
- Rita Gomes, especialidade Freios.

**Serviços e preço de tabela**

- Troca de óleo, R$ 120,00.
- Alinhamento, R$ 90,00.
- Troca de pastilhas, R$ 180,00.
- Troca de filtro, R$ 60,00.
- Balanceamento, R$ 80,00.
- Revisão completa, R$ 350,00.

### Entrada 2 — Ordens de serviço 1001 a 1006

Cada OS tem o número, o dia, o veículo, o mecânico e os serviços feitos, com o **valor que foi cobrado**.

| OS | Dia | Veículo | Mecânico | Serviços feitos (valor cobrado) |
|---|---|---|---|---|
| 1001 | 02 | ABC1D23 | Carlos Lima | Troca de óleo (R$ 120,00) e Alinhamento (R$ 90,00) |
| 1002 | 02 | XYZ9K88 | Marta Alves | Alinhamento (R$ 90,00) |
| 1003 | 05 | ABC1D23 | Marta Alves | Troca de pastilhas (R$ 180,00) |
| 1004 | 06 | QWE4R56 | Carlos Lima | Troca de óleo (R$ 120,00) e Troca de filtro (R$ 60,00) |
| 1005 | 07 | XYZ9K88 | Carlos Lima | Troca de óleo (R$ 120,00) |
| 1006 | 08 | HND2E45 | Marta Alves | Alinhamento (R$ **70,00**, com desconto) e Balanceamento (R$ 80,00) |

### Entrada 3 — Reajuste de preço

No dia 09 a oficina reajustou a **Troca de óleo**: o preço de tabela passa de R$ 120,00 para **R$ 135,00**. Atualize o
cadastro do serviço. As OS já feitas continuam como foram cobradas.

### Entrada 4 — Ordens de serviço 1007 a 1010

| OS | Dia | Veículo | Mecânico | Serviços feitos (valor cobrado) |
|---|---|---|---|---|
| 1007 | 12 | DEF4G56 | Carlos Lima | Troca de óleo (R$ 135,00) e Troca de filtro (R$ 60,00) |
| 1008 | 13 | QWE4R56 | Marta Alves | Balanceamento (R$ 80,00) |
| 1009 | 14 | XYZ9K88 | Paulo Neri | Troca de filtro (R$ 60,00) e Balanceamento (R$ 80,00) |
| 1010 | 20 | ABC1D23 | Carlos Lima | **Nenhum serviço lançado ainda** (o carro acabou de entrar) |

### Entrada 5 — Correção

A OS 1008 foi aberta **por engano**. Apague a OS 1008 **e tudo o que pertence a ela**.

## O que sai

Todas as consultas valem para o banco **depois das 5 entradas**.

| # | Pergunta | O que sai |
|---|---|---|
| C1 | Quantas ordens de serviço existem e quantos serviços foram lançados nelas, no total? | 9 ordens de serviço e 13 serviços lançados |
| C2 | Liste todos os clientes com os seus veículos (placa, modelo e marca). **Todo cliente aparece**, mesmo sem veículo. | 7 linhas: Ana (ABC1D23 Gol Volkswagen), Ana (DEF4G56 Uno Fiat), Bruno (XYZ9K88 Onix Chevrolet), Carla (QWE4R56 Onix Chevrolet), Davi (HND2E45 Civic Honda), Eva (TYT7F90 Corolla Toyota), Fábio (sem veículo) |
| C3 | Qual o total de cada OS, com o nome do cliente? Uma OS sem serviço tem total 0. | 1001 Ana 210 · 1002 Bruno 90 · 1003 Ana 180 · 1004 Carla 180 · 1005 Bruno 120 · 1006 Davi 150 · 1007 Ana 195 · 1009 Bruno 140 · 1010 Ana 0 |
| C4 | Quanto a oficina faturou nas OS do dia 02 ao dia 07 (inclusive)? | 780 |
| C5 | Em cada OS que teve troca de óleo, qual valor foi cobrado? E qual é hoje o preço de tabela? | 1001 cobrou 120 · 1004 cobrou 120 · 1005 cobrou 120 · 1007 cobrou 135 · preço de tabela hoje: 135 |
| C6 | Em quais OS o **Alinhamento** foi cobrado por um valor diferente do preço de tabela? | OS 1006, cobrado 70 (tabela 90). Só essa |
| C7 | Quantas vezes cada serviço foi prestado? **Todo serviço aparece**, mesmo o nunca prestado. | Troca de óleo 4 · Alinhamento 3 · Troca de filtro 3 · Balanceamento 2 · Troca de pastilhas 1 · Revisão completa 0 |
| C8 | Quanto cada serviço rendeu (soma do valor cobrado)? Todo serviço aparece. | Troca de óleo 495 · Alinhamento 250 · Troca de filtro 180 · Troca de pastilhas 180 · Balanceamento 160 · Revisão completa 0 |
| C9 | Para cada mecânico: quantas OS atendeu e quanto somou em serviços? **Todo mecânico aparece.** | Carlos 5 OS e 705 · Marta 3 OS e 420 · Paulo 1 OS e 140 · Rita 0 OS e 0 |
| C10 | Quais veículos **nunca** passaram pela oficina? | TYT7F90 (só ele) |
| C11 | Quais clientes **nunca** tiveram uma OS? | Eva Costa e Fábio Mendes |
| C12 | Quanto cada cliente já gastou na oficina, somando todos os seus veículos? Todo cliente aparece. | Ana 585 · Bruno 350 · Carla 180 · Davi 150 · Eva 0 · Fábio 0 |
| C13 | Quais OS estão **sem nenhum serviço lançado**? Mostre número, dia, veículo e mecânico. | OS 1010, dia 20, ABC1D23, Carlos Lima (só ela) |
| C14 | Quantas OS cada **marca** de veículo teve? Toda marca cadastrada aparece. | Chevrolet 4 · Volkswagen 3 · Fiat 1 · Honda 1 · Toyota 0 |
| C15 | Quais mecânicos estão sem especialidade informada? | Paulo Neri (só ele) |
| C16 | Mostre o histórico do veículo ABC1D23: número da OS, dia, mecânico e serviços feitos. | 1001, dia 02, Carlos, Alinhamento e Troca de óleo · 1003, dia 05, Marta, Troca de pastilhas · 1010, dia 20, Carlos, sem serviços |

## Testes de recusa

Estes três comandos **precisam dar erro**. Se o banco aceitar, falta uma regra na estrutura. Copie a mensagem de erro de cada
um no `achados.md`.

| # | Tente | O que sai |
|---|---|---|
| R1 | Criar uma OS ligada a um veículo que não existe (por exemplo, a placa ZZZ0Z00, ou um código de veículo que ninguém tem) | Erro de chave estrangeira (FK) |
| R2 | Apagar a cliente Ana Souza, que tem veículos | Erro: o banco não deixa apagar quem ainda é usado em outra tabela |
| R3 | Cadastrar de novo o veículo de placa ABC1D23 | Erro de chave duplicada |

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

- O valor cobrado de uma OS mudou quando o preço de tabela mudou? Onde o preço da época ficou guardado?
- Um cliente, mecânico, serviço ou veículo **sem nenhuma OS** sumiu do resultado? Isso costuma ser `JOIN` no lugar de `LEFT JOIN`.
- O total de uma OS está guardado em algum lugar? Se está, ele ficou errado depois da correção?
- Faltou algum lugar para guardar uma informação do pedido?
