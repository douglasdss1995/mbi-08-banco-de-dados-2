# Gabarito — Exercício 2 nas planilhas A a E

Enunciado: [`../aluno/exercicio.md`](../aluno/exercicio.md). Este arquivo é do professor: **não vai para o Classroom**.

O aluno faz o exercício nas **tabelas da planilha do grupo** (aula 2). Os scripts abaixo são a resolução de cada uma das
cinco planilhas, na pasta [`gabarito-planilhas/`](gabarito-planilhas/). As tabelas vêm do
[gabarito da oficina de normalização](../../aula-02-2026-10-16/professor/gabarito-oficina-de-normalizacao.md) e os
dados, das planilhas [`planilhas-oficina/`](../../aula-02-2026-10-16/aluno/planilhas-oficina/) (`.csv`), com linhas
inventadas para chegar a 5 em cada tabela. A pontuação é a de [`gabarito-exercicio.md`](gabarito-exercicio.md).

Todos os scripts foram **executados no PostgreSQL 18.4** (cluster temporário): `01_ddl.sql` rodou duas vezes seguidas sem
erro, `02_carga.sql` rodou sem erro e o `03_dml.sql` produziu **exatamente 3 erros**, os de B.4, nos 3 últimos comandos.

| Planilha | Pasta | Linhas por tabela depois da carga | `UPDATE` 1 · `UPDATE` 2 · `DELETE` |
|---|---|---|---|
| A · Pedidos | `a-pedidos/` | `cidade` 5, `cliente` 5, `vendedor` 5, `produto` 5, `pedido` 6, `item_pedido` 9 | 1 · 3 · `item_pedido` 1 e `pedido` 1 |
| B · Matrículas | `b-matriculas/` | `aluno` 5, `professor` 5, `turma` 5, `matricula` 8 | 1 · 2 · `matricula` 1 |
| C · Consultas | `c-consultas/` | `convenio` 5, `paciente` 5, `especialidade` 5, `medico` 5, `consulta` 7 | 1 · 4 · `consulta` 1 |
| D · Aluguéis | `d-alugueis/` | `cliente` 5, `equipamento` 5, `contrato` 6, `item_contrato` 10 | 1 · 3 · `item_contrato` 2 e `contrato` 1 |
| E · Estoque | `e-estoque/` | `fornecedor` 5, `produto` 5, `deposito` 5, `estoque` 8 | 1 · 2 · `estoque` 1 |

Em cada pasta: `01_ddl.sql` (A.2 e A.3), `02_carga.sql` (B.1) e `03_dml.sql` (B.2, B.3 e B.4).

## Para rodar do zero (parte C)

```
psql -U postgres -c "DROP DATABASE IF EXISTS bd2_planilha" -c "CREATE DATABASE bd2_planilha"
psql -U postgres -d bd2_planilha -f 01_ddl.sql
psql -U postgres -d bd2_planilha -f 02_carga.sql
```

## Mensagens esperadas (B.4)

As três mensagens são as mesmas em todas as planilhas, mudando só os nomes:

| Erro | Mensagem do PostgreSQL | Por quê |
|---|---|---|
| 1 · Linha que aponta para código que não existe | `insert or update on table "..." violates foreign key constraint "..."` | A chave estrangeira exige que o código exista na tabela de origem |
| 2 · Apagar linha que tem filhos | `update or delete on table "..." violates foreign key constraint "..." on table "..."` | Apagar deixaria linhas órfãs |
| 3 · Inserir sem preencher coluna obrigatória | `null value in column "nome" of relation "..." violates not-null constraint` | A coluna é `NOT NULL` |

O erro 2 abre o gancho para a aula 8 (`ON DELETE`).

## O que muda entre as planilhas

- **A e D** têm tabela de itens (chave composta): o `DELETE` precisa apagar os itens antes da ocorrência principal.
- **B, C e E** não têm itens: o `DELETE` é direto. Em **B** e **E** a chave composta está em `matricula` e `estoque`.
- **C e D** guardam derivados? Não: o valor final da consulta e o total do aluguel **não são guardados** (calculam-se).
  Se um aluno guardar, pedir a justificativa (ver «Ponto para o confronto» no gabarito da aula 2).
- Os códigos gerados (`GENERATED ALWAYS AS IDENTITY`) seguem a ordem dos `INSERT`; por isso a carga pode usar `1`, `2`,
  `3` nas chaves estrangeiras. É frágil: aceite quem buscar o código com subconsulta, como o `03_dml.sql` faz.
- Os modelos dos alunos podem diferir (por exemplo, `idioma` em tabela própria na planilha B). Se o modelo é defensável
  e os scripts rodam, vale a pontuação inteira; confira se o `01_ddl.sql` tem as chaves e as ligações certas (a modelagem é lida no próprio DDL).
