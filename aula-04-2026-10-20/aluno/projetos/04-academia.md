# Projeto 4 — Academia

Estrutura comum das entregas (GitHub, tags, notas): [00-estrutura-das-entregas.md](00-estrutura-das-entregas.md).
Projetos de referência já detalhados: [01-biblioteca.md](01-biblioteca.md) e [02-clinica-medica.md](02-clinica-medica.md).

## Cenário

Uma academia oferece **musculação e aulas coletivas** (spinning, funcional, yoga). Os alunos se matriculam em **planos**,
pagam **mensalidades**, entram pela **catraca** e reservam **vagas nas aulas coletivas**, que têm lotação. A academia quer
controlar matrículas, cobrança, frequência e a ocupação das turmas. Todos os dados do projeto são **fictícios**.

## Solicitação do usuário

**Solicitante:** Paulo, gerente de uma academia de médio porte. Leia o relato como se ele tivesse chamado você para
fazer o sistema. O que ele não explicou, você pergunta ao professor (ele faz o papel do Paulo). A modelagem é sua.

### O relato do Paulo

> Temos musculação e aulas coletivas (spinning, funcional, yoga). Hoje a matrícula e a cobrança estão em planilha, a
> catraca é de um fornecedor que só me entrega um arquivo, e as reservas de aula são por WhatsApp.
>
> **Meu dia começa** vendo quem está com mensalidade em atraso e quem vence hoje. Depois confiro as aulas do dia e as
> vagas.
>
> **Planos:** básico (só musculação) e completo (musculação e aulas coletivas), cada um mensal, trimestral ou anual. Os
> valores sobem de tempos em tempos e preciso saber o que cada aluno pagava na época.
>
> **Matrícula:** tem início, fim e situação (ativa, trancada, vencida, cancelada). O aluno pode trancar até 30 dias por
> ano, e o tempo trancado é somado ao fim da matrícula. Se o aluno volta meses depois, faço uma nova matrícula.
>
> **Mensalidade:** uma por mês, com vencimento no dia que o aluno escolhe. Pagou depois, tem multa de 2% mais juros de
> 0,033% ao dia. Com **mais de 15 dias de atraso o aluno não passa na catraca**.
>
> **Aula coletiva:** cada turma tem modalidade, instrutor, dia e horário e uma lotação. O aluno reserva a vaga (só plano
> completo). Sem vaga, entra na lista de espera, na ordem. Cancela até 2 horas antes. Quem falta 3 vezes no mês sem
> cancelar fica sem reservar até o mês seguinte.
>
> **Avaliação física:** peso, altura e medidas, no máximo a cada 90 dias. Quero o IMC (índice de massa corporal) calculado.
> Cada instrutor tem um CREF (registro profissional) e pode dar mais de uma modalidade.

### Minhas dificuldades hoje

1. **Inadimplência:** não sei, de cara, quem está atrasado e há quantos dias. Cobro por telefone. Queria **aviso por
   e-mail e WhatsApp** na véspera do vencimento e após o atraso, com registro de quem já foi avisado.
2. **Lotação** das aulas: ora lotada, ora vazia, e não sei os horários que valem a pena.
3. Não sei **quem está dentro da academia agora**.
4. O reajuste de planos bagunça os valores antigos.
5. Quero saber **quais alunos não aparecem** há semanas (risco de cancelamento).

### O que quero ver quando abrir o sistema

- **Mensalidades vencidas** e há quantos dias, com valor atualizado (multa e juros).
- **Vagas** de cada aula do dia e a lista de espera.
- Quem está **bloqueado** na catraca.
- Alunos **sem frequência** nos últimos 30 dias.
- **Quantidade de matrículas** ativas por plano.

### O que guardo hoje

| Onde | O que tem |
|---|---|
| Planilha de alunos | nome, CPF, telefone, e-mail, plano, início |
| Planilha de mensalidades | aluno, mês, vencimento, valor, pago em |
| Arquivo da catraca | aluno, data e hora de entrada e saída |
| WhatsApp | reservas de aula |

### Perguntas para fazer ao Paulo

- Quando o aluno muda de plano no meio do contrato, o que acontece com as mensalidades?
- O que acontece com a mensalidade no período em que a matrícula está trancada?
- Um instrutor pode dar duas turmas no mesmo horário?
- Avaliação física é feita pelo mesmo instrutor da turma?

> O envio real de e-mail e WhatsApp é feito por outro sistema. **O banco de dados guarda o que precisa ser avisado e o que
> já foi avisado.**

## Regras de negócio

