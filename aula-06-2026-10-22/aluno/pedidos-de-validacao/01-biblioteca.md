# Validação do banco — Biblioteca escolar

Banco de Dados 2

Você vai testar se o **banco de dados do seu projeto** consegue **guardar e devolver** o que o cliente do projeto precisa. O pedido
abaixo usa o cenário do seu projeto e traz dados de teste.

Ninguém aqui diz **como** o seu banco deve ser (nomes de tabelas e de colunas são seus). O pedido diz **o que entra** e **o que
tem que sair**. Se a sua consulta devolve o que está na tabela «O que sai», a sua estrutura está servindo. Se não devolve, a
estrutura tem um problema, e achar esse problema é o objetivo.

Siglas: **DML** (*Data Manipulation Language*, linguagem de manipulação de dados: `INSERT`, `UPDATE`, `DELETE`), **FK** (*Foreign
Key*, chave estrangeira), **PK** (*Primary Key*, chave primária).

## Como fazer

1. Use um **banco vazio**, só com a sua estrutura (as tabelas, sem nenhuma linha). Se o seu banco já tem dados de teste,
   crie um banco novo e rode só o seu script de estrutura. Os resultados abaixo só valem para os dados deste pedido.
2. Execute as **5 entradas** abaixo, **na ordem**. Escreva os comandos `INSERT`, `UPDATE` e `DELETE` no arquivo
   `entradas.sql`.
3. Escreva **uma consulta para cada pergunta** (C1 a C16) no arquivo `consultas.sql`. A consulta é sua.
4. Compare o que a sua consulta devolve com a coluna «O que sai».
5. Faça os 3 testes de recusa (R1 a R3).
6. Se alguma informação do pedido **não tem lugar** na sua estrutura, ou alguma consulta não consegue responder, **corrija a
   estrutura** (com `ALTER TABLE` ou refazendo a tabela), rode tudo de novo e anote o que mudou no arquivo `achados.md`.

**Como conferir:** os nomes das colunas e a ordem delas não importam. A ordem das linhas só importa quando o enunciado pedir
ordenação. Valores de dinheiro: `210` e `210,00` são iguais. Onde a resposta é «0», um campo vazio também vale.

**Datas:** as datas são dadas em relação a **hoje** (por exemplo, «10 dias atrás» ou «daqui a 2 dias»). Use a data de hoje do seu banco (`CURRENT_DATE`) para calcular, assim o resultado é o mesmo em qualquer dia.

## O que entra

### Entrada 1 — Cadastros

**Editoras:** Rocco, Companhia das Letras, Novatec.
**Categorias:** Fantasia, Literatura, Tecnologia, Poesia (esta ainda sem livros).
**Autores:** J.K. Rowling, Machado de Assis, Ana Beatriz Lemos, Rui Carvalho, Marcos Teles, Clarice Lispector (esta ainda sem livros).

**Livros e exemplares** (a **coleção Harry Potter** tem 3 livros; o primeiro tem **2 exemplares**, A e B, e os outros um só)

| Livro | Editora | Categoria | Autor(es), na ordem | Exemplares |
|---|---|---|---|---|
| Harry Potter e a Pedra Filosofal | Rocco | Fantasia | J.K. Rowling | 2 (A e B) |
| Harry Potter e a Câmara Secreta | Rocco | Fantasia | J.K. Rowling | 1 |
| Harry Potter e o Prisioneiro de Azkaban | Rocco | Fantasia | J.K. Rowling | 1 |
| Dom Casmurro | Companhia das Letras | Literatura | Machado de Assis | 1 |
| Banco de Dados Relacional | Novatec | Tecnologia | 1º Ana Beatriz Lemos, 2º Rui Carvalho | 1 |
| Redes de Computadores | Novatec | Tecnologia | Marcos Teles | 1 |
| Algoritmos na Prática | Novatec | Tecnologia | Rui Carvalho | 1 (**em manutenção**) |

Os exemplares com empréstimo ainda não devolvido (Entrada 4) ficam com a situação «emprestado»; os demais, «disponível».

**Tipos de leitor:** aluno (prazo de 7 dias e até 3 livros ao mesmo tempo), professor (15 dias e até 5 livros), funcionário (10 dias e até 3 livros).
**Multa por dia de atraso, desde 90 dias atrás:** aluno R$ 0,50, professor R$ 0,25, funcionário R$ 0,25.

**Leitores**

