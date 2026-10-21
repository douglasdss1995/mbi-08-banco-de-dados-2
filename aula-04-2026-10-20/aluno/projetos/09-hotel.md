# Projeto 9 — Hotel ou pousada

Estrutura comum das entregas (GitHub, tags, notas): [00-estrutura-das-entregas.md](00-estrutura-das-entregas.md).
Projetos de referência já detalhados: [01-biblioteca.md](01-biblioteca.md) e [02-clinica-medica.md](02-clinica-medica.md).

## Cenário

Uma pousada de porte médio tem **quartos de vários tipos** e recebe **hóspedes** por reserva ou direto no balcão. Cada
estadia tem check-in, check-out, **diárias com tarifa por temporada** e uma **conta de consumo** (frigobar, restaurante,
lavanderia). A pousada quer controlar a ocupação, evitar a venda do mesmo quarto duas vezes e fechar a conta no check-out.
Todos os dados do projeto são **fictícios**.

## Solicitação do usuário

**Solicitante:** Dona Lúcia, proprietária de uma pousada de porte médio. Leia o relato como se ela tivesse chamado você
para fazer o sistema. O que ela não explicou, você pergunta ao professor (ele faz o papel da Dona Lúcia). A modelagem é
sua.

### O relato da Dona Lúcia

> A pousada tem 30 quartos de três tipos: standard, superior e suíte. Recebo reservas por telefone, site e balcão. Hoje
> controlo tudo num caderno de reservas e numa planilha, e já vendi o mesmo quarto duas vezes.
>
> **Meu dia começa** vendo quem chega e quem sai hoje, e quais quartos estão sujos esperando a camareira.
>
> **Tarifa:** a diária depende do tipo de quarto e da temporada (baixa, alta e feriado), e os valores mudam de ano
> para ano. Acima de 2 hóspedes cobro um adicional por pessoa por noite. Criança até 5 anos não paga.
>
> **Reserva:** é por **tipo** de quarto, com datas de entrada e saída e número de hóspedes. Mínimo de 1 noite; na
> alta temporada, 2. Só aceito se houver quarto do tipo livre em todas as noites. Cobro um sinal de 30% das diárias.
>
> **Cancelamento:** até 7 dias antes, sem custo. De 7 a 2 dias, paga 1 diária. Com menos de 2 dias ou se não aparecer
> (*no-show*), paga 50% do total.
>
> **Check-in:** só aí escolho o quarto específico. **Check-out:** até meio-dia; saindo até as 18h paga meia diária,
> depois disso, diária inteira. O quarto fica **aguardando limpeza** e só volta a livre quando a governanta confirma.
>
> **Consumo:** frigobar, restaurante e lavanderia entram na conta da estadia, com o preço da época, e é pago no check-out,
> podendo dividir entre dinheiro, cartão e pix. O sinal é abatido.
>
> **Hóspede:** tem um documento único (CPF ou passaporte). Numa reserva há um responsável e os acompanhantes. Quarto em
> manutenção não pode ser vendido.

### Minhas dificuldades hoje

1. **Overbooking**: vender mais quartos do que tenho.
2. Não sei **quais quartos estão livres** numa data futura.
3. **Reserva sem sinal** ou perto da data: quero avisar o hóspede por e-mail e WhatsApp, com registro do aviso, inclusive
   a confirmação na véspera da chegada.
4. A conta de consumo é feita no papel e some.
5. Quero saber a **taxa de ocupação** e a receita por tipo de quarto.

### O que quero ver quando abrir o sistema

- **Chegadas e saídas** do dia.
- Os quartos **aguardando limpeza**.
- A **disponibilidade** de cada tipo em um período.
- A **conta** de cada estadia em aberto.
- A **taxa de ocupação** do mês.

### O que guardo hoje

| Onde | O que tem |
|---|---|
| Caderno de reservas | hóspede, datas, tipo de quarto, sinal |
| Planilha de quartos | número, andar, tipo, situação |
| Papel por estadia | consumos lançados à mão |
| Planilha de tarifas | tipo de quarto, temporada, valor |

