# Projeto 8 — Sistema de chamados (helpdesk)

Estrutura comum das entregas (GitHub, tags, notas): [00-estrutura-das-entregas.md](00-estrutura-das-entregas.md).
Projetos de referência já detalhados: [01-biblioteca.md](01-biblioteca.md) e [02-clinica-medica.md](02-clinica-medica.md).

## Cenário

O setor de TI de uma empresa atende **solicitantes** (funcionários) por meio de **chamados**. Cada chamado cai em uma
**fila** por categoria, é assumido por um **atendente**, passa por vários status e tem **prazos de SLA** conforme a
prioridade. A empresa quer saber quanto tempo cada chamado levou, quais estouraram o prazo e como está a carga de cada
atendente. Todos os dados do projeto são **fictícios**.

## Solicitação do usuário

**Solicitante:** Fernanda, coordenadora de TI de uma empresa de médio porte. Leia o relato como se ela tivesse chamado
você para fazer o sistema. O que ela não explicou, você pergunta ao professor (ele faz o papel da Fernanda). A modelagem
é sua.

### O relato da Fernanda

> Minha equipe atende os funcionários da empresa: senha esquecida, notebook que não liga, internet fora do ar, sistema
> com erro. Hoje os pedidos chegam por e-mail e WhatsApp, e eu controlo tudo numa planilha. Ninguém sabe o que está
> parado.
>
> **Meu dia começa** vendo os chamados abertos, quais estouraram o prazo e como está a carga de cada atendente.
>
> **Chamado:** cada solicitante abre um chamado com categoria (acesso e senhas, equipamentos, rede, sistemas) e uma
> prioridade sugerida: baixa, média, alta ou crítica. O atendente pode mudar a prioridade, mas precisa justificar. Cada
> categoria tem uma fila. O atendimento tem dois níveis: N1 (triagem) e N2 (especialistas).
>
> **SLA** (*Service Level Agreement*, acordo de nível de serviço) é o prazo que prometemos, em horas corridas: crítica,
> 1 hora para a primeira resposta e 4 para resolver; alta, 4 e 8; média, 8 e 24; baixa, 24 e 72. Esses prazos mudam de
> tempos em tempos, e preciso saber qual valia quando o chamado foi aberto.
>
> **Status:** aberto, em atendimento, aguardando solicitante, resolvido, fechado e cancelado. Toda mudança precisa
> registrar quem fez e a hora. Quando o chamado está **aguardando solicitante**, o relógio do SLA para.
>
> **Atendente:** assume chamados da própria fila, no máximo 8 em atendimento ao mesmo tempo. Se o N1 não responde no
> prazo, o chamado vai para a fila do N2.
>
> **Comentários:** públicos (o solicitante vê) e internos (só nós). **Reabertura:** o solicitante reabre um resolvido
> em até 5 dias; depois, abre outro, ligado ao primeiro. Resolvido há 5 dias sem retorno, eu fecho. Depois de resolvido,
> o solicitante dá uma nota de 1 a 5. O chamado pode estar ligado a um equipamento da empresa (patrimônio).

### Minhas dificuldades hoje

1. **Prazo estourado**: só descubro depois. Quero ver os que estão perto de estourar e **avisar o atendente e o
   solicitante por e-mail e WhatsApp**, com registro do aviso.
2. Não sei **quanto tempo** cada chamado ficou em cada etapa.
3. **Carga desigual** entre os atendentes.
4. A pausa do SLA é feita de cabeça, e erro.
5. Quero saber quais **equipamentos e categorias** geram mais chamados.

### O que quero ver quando abrir o sistema

- Chamados **abertos** por fila e prioridade.
- Chamados que **estouraram** ou estão perto de estourar o SLA.
- A **carga** de cada atendente.
- O **tempo** em cada status de um chamado.
- Os equipamentos com **mais chamados**.

### O que guardo hoje

| Onde | O que tem |
|---|---|
| Planilha de chamados | número, solicitante, categoria, prioridade, status, datas |
| E-mails e WhatsApp | comentários e histórico (espalhados) |
| Planilha de patrimônio | equipamento, setor, responsável |

### Perguntas para fazer à Fernanda

- Um atendente pode atender mais de uma fila?
- Os campos do chamado variam por categoria? Quais?
- Quem pode alterar a prioridade? Fica registrado o valor anterior?
- Se o SLA muda, os chamados já abertos mudam também?

