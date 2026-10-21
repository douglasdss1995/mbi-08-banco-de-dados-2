# Exercício 1 — Ambiente, modelo relacional e normalização

Banco de Dados 2 · Turma MBI-08 · Assunto 1 de 15 · Aulas 1 e 2

| | |
|---|---|
| **Individual** | Cada aluno entrega o seu, mesmo trabalhando com o grupo |
| **Como entregar** | Uma única atividade no Google Classroom, com as duas partes |
| **Prazo** | Sem horário limite por dia. O ideal é entregar até o fim da aula 2 (16/10). Vale entregar até 18/11 |
| **Nota** | De 0 a 10: parte 1 vale 3 pontos e parte 2 vale 7 pontos |
| **IA** | Liberada. Anote no fim da entrega qual IA usou e para quê, e saiba explicar tudo o que entregou |

A **parte 1** é feita na aula 1 (às 11:00). A **parte 2** é liberada na aula 2.

---

## Parte 1 — Ambiente e tema (aula 1) · 3 pontos

### 1.1 Sua ferramenta e sua versão do PostgreSQL (1 ponto)

1. No cliente que você escolheu (DBeaver ou DataGrip), conecte ao PostgreSQL em `localhost:5432` e execute:

   ```sql
   SELECT version();
   ```

2. Abra o terminal e execute:

   ```
   psql --version
   ```

3. **Entregue:** um print do resultado do `SELECT version();` (com o seu cliente visível) e um print do terminal com
   o `psql --version`. Escreva qual cliente você escolheu.

### 1.2 Seu primeiro banco (1 ponto)

1. Crie um banco de dados chamado `bd2_teste` e conecte-se a ele.
2. Execute o script abaixo, linha por linha, no banco `bd2_teste`:

   ```sql
   CREATE TABLE saudacao (
       id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
       mensagem text NOT NULL
   );

   INSERT INTO saudacao (mensagem) VALUES ('Olá, Banco de Dados 2!');

   SELECT * FROM saudacao;
   ```

3. Insira uma segunda linha com uma mensagem sua e execute o `SELECT` de novo.
4. **Entregue:** um print do resultado do último `SELECT`, mostrando as duas linhas.

### 1.3 Seu grupo e seu tema (1 ponto)

Responda em texto:

1. Número do grupo, tema sorteado e nome dos integrantes.
2. Link do repositório do grupo no GitHub (se ainda não foi criado, escreva "pendente" e crie na aula 2).
3. **Uma frase** que explique o que o sistema do seu tema faz e para quem.
4. **Cinco coisas** que esse sistema precisa guardar, escritas em linguagem comum (por exemplo, "os livros da
   biblioteca", "os empréstimos"). Não precisa ser tabela ainda.

---

## Parte 2 — Normalização e diagrama (aula 2) · 7 pontos

### O cenário

A oficina mecânica **Oficina Mecânica** controla suas ordens de serviço (OS) em uma planilha:

| os | data | cod_cliente | cliente | telefone | placa | modelo | marca | cod_mecanico | mecanico | especialidade | servicos | total |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1001 | 02/10/2026 | C01 | Ana Souza | (47) 99111-0001 | ABC1D23 | Gol | Volkswagen | M1 | Carlos Lima | Motor | Troca de óleo (R$ 120); Alinhamento (R$ 90) | R$ 210 |
| 1002 | 02/10/2026 | C02 | Bruno Reis | (47) 99222-0002 | XYZ9K88 | Onix | Chevrolet | M2 | Marta Alves | Suspensão | Alinhamento (R$ 90) | R$ 90 |
| 1003 | 05/10/2026 | C01 | Ana Souza | (47) 99111-0001 | ABC1D23 | Gol | Volkswagen | M2 | Marta Alves | Suspensão | Troca de pastilhas (R$ 180) | R$ 180 |
| 1004 | 06/10/2026 | C03 | Carla Dias | (47) 99333-0003 | QWE4R56 | Onix | Chevrolet | M1 | Carlos Lima | Motor | Troca de óleo (R$ 120); Troca de filtro (R$ 60) | R$ 180 |
| 1005 | 07/10/2026 | C02 | Bruno Reis | (47) 99222-0002 | XYZ9K88 | Onix | Chevrolet | M1 | Carlos Lima | Motor | Troca de óleo (R$ 120) | R$ 120 |

Regras do negócio: cada OS é de **um** veículo e atendida por **um** mecânico; um cliente pode ter vários veículos, e um
veículo pertence a **um** cliente; cada mecânico tem **uma** especialidade; um serviço tem um preço de tabela.

### 2.1 Problemas da planilha (1 ponto)

Responda com base na planilha acima:

1. **Atualização:** a Ana Souza mudou de telefone. Em quantas linhas é preciso alterar? O que acontece se alguém esquecer uma?
2. **Inserção:** dá para cadastrar um mecânico novo, ou o serviço «Troca de correia», sem criar uma OS? Por quê?
3. **Exclusão:** se a OS 1004 for apagada, que informações deixam de existir na planilha?

### 2.2 Primeira forma normal (1 ponto)

1. Qual coluna viola a 1FN? Explique por quê.
2. Reescreva a planilha em **1FN** (uma linha por OS e por serviço). Indique qual é a **chave primária**.

### 2.3 Dependências funcionais (1 ponto)

1. Liste as dependências funcionais no formato `X → Y` (leia: "dado X, existe um único Y"). Dica: pergunte para cada coluna
   "o que ela determina?".
2. Marque quais são **parciais** (dependem de apenas parte da chave) e quais são **transitivas** (dependem de uma coluna
   que não é chave).

### 2.4 2FN e 3FN (1,5 ponto)

Escreva as tabelas finais, em 3FN, no formato `tabela(coluna PK, coluna, coluna FK)`. Marque as chaves primárias e as
chaves estrangeiras. Nenhuma informação pode ficar repetida entre linhas.

### 2.5 Atributo derivado (0,5 ponto)

A coluna `total` deve ser guardada em uma das suas tabelas, ou calculada quando necessário? Justifique em até 3 linhas.

### 2.6 Diagrama da oficina (1 ponto)

Desenhe no **ERD Concepts** o diagrama das tabelas da questão 2.4, com as chaves e a **cardinalidade** dos relacionamentos
(1:N ou N:N). Exporte como imagem e anexe.

### 2.7 O diagrama do seu tema (1 ponto)

1. Termine o diagrama do tema do seu grupo, que foi começado no tempo de projeto da aula 2. Ele deve ter pelo menos
   **6 tabelas**, com chaves primárias, chaves estrangeiras e cardinalidades, e estar em **3FN**.
2. Exporte o diagrama como imagem e suba no repositório do grupo, com um **commit seu**.
3. **Entregue:** a imagem do diagrama e o link do seu commit.

---

## Lista de conferência da entrega

- [ ] Parte 1: prints do `SELECT version();`, do `psql --version` e do `SELECT * FROM saudacao;`.
- [ ] Parte 1: grupo, tema, link do repositório, uma frase e cinco coisas.
- [ ] Parte 2: respostas das questões 2.1 a 2.5.
- [ ] Parte 2: imagem do diagrama da oficina (2.6).
- [ ] Parte 2: imagem do diagrama do tema e link do seu commit (2.7).
- [ ] Se usou IA: qual e para quê, no fim da entrega.
