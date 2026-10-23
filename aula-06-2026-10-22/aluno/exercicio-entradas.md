# Exercício — Entradas do seu projeto

Banco de Dados 2 · Aula 6

|                   |                                                                                                     |
| ----------------- | --------------------------------------------------------------------------------------------------- |
| **Individual**    | Cada aluno entrega o seu                                                                            |
| **Como entregar** | Uma atividade no Google Classroom, com os arquivos `entradas.sql`, `achados.md` e `uso-de-ia.md`     |
| **Prazo**         | Sem horário limite por dia. O ideal é entregar até o fim da aula 6. Vale entregar até o último dia de aula |
| **Nota**          | De 0 a 10 (pontos indicados em cada item)                                                           |
| **IA**            | Liberada. Anote no `uso-de-ia.md` qual IA usou e para quê, e saiba explicar tudo o que entregou     |
| **Colaboração**   | Pode trocar ideias com colegas. Anote **com quem conversou** e sobre o quê                           |

Na aula 6, depois da DDL, o professor carregou o banco da **Oficina Mecânica** a partir do pedido de validação dela. Agora você faz o mesmo no banco do
**seu** projeto, com o pedido do seu tema (na pasta `pedidos-de-validacao`, publicado no Classroom).

Siglas: **DML** (*Data Manipulation Language*, linguagem de manipulação de dados), **FK** (*Foreign Key*, chave estrangeira),
**SQL** (*Structured Query Language*, linguagem de consulta estruturada).

## O que fazer

O pedido tem 5 entradas. **Hoje você faz só as Entradas 1, 2 e 4** (as que usam `INSERT`). As Entradas 3 e 5 (mudar e apagar) ficam para a
aula 7, junto com as primeiras consultas.

1. Abra o banco do seu projeto, **vazio**: rode o seu `01_ddl.sql` (ele apaga e recria tudo).
2. Leia o pedido do seu projeto. O pedido diz **o que entra**, não diz em qual coluna: você decide onde cada fato vai, olhando as suas tabelas.
3. Escreva as **Entradas 1, 2 e 4**, nesta ordem, em um arquivo `entradas.sql`. Comece o arquivo com o `SET search_path` do seu schema.
4. Rode do zero **duas vezes seguidas**: `01_ddl.sql` e depois `entradas.sql`, sem erro.
5. Confira as **quantidades**: depois de cada entrada, `SELECT count(*)` em cada tabela e compare com o que o pedido manda.
6. Faça o teste de recusa **R1** do pedido e copie a mensagem de erro.
7. Escreva o `achados.md` e o `uso-de-ia.md`.

Consulte a [referência de `INSERT`](referencia-insert.md) quando tiver dúvida.

## O que entregar

### Parte A — `entradas.sql` (7 pontos)

- As Entradas 1, 2 e 4 do pedido, em ordem, com **uma anotação em comentário** no começo de cada entrada (`-- Entrada 1 · cadastros`).
- Roda do zero, duas vezes seguidas, sem erro.
- As quantidades de linhas batem com o pedido. Um fato do pedido que **não cabe** na sua estrutura não é descontado: ele vai para o `achados.md`.

### Parte B — Teste de recusa e achados (1 ponto)

Em um arquivo `achados.md`:

1. A **mensagem de erro do R1** do seu pedido, copiada do banco, e **uma frase** explicando por que o banco recusou.
2. O que **não coube** na sua estrutura e o que você mudou (ou mudaria). Se tudo coube, escreva isso.

### Parte C — Uso de IA e colaboração (2 pontos)

Em um arquivo `uso-de-ia.md`: se usou IA, qual e para quê (por exemplo, «gerar nomes fictícios» ou «corrigir um erro»); se não usou,
escreva que não usou. Inclua **com quem conversou** e sobre o quê.

## Como a nota é dada

| Item | Pontos |
|---|---|
| `entradas.sql` completo, em ordem, rodando do zero | 7 |
| R1 com a mensagem e a explicação, e os achados | 1 |
| `uso-de-ia.md` e colaboração | 2 |

## Para conferir antes de entregar

- [ ] O `entradas.sql` começa com o `SET search_path` do meu schema.
- [ ] As tabelas «pai» foram preenchidas antes das que têm FK.
- [ ] Não informei a coluna `IDENTITY` em nenhum `INSERT`.
- [ ] Rodei `01_ddl.sql` e `entradas.sql` do zero, duas vezes, sem erro.
- [ ] A contagem de linhas de cada tabela bate com o pedido.
- [ ] Copiei a mensagem de erro do R1 no `achados.md`.
- [ ] Escrevi o `uso-de-ia.md`.