> O envio real de e-mail e WhatsApp é feito por outro sistema. **O banco de dados guarda o que precisa ser avisado e o que
> já foi avisado.**

## Regras de negócio

| Regra | Valor |
|---|---|
| Fila e nível | Cada categoria tem uma fila (acesso e senhas, equipamentos, rede, sistemas). O atendimento tem 2 níveis: **N1** (triagem) e **N2** (especialistas) |
| Prioridade | Baixa, média, alta e crítica. O solicitante sugere; o atendente pode alterar, **com justificativa registrada** |
| SLA | Dois prazos por prioridade, em **horas corridas**: crítica 1 h para a primeira resposta e 4 h para resolver; alta 4 h e 8 h; média 8 h e 24 h; baixa 24 h e 72 h. Os prazos **mudam com o tempo** e o histórico deve ser preservado |
| Status | Aberto, em atendimento, aguardando solicitante, resolvido, fechado e cancelado. Toda mudança é registrada com a hora e o autor |
| Pausa do SLA | Enquanto o chamado está **aguardando solicitante**, o relógio do SLA para. Ao voltar, o prazo é empurrado pelo tempo parado |
| Atribuição | Um atendente assume chamados da própria fila, no máximo **8 em atendimento ao mesmo tempo** |
| Escalonamento | Estourou o prazo da primeira resposta no N1, o chamado vai para a fila do N2. **Regra descrita**: o grupo não cria rotina para isso (o banco não roda nada sozinho; D-22) |
| Comentários | **Públicos** (o solicitante vê) e **internos** (só atendentes) |
| Reabertura | O solicitante reabre um chamado resolvido em até **5 dias**. Depois disso, abre um novo, ligado ao anterior |
| Fechamento | Chamado resolvido há 5 dias sem manifestação do solicitante é fechado |
| Satisfação | Uma nota de 1 a 5 por chamado, só depois de resolvido. É só um dado: **sem trigger** (D-22) |
| Ativo | O chamado pode estar ligado a um equipamento da empresa (patrimônio) |

## Modelo mínimo (a decidir pelo grupo; pelo menos 8 tabelas)

Solicitante (com setor), atendente, categoria, fila, prioridade, SLA (com vigência), chamado, comentário, histórico de status,
ativo (equipamento), pesquisa de satisfação. O grupo decide e **justifica** o desenho.

**Pontos que exigem decisão** (a prova cobra a justificativa):

1. SLA: gravar os prazos no chamado na abertura, ou consultar a regra vigente quando precisar? O que muda se a regra mudar?
2. Status: uma coluna no chamado, um histórico de mudanças, ou os dois? Como calcular quanto tempo o chamado ficou em cada etapa?
3. Pausa do SLA: como o banco sabe quanto tempo o chamado ficou aguardando o solicitante?
4. Atendente e fila: um atendente pode atender mais de uma fila? Como o escalonamento aparece no modelo (a fila do chamado muda ou há outro registro)?
5. Chamado reaberto x novo chamado ligado ao anterior: uma tabela com auto-relacionamento ou duas tabelas?
6. Campos que variam por categoria (um chamado de rede não pede o mesmo que um de equipamento): colunas, tabelas por categoria ou dados semiestruturados?

## Dados de apoio

- Coluna `dados_extras` (`JSONB`) no chamado: campos do formulário que variam por categoria (equipamento: patrimônio,
  modelo e sintomas; rede: setor e ponto de rede; acesso: sistema e perfil pedido).
- Número do chamado no formato `CH-2026-000123`, gerado com `LPAD`.

## Entrega 1 — Prova 1 (aula 12): modelo, DDL, carga e transações

Tag: `prova-1`. As transações são dadas na aula 11, um dia antes: a entrega é pequena e guiada pelo exercício do dia.

