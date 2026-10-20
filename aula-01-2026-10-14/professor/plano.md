# Aula 01 — 14/10/2026 (quarta-feira)

Semana do curso: 1 · Tipo: Revisão de BD1 · 3 h · Status: **rascunho**

**Tema:** Apresentação, regras, sorteio dos grupos e temas, verificação das ferramentas e ambiente (PostgreSQL + DBeaver)

## Objetivos

- Mostrar o que cada grupo vai construir e como o curso se organiza, antes das regras.
- Formar os grupos por sorteio e atribuir os temas dos projetos.
- Alinhar as regras do curso (exercícios, recuperação, provas, Classroom e IA) com participação dos alunos.
- Garantir que **todos os alunos tenham as ferramentas** funcionando (ou saibam o que falta instalar em casa).

## Roteiro

A aula começa às 09:00 (o 1º tempo é de outro professor). Não há correção de exercício neste primeiro dia.

| Horário | Atividade | Dinâmica |
|---|---|---|
| 08:00 – 09:00 | Aula de outro professor (sem aula desta disciplina) | |
| 09:00 | **1ª chamada** | |
| 09:00 – 09:10 | **Diagnóstico de BD1** (7 questões + 2 de autoavaliação), anônimo e sem nota | Google Forms sem login |
| 09:10 – 09:30 | **O que vamos construir**: produto final, linha do tempo, as 4 provas como entregas do projeto e os 10 temas (slides 1 a 5) | Exposição dialogada |
| 09:30 – 09:40 | **Sorteio** dos grupos (3 alunos) e dos temas dos projetos, pela planilha `sorteio-grupos.xlsx` | Sorteio ao vivo; dois alunos digitam os números do sorteio |
| 09:40 – 10:00 | Intervalo | |
| 10:00 – 10:15 | **Combinados** em grupo: cada grupo recebe um bloco das regras, lê em `combinados.md` e explica em 1 min; o professor corrige e completa | Metodologia ativa (doc 04 da raiz) |
| 10:15 – 10:50 | **Verificação das ferramentas** com o checklist (PostgreSQL, DBeaver ou DataGrip à escolha, ERD Concepts, Git, GitKraken, navegador, conta Google/Classroom) e instalação do que faltar; registrar quem ficou sem licença do DataGrip | Checklist individual; o professor circula; quem termina ajuda os colegas |
| 10:50 – 11:00 | **Repositório do grupo**: criar `bd2-grupo-NN-tema` no GitHub, adicionar o professor e fazer o primeiro commit; teste de conexão no cliente escolhido | Grupos |
| 11:00 | Exercício do assunto «Ambiente, modelo relacional e normalização»: **parte 1** (entrega prevista na aula 02, sem horário limite) | |
| 11:30 | **2ª chamada** · atendimento até 11:40 | |

## Blocos de combinados

Distribuir um bloco por grupo (com 10 grupos, dois grupos repetem blocos):

1. Nota e provas (4 provas, 60% grupo e 40% individual, média ≥ 7).
2. Exercícios e recuperação (15 exercícios, sem horário limite diário, exemplo numérico).
3. Uso de IA (livre, registrar no `README`, saber explicar).
4. Frequência e horários (duas chamadas, 25%, meia falta, horário por dia).
5. Rotina do dia, Classroom e tempo de projeto.

## Verificação das ferramentas

- Lista de referência: [docs/07-ferramentas.md](../../../docs/07-ferramentas.md).
- Material do aluno: `../aluno/checklist-ferramentas.md` e `../aluno/combinados.md` (publicar no Classroom antes da aula).
- Registrar, por aluno, o que falta. Quem não conseguir instalar na aula termina em casa e confirma no Classroom.
- Alunos com notebook próprio podem instalar nele; as máquinas do laboratório devem estar prontas (o que faltar aparece na sala, com o checklist).
- **DBeaver ou DataGrip:** o aluno escolhe. A licença do DataGrip deve estar nas máquinas; se não estiver, o professor
  requisita à TI. O checklist da aula é o instrumento para descobrir isso no primeiro dia. Demonstrações em aula
  são feitas no DBeaver.
- **Link de download das ferramentas:** publicar no Classroom, em um tópico de ferramentas, antes da aula (PostgreSQL,
  DBeaver, DataGrip, ERD Concepts, Git, GitKraken).