| Regra | Valor |
|---|---|
| Planos | Básico (só musculação) e completo (musculação e aulas coletivas), cada um mensal, trimestral ou anual. O **valor muda com o tempo** e o histórico deve ser preservado |
| Matrícula | Tem início, fim e status: ativa, trancada, vencida, cancelada. O aluno pode voltar depois com uma nova matrícula |
| Trancamento | Até 30 dias por ano de matrícula; o prazo da matrícula é estendido pelos dias trancados. **Regra descrita**: o status `trancada` é um dado; o grupo não cria rotina de trancamento (D-25) |
| Mensalidade | Uma por mês, com vencimento no dia escolhido pelo aluno. Pagamento depois do vencimento paga **multa de 2%** mais **juros de 0,033% ao dia** |
| Bloqueio | Aluno com mensalidade em atraso há mais de **15 dias** não passa na catraca |
| Acesso | A entrada só é registrada com matrícula ativa e sem bloqueio. A saída pode ficar em aberto |
| Aula coletiva | A turma tem modalidade, instrutor, dia e horário na semana e **capacidade** de vagas |
| Reserva | Por data da aula. Sem vaga, o aluno entra na **lista de espera**, por ordem de pedido. Só o plano completo reserva |
| Cancelar reserva | Até 2 horas antes da aula. Quem falta sem cancelar 3 vezes no mês fica **suspenso de reservas** até o mês seguinte. **Regra descrita**: o grupo não cria rotina de suspensão (D-25) |
| Avaliação física | Peso, altura e medidas, no máximo a cada 90 dias. O IMC é calculado a partir do peso e da altura |
| Instrutor | Tem CREF único e pode dar mais de uma modalidade |

## Modelo mínimo (a decidir pelo grupo; pelo menos 8 tabelas)

Plano, preço do plano (com vigência), modalidade, plano-modalidade, aluno, matrícula, mensalidade, pagamento, instrutor,
turma, reserva de aula, acesso (catraca), avaliação física. O grupo decide e **justifica** o desenho.

**Pontos que exigem decisão** (a prova cobra a justificativa):

1. O valor do plano muda: gravar o valor na matrícula, consultar o histórico do plano na data, ou os dois?
2. Aluno x matrícula: uma tabela ou duas? O que acontece quando o aluno volta depois de meses?
3. Mensalidades: gerar todas na matrícula ou mês a mês? E se a matrícula for trancada ou cancelada no meio?
4. Vagas da turma: contar as reservas confirmadas ou manter uma coluna `vagas_ocupadas`? Como representar a ordem da lista de espera?
5. Inadimplência: gravar o status do aluno ou calculá-lo a partir das mensalidades?
6. Acesso: um registro com entrada e saída ou dois registros? Como achar quem está dentro da academia agora?

## Dados de apoio

- Coluna `dados_avaliacao` (`JSONB`) na avaliação física: medidas (peito, cintura, quadril, braços), lesões, objetivos e
  observações do instrutor, que variam de aluno para aluno.
- Número da matrícula no formato `AC-000123`, gerado com `LPAD`.

## Entrega 1 — Prova 1 (aula 12): modelo, DDL, carga e transações

Tag: `prova-1`. As transações são dadas na aula 11, um dia antes: a entrega é pequena e guiada pelo exercício do dia.

| # | Item | Arquivo | O que entregar |
|---|---|---|---|
| 1 | Modelo | `diagrama/` | Diagrama no ERD Concepts (conceitual e lógico) com cardinalidades, e a imagem exportada |
| 2 | Estrutura | `sql/01_ddl.sql` | Schema `academia`, 8 ou mais tabelas, `PK`, `FK`, `UNIQUE`, `CHECK` e `DEFAULT` para as regras que o banco consegue garantir (fim da matrícula depois do início, capacidade positiva, uma reserva por aluno, turma e data) |
| 3 | Normalização | `README.md` | Justificar até a 3FN e dizer uma desnormalização feita de propósito, se houver |
| 4 | Carga | `sql/02_carga.sql` | 3 planos com mais de um preço ao longo do tempo, 5 modalidades, 6 instrutores, 12 turmas, 50 alunos, 60 matrículas (ativas, trancadas, vencidas e canceladas), 6 meses de mensalidades (em dia e em atraso), 500 acessos, 150 reservas com lista de espera, 40 avaliações físicas. Dados que **exercitam as regras** (aluno com atraso de 16 dias, turma lotada, aluno com 3 faltas no mês) |
| 5 | Transações | `sql/03_transacoes.sql` | Matrícula como transação (criar a matrícula, gerar a primeira mensalidade e registrar o pagamento, tudo ou nada), com `ROLLBACK` quando falhar |
| 6 | Concorrência | `sql/03_transacoes.sql` + `evidencias/` | **Duas sessões reservando a última vaga da mesma turma na mesma data**: mostrar o problema (lotação ultrapassada), a solução (bloqueio de linha ou isolamento) e explicar por quê |
| 7 | Decisões | `README.md` | As respostas dos 6 pontos de decisão acima, por que a transação protege o que protege, divisão do trabalho e uso de IA |

