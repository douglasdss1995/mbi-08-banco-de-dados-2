# Projeto 10 — Cinema

Estrutura comum das entregas (GitHub, tags, notas): [00-estrutura-das-entregas.md](00-estrutura-das-entregas.md).
Projetos de referência já detalhados: [01-biblioteca.md](01-biblioteca.md) e [02-clinica-medica.md](02-clinica-medica.md).

## Cenário

Um cinema com várias **salas** exibe **filmes** em **sessões** com horário. O cliente escolhe a sessão, **escolhe os assentos**
e paga o **ingresso** (inteira ou meia). Muita gente compra ao mesmo tempo, principalmente na estreia, e o mesmo assento não
pode ser vendido duas vezes. O cinema quer controlar a venda, a ocupação das sessões e a bilheteria por filme. Todos os dados
do projeto são **fictícios**.

## Solicitação do usuário

**Solicitante:** Henrique, gerente de um cinema com seis salas. Leia o relato como se ele tivesse chamado você para
fazer o sistema. O que ele não explicou, você pergunta ao professor (ele faz o papel do Henrique). A modelagem é sua.

### O relato do Henrique

> Temos seis salas (2D, 3D e VIP). Hoje a venda de ingressos é num sistema antigo que não me dá relatórios, e na
> estreia a fila trava. Já vendemos o mesmo assento duas vezes.
>
> **Meu dia começa** vendo as sessões do dia, a ocupação de cada uma e se algum filme entrou ou saiu de cartaz.
>
> **Filme:** tem gênero, duração, classificação indicativa (livre, 10, 12, 14, 16 e 18) e idioma. **Sessão:** filme,
> sala, horário e formato (dublado ou legendado). Duas sessões na mesma sala não podem se sobrepor: depois do fim do
> filme, preciso de 20 minutos para a limpeza.
>
> **Sala:** tem tipo e uma grade de assentos (fileira e número). Há assentos especiais (cadeirante e casal).
>
> **Preço:** a inteira depende do tipo da sala e do dia da semana (quarta é promocional), e os valores mudam com o tempo.
> **Meia-entrada** é 50%, para estudante, idoso (60 anos ou mais), criança até 12 anos e pessoa com deficiência.
>
> **Venda:** o mesmo assento nunca pode ser vendido duas vezes na mesma sessão. Quem escolhe o assento o segura por
> 10 minutos enquanto paga. Compra de 1 a 3 ingressos, todos da mesma sessão, e é tudo ou nada: se um assento não
> puder ser vendido, nenhum é.
>
> **Classificação:** menor de idade só compra se houver, na mesma compra, um ingresso de adulto (18 anos ou mais).
>
> **Cancelamento:** pelo cliente, até 2 horas antes do início, com reembolso total; depois, sem reembolso. Se o cinema
> cancela a sessão, reembolsa sempre. Quando o último assento é vendido, a sessão fica **esgotada**.

### Minhas dificuldades hoje

1. **Venda dupla** do mesmo assento na hora da estreia.
2. Não sei a **ocupação** de cada sessão para decidir os horários.
3. **Sessão cancelada**: preciso avisar quem comprou, por e-mail e WhatsApp, e ter certeza de quem já foi avisado.
4. A **bilheteria por filme** é feita à mão no fim do mês.
5. Calcular preço com meia e quarta promocional confunde a bilheteria.

### O que quero ver quando abrir o sistema

- As **sessões do dia** e os assentos livres de cada uma.
- **Sessões esgotadas**.
- A **bilheteria** por filme e por dia.
- A **ocupação média** por sala e horário.
- Compras de uma sessão cancelada que **ainda não foram avisadas**.

### O que guardo hoje

| Onde | O que tem |
|---|---|
| Sistema antigo de bilheteria | ingressos vendidos (sem relatório) |
| Planilha de programação | filme, sala, horário |
| Planilha de preços | tipo de sala, dia, valor |

### Perguntas para fazer ao Henrique

- O que acontece com o assento se o cliente desiste de pagar?
- Se o preço muda, o ingresso já vendido muda?
- Quem comprou e cancelou volta ao estoque de assentos?
- Existem sessões que atravessam a meia-noite?

> O envio real de e-mail e WhatsApp é feito por outro sistema. **O banco de dados guarda o que precisa ser avisado e o que
> já foi avisado.**

## Regras de negócio

