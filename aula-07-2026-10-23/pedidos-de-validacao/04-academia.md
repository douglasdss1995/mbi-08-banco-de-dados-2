# Validação do banco — Academia

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

**Modalidades:** Musculação, Spinning, Funcional, Yoga.

**Planos** (valor **mensal**, desde 300 dias atrás) e o que cada um inclui

| Plano | Duração | Valor mensal | Inclui |
|---|---|---|---|
| Básico Mensal | 1 mês | R$ 90,00 | só Musculação |
| Completo Mensal | 1 mês | R$ 140,00 | todas as modalidades |
| Completo Anual | 12 meses | R$ 120,00 | todas as modalidades |

**Alunos** (a idade é aproximada; o dia de vencimento é o que o aluno escolheu)

| Aluno | E-mail | Idade | Dia de vencimento |
|---|---|---|---|
| Bia Campos | bia.campos@academia.example | 28 anos | 10 |
| Caio Mendes | caio.mendes@academia.example | 41 anos | 5 |
| Dani Rocha | dani.rocha@academia.example | 33 anos | 15 |
| Enzo Pires | enzo.pires@academia.example | 25 anos | 10 |
| Flávia Lopes | flavia.lopes@academia.example | 52 anos | 20 |
| Gabi Torres | gabi.torres@academia.example | 30 anos | 10 |
| Heitor Vaz | heitor.vaz@academia.example | 37 anos | 10 |

**Instrutores** (o CREF é o registro profissional)

| Instrutor | CREF | Modalidades |
|---|---|---|
| Gil Prado | CREF-001 | Musculação e Funcional |
| Hana Cruz | CREF-002 | Spinning e Yoga |
| Igor Silva | CREF-003 | Musculação |

**Turmas de aula coletiva** (50 minutos cada)

| Modalidade | Instrutor | Dia e hora | Vagas |
|---|---|---|---|
| Spinning | Hana Cruz | segunda, 18:00 | **2** |
| Funcional | Gil Prado | terça, 07:00 | 20 |
| Yoga | Hana Cruz | quinta, 19:00 | 15 |

### Entrada 2 — Matrículas antigas, mensalidades e pagamentos

| Aluno | Plano | Valor mensal da matrícula | Início | Fim | Situação |
|---|---|---|---|---|---|
| Bia Campos | Completo Mensal | R$ 140,00 | 200 dias atrás | 170 dias atrás | vencida (a Bia saiu) |
| Bia Campos | Completo Anual | R$ 120,00 | 70 dias atrás | daqui a 295 dias | ativa (ela voltou e fez uma **nova** matrícula) |
| Caio Mendes | Básico Mensal | R$ 90,00 | 45 dias atrás | daqui a 20 dias | ativa |
| Enzo Pires | Básico Mensal | R$ 90,00 | 100 dias atrás | 70 dias atrás | cancelada |

**Mensalidades** (uma por mês; o vencimento é dado em dias a partir de hoje)

| Aluno | Vencimento | Valor | Pagamento |
|---|---|---|---|
| Bia Campos | 70 dias atrás | R$ 120,00 | paga no vencimento, por pix, R$ 120,00 |
| Bia Campos | 35 dias atrás | R$ 120,00 | paga com **10 dias de atraso** (25 dias atrás), por cartão: base R$ 120,00 + multa de 2% (R$ 2,40) + juros de 0,033% ao dia (R$ 0,40) = **R$ 122,80** |
| Bia Campos | hoje | R$ 120,00 | ainda não paga |
| Bia Campos | daqui a 35 dias | R$ 120,00 | ainda não paga |
| Caio Mendes | 40 dias atrás | R$ 90,00 | **não paga** |
| Caio Mendes | 5 dias atrás | R$ 90,00 | **não paga** |

### Entrada 3 — Reajuste de plano

O **Completo Mensal** passa de R$ 140,00 para **R$ 160,00** por mês, valendo desde 10 dias atrás. As matrículas já feitas continuam com o valor que tinham.

### Entrada 4 — Matrículas novas, reservas, acessos e avaliações

| Aluno | Plano | Valor mensal | Início | Fim | Mensalidade (vencimento, valor) |
|---|---|---|---|---|---|
| Dani Rocha | Completo Mensal | R$ 160,00 | 3 dias atrás | daqui a 27 dias | daqui a 12 dias, R$ 160,00, não paga |
| Gabi Torres | Completo Mensal | R$ 160,00 | 2 dias atrás | daqui a 28 dias | daqui a 13 dias, R$ 160,00, não paga |
| Heitor Vaz | Básico Mensal | R$ 90,00 | 1 dia atrás | daqui a 29 dias | daqui a 14 dias, R$ 90,00, não paga |

**Reservas de aula** (a data é a da aula, em dias a partir de hoje; "mais antiga" significa que pediu primeiro)

| Aluno | Aula | Data | Situação |
|---|---|---|---|
| Bia Campos | Spinning | daqui a 3 dias | confirmada (pediu primeiro) |
| Dani Rocha | Spinning | daqui a 3 dias | confirmada |
| Gabi Torres | Spinning | daqui a 3 dias | **lista de espera** (as 2 vagas já estão ocupadas) |
| Bia Campos | Funcional | daqui a 4 dias | confirmada |
| Dani Rocha | Funcional | daqui a 4 dias | cancelada |
| Bia Campos | Funcional | 14 dias atrás | presente |
| Bia Campos | Yoga | 7 dias atrás | faltou |

