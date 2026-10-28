# Referência: integridade (constraints)

Banco de Dados 2 · Aula 10

Uma folha de consulta para a aula e para o exercício. Os exemplos usam a **Oficina Mecânica**. Não substitui a documentação do PostgreSQL.

Siglas: **SQL** (*Structured Query Language*, linguagem de consulta estruturada), **PK** (*Primary Key*, chave primária), **FK** (*Foreign Key*,
chave estrangeira), **DDL** (*Data Definition Language*, linguagem de definição de dados), **DML** (*Data Manipulation Language*, linguagem de manipulação de dados).

## 1. Para que serve

O banco **se defende sozinho**: a regra do negócio vai para dentro dele, e vale para qualquer aplicativo, script ou pessoa que escreva nas tabelas. Uma regra
que só existe no aplicativo some no dia em que alguém conecta direto no banco.

Uma *constraint* (restrição) é uma regra que o banco confere a cada `INSERT` e a cada `UPDATE` (e, no caso da FK, a cada `DELETE`).

## 2. As constraints

| Constraint | Garante | Exemplo |
|---|---|---|
| `NOT NULL` | A coluna sempre tem valor | `nome varchar(100) NOT NULL` |
| `DEFAULT` | Valor usado quando o `INSERT` não informa a coluna | `data_abertura date NOT NULL DEFAULT CURRENT_DATE` |
| `PRIMARY KEY` | Cada linha é única e identificável (`NOT NULL` + `UNIQUE`) | `id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `UNIQUE` | Nenhum valor se repete (vários `NULL` são aceitos) | `placa char(7) NOT NULL UNIQUE` |
| `CHECK` | A linha obedece a uma condição | `CONSTRAINT servico_valor_check CHECK (valor > 0)` |
| `FOREIGN KEY` | Só se referencia o que existe | `cliente_id integer NOT NULL REFERENCES cliente (id)` |

`DEFAULT` não é uma proibição; é um valor padrão. Ele entra aqui porque define o estado inicial da linha.

## 3. Dentro do `CREATE TABLE`

```sql
CREATE TABLE servico (
    id        integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    descricao varchar(100) NOT NULL,
    valor     numeric(10,2) NOT NULL,
    ativo     boolean NOT NULL DEFAULT true,
    CONSTRAINT servico_descricao_key UNIQUE (descricao),
    CONSTRAINT servico_valor_check   CHECK (valor > 0)
);
```

- Dar **nome** à constraint (`CONSTRAINT nome ...`) é boa prática: a mensagem de erro mostra o nome.
- A turma segue o jeito do PostgreSQL, do [guia de estilo](guia-de-estilo.md): `tabela_coluna_sufixo`, com `_key` para `UNIQUE`, `_check` para `CHECK`, `_fkey` para chave estrangeira e `_pkey` para chave primária.
- Se você **não** der nome, o PostgreSQL cria um com esse mesmo jeito. Quando o erro disser `servico_valor_check`, você já sabe qual regra foi quebrada.

## 4. Em um banco que já existe (`ALTER TABLE`)

```sql
ALTER TABLE servico ADD CONSTRAINT servico_valor_check CHECK (valor > 0);
ALTER TABLE cliente ADD CONSTRAINT cliente_telefone_key UNIQUE (telefone);
ALTER TABLE cliente ALTER COLUMN telefone SET NOT NULL;
ALTER TABLE mecanico ALTER COLUMN especialidade SET DEFAULT 'Geral';
ALTER TABLE servico DROP CONSTRAINT servico_valor_check;
```

A constraint **nasce junto da tabela**, no `01_ddl.sql`. O `ALTER TABLE` serve para **testar** e para mudar um banco que já existe; depois, passe a regra para o `01_ddl.sql`.

Para descobrir o nome das constraints do seu schema (troque `oficina` pelo nome do seu):

```sql
SELECT conrelid::regclass AS tabela, conname, contype
FROM pg_constraint
WHERE connamespace = 'oficina'::regnamespace
  AND contype <> 'n'
