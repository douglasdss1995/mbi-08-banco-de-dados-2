# Aula 06 — 22/10/2026 (quinta-feira)

Tipo: DDL e carga do projeto · 4 h · Status: **rascunho** (ajustado depois de a DDL ter sido feita mais rápido do que o previsto)

**Tema:** Do dicionário de dados ao banco: a DDL dos projetos (1º tempo) e os `INSERT` com o pedido de validação (2º tempo)

## Resumo

No **1º tempo** a turma **cria a DDL (*Data Definition Language*) dos projetos**. O professor cria primeiro a DDL do projeto
**Oficina Mecânica**, ao vivo, lendo o dicionário de dados simples; os alunos fazem a do próprio projeto. A DDL saiu rápido porque muitos
alunos a **geraram pelo ERD Concepts ou pelo MorphERD** a partir do modelo (v2 da aula 5) e só conferiram e ajustaram.

No **2º tempo, depois do intervalo, começa a carga**: o bloco de `INSERT` que estava planejado para a aula 7. Cada aluno recebe o **pedido de
validação** do seu projeto (pasta [`../aluno/pedidos-de-validacao/`](../aluno/pedidos-de-validacao/)) e carrega o banco com as Entradas 1, 2 e 4.
O bloco ocupa **todo o resto da aula**. A aula 7 continua daqui (mudar, apagar e consultar).

**Não há Git nem GitHub** do lado do aluno: a turma ainda não teve aula de versionamento. O aluno entrega os arquivos pelo Classroom.

## Objetivos

- Ver o professor transformar um dicionário de dados em `CREATE TABLE`, na ordem certa, e conferir uma DDL gerada por ferramenta.
- Escrever o `01_ddl.sql` do **próprio projeto** (as tabelas principais) e rodá-lo do zero, duas vezes seguidas, sem erro.
- Ver o professor carregar a Oficina ao vivo com `INSERT`, seguindo as Entradas 1, 2 e 4 do pedido dela.
- Entender a **ordem das tabelas** na carga (as «pai» antes das «filhas») e ler a mensagem quando a ordem erra.
- Escrever o `entradas.sql` do próprio projeto (Entradas 1, 2 e 4), rodar do zero e provocar o erro de chave estrangeira (R1).
- Perceber que um fato do pedido **sem lugar na estrutura** é um achado: a estrutura precisa mudar.

## Roteiro

| Horário | Atividade | Dinâmica |
|---|---|---|
| 08:00 – 08:30 | **Correção do dicionário (aula 5):** mostrar 2 ou 3 dicionários bons, os erros mais comuns e quem ainda precisa ajustar o modelo | Correção coletiva |
| 08:30 | **1ª chamada** | |
| 08:30 – 09:00 | **DDL da Oficina:** criar o schema (`DROP SCHEMA IF EXISTS`, `CREATE SCHEMA`, `SET search_path`) e as tabelas, lendo o [dicionário da Oficina](../aluno/oficina-dicionario-de-dados-simples.md), na ordem das chaves estrangeiras (errar a ordem de propósito uma vez). Rodar duas vezes seguidas | Demonstração ao vivo; a turma diz o próximo campo |
| 09:00 – 09:40 | **DDL dos alunos:** cada aluno gera ou escreve o `01_ddl.sql` do **seu** projeto (pelo ERD Concepts, MorphERD ou à mão), confere com o dicionário e roda do zero duas vezes. O professor circula | Individual, com o professor ajudando |
| 09:40 – 10:00 | Intervalo | |
| 10:00 – 10:10 | **Abertura da carga:** apresentar o pedido de validação da Oficina e o `INSERT` (uma linha e várias linhas); `IDENTITY` não se informa; a ordem das tabelas | Exposição curta |
| 10:10 – 10:30 | **Oficina ao vivo, Entrada 1 (cadastros):** clientes, modelos, veículos, mecânicos e serviços, nesta ordem; conferir com `SELECT * FROM tabela`; errar a ordem de propósito (veículo antes do cliente) e ler a mensagem | Demonstração; a turma diz a próxima tabela |
| 10:30 – 10:50 | **Oficina ao vivo, Entradas 2 e 4 (ordens de serviço):** `ordem_servico` e `item_servico`, o `id` diferente do `numero` e a subconsulta que acha o id; **R1 ao vivo** (OS para um veículo que não existe) | Demonstração, com erro de propósito |
| 10:50 – 11:30 | **Carga dos alunos:** cada aluno abre o pedido do **seu** projeto e escreve o `entradas.sql` (Entradas 1, 2 e 4 e o R1) no próprio banco. O professor circula e lê os erros com cada um | Individual, com o professor ajudando |
| 11:30 | **2ª chamada** · atendimento até 11:40 | |

