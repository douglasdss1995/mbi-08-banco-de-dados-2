# Projeto 1 — Biblioteca escolar

Estrutura comum das entregas (GitHub, tags, notas): [00-estrutura-das-entregas.md](00-estrutura-das-entregas.md).

## Cenário

A biblioteca de uma escola técnica empresta livros a **alunos, professores e funcionários**. O acervo tem vários
**exemplares** do mesmo livro. A biblioteca quer controlar empréstimos, devoluções, reservas e multas por atraso, e
saber quais livros são mais usados.

## Solicitação do usuário

**Solicitante:** Marta, bibliotecária da escola. Leia o relato como se ela tivesse chamado você para fazer o sistema.
O que ela não explicou, você pergunta ao professor (ele faz o papel da Marta). A modelagem é sua.

### O relato da Marta

> Oi! Sou a Marta, cuido da biblioteca há oito anos. Hoje controlo tudo em planilha e em um caderno, e está ficando
> impossível. Deixa eu contar o meu dia.
>
> **Meu dia começa** olhando o que tem para ser devolvido naquele dia. Abro a planilha de empréstimos, ordeno pela data de
> devolução e marco os que vencem hoje. Depois olho os que já passaram do prazo: quem não devolveu até ontem eu preciso
> cobrar.
>
> **Depois cadastro os livros novos.** Cada livro tem título, autor (às vezes vários), editora, ano e categoria. A escola
> compra vários exemplares do mesmo título, e cada exemplar tem um número de tombo colado na lombada. Se eu cadastrar só
> "o livro", não sei qual exemplar está com quem.
>
> **Quando alguém vem pegar um livro**, aluno, professor ou funcionário, anoto: quem é a pessoa, qual exemplar (o tombo),
> a data do empréstimo e a data prevista de devolução. O prazo muda conforme quem pegou: aluno tem 7 dias, professor 15 e
> funcionário 10. Cada um também tem um limite de livros ao mesmo tempo: aluno 3, professor 5, funcionário 3.
>
> **Na devolução** procuro a linha do empréstimo, escrevo a data em que o livro voltou e confiro o estado do exemplar. Se
> voltou estragado, vai para manutenção. Se o livro sumiu, marco como perdido.
>
> **Quando o livro está em falta**, a pessoa pede reserva. Hoje anoto num caderno e sempre erro a ordem da fila. Quando o
> exemplar volta, o primeiro da fila tem 3 dias para buscar. Passou disso, vai para o próximo.
>
> **Renovação:** a pessoa renova uma vez, pelo mesmo prazo, mas só se ninguém estiver na fila daquele livro.
>
> **Multa:** cada dia de atraso custa R$ 0,50 para aluno e R$ 0,25 para professor e funcionário. Esse valor já mudou duas
> vezes e preciso saber quanto era na época do atraso, porque às vezes alguém contesta uma multa antiga. Quem tem multa
> pendente não pega livro novo até pagar.

### Minhas dificuldades hoje

1. Não sei, de cara, **quais livros vencem hoje** e **quais já estão atrasados**. Descubro lendo a planilha linha por linha.
2. **Cobrança:** devo cobrar quem não devolveu até ontem. Hoje ligo para cada um. Queria que o sistema **avisasse por
   e-mail e por WhatsApp**, e que eu visse quem já foi avisado e quando, para não cobrar duas vezes sem querer.
3. Não sei **quais livros são mais emprestados** nem quais ninguém pega. Uso isso para decidir as próximas compras.
4. Perco o controle de **onde está cada exemplar** (estante, emprestado, manutenção, perdido).
5. Calculo multa na calculadora e já errei a conta.

### O que quero ver quando abrir o sistema

- Os empréstimos que **vencem hoje**.
- Os **atrasados**, com nome, telefone, e-mail, livro, dias de atraso e multa até agora.
- Para cada atrasado, se **já foi avisado** (por qual meio e quando).
- A **fila de reservas** de cada livro, na ordem.
- Os livros **mais emprestados do mês**.

### O que guardo hoje nas planilhas