| # | Item | Arquivo | O que entregar |
|---|---|---|---|
| 1 | Modelo | `diagrama/` | Diagrama no ERD Concepts (conceitual e lógico) com cardinalidades, e a imagem exportada |
| 2 | Estrutura | `sql/01_ddl.sql` | Schema `helpdesk`, 8 ou mais tabelas, `PK`, `FK`, `UNIQUE`, `CHECK` e `DEFAULT` para as regras que o banco consegue garantir (prioridade e status válidos, nota de 1 a 5, uma pesquisa por chamado, resolução depois da abertura) |
| 3 | Normalização | `README.md` | Justificar até a 3FN e dizer uma desnormalização feita de propósito, se houver |
| 4 | Carga | `sql/02_carga.sql` | 4 categorias e filas, 8 atendentes (N1 e N2), 40 solicitantes de 6 setores, 30 ativos, 200 chamados em todos os status, com comentários (públicos e internos), histórico de status e SLA em mais de uma versão. Dados que **exercitam as regras** (chamado crítico com SLA estourado, chamado aguardando solicitante há 3 dias, atendente com 8 chamados, chamado reaberto) |
| 5 | Transações | `sql/03_transacoes.sql` | Abertura do chamado como transação (inserir o chamado, o primeiro registro do histórico e calcular os prazos do SLA, tudo ou nada), com `ROLLBACK` quando falhar |
| 6 | Concorrência | `sql/03_transacoes.sql` + `evidencias/` | **Duas sessões (dois atendentes) assumindo o mesmo chamado da fila**, e uma segunda situação: **dois atendentes assumindo o 8º chamado ao mesmo tempo**. Mostrar o problema (chamado atribuído duas vezes, limite ultrapassado), a solução (bloqueio de linha ou isolamento) e explicar por quê |
| 7 | Decisões | `README.md` | As respostas dos 6 pontos de decisão acima, por que a transação protege o que protege, divisão do trabalho e uso de IA |

Dado na aula: modelagem (9), análise de bancos (10), transações e ACID (11), DDL e normalização (revisão, aulas 2 e 3).

## Entrega 2 — Prova 2 (aula 16): funções SQL, subconsultas/CTE, `JSONB`, window functions e views

Tag: `prova-2`.

| # | Item | Arquivo | O que entregar |
|---|---|---|---|
| 1 | Funções SQL | `sql/04_consultas.sql` | 10 consultas, entre elas: número do chamado com `LPAD`, nome do solicitante formatado, tempo de resolução (`AGE` ou diferença de datas), prazo do SLA (`abertura + INTERVAL`), chamados por mês (`DATE_TRUNC`), hora do dia com mais aberturas (`EXTRACT`), dia da semana (`TO_CHAR`), tempo médio de resolução (`ROUND`), situação do SLA (`CASE`: no prazo, vence em 1 hora, estourado), `COALESCE` para "sem atendente" |
| 2 | Subconsultas e CTE | `sql/04_consultas.sql` | 3 ou mais: atendentes com mais chamados abertos que a média, categorias sem chamado no mês, percentual de SLA cumprido por atendente feito com CTE em etapas (resolvidos, dentro do prazo, percentual) |
| 3 | `JSONB` | `sql/04_consultas.sql` | 3 consultas sobre `dados_extras` (chamados de rede de um setor, chamados de equipamento de um patrimônio, listar os sintomas relatados) |
| 4 | Window functions | `sql/05_janelas_views.sql` | 2 consultas: ranking de atendentes por chamados resolvidos dentro da fila (`RANK`) e tempo entre uma mudança de status e a anterior no histórico (`LAG`) |
| 5 | Views | `sql/05_janelas_views.sql` | `vw_chamados_abertos` (com tempo restante do SLA) e uma view materializada com indicadores mensais por categoria (volume, tempo médio e SLA cumprido), com atualização |
| 6 | Decisões | `README.md` | Decisões, o que a IA errou, divisão do trabalho |

Dado na aula: funções SQL (13), subconsultas, CTE e `JSONB` (14), window functions e views (15).

## Entrega 3 — Prova 3 (aula 21): índice, funções, procedures e triggers

Tag: `prova-3`. Com o bloco de `PL/pgSQL` em três dias (aulas 18 a 20, com 40 min de projeto por dia), a entrega pede
**mais rotinas e testadas**, e a parte de índice segue enxuta.

