# Guia de estilo para nomes no PostgreSQL

Banco de Dados 2 · Turma MBI-08 · Aula 10

---

## Antes de tudo: o que é este guia

Este guia é uma **mistura de convenções e boas práticas** que a comunidade de PostgreSQL usa.
Ele foi montado a partir de várias fontes (manual do PostgreSQL, guias de ferramentas e de empresas).

**Não é um padrão oficial.** Nenhuma empresa (nem o Google, nem a Microsoft, nem a equipe do PostgreSQL) recomenda este guia.

O que **é regra** do PostgreSQL está marcado como **Regra do banco**.
O que é **escolha da turma** está marcado como **Convenção**. Convenção você pode mudar,
mas dentro de um mesmo banco **todos os nomes seguem a mesma regra**.

---

## 1. Use letras minúsculas

**Convenção:** escreva os nomes de tabelas e colunas em minúsculas, separando as palavras com sublinhado (`_`).
Esse jeito se chama `snake_case` (em português, "caixa de cobra", porque o sublinhado lembra o corpo de uma cobra).

| Evite | Prefira |
|---|---|
| `DataNascimento` | `data_nascimento` |
| `ordemServico` | `ordem_servico` |
| `Nome Cliente` | `nome_cliente` |

Também **evite acentos, espaços e `ç`** nos nomes: `situacao`, não `situação`.

### E as palavras do SQL (`SELECT`, `INSERT`...)?

**Convenção:** o próprio manual do PostgreSQL diz que é comum escrever
as **palavras do SQL em MAIÚSCULAS** e os **nomes em minúsculas**:

```sql
SELECT nome, telefone
FROM cliente
WHERE id = 5;
```

Assim, quem lê separa na hora o que é comando e o que é nome do seu banco.
Funciona com maiúsculas ou minúsculas: é só para ficar fácil de ler.

---

## 2. Cuidado com as aspas duplas

**Regra do banco:** o PostgreSQL **transforma em minúsculas** todo nome escrito **sem aspas**.

```sql
CREATE TABLE Cliente (id integer);   -- o banco guarda: cliente
SELECT * FROM CLIENTE;               -- funciona (vira cliente)
SELECT * FROM cliente;               -- funciona
```

Os três são a mesma tabela. Tudo certo.

**Mas, se você usar aspas duplas, o nome fica exatamente como foi escrito:**

```sql
CREATE TABLE "Cliente" (id integer);   -- o banco guarda: Cliente (com C maiúsculo)
SELECT * FROM Cliente;                 -- ERRO: relation "cliente" does not exist
SELECT * FROM "Cliente";               -- funciona
```

O erro confunde muito: a tabela existe, mas o banco procurou `cliente` (minúsculo).

### O que fazer

- **Não use aspas duplas nos nomes.** Sem aspas, nunca há surpresa.
- Se uma ferramenta (como o DBeaver) criar um nome com aspas e maiúsculas, **troque o nome** para minúsculas.
- Aspas **duplas** (`"`) são para **nomes**. Aspas **simples** (`'`) são para **textos e datas**:
  `WHERE nome = 'Ana'`. Não confunda.

---

## 3. Não use prefixo que repete o tipo

**Convenção:** não comece o nome com `tbl_`, `col_`, `t_`, `fk_`.

| Evite | Prefira |
|---|---|
| `tbl_cliente` | `cliente` |
| `col_nome` | `nome` |

**Por quê?** O banco já sabe que `cliente` é uma tabela. O prefixo só deixa o nome mais comprido e não ajuda em nada.

---

## 4. Tabelas e colunas

| Item | Convenção | Exemplo |
|---|---|---|
| Nome da tabela | Um substantivo, sem prefixo | `cliente`, `ordem_servico` |
| Nome da coluna | **Singular** e descreve o dado | `nome`, `data_abertura` |
| Chave primária (PK: *Primary Key*) | `id` | `id` |
| Chave estrangeira (FK: *Foreign Key*) | nome da tabela de origem + `_id` | `cliente_id` |
| Data | começa com `data_` ou termina com `_em` | `data_abertura`, `criado_em` |
| Verdadeiro ou falso | uma palavra que responde sim ou não | `ativo`, `pago` |