| Planilha | Colunas atuais |
|---|---|
| Acervo | título, autor, editora, ano, categoria, nº do tombo, situação |
| Leitores | nome, tipo (aluno/professor/funcionário), matrícula ou registro, telefone, e-mail |
| Empréstimos | leitor, tombo, data do empréstimo, data prevista, data da devolução, renovado? |
| Reservas (caderno) | leitor, livro, data do pedido, posição na fila |
| Multas | leitor, empréstimo, dias de atraso, valor, pago? |

### Perguntas para fazer à Marta

- O que acontece se um livro é perdido? O leitor paga o valor do livro?
- Um mesmo e-mail ou telefone pode ser de mais de um leitor (irmãos, por exemplo)?
- A multa tem teto? Conta fim de semana e feriado?
- O aviso ao leitor é sempre o mesmo texto?

> O envio real de e-mail e WhatsApp é feito por outro sistema. **O banco de dados guarda o que precisa ser avisado e o que
> já foi avisado.**

## Regras de negócio

| Regra | Valor |
|---|---|
| Prazo de empréstimo | Aluno 7 dias; professor 15 dias; funcionário 10 dias |
| Limite de empréstimos abertos | Aluno 3; professor 5; funcionário 3 |
| Multa por dia de atraso | R$ 0,50 (aluno), R$ 0,25 (professor e funcionário); a tarifa **muda com o tempo** e o histórico deve ser preservado |
| Leitor com multa pendente | Não pode pegar novos livros |
| Exemplar | Só é emprestado se estiver `disponivel`. Estados: disponível, emprestado, em manutenção, perdido |
| Renovação | Uma vez, por mais o prazo do tipo de leitor, e só se não houver reserva do livro |
| Reserva | Quando não há exemplar disponível; fila por ordem de pedido; vale por 3 dias depois que o exemplar volta |
| Livro | Pode ter vários autores e pertence a uma categoria; autor pode ter vários livros |

## Modelo mínimo (a decidir pelo grupo; pelo menos 8 tabelas)

Editora, autor, livro, livro-autor, categoria, **exemplar** (tombo), tipo de leitor, leitor, empréstimo, reserva, multa,
tarifa de multa (com vigência), **notificação** (aviso de cobrança por e-mail ou WhatsApp). O grupo decide e **justifica** o desenho.

**Pontos que exigem decisão** (a prova cobra a justificativa):

1. Livro x exemplar: onde ficam o título e onde fica o estado físico?
2. Livro com vários autores (N:N) e a ordem dos autores.
3. Histórico da tarifa de multa: guardar o valor no empréstimo ou consultar a tarifa vigente na data?
4. O leitor tem tipo fixo ou o tipo pode mudar com o tempo (aluno que vira funcionário)?
5. Reserva em fila: como representar a ordem e a validade?
6. Multa: guardar o valor calculado ou calculá-lo sempre que consultar?

## Dados de apoio

- Coluna `metadados` (`JSONB`) em livro: idioma, edição, ano, páginas, ISBN, tags, sinopse curta. Livros diferentes têm
  campos diferentes.
- Código do exemplar (tombo) no formato `EX-000123`, gerado com `LPAD`.

## Entrega 1 — Prova 1 (aula 12): modelo, DDL, carga e transações

Tag: `prova-1`. As transações são dadas na aula 11, um dia antes: a entrega é pequena e guiada pelo exercício do dia.

| # | Item | Arquivo | O que entregar |
|---|---|---|---|
| 1 | Modelo | `diagrama/` | Diagrama no ERD Concepts (conceitual e lógico) com cardinalidades, e a imagem exportada |
| 2 | Estrutura | `sql/01_ddl.sql` | Schema `biblioteca`, 8 ou mais tabelas, `PK`, `FK`, `UNIQUE`, `CHECK` e `DEFAULT` para as regras que o banco consegue garantir |
| 3 | Normalização | `README.md` | Justificar até a 3FN e dizer uma desnormalização feita de propósito, se houver |
| 4 | Carga | `sql/02_carga.sql` | 30 livros, 60 exemplares, 40 leitores (3 tipos), 100 empréstimos (em dia, atrasados, em aberto), 10 reservas, multas. Dados que **exercitam as regras** (leitor no limite, exemplar em manutenção) |
| 5 | Transações | `sql/03_transacoes.sql` | Empréstimo como transação (inserir empréstimo e mudar o estado do exemplar, tudo ou nada), com `ROLLBACK` quando falhar |
| 6 | Concorrência | `sql/03_transacoes.sql` + `evidencias/` | **Duas sessões disputando o último exemplar**: mostrar o problema, a solução (bloqueio de linha ou isolamento) e explicar por quê |
| 7 | Decisões | `README.md` | As respostas dos 6 pontos de decisão acima, por que a transação protege o que protege, divisão do trabalho e uso de IA |