| Leitor | Tipo | Registro | E-mail | Telefone |
|---|---|---|---|---|
| Lia Torres | aluno | A-1001 | lia.torres@escola.example | (47) 99100-0001 |
| Caio Ramos | aluno | A-1002 | caio.ramos@escola.example | (47) 99100-0002 |
| Nina Prado | aluno | A-1003 | nina.prado@escola.example | (47) 99100-0003 |
| Helena Vaz | professor | P-2001 | helena.vaz@escola.example | (47) 99100-0004 |
| Otávio Lins | funcionário | F-3001 | otavio.lins@escola.example | (47) 99100-0005 |
| Paulo Reis | funcionário | F-3002 | paulo.reis@escola.example | (47) 99100-0006 |

### Entrada 2 — Empréstimos antigos, já devolvidos, e as multas deles

| Leitor | Livro | Emprestado | Previsto | Devolvido | Multa |
|---|---|---|---|---|---|
| Nina Prado | Redes de Computadores | 50 dias atrás | 43 dias atrás | 39 dias atrás | 4 dias de atraso, R$ 2,00, **paga** |
| Lia Torres | Banco de Dados Relacional | 40 dias atrás | 33 dias atrás | 35 dias atrás | sem atraso, sem multa |
| Otávio Lins | Dom Casmurro | 30 dias atrás | 20 dias atrás | 12 dias atrás | 8 dias de atraso, R$ 2,00, **não paga** |

### Entrada 3 — Mudança de tarifa

A multa por dia do **aluno** passa de R$ 0,50 para **R$ 0,75**, valendo a partir de 30 dias atrás. As multas já geradas não mudam.

### Entrada 4 — Empréstimos recentes, multa, reservas e avisos

| Leitor | Livro | Emprestado | Previsto | Devolvido |
|---|---|---|---|---|
| Caio Ramos | Banco de Dados Relacional | 25 dias atrás | 18 dias atrás | 16 dias atrás (2 dias de atraso, multa de R$ 1,50, **paga**) |
| Lia Torres | Harry Potter e a Pedra Filosofal (exemplar A) | 10 dias atrás | 3 dias atrás | **ainda não devolvido** |
| Caio Ramos | Harry Potter e a Câmara Secreta | 5 dias atrás | daqui a 2 dias | **ainda não devolvido** |
| Helena Vaz | Harry Potter e o Prisioneiro de Azkaban | 20 dias atrás | 5 dias atrás | **ainda não devolvido** |
| Nina Prado | Dom Casmurro | 9 dias atrás | 2 dias atrás | **ainda não devolvido** |

**Reservas** do livro Prisioneiro de Azkaban, na ordem do pedido: primeiro Nina Prado (4 dias atrás), depois Otávio Lins (2 dias atrás).

**Avisos de cobrança:** a Lia Torres foi avisada por **e-mail** ontem (aviso enviado). A Helena Vaz tem um aviso por **WhatsApp**
ainda **pendente** (não enviado).

### Entrada 5 — Correção

Ontem foi lançado, por engano, um empréstimo de Redes de Computadores para o Paulo Reis. **Apague esse empréstimo** (e tudo o que
pertence a ele) e deixe o exemplar **disponível** de novo.

## O que sai

Todas as consultas valem para o banco **depois das 5 entradas**.

