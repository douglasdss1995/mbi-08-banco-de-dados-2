# Projeto 5 — Delivery de comida

Estrutura comum das entregas (GitHub, tags, notas): [00-estrutura-das-entregas.md](00-estrutura-das-entregas.md).
Projetos de referência já detalhados: [01-biblioteca.md](01-biblioteca.md) e [02-clinica-medica.md](02-clinica-medica.md).

## Cenário

Um aplicativo de delivery conecta **restaurantes, clientes e entregadores**. O cliente escolhe um restaurante, monta o
pedido com itens do cardápio e recebe em casa. O restaurante aceita e prepara, e um entregador leva. A plataforma quer
controlar **pedidos, entregas, tempos, comissões** e a qualidade do serviço. Todos os dados do projeto são **fictícios**.

## Solicitação do usuário

**Solicitante:** Camila, gerente de operações de um aplicativo de delivery regional. Leia o relato como se ela tivesse
chamado você para fazer o sistema. O que ela não explicou, você pergunta ao professor (ele faz o papel da Camila). A
modelagem é sua.

### O relato da Camila

> Nosso aplicativo liga restaurantes, clientes e entregadores. Hoje o cadastro está no sistema do fornecedor, mas ele
> não me dá os números de que preciso, então exporto planilhas e tento juntar.
>
> **Meu dia começa** vendo os pedidos atrasados da noite anterior e os restaurantes que ficaram fechados no horário
> de pico. Depois vejo quantos entregadores estão disponíveis.
>
> **Restaurante:** tem categoria culinária, horário de funcionamento (cada dia da semana é diferente, e alguns fecham
> depois da meia-noite), pedido mínimo e comissão (padrão de 15% sobre os itens). O cardápio tem preços que mudam, e
> o item pode ficar indisponível. Pedido antigo precisa manter o preço da época.
>
> **Pedido:** um cliente, um restaurante, vários itens, às vezes com observação ("sem cebola"). Cada mudança de status
> (criado, aceito, em preparo, pronto, a caminho, entregue, cancelado) precisa ficar registrada com a hora.
>
> **Taxa de entrega** por distância: até 3 km, R$ 5; de 3 a 6 km, R$ 8; acima disso, R$ 12. Pedido de R$ 80 ou mais em
> itens tem taxa grátis.
>
> **Entregador:** disponível, em entrega ou offline. Só uma entrega por vez, e só pega pedido pronto.
>
> **Cancelamento:** sem custo até o restaurante aceitar; depois, o cliente paga 50% dos itens; em preparo, 100%.
>
> **Prazo:** cada pedido tem um tempo prometido. Passou, está atrasado. Depois da entrega, o cliente avalia restaurante
> e entregador (nota de 1 a 5).
>
> **Repasse:** a plataforma fica com a comissão e repassa o resto ao restaurante.

### Minhas dificuldades hoje

1. **Pedidos atrasados**: só descubro quando o cliente reclama. Quero ver na hora e **avisar o cliente por e-mail e
   WhatsApp**, com registro do aviso.
2. Não sei **quanto tempo** o pedido leva em cada etapa (aceite, preparo, entrega).
3. Calcular o **repasse** de cada restaurante no mês é manual e dá erro.
4. Não sei quais restaurantes e entregadores têm **pior avaliação**.
5. Entregador pegando duas entregas ao mesmo tempo.

### O que quero ver quando abrir o sistema

- Os pedidos **atrasados agora** e se o cliente já foi avisado.
- O **tempo médio** de cada etapa por restaurante.
- O **repasse do mês** por restaurante.
- **Ranking** de restaurantes e de entregadores por nota.
- Entregadores **disponíveis** agora.

### O que guardo hoje

| Onde | O que tem |
|---|---|
| Exportação do fornecedor | pedidos, restaurantes, clientes |
| Planilha de repasse | restaurante, mês, valor dos itens, comissão |
| Planilha de entregadores | nome, telefone, situação |

### Perguntas para fazer à Camila

- Se o entregador desiste da entrega, outro assume? O que fica registrado?
- A comissão muda por restaurante? O que acontece com pedidos antigos quando muda?
- A distância vem do endereço do cliente? Quem informa?
- O cliente pode pedir em dois restaurantes ao mesmo tempo?

> O envio real de e-mail e WhatsApp é feito por outro sistema. **O banco de dados guarda o que precisa ser avisado e o que
> já foi avisado.**

## Regras de negócio

