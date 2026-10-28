# Validação do banco — Clínica médica

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

**Especialidades:** Cardiologia, Clínica Geral, Pediatria, Dermatologia, Ortopedia, Neurologia (esta ainda sem médico).

**Médicos**

| Médico | CRM (registro profissional) | Especialidade(s) | Atende |
|---|---|---|---|
| Helena Costa (médica) | CRM-1001 | Cardiologia e Clínica Geral | segunda, das 08:00 às 12:00 e das 14:00 às 18:00 |
| Rui Matos (médico) | CRM-1002 | Pediatria | terça, das 08:00 às 12:00 |
| Sofia Lins (médica) | CRM-1003 | Dermatologia | quarta, das 13:00 às 17:00 |
| Téo Alves (médico) | CRM-1004 | Ortopedia | sexta, das 08:00 às 12:00 |

A Sofia Lins tem um **bloqueio na agenda** (congresso) começando daqui a 10 dias e terminando daqui a 12 dias.

**Convênios:** Saúde Mais (cobre 70% do valor) e VidaPlena (cobre 50%).

**Pacientes**

| Paciente | Idade | Convênio |
|---|---|---|
| Alice Pires | 34 anos | Saúde Mais |
| Bento Rocha | 8 anos | particular (sem convênio) |
| Cecília Souza | 61 anos | VidaPlena |
| Davi Nunes | 45 anos | particular |
| Elisa Moraes | 29 anos | Saúde Mais |

**Tipos de consulta e valor de tabela:** Primeira consulta (30 min, R$ 200,00), Retorno (20 min, R$ 120,00), Exame de rotina (45 min, R$ 300,00).

### Entrada 2 — Consultas antigas, pagamentos e prontuários

Quem tem convênio paga só a parte que o convênio não cobre. **Retorno** com o mesmo médico em até 30 dias da consulta anterior é
**gratuito**. Cancelar a menos de 24 horas antes cobra **metade** do valor.

| Dia | Hora | Paciente | Médico | Tipo | Situação | Pagamento |
|---|---|---|---|---|---|---|
| 40 dias atrás | 09:00 | Alice Pires | Helena Costa | Primeira consulta | realizada | R$ 200,00: convênio R$ 140,00, paciente R$ 60,00, pago |
| 20 dias atrás | 10:00 | Bento Rocha | Rui Matos | Primeira consulta | realizada | R$ 200,00, paciente, pago |
| 15 dias atrás | 09:30 | Alice Pires | Helena Costa | Retorno | realizada | gratuito (isento) |
| 12 dias atrás | 08:00 | Cecília Souza | Sofia Lins | Exame de rotina | realizada | R$ 300,00: convênio R$ 150,00, paciente R$ 150,00, pago |
| 10 dias atrás | 14:00 | Bento Rocha | Rui Matos | Retorno | realizada | gratuito (isento) |
| 9 dias atrás | 15:00 | Davi Nunes | Helena Costa | Primeira consulta | **faltou** | sem pagamento |
| 8 dias atrás | 10:00 | Davi Nunes | Helena Costa | Primeira consulta | **cancelada** 8 horas antes | R$ 100,00 (metade), paciente, pendente |

**Prontuários** (só das consultas realizadas de Alice, Bento e Cecília)

| Paciente | Queixa | CID (código da doença) | Receitas | Exames pedidos |
|---|---|---|---|---|
| Alice Pires | Dor no peito ao esforço | R07 | AAS 100 mg (1 comprimido ao dia); Atenolol 25 mg (1 comprimido pela manhã) | Eletrocardiograma |
| Bento Rocha | Febre há dois dias | R50 | Paracetamol gotas (10 gotas a cada 6 horas) | nenhum |
| Cecília Souza | Manchas na pele | L30 | nenhuma | Biópsia de pele |

### Entrada 3 — Reajuste de preço

A **Primeira consulta** passa de R$ 200,00 para **R$ 240,00**. As consultas já marcadas continuam com o valor que tinham.

### Entrada 4 — Consultas de hoje e futuras

| Dia | Hora | Paciente | Médico | Tipo | Situação | Pagamento |
|---|---|---|---|---|---|---|
| hoje | 09:00 | Alice Pires | Helena Costa | Retorno | confirmada | gratuito (isento): é retorno em até 30 dias |
| hoje | 09:30 | Cecília Souza | Helena Costa | Primeira consulta | agendada | R$ 240,00: convênio R$ 120,00, paciente R$ 120,00, pendente |
| hoje | 14:00 | Bento Rocha | Rui Matos | Exame de rotina | confirmada | R$ 300,00, paciente, pendente |
| amanhã | 08:00 | Alice Pires | Sofia Lins | Primeira consulta | agendada | R$ 240,00: convênio R$ 168,00, paciente R$ 72,00, pendente |
| daqui a 2 dias | 10:00 | Elisa Moraes | Helena Costa | Primeira consulta | agendada | R$ 240,00: convênio R$ 168,00, paciente R$ 72,00, pendente |

### Entrada 5 — Correção

