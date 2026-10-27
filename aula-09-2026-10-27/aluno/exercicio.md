# Exercício — Consultar o seu projeto

Banco de Dados 2 · Aula 9

|                   |                                                                                                     |
| ----------------- | --------------------------------------------------------------------------------------------------- |
| **Individual**    | Cada aluno entrega o seu                                                                            |
| **Como entregar** | Uma atividade no Google Classroom, com os arquivos `consultas.sql`, `resultados.md`, `achados.md` e `uso-de-ia.md` |
| **Prazo**         | Sem horário limite por dia. O ideal é entregar até o fim da aula 10. Vale entregar até o último dia de aula |
| **Nota**          | De 0 a 10 (pontos indicados em cada item)                                                           |
| **IA**            | Liberada. Anote no `uso-de-ia.md` qual IA usou e para quê, e saiba explicar tudo o que entregou     |
| **Colaboração**   | Pode trocar ideias com colegas. Anote **com quem conversou** e sobre o quê                           |

Na aula 9, o professor escreveu e explicou algumas consultas da **Oficina Mecânica**. Agora você faz o mesmo no banco do **seu** projeto, com as
16 perguntas do pedido do seu tema (na pasta `pedidos-de-validacao`, publicado no Classroom).

Siglas: **SQL** (*Structured Query Language*, linguagem de consulta estruturada), **FK** (*Foreign Key*, chave estrangeira).

## O que fazer

O pedido tem uma tabela «O que sai» com 16 perguntas (C1 a C16) e o resultado esperado de cada uma.

1. Abra o banco do seu projeto, com a estrutura e a carga (Entradas 1, 2 e 4) que você fez nas aulas 6 a 9.
2. Para cada pergunta, antes de escrever, responda: o que ela quer ver, em quais tabelas estão os dados, quais linhas interessam e se quer uma linha por quê.
3. Escreva uma consulta por pergunta, em um arquivo `consultas.sql`. Comece o arquivo com o `SET search_path` do seu schema e, antes de cada consulta, um comentário com o número (`-- C1`).
4. Rode cada uma e **compare com o «O que sai»** do pedido. Os nomes e a ordem das colunas não importam; a ordem das linhas só importa quando a pergunta pede ordenação.
5. Copie o resultado de cada consulta no `resultados.md` (texto ou print).
6. Se alguma não bateu, pergunte antes de mexer na consulta: o erro está na **consulta** ou na **estrutura**? Anote no `achados.md`.
7. Escreva o `uso-de-ia.md`.

Consulte a [referência de `SELECT`](referencia-select.md) quando tiver dúvida.

**Sobre as Entradas 3 e 5.** O «O que sai» do pedido vale para o banco **depois das 5 entradas**. As Entradas 3 e 5 (mudar e apagar dados) entram na aula 10.
Você pode escrevê-las antes, se quiser comparar já; senão, faça as consultas agora e **compare de novo depois da aula 10**. No `resultados.md`,
marque as que só não bateram porque as Entradas 3 e 5 ainda não foram feitas.

## O que entregar

### Parte A — `consultas.sql` (8 pontos)

- As consultas C1 a C16, em ordem, cada uma com um comentário com o número.
- Cada consulta **roda sem erro** e devolve o que o pedido manda. Cada uma vale **0,5 ponto**.
- Uma consulta que roda e devolve o valor errado não vale ponto, mas o que você aprendeu entra no `achados.md`.
- Não precisa entregar todas de uma vez: o que for entregue vale. O resto pode ser entregue depois, até o último dia de aula.

### Parte B — `resultados.md` e achados (1 ponto)

1. O **resultado de cada consulta**, copiado do banco.
2. Um `achados.md` com o que **não bateu**: **por que** não bateu e o que você mudou (na consulta ou na estrutura). Se tudo bateu de primeira, escreva isso.

### Parte C — Uso de IA e colaboração (1 ponto)

Em um arquivo `uso-de-ia.md`: se usou IA, qual e para quê (por exemplo, «explicar um erro» ou «escrever o primeiro rascunho da C9»);
se não usou, escreva que não usou. Inclua **com quem conversou** e sobre o quê.

A IA escreve consulta com facilidade, mas pode errar de um jeito que o banco aceita (por exemplo, um `JOIN` no lugar de `LEFT JOIN`).
Você precisa saber **explicar cada cláusula** do que entregou.

## Como a nota é dada

| Item | Pontos |
|---|---|
| `consultas.sql`: cada uma das 16 consultas que roda e bate com o pedido | 0,5 cada (8 no total) |
| `resultados.md` e `achados.md` | 1 |
| `uso-de-ia.md` e colaboração | 1 |

## Para conferir antes de entregar

- [ ] O `consultas.sql` começa com o `SET search_path` do meu schema.
- [ ] Cada consulta tem um comentário com o número (`-- C1`).
- [ ] Rodei cada consulta e comparei com o «O que sai» do pedido.
- [ ] Onde o pedido diz «todo X aparece», usei `LEFT JOIN` a partir da tabela do X.
- [ ] Onde a pergunta pede «quem nunca...», usei `LEFT JOIN` com `IS NULL` ou `NOT EXISTS`.
- [ ] Copiei o resultado de cada consulta no `resultados.md`.
- [ ] Escrevi o que não bateu no `achados.md`.
- [ ] Escrevi o `uso-de-ia.md`.