## Como conduzir

1. **DDL: parta do dicionário, não do banco.** A frase que repete é: «cada tabela do dicionário vira um `CREATE TABLE`; cada campo vira uma
   coluna». Quem gerou a DDL por ferramenta confere tabela por tabela contra o dicionário: tipos, `NOT NULL`, `UNIQUE` e as `REFERENCES`.
2. **Rode duas vezes seguidas** para mostrar o `DROP SCHEMA` no início. É o hábito que será cobrado em todas as entregas.
3. **Carga: parta do pedido, não do comando.** A frase que repete é: «o pedido diz o que entra; eu decido onde cada fato mora». Leia um fato
   do pedido da Oficina em voz alta e pergunte à turma em qual tabela ele entra.
4. **A turma conduz a próxima linha:** «qual tabela vem agora?» e «esta tabela referencia quem?».
5. **Erre de propósito** duas vezes: a ordem das tabelas e o R1; leia a mensagem inteira (`viola restrição de chave estrangeira`,
   `Chave (cliente_id)=(1) não está presente na tabela "cliente"`).
6. **Só `INSERT` hoje.** Se alguém perguntar como corrigir ou apagar uma linha, diga que é a aula 7; por ora, recriar o banco
   (`01_ddl.sql` e a carga de novo) resolve, e é o hábito que o pedido cobra.
7. **`SELECT` só para conferir:** `SELECT * FROM tabela` e `SELECT count(*)`. Não dê o `JOIN` hoje.
8. **Ids previsíveis só no banco recém-criado.** Mostre também a alternativa `(SELECT id FROM cliente WHERE nome = 'Ana Souza')`.
9. **Fato sem lugar é achado, não erro do aluno.** Quem montou um núcleo menor (6 tabelas, não 8) faz só as entradas que a estrutura comporta e
   anota o resto no `achados.md`. Isso vale nota.
10. **Os dois ou três alunos do mesmo projeto** podem comparar os scripts (a regra de colaboração permite); cada um entrega o seu.
    O guia de cada projeto está em `projetos-referencia/NN-tema/dicionario-de-dados.md` (régua do professor; **não mostrar ao aluno**).
11. **Projetos pesados** (escola, academia, delivery, locadora): aceite um núcleo menor na DDL e na carga.
12. **IA liberada:** peça que registrem no `uso-de-ia.md` qual IA usaram e para quê; a IA ajuda a gerar nomes e e-mails fictícios, e o aluno
    **confere** se os números fecham com o pedido.

## Conteúdo (e o que fica para depois)

| Hoje | Fica para |
|---|---|
| `DROP SCHEMA`, `CREATE SCHEMA`, `CREATE TABLE`, tipos, `PRIMARY KEY` com `IDENTITY`, `FOREIGN KEY`, `NOT NULL`, `UNIQUE` | `CHECK`, `DEFAULT` elaborado e `ON DELETE`: aula de integridade |
| Ordem de criação e tabela de ligação (N:N); DDL gerada por ferramenta e conferida | `ALTER TABLE` e outras mudanças depois de criado |
| `INSERT` (uma e várias linhas), ordem das tabelas, `IDENTITY`; `SELECT * FROM tabela` e `SELECT count(*)` para conferir | `UPDATE` e `DELETE` com `WHERE` (Entradas 3 e 5 do pedido): **aula 7** |
| Erro de chave estrangeira (R1) | R2 e R3 (aula 7); `SELECT` com `JOIN`, `GROUP BY` e agregação (consultas C1 a C16): aulas 7 e 8 |

**Excesso planejado (o professor corta):** `COPY`/`\copy` com CSV (≈10 min), dados gerados com IA e como conferir (≈5 min) e `RETURNING id`
no `INSERT` (≈5 min). Se faltar tempo, corte nesta ordem: `COPY`, IA, `RETURNING`.

## Exercícios

Dois arquivos, entregues no Classroom **sem horário limite**:

- **«DDL do seu projeto»**: [`../aluno/exercicio.md`](../aluno/exercicio.md). Entrega do `01_ddl.sql` e de um print. Correção: o professor confere se o
  script roda do zero e se as tabelas batem com o dicionário do aluno.