### Perguntas para fazer à Dona Lúcia

- Se o hóspede pede para trocar de quarto durante a estadia, o que muda?
- A tarifa vale pela temporada da noite de chegada ou noite a noite?
- Grupos grandes (uma reserva para vários quartos) entram agora?
- O hóspede pode adiar a saída? Como cobra?

> O envio real de e-mail e WhatsApp é feito por outro sistema. **O banco de dados guarda o que precisa ser avisado e o que
> já foi avisado.**

## Regras de negócio

| Regra | Valor |
|---|---|
| Tipos de quarto | Standard, superior e suíte, cada um com capacidade de hóspedes. O quarto tem número, andar e um tipo |
| Tarifa | Valor da diária por tipo de quarto e **temporada** (baixa, alta e feriado). Os valores **mudam com o tempo** e o histórico deve ser preservado |
| Hóspedes extras | Acima de 2 hóspedes, cobra-se um adicional por pessoa por noite. **Criança até 5 anos não paga** e não conta no adicional |
| Reserva | Por **tipo de quarto**, com datas de entrada e saída e número de hóspedes (até a capacidade). Mínimo de 1 noite; na alta temporada, **2 noites** |
| Disponibilidade | Só há reserva se existir quarto do tipo livre em **todas as noites** do período, descontadas as reservas confirmadas e as manutenções. Venda além disso é *overbooking* e não é permitida. A checagem é **por contagem**: recusa se as reservas e estadias do tipo que se sobrepõem ao período já igualam o número de quartos do tipo (conservadora; sem percorrer noite a noite; D-38) |
| Fora do projeto | Hospedagem de grupo (várias reservas com um único pagamento) não faz parte (D-29) |
| Sinal | 30% do valor das diárias, pago na reserva |
| Cancelamento | Até 7 dias antes da entrada, sem custo. De 7 a 2 dias, paga 1 diária. Com menos de 2 dias ou sem comparecimento (*no-show*), paga **50%** do valor total das diárias |
| Check-in | A partir das 14:00. O **quarto específico** é atribuído no check-in |
| Check-out | Até 12:00. Saída entre 12:00 e 18:00 paga **meia diária**; depois das 18:00, diária inteira |
| Consumo | Lançado na conta da estadia, com o preço da época, e pago no check-out |
| Quarto | Estados: livre, ocupado, aguardando limpeza e em manutenção. Depois do check-out vai para **aguardando limpeza** e só volta a `livre` quando a governança confirma |
| Hóspede | Documento único (CPF ou passaporte). Há um hóspede responsável pela reserva e acompanhantes |
| Pagamento | No check-out, podendo dividir entre formas (dinheiro, cartão, pix). O sinal é abatido |

## Modelo mínimo (a decidir pelo grupo; pelo menos 8 tabelas)

Tipo de quarto, quarto, temporada, tarifa (com vigência), hóspede, reserva, estadia, hóspede da estadia, item de consumo,
consumo da estadia, manutenção do quarto, pagamento. O grupo decide e **justifica** o desenho.

**Pontos que exigem decisão** (a prova cobra a justificativa):

1. Reserva x estadia: uma tabela ou duas? O que acontece com a reserva quando o hóspede faz o check-in?
2. A reserva é do **tipo** e o quarto só aparece no check-in: como contar os quartos livres de um tipo em um período?
3. Tarifa por temporada: como representar as temporadas (datas) e como descobrir a tarifa da temporada em que a estadia começa? (a tarifa da noite de entrada vale para toda a estadia, D-21)
4. O preço do consumo e da diária muda: gravar o valor na conta, consultar o histórico, ou os dois?
5. Hóspede responsável x acompanhantes: tabela N:N com o papel de cada um ou colunas na estadia?
6. Estado do quarto: uma coluna `status` ou derivado das estadias e manutenções? Como saber o que está sujo agora?

## Dados de apoio

