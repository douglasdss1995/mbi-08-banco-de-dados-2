# Exercício — Mudar, apagar e proteger o seu projeto

Banco de Dados 2 · Aula 10

|                   |                                                                                                     |
| ----------------- | --------------------------------------------------------------------------------------------------- |
| **Individual**    | Cada aluno entrega o seu                                                                            |
| **Como entregar** | Uma atividade no Google Classroom, com os arquivos `entradas.sql`, `01_ddl.sql`, `ataques.sql`, `achados.md` e `uso-de-ia.md` |
| **Prazo**         | Sem horário limite por dia. O ideal é entregar até o fim da aula 11. Vale entregar até o último dia de aula |
| **Nota**          | De 0 a 10 (pontos indicados em cada item)                                                           |
| **IA**            | Liberada. Anote no `uso-de-ia.md` qual IA usou e para quê, e saiba explicar tudo o que entregou     |
| **Colaboração**   | Pode trocar ideias com colegas. Anote **com quem conversou** e sobre o quê                           |

Na aula 10, o professor mudou e apagou dados na **Oficina Mecânica** (`UPDATE`, `DELETE`), viu os erros que o banco devolve quando a ordem ou a regra está errada e
acrescentou constraints (restrições) para o banco se defender. Agora você faz o mesmo no banco do **seu** projeto, com o pedido do seu tema
(na pasta `pedidos-de-validacao`, publicado no Classroom).

Siglas: **SQL** (*Structured Query Language*, linguagem de consulta estruturada), **DML** (*Data Manipulation Language*, linguagem de manipulação de dados),
**FK** (*Foreign Key*, chave estrangeira), **DDL** (*Data Definition Language*, linguagem de definição de dados).

Apoio: [referência de `UPDATE` e `DELETE`](referencia-update-delete.md), [referência de integridade](referencia-integridade.md) e
[cenário do erro](cenario-do-erro.md). O [guia de estilo](guia-de-estilo.md) ajuda a dar nome às constraints.

## O que fazer

### Parte 1 · Mudar e apagar (Entradas 3 e 5 e testes R2 e R3)

1. Abra o `entradas.sql` do seu projeto (Entradas 1, 2 e 4, das aulas 6 a 9). Acrescente, **na ordem do pedido**:
   - a **Entrada 3** (a mudança do pedido: em alguns projetos é um `UPDATE`, em outros é um `INSERT` de um novo preço ou fato; você decide como a sua estrutura guarda o histórico);
   - a **Entrada 5** (apagar o que foi lançado por engano **e tudo o que pertence a ele**; as «filhas» antes da «pai»).
   Escreva o `WHERE` primeiro e rode como `SELECT` antes de trocar por `UPDATE` ou `DELETE`.
2. Rode do zero **duas vezes seguidas**: `01_ddl.sql` e depois `entradas.sql`, sem erro. Confira as **quantidades** com o que o pedido manda.
3. Faça os testes **R2** e **R3** do pedido. Os dois **precisam dar erro**. Copie a mensagem de cada um no `achados.md` e escreva **uma frase** explicando por que o banco recusou
   (qual constraint, qual regra).
4. Se o R2 ou o R3 **não deu erro**, o seu banco não tem a regra: acrescente a constraint (Parte 2), recrie o banco e teste de novo.

### Parte 2 · O banco se defende (constraints e cenário do erro)

5. Siga o [cenário do erro](cenario-do-erro.md) e ataque o seu banco com **pelo menos 5 ataques**, cada um ligado a uma regra do negócio do seu tema.
   Pelo menos **2** ataques devem ter sido **aceitos antes** de você criar a constraint.
6. Acrescente ao `01_ddl.sql` **pelo menos 5 constraints** que garantam regras do negócio do seu tema. Tem que haver **pelo menos uma de cada**:
   `NOT NULL`, `UNIQUE`, `CHECK` e `FOREIGN KEY` com `ON DELETE` **escrito** (mesmo que seja `RESTRICT`). Se o seu tema pede, use também `DEFAULT`.
   Dê nome às `CHECK` e `UNIQUE` (`tabela_coluna_check`, `tabela_coluna_key`) e escreva, em um comentário acima de cada uma, **qual regra** ela garante.
7. Rode o `01_ddl.sql` e o `entradas.sql` do zero **sem nenhum erro**. A carga precisa respeitar as constraints novas: se não respeitar, corrija o **dado** ou a **regra**, e anote qual dos dois.

### Parte 3 · Achados, IA e colaboração

8. No `achados.md`: as mensagens de R2 e R3, o que o cenário do erro mostrou (o que o banco aceitou e você teve de corrigir) e o que **não conseguiu** barrar.
   Se o seu R3 pede uma regra que `UNIQUE` e `CHECK` não resolvem (por exemplo, «um exemplar não pode ter dois empréstimos abertos»), diga isso; a [leitura extra](leitura-extra.md) mostra o caminho, mas
   **não é obrigatório** e não cai em prova.
9. No `uso-de-ia.md`: se usou IA, qual e para quê; se não usou, escreva que não usou. Inclua **com quem conversou** e sobre o quê.

## O que entregar

| Arquivo | Conteúdo |
|---|---|
| `entradas.sql` | As Entradas 1 a 5 do pedido, em ordem, com um comentário no começo de cada uma. Roda do zero depois do `01_ddl.sql` |
| `01_ddl.sql` | A estrutura do seu projeto com as constraints novas, cada uma com um comentário com a regra |
| `ataques.sql` | Pelo menos 5 ataques: o comando, se o banco **aceitou** antes ou **recusou**, a constraint que o recusou e a mensagem de erro |
| `achados.md` | Mensagens de R2 e R3 com a explicação, o que o cenário do erro mostrou e o que não foi barrado |
| `uso-de-ia.md` | Uso de IA e colaboração |

## Como a nota é dada

| Item | Pontos |
|---|---|
| Entradas 3 e 5 no `entradas.sql`, rodando do zero com as Entradas 1, 2 e 4, e as quantidades batendo | 3 |
| R2 e R3 com a mensagem do banco e a explicação | 2 |
| Constraints acrescentadas ao `01_ddl.sql` (5, uma de cada tipo pedido) e justificadas | 2 |
| `ataques.sql`: 5 ataques, pelo menos 2 aceitos antes | 2 |
| `uso-de-ia.md` e colaboração | 1 |

Um fato do pedido que **não cabe** na sua estrutura não é descontado: ele vai para o `achados.md`. Isso vale nota.

## Para conferir antes de entregar

- [ ] O `entradas.sql` tem as Entradas 1 a 5, na ordem, e começa com o `SET search_path` do meu schema.
- [ ] Escrevi o `WHERE` primeiro e conferi com um `SELECT` antes de cada `UPDATE` e `DELETE`.
- [ ] Apaguei as «filhas» antes da «pai» na Entrada 5.
- [ ] Rodei `01_ddl.sql` e `entradas.sql` do zero, duas vezes, sem erro.
- [ ] A contagem de linhas de cada tabela bate com o pedido.
- [ ] R2 e R3 deram erro, e copiei a mensagem de cada um no `achados.md`.
- [ ] O `01_ddl.sql` tem 5 constraints ou mais, com `NOT NULL`, `UNIQUE`, `CHECK` e `FOREIGN KEY` com `ON DELETE`, cada uma com um comentário.
- [ ] O `ataques.sql` tem 5 ataques ou mais, e pelo menos 2 foram aceitos antes da constraint.
- [ ] Escrevi o `uso-de-ia.md`.
