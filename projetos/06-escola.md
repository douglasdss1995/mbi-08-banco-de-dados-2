# Projeto 6 — Escola (notas e frequência)

Estrutura comum das entregas (GitHub, tags, notas): [00-estrutura-das-entregas.md](00-estrutura-das-entregas.md).
Projetos de referência já detalhados: [01-biblioteca.md](01-biblioteca.md) e [02-clinica-medica.md](02-clinica-medica.md).

## Cenário

Uma escola de ensino médio técnico organiza o ano letivo em **turmas, disciplinas e bimestres**. Os professores lançam
**notas** e fazem a **chamada** a cada aula; a secretaria fecha o bimestre e emite o **boletim**. A escola quer calcular
médias, frequência e a situação final de cada aluno, e saber quem está em risco de reprovação. Todos os dados do projeto são
**fictícios**.

## Solicitação do usuário

**Solicitante:** Sônia, secretária acadêmica de uma escola de ensino médio técnico. Leia o relato como se ela tivesse
chamado você para fazer o sistema. O que ela não explicou, você pergunta ao professor (ele faz o papel da Sônia). A
modelagem é sua.

### O relato da Sônia

> Cuido da secretaria há dez anos. Os professores me entregam notas e listas de chamada em papel ou em planilha, e eu
> junto tudo para fazer o boletim. No fim do bimestre é uma correria.
>
> **Meu dia começa** vendo quais professores ainda não lançaram nota ou chamada. Depois atendo alunos e responsáveis.
>
> **Estrutura:** o ano tem 4 bimestres. A turma é de uma série, um turno e um ano. Cada disciplina da turma tem um
> professor e um número de aulas por semana. O professor pode mudar no meio do ano, e preciso saber quem deu cada
> disciplina em cada período. O aluno tem uma matrícula por ano e às vezes é transferido de turma.
>
> **Notas:** cada disciplina tem avaliações por bimestre (prova, trabalho, participação), cada uma com um peso, e a nota
> vai de 0 a 10. A média do bimestre é ponderada. Se falta nota, o bimestre fica "incompleto". A média anual é a média
> simples dos 4 bimestres.
>
> **Chamada:** uma por aula. Cada aluno fica presente, ausente ou com falta justificada. A falta justificada não conta na
> frequência. A frequência é calculada por disciplina.
>
> **Situação final:** média anual de 6,0 ou mais e frequência de 75% ou mais, aprovado. Média de 4,0 a 5,9 com frequência
> suficiente, recuperação final. Abaixo de 4,0 ou frequência abaixo de 75%, reprovado.
>
> **Prazo:** o professor lança até 15 dias depois do fim do bimestre. Depois disso, só eu corrijo, e registro o motivo. Fechado
> o bimestre, as notas não mudam sem justificativa. Um professor não pode ter duas aulas no mesmo dia e horário.

### Minhas dificuldades hoje

1. **Quem está em risco de reprovar** (nota ou frequência): só descubro tarde. Queria avisar o responsável por e-mail e
   WhatsApp, com registro do aviso.
2. Professores que **não lançaram** nota ou chamada no prazo.
3. Calcular média ponderada e frequência na mão, com erros.
4. **Correção de nota**: preciso saber quem corrigiu, quando e por quê.
5. Quando o aluno é transferido, o histórico fica espalhado.

### O que quero ver quando abrir o sistema

- O **boletim** de cada aluno, com a média de cada bimestre.
- A **frequência** por aluno e por disciplina.
- Alunos **em risco** de reprovação.
- Professores com **lançamentos pendentes**.
- O **histórico de correções** de uma nota.

### O que guardo hoje

| Onde | O que tem |
|---|---|
| Planilha de alunos | nome, matrícula, turma, responsáveis, telefone |
| Planilhas dos professores | avaliações e notas por turma |
| Listas de chamada em papel | data, aula, presentes e ausentes |
| Caderno da secretaria | correções de nota |

### Perguntas para fazer à Sônia

- Se uma nota for corrigida depois do fechamento, a média do bimestre é recalculada?
- O peso das avaliações pode mudar no meio do bimestre?
- Aluno transferido leva as notas já lançadas?
- Recuperação final entra no sistema ou fica fora por enquanto?

> O envio real de e-mail e WhatsApp é feito por outro sistema. **O banco de dados guarda o que precisa ser avisado e o que
> já foi avisado.**