| Regra | Valor |
|---|---|
| Restaurante | Tem categoria culinária, horário de funcionamento por dia da semana, pedido mínimo e comissão da plataforma (padrão de 15% dos itens) |
| Cardápio | Cada item tem preço e pode ficar **indisponível**. O **preço muda com o tempo** e o pedido antigo deve continuar com o valor da época |
| Pedido | Um cliente, **um restaurante**, vários itens. Restaurante fechado ou item indisponível não recebe pedido |
| Status do pedido | Criado, aceito, em preparo, pronto, a caminho, entregue, cancelado. Cada mudança é registrada com a hora |
| Taxa de entrega | Por faixa de distância: até 3 km, R$ 5,00; de 3 a 6 km, R$ 8,00; acima de 6 km, R$ 12,00. Pedido de R$ 80,00 ou mais (só itens) tem taxa grátis. A distância é um **dado do endereço** (`distancia_km` em km, informada na carga; o curso não usa geolocalização; D-27) |
| Endereço de entrega | O cliente tem vários endereços. O pedido preserva o endereço usado, mesmo que o cliente o altere depois |
| Entregador | Está `disponivel`, `em_entrega` ou `offline`. Tem **uma entrega ativa por vez** e só recebe pedido `pronto` |
| Cancelamento | O cliente cancela sem custo até o restaurante aceitar. Depois, paga 50% dos itens; em preparo, paga 100%. O restaurante pode recusar |
| Pagamento | Online (pix ou cartão) ou dinheiro na entrega, com a taxa de entrega incluída |
| Prazo | Cada pedido recebe um **tempo prometido** (preparo estimado mais o deslocamento). Passou disso, o pedido é marcado como atrasado |
| Avaliação | Uma nota de 1 a 5 do restaurante e outra do entregador, por pedido entregue |
| Comissão e repasse | A plataforma fica com a comissão sobre os itens; o restante é repassado ao restaurante |

## Modelo mínimo (a decidir pelo grupo; pelo menos 8 tabelas)

Categoria culinária, restaurante, horário de funcionamento, item do cardápio, cliente, endereço, entregador, pedido, item do
pedido, entrega, pagamento, avaliação, faixa de taxa, histórico de status. O grupo decide e **justifica** o desenho.

**Pontos que exigem decisão** (a prova cobra a justificativa):

1. O preço do item muda: gravar o valor no item do pedido, consultar o histórico, ou os dois?
2. Pedido x entrega: uma tabela ou duas? O que acontece se o entregador desiste e outro assume?
3. Horário de funcionamento: como representar por dia da semana, e o restaurante que fecha depois da meia-noite?
4. Status: uma coluna no pedido, um histórico de mudanças, ou os dois? Como calcular o tempo de cada etapa?
5. Comissão: guardar o valor calculado no pedido ou recalcular sempre? E se a comissão do restaurante mudar depois?
6. Opcionais e observações do item ("sem cebola", "queijo extra"): tabelas à parte ou dados semiestruturados?

## Dados de apoio

- Coluna `detalhes` (`JSONB`) no item do cardápio: ingredientes, alergênicos, calorias, tamanhos e outros campos que variam
  de prato para prato (uma pizza e um suco não têm os mesmos atributos).
- Número do pedido no formato `DL-2026-000123`, gerado com `LPAD`.

## Entrega 1 — Prova 1 (aula 12): modelo, DDL, carga e transações

Tag: `prova-1`. As transações são dadas na aula 11, um dia antes: a entrega é pequena e guiada pelo exercício do dia.

| # | Item | Arquivo | O que entregar |
|---|---|---|---|
| 1 | Modelo | `diagrama/` | Diagrama no ERD Concepts (conceitual e lógico) com cardinalidades, e a imagem exportada |
| 2 | Estrutura | `sql/01_ddl.sql` | Schema `delivery`, 8 ou mais tabelas, `PK`, `FK`, `UNIQUE`, `CHECK` e `DEFAULT` para as regras que o banco consegue garantir (nota de 1 a 5, status válidos, preço positivo, uma avaliação por pedido) |
| 3 | Normalização | `README.md` | Justificar até a 3FN e dizer uma desnormalização feita de propósito, se houver |
| 4 | Carga | `sql/02_carga.sql` | 8 restaurantes em 4 categorias culinárias, 60 itens de cardápio (alguns com mais de um preço ao longo do tempo), 40 clientes com 60 endereços, 10 entregadores, 150 pedidos em todos os status, com itens, entregas, pagamentos e histórico de status. Dados que **exercitam as regras** (restaurante fechado agora, item indisponível, pedido atrasado, entregador com entrega ativa) |
| 5 | Transações | `sql/03_transacoes.sql` | Criação do pedido como transação (inserir o pedido, os itens com o preço do momento e o pagamento pendente, tudo ou nada), com `ROLLBACK` quando falhar |
| 6 | Concorrência | `sql/03_transacoes.sql` + `evidencias/` | **Duas sessões (dois entregadores) aceitando o mesmo pedido pronto**: mostrar o problema (entrega duplicada), a solução (bloqueio de linha ou isolamento) e explicar por quê |
| 7 | Decisões | `README.md` | As respostas dos 6 pontos de decisão acima, por que a transação protege o que protege, divisão do trabalho e uso de IA |