| Regra | Valor |
|---|---|
| Sala | Tem tipo (2D, 3D e VIP) e uma grade de assentos (fileira e número). Há assentos **especiais** (cadeirante e casal) |
| Filme | Tem gênero, duração em minutos, **classificação indicativa** (livre, 10, 12, 14, 16 e 18) e idioma |
| Sessão | Filme, sala, início, formato (dublado ou legendado). **Duas sessões na mesma sala não podem se sobrepor**: o fim é o início mais a duração do filme mais 20 minutos de limpeza |
| Preço | Valor da inteira por tipo de sala e dia da semana (**quarta-feira** é promocional). Os valores **mudam com o tempo** e o histórico deve ser preservado |
| Meia-entrada | 50% do valor da inteira, para estudante (com carteirinha), idoso (60 anos ou mais), criança até 12 anos e pessoa com deficiência |
| Ingresso | Um assento por sessão: **o mesmo assento não pode ser vendido duas vezes na mesma sessão** |
| Classificação | O cliente com idade abaixo da classificação só compra se houver, **na mesma compra**, um ingresso de adulto (18 anos ou mais) |
| Reserva do assento | Quem escolhe o assento o segura por **10 minutos** enquanto paga. Vencido o prazo sem pagamento, o assento é liberado pela procedure `liberar_reservas_vencidas()`, **chamada à mão** (o banco não roda nada sozinho; D-23). Bomboniere e combos ficam fora do projeto |
| Compra | De **1 a 3 ingressos** por compra, todos da mesma sessão. A compra é **tudo ou nada**: se um assento não puder ser vendido, nenhum é |
| Pagamento | Pix ou cartão. Compra paga é confirmada e gera os ingressos |
| Cancelamento | Pelo cliente, até 2 horas antes do início, com reembolso integral; depois disso, sem reembolso. Pelo cinema (sessão cancelada), reembolso integral sempre |
| Sessão esgotada | Quando o último assento é vendido, a sessão passa a **esgotada**. Se uma compra for cancelada, deixa de estar |

## Modelo mínimo (a decidir pelo grupo; pelo menos 8 tabelas)

Gênero, filme, sala, assento, sessão, preço (com vigência), cliente, compra, ingresso, tipo de ingresso, pagamento. O grupo
decide e **justifica** o desenho.

**Pontos que exigem decisão** (a prova cobra a justificativa):

1. Assento x ingresso x sessão: o assento é da sala e o ingresso liga **assento e sessão**. Qual restrição impede a venda dupla?
2. Reserva temporária: uma tabela à parte, um status no ingresso ou uma coluna de validade? Quem libera os assentos vencidos?
3. O preço muda: gravar o valor pago no ingresso, consultar o preço vigente na data, ou os dois?
4. Meia-entrada: tipo de ingresso com percentual na tabela ou regra no código? O valor pago é guardado calculado?
5. Sobreposição de sessões na mesma sala: como o banco sabe o fim de uma sessão (campo calculado ou guardado)?
6. Compra x ingresso: uma tabela ou duas? O que acontece com os ingressos quando a compra é cancelada?

## Dados de apoio

- Coluna `ficha_tecnica` (`JSONB`) no filme: direção, elenco (lista), roteiro, países, idiomas de áudio e legenda, premiações
  e links de trailer. Filmes diferentes têm campos diferentes.
- Código do ingresso no formato `CN-000123`, gerado com `LPAD`.

## Entrega 1 — Prova 1 (aula 12): modelo, DDL, carga e transações

Tag: `prova-1`. As transações são dadas na aula 11, um dia antes: a entrega é pequena e guiada pelo exercício do dia.

| # | Item | Arquivo | O que entregar |
|---|---|---|---|
| 1 | Modelo | `diagrama/` | Diagrama no ERD Concepts (conceitual e lógico) com cardinalidades, e a imagem exportada |
| 2 | Estrutura | `sql/01_ddl.sql` | Schema `cinema`, 8 ou mais tabelas, `PK`, `FK`, `UNIQUE`, `CHECK` e `DEFAULT` para as regras que o banco consegue garantir (**um assento por sessão** com `UNIQUE (sessao, assento)`, classificação válida, duração positiva, valores positivos, status válidos) |
| 3 | Normalização | `README.md` | Justificar até a 3FN e dizer uma desnormalização feita de propósito, se houver |
| 4 | Carga | `sql/02_carga.sql` | 4 salas com 40 a 80 assentos cada, 12 filmes em 5 gêneros, 40 sessões (passadas, do dia e futuras), 60 clientes, 100 compras com 250 ingressos (inteira e meia) e pagamentos, preços em mais de uma versão. Dados que **exercitam as regras** (sessão esgotada, sessão com um assento livre, compra cancelada com reembolso, cliente menor em filme 16 anos) |
| 5 | Transações | `sql/03_transacoes.sql` | Compra de 3 ingressos como transação (criar a compra, vender os 3 assentos e registrar o pagamento, tudo ou nada), com `ROLLBACK` quando um dos assentos já estiver vendido |
| 6 | Concorrência | `sql/03_transacoes.sql` + `evidencias/` | **Duas sessões disputando o mesmo assento (o último livre da sessão)**: mostrar o que acontece **sem** a proteção e **com** ela (`UNIQUE` e bloqueio de linha), por que a segunda compra falha e por que o resto da compra dela também é desfeito |
| 7 | Decisões | `README.md` | As respostas dos 6 pontos de decisão acima, por que a transação protege o que protege, divisão do trabalho e uso de IA |

Dado na aula: modelagem (9), análise de bancos (10), transações e ACID (11), DDL e normalização (revisão, aulas 2 e 3).

## Entrega 2 — Prova 2 (aula 16): funções SQL, subconsultas/CTE, `JSONB`, window functions e views

Tag: `prova-2`.