## Regras de negócio

| Regra | Valor |
|---|---|
| Ano letivo | 4 bimestres. A turma é de uma série, um turno e um ano letivo |
| Disciplinas da turma | Cada disciplina da turma tem um professor e um número de aulas por semana. O professor pode mudar no meio do ano e o histórico deve ser preservado |
| Matrícula | O aluno tem uma matrícula por ano letivo, em uma turma. Pode ser **transferido** de turma durante o ano |
| Avaliação | Cada disciplina tem, por bimestre, avaliações com **peso** (prova, trabalho, participação). Nota de 0 a 10 |
| Média do bimestre | Média ponderada pelos pesos das avaliações. Avaliação sem nota lançada não entra na conta e o bimestre fica "incompleto" |
| Média anual | Média simples dos 4 bimestres |
| Situação final | Média anual **≥ 6,0** e frequência **≥ 75%**: aprovado. Média de 4,0 a 5,9 com frequência suficiente: recuperação final. Abaixo de 4,0 ou frequência abaixo de 75%: reprovado |
| Recuperação final | A nova média é a média entre a média anual e a nota da recuperação; precisa de **5,0 ou mais** para aprovar. **Regra escrita**: não entra no modelo nem nas rotinas; `situacao_final` só devolve "recuperação" (D-28) |
| Chamada | Uma por aula (turma, disciplina, data e horário). Cada aluno fica presente, ausente ou com falta justificada. **Falta justificada não conta** no cálculo da frequência |
| Frequência | Calculada por disciplina: aulas presentes ÷ aulas dadas (justificadas fora da conta) |
| Prazo de lançamento | O professor lança nota e frequência até **15 dias** depois do fim do bimestre. Depois, só a secretaria corrige, com justificativa registrada |
| Fechamento | Fechado o bimestre, as médias são gravadas e as notas não podem mais ser alteradas sem justificativa |
| Grade | O professor não pode ter duas aulas no mesmo dia e horário |

## Modelo mínimo (a decidir pelo grupo; pelo menos 8 tabelas)

Aluno, turma, matrícula, disciplina, professor, oferta da disciplina na turma (disciplina + turma + professor), bimestre,
avaliação, nota, aula (chamada), frequência, resultado do bimestre, histórico de correção de nota. O grupo decide e
**justifica** o desenho.

**Pontos que exigem decisão** (a prova cobra a justificativa):

1. Aluno x matrícula x turma: o que fica no aluno (permanente) e o que fica na matrícula (do ano)? Como representar a transferência de turma?
2. Média do bimestre: guardar o valor calculado no fechamento ou calcular sempre? E se uma nota for corrigida depois do fechamento?
3. Frequência: gravar uma linha por aluno por aula (presença e falta) ou só as faltas? O que cada escolha custa em volume e em consulta?
4. O professor da disciplina muda no meio do ano: onde fica o professor, na disciplina, na oferta da turma ou na aula dada?
5. Peso das avaliações: no cadastro da avaliação ou numa regra geral da disciplina? E se o peso mudar?
6. Correção de nota: sobrescrever ou manter o histórico? Quem corrigiu, quando e por quê?

## Dados de apoio

- Coluna `ficha` (`JSONB`) no aluno: responsáveis (lista de nome e telefone), restrições médicas, uso de transporte escolar,
  necessidades de atendimento e contatos de emergência. Cada aluno tem campos diferentes.
- Número da matrícula no formato `MT-2026-000123`, gerado com `LPAD`.

## Entrega 1 — Prova 1 (aula 12): modelo, DDL, carga e transações

Tag: `prova-1`. As transações são dadas na aula 11, um dia antes: a entrega é pequena e guiada pelo exercício do dia.