- Verificar também **Git** e a **conta no GitHub** de cada aluno: o projeto do grupo é entregue em um repositório.
- Avisar que Python, uv e VS Code serão necessários na aula 22 (Django ORM).
- **Repositório do grupo:** `bd2-grupo-NN-tema`, **público** (o plano gratuito do GitKraken só atende repositórios públicos), todos os membros e o professor como colaboradores, com um primeiro
  commit. Usuário do professor no GitHub: `douglasdss1995` (https://github.com/douglasdss1995). Detalhes:
  [docs/projetos/00-estrutura-das-entregas.md](../../../docs/projetos/00-estrutura-das-entregas.md).

## Exercício do assunto

- Assunto: «Ambiente, modelo relacional e normalização» (aulas 01 e 02). Um único exercício, com duas partes: enunciado em `../aluno/exercicio.md` (pronto). Entrega prevista na aula 02, sem horário limite.
- **Parte 1 (esta aula, 3 pontos):** prints do `SELECT version();` e do `psql --version`, banco `bd2_teste` com a tabela `saudacao`, e grupo, tema, repositório, uma frase e cinco coisas que o sistema guarda.
- **Parte 2 (aula 02, 7 pontos):** normalização da planilha da Oficina Mecânica até a 3FN, diagrama dela e o diagrama do tema do grupo. Está no mesmo arquivo: publicar no Classroom só a parte 1 hoje e completar a atividade na aula 02.
- Gabarito: `../../aula-02-2026-10-16/aluno/gabarito-oficina-mecanica.md` (entregue aos alunos depois de explicado em aula).

## Material

| Arquivo | Para quê | Estado |
|---|---|---|
| [`../aluno/combinados.md`](../aluno/combinados.md) | Página única de regras, para publicar no Classroom | pronto |
| [`../aluno/checklist-ferramentas.md`](../aluno/checklist-ferramentas.md) | Verificação das ferramentas | pronto |
| [`slides.pptx`](slides.pptx) | Os 10 slides, no modelo da escola, com a fala em cada slide nas notas do orador | pronto |
| [`slides.md`](slides.md) | Roteiro e texto de cada slide (fonte do `.pptx`) | pronto |
| [`diagnostico.md`](diagnostico.md) | Respostas certas do quiz anônimo e leitura do resultado | pronto |
| [`formulario-diagnostico.md`](formulario-diagnostico.md) | Texto e configurações para criar o formulário no Google Forms | pronto (criar o formulário) |
| [`sorteio-grupos.xlsx`](sorteio-grupos.xlsx) | Planilha do sorteio de grupos e temas (modelo em branco; salvar a cópia preenchida como `sorteio-grupos-preenchido.xlsx`, que o git ignora) | pronto |
| `../aluno/exercicio.md` | Exercício do assunto (partes 1 e 2) | pronto (publicar só a parte 1 hoje) |
| Tópico «Ferramentas» no Classroom | Links de download (PostgreSQL, DBeaver, DataGrip, ERD Concepts, Git, GitKraken) | **a criar pelo professor** |

## Notas do professor

**Antes da aula:** D-01, D-03, D-04, D-05, D-06 e D-07 estão decididas (a falta é contada por chamada). Em aberto no
`TODO.md`: D-02 (formato da correção, que só é preciso na aula 13). Também: publicar o link de download das ferramentas no Classroom.

**Na aula:**

- Dizer aos alunos, desde já: o exercício é por assunto (15 ao todo), sem horário limite diário de entrega (vale entregar até 18/11), e a média deles vale para a recuperação, e a meia falta conta como falta.
- Avisar o novo horário: segunda, quarta e sexta a aula começa às 09:00 (1ª chamada às 09:00); terça e quinta às 08:00 (1ª chamada às 08:30).
- Aula de 3 h, sem correção: cerca de 80 min de conteúdo. A modelagem e a normalização ficam na aula 2 (não haverá aula em 15/10). Se a instalação consumir o tempo, o tempo de projeto
  vira instalação e os grupos só criam o repositório na aula 2.
- O diagnóstico é anônimo: não circular pela sala olhando as telas.
- Se o sorteio atrasar ou a turma for pequena, o bloco de combinados em grupo vira exposição de 10 min, sem a dinâmica.