A consulta da **Elisa Moraes** (daqui a 2 dias) foi marcada **por engano**. Apague essa consulta **e tudo o que pertence a ela**.

## O que sai

Todas as consultas valem para o banco **depois das 5 entradas**.

| # | Pergunta | O que sai |
|---|---|---|
| C1 | Quantas consultas, pacientes e médicos existem? | 11 consultas, 5 pacientes, 4 médicos |
| C2 | Qual a agenda de hoje? Mostre hora, médico, paciente, tipo e situação. | 09:00 Helena, Alice, Retorno, confirmada · 09:30 Helena, Cecília, Primeira consulta, agendada · 14:00 Rui, Bento, Exame de rotina, confirmada |
| C3 | Quantos médicos cada especialidade tem? **Toda especialidade aparece.** | Cardiologia 1 · Clínica Geral 1 · Dermatologia 1 · Ortopedia 1 · Pediatria 1 · Neurologia 0 |
| C4 | Quais os horários de atendimento da Helena Costa? | Segunda, 08:00–12:00 e segunda, 14:00–18:00 |
| C5 | Quais médicos não têm nenhuma consulta? | Téo Alves (só ele) |
| C6 | Quais pacientes não têm nenhuma consulta? | Elisa Moraes (só ela) |
| C7 | Quanto cada convênio deve pagar, somando as consultas? **Todo convênio aparece.** | Saúde Mais R$ 308,00 · VidaPlena R$ 270,00 |
| C8 | Quais retornos foram gratuitos? Mostre paciente, médico e quantos dias depois da consulta anterior com o mesmo médico. | Alice, Helena, 25 dias · Bento, Rui, 10 dias · Alice, Helena, 15 dias (o de hoje) |
| C9 | Qual o valor de tabela de cada **Primeira consulta** marcada, e qual é o valor de hoje? | 40 dias atrás R$ 200 · 20 dias atrás R$ 200 · 9 dias atrás R$ 200 · 8 dias atrás R$ 200 · hoje R$ 240 · amanhã R$ 240 · valor de hoje: R$ 240 |
| C10 | Quais consultas foram canceladas e quanto foi cobrado? | Davi Nunes, R$ 100,00 (só ela) |
| C11 | Quantas faltas cada paciente tem? **Todo paciente aparece.** | Davi 1 · Alice 0 · Bento 0 · Cecília 0 · Elisa 0 |
| C12 | Quantas consultas cada médico tem? **Todo médico aparece.** | Helena 6 · Rui 3 · Sofia 2 · Téo 0 |
| C13 | Para cada atendimento: paciente, CID, quantos medicamentos e quantos exames. | Alice, R07, 2 medicamentos, 1 exame · Bento, R50, 1 medicamento, 0 exames · Cecília, L30, 0 medicamentos, 1 exame |
| C14 | Liste os pacientes com o convênio e o percentual de cobertura. Particular aparece sem convênio. | Alice, Saúde Mais, 70% · Bento, particular · Cecília, VidaPlena, 50% · Davi, particular · Elisa, Saúde Mais, 70% |
| C15 | Quanto cada paciente ainda deve (a parte do paciente nos pagamentos pendentes)? | Bento R$ 300,00 · Cecília R$ 120,00 · Davi R$ 100,00 · Alice R$ 72,00 |
| C16 | Quantas consultas **realizadas** cada tipo tem? **Todo tipo aparece.** | Primeira consulta 2 · Retorno 2 · Exame de rotina 1 |

## Testes de recusa

Estes três comandos **precisam dar erro**. Se o banco aceitar, falta uma regra na estrutura (se não souber como criá-la, anote como
achado). Copie a mensagem de erro de cada um no `achados.md`.

| # | Tente | O que sai |
|---|---|---|
| R1 | Marcar uma consulta para um paciente que não existe | Erro de chave estrangeira (FK) |
| R2 | Apagar a médica Helena Costa, que tem consultas | Erro: o banco não deixa apagar o que ainda é usado em outra tabela |
| R3 | Cadastrar outro médico com o registro CRM-1001, que já é da Helena Costa | Erro de valor duplicado |

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

- O valor de uma consulta mudou quando o preço da tabela mudou (C9)? Onde ficou guardado o valor **do dia em que a consulta foi marcada**?
- A divisão entre a parte do **convênio** e a parte do **paciente** (C7, C15) está guardada ou dá para calcular? Particular tem convênio vazio?
- Um médico com **duas especialidades** (C3) e uma especialidade **sem médico** aparecem como o esperado? Isso pede uma tabela de ligação e `LEFT JOIN`.
- Um médico ou paciente **sem nenhuma consulta** sumiu do resultado (C5, C6, C11, C12)? Isso costuma ser `JOIN` no lugar de `LEFT JOIN`.
- Um médico com **dois intervalos no mesmo dia** (C4) cabe na sua agenda?
- Os dados do prontuário (C13) estão ligados ao **atendimento**, e o atendimento à **consulta**?
- Faltou algum lugar para guardar uma informação do pedido?