| # | Item | Arquivo | O que entregar |
|---|---|---|---|
| 1 | Modelo | `diagrama/` | Diagrama no ERD Concepts (conceitual e lógico) com cardinalidades, e a imagem exportada |
| 2 | Estrutura | `sql/01_ddl.sql` | Schema `escola`, 8 ou mais tabelas, `PK`, `FK`, `UNIQUE`, `CHECK` e `DEFAULT` para as regras que o banco consegue garantir (nota de 0 a 10, peso positivo, uma matrícula por aluno e ano, uma frequência por aluno e aula, status válidos) |
| 3 | Normalização | `README.md` | Justificar até a 3FN e dizer uma desnormalização feita de propósito, se houver |
| 4 | Carga | `sql/02_carga.sql` | 12 disciplinas, 10 professores, 4 turmas, 60 alunos, 4 bimestres, 80 avaliações com notas, 300 aulas com chamada (frequência) e resultados de bimestres fechados. Dados que **exercitam as regras** (aluno com 74% de frequência, aluno com média 5,9, bimestre incompleto, nota corrigida com justificativa, aluno transferido de turma) |
| 5 | Transações | `sql/03_transacoes.sql` | Matrícula como transação (criar a matrícula, vincular o aluno às disciplinas da turma e criar o resultado de cada disciplina, tudo ou nada), com `ROLLBACK` quando falhar |
| 6 | Concorrência | `sql/03_transacoes.sql` + `evidencias/` | **Duas sessões ao mesmo tempo: o professor corrige uma nota enquanto a secretaria fecha o bimestre**: mostrar o problema (média gravada com a nota antiga), a solução (bloqueio de linha ou isolamento) e explicar por quê |
| 7 | Decisões | `README.md` | As respostas dos 6 pontos de decisão acima, por que a transação protege o que protege, divisão do trabalho e uso de IA |

Dado na aula: modelagem (9), análise de bancos (10), transações e ACID (11), DDL e normalização (revisão, aulas 2 e 3).

## Entrega 2 — Prova 2 (aula 16): funções SQL, subconsultas/CTE, `JSONB`, window functions e views

Tag: `prova-2`.

| # | Item | Arquivo | O que entregar |
|---|---|---|---|
| 1 | Funções SQL | `sql/04_consultas.sql` | 10 consultas, entre elas: matrícula com `LPAD`, nome do aluno formatado (`INITCAP`, `CONCAT`), idade (`AGE`), média ponderada do bimestre (`ROUND`), percentual de frequência (`ROUND`), situação (`CASE`: aprovado, recuperação, reprovado), `COALESCE` para "nota não lançada", avaliações por mês (`DATE_TRUNC`), dia da semana com mais faltas (`TO_CHAR`), aniversariantes do mês (`EXTRACT`) |
| 2 | Subconsultas e CTE | `sql/04_consultas.sql` | 3 ou mais: alunos com média abaixo da média da turma, disciplinas sem nenhuma nota lançada no bimestre, alunos em risco de reprovação por falta feito com CTE em etapas (aulas dadas, faltas, percentual) |
| 3 | `JSONB` | `sql/04_consultas.sql` | 3 consultas sobre `ficha` (alunos com restrição médica, alunos que usam transporte escolar, listar os telefones dos responsáveis) |
| 4 | Window functions | `sql/05_janelas_views.sql` | 2 consultas: ranking de alunos por turma pela média (`RANK`) e evolução da média por bimestre comparada à do bimestre anterior (`LAG`) |
| 5 | Views | `sql/05_janelas_views.sql` | `vw_boletim` (aluno, disciplina, médias, frequência e situação) e uma view materializada com média e frequência por turma e disciplina, com atualização |
| 6 | Decisões | `README.md` | Decisões, o que a IA errou, divisão do trabalho |

Dado na aula: funções SQL (13), subconsultas, CTE e `JSONB` (14), window functions e views (15).

## Entrega 3 — Prova 3 (aula 21): índice, funções, procedures e triggers

Tag: `prova-3`. Com o bloco de `PL/pgSQL` em três dias (aulas 18 a 20, com 40 min de projeto por dia), a entrega pede
**mais rotinas e testadas**, e a parte de índice segue enxuta.