- Coluna `preferencias` (`JSONB`) no hóspede: andar, tipo de travesseiro, restrições alimentares, alergias, viagem com pet e
  observações. Cada hóspede tem campos diferentes.
- Número da reserva no formato `HT-2026-000123`, gerado com `LPAD`.

## Entrega 1 — Prova 1 (aula 12): modelo, DDL, carga e transações

Tag: `prova-1`. As transações são dadas na aula 11, um dia antes: a entrega é pequena e guiada pelo exercício do dia.

| # | Item | Arquivo | O que entregar |
|---|---|---|---|
| 1 | Modelo | `diagrama/` | Diagrama no ERD Concepts (conceitual e lógico) com cardinalidades, e a imagem exportada |
| 2 | Estrutura | `sql/01_ddl.sql` | Schema `hotel`, 8 ou mais tabelas, `PK`, `FK`, `UNIQUE`, `CHECK` e `DEFAULT` para as regras que o banco consegue garantir (saída depois da entrada, capacidade positiva, número do quarto único, documento único, status válidos, quantidade de consumo positiva) |
| 3 | Normalização | `README.md` | Justificar até a 3FN e dizer uma desnormalização feita de propósito, se houver |
| 4 | Carga | `sql/02_carga.sql` | 3 tipos de quarto com tarifas em 3 temporadas (alguns valores mudaram), 20 quartos, 40 hóspedes, 60 reservas (confirmadas, canceladas, *no-show*), 50 estadias (em curso e encerradas) com acompanhantes, 12 itens de consumo, 150 consumos e pagamentos. Dados que **exercitam as regras** (estadia que atravessa duas temporadas, check-out às 15:00, quarto aguardando limpeza, tipo de quarto com uma única unidade livre) |
| 5 | Transações | `sql/03_transacoes.sql` | Check-in como transação (atribuir o quarto, criar a estadia, registrar os hóspedes e mudar o quarto para `ocupado`, tudo ou nada), com `ROLLBACK` quando falhar |
| 6 | Concorrência | `sql/03_transacoes.sql` + `evidencias/` | **Duas sessões (balcão e site) reservando o último quarto do tipo para o mesmo período**: mostrar o problema (*overbooking*), a solução (bloqueio de linha ou isolamento) e explicar por quê |
| 7 | Decisões | `README.md` | As respostas dos 6 pontos de decisão acima, por que a transação protege o que protege, divisão do trabalho e uso de IA |

Dado na aula: modelagem (9), análise de bancos (10), transações e ACID (11), DDL e normalização (revisão, aulas 2 e 3).

## Entrega 2 — Prova 2 (aula 16): funções SQL, subconsultas/CTE, `JSONB`, window functions e views

Tag: `prova-2`.

| # | Item | Arquivo | O que entregar |
|---|---|---|---|
| 1 | Funções SQL | `sql/04_consultas.sql` | 10 consultas, entre elas: número da reserva com `LPAD`, nome do hóspede formatado, número de noites (diferença de datas), idade e se paga como criança (`AGE`), reservas por mês (`DATE_TRUNC`), dia da semana com mais check-ins (`TO_CHAR`), valor das diárias com adicional por hóspede (`ROUND`), situação da reserva (`CASE`: a chegar, hospedado, encerrada, cancelada), `COALESCE` para saída ainda não realizada, taxa de saída tardia (`CASE` sobre a hora, `EXTRACT`) |
| 2 | Subconsultas e CTE | `sql/04_consultas.sql` | 3 ou mais: quartos que nunca tiveram estadia no mês, hóspedes com mais estadias que a média, taxa de ocupação por tipo de quarto feita com CTE em etapas (noites ocupadas, noites disponíveis, percentual) |
| 3 | `JSONB` | `sql/04_consultas.sql` | 3 consultas sobre `preferencias` (hóspedes com alergia registrada, hóspedes que viajam com pet, listar as preferências de andar) |
| 4 | Window functions | `sql/05_janelas_views.sql` | 2 consultas: ranking de quartos por receita dentro de cada tipo de quarto (`RANK`) e receita acumulada por mês |
| 5 | Views | `sql/05_janelas_views.sql` | `vw_quartos_hoje` (situação de cada quarto agora e hóspede atual) e uma view materializada com ocupação e receita mensais por tipo de quarto, com atualização |
| 6 | Decisões | `README.md` | Decisões, o que a IA errou, divisão do trabalho |

