# Aula 05 — 21/10/2026 (quarta-feira)

Tipo: Modelagem (continuação da aula 4) · 3 h · Status: **rascunho**

**Tema:** Fechar o modelo do projeto: apresentações na frente, correção coletiva e a «estrutura» que a turma foi construindo

> A data é a de hoje (quarta, 3 h, aula às 09:00). O calendário dos docs ainda é o antigo e será refeito no replanejamento
> (T-21). Se a aula for em outro dia, renomeie a pasta.

## De onde viemos (aula 4)

Na aula 4 os alunos leram a solicitação do cliente do seu projeto, fizeram perguntas ao professor e passaram a aula inteira
desenhando o modelo. Depois do intervalo, alguns foram à frente apresentar o modelo e foram corrigidos com o professor. As
correções feitas na frente deixaram **uma estrutura** que serve a todos: os mesmos erros e as mesmas boas decisões aparecem
em projetos diferentes. Hoje essa estrutura vira um quadro da turma (o checklist) e todos terminam de apresentar e corrigir.

## Objetivos

- Fazer a **turma inteira** apresentar o modelo na frente e receber correção, até todos terem passado.
- Transformar as correções da aula 4 em um **checklist de modelagem** que vale para qualquer projeto.
- Cada aluno sai com o **modelo corrigido (v2)**: MER e dicionário de dados simples, prontos para virar `CREATE TABLE` na próxima aula.
- Praticar a ler o cliente: cada decisão do modelo precisa apontar para uma frase do relato.

## Roteiro

A aula começa às 09:00 (o 1º tempo é de outro professor).

| Horário | Atividade | Dinâmica |
|---|---|---|
| 08:00 – 09:00 | Aula de outro professor (sem aula desta disciplina) | |
| 09:00 | **1ª chamada** | |
| 09:00 – 09:20 | **Retomada e quadro da estrutura:** a turma diz o que aprendeu com as correções da aula 4. O professor monta no quadro o **checklist de modelagem** ([`../aluno/checklist-de-modelagem.md`](../aluno/checklist-de-modelagem.md)) com as respostas e completa com o que faltar | A turma fala; o professor organiza |
| 09:20 – 09:40 | **Rodada 1 das apresentações:** quem ainda não foi à frente apresenta (5 min cada: relato, tabelas, decisão difícil). A turma confere com o checklist e aponta falhas; o professor fecha com a correção (2 a 3 min) | Aluno na frente, turma ajuda |
| 09:40 – 10:00 | Intervalo | |
| 10:00 – 10:40 | **Rodada 2 das apresentações**, no mesmo formato. Quem já apresentou **corrige o próprio modelo** com o que ouviu e ajuda o colega de tema | Aluno na frente; os demais ajustam o modelo |
| 10:40 – 11:00 | **Tempo de projeto:** quem não apresentou apresenta ao professor na mesa; os demais passam o MER a limpo (v2) e começam o dicionário de dados simples | Individual, com o professor circulando |
| 11:00 – 11:30 | **Exercício «Modelo v2»:** terminar o dicionário de dados simples e o MER e entregar no Classroom ([`../aluno/exercicio.md`](../aluno/exercicio.md)) | Individual |
| 11:30 | **2ª chamada** · atendimento até 11:40 | |

## Como conduzir as apresentações

Com 24 alunos, 5 min de apresentação + 2 a 3 min de correção dá cerca de 8 min por pessoa. Em 60 min cabem **7 ou 8
alunos**. Por isso:

1. **Chame primeiro** quem não foi à frente na aula 4. Quem já foi só volta se houver tempo ou para mostrar uma mudança.
2. **Ordem por tema:** apresentar seguidos os alunos do mesmo tema deixa a turma comparar duas soluções para o mesmo cliente
   (essa é a melhor parte da dinâmica).
3. **O que o aluno mostra** (5 min): uma frase do relato; as tabelas e as ligações; **uma decisão difícil** e por que a tomou.
4. **A turma corrige antes do professor:** quem estiver sentado usa o checklist e levanta o que falta. O professor só
   fecha com a correção que a turma não achou. Isso exercita a leitura de modelos, que é o objetivo.
5. **Anote no quadro** cada erro novo e cada boa decisão. No fim, o quadro é a «estrutura» da turma.
6. **Quem não conseguir apresentar hoje** apresenta ao professor no tempo de projeto ou no início da próxima aula.

O guia do que esperar em cada projeto está em [`guia-de-correcao-dos-modelos.md`](guia-de-correcao-dos-modelos.md).

## Conteúdo (e o que fica para depois)

| Hoje | Fica para |
|---|---|
| Entidades, atributos, chaves e ligações (1:N e N:N) no MER, e o dicionário de dados simples | `CREATE TABLE`, tipos e `IDENTITY`: aula 6 |
| Histórico (vigência), valor da época, status e dado derivado: **decidir, não implementar** | Constraints (`CHECK`, `UNIQUE`, `ON DELETE`): depois do DDL |
| Ler o cliente: do relato à tabela | Regras de negócio em funções, procedures e triggers: etapa final do curso |

## Exercício

- «Modelo v2 e dicionário de dados simples». Enunciado: [`../aluno/exercicio.md`](../aluno/exercicio.md), com o modelo de preenchimento
  [`../aluno/dicionario-de-dados-simples.md`](../aluno/dicionario-de-dados-simples.md). Entrega no Classroom, **sem horário limite**.
- A entrega é o MER (imagem ou PDF) e o dicionário de dados simples preenchido em `.md`. Sem Word nem Excel (regra 15).
- Correção: o professor usa o [`guia-de-correcao-dos-modelos.md`](guia-de-correcao-dos-modelos.md) e devolve um comentário
  por aluno.

## Material

| Arquivo | Para quê | Estado |
|---|---|---|
| [`../aluno/checklist-de-modelagem.md`](../aluno/checklist-de-modelagem.md) | Checklist de modelagem da turma (a «estrutura»); a turma completa na aula | pronto |
| [`../aluno/dicionario-de-dados-simples.md`](../aluno/dicionario-de-dados-simples.md) | Modelo e exemplo: uma tabela por bloco, uma linha por campo (nome e explicação) | pronto |
| [`../aluno/exercicio.md`](../aluno/exercicio.md) | Exercício «Modelo v2 e dicionário de dados simples» | pronto |
| [`guia-de-correcao-dos-modelos.md`](guia-de-correcao-dos-modelos.md) | O que esperar e as armadilhas de cada um dos 10 projetos | pronto |

## Notas do professor

- Dados dos alunos e o sorteio: `aulas/aula-04-2026-10-20/aluno/sorteio-projetos-preenchido.md` (fora do remoto).
- Se a turma terminar cedo, use o tempo para a **tabela de tipos do PostgreSQL** (introdução da aula 6) ou para pedir o
  modelo a duas duplas de temas diferentes e comparar.
- Não mostre ainda o `dicionario-de-dados.md` de `projetos-referencia`: ele é a régua do professor. Pode ser mostrado
  **depois** da entrega do exercício, para o aluno comparar.