| # | Item | Arquivo | O que entregar |
|---|---|---|---|
| 1 | Índice | `sql/06_indices.sql` + `evidencias/` | Carga em volume (200 mil registros de frequência ou mais, com `generate_series`), **1 consulta lenta** (faltas de um aluno em um período), `EXPLAIN` antes e depois do índice e explicação |
| 2 | Funções | `sql/07_funcoes.sql` | 3 ou mais: `calcular_media(aluno, disciplina, bimestre)` (média ponderada), `calcular_frequencia(aluno, disciplina)` e `situacao_final(aluno, disciplina)` (aprovado, recuperação ou reprovado, retornando o motivo). Cada uma com chamada de teste e resultado em `evidencias/` |
| 3 | Procedures | `sql/08_procedures.sql` | 3: `lancar_nota(avaliacao, aluno, nota)` (nota de 0 a 10, professor da disciplina, prazo do bimestre), `registrar_chamada(turma, disciplina, data, aluno, situacao)` (uma chamada por aluno e por aula; presente, ausente ou falta justificada) e `fechar_bimestre(turma, bimestre)` (calcula e grava as médias, trava os lançamentos). Erros com `RAISE EXCEPTION` e mensagens claras, cada uma com um teste que dá certo e um que falha |
| 4 | Triggers | `sql/09_triggers.sql` | 2: **auditoria** das notas (quem, quando, antes e depois, com a justificativa) e **regra de negócio** (ao registrar uma falta que leva a frequência abaixo de 75%, gerar um alerta de risco), com um teste de cada |
| 5 | Decisões | `README.md` | Onde cada regra ficou (função, procedure, trigger ou `CHECK`) e por quê, divisão do trabalho, uso de IA |

Dado na aula: índices e `generate_series` (17), funções (18), procedures (19), triggers (20).

## Entrega final — Prova 4 (aulas 23 e 24): apresentação

Tag: `final`.

- **Demonstração (6 min):** um cenário de ponta a ponta: o aluno é matriculado, o professor faz a chamada e lança notas, uma
  falta leva o aluno abaixo de 75% e o alerta é gerado, o professor tenta lançar fora do prazo e é recusado, a secretaria
  fecha o bimestre e o boletim mostra a situação de cada aluno. Executado ao vivo por uma procedure.
- **Desenvolvimento do projeto (4 min):** linha do tempo, decisões difíceis, dificuldades, o que a IA errou e o que o grupo aprendeu.
- **Entrega:** repositório com `instalar.sql` que recria o banco do zero e `README.md` final.

## Rubrica (parte do grupo, 10 pontos por prova)

| Prova | Item | Pontos |
|---|---|---|
| 1 | Modelo e justificativas (itens 1, 3 e 7) | 3,0 |
| 1 | DDL com regras no banco (item 2) | 2,5 |
| 1 | Carga que exercita as regras (item 4) | 1,5 |
| 1 | Transação e concorrência, com explicação (itens 5 e 6) | 3,0 |
| 2 | Funções SQL (item 1) | 2,5 |
| 2 | Subconsultas e CTE (item 2) | 2,0 |
| 2 | `JSONB` (item 3) | 1,0 |
| 2 | Window functions e views (itens 4 e 5) | 3,0 |
| 2 | Decisões e uso de IA (item 6) | 1,5 |
| 3 | Índice com `EXPLAIN` e análise (item 1) | 2,0 |
| 3 | Funções (item 2) | 2,0 |
| 3 | Procedures (item 3) | 2,0 |
| 3 | Triggers (item 4) | 2,5 |
| 3 | Decisões e uso de IA (item 5) | 1,5 |
| 4 | Demonstração: cenário de ponta a ponta, regras de negócio funcionando ao vivo | 4,0 |
| 4 | Desenvolvimento do projeto: linha do tempo, decisões e dificuldades | 2,5 |
| 4 | Uso de IA: o que a IA errou e o que o grupo corrigiu | 1,5 |
| 4 | Entrega: `instalar.sql` que recria o banco do zero, `README.md` e divisão do trabalho | 2,0 |

Penalidade: entrega que não roda do zero, sem `README.md` ou sem divisão do trabalho perde até 2 pontos.
Na prova 4 não há penalidade à parte: o critério «Entrega» já cobre `instalar.sql`, `README.md` e divisão do trabalho. As perguntas do professor entram na parte individual (40%).
A nota do aluno é 60% desta parte (grupo) e 40% individual (20% a parte apresentada e 20% a pergunta individual, D-36).

## Diferenças em relação aos projetos anteriores

- O ponto forte é a **regra de cálculo com limites** (média ponderada, 75% de frequência, recuperação): rende muito
  `CASE`, `ROUND` e a função `situacao_final` com motivo.
- A **frequência é o maior volume** do projeto (uma linha por aluno por aula), o que torna o índice da prova 3 natural.
- A **auditoria de nota** é central: correção depois do fechamento exige justificativa e histórico.
- O `JSONB` guarda a ficha do aluno (responsáveis, restrições, transporte), que varia de aluno para aluno.