### Tabela no singular ou no plural?

Os guias **não concordam**: uns preferem `cliente`, outros `clientes`. As duas formas estão certas.
O importante é **escolher uma e usar em todas as tabelas**.

Nas aulas de BD2 usamos o **singular** (`cliente`, `veiculo`, `ordem_servico`).
Se o seu projeto usa o plural, tudo bem, desde que seja assim em **todas** as tabelas.

### Exemplo completo

```sql
CREATE TABLE cliente (
    id       integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome     varchar(100) NOT NULL,
    telefone varchar(20)  NOT NULL
);

CREATE TABLE veiculo (
    id         integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    placa      char(7) NOT NULL UNIQUE,
    cliente_id integer NOT NULL REFERENCES cliente (id)
);
```

Repare que `veiculo.cliente_id` aponta para `cliente.id`. Quem lê o nome já entende para onde a ligação vai.

---

## 5. Limites e palavras proibidas

### Tamanho do nome

**Regra do banco:** um nome pode ter no máximo **63 bytes** (na prática, 63 letras sem acento).
Se passar, o PostgreSQL **corta o final sem erro** (só dá um aviso).
Nomes longos demais podem virar dois nomes iguais depois do corte.

### Letras permitidas

**Regra do banco:** o nome começa com **letra ou sublinhado** e depois pode ter letras, números e sublinhado.
Não pode começar com número: `1_cliente` dá erro.

### Palavras reservadas

**Regra do banco:** algumas palavras já têm significado no SQL, como `user`, `order`, `table`, `group`.
**Evite usá-las como nome.** Por isso a tabela da oficina se chama `ordem_servico`, e não `order`.

---

## 6. Nomes que o PostgreSQL cria sozinho

Quando você cria uma regra (constraint) **sem dar nome**, o PostgreSQL inventa um.
O jeito dele é `tabela_coluna_sufixo`:

| Tipo | Sufixo | Exemplo |
|---|---|---|
| Chave primária | `_pkey` | `cliente_pkey` |
| Chave estrangeira | `_fkey` | `veiculo_cliente_id_fkey` |
| Única (`UNIQUE`) | `_key` | `veiculo_placa_key` |
| Verificação (`CHECK`) | `_check` | `servico_valor_check` |

**Esse formato vem do comportamento do PostgreSQL, não é descrito no manual.** Mesmo assim ele aparece em todas
as mensagens de erro, então vale conhecer: quando o erro disser `veiculo_placa_key`, você já sabe que a regra
`UNIQUE` da coluna `placa` da tabela `veiculo` foi quebrada.

**Convenção:** se você der nome a uma regra ou a um índice, **siga o mesmo jeito**.
Para índice, o sufixo costumado é `_idx`: `veiculo_placa_idx`.

---

## 7. Resumo

| Faça | Evite |
|---|---|
| `snake_case` em minúsculas | Maiúsculas, espaços e acentos nos nomes |
| Palavras do SQL em maiúsculas | Misturar maiúsculas e minúsculas sem padrão |
| Nomes sem aspas duplas | `"Cliente"` entre aspas |
| `cliente` | `tbl_cliente` |
| `cliente_id` para a chave estrangeira | `fk_cli`, `codcli` |
| Mesma regra em todo o banco | Singular numa tabela e plural em outra |
| Nomes com menos de 63 letras | Nomes enormes |
| `ordem_servico` | `order` (palavra reservada) |

---

## De onde vêm as ideias

Este guia reúne:

- **o manual do PostgreSQL** (regra das minúsculas, aspas, limite de 63 bytes, maiúsculas nas palavras do SQL);
- **guias de ferramentas e de empresas** de banco de dados (nomes em `snake_case`, sufixos, sem prefixo de tipo).

Em todos esses casos, o que é **convenção** varia de um guia para outro. Por isso, o que vale na prática é:
**escolher um jeito e seguir em todo o projeto**.