- **«Entradas do seu projeto»**: [`../aluno/exercicio-entradas.md`](../aluno/exercicio-entradas.md). Entrega do `entradas.sql` (Entradas 1, 2 e 4),
  da mensagem do R1 dentro do `achados.md` e do `uso-de-ia.md`. Pontuação proposta: 7 + 1 + 2. Correção: o professor roda o `entradas.sql` sobre o
  `01_ddl.sql` do aluno e confere se não dá erro e se as quantidades batem com o pedido.
- O pedido de cada projeto está em [`../aluno/pedidos-de-validacao/`](../aluno/pedidos-de-validacao/) (um arquivo por tema). Publique no
  Classroom o do tema de **cada aluno** (a lista de sorteio não vai para o remoto).
- **Entrega em partes.** Aula 6: DDL e Entradas 1, 2 e 4 com R1. Aula 7: Entradas 3 e 5, R2, R3 e as primeiras consultas. Depois: o restante das
  consultas (D-43). O texto do pedido fala em uma entrega só: avisar a turma, ou ajustar o texto antes de publicar.

## Material

| Arquivo | Para quê | Estado |
|---|---|---|
| [`ddl-oficina.sql`](ddl-oficina.sql) | Script da Oficina Mecânica que o professor cria ao vivo (testado no PostgreSQL 18, roda duas vezes) | pronto |
| [`../aluno/oficina-dicionario-de-dados-simples.md`](../aluno/oficina-dicionario-de-dados-simples.md) | Dicionário da Oficina (7 tabelas), de onde sai a DDL | pronto |
| [`../aluno/referencia-ddl.md`](../aluno/referencia-ddl.md) | Folha de consulta: esqueleto do script, tipos, FK, N:N, erros comuns | pronto |
| [`../aluno/exercicio.md`](../aluno/exercicio.md) | Exercício «DDL do seu projeto» | pronto |
| [`../aluno/pedidos-de-validacao/`](../aluno/pedidos-de-validacao/) | Pedido da Oficina (exemplo guiado) e dos 10 projetos | pronto (revisar o da biblioteca primeiro) |
| [`../aluno/entradas-oficina-sala.sql`](../aluno/entradas-oficina-sala.sql) | Versão de sala da Oficina (Entradas 1, 2 e 4): `INSERT` simples, ids em ordem, com o erro de ordem e o R1 de propósito (testado no PostgreSQL 18, roda duas vezes) | pronto |
| [`../aluno/referencia-insert.md`](../aluno/referencia-insert.md) | Folha de consulta: `INSERT`, ordem, `IDENTITY`, erros, `\copy` | pronto |
| [`../aluno/exercicio-entradas.md`](../aluno/exercicio-entradas.md) | Exercício «Entradas do seu projeto» | pronto |
| `projetos-referencia/00-oficina-mecanica/validacao/entradas.sql` | Solução do professor, testada (usa `VALUES` com subconsultas: **não mostrar assim**) | pronto |

## Notas do professor

- Os arquivos da carga ficam em `aluno/` porque vão para o Classroom. Publique o `ddl-oficina.sql` (copie de `professor/` para `aluno/` depois da aula) e a
  versão de sala da carga: são os exemplos guiados, já explicados (regra 2 do `CLAUDE.md`). A solução (`consultas.sql`, `testes.sql`, `achados.md` dos
  projetos) **não** vai para o aluno.
- A Oficina desta aula é a versão **completa** (7 tabelas). O exemplo curto do dicionário da aula 5 tinha só 3 tabelas.
- **ERD Concepts** não faz engenharia reversa com o PostgreSQL 18, mas gera o script de criação a partir do desenho. O **MorphERD** idem. Ferramenta
  gera tipos e nomes que nem sempre batem com o dicionário: a conferência é do aluno.
- Não use Git, GitHub nem GitKraken: o aluno só entrega os arquivos.
- **Risco:** a turma ainda tem dificuldade para ler um relato e transformar em tabelas. O pedido ajuda porque traz os dados prontos; se
  travar, faça junto a Entrada 1 de um projeto voluntário na frente.
- **Próxima aula (7, sexta, 3 h):** continuação da carga e das consultas: `UPDATE` e `DELETE` (Entradas 3 e 5, R2 e R3) e as primeiras consultas do pedido.
