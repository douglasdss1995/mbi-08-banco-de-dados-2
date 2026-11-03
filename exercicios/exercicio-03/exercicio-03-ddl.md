# Exercício — DDL do seu projeto

Banco de Dados 2 · Turma MBI-08 · Aula 6

|                   |                                                                                                     |
| ----------------- | --------------------------------------------------------------------------------------------------- |
| **Individual**    | Cada aluno entrega o seu                                                                            |
| **Como entregar** | Uma atividade no Google Classroom, com o arquivo `01_ddl.sql` e um print do banco criado             |
| **Prazo**         | Sem horário limite por dia. O ideal é entregar até o fim da aula 6. Vale entregar até 18/11         |
| **Nota**          | De 0 a 10 (pontos indicados em cada item)                                                           |
| **IA**            | Liberada. Anote no fim do arquivo (em comentário) qual IA usou e para quê, e saiba explicar tudo     |
| **Colaboração**   | Pode trocar ideias com colegas. Anote **com quem conversou** e sobre o quê                           |

Na aula 6 o professor criou ao vivo o banco da **Oficina Mecânica** a partir do dicionário de dados simples. Agora você faz o
mesmo com o dicionário do **seu projeto**, que você entregou na aula 5.

Siglas: **DDL** (*Data Definition Language*, linguagem de definição de dados), **PK** (*Primary Key*, chave primária),
**FK** (*Foreign Key*, chave estrangeira).

## O que entregar

### Parte A — O script `01_ddl.sql` (7 pontos)

Um arquivo `01_ddl.sql` que:

1. Começa com `DROP SCHEMA IF EXISTS ... CASCADE`, `CREATE SCHEMA` e `SET search_path` (veja [referencia-ddl.md](referencia-ddl.md)).
2. Cria **as tabelas principais** do seu projeto (6 a 8 no mínimo), na ordem certa por causa das **FK**.
3. Dá a cada tabela uma **PK** e usa `NOT NULL`, `UNIQUE` e os tipos certos, conforme o seu dicionário.
4. Tem uma **tabela de ligação** quando houver relação N:N.

### Parte B — Rodar do zero (3 pontos)

O script **roda duas vezes seguidas sem erro**. Entregue um print do banco criado (a lista de tabelas) e do resultado da
segunda execução.

## Como a nota é dada

| Item | Pontos |
|---|---|
| Script completo, na ordem certa, com PK, FK e tipos | 7 |
| Roda do zero duas vezes sem erro | 3 |

## Para conferir antes de entregar

- [ ] Cada tabela do dicionário virou um `CREATE TABLE`.
- [ ] Cada campo do dicionário está na tabela, com um tipo que faz sentido.
- [ ] Cada campo que liga a outra tabela tem `REFERENCES`.
- [ ] O script roda sem erro duas vezes seguidas.