| # | Item | Arquivo | O que entregar |
|---|---|---|---|
| 1 | Funções SQL | `sql/04_consultas.sql` | 10 consultas, entre elas: código do ingresso com `LPAD`, nome do cliente formatado, horário de término da sessão (início + duração), duração do filme em horas e minutos (`TO_CHAR` ou `EXTRACT`), ingressos por mês (`DATE_TRUNC`), dia da semana com mais vendas (`TO_CHAR`), idade do cliente e se pode assistir (`AGE`), taxa de ocupação da sessão (`ROUND`), situação da sessão (`CASE`: esgotada, últimos lugares, disponível, encerrada), `COALESCE` para ingresso sem tipo informado |
| 2 | Subconsultas e CTE | `sql/04_consultas.sql` | 3 ou mais: filmes sem sessão na próxima semana, sessões com ocupação abaixo da média, bilheteria por filme feita com CTE em etapas (ingressos, valor pago, estornos) |
| 3 | `JSONB` | `sql/04_consultas.sql` | 3 consultas sobre `ficha_tecnica` (filmes de um diretor, filmes com um ator no elenco, listar os idiomas de legenda) |
| 4 | Window functions | `sql/05_janelas_views.sql` | 2 consultas: ranking de filmes por bilheteria dentro do gênero (`RANK`) e bilheteria acumulada por dia |
| 5 | Views | `sql/05_janelas_views.sql` | `vw_sessoes_do_dia` (sessões com assentos livres e situação) e uma view materializada com bilheteria e ocupação mensais por filme, com atualização |
| 6 | Decisões | `README.md` | Decisões, o que a IA errou, divisão do trabalho |

Dado na aula: funções SQL (13), subconsultas, CTE e `JSONB` (14), window functions e views (15).

## Entrega 3 — Prova 3 (aula 21): índice, funções, procedures e triggers

Tag: `prova-3`. Com o bloco de `PL/pgSQL` em três dias (aulas 18 a 20, com 40 min de projeto por dia), a entrega pede
**mais rotinas e testadas**, e a parte de índice segue enxuta.

| # | Item | Arquivo | O que entregar |
|---|---|---|---|
| 1 | Índice | `sql/06_indices.sql` + `evidencias/` | Carga em volume (200 mil ingressos ou mais, com `generate_series`), **1 consulta lenta** (ingressos de um cliente ou de uma sessão), `EXPLAIN` antes e depois do índice e explicação |
| 2 | Funções | `sql/07_funcoes.sql` | 3 ou mais: `calcular_preco(sessao, tipo_ingresso)` (tipo de sala, dia da semana e meia-entrada), `assentos_livres(sessao)` e `cliente_pode_assistir(cliente, filme)` (idade e classificação, retornando o motivo). Cada uma com chamada de teste e resultado em `evidencias/` |
| 3 | Procedures | `sql/08_procedures.sql` | 3, mais a rotina curta `liberar_reservas_vencidas()` (libera as reservas vencidas, chamada à mão): `reservar_assento(sessao, assento, cliente)` (assento livre, sem reserva vigente, por 10 minutos), `comprar_ingressos(cliente, sessao, tipo, assento1, assento2, assento3)` (de 1 a 3 assentos fixos: `assento2` e `assento3` são opcionais, com `DEFAULT NULL`; tudo ou nada, classificação e pagamento) e `cancelar_compra(compra)` (prazo de 2 horas, reembolso e liberação dos assentos). Erros com `RAISE EXCEPTION` e mensagens claras, cada uma com um teste que dá certo e um que falha |
| 4 | Triggers | `sql/09_triggers.sql` | 2: **auditoria** das mudanças de status da compra (quem, quando, antes e depois) e **regra de negócio** (ao vender o último assento a sessão passa a `esgotada`; ao cancelar uma compra deixa de estar), com um teste de cada |
| 5 | Decisões | `README.md` | Onde cada regra ficou (função, procedure, trigger ou `CHECK`) e por quê, divisão do trabalho, uso de IA |

Dado na aula: índices e `generate_series` (17), funções (18), procedures (19), triggers (20).

## Entrega final — Prova 4 (aulas 23 e 24): apresentação

Tag: `final`.

- **Demonstração (6 min):** um cenário de ponta a ponta: o cliente reserva três assentos, outro tenta um dos mesmos assentos
  e é recusado, a reserva vence e o assento volta, uma compra de um menor em filme 16 anos sem adulto é recusada, a compra é
  paga, a sessão esgota ao vender o último lugar, um cancelamento libera os assentos e o relatório mostra a bilheteria.
  Executado ao vivo por uma procedure.
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

- É o projeto **mais voltado a concorrência**: o recurso disputado (o assento) é único e todos o querem ao mesmo tempo. A
  prova 1 mostra a venda dupla; a restrição `UNIQUE` já protege, mas a compra de vários assentos exige a **transação**.
- A **reserva com prazo** (10 minutos) traz o tempo para dentro do modelo: o que vale agora depende da hora.
- A **sobreposição de sessões** na mesma sala é uma regra de intervalo, parecida com a da locadora e do hotel.
- O `JSONB` guarda a ficha técnica do filme (elenco em lista, idiomas, premiações), que varia de filme para filme.