Dado na aula: modelagem (9), análise de bancos (10), transações e ACID (11), DDL e normalização (revisão, aulas 2 e 3).

## Entrega 2 — Prova 2 (aula 16): funções SQL, subconsultas/CTE, `JSONB`, window functions e views

Tag: `prova-2`.

| # | Item | Arquivo | O que entregar |
|---|---|---|---|
| 1 | Funções SQL | `sql/04_consultas.sql` | 10 consultas, entre elas: tombo com `LPAD`, nome formatado, prazo de devolução (`data + intervalo`), dias de atraso, empréstimos por mês (`DATE_TRUNC`), dia da semana com mais empréstimos (`EXTRACT`), situação (`CASE`: no prazo, atrasado, devolvido), `COALESCE` para devolução em aberto |
| 2 | Subconsultas e CTE | `sql/04_consultas.sql` | 3 ou mais: livros nunca emprestados, leitores acima da média de empréstimos, ranking de multa por leitor feito com CTE em etapas |
| 3 | `JSONB` | `sql/04_consultas.sql` | 3 consultas sobre `metadados` (filtrar por idioma, listar tags, livros com mais de 300 páginas) |
| 4 | Window functions | `sql/05_janelas_views.sql` | 2 consultas: livros mais emprestados por categoria (`RANK`) e total acumulado de multas por mês |
| 5 | Views | `sql/05_janelas_views.sql` | `vw_emprestimos_abertos` e uma view materializada com ranking mensal, com atualização |
| 6 | Decisões | `README.md` | Decisões, o que a IA errou, divisão do trabalho |

Dado na aula: funções SQL (13), subconsultas, CTE e `JSONB` (14), window functions e views (15).

## Entrega 3 — Prova 3 (aula 21): índice, funções, procedures e triggers

Tag: `prova-3`. Com o bloco de `PL/pgSQL` em três dias (aulas 18 a 20, com 40 min de projeto por dia), a entrega pede
**mais rotinas e testadas**, e a parte de índice segue enxuta.

| # | Item | Arquivo | O que entregar |
|---|---|---|---|
| 1 | Índice | `sql/06_indices.sql` + `evidencias/` | Carga em volume (100 mil empréstimos ou mais, com `generate_series`), **1 consulta lenta**, `EXPLAIN` antes e depois do índice e explicação |
| 2 | Funções | `sql/07_funcoes.sql` | 3 ou mais: `calcular_multa(emprestimo)`, `prazo_devolucao(leitor, data)` e `leitor_pode_emprestar(leitor)` (limite e multa pendente, retornando o motivo). Cada uma com chamada de teste e resultado em `evidencias/` |
| 3 | Procedures | `sql/08_procedures.sql` | 3: `registrar_emprestimo(leitor, exemplar)` aplicando as regras (limite, multa pendente, exemplar disponível), `registrar_devolucao(emprestimo)` (gera a multa quando há atraso) e `renovar_emprestimo(emprestimo)` (uma vez, sem reserva). Erros com `RAISE EXCEPTION` e mensagens claras, cada uma com um teste que dá certo e um que falha |
| 4 | Triggers | `sql/09_triggers.sql` | 2: **auditoria** de mudanças em empréstimo (quem, quando, antes e depois) e **regra de negócio** (ao devolver, o exemplar volta a `disponivel` ou vai para a reserva mais antiga), com um teste de cada |
| 5 | Decisões | `README.md` | Onde cada regra ficou (função, procedure, trigger ou `CHECK`) e por quê, divisão do trabalho, uso de IA |

Dado na aula: índices e `generate_series` (17), funções (18), procedures (19), triggers (20).

## Entrega final — Prova 4 (aulas 23 e 24): apresentação

Tag: `final`.

- **Demonstração (6 min):** um cenário de ponta a ponta: leitor empresta, atrasa, devolve com multa e o relatório mostra o
  ranking. Executado ao vivo por uma procedure.
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
