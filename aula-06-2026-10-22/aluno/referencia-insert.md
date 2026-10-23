# Referência: `INSERT`

Banco de Dados 2 · Aula 6

`INSERT` é o comando que **coloca linhas** em uma tabela. Faz parte do DML (*Data Manipulation Language*, linguagem de manipulação de
dados), o grupo dos comandos que mexem nos **dados**, e não na estrutura. Esta é a folha de consulta da aula. Os exemplos usam a
**Oficina Mecânica**. Não substitui a documentação do PostgreSQL.

Siglas: **FK** (*Foreign Key*, chave estrangeira), **PK** (*Primary Key*, chave primária), **SQL** (*Structured Query Language*,
linguagem de consulta estruturada), **CSV** (*Comma-Separated Values*, valores separados por vírgula).

## 1. Uma linha e várias linhas

```sql
INSERT INTO cliente (nome, telefone) VALUES ('Ana Souza', '(47) 99111-0001');

INSERT INTO cliente (nome, telefone) VALUES
    ('Bruno Reis', '(47) 99222-0002'),
    ('Carla Dias', '(47) 99333-0003');
```

| Parte | O que faz |
|---|---|
| `INSERT INTO cliente` | A tabela que recebe as linhas |
| `(nome, telefone)` | As colunas que você vai preencher, **na ordem em que vai dar os valores** |
| `VALUES (...)` | Uma linha. Para várias, separe os parênteses por vírgula; o `;` só vem no fim |
| Texto e data entre aspas simples | `'Ana'`, `'2025-03-02'` (ano-mês-dia). Número e `NULL` ficam sem aspas |

- **Tudo ou nada:** se **uma** linha do comando der erro, o comando inteiro é recusado e **nenhuma** linha entra.
- **`NULL`** é «sem valor». Só vale em coluna que **não** é `NOT NULL`. Escreva `NULL` sem aspas.
- Escreva as colunas sempre. `INSERT INTO cliente VALUES (...)` funciona, mas quebra quando alguém acrescenta uma coluna.

## 2. Coluna `IDENTITY`: não informe

Quando a coluna é `GENERATED ALWAYS AS IDENTITY` (a `id` das suas tabelas), **o banco numera sozinho**: 1, 2, 3... Deixe a coluna de
fora do `INSERT`. Se informar um valor, o banco recusa.

## 3. A ordem das tabelas

Primeiro as tabelas que **ninguém referencia** (as «pai»: `cliente`, `modelo`, `mecanico`, `servico`); depois as que têm **FK** para
elas (`veiculo`, `ordem_servico`); por último as de ligação (`item_servico`).

```text
cliente  ──┐
modelo   ──┴─► veiculo ──┐
mecanico ────────────────┴─► ordem_servico ──┐
servico ─────────────────────────────────────┴─► item_servico
```

Se você inserir um veículo **antes** do cliente dele, o banco recusa: o cliente ainda não existe.

## 4. Ids: de onde vêm os números das FK

Em uma coluna de FK você escreve o **id** da linha da outra tabela, e não o nome:

```sql
INSERT INTO veiculo (placa, modelo_id, cliente_id) VALUES ('ABC1D23', 1, 1);   -- modelo 1 (Gol), cliente 1 (Ana)
```

- **Banco recém-criado:** o 1º cliente é o 1, o 2º é o 2, e assim por diante. Dá para contar de cabeça.
- **Perigo:** se você rodar a carga duas vezes **sem recriar as tabelas**, os ids continuam de onde pararam (o 7, o 8...) e as FK
  apontam para o lugar errado. Por isso o script de carga sempre roda **depois do `01_ddl.sql`**, que apaga tudo e recria.
- **`id` não é o número do negócio.** A ordem de serviço tem `id` (1, 2, 3...) e `numero` (1001, 1002...). A FK usa o `id`.
  Para não errar, procure o id pelo número com uma subconsulta:

```sql
INSERT INTO item_servico (ordem_servico_id, servico_id, valor_cobrado) VALUES
    ((SELECT id FROM ordem_servico WHERE numero = 1001), 1, 120.00);
```

A subconsulta `(SELECT id FROM ordem_servico WHERE numero = 1001)` devolve o `id` da OS 1001. Use quando o número do negócio e o id
forem diferentes.

## 5. Conferir o que entrou

Por enquanto, só dois `SELECT` (as consultas de verdade vêm depois):

```sql
SELECT * FROM cliente;           -- mostra todas as linhas da tabela
SELECT count(*) FROM cliente;    -- quantas linhas a tabela tem
```

Depois de cada bloco do pedido, confira se a **quantidade de linhas** bate com o que o pedido manda.

## 6. Erros que você vai ver

As mensagens podem vir em português ou em inglês, conforme o servidor.

| Mensagem (resumo) | O que aconteceu | Como resolver |
|---|---|---|
| `viola restrição de chave estrangeira` / `violates foreign key constraint` | Você usou um id que **não existe** na outra tabela (ou inseriu na ordem errada) | Cadastre a linha «pai» primeiro, ou corrija o id |
| `valor nulo na coluna ... viola a restrição de não-nulo` / `null value ... violates not-null constraint` | Faltou um campo obrigatório | Preencha a coluna, ou veja se o pedido manda deixá-la vazia |
| `duplicar valor da chave viola a restrição de unicidade` / `duplicate key value violates unique constraint` | O valor já existe em uma coluna `UNIQUE` ou `PRIMARY KEY` | Troque o valor, ou apague a linha repetida |
| `cannot insert a non-DEFAULT value into column` | Você informou a coluna `IDENTITY` | Tire a coluna do `INSERT` |
| `não existe` / `does not exist` | O nome da tabela ou coluna está errado, ou você não rodou o `SET search_path` | Confira o nome e rode o `SET search_path TO ...` |

**Lembre:** um erro em um comando só interrompe aquele comando. Se o script usa `ON_ERROR_STOP`, ele para no primeiro erro.
O jeito mais seguro de conferir o `entradas.sql` é **rodar tudo do zero**: `01_ddl.sql` e depois `entradas.sql`.

## 7. Dados gerados com IA

A IA (inteligência artificial) ajuda a inventar nomes, e-mails e telefones fictícios. Peça sempre **dados fictícios** e confira:

- Os **números fecham** com o pedido (quantas linhas, quais valores)?
- Ela não **inventou** uma coluna que a sua tabela não tem, nem trocou a ordem das tabelas?
- Anote no `uso-de-ia.md` qual IA você usou e para quê.

## 8. Leitura extra: carregar um CSV com `\copy`

Se um dia tiver centenas de linhas, escrever `INSERT` à mão não compensa. O `\copy` lê um arquivo CSV (valores separados por vírgula):

```text
\copy cliente (nome, telefone) FROM 'clientes.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
```

- O `\copy` é um comando do `psql` (o terminal do PostgreSQL), **não** do SQL: não funciona em um script rodado no DBeaver ou no DataGrip, e
  fica em **uma linha só**, sem `;`.
- `HEADER true` diz que a 1ª linha é o cabeçalho. Deixe de fora a coluna `IDENTITY`.
- Não vale nota. É só para você saber que existe.
