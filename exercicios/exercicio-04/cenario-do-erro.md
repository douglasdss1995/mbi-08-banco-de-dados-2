# Cenário do erro — tente quebrar o seu banco

Banco de Dados 2 · Aula 10

Você vai **atacar o próprio banco**: inserir lixo, apagar o que não deve e ver o que ele aceita. Tudo que o banco aceitar e não deveria é uma **regra do negócio sem defesa**.
Para cada falha, você cria a constraint (restrição) e ataca de novo, até o banco se defender.

Siglas: **FK** (*Foreign Key*, chave estrangeira), **SQL** (*Structured Query Language*, linguagem de consulta estruturada).

## Como funciona

O trabalho é individual, mas fica melhor com um colega do mesmo tema ou ao lado: um **ataca** (escreve o comando que tenta quebrar o banco) e o outro **confere**
(diz qual regra do negócio o ataque viola e se o banco recusou). Troquem a cada ataque. Quem trabalhar sozinho faz os dois papéis.

## Passo a passo

1. **Liste as regras.** Abra a seção de regras do seu projeto (o pedido de validação e o que você sabe do tema) e marque as que **o banco consegue** garantir sozinho: valor,
   faixa, lista de valores, formato, unicidade, relação obrigatória. Regras que dependem de outras linhas (limite de empréstimos por aluno, por exemplo) ficam para depois.
2. **Recrie o banco do zero** (`01_ddl.sql` e depois `entradas.sql`).
3. **Ataque.** Use o catálogo abaixo, sempre contra uma regra do seu tema. Um ataque por vez.
4. **Registre** o resultado: o banco aceitou ou recusou?
5. **Se aceitou**, escreva a constraint no `01_ddl.sql`, **recrie o banco** e **repita o ataque**: agora tem que recusar.
6. **Se a carga quebrar** na recriação, a constraint pegou um dado ruim do `entradas.sql`. Conserte o **dado** ou revise a **regra**, e anote qual dos dois no `achados.md`.

## Catálogo de ataques

| # | Ataque | Defesa provável |
|---|---|---|
| 1 | Inserir uma linha **sem** um campo obrigatório | `NOT NULL` |
| 2 | Inserir texto **vazio** ou só espaços onde há nome ou descrição | `CHECK (length(trim(...)) > 0)` |
| 3 | **Repetir** o que deve ser único: e-mail, código, documento, placa | `UNIQUE` |
| 4 | Número **impossível**: negativo, zero, acima do limite do negócio | `CHECK` |
| 5 | Data **impossível**: fim antes do início, entrega antes do pedido | `CHECK` entre duas colunas |
| 6 | Valor **fora da lista**: uma situação que não existe | `CHECK ... IN (...)` ou tabela de domínio com chave estrangeira |
| 7 | Apontar para um **pai que não existe** | `FOREIGN KEY` |
| 8 | **Apagar o pai** que tem filhos | `ON DELETE` (recusar, apagar junto ou anular, e escolher de propósito) |
| 9 | **Esquecer** um campo que deveria ter valor padrão (situação inicial, data de hoje) | `DEFAULT` |
| 10 | **Mudar** com `UPDATE` um valor para um que o `INSERT` nunca aceitaria | A mesma `CHECK` ou `UNIQUE`: confira o `UPDATE` também |

O ataque 10 é o mais esquecido: a constraint vale para `INSERT` **e** `UPDATE`, e quem só testa o `INSERT` não vê.

## Tabela de registro

Copie para o `ataques.sql`, como comentário, e preencha uma linha por ataque:

| # | Regra do negócio | Ataque (comando) | Aceitou antes? | Constraint criada | Recusou depois? |
|---|---|---|---|---|---|
| 1 | | | | | |
| 2 | | | | | |
| 3 | | | | | |
| 4 | | | | | |
| 5 | | | | | |

No `ataques.sql`, deixe os ataques escritos como comandos que **falham** (o banco recusa), com um comentário com a **mensagem de erro** e o **nome** da constraint.
Rode o arquivo sem `ON_ERROR_STOP`, comando por comando, ou o primeiro erro interrompe o resto.

Exemplo de uma linha da tabela, na Oficina:

| # | Regra do negócio | Ataque (comando) | Aceitou antes? | Constraint criada | Recusou depois? |
|---|---|---|---|---|---|
| 4 | O preço de um serviço é maior que zero | `INSERT INTO servico (descricao, valor) VALUES ('Teste', -10);` | Sim | `servico_valor_check` | Sim: `viola a restrição de verificação "servico_valor_check"` |

## Regras do cenário

- **Ataque com regra:** todo ataque precisa citar a regra do negócio que viola. «Inserir lixo» sem dizer qual regra não conta.
- **Não vale destruir o banco inteiro** (`DROP`, `TRUNCATE`) nem apagar sem `WHERE`: o ataque é sobre dados, não sobre o esquema.
- **O professor desafia:** durante a aula, ele propõe ataques que você ainda não tentou. Se o banco aceitar, anote e corrija.
- **Troque de lado:** se terminar antes, ataque o banco de um colega (com o `01_ddl.sql` e o `entradas.sql` dele) e entregue a ele a lista de falhas.