Dado na aula: modelagem (9), análise de bancos (10), transações e ACID (11), DDL e normalização (revisão, aulas 2 e 3).

## Entrega 2 — Prova 2 (aula 16): funções SQL, subconsultas/CTE, `JSONB`, window functions e views

Tag: `prova-2`.

| # | Item | Arquivo | O que entregar |
|---|---|---|---|
| 1 | Funções SQL | `sql/04_consultas.sql` | 10 consultas, entre elas: número do pedido com `LPAD`, nome do cliente formatado, tempo total de entrega (`AGE` ou diferença de datas), horário de pico (`EXTRACT` da hora), pedidos por mês (`DATE_TRUNC`), dia da semana com mais pedidos (`TO_CHAR`), ticket médio (`ROUND`), situação (`CASE`: no prazo, atrasado, cancelado), `COALESCE` para "aguardando entregador", comissão por pedido |
| 2 | Subconsultas e CTE | `sql/04_consultas.sql` | 3 ou mais: restaurantes sem pedido na última semana, clientes com ticket acima da média, ranking de entregadores por tempo médio de entrega feito com CTE em etapas |
| 3 | `JSONB` | `sql/04_consultas.sql` | 3 consultas sobre `detalhes` (itens sem determinado alergênico, itens abaixo de um limite de calorias, listar os ingredientes de um prato) |
| 4 | Window functions | `sql/05_janelas_views.sql` | 2 consultas: ranking de restaurantes por categoria culinária em faturamento (`RANK`) e faturamento acumulado por mês |
| 5 | Views | `sql/05_janelas_views.sql` | `vw_pedidos_em_andamento` e uma view materializada com faturamento e comissão mensais por restaurante, com atualização |
| 6 | Decisões | `README.md` | Decisões, o que a IA errou, divisão do trabalho |

Dado na aula: funções SQL (13), subconsultas, CTE e `JSONB` (14), window functions e views (15).

## Entrega 3 — Prova 3 (aula 21): índice, funções, procedures e triggers

Tag: `prova-3`. Com o bloco de `PL/pgSQL` em três dias (aulas 18 a 20, com 40 min de projeto por dia), a entrega pede
**mais rotinas e testadas**, e a parte de índice segue enxuta.

| # | Item | Arquivo | O que entregar |
|---|---|---|---|
| 1 | Índice | `sql/06_indices.sql` + `evidencias/` | Carga em volume (100 mil pedidos ou mais, com `generate_series`), **1 consulta lenta** (pedidos de um restaurante em um período), `EXPLAIN` antes e depois do índice e explicação |
| 2 | Funções | `sql/07_funcoes.sql` | 3 ou mais: `calcular_taxa_entrega(distancia_km, valor_itens)`, `calcular_comissao(pedido)` e `restaurante_aberto(restaurante, momento)` (dia da semana e horário, retornando o motivo). Cada uma com chamada de teste e resultado em `evidencias/` |
| 3 | Procedures | `sql/08_procedures.sql` | 3: `criar_pedido(cliente, restaurante, endereco)` (restaurante aberto, pedido mínimo, itens disponíveis, taxa de entrega), `atribuir_entregador(pedido, entregador)` (pedido pronto, entregador disponível, uma entrega ativa) e `concluir_entrega(pedido)` (muda o status e registra o pagamento em dinheiro, se for o caso). Erros com `RAISE EXCEPTION` e mensagens claras, cada uma com um teste que dá certo e um que falha |
| 4 | Triggers | `sql/09_triggers.sql` | 2: **histórico de status** do pedido (quem, quando, antes e depois, permitindo calcular o tempo de cada etapa) e **regra de negócio** (ao entregar ou cancelar, o entregador volta a `disponivel`), com um teste de cada |
| 5 | Decisões | `README.md` | Onde cada regra ficou (função, procedure, trigger ou `CHECK`) e por quê, divisão do trabalho, uso de IA |

Dado na aula: índices e `generate_series` (17), funções (18), procedures (19), triggers (20).

## Entrega final — Prova 4 (aulas 23 e 24): apresentação

Tag: `final`.

- **Demonstração (6 min):** um cenário de ponta a ponta: o cliente pede, o sistema recusa um pedido com restaurante fechado,
  o restaurante prepara, dois entregadores tentam pegar o mesmo pedido e só um consegue, a entrega é concluída e o relatório
  mostra o faturamento e a comissão. Executado ao vivo por uma procedure.
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

- O ponto forte é o **ciclo de vida do pedido**: status com histórico e tempo de cada etapa (função de datas na prova 2 e
  trigger de histórico na prova 3).
- Há **três atores** (cliente, restaurante, entregador) disputando o mesmo pedido, o que rende a concorrência da prova 1.
- A regra de **restaurante aberto** exige pensar em dia da semana e horário, boa para uma função.
- O `JSONB` guarda ingredientes, alergênicos e calorias, que variam de prato para prato.
