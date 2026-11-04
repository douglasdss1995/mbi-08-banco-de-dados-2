# Exercício 3 (aula 6) — DDL e entradas do seu projeto

Banco de Dados 2 · Turma MBI-08 · Aula 6

Siglas: **DDL** (*Data Definition Language*, linguagem de definição de dados), **DML** (*Data Manipulation Language*, linguagem de manipulação de dados),
**PK** (*Primary Key*, chave primária), **FK** (*Foreign Key*, chave estrangeira), **SQL** (*Structured Query Language*, linguagem de consulta estruturada).

| | |
|---|---|
| **Como fazer** | Individual. Pode trocar ideias com colegas. |
| **Entrega** | Uma atividade no Google Classroom, com `01_ddl.sql`, `entradas.sql`, `achados.md` e `uso-de-ia.md`, mais um print. |
| **Prazo** | Vale entregar até 18/11. |

## O que fazer

Na aula 6 o professor montou o banco da **Oficina Mecânica**: primeiro a estrutura, depois os dados.
Agora você faz o mesmo no **seu projeto**.

Use o dicionário de dados que você entregou na aula 5 e o pedido do seu tema (pasta `pedidos-de-validacao`, no Classroom).

## Parte 1 — A estrutura (`01_ddl.sql`)

1. Abra o script `01_ddl.sql`.
2. Comece com `DROP SCHEMA IF EXISTS ... CASCADE`, `CREATE SCHEMA` e `SET search_path` (veja a [referência de DDL](referencia-ddl.md)).
3. Crie as tabelas principais do projeto (6 a 8, no mínimo). Crie primeiro as tabelas «pai», depois as que têm FK.
4. Dê a cada tabela uma PK. Use `NOT NULL`, `UNIQUE` e os tipos do dicionário.
5. Se houver relação N:N, crie a tabela de ligação.
6. Rode o script duas vezes seguidas, sem erro.
7. Tire um print: a lista de tabelas e o resultado da segunda execução.

## Parte 2 — Os dados (`entradas.sql`)

O pedido tem 5 entradas. Faça só as **Entradas 1, 2 e 4** (as que usam `INSERT`).
As Entradas 3 e 5 (mudar e apagar) ficam para depois.

1. Abra o banco **vazio**: rode o `01_ddl.sql`.
2. Leia o pedido do seu projeto. Ele diz **o que entra**, não em qual coluna. Você decide.
3. Crie o `entradas.sql`. Comece com o `SET search_path` do seu schema.
4. Escreva as Entradas 1, 2 e 4, nesta ordem. Abra cada uma com um comentário (`-- Entrada 1 · cadastros`).
5. Rode `01_ddl.sql` e depois `entradas.sql`, duas vezes seguidas, sem erro.
6. Confira as quantidades: depois de cada entrada, rode `SELECT count(*)` em cada tabela e compare com o pedido.
7. Faça o teste de recusa **R1** do pedido. Copie a mensagem de erro.

Dúvida no `INSERT`? Veja a [referência de INSERT](referencia-insert.md).

## Parte 3 — Achados e registro

- `achados.md`:
  1. A mensagem de erro do R1 e **uma frase** que explica por que o banco recusou.
  2. O que **não coube** na sua estrutura e o que você mudou. Se tudo coube, escreva isso.
- `uso-de-ia.md`: qual IA usou e para quê (ou que não usou). Diga **com quem conversou** e sobre o quê.

## Regras

- Um fato do pedido que não cabe na sua estrutura vai para o `achados.md`.
- Não informe a coluna `IDENTITY` em nenhum `INSERT`.
- Saiba explicar tudo o que entregou.

## Para conferir antes de entregar

- [ ] Cada tabela do dicionário virou um `CREATE TABLE`, com PK e tipos que fazem sentido.
- [ ] Cada campo que liga a outra tabela tem `REFERENCES`.
- [ ] `01_ddl.sql` e `entradas.sql` rodam do zero, duas vezes, sem erro.
- [ ] O `entradas.sql` começa com o `SET search_path` do meu schema.
- [ ] As tabelas «pai» foram preenchidas antes das que têm FK.
- [ ] A contagem de linhas de cada tabela bate com o pedido.
- [ ] O `achados.md` tem a mensagem do R1.
- [ ] O `uso-de-ia.md` está escrito.

## Para fixar (sem nota)

Responda em comentário no fim do `entradas.sql`, sem olhar o material.

1. Por que a tabela «pai» é criada e preenchida antes da tabela com FK?
2. O que o `DROP SCHEMA ... CASCADE` faz, e por que ele deixa o script rodar de novo?
3. Por que não se informa a coluna `IDENTITY` no `INSERT`?
