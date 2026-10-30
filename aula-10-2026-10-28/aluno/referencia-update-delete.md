# Referência: `UPDATE` e `DELETE`

Banco de Dados 2 · Aula 10

`UPDATE` **muda** linhas que já existem e `DELETE` **apaga** linhas. Os dois fazem parte do DML (*Data Manipulation Language*, linguagem de
manipulação de dados), junto com o `INSERT`. Esta é a folha de consulta da aula; os exemplos usam a **Oficina Mecânica**. Não substitui a
documentação do PostgreSQL.

Siglas: **SQL** (*Structured Query Language*, linguagem de consulta estruturada), **FK** (*Foreign Key*, chave estrangeira),
**PK** (*Primary Key*, chave primária), **OS** (ordem de serviço).

## 1. O hábito: o `WHERE` primeiro

`UPDATE` e `DELETE` **sem `WHERE` valem para todas as linhas da tabela**. Não há «desfazer» automático. Por isso o caminho é sempre este:

1. Escreva o **`SELECT` com o `WHERE`** e rode: são essas as linhas que você quer mudar ou apagar?
2. Se a lista está certa, troque o começo do comando (`SELECT * FROM` por `UPDATE ... SET` ou `DELETE FROM`) **mantendo o mesmo `WHERE`**.
3. Rode.
4. **Confira** com outro `SELECT`.

```sql
SELECT * FROM servico WHERE descricao = 'Troca de óleo';                          -- 1. é esta linha?
UPDATE servico SET valor = 135.00 WHERE descricao = 'Troca de óleo';             -- 2 e 3. muda
SELECT descricao, valor FROM servico WHERE descricao = 'Troca de óleo';          -- 4. conferir
```

## 2. `UPDATE`

```sql
UPDATE tabela
SET coluna1 = valor1,
    coluna2 = valor2
WHERE condição;
```

| Parte | O que faz |
|---|---|
| `UPDATE servico` | A tabela que será alterada |
| `SET valor = 135.00` | A coluna e o **novo** valor. Para mais de uma coluna, separe por vírgula |
| `WHERE descricao = 'Troca de óleo'` | **Quais linhas** mudam |

Exemplos:

```sql
UPDATE servico SET valor = 135.00 WHERE descricao = 'Troca de óleo';            -- um valor novo
UPDATE servico SET valor = valor * 1.10 WHERE descricao = 'Alinhamento';        -- um cálculo sobre o valor antigo (+10%)
UPDATE mecanico SET especialidade = 'Elétrica' WHERE nome = 'Paulo Neri';       -- preencher um campo que estava vazio (NULL)
```

- O valor novo pode ser **uma conta com a própria coluna** (`valor * 1.10`).
- O `WHERE` pode pegar **mais de uma linha** (`WHERE valor < 100`). Por isso o `SELECT` antes.
- Texto e data ficam entre aspas simples; número e `NULL` ficam sem aspas.
- O `UPDATE` obedece às mesmas regras do `INSERT`: se a coluna é `NOT NULL`, não dá para pôr `NULL`; se há `CHECK`, o novo valor precisa passar.

## 3. `DELETE`

```sql
DELETE FROM tabela
WHERE condição;
```

```sql
DELETE FROM item_servico WHERE ordem_servico_id = (SELECT id FROM ordem_servico WHERE numero = 1008);
DELETE FROM ordem_servico WHERE numero = 1008;
```

- `DELETE FROM tabela;` (sem `WHERE`) **esvazia a tabela**. Só faça de propósito, num banco de teste.
- A subconsulta `(SELECT id FROM ordem_servico WHERE numero = 1008)` devolve o `id` da OS. Use quando o número do negócio e o `id` forem diferentes.

## 4. A ordem do `DELETE`

Para apagar um registro e **tudo o que pertence a ele**, apague das tabelas «filhas» para as «pai»:

```text
item_servico  (filha)   ← apague primeiro
ordem_servico (pai)     ← depois
```

Se você apagar a «pai» antes, o banco recusa:

