# Referência: `SELECT`

Banco de Dados 2 · Aula 9

`SELECT` é o comando que **lê** dados. Ele não altera nada no banco. Esta é a folha de consulta da aula; os exemplos usam a
**Oficina Mecânica**. Não substitui a documentação do PostgreSQL.

Siglas: **SQL** (*Structured Query Language*, linguagem de consulta estruturada), **FK** (*Foreign Key*, chave estrangeira),
**PK** (*Primary Key*, chave primária), **OS** (ordem de serviço).

## 1. Da pergunta ao `SELECT`

Antes de escrever, responda a quatro perguntas:

1. **O que a pergunta quer ver?** São as colunas do `SELECT`.
2. **Em quais tabelas esses dados estão?** São o `FROM` e os `JOIN`.
3. **Quais linhas interessam?** É o `WHERE` (período, nome, «nunca», «diferente de»).
4. **Quer uma linha por quê?** Uma linha por cliente, por serviço, por OS? É o `GROUP BY`.

Depois **compare o resultado com a coluna «O que sai»** do pedido. Se não bateu, pergunte: o erro está na consulta ou na estrutura?

## 2. Esqueleto

```sql
SELECT colunas
FROM tabela
JOIN outra ON ligação
WHERE filtro
GROUP BY colunas
ORDER BY colunas
LIMIT n;
```

Nem toda consulta usa todas as partes, mas **a ordem é sempre esta**.

| Parte | O que faz |
|---|---|
| `SELECT` | As colunas que aparecem. `*` é «todas» (bom para olhar, ruim para entregar) |
| `FROM` | A tabela principal |
| `JOIN ... ON` | Liga outra tabela; o `ON` diz **qual coluna casa com qual** |
| `WHERE` | Filtra as **linhas** antes de agrupar |
| `GROUP BY` | Junta as linhas em grupos |
| `ORDER BY` | Ordena o resultado. `DESC` é decrescente |
| `LIMIT` | Corta o número de linhas |
| `AS` | Dá um **apelido** a uma coluna ou tabela (`c` para `cliente`) |

## 3. `WHERE`: filtrar

```sql
SELECT descricao, valor FROM servico WHERE valor > 100;
SELECT * FROM servico WHERE descricao = 'Alinhamento';
SELECT * FROM ordem_servico WHERE data_abertura BETWEEN '2026-10-02' AND '2026-10-07';
SELECT * FROM servico WHERE descricao = 'Alinhamento' AND valor < 100;
```

| Operador | Significa |
|---|---|
| `=`, `<>` | Igual, diferente |
| `<`, `<=`, `>`, `>=` | Menor, menor ou igual, maior, maior ou igual |
| `BETWEEN a AND b` | Entre `a` e `b`, **incluindo as duas pontas** |
| `AND`, `OR`, `NOT` | E, ou, não. Use parênteses quando misturar |
| `IN ('a', 'b')` | Igual a algum da lista |
| `LIKE 'Troca%'` | Texto que começa com «Troca». `%` é «qualquer coisa» |
| `IS NULL`, `IS NOT NULL` | Está vazio, não está vazio |

- **Texto e data ficam entre aspas simples** (`'Alinhamento'`, `'2026-10-02'`). Número fica sem aspas. Aspas duplas são para nomes de tabela e coluna, e você não precisa delas.
- **`= NULL` nunca dá certo.** `NULL` é «sem valor», e «sem valor» não é igual a nada. Use `IS NULL`.

## 4. Contar e somar: funções de agregação

Uma função de agregação junta várias linhas em **um valor**.

| Função | O que faz |
|---|---|
| `count(*)` | Quantas linhas |
| `count(coluna)` | Quantas linhas têm essa coluna **preenchida** (ignora `NULL`) |
| `count(DISTINCT coluna)` | Quantos valores **diferentes** |
| `SUM(coluna)` | Soma |
| `AVG(coluna)` | Média |
| `MIN(coluna)`, `MAX(coluna)` | Menor e maior |
| `COALESCE(a, b)` | Devolve `a`, ou `b` se `a` for `NULL`. Usa-se para trocar «sem valor» por 0 |

