# Aula 03 — 19/10/2026 (segunda-feira)

Semana do curso: 2 · Tipo: Revisão de BD1 · 3 h · Status: **rascunho**

**Tema:** Revisão de DDL e DML na prática, com o banco da Oficina Mecânica

## Objetivos

- Revisar `CREATE TABLE`, tipos, `PRIMARY KEY`, `FOREIGN KEY`, `NOT NULL`, `DEFAULT` e `ALTER TABLE`.
- Revisar `INSERT`, `UPDATE` e `DELETE` (com `WHERE`), e entender o que as chaves estrangeiras recusam.
- Ver o professor criar e carregar o banco da Oficina Mecânica (modelo em 3FN do exercício 1) **ao vivo, para todos**, e
  repetir o caminho nas tabelas da planilha que o grupo normalizou na aula 2, em **scripts reexecutáveis**.
- Levar o que foi mostrado para o **projeto** do grupo (início do `01_ddl.sql` do tema).
- Ser corrigido por outro grupo (aula 4), na modelagem e nos scripts, e corrigir o trabalho dele.

## Roteiro

A aula começa às 09:00 (o 1º tempo é de outro professor).

| Horário | Atividade | Dinâmica |
|---|---|---|
| 08:00 – 09:00 | Aula de outro professor (sem aula desta disciplina) | |
| 09:00 | **1ª chamada** | |
| 09:00 – 09:20 | **Resolução do exercício 1 e das planilhas:** refazer a normalização da Oficina Mecânica no quadro (roteiro em `../../aula-02-2026-10-16/aluno/gabarito-oficina-mecanica.md`) e **mostrar as tabelas corretas das planilhas A a E** (`../../aula-02-2026-10-16/professor/gabarito-oficina-de-normalizacao.md`), para todos partirem do modelo certo | A turma diz o próximo passo |
| 09:20 – 09:40 | **DDL ao vivo, com a Oficina Mecânica:** criar o banco, `CREATE TABLE`, tipos, `PRIMARY KEY`, `FOREIGN KEY`, a ordem de criação por causa das chaves estrangeiras e `ALTER TABLE`. Os alunos só acompanham | Demonstração ao vivo, na frente de todos |
| 09:40 – 10:00 | Intervalo | |
| 10:00 – 10:15 | **DML ao vivo, com a Oficina Mecânica:** `INSERT` (um e vários), `UPDATE` e `DELETE` com `WHERE`, e o erro que a chave estrangeira provoca | Demonstração, com o erro de propósito |
| 10:15 – 10:40 | **Prática:** cada aluno cria o banco `bd2_planilha` com as tabelas da **planilha do seu grupo** (aula 2) e carrega dados, em `01_ddl.sql` e `02_carga.sql` | Individual, com o professor circulando |
| 10:40 – 11:00 | **Tempo de projeto:** o grupo converte o que foi mostrado para o **projeto**: escreve o início do `01_ddl.sql` do tema (tabelas principais do diagrama) e faz o commit com o GitKraken | Grupos |
| 11:00 – 11:30 | **Exercício «DDL e DML»:** terminar a prática e fazer as partes B e C, e subir os arquivos para `exercicio-2/<nome>/` do repositório do grupo (entrega no Classroom sem horário limite) | Individual |
| 11:30 | **2ª chamada** · atendimento até 11:40 | |

## Conteúdo (e o que fica para depois)

| Hoje | Fica para |
|---|---|
| `CREATE TABLE`, tipos, `PK`, `FK`, `NOT NULL`, `DEFAULT`, `ALTER TABLE ... ADD COLUMN` | `CHECK`, `UNIQUE` e `ON DELETE`: aula 8 (integridade) |
| `INSERT`, `UPDATE` e `DELETE` com `WHERE` | Uso seguro de `UPDATE` e `DELETE` (conferir com `SELECT` antes), `COPY` e CSV: aula 6 |
| Scripts reexecutáveis (`DROP TABLE IF EXISTS`) | `SELECT`: aulas 4 e 5 |

## Demonstração

O professor faz tudo **na frente de todos**, com o banco da Oficina Mecânica (`bd2_oficina`), criado ao vivo e na mesma
ordem do roteiro. Os alunos acompanham e depois repetem nas tabelas da planilha do grupo; no tempo de projeto, repetem
no projeto:

1. **DDL:** criar o banco; criar `cliente` e `veiculo` (a primeira com chave primária de identidade, a segunda com
   chave estrangeira); mostrar o erro ao criar `veiculo` antes de `cliente`; criar as demais; `ALTER TABLE ... ADD COLUMN`.