| # | Item | Arquivo | O que entregar |
|---|---|---|---|
| 1 | Índice | `sql/06_indices.sql` + `evidencias/` | Carga em volume (200 mil chamados ou registros de histórico, com `generate_series`), **1 consulta lenta** (chamados de uma fila por status em um período), `EXPLAIN` antes e depois do índice e explicação |
| 2 | Funções | `sql/07_funcoes.sql` | 3 ou mais: `calcular_prazo_sla(prioridade, abertura)`, `tempo_efetivo(chamado)` (tempo de atendimento descontando o tempo aguardando solicitante) e `atendente_pode_assumir(atendente, chamado)` (fila e limite de 8, retornando o motivo). Cada uma com chamada de teste e resultado em `evidencias/` |
| 3 | Procedures | `sql/08_procedures.sql` | 3: `abrir_chamado(solicitante, categoria, prioridade, descricao, dados)` (valida e calcula o SLA), `assumir_chamado(chamado, atendente)` (fila, limite e status) e `resolver_chamado(chamado, solucao)` (muda o status e libera o atendente). Erros com `RAISE EXCEPTION` e mensagens claras, cada uma com um teste que dá certo e um que falha |
| 4 | Triggers | `sql/09_triggers.sql` | 2: **histórico de status** (quem, quando, antes e depois, permitindo calcular o tempo de cada etapa) e **regra de negócio** (ao sair de `aguardando solicitante`, o prazo do SLA é empurrado pelo tempo parado), com um teste de cada |
| 5 | Decisões | `README.md` | Onde cada regra ficou (função, procedure, trigger ou `CHECK`) e por quê, divisão do trabalho, uso de IA |

Dado na aula: índices e `generate_series` (17), funções (18), procedures (19), triggers (20).

## Entrega final — Prova 4 (aulas 23 e 24): apresentação

Tag: `final`.

- **Demonstração (6 min):** um cenário de ponta a ponta: o solicitante abre um chamado crítico, dois atendentes tentam assumir
  e só um consegue, o chamado fica aguardando o solicitante e o SLA pausa, o solicitante responde e o prazo é empurrado, o
  chamado é resolvido e o relatório mostra o SLA cumprido por atendente. Executado ao vivo por uma procedure.
- **Desenvolvimento do projeto (4 min):** linha do tempo, decisões difíceis, dificuldades, o que a IA errou e o que o grupo aprendeu.
- **Entrega:** repositório com `instalar.sql` que recria o banco do zero e `README.md` final.

## Rubrica (parte do grupo, 10 pontos por prova)

| Prova | Item | Pontos |
|---|---|---|
| 1 | Modelo e justificativas (itens 1, 3 e 7) | 3,0 |
| 1 | DDL com regras no banco (item 2) | 2,5 |
| 1 | Carga que exercita as regras (item 4) | 1,5 |
| 1 | Transação e concorrência, com explicação (itens 5 e 6) | 3,0 |
| 2 | Funções SQL (item 1) | 2,5 |
| 2 | Subconsultas e CTE (item 2) | 2,0 |
| 2 | `JSONB` (item 3) | 1,0 |
| 2 | Window functions e views (itens 4 e 5) | 3,0 |
| 2 | Decisões e uso de IA (item 6) | 1,5 |
| 3 | Índice com `EXPLAIN` e análise (item 1) | 2,0 |
| 3 | Funções (item 2) | 2,0 |
| 3 | Procedures (item 3) | 2,0 |
| 3 | Triggers (item 4) | 2,5 |
| 3 | Decisões e uso de IA (item 5) | 1,5 |
| 4 | Demonstração: cenário de ponta a ponta, regras de negócio funcionando ao vivo | 4,0 |
| 4 | Desenvolvimento do projeto: linha do tempo, decisões e dificuldades | 2,5 |
| 4 | Uso de IA: o que a IA errou e o que o grupo corrigiu | 1,5 |
| 4 | Entrega: `instalar.sql` que recria o banco do zero, `README.md` e divisão do trabalho | 2,0 |

Penalidade: entrega que não roda do zero, sem `README.md` ou sem divisão do trabalho perde até 2 pontos.
Na prova 4 não há penalidade à parte: o critério «Entrega» já cobre `instalar.sql`, `README.md` e divisão do trabalho. As perguntas do professor entram na parte individual (40%).
A nota do aluno é 60% desta parte (grupo) e 40% individual (20% a parte apresentada e 20% a pergunta individual, D-36).

## Diferenças em relação aos projetos anteriores

- É o projeto **mais voltado a triggers**: o histórico de status e a pausa do SLA são regras que reagem a mudanças e
  naturalmente moram no banco.
- O **SLA** transforma datas e intervalos em regra de negócio (`abertura + INTERVAL`, tempo parado descontado), usando bem as
  funções de data da prova 2 e a função `tempo_efetivo` da prova 3.
- A **fila concorrida** (vários atendentes pegando o mesmo chamado) é o cenário clássico de bloqueio de linha.
- O `JSONB` guarda os campos do formulário que variam por categoria.