```sql
SELECT count(*) FROM ordem_servico;                    -- 9
SELECT SUM(valor_cobrado) FROM item_servico;           -- soma de tudo
SELECT COALESCE(SUM(valor_cobrado), 0) FROM item_servico WHERE ordem_servico_id = 999;   -- 0, e não NULL
```

- A soma de nenhuma linha é `NULL`, e não 0. Por isso o `COALESCE`.
- Várias contagens independentes em uma linha só: `SELECT (SELECT count(*) FROM a) AS qtd_a, (SELECT count(*) FROM b) AS qtd_b;`.
  Cada `(SELECT ...)` entre parênteses devolve um único valor.

## 5. `GROUP BY`: uma linha por grupo

```sql
SELECT s.descricao, count(i.servico_id) AS vezes
FROM servico s
LEFT JOIN item_servico i ON i.servico_id = s.id
GROUP BY s.descricao
ORDER BY vezes DESC;
```

- **Regra de ouro:** toda coluna do `SELECT` que **não** está dentro de uma função de agregação precisa estar no `GROUP BY`.
- O `WHERE` filtra **antes** de agrupar. O `HAVING` (extra) filtra **depois**, para condições sobre o resultado da agregação (por exemplo, «só quem tem mais de 2»).
- Agrupe por uma coluna que **identifica** o grupo. Dois clientes com o mesmo nome seriam somados juntos; o ideal é agrupar também pelo `id`.

## 6. `JOIN` e `LEFT JOIN`

| Tipo | O que devolve |
|---|---|
| `JOIN` (ou `INNER JOIN`) | Só as linhas que **têm par** nas duas tabelas |
| `LEFT JOIN` | **Todas** as linhas da tabela da esquerda, com ou sem par. Sem par, as colunas da direita vêm `NULL` |

```text
cliente          veiculo
 Ana     ───────  ABC1D23
 Ana     ───────  DEF4G56
 Fábio   ─── (sem veículo)
```

- `JOIN`: o Fábio **some** (não tem veículo).
- `LEFT JOIN` partindo de `cliente`: o Fábio **aparece**, com a placa vazia.
- **Quando o pedido diz «todo X aparece»**, comece pela tabela do X e use `LEFT JOIN` para as outras.
- Em uma cadeia de `LEFT JOIN`, **todos** os que vêm depois devem ser `LEFT JOIN` também; um `JOIN` no meio tira de volta quem você queria manter.
- O `ON` liga a **FK** à **PK** (`v.cliente_id = c.id`). Se esquecer o `ON`, o resultado multiplica as linhas.

## 7. «Quem nunca...»

Duas maneiras de achar o que **não tem** par:

```sql
-- LEFT JOIN + IS NULL: veículos que nunca tiveram uma OS
SELECT v.placa
FROM veiculo v
LEFT JOIN ordem_servico o ON o.veiculo_id = v.id
WHERE o.id IS NULL;

-- NOT EXISTS: clientes que nunca tiveram uma OS
SELECT c.nome
FROM cliente c
WHERE NOT EXISTS (
    SELECT 1 FROM veiculo v JOIN ordem_servico o ON o.veiculo_id = v.id
    WHERE v.cliente_id = c.id
);
```

- Na primeira, o veículo sem OS fica com `o.id` vazio; o `WHERE o.id IS NULL` deixa só esses.
- Na segunda, a subconsulta olha o cliente da linha atual; `NOT EXISTS` é verdadeiro quando ela **não acha nada**. O `SELECT 1` é convenção: só importa se existe linha.
- Use a que você entender melhor. Se a ligação passa por mais de uma tabela, o `NOT EXISTS` costuma ficar mais claro.