```text
ERRO:  atualização ou exclusão em tabela "ordem_servico" viola restrição de chave estrangeira
       "item_servico_ordem_servico_id_fkey" em "item_servico"
DETALHE:  Chave (id)=(8) ainda é referenciada pela tabela "item_servico".
```

A mensagem diz **quem ainda usa** a linha: a tabela (`item_servico`), a constraint (`item_servico_ordem_servico_id_fkey`) e a chave (`id` 8). O banco está protegendo
o que ainda é usado; é isso que o teste **R2** do pedido mostra («apagar a cliente que tem veículos»).

Para a cliente Ana Souza sair, teria de sair antes tudo o que depende dela: itens das OS, OS, veículos e só depois a cliente. Na aula 10 você também vê
como o banco pode fazer isso sozinho (`ON DELETE CASCADE`; ver a [referência de integridade](referencia-integridade.md)).

## 5. Mudar um fato que tem histórico

O pedido diz **o que mudou**, não como o seu banco guarda o histórico. Na Entrada 3 da Oficina, o preço da troca de óleo muda de 120 para 135:

- **`UPDATE` no cadastro** (como na Oficina): o preço de tabela passa a ser 135. As OS antigas continuam cobrando 120 porque o **valor cobrado** foi gravado no item da OS.
- Em outros projetos, a mudança vira um **novo registro** (um `INSERT` de um preço novo com a data de vigência), e o preço antigo fica guardado.

Pergunta para decidir: **a informação antiga ainda importa?** Se importa, não sobrescreva: guarde a mudança como linha nova ou como histórico.

## 6. Conferir quantas linhas mudaram

- O DBeaver mostra as linhas afetadas.
- `RETURNING` devolve as linhas que foram alteradas ou apagadas, no mesmo comando:

```sql
UPDATE servico SET valor = 135.00 WHERE descricao = 'Troca de óleo' RETURNING id, descricao, valor;
DELETE FROM item_servico WHERE ordem_servico_id = 8 RETURNING *;
```

- Depois, confira com `SELECT count(*)` e compare com a quantidade esperada pelo pedido.

## 7. Se você errar: recriar o banco

O jeito mais simples de voltar ao ponto de partida é **rodar tudo do zero**: `01_ddl.sql` (que apaga e recria o schema) e depois o `entradas.sql`.
Por isso os dois arquivos precisam sempre rodar do zero, sem erro.

**Extra (aula 11, transações):** dá para testar um comando perigoso e desfazê-lo:

```sql
BEGIN;
UPDATE servico SET valor = 0;        -- sem WHERE: mudou TODAS as linhas
SELECT descricao, valor FROM servico;
ROLLBACK;                            -- desfaz: nada foi gravado
```

`BEGIN` abre uma transação; `ROLLBACK` a desfaz; `COMMIT` a grava. Se esquecer de fechar, o DBeaver pode ficar com a transação aberta.

## 8. Erros que você vai ver

As mensagens podem vir em português ou em inglês, conforme o servidor.

| Mensagem (resumo) | O que aconteceu | Como resolver |
|---|---|---|
| `viola restrição de chave estrangeira ... ainda é referenciada` / `update or delete on table ... violates foreign key constraint` | Você apagou (ou mudou o id de) uma linha que outra tabela ainda usa | Apague primeiro as «filhas», ou mude a regra com `ON DELETE` |
| `valor nulo na coluna ... viola a restrição de não-nulo` / `null value in column ... violates not-null constraint` | O `UPDATE` pôs `NULL` numa coluna obrigatória | Dê um valor |
| `nova linha da relação ... viola a restrição de verificação` / `new row for relation ... violates check constraint` | O novo valor não passa na `CHECK` | Use um valor que a regra aceita |
| `duplicar valor da chave viola a restrição de unicidade` / `duplicate key value violates unique constraint` | O novo valor já existe numa coluna `UNIQUE` | Troque o valor |
| `UPDATE 0` / `DELETE 0` | O `WHERE` não achou nenhuma linha (nome errado, acento, espaço) | Rode o `SELECT` do passo 1 e confira o texto |
| `UPDATE 6` quando você queria 1 | O `WHERE` pegou linhas demais, ou faltou | Recrie o banco e refaça com o `SELECT` antes |
