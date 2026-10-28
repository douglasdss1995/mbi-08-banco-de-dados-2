# Leitura extra — o que pode ajudar o seu projeto

Banco de Dados 2 · Aula 10

**Não cai em prova.** É o que não foi dado em aula, mas pode ajudar quando o seu projeto pedir uma regra que `UNIQUE` e `CHECK` sozinhos não resolvem, ou quando você
estiver em dúvida sobre o tipo de uma coluna. Os exemplos usam a **Oficina Mecânica** e um pequeno exemplo de empréstimos.

Siglas: **SQL** (*Structured Query Language*, linguagem de consulta estruturada), **PK** (*Primary Key*, chave primária), **FK** (*Foreign Key*, chave estrangeira).

## 1. Índice único parcial: «só uma linha **ativa** por vez»

**Problema.** Um exemplar não pode ter dois empréstimos **abertos** ao mesmo tempo (R3 da biblioteca), mas pode ter muitos empréstimos já **devolvidos**. Um `UNIQUE (exemplar_id)`
comum bloquearia também o histórico. A regra vale só para as linhas ainda não devolvidas.

**Solução.** Um índice único que só enxerga as linhas que obedecem a uma condição:

```sql
CREATE TABLE emprestimo (
    id           integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    exemplar_id  integer NOT NULL,
    leitor       varchar(100) NOT NULL,
    devolvido_em date            -- NULL = ainda não devolvido
);

CREATE UNIQUE INDEX emprestimo_exemplar_aberto_idx
    ON emprestimo (exemplar_id)
    WHERE devolvido_em IS NULL;
```

- O `WHERE devolvido_em IS NULL` faz o índice valer só para os empréstimos **abertos**: nenhum exemplar aparece duas vezes entre eles.
- Depois de devolvido (`devolvido_em` preenchido), a linha sai do índice e o exemplar pode ser emprestado de novo.

```sql
INSERT INTO emprestimo (exemplar_id, leitor) VALUES (1, 'Lia');                          -- aberto: entra
INSERT INTO emprestimo (exemplar_id, leitor) VALUES (1, 'Caio');                         -- ERRO: já está emprestado
UPDATE emprestimo SET devolvido_em = current_date WHERE leitor = 'Lia';                  -- devolve
INSERT INTO emprestimo (exemplar_id, leitor) VALUES (1, 'Caio');                         -- agora entra
```

A mensagem do erro é a de qualquer `UNIQUE` (`duplicar valor da chave viola a restrição de unicidade "emprestimo_exemplar_aberto_idx"`).
O mesmo desenho serve para «um entregador só tem uma entrega ativa por vez» (R3 do delivery): a condição do `WHERE` é a que define «ativa».

## 2. `EXCLUDE`: períodos que não se sobrepõem

**Problema.** Um quarto não pode ter duas reservas cujos períodos se cruzam. `UNIQUE` não resolve, porque os períodos nunca são exatamente iguais.

**Solução.** Uma constraint `EXCLUDE` com `daterange` (intervalo de datas):

```sql
CREATE EXTENSION IF NOT EXISTS btree_gist;     -- pode exigir permissão de administrador

CREATE TABLE reserva (
    id         integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    quarto_id  integer NOT NULL,
    entrada    date NOT NULL,
    saida      date NOT NULL,
    CONSTRAINT reserva_datas_check CHECK (saida > entrada),
    CONSTRAINT reserva_quarto_periodo_excl
        EXCLUDE USING gist (quarto_id WITH =, daterange(entrada, saida) WITH &&)
);

INSERT INTO reserva (quarto_id, entrada, saida) VALUES (101, '2026-11-10', '2026-11-13');   -- entra
INSERT INTO reserva (quarto_id, entrada, saida) VALUES (101, '2026-11-12', '2026-11-15');   -- ERRO: cruza o período
INSERT INTO reserva (quarto_id, entrada, saida) VALUES (101, '2026-11-13', '2026-11-15');   -- entra (começa quando a outra termina)
INSERT INTO reserva (quarto_id, entrada, saida) VALUES (102, '2026-11-12', '2026-11-15');   -- entra (outro quarto)
```

- `quarto_id WITH =`: só compara reservas **do mesmo quarto**.
- `daterange(entrada, saida) WITH &&`: o operador `&&` quer dizer «os intervalos se sobrepõem». A reserva é recusada se o quarto é o mesmo **e** os intervalos se cruzam.
- `daterange(a, b)` inclui `a` e **não** inclui `b`, por isso a saída de uma reserva no dia 13 deixa a próxima entrar no dia 13.
- Se o servidor da sua máquina não deixar criar a extensão `btree_gist`, anote no `achados.md` e use a [referência de integridade](referencia-integridade.md) para as outras regras.

## 3. Escolher o tipo de dado

O DDL (*Data Definition Language*, linguagem de definição de dados) pede um tipo para cada coluna. Um guia curto para decidir:

| Dado | Tipo | Por quê |
|---|---|---|
| Identificador (`id`) | `integer GENERATED ALWAYS AS IDENTITY` | O banco numera sozinho. `bigint` só se esperar bilhões de linhas |
| Dinheiro e quantidades com casas decimais | `numeric(10,2)` | Exato. **Não use `real` nem `double precision` para dinheiro**: eles arredondam |
| Quantidade inteira (estoque, número de vagas) | `integer` | Com `CHECK (quantidade >= 0)` |
| Texto curto com limite conhecido (nome, placa) | `varchar(n)` ou `char(n)` | `char(n)` completa com espaços, use só para tamanho fixo (placa: 7) |
| Texto livre, sem limite natural (observação) | `text` | No PostgreSQL, `text` e `varchar` têm o mesmo desempenho |
| Dia (data de nascimento, vencimento) | `date` | Só a data |
| Momento exato (abertura de chamado, compra) | `timestamp` (ou `timestamptz`, com fuso horário) | Data **e** hora. Prefira `timestamptz` quando houver pessoas em fusos diferentes |
| Sim ou não | `boolean` | `true`/`false`, sem texto `'S'`/`'N'` |
| Lista fixa de valores (situação) | `varchar` + `CHECK ... IN (...)` ou tabela de domínio | A tabela de domínio vale se a lista muda |
| Preço de hoje x preço cobrado | Duas colunas | O preço de tabela muda; o valor cobrado fica gravado na venda |

Perguntas úteis antes de escolher:

- A coluna pode ficar vazia? Se não, `NOT NULL`.
- Existe um limite ou uma lista? Se sim, `CHECK`.
- Dois registros podem ter o mesmo valor? Se não, `UNIQUE`.
- O valor é um **identificador** (CPF, CNPJ, telefone, CEP) ou um **número** de verdade? Identificador é **texto**: você não faz conta com ele e o zero à esquerda importa.

## 4. Onde ir depois

- A documentação do PostgreSQL tem as páginas «Constraints», «Índices parciais» e «Tipos de dados».
- Para regras que dependem de **outras linhas** (limite de empréstimos por leitor, por exemplo), o caminho são *triggers* e *procedures*, que o curso mostra mais à frente.
