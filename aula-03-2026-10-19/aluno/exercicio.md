# Exercício 2 — DDL e DML

Banco de Dados 2 · Turma MCI-05 · Assunto 2 de 15 · Aula 3

|                   |                                                                                                     |
| ----------------- | --------------------------------------------------------------------------------------------------- |
| **Individual**    | Cada aluno entrega o seu                                                                            |
| **Como entregar** | Uma atividade no Google Classroom, com os arquivos `.sql` e os prints                                |
| **Prazo**         | Sem horário limite por dia. O ideal é entregar até o fim da aula 3 (19/10). Vale entregar até 18/11 |
| **Nota**          | De 0 a 10 (pontos indicados em cada item)                                                           |
| **IA**            | Liberada. Anote no fim da entrega qual IA usou e para quê, e saiba explicar tudo o que entregou     |
| **Correção**      | Outro grupo corrige o seu trabalho e a sua modelagem (veja «A correção cruzada», no fim)            |

Nesta aula, o professor mostra **ao vivo, na frente de todos**, como criar e carregar um banco, usando o modelo da
**Oficina Mecânica** (veja [cenario-oficina-mecanica.md](cenario-oficina-mecanica.md)). Você acompanha e depois repete o
que foi mostrado nas **tabelas da planilha que o seu grupo normalizou na aula 2** (a oficina de normalização, planilhas
A a E). No tempo de projeto, o grupo leva o mesmo caminho para o **projeto**.

Você vai criar, no PostgreSQL, o banco da sua planilha, carregar dados, alterar e apagar linhas, e provocar erros de
propósito para entender o que o banco recusa. Use o seu cliente (DBeaver ou DataGrip). Os comandos podem ser rodados
também pelo `psql`, no terminal.

## As tabelas de cada planilha

Se a sua normalização da aula 2 ficou diferente do quadro mostrado hoje, **corrija-a antes de começar** (o professor
mostra as tabelas corretas das cinco planilhas). Os nomes abaixo são os do quadro; use-os para os `ALTER TABLE` e os
`UPDATE` pedidos.

| Planilha | Assunto            | Tabelas (em terceira forma normal, 3FN)                                       |
| -------- | ------------------ | ----------------------------------------------------------------------------- |
| A        | Pedidos            | `cidade`, `cliente`, `vendedor`, `produto`, `pedido`, `item_pedido`           |
| B        | Matrículas         | `aluno`, `professor`, `turma`, `matricula`                                    |
| C        | Consultas          | `convenio`, `paciente`, `especialidade`, `medico`, `consulta`                 |
| D        | Aluguéis           | `cliente`, `equipamento`, `contrato`, `item_contrato`                         |
| E        | Estoque            | `fornecedor`, `produto`, `deposito`, `estoque`                                |

## Parte A · A estrutura (DDL, *Data Definition Language*) · 4 pontos

### A.1 O banco (0,5 ponto)

Crie um banco chamado `bd2_planilha` e conecte-se a ele. Use as tabelas da sua planilha como estão no quadro; elas
viram `CREATE TABLE` no próximo item, com as chaves primárias (PK, *Primary Key*) e estrangeiras (FK, *Foreign Key*).

### A.2 O script `01_ddl.sql` (2,5 pontos)

Escreva em **um arquivo** `01_ddl.sql` o script que cria **todas as tabelas da sua planilha**, com:

- chaves primárias (inclusive a **composta**, se a sua planilha tiver uma tabela de itens ou de ligação);
- chaves estrangeiras (`REFERENCES`);
- `NOT NULL` onde a informação é obrigatória;
- pelo menos um valor padrão (`DEFAULT`), por exemplo `CURRENT_DATE` em uma coluna de data;
- tipos adequados: dinheiro em `numeric`, texto com `varchar`, datas em `date`.

O script deve poder ser **executado várias vezes**: no começo, apague as tabelas com `DROP TABLE IF EXISTS`, na ordem
certa (primeiro as que têm chave estrangeira).

### A.3 Alterações com `ALTER TABLE` (1 ponto)

No fim do `01_ddl.sql`, acrescente três comandos `ALTER TABLE`:

1. uma coluna `email` (texto, opcional) na tabela das pessoas atendidas;
2. uma coluna `observacao` (texto livre, opcional) na tabela principal, a que registra cada ocorrência;
3. uma coluna `ativo` (verdadeiro ou falso, obrigatória, com padrão `true`) na tabela de quem presta o serviço.