2. **DML:** `INSERT` de um cliente e de vários; `UPDATE` com e sem `WHERE` (**mostrar só como `SELECT`** o efeito do
   `UPDATE` sem `WHERE`, sem executar); `DELETE` de uma OS e depois do cliente (erro de chave estrangeira).
3. **Reexecutar:** rodar o `01_ddl.sql` duas vezes e mostrar que não falha.

Os scripts da demonstração estão prontos em `gabarito-exercicio.md` (somente nesta pasta). Eles são da Oficina
Mecânica; o aluno não os recebe, porque a prática é nas tabelas da planilha dele.

## Exercício do assunto

- Assunto: «DDL e DML». Enunciado: [`../aluno/exercicio.md`](../aluno/exercicio.md), feito nas **tabelas da planilha
  do grupo** (aula 2, planilhas A a E). Modelo da demonstração:
  [`../aluno/cenario-oficina-mecanica.md`](../aluno/cenario-oficina-mecanica.md). Resolução:
  [`gabarito-exercicio.md`](gabarito-exercicio.md) (somente nesta pasta). Entrega sem horário limite.
- Três partes: A (DDL, 4 pontos), B (DML, 4 pontos) e C (rodar do zero, 2 pontos). O início do `01_ddl.sql` do projeto
  é só o tempo de projeto (10:40 às 11:00) e não faz parte do exercício.
- **Correção cruzada na aula 4, de 08:00 às 08:30:** o outro grupo que normalizou a mesma planilha corrige a modelagem e
  os scripts, com a [`ficha`](../aluno/ficha-correcao-cruzada.md). O professor fecha com os erros mais comuns.

## Material

| Arquivo | Para quê | Estado |
|---|---|---|
| [`../aluno/exercicio.md`](../aluno/exercicio.md) | Enunciado (partes A a C, com a correção cruzada) | pronto |
| [`../aluno/cenario-oficina-mecanica.md`](../aluno/cenario-oficina-mecanica.md) | Modelo da demonstração: regras, tipos e dados de partida | pronto |
| [`../aluno/ficha-correcao-cruzada.md`](../aluno/ficha-correcao-cruzada.md) | Ficha da correção entre grupos (aula 4) | pronto |
| [`gabarito-exercicio.md`](gabarito-exercicio.md) | Scripts da demonstração (Oficina Mecânica), pontuação e roteiro da correção | pronto |
| [`gabarito-planilhas.md`](gabarito-planilhas.md) | Scripts testados do exercício nas planilhas A a E (pasta `gabarito-planilhas/`) | pronto |
| [`slides.pptx`](slides.pptx) | 8 slides no modelo da escola, com a fala nas notas do orador | pronto |
| [`slides.md`](slides.md) | Passo a passo da fala, slide por slide, com explicação e informações de apoio | pronto |

## Notas do professor

- **Antes da aula:** publicar no Classroom o enunciado, o modelo da demonstração e a ficha de correção cruzada; conferir
  que o PostgreSQL abre e que o `psql` está no `PATH` (a aula 6 usa `\copy`).
- **Quem errou a normalização** copia as tabelas corretas mostradas às 09:00; não perca tempo corrigindo
  individualmente. Deixe o quadro (ou a tela) com as cinco planilhas visíveis durante a prática.
- **Pares de grupos:** o grupo que recebeu a mesma planilha na aula 2 é o corretor (o do «confronto»). Se uma planilha
  tiver só um grupo, combine com outra planilha. O banco do aluno é `bd2_planilha`: ele **não** é o `bd2_oficina` da
  aula 4.
- **Erro mais provável:** a ordem de criação ou de carga por causa das chaves estrangeiras. Deixar a mensagem de erro
  aparecer e perguntar à turma o que ela diz.
- **Aula de 3 h, sem folga:** se o ritmo atrasar, corte o 2º commit do tempo de projeto (vira tarefa para casa) e nunca a
  prática.
- **O banco das aulas 4 e 5 é o da Oficina Mecânica.** Os alunos ainda não o criaram (na aula 3 fizeram o da
  planilha): na aula 4 eles criam `bd2_oficina` e rodam `oficina-completo.sql` (em `aula-04.../aluno/`), com cerca de
  40 ordens de serviço, para ter dados suficientes para as consultas.
- **Escopo:** não ensinar `CHECK`, `UNIQUE` nem `ON DELETE` hoje. Se um aluno perguntar, registrar para a aula 8.
