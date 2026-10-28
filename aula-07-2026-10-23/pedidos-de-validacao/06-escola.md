# Validação do banco — Escola (notas e frequência)

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

O ano letivo é o **ano de hoje**. Os bimestres são dados em dias a partir de hoje.

| Bimestre | Começa | Termina |
|---|---|---|
| 1º | 200 dias atrás | 120 dias atrás |
| 2º | 119 dias atrás | 40 dias atrás |
| 3º | 39 dias atrás | daqui a 40 dias |
| 4º | daqui a 41 dias | daqui a 120 dias |

**Disciplinas:** Português, Matemática, História (esta ninguém dá ainda).
**Professores:** Clara Dias, Dario Luz, Elis Mota (esta ainda sem aulas).

**Turmas** (do ano): 1A (1ª série, manhã), 2B (2ª série, tarde), 3C (3ª série, noite, ainda sem alunos).

**Alunos e matrículas** (uma matrícula por aluno no ano; a turma vale desde 200 dias atrás)

| Aluno | Idade | Matrícula | Turma |
|---|---|---|---|
| Fábia Teles | 15 anos | sim | 1A |
| Gui Pacheco | 15 anos | sim | 1A |
| Hugo Lemos | 16 anos | sim | 1A |
| Íris Barros | 16 anos | sim | 2B |
| Jota Maciel | 17 anos | **ainda não** | — |

**Disciplinas dadas em cada turma** (com aulas por semana) e o professor desde 200 dias atrás

| Turma | Disciplina | Aulas por semana | Professor |
|---|---|---|---|
| 1A | Português | 4 | Clara Dias |
| 1A | Matemática | 5 | Dario Luz |
| 2B | Português | 4 | Dario Luz |

### Entrada 2 — Avaliações, notas, aulas e fechamento (Português da 1A)

| Bimestre | Avaliação | Tipo | Peso |
|---|---|---|---|
| 1º | Prova 1 | prova | 2 |
| 1º | Trabalho 1 | trabalho | 1 |
| 2º | Prova 2 | prova | 3 |
| 2º | Participação 2 | participação | 1 |

**Notas** (de 0 a 10)

| Aluno | Prova 1 | Trabalho 1 | Prova 2 | Participação 2 |
|---|---|---|---|---|
| Fábia Teles | 8 | 6 | 7 | 9 |
| Gui Pacheco | 5 | 7 | 6 | 4 |
| Hugo Lemos | 9 | **sem nota** | — | — |

**Aulas e chamada de Português da 1A** (Clara Dias, às 08:00; **falta justificada não conta** na frequência)

| Aula | Fábia | Gui | Hugo |
|---|---|---|---|
| 50 dias atrás | presente | presente | presente |
| 49 dias atrás | presente | ausente | presente |
| 48 dias atrás | presente | ausente | falta justificada |
| 47 dias atrás | ausente | ausente | presente |
| 46 dias atrás | presente | presente | presente |

**Fechamento** da 1A: 1º bimestre fechado há 115 dias; 2º bimestre fechado há 35 dias.

### Entrada 3 — Troca de professor, transferência e correção de nota

- **Matemática da 1A:** o Dario Luz deixou a disciplina há 60 dias (último dia) e a Clara Dias assumiu desde 59 dias atrás. O histórico fica.
- **Hugo Lemos** foi transferido da 1A para a 2B: esteve na 1A até 31 dias atrás e está na 2B desde 30 dias atrás.
- **Correção depois do fechamento:** a Prova 1 do Gui Pacheco passa de 5 para **6**, com a justificativa «Erro na soma da prova». Guarde a nota anterior.

### Entrada 4 — Mais notas e aulas, e uma matrícula nova

| Avaliação | Oferta | Bimestre | Peso | Notas |
|---|---|---|---|---|
| Prova de Matemática 1 | Matemática da 1A | 1º | 1 | Fábia 9, Gui 3, Hugo 6 |
| Prova de Português 3 | Português da 2B | 3º | 1 | Íris 10, Hugo 7 |

**Aulas de Matemática da 1A**, dadas pelo Dario Luz às 09:00, 100 e 99 dias atrás (sem chamada).

**Jota Maciel:** matrícula feita ontem na turma 3C.

### Entrada 5 — Correção

A matrícula do **Jota Maciel** foi feita **por engano**. Apague a matrícula **e tudo o que pertence a ela**. O Jota continua cadastrado como aluno.

## O que sai

Todas as consultas valem para o banco **depois das 5 entradas**.