| Planilha | 1 · `email` em | 2 · `observacao` em | 3 · `ativo` em |
| -------- | -------------- | ------------------- | -------------- |
| A        | `cliente`      | `pedido`            | `vendedor`     |
| B        | `aluno`        | `matricula`         | `professor`    |
| C        | `paciente`     | `consulta`          | `medico`       |
| D        | `cliente`      | `contrato`          | `equipamento`  |
| E        | `fornecedor`   | `estoque`           | `deposito`     |

## Parte B · Os dados (DML, *Data Manipulation Language*) · 4 pontos

### B.1 A carga, no arquivo `02_carga.sql` (1,5 ponto)

Escreva um arquivo com os `INSERT` que carregam o banco, com **pelo menos 5 linhas em cada tabela**, na ordem correta
das chaves estrangeiras. Inclua as linhas da sua planilha original (o `.csv` da pasta `planilhas-oficina`) e invente os demais dados.

### B.2 Alterar com `UPDATE` (1 ponto)

Escreva e execute, **sempre com `WHERE`**:

1. a mudança de um dado de uma pessoa ou de um cadastro;
2. uma alteração que atinja **várias linhas de uma vez**.

| Planilha | 1 · Um dado de uma pessoa                  | 2 · Várias linhas de uma vez                                      |
| -------- | ------------------------------------------ | ----------------------------------------------------------------- |
| A        | trocar a cidade de um `cliente`            | reajuste de 10% no `preco` dos produtos de uma faixa de preço     |
| B        | trocar o `fone` de um `professor`          | trocar a `sala` de todas as turmas de um professor                |
| C        | trocar o convênio de um `paciente`         | reajuste de 10% no `valor_base` das especialidades acima de R$ 200 |
| D        | trocar o telefone de um `cliente`          | reajuste de 10% na `diaria` dos equipamentos mais caros           |
| E        | trocar o `fone` de um `fornecedor`         | reajuste de 10% no `custo_unit` dos produtos de um fornecedor     |

Antes e depois de cada `UPDATE`, rode um `SELECT` para conferir o que mudou.

### B.3 Apagar com `DELETE` (0,5 ponto)

Apague **uma ocorrência da tabela principal** (`pedido`, `matricula`, `consulta`, `contrato` ou uma linha de `estoque`)
e, se ela tiver itens, apague os itens também. Pense na ordem: o que precisa sair primeiro?

### B.4 Os três erros de propósito (1 ponto)

Provoque os três erros abaixo, copie a mensagem que o PostgreSQL mostrou e explique, em uma frase cada, **por que o
banco recusou**:

1. inserir, em uma tabela com chave estrangeira, uma linha que aponta para um código que não existe;
2. apagar uma linha que ainda é referenciada por outra tabela (por exemplo, um cliente que já tem pedidos);
3. inserir uma linha sem preencher uma coluna `NOT NULL`.

## Parte C · Do zero · 2 pontos

Prove que o seu banco **roda do zero**:

1. apague o banco (ou todas as tabelas);
2. execute `01_ddl.sql` e depois `02_carga.sql`, **sem nenhum erro**;
3. rode `SELECT count(*)` em cada tabela e tire um print com os resultados.

## A correção cruzada

Depois de terminar, suba para o repositório do seu grupo, na pasta `exercicio-2/<seu-nome>/`, os arquivos
`01_ddl.sql`, `02_carga.sql` e `03_dml.sql` (os comandos de B.2, B.3 e B.4).

Na **aula 4**, o outro grupo que normalizou a **mesma planilha** corrige o seu trabalho, e você corrige o dele: cada
pessoa fica com o trabalho de um colega do outro grupo. A correção olha **a modelagem** (as tabelas em 3FN, as chaves e
as ligações) **e os scripts** (rodam do zero, sem erro). Use a [ficha de correção cruzada](ficha-correcao-cruzada.md).
A ficha serve para quem fez corrigir o próprio trabalho e, se quiser, entregar de novo no Classroom até 18/11.

## O que entregar

- [ ] `01_ddl.sql` e `02_carga.sql`.
- [ ] Os comandos do B.2, B.3 e B.4 (pode ser um terceiro arquivo, `03_dml.sql`).
- [ ] As mensagens de erro do B.4 e a explicação de cada uma.
- [ ] O print da Parte C.
- [ ] Se usou IA: qual e para quê.

## Dicas

- Crie as tabelas **de fora para dentro**: primeiro as que ninguém referencia (as das pessoas e dos cadastros), por último
  as que têm chaves estrangeiras.
- Para apagar, é o contrário: primeiro as que têm chave estrangeira.
- Quando uma coluna usa `GENERATED ALWAYS AS IDENTITY`, **não** informe o valor dela no `INSERT`.
- Antes de qualquer `UPDATE` ou `DELETE`, rode o mesmo `WHERE` em um `SELECT`.