Dado na aula: funções SQL (13), subconsultas, CTE e `JSONB` (14), window functions e views (15).

## Entrega 3 — Prova 3 (aula 21): índice, funções, procedures e triggers

Tag: `prova-3`. Com o bloco de `PL/pgSQL` em três dias (aulas 18 a 20, com 40 min de projeto por dia), a entrega pede
**mais rotinas e testadas**, e a parte de índice segue enxuta.

| # | Item | Arquivo | O que entregar |
|---|---|---|---|
| 1 | Índice | `sql/06_indices.sql` + `evidencias/` | Carga em volume (100 mil estadias e consumos ou mais, com `generate_series`), **1 consulta lenta** (estadias de um quarto em um período, usada para checar conflito), `EXPLAIN` antes e depois do índice e explicação |
| 2 | Funções | `sql/07_funcoes.sql` | 3 ou mais: `calcular_diarias(tipo, entrada, saida, hospedes)` (tarifa da temporada da noite de entrada para todas as noites e adicional por hóspede), `quarto_disponivel(quarto, entrada, saida)` (sem estadia e fora da manutenção, retornando o motivo) e `valor_cancelamento(reserva, data)` (aplica as faixas de cancelamento). Cada uma com chamada de teste e resultado em `evidencias/` |
| 3 | Procedures | `sql/08_procedures.sql` | 3: `fazer_reserva(hospede, tipo, entrada, saida, hospedes)` (mínimo de noites, capacidade, disponibilidade do tipo, sinal), `fazer_checkin(reserva, quarto)` (quarto do tipo, livre, sem conflito) e `fazer_checkout(estadia)` (diárias, saída tardia, consumo e valor final). Erros com `RAISE EXCEPTION` e mensagens claras, cada uma com um teste que dá certo e um que falha |
| 4 | Triggers | `sql/09_triggers.sql` | 2: **auditoria** das mudanças de status da reserva e da estadia (quem, quando, antes e depois) e **regra de negócio** (ao fazer o check-out, o quarto vai para `aguardando limpeza`), com um teste de cada |
| 5 | Decisões | `README.md` | Onde cada regra ficou (função, procedure, trigger ou `CHECK`) e por quê, divisão do trabalho, uso de IA |

Dado na aula: índices e `generate_series` (17), funções (18), procedures (19), triggers (20).

## Entrega final — Prova 4 (aulas 23 e 24): apresentação

Tag: `final`.

- **Demonstração (6 min):** um cenário de ponta a ponta: o hóspede reserva uma suíte na alta temporada, a pousada recusa a
  reserva de 1 noite, o último quarto do tipo é vendido uma única vez para dois pedidos simultâneos, o check-in atribui o
  quarto, o hóspede consome e sai às 15:00, e o check-out calcula o valor com meia diária e consumo, deixando o quarto
  aguardando limpeza. O relatório mostra a ocupação. Executado ao vivo por uma procedure.
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

- Parece a locadora (período e sobreposição), mas a **reserva é por tipo** e o quarto específico só aparece no check-in:
  disponibilidade vira **contagem** de reservas e estadias do tipo que se sobrepõem ao período, não a checagem de um item.
- A **tarifa por temporada** vale a da **noite de entrada** para a estadia inteira, mesmo quando ela atravessa duas
  temporadas (simplificação decidida em D-21; o cálculo noite a noite com `generate_series` fica fora do projeto).
- A **conta de consumo** acumula itens durante a estadia e fecha no check-out, com regras de horário de saída.
- O `JSONB` guarda as preferências do hóspede, que variam de pessoa para pessoa.