**Acessos pela catraca:** a Bia Campos entrou 49 horas atrás e saiu uma hora e meia depois; a Dani Rocha entrou 25 horas atrás e saiu 1 hora depois;
a Bia Campos entrou de novo há 1 hora e **ainda não saiu**.

**Avaliações físicas:** Bia Campos, 90 dias atrás, 62,0 kg e 1,65 m; Bia Campos, 5 dias atrás, 60,5 kg e 1,65 m; Caio Mendes, 20 dias atrás, 85,0 kg e 1,80 m.

### Entrada 5 — Correção

A matrícula do **Heitor Vaz** foi feita **por engano**. Apague a matrícula **e tudo o que pertence a ela**. O Heitor continua cadastrado como aluno.

## O que sai

Todas as consultas valem para o banco **depois das 5 entradas**.

| # | Pergunta | O que sai |
|---|---|---|
| C1 | Quantos alunos, matrículas e mensalidades existem? | 7 alunos, 6 matrículas, 8 mensalidades |
| C2 | Quais são as matrículas ativas? Mostre aluno, plano e valor mensal. | Bia, Completo Anual, R$ 120 · Caio, Básico Mensal, R$ 90 · Dani, Completo Mensal, R$ 160 · Gabi, Completo Mensal, R$ 160 |
| C3 | Qual o histórico de matrículas da Bia Campos? Plano, valor mensal, início, fim e situação. | Completo Mensal, R$ 140, 200 dias atrás até 170 dias atrás, vencida · Completo Anual, R$ 120, 70 dias atrás até daqui a 295 dias, ativa |
| C4 | Quantas modalidades cada plano inclui? **Todo plano aparece.** | Básico Mensal 1 · Completo Anual 4 · Completo Mensal 4 |
| C5 | Em cada matrícula do Completo Mensal: quanto o aluno paga por mês, e qual é o valor de hoje do plano? | Bia R$ 140 · Dani R$ 160 · Gabi R$ 160 · valor de hoje: R$ 160 |
| C6 | Quais mensalidades estão em atraso (vencidas e sem pagamento)? Mostre aluno e dias de atraso. | Caio, 40 dias · Caio, 5 dias |
| C7 | Quais alunos estão bloqueados na catraca (mensalidade em atraso há mais de 15 dias)? | Caio Mendes (só ele) |
| C8 | Quais pagamentos foram feitos com atraso? Mostre base, multa, juros e valor pago. | Bia: base R$ 120,00, multa R$ 2,40, juros R$ 0,40, pago R$ 122,80 (só esse) |
| C9 | Quanto foi recebido no total? | R$ 242,80 |
| C10 | Quais alunos nunca tiveram uma matrícula? | Flávia Lopes e Heitor Vaz |
| C11 | Na aula de Spinning de daqui a 3 dias: quantas vagas, quantas confirmadas e quantas pessoas na espera? | 2 vagas, 2 confirmadas, 1 na espera |
| C12 | Quais as reservas da Bia Campos? Modalidade, dia da aula e situação. | Funcional, 14 dias atrás, presente · Yoga, 7 dias atrás, faltou · Spinning, daqui a 3 dias, confirmada · Funcional, daqui a 4 dias, confirmada |
| C13 | Quem está dentro da academia agora (entrou e ainda não saiu)? | Bia Campos (só ela) |
| C14 | Para cada instrutor: quantas modalidades e quantas turmas? **Todo instrutor aparece.** | Gil 2 modalidades e 1 turma · Hana 2 e 2 · Igor 1 e 0 |
| C15 | Qual o IMC (peso dividido pela altura ao quadrado, com 1 casa decimal) da avaliação mais recente de cada aluno avaliado? | Bia 22,2 · Caio 26,2 |
| C16 | Quantas matrículas ativas cada plano tem? **Todo plano aparece.** | Completo Mensal 2 · Básico Mensal 1 · Completo Anual 1 |

## Testes de recusa

Estes três comandos **precisam dar erro**. Se o banco aceitar, falta uma regra na estrutura (se não souber como criá-la, anote como
achado). Copie a mensagem de erro de cada um no `achados.md`.

| # | Tente | O que sai |
|---|---|---|
| R1 | Fazer uma matrícula para um aluno que não existe | Erro de chave estrangeira (FK) |
| R2 | Apagar o plano Completo Mensal, que tem matrículas | Erro: o banco não deixa apagar o que ainda é usado em outra tabela |
| R3 | A Bia Campos reservar de novo o Spinning de daqui a 3 dias | Erro: a mesma reserva não pode se repetir (aluno, aula e data) |

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

- O valor da matrícula da Bia ficou o do dia em que ela se matriculou, mesmo depois do reajuste do plano (C3, C5)?
- Uma aluna que **saiu e voltou** (Bia) tem duas matrículas no histórico (C3)? O aluno e a matrícula são a mesma tabela no seu banco?
- A multa e os juros do pagamento atrasado (C8) estão guardados no pagamento? O atraso (C6, C7) é guardado ou calculado a partir do vencimento?
- A vaga ocupada de uma aula (C11) é uma coluna ou é contada nas reservas? Onde fica a **ordem** da lista de espera?
- Quem está dentro da academia (C13) sai de uma saída vazia? E o IMC (C15) é guardado ou calculado?
- Um aluno, plano ou instrutor **sem nenhuma matrícula, aluno ou turma** sumiu do resultado (C4, C10, C14, C16)? Isso costuma ser `JOIN` no lugar de `LEFT JOIN`.
- Faltou algum lugar para guardar uma informação do pedido?

