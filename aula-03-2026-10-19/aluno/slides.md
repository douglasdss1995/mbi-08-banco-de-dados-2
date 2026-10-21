# DDL e DML

Banco de Dados 2 · aula 3

19/10/2026 · do modelo ao banco

## Slide 2 — Hoje o modelo vira um banco de verdade

- cliente
- Banco da Oficina Mecânica
- Vamos criar as 7 tabelas, carregar dados e ver o que o banco aceita e o que ele recusa. Tudo em scripts que rodam do zero, quantas vezes for preciso.
- veiculo
- ordem_servico
- 7 — tabelas para criar
- 5 — linhas, no mínimo, em cada uma
- item_servico

## Slide 3 — DDL: definir a estrutura

*Os comandos que criam e mudam as tabelas*

- CREATE TABLE
- Cria a tabela, com as colunas e os tipos.
- FOREIGN KEY
- Liga uma tabela a outra e impede referência a algo que não existe.
- PRIMARY KEY
- Identifica cada linha, sozinha ou composta.
- ALTER TABLE
- Muda a tabela depois de criada, por exemplo, ADD COLUMN.

## Slide 4 — Os tipos que vamos usar

*Escolha o tipo pelo que o dado é*

- integer ... IDENTITY
- Código que o banco numera sozinho
- varchar(n)
- Texto com limite: nome e descrição
- char(7)
- Texto de tamanho fixo: a placa
- numeric(10,2)
- Dinheiro. Nunca em float
- date
- Só o dia: a data da OS
- boolean
- Verdadeiro ou falso: mecânico ativo

## Slide 5 — A ordem importa

*Por causa das chaves estrangeiras*

- Para criar, comece pelas tabelas que ninguém referencia. Para apagar, comece pelas que têm chave estrangeira. Comece o script com DROP TABLE IF EXISTS: assim ele roda do zero, sem erro.
- A regra:
- Criar: de fora para dentro
- Apagar: de dentro para fora

## Slide 6 — DML: mexer nos dados

*Os comandos que acrescentam, alteram e apagam linhas*

- INSERT
- Acrescenta linhas. Um por vez ou vários em um só comando.
- DELETE
- Apaga linhas.
- UPDATE
- Altera linhas que já existem.
- WHERE
- Sempre: escolhe quais linhas o comando atinge.

## Slide 7 — Três erros que o banco recusa

*E o que cada recusa protege*

- ERRO 1
- Inserir um veículo com um cod_cliente que não existe.
- A chave estrangeira exige que o cliente exista.
- ERRO 2
- Apagar um cliente que ainda tem veículos.
- Apagar deixaria veículos sem dono.
- ERRO 3
- Inserir um cliente sem nome.
- A coluna é NOT NULL.

## Slide 8 — Agora, a prática

*Em sequência*

- 01_ddl.sql
- As 7 tabelas, o script que roda várias vezes e os 3 ALTER TABLE.
- Quem errou o exercício 1 usa o modelo de referência do Classroom.
- Depois, o grupo ajusta o diagrama do tema e faz o 2º commit. Por fim, o exercício.
- 02_carga.sql
- Pelo menos 5 linhas por tabela, na ordem das chaves estrangeiras.
