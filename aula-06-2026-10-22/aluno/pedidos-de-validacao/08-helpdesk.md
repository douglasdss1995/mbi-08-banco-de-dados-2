# Validação do banco — Sistema de chamados (helpdesk)

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

**Setores:** TI, Financeiro, RH, Comercial.

**Solicitantes** (quem abre chamado)

| Solicitante | E-mail | Setor |
|---|---|---|
| Alê Nunes | ale.nunes@empresa.example | Financeiro |
| Beto Ramos | beto.ramos@empresa.example | RH |
| Cris Lima | cris.lima@empresa.example | Financeiro |
| Dora Pires | dora.pires@empresa.example | Comercial |

**Categorias:** Acesso e senhas, Equipamentos, Rede, Sistemas. **Cada categoria tem duas filas:** N1 (triagem) e N2 (especialistas).

**Atendentes e as filas que atendem**

| Atendente | Nível | Filas |
|---|---|---|
| Iara Costa | N1 | Acesso e senhas N1; Equipamentos N1 |
| Jonas Reis | N1 | Rede N1 |
| Kátia Moura | N2 | Rede N2; Sistemas N2 |
| Léo Prado | N2 | Sistemas N2; Equipamentos N2 |

**SLA** (prazos em horas corridas, desde 300 dias atrás)

| Prioridade | Primeira resposta | Resolução |
|---|---|---|
| crítica | 1 h | 4 h |
| alta | 4 h | 8 h |
| média | 8 h | 24 h |
| baixa | 24 h | 72 h |

**Equipamentos (patrimônio):** PAT-0001 notebook Latitude 5420 (Financeiro); PAT-0002 roteador Cisco RV340 (TI); PAT-0003 impressora HP LaserJet (RH).

### Entrada 2 — Chamados antigos

Os **prazos de resposta e de resolução ficam gravados no chamado**, com o SLA do dia em que ele foi aberto. Os horários são dados depois da abertura.

| Chamado | Solicitante | Categoria e fila | Atendente | Equipamento | Prioridade (sugerida → final) | Aberto | 1ª resposta | Resolvido | Situação | Prazos gravados |
|---|---|---|---|---|---|---|---|---|---|---|
| Esqueci a senha do sistema | Alê | Acesso e senhas, N1 | Iara | — | média → média | 20 dias atrás, 09:00 | 2 h depois | 5 h depois | fechado 15 dias atrás | 8 h / 24 h |
| Impressora não imprime | Beto | Equipamentos, N1 | Iara | PAT-0003 | baixa → **média** | 12 dias atrás, 10:00 | 1 h depois | 20 h depois | resolvido | 8 h / 24 h |
| Internet fora do ar | Cris | Rede, **N2** (foi escalado) | Kátia | PAT-0002 | crítica → crítica | 8 dias atrás, 08:00 | 3 h depois | 9 h depois | resolvido | 1 h / 4 h |
| Sistema de vendas com erro | Dora | Sistemas, N2 | Kátia | — | alta → alta | 14 dias atrás, 14:00 | 2 h depois | 6 h depois | resolvido | 4 h / 8 h |

**Troca de prioridade:** a Iara trocou o chamado «Impressora não imprime» de baixa para média, com a justificativa «Impressora usada por vários colaboradores».

**Comentários do chamado «Internet fora do ar»** (horas depois da abertura): 1 h, Jonas, **público**, «Reiniciei o roteador e a internet continua fora.»; 2 h, Jonas, **interno**,
«Sem resposta do provedor; escalar para o N2.»; 8 h, Kátia, público, «Cabo trocado, internet normalizada.»

**Histórico de status do chamado «Internet fora do ar»:** aberto (0 h), em atendimento (3 h depois), resolvido (9 h depois).

**Pesquisa de satisfação (nota de 1 a 5):** «Esqueci a senha do sistema» 5 («Rápido»); «Impressora não imprime» 4; «Internet fora do ar» 2 («Demorou»).

### Entrada 3 — Mudança de SLA

O SLA da prioridade **alta** passa de 4 h / 8 h para **3 h / 6 h**, valendo desde 10 dias atrás. Os chamados já abertos continuam com os prazos gravados.

### Entrada 4 — Chamados recentes

| Chamado | Solicitante | Categoria e fila | Atendente | Equipamento | Prioridade | Aberto | 1ª resposta | Situação | Prazos gravados |
|---|---|---|---|---|---|---|---|---|---|
| Notebook não liga | Alê | Equipamentos, N1 | Iara | PAT-0001 | alta | 6 dias atrás, 11:00 | 1 h depois | em atendimento | 3 h / 6 h |
| Erro ao emitir relatório | Beto | Sistemas, N2 | Kátia | — | média | 3 dias atrás, 09:00 | 1 h depois | **aguardando solicitante** (desde 2 dias atrás, 10:00) | 8 h / 24 h |
| Pedido de acesso à pasta | Dora | Acesso e senhas, N1 | ninguém ainda | — | baixa | há 1 hora | ainda não | aberto | 24 h / 72 h |
| Impressora voltou a falhar | Beto | Equipamentos, N1 | Iara | PAT-0003 | média | 2 dias atrás, 15:00 | 1 h depois | em atendimento | 8 h / 24 h |
| Chamado criado por engano | Cris | Rede, N1 | ninguém ainda | — | baixa | agora | ainda não | aberto | 24 h / 72 h |

O chamado «Impressora voltou a falhar» **reabre o problema** de «Impressora não imprime» (resolvido há mais de 5 dias, então é um chamado novo, **ligado ao original**).