| # | Pergunta | O que sai |
|---|---|---|
| C1 | Quantos exemplares, quantos empréstimos e quantos leitores existem? | 8 exemplares, 8 empréstimos, 6 leitores |
| C2 | Quais livros estão emprestados agora? Mostre leitor, livro e a data prevista de devolução. | Helena, Prisioneiro de Azkaban, 5 dias atrás · Lia, Pedra Filosofal, 3 dias atrás · Nina, Dom Casmurro, 2 dias atrás · Caio, Câmara Secreta, daqui a 2 dias |
| C3 | Qual o estoque de cada livro da coleção da autora J.K. Rowling (exemplares no total e disponíveis agora)? | Câmara Secreta 1 exemplar, 0 disponíveis · Pedra Filosofal 2 exemplares, 1 disponível · Prisioneiro de Azkaban 1 exemplar, 0 disponíveis |
| C4 | Quem está com livro atrasado hoje? Mostre leitor, telefone, e-mail, livro e dias de atraso. | Helena (47) 99100-0004, helena.vaz@escola.example, Prisioneiro de Azkaban, 5 dias · Lia (47) 99100-0001, lia.torres@escola.example, Pedra Filosofal, 3 dias · Nina (47) 99100-0003, nina.prado@escola.example, Dom Casmurro, 2 dias |
| C5 | Quais livros têm mais de um autor? Mostre os autores na ordem. | Banco de Dados Relacional: Ana Beatriz Lemos, Rui Carvalho (só ele) |
| C6 | Quantos livros cada autor tem? **Todo autor aparece.** | J.K. Rowling 3 · Rui Carvalho 2 · Ana Beatriz Lemos 1 · Machado de Assis 1 · Marcos Teles 1 · Clarice Lispector 0 |
| C7 | Quais livros nunca foram emprestados? | Algoritmos na Prática (só ele) |
| C8 | Ranking dos livros mais emprestados (quantas vezes cada um), com todos os livros. | Banco de Dados Relacional 2 · Dom Casmurro 2 · Câmara Secreta 1 · Pedra Filosofal 1 · Prisioneiro de Azkaban 1 · Redes de Computadores 1 · Algoritmos na Prática 0 |
| C9 | Quanto de multa foi gerado no total e quanto ainda está pendente (não pago)? | Gerado R$ 5,50 · pendente R$ 2,00 |
| C10 | Para cada multa de **aluno**: leitor, dias de atraso, valor, valor cobrado por dia, e a tarifa de hoje do aluno. | Nina, 4 dias, R$ 2,00, R$ 0,50 por dia · Caio, 2 dias, R$ 1,50, R$ 0,75 por dia · tarifa de hoje do aluno: R$ 0,75 |
| C11 | Qual a fila de reservas do livro Prisioneiro de Azkaban, na ordem? | 1º Nina Prado, 2º Otávio Lins |
| C12 | Quais leitores nunca pegaram um livro? | Paulo Reis (só ele) |
| C13 | Para cada leitor: quantos empréstimos em aberto e qual o limite do tipo dele? **Todo leitor aparece.** | Caio 1 de 3 · Helena 1 de 5 · Lia 1 de 3 · Nina 1 de 3 · Otávio 0 de 3 · Paulo 0 de 3 |
| C14 | Quais atrasados ainda **não receberam aviso enviado**? | Helena Vaz (Prisioneiro de Azkaban, o aviso dela está pendente) e Nina Prado (Dom Casmurro, sem aviso) |
| C15 | Liste os avisos: leitor, canal e situação. | Helena, WhatsApp, pendente · Lia, e-mail, enviado |
| C16 | Por categoria: quantos livros e quantos exemplares? Toda categoria aparece. | Fantasia 3 livros e 4 exemplares · Tecnologia 3 e 3 · Literatura 1 e 1 · Poesia 0 e 0 |

## Testes de recusa

Estes três comandos **precisam dar erro**. Se o banco aceitar, falta uma regra na estrutura (se não souber como criá-la, anote como
achado). Copie a mensagem de erro de cada um no `achados.md`.

| # | Tente | O que sai |
|---|---|---|
| R1 | Registrar um empréstimo de um exemplar que não existe | Erro de chave estrangeira (FK) |
| R2 | Apagar o livro «Harry Potter e a Pedra Filosofal», que tem exemplares | Erro: o banco não deixa apagar o que ainda é usado em outra tabela |
| R3 | Emprestar ao Caio o exemplar A da Pedra Filosofal, que já está emprestado à Lia e não foi devolvido | Erro: um exemplar não pode ter dois empréstimos abertos ao mesmo tempo |

## O que entregar

Entregue **todos os arquivos abaixo pelo Google Classroom, na atividade indicada pelo professor**:

| Arquivo | Conteúdo |
|---|---|
| `entradas.sql` | Só os comandos das 5 entradas (sem o script de criação das tabelas) |
| `consultas.sql` | As 16 consultas, C1 a C16, cada uma com um comentário com o seu número |
| `resultados.md` | O resultado de cada consulta (texto copiado ou print) |
| `achados.md` | As mensagens de erro de R1 a R3 e o que não bateu: **por que não bateu** e o que você mudou na estrutura. Se tudo bateu de primeira, escreva isso |
| `uso-de-ia.md` | Se usou IA: qual e para quê. Se não usou, escreva que não usou |

## Se uma consulta não bateu

Antes de mexer na consulta, pergunte se é a **estrutura** que não deixa a resposta sair certa:

- O estoque de um livro (C3) depende de **quantos exemplares** ele tem e de **quais estão disponíveis**. Onde o seu banco guarda o exemplar e o seu estado?
- Um livro com **dois autores** (C5) mostra os autores na ordem certa? Onde ficou guardada a ordem?
- A multa da aluna Nina foi calculada com a tarifa **da época**. A tarifa nova mudou a multa antiga? Onde ficou o valor cobrado (C10)?
- Um leitor, autor, categoria ou livro **sem nenhum vínculo** sumiu do resultado? Isso costuma ser `JOIN` no lugar de `LEFT JOIN`.
- «Em aberto» e «atrasado» (C2, C4) saem da data de devolução vazia e da data prevista. O seu banco consegue dizer isso?
- Faltou algum lugar para guardar uma informação do pedido?