| # | Pergunta | O que sai |
|---|---|---|
| C1 | Quantos alunos, matrículas, turmas e disciplinas dadas em turmas (ofertas) existem? | 5 alunos, 4 matrículas, 3 turmas, 3 ofertas |
| C2 | Qual a turma atual de cada aluno? Aluno sem matrícula aparece sem turma. | Fábia 1A · Gui 1A · Hugo 2B · Íris 2B · Jota sem turma |
| C3 | Qual o histórico de turmas do Hugo Lemos? | 1A, de 200 dias atrás até 31 dias atrás · 2B, desde 30 dias atrás (turma atual) |
| C4 | Quem deu Matemática na 1A e em que período? | Dario Luz, de 200 dias atrás até 60 dias atrás · Clara Dias, desde 59 dias atrás (atual) |
| C5 | Em Português da 1A, qual a média ponderada de cada aluno no 1º bimestre (só entram as notas lançadas)? | Fábia 7,33 · Gui 6,33 · Hugo 9,00 |
| C6 | Quais alunos têm o 1º bimestre de Português da 1A incompleto (falta nota de alguma avaliação)? | Hugo Lemos, faltando 1 avaliação |
| C7 | Em Português da 1A, qual a média anual parcial (média simples dos bimestres 1 e 2) dos alunos com os dois bimestres completos? | Fábia 7,42 · Gui 5,92 |
| C8 | Em Português, qual a frequência de cada aluno (presentes ÷ aulas contadas, sem as faltas justificadas)? | Fábia 80% · Gui 40% · Hugo 100% |
| C9 | Qual a situação de cada aluno com os dois bimestres completos em Português da 1A? (aprovado: média 6 ou mais e frequência 75% ou mais; recuperação: média de 4 a 5,9 com frequência suficiente; reprovado: média abaixo de 4 ou frequência abaixo de 75%) | Fábia: média 7,42, frequência 80%, aprovada · Gui: média 5,92, frequência 40%, reprovado |
| C10 | Quais alunos estão em risco por frequência abaixo de 75% em Português? | Gui Pacheco (só ele) |
| C11 | Qual nota foi corrigida? Mostre aluno, avaliação, nota antes, nota depois e a justificativa. | Gui Pacheco, Prova 1, 5,00 → 6,00, «Erro na soma da prova» |
| C12 | Quais disciplinas ninguém dá e quais professores não têm nenhuma disciplina atribuída? | Disciplina História · professor Elis Mota |
| C13 | Quantas aulas cada professor deu? **Todo professor aparece.** | Clara Dias 5 · Dario Luz 2 · Elis Mota 0 |
| C14 | Quais alunos não têm matrícula neste ano? | Jota Maciel (só ele) |
| C15 | Quantos alunos há hoje em cada turma? **Toda turma aparece.** | 1A 2 · 2B 2 · 3C 0 |
| C16 | Em Português da 1A, quantas avaliações e qual a soma dos pesos em cada bimestre? | 1º bimestre: 2 avaliações, soma dos pesos 3 · 2º bimestre: 2 avaliações, soma 4 |

## Testes de recusa

Estes três comandos **precisam dar erro**. Se o banco aceitar, falta uma regra na estrutura (se não souber como criá-la, anote como
achado). Copie a mensagem de erro de cada um no `achados.md`.

| # | Tente | O que sai |
|---|---|---|
| R1 | Lançar uma nota para uma matrícula que não existe | Erro de chave estrangeira (FK) |
| R2 | Mudar a Prova 2 da Fábia Teles para a nota 11 | Erro: a nota vai de 0 a 10 |
| R3 | A Clara Dias dar uma segunda aula no mesmo dia e horário (50 dias atrás, às 08:00) | Erro: um professor não pode ter duas aulas no mesmo dia e horário |

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

- A **turma** do aluno está na matrícula ou numa tabela à parte (C2, C3)? Uma transferência no meio do ano apaga a turma antiga ou guarda o histórico?
- O **professor** da disciplina (C4) tem período? Trocar de professor apaga o anterior?
- A média do bimestre (C5) usa os **pesos** de cada avaliação? A avaliação sem nota entra como zero ou fica de fora (C6)?
- A **falta justificada** fica fora da conta da frequência (C8)? Onde ficou guardada a situação de cada aluno em cada aula?
- A nota corrigida (C11) guarda a nota anterior e a justificativa? Onde?
- Uma disciplina sem oferta, um professor sem aula e uma turma sem alunos sumiram do resultado (C12, C13, C15)? Isso costuma ser `JOIN` no lugar de `LEFT JOIN`.
- A frequência e a média anual (C7, C9) são guardadas ou calculadas? Se são guardadas, ficaram certas depois da correção da nota?
- Faltou algum lugar para guardar uma informação do pedido?