**Comentários públicos:** «Erro ao emitir relatório», Kátia, 1 h depois, «Pode enviar o print do erro?»; o Beto (solicitante), 2 h depois, «Enviei por e-mail.»
No chamado «Chamado criado por engano», a Cris (solicitante) escreveu «Teste.»

### Entrada 5 — Correção

O chamado **«Chamado criado por engano»** foi aberto por engano. Apague o chamado **e tudo o que pertence a ele**.

## O que sai

Todas as consultas valem para o banco **depois das 5 entradas**.

| # | Pergunta | O que sai |
|---|---|---|
| C1 | Quantos chamados, solicitantes e atendentes existem? | 8 chamados, 4 solicitantes, 4 atendentes |
| C2 | Quantos chamados em cada situação? | resolvido 3 · em atendimento 2 · aberto 1 · aguardando solicitante 1 · fechado 1 |
| C3 | Quais chamados estão em aberto (nem resolvidos, nem fechados, nem cancelados)? Mostre descrição, solicitante, categoria e prioridade. | Notebook não liga, Alê, Equipamentos, alta · Erro ao emitir relatório, Beto, Sistemas, média · Impressora voltou a falhar, Beto, Equipamentos, média · Pedido de acesso à pasta, Dora, Acesso e senhas, baixa |
| C4 | Para os chamados de prioridade **alta**: os prazos gravados (em horas depois da abertura) e o SLA de hoje. | Sistema de vendas com erro: 4 h e 8 h · Notebook não liga: 3 h e 6 h · SLA de hoje: 3 h / 6 h |
| C5 | Quais chamados tiveram a primeira resposta depois do prazo? Mostre as horas de atraso. | Internet fora do ar, 2 horas de atraso (só esse) |
| C6 | Quais chamados foram resolvidos depois do prazo de resolução? Mostre as horas de atraso. | Internet fora do ar, 5 horas de atraso (só esse) |
| C7 | Quantos chamados em atendimento cada atendente tem? **Todo atendente aparece.** | Iara 2 · Jonas 0 · Kátia 0 · Léo 0 |
| C8 | Quantos chamados cada categoria tem? **Toda categoria aparece.** | Equipamentos 3 · Acesso e senhas 2 · Sistemas 2 · Rede 1 |
| C9 | Quantos chamados cada setor abriu (pelos seus solicitantes)? **Todo setor aparece.** | Financeiro 3 · RH 3 · Comercial 2 · TI 0 |
| C10 | Quais prioridades foram trocadas? Mostre o chamado, de qual para qual, quem trocou e a justificativa. | Impressora não imprime, baixa → média, Iara, «Impressora usada por vários colaboradores» |
| C11 | Quais chamados reabriram outro? Mostre o novo e o original. | Impressora voltou a falhar → Impressora não imprime |
| C12 | Quantos comentários públicos e internos cada chamado com comentários tem? | Erro ao emitir relatório: 2 públicos e 0 internos · Internet fora do ar: 2 públicos e 1 interno |
| C13 | Quantos chamados cada equipamento tem? **Todo equipamento aparece.** | PAT-0001 1 · PAT-0002 1 · PAT-0003 2 |
| C14 | Qual a média da nota de satisfação de cada atendente? **Todo atendente aparece.** | Iara 4,5 (2 notas) · Kátia 2,0 (1 nota) · Jonas sem nota · Léo sem nota |
| C15 | Em quantas horas cada chamado respondido recebeu a primeira resposta? | Esqueci a senha 2 · Sistema de vendas 2 · Impressora não imprime 1 · Internet fora do ar 3 · Notebook não liga 1 · Erro ao emitir relatório 1 · Impressora voltou a falhar 1 |
| C16 | Quantos atendentes cada fila (categoria e nível) tem? **Toda fila aparece.** | Acesso e senhas N1 1, N2 0 · Equipamentos N1 1, N2 1 · Rede N1 1, N2 1 · Sistemas N1 0, N2 2 |

## Testes de recusa

Estes três comandos **precisam dar erro**. Se o banco aceitar, falta uma regra na estrutura (se não souber como criá-la, anote como
achado). Copie a mensagem de erro de cada um no `achados.md`.

| # | Tente | O que sai |
|---|---|---|
| R1 | Abrir um chamado de um solicitante que não existe | Erro de chave estrangeira (FK) |
| R2 | Apagar o setor Financeiro, que tem solicitantes | Erro: o banco não deixa apagar o que ainda é usado em outra tabela |
| R3 | Dar uma segunda nota de satisfação ao chamado «Esqueci a senha do sistema», que já foi avaliado | Erro: só uma nota por chamado |

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

- Os **prazos** do chamado (C4, C5, C6) ficaram gravados com o SLA da época, mesmo depois de o SLA da prioridade alta mudar? Ou o seu banco recalcula com o SLA de hoje?
- A **troca de prioridade** (C10) guarda de qual para qual, quem trocou e a justificativa?
- Um chamado que **reabre** outro (C11) tem como apontar para o original? A tabela de chamados aponta para ela mesma?
- A diferença entre comentário **público** e **interno** (C12) está guardada? Quem escreveu: atendente ou solicitante?
- O tempo até a primeira resposta (C15) é calculado ou guardado? E o atendimento em N1 e N2 (C16): cada categoria tem as duas filas?
- Um atendente, setor ou equipamento **sem nenhum chamado** sumiu do resultado (C7, C9, C13, C14, C16)? Isso costuma ser `JOIN` no lugar de `LEFT JOIN`.
- A nota de satisfação (R3) é uma por chamado?
- Faltou algum lugar para guardar uma informação do pedido?

