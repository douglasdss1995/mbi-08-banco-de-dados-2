# Referência: DDL

Banco de Dados 2 · Turma MBI-08 · Aula 6

DDL (*Data Definition Language*, linguagem de definição de dados) são os comandos que **criam e mudam a estrutura** do banco:
schemas, tabelas, colunas e chaves. Esta é a folha de consulta da aula.

Siglas: **PK** (*Primary Key*, chave primária), **FK** (*Foreign Key*, chave estrangeira), **N:N** (muitos para muitos).

## O esqueleto do script

Todo script do projeto começa assim, para poder rodar de novo quantas vezes precisar:

```sql
DROP SCHEMA IF EXISTS meu_projeto CASCADE;
CREATE SCHEMA meu_projeto;
SET search_path TO meu_projeto;
```

- `DROP SCHEMA ... CASCADE` apaga o schema e tudo o que está dentro. Por isso o script **recria tudo do zero**.
- `SET search_path` diz em qual schema as tabelas seguintes serão criadas.

## Criar uma tabela

```sql
CREATE TABLE cliente (
    id       integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome     varchar(100) NOT NULL,
    telefone varchar(20)  NOT NULL
);
```

| Parte | O que faz |
|---|---|
| `integer GENERATED ALWAYS AS IDENTITY` | O banco numera sozinho (1, 2, 3...). Você não informa o `id` |
| `PRIMARY KEY` | Identifica cada linha; não repete e não fica vazio |
| `NOT NULL` | O campo é obrigatório |
| `UNIQUE` | O valor não pode se repetir na tabela |
| `DEFAULT valor` | Valor usado quando você não informa nada |

## Ligar uma tabela a outra (FK)

```sql
CREATE TABLE veiculo (
    id         integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    placa      char(7) NOT NULL UNIQUE,
    cliente_id integer NOT NULL REFERENCES cliente (id)
);
```

`REFERENCES cliente (id)` cria a **FK**: o valor de `cliente_id` precisa existir em `cliente.id`.
**Por isso a tabela `cliente` precisa ser criada antes de `veiculo`.**

## Tabela de ligação (N:N)

Quando duas tabelas se relacionam de muitos para muitos, crie uma terceira com as duas FK. A PK é a combinação das duas:

```sql
CREATE TABLE item_servico (
    ordem_servico_id integer NOT NULL REFERENCES ordem_servico (id),
    servico_id       integer NOT NULL REFERENCES servico (id),
    valor_cobrado    numeric(10,2) NOT NULL,
    PRIMARY KEY (ordem_servico_id, servico_id)
);
```

## Os tipos que vamos usar

| O dado é... | Tipo | Exemplo |
|---|---|---|
| Número inteiro | `integer` | quantidade, número da OS |
| Número que o banco gera sozinho | `integer GENERATED ALWAYS AS IDENTITY` | o `id` |
| Texto com limite | `varchar(n)` | nome, descrição |
| Texto de tamanho fixo | `char(n)` | placa (7 caracteres) |
| Texto longo | `text` | observação, mensagem |
| Dinheiro ou valor com centavos | `numeric(10,2)` | preço. **Nunca `float`** |
| Só o dia | `date` | data de abertura |
| Dia e hora | `timestamp` | quando aconteceu |
| Sim ou não | `boolean` | ativo, pago |
| Dados que variam de linha para linha | `jsonb` | características de um produto |

Telefone, CPF, CEP e placa são **texto**, não número: você não soma nem faz conta com eles.

## Do dicionário para o `CREATE TABLE`

1. Uma tabela do dicionário vira um `CREATE TABLE`.
2. Um campo vira uma coluna. Escolha o **tipo** pelo que o dado é (veja a tabela acima).
3. O `id` vira `integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY`.
4. Um campo que liga a outra tabela (`cliente_id`) vira `integer ... REFERENCES cliente (id)`.
5. Se a explicação diz «obrigatório», «não se repete» ou «pode ficar vazio», use `NOT NULL`, `UNIQUE` ou deixe sem `NOT NULL`.
6. Crie primeiro as tabelas que **não dependem de nenhuma outra**; depois as que dependem; por último as de ligação.

## Erros comuns

| Mensagem | O que quer dizer |
|---|---|
| `relação "x" não existe` | Você está ligando a uma tabela que ainda não foi criada. Mude a ordem |
| `relação "x" já existe` | A tabela já foi criada antes. Rode o `DROP SCHEMA` no começo do script |
| `erro de sintaxe em ou perto de ...` | Falta vírgula, parêntese ou ponto e vírgula. Olhe a linha anterior ao erro |
| `não existe a coluna "x"` | O nome da coluna está diferente do dicionário |