ORDER BY 1, 2;
```

(`p` é chave primária, `f` é chave estrangeira, `u` é `UNIQUE` e `c` é `CHECK`. No PostgreSQL 18, o `NOT NULL` também aparece, como `n`; o `AND contype <> 'n'` tira essas linhas para a lista ficar curta.)

## 5. `CHECK`: o que cabe

| Regra | Condição |
|---|---|
| Valor positivo | `CHECK (valor > 0)` |
| Faixa | `CHECK (nota BETWEEN 0 AND 10)` |
| Lista de valores | `CHECK (situacao IN ('aberto', 'fechado', 'cancelado'))` |
| Entre colunas | `CHECK (data_fim >= data_inicio)` |
| Texto não vazio | `CHECK (length(trim(nome)) > 0)` |
| Formato (expressão regular) | `CHECK (placa ~ '^[A-Z]{3}[0-9][A-Z0-9][0-9]{2}$')` |

`~` testa a coluna contra uma **expressão regular**: `^` começa, `$` termina, `[A-Z]{3}` são três letras maiúsculas, `[0-9]` é um número. Uma `CHECK` que dá `NULL` **passa**:
para exigir valor, use `NOT NULL` também.

## 6. `UNIQUE` em mais de uma coluna

Quando a regra é «a **combinação** não se repete», a `UNIQUE` pega as colunas juntas:

```sql
ALTER TABLE item_servico ADD CONSTRAINT item_servico_os_servico_key UNIQUE (ordem_servico_id, servico_id);
```

Cada coluna sozinha pode repetir; o par não. É o caso de «a mesma reserva não pode se repetir (aluno, aula e data)» ou «o mesmo assento não pode ser vendido duas vezes na mesma sessão».

## 7. `ON DELETE`: o que acontece com os filhos

Definido na chave estrangeira do **filho**, para o caso de o **pai** ser apagado.

| Opção | Efeito | Quando usar |
|---|---|---|
| `RESTRICT` (ou `NO ACTION`, o padrão) | **Recusa** apagar o pai que tem filhos | Quando o filho não faz sentido sem o pai e não deve sumir sem querer (cliente com OS) |
| `CASCADE` | **Apaga os filhos** junto | Quando o filho é parte do pai (itens de uma OS) |
| `SET NULL` | **Anula** a chave do filho (a coluna precisa permitir `NULL`) | Quando o filho continua existindo sem o pai (mecânico que saiu) |

Para mudar a regra de uma chave estrangeira que já existe, **apague a constraint e crie de novo**:

```sql
ALTER TABLE item_servico DROP CONSTRAINT item_servico_ordem_servico_id_fkey;
ALTER TABLE item_servico ADD CONSTRAINT item_servico_ordem_servico_id_fkey
    FOREIGN KEY (ordem_servico_id) REFERENCES ordem_servico (id) ON DELETE CASCADE;
```

Cuidado com o `CASCADE`: ele apaga **sem perguntar**. Antes de usar, conte com um `SELECT` o que vai embora. Prefira `RESTRICT` quando houver dúvida, e **escolha de propósito**
(escrever `ON DELETE RESTRICT` deixa a escolha visível).

## 8. As mensagens de erro

| Mensagem (trecho) | Constraint |
|---|---|
| `valor nulo na coluna "x" ... viola a restrição de não-nulo` / `null value in column "x" ... violates not-null constraint` | `NOT NULL` |
| `duplicar valor da chave viola a restrição de unicidade "nome"` / `duplicate key value violates unique constraint "nome"` | `UNIQUE` ou `PRIMARY KEY` |
| `nova linha da relação "t" viola a restrição de verificação "nome"` / `new row for relation "t" violates check constraint "nome"` | `CHECK` |
| `insert ou update na tabela "t" viola restrição de chave estrangeira "nome"` / `insert or update on table "t" violates foreign key constraint "nome"` | `FOREIGN KEY`: o pai não existe |
| `atualização ou exclusão em tabela "t" viola restrição de chave estrangeira "nome"` / `update or delete on table "t" violates foreign key constraint "nome"` | `FOREIGN KEY`: ainda há filhos |

O **nome** da constraint, no fim da mensagem, mostra qual regra barrou o comando: `veiculo_placa_key` é o `UNIQUE` da coluna `placa` da tabela `veiculo`.

## 9. Armadilhas

- **A constraint nova pode falhar por causa do dado antigo.** O erro mostra a linha: conserte o dado ou revise a regra.
- **`UNIQUE` e `NULL`:** vários `NULL` são aceitos. Se a coluna é obrigatória, use `NOT NULL` também.
- **`CHECK` com `CURRENT_DATE`:** evite. A regra deixa de ser sempre verdadeira com o passar do tempo.
- **`CHECK` não consulta outra tabela.** Para a regra «o valor tem que estar numa lista que muda», use uma tabela de domínio e uma chave estrangeira.
- **Nem tudo vira constraint.** Regras que dependem de outras linhas (limite de 3 empréstimos por aluno, por exemplo) pedem *trigger* ou *procedure*, que vêm mais à frente no curso.
- **Se o seu R3 não deu erro e você não sabe como barrar** (por exemplo, «um exemplar não pode ter dois empréstimos abertos»), anote no `achados.md`. A [leitura extra](leitura-extra.md) mostra o índice único parcial; ela não cai em prova.
- **A carga precisa respeitar as constraints novas.** Se o `entradas.sql` quebrar depois que você acrescentou uma regra, conserte o **dado** ou revise a **regra**, e diga qual dos dois no `achados.md`.