Dado na aula: modelagem (9), análise de bancos (10), transações e ACID (11), DDL e normalização (revisão, aulas 2 e 3).

## Entrega 2 — Prova 2 (aula 16): funções SQL, subconsultas/CTE, `JSONB`, window functions e views

Tag: `prova-2`.

| # | Item | Arquivo | O que entregar |
|---|---|---|---|
| 1 | Funções SQL | `sql/04_consultas.sql` | 10 consultas, entre elas: matrícula com `LPAD`, nome do aluno formatado, vencimento da mensalidade (`data + intervalo`), dias de atraso e multa com juros (`ROUND`), idade do aluno (`AGE`), mensalidades por mês (`DATE_TRUNC`), dia da semana mais movimentado (`EXTRACT` ou `TO_CHAR`), IMC (`ROUND`), situação da mensalidade (`CASE`: em dia, vence em 7 dias, vencida), `COALESCE` para saída em aberto na catraca |
| 2 | Subconsultas e CTE | `sql/04_consultas.sql` | 3 ou mais: alunos sem acesso nos últimos 30 dias (risco de evasão), alunos com mais atraso que a média, taxa de ocupação por turma feita com CTE em etapas |
| 3 | `JSONB` | `sql/04_consultas.sql` | 3 consultas sobre `dados_avaliacao` (alunos com lesão registrada, cintura acima de um valor, listar os objetivos) |
| 4 | Window functions | `sql/05_janelas_views.sql` | 2 consultas: turmas com mais presença por modalidade (`RANK`) e receita acumulada por mês |
| 5 | Views | `sql/05_janelas_views.sql` | `vw_alunos_inadimplentes` e uma view materializada com frequência mensal por modalidade, com atualização |
| 6 | Decisões | `README.md` | Decisões, o que a IA errou, divisão do trabalho |

Dado na aula: funções SQL (13), subconsultas, CTE e `JSONB` (14), window functions e views (15).

## Entrega 3 — Prova 3 (aula 21): índice, funções, procedures e triggers

Tag: `prova-3`. Com o bloco de `PL/pgSQL` em três dias (aulas 18 a 20, com 40 min de projeto por dia), a entrega pede
**mais rotinas e testadas**, e a parte de índice segue enxuta.

| # | Item | Arquivo | O que entregar |
|---|---|---|---|
| 1 | Índice | `sql/06_indices.sql` + `evidencias/` | Carga em volume (100 mil acessos ou mais, com `generate_series`), **1 consulta lenta** (acessos de um aluno em um período), `EXPLAIN` antes e depois do índice e explicação |
| 2 | Funções | `sql/07_funcoes.sql` | 3 ou mais: `calcular_encargos(mensalidade, data)` (multa e juros), `aluno_pode_entrar(aluno)` (matrícula ativa e atraso até 15 dias, retornando o motivo) e `vagas_disponiveis(turma, data)`. Cada uma com chamada de teste e resultado em `evidencias/` |
| 3 | Procedures | `sql/08_procedures.sql` | 3: `matricular_aluno(aluno, plano)` (cria a matrícula e as mensalidades), `reservar_aula(aluno, turma, data)` (plano completo, vaga ou lista de espera) e `registrar_pagamento(mensalidade, valor)` (aplica os encargos e baixa a mensalidade). Erros com `RAISE EXCEPTION` e mensagens claras, cada uma com um teste que dá certo e um que falha |
| 4 | Triggers | `sql/09_triggers.sql` | 2: **auditoria** das mudanças de status da matrícula (quem, quando, antes e depois) e **regra de negócio** (ao cancelar uma reserva, o primeiro da lista de espera é promovido), com um teste de cada |
| 5 | Decisões | `README.md` | Onde cada regra ficou (função, procedure, trigger ou `CHECK`) e por quê, divisão do trabalho, uso de IA |

Dado na aula: índices e `generate_series` (17), funções (18), procedures (19), triggers (20).

## Entrega final — Prova 4 (aulas 23 e 24): apresentação

Tag: `final`.

- **Demonstração (6 min):** um cenário de ponta a ponta: o aluno se matricula, a catraca libera a entrada, a turma lota e o
  próximo aluno vai para a lista de espera, uma reserva é cancelada e a lista anda, uma mensalidade atrasada é paga com
  encargos e o relatório mostra os inadimplentes. Executado ao vivo por uma procedure.
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

- O ponto forte é a **vaga limitada**: lotação sob concorrência (prova 1) e **lista de espera** promovida por trigger (prova 3).
- A **cobrança com encargos** (multa e juros por dia) dá muito uso a `ROUND`, datas e intervalos (prova 2) e à função
  `calcular_encargos` (prova 3).
- A regra de **quem pode entrar** combina matrícula, trancamento e atraso, boa para uma função que devolve o motivo.
- O `JSONB` guarda as medidas e observações da avaliação física, que variam de aluno para aluno.