## 8. Um detalhe que muda o resultado: o que contar

Ao ligar tabelas de «um para muitos», a linha da tabela de cima se **repete** uma vez por filho. Isso afeta a contagem:

- `count(*)` conta a linha do `LEFT JOIN` mesmo quando o filho não existe: dá 1 onde o certo seria 0.
- `count(i.servico_id)` conta só os filhos que existem: dá 0 para o serviço nunca prestado.
- `count(DISTINCT o.id)` conta cada OS **uma vez só**, mesmo que ela apareça repetida por causa dos itens.

## 9. Datas

```sql
SELECT current_date;                                  -- a data de hoje
SELECT date_trunc('month', current_date)::date;       -- o dia 1 deste mês
SELECT date_trunc('month', current_date)::date + 6;   -- o dia 7 deste mês
```

- `date_trunc('month', data)` corta a data no começo do mês. Devolve data com hora, e o `::date` deixa só a data, para poder somar dias.
- Data mais um número é a data N dias depois. Com `BETWEEN`, as duas pontas entram.
- O pedido dá só o **dia**. Use o mês corrente, como na carga (`data_abertura = início do mês + dia - 1`).

## 10. Juntar texto de várias linhas

```sql
SELECT o.numero, string_agg(s.descricao, ', ' ORDER BY s.descricao) AS servicos
FROM ordem_servico o
LEFT JOIN item_servico i ON i.ordem_servico_id = o.id
LEFT JOIN servico s ON s.id = i.servico_id
GROUP BY o.numero;
```

`string_agg(texto, separador)` junta os textos do grupo em um só, e o `ORDER BY` de dentro define a ordem das partes. Ignora `NULL`: uma OS sem serviço devolve vazio.

## 11. Erros que você vai ver

As mensagens podem vir em português ou em inglês, conforme o servidor.

| Mensagem (resumo) | O que aconteceu | Como resolver |
|---|---|---|
| `a coluna ... deve aparecer na cláusula GROUP BY ou ser usada em uma função de agregação` / `column ... must appear in the GROUP BY clause or be used in an aggregate function` | Há coluna no `SELECT` sem agregação e fora do `GROUP BY` | Acrescente a coluna ao `GROUP BY`, ou agregue-a |
| `a referência à coluna "id" é ambígua` / `column reference "id" is ambiguous` | Duas tabelas têm a coluna `id` e você não disse de qual | Escreva `c.id`, `v.id`, com o apelido da tabela |
| `a coluna ... não existe` / `column ... does not exist` | O nome da coluna está errado, ou a coluna é de outra tabela | Confira o nome em `SELECT * FROM tabela LIMIT 1` |
| `a relação "..." não existe` / `relation "..." does not exist` | O nome da tabela está errado, ou faltou o `SET search_path` | Confira o nome e rode o `SET search_path TO ...` |
| `erro de sintaxe em ou próximo a ...` / `syntax error at or near ...` | Falta vírgula, parêntese, aspas ou há vírgula a mais antes do `FROM` | Olhe a palavra que o erro aponta e a linha de cima |
| Resultado com **linhas demais** | `JOIN` sem `ON` ou com `ON` errado | Confira a ligação FK = PK |
| Uma linha sumiu (por exemplo, o cliente sem veículo) | Você usou `JOIN` onde o pedido pede «todo X aparece» | Troque por `LEFT JOIN`, a partir da tabela do X |

## 12. Dicas de trabalho

- Escreva a consulta **aos poucos**: comece pelo `FROM` e pelos `JOIN` com `SELECT *`, veja as linhas, depois troque pelas colunas e acrescente `WHERE` e `GROUP BY`.
- Rode e **compare com «O que sai»** a cada consulta, antes de ir para a próxima.
- Cada consulta no `consultas.sql` começa com um comentário com o seu número (`-- C1`).
- Uma consulta que **funciona** mas devolve o valor errado é mais perigosa do que uma que dá erro. Confira os números.
