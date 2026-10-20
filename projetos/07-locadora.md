# Projeto 7 — Locadora de veículos

Estrutura comum das entregas (GitHub, tags, notas): [00-estrutura-das-entregas.md](00-estrutura-das-entregas.md).
Projetos de referência já detalhados: [01-biblioteca.md](01-biblioteca.md) e [02-clinica-medica.md](02-clinica-medica.md).

## Cenário

Uma locadora tem **filiais** e uma frota dividida em **grupos de veículos** (econômico, sedã, SUV, utilitário). O cliente
reserva um grupo, retira um veículo específico na filial, devolve na data combinada e paga pelas **diárias** e pelos
**adicionais** (seguro, cadeirinha, GPS). A locadora quer controlar a disponibilidade da frota por período, o valor de cada
locação, a manutenção e as multas de trânsito. Todos os dados do projeto são **fictícios**.

## Solicitação do usuário

**Solicitante:** Ricardo, gerente de uma locadora de veículos com três filiais. Leia o relato como se ele tivesse chamado
você para fazer o sistema. O que ele não explicou, você pergunta ao professor (ele faz o papel do Ricardo). A modelagem é
sua.

### O relato do Ricardo

> Temos três filiais e cerca de cem carros em quatro grupos: econômico, sedã, SUV e utilitário. Hoje a reserva é por
> telefone e planilha, e já prometi o mesmo carro para dois clientes.
>
> **Meu dia começa** vendo as retiradas e devoluções do dia em cada filial e quais carros estão em manutenção.
>
> **Grupos e diárias:** cada grupo tem uma diária e uma caução. A diária muda com o tempo, e preciso saber o valor da
> época de cada locação. De 7 a 14 diárias, 10% de desconto; 15 ou mais, 15%.
>
> **Cliente:** maior de 21 anos, com CNH (Carteira Nacional de Habilitação) que **não vença durante a locação**. SUV e
> utilitário exigem CNH com 2 anos ou mais.
>
> **Reserva:** é de um **grupo**, não de um carro, com data e hora de retirada e devolução. Cancela de graça até 24 horas
> antes. Depois disso, ou se o cliente não aparecer (*no-show*), paga 1 diária. Seguro a reserva por 2 horas depois do
> horário combinado.
>
> **Retirada:** só na hora eu escolho o carro específico, faço a vistoria (combustível, quilometragem, avarias,
> acessórios) e cobro a caução. **Devolução:** nova vistoria. Se voltar com menos combustível, cobro reabastecimento
> por quarto de tanque. Devolução em outra filial paga R$ 150.
>
> **Atraso:** tolerância de 1 hora; depois, cada hora custa 1/6 da diária, até uma diária inteira.
>
> **Adicionais:** seguro, cadeirinha, GPS, motorista adicional, cada um com valor por diária.
>
> **Manutenção:** a cada 10.000 km ou 6 meses o carro vai para a oficina. **Multa de trânsito:** vai para o cliente que
> estava com o carro na data e hora da infração.

### Minhas dificuldades hoje

1. **Disponibilidade**: não sei quais carros estão livres na semana que vem.
2. **Devoluções atrasadas**: quero ver quem não devolveu e **avisar o cliente por e-mail e WhatsApp**, com registro.
3. **Revisões** esquecidas: carro passa dos 10.000 km sem ir para a oficina.
4. **Multas**: demoro para descobrir quem estava com o carro.
5. Calcular o total da locação (diárias, desconto, adicionais, reabastecimento) me toma tempo.

### O que quero ver quando abrir o sistema

- **Retiradas e devoluções do dia** por filial.
- Carros **disponíveis** de um grupo em um período.
- **Devoluções atrasadas** e se o cliente foi avisado.
- Carros que **precisam de revisão**.
- O **total** de cada locação.

### O que guardo hoje

| Onde | O que tem |
|---|---|
| Planilha da frota | placa, modelo, grupo, filial, km, situação |
| Planilha de clientes | nome, CPF, CNH e validade, telefone, e-mail |
| Planilha de reservas e locações | cliente, grupo, carro, datas |
| Formulário em papel | vistoria de retirada e devolução |

### Perguntas para fazer ao Ricardo

- Dois carros do mesmo grupo podem estar em filiais diferentes? Como sei onde cada um está?
- A manutenção bloqueia o carro por quanto tempo? Pode agendar à frente?
- O adicional novo (um item novo no catálogo) vale para locações antigas?
- Quando o cliente retira, o que acontece com a reserva?

> O envio real de e-mail e WhatsApp é feito por outro sistema. **O banco de dados guarda o que precisa ser avisado e o que
> já foi avisado.**

## Regras de negócio

| Regra | Valor |
|---|---|
| Grupo de veículos | Cada grupo tem uma **diária** e uma caução. A diária **muda com o tempo** e o histórico deve ser preservado |
| Desconto por duração | De 7 a 14 diárias, 10%; 15 diárias ou mais, 15%, sobre o valor das diárias |
| Diária | Conta 24 horas a partir da retirada. Atraso na devolução tem **tolerância de 1 hora**; depois, cada hora extra custa 1/6 da diária, limitada a uma diária inteira |
| Cliente | Maior de 21 anos, com CNH **válida durante toda a locação** (vencimento depois da devolução prevista) |
| Grupos premium | SUV e utilitário exigem CNH com 2 anos ou mais |
| Reserva | Feita para um **grupo** (não para um carro), com data e hora de retirada e de devolução. Cancelamento gratuito até 24 horas antes; depois, ou se o cliente não comparecer (*no-show*), paga 1 diária. A reserva é mantida por **2 horas** depois do horário combinado |
| Veículo | Estados: disponível, alugado, em manutenção, baixado. **Não pode ter duas locações com períodos que se sobrepõem** e o período de manutenção também bloqueia |
| Retirada | O veículo específico é atribuído na retirada. Há uma **vistoria** (combustível, quilometragem, avarias e acessórios) e a caução do grupo |
| Devolução | Nova vistoria. Combustível abaixo do nível da retirada gera **taxa de reabastecimento** (valor fixo por quarto de tanque). Devolução em **outra filial** paga taxa de R$ 150,00 |
| Adicionais | Seguro, cadeirinha, GPS e motorista adicional, cada um com valor por diária. O valor da época fica na locação |
| Manutenção | A cada **10.000 km** ou 6 meses desde a última revisão, o veículo vai para manutenção |
| Multa de trânsito | A infração (data e hora) é atribuída ao **cliente que estava com o veículo** naquele momento |

## Modelo mínimo (a decidir pelo grupo; pelo menos 8 tabelas)

Filial, grupo de veículos, tarifa do grupo (com vigência), modelo, veículo, cliente, reserva, locação, vistoria, adicional,
adicional da locação, manutenção, multa de trânsito. O grupo decide e **justifica** o desenho.

**Pontos que exigem decisão** (a prova cobra a justificativa):

1. Grupo x modelo x veículo: onde fica a diária, onde fica a placa e onde fica o estado do veículo?
2. A diária muda: gravar o valor na locação, consultar a tarifa vigente na data da retirada, ou os dois?
3. Disponibilidade: uma coluna `status` no veículo basta? Como saber se o carro está livre **na semana que vem**?
4. Reserva x locação: uma tabela ou duas? O que acontece com a reserva quando o cliente retira o veículo?
5. Adicionais: tabela N:N com o preço da época ou colunas na locação? O que muda se um adicional novo for criado?
6. Multa de trânsito: como descobrir o cliente a partir da placa, da data e da hora, sem guardar o cliente na multa?

## Dados de apoio

- Coluna `dados_vistoria` (`JSONB`) na vistoria: nível de combustível, quilometragem, lista de avarias (local e descrição),
  acessórios presentes e observações. Cada vistoria tem campos e quantidades diferentes.
- Número do contrato no formato `LC-2026-000123`, gerado com `LPAD`.

## Entrega 1 — Prova 1 (aula 12): modelo, DDL, carga e transações

Tag: `prova-1`. As transações são dadas na aula 11, um dia antes: a entrega é pequena e guiada pelo exercício do dia.

| # | Item | Arquivo | O que entregar |
|---|---|---|---|
| 1 | Modelo | `diagrama/` | Diagrama no ERD Concepts (conceitual e lógico) com cardinalidades, e a imagem exportada |
| 2 | Estrutura | `sql/01_ddl.sql` | Schema `locadora`, 8 ou mais tabelas, `PK`, `FK`, `UNIQUE`, `CHECK` e `DEFAULT` para as regras que o banco consegue garantir (devolução depois da retirada, diária positiva, placa única, status válidos, quilometragem não decrescente na vistoria) |
| 3 | Normalização | `README.md` | Justificar até a 3FN e dizer uma desnormalização feita de propósito, se houver |
| 4 | Carga | `sql/02_carga.sql` | 2 filiais, 4 grupos com mais de uma diária ao longo do tempo, 25 veículos, 40 clientes, 20 reservas, 120 locações (em andamento, devolvidas no prazo, atrasadas, com adicionais), vistorias de retirada e devolução, 6 manutenções, 10 multas de trânsito. Dados que **exercitam as regras** (cliente com CNH vencendo em 10 dias, veículo com 9.900 km desde a revisão, locação atrasada, reserva em *no-show*) |
| 5 | Transações | `sql/03_transacoes.sql` | Retirada como transação (criar a locação a partir da reserva, registrar a vistoria, mudar o veículo para `alugado` e registrar a caução, tudo ou nada), com `ROLLBACK` quando falhar |
| 6 | Concorrência | `sql/03_transacoes.sql` + `evidencias/` | **Duas sessões (dois atendentes) alugando o mesmo veículo para períodos que se sobrepõem**: mostrar o problema (dupla locação), a solução (bloqueio de linha ou isolamento) e explicar por quê |
| 7 | Decisões | `README.md` | As respostas dos 6 pontos de decisão acima, por que a transação protege o que protege, divisão do trabalho e uso de IA |

Dado na aula: modelagem (9), análise de bancos (10), transações e ACID (11), DDL e normalização (revisão, aulas 2 e 3).

## Entrega 2 — Prova 2 (aula 16): funções SQL, subconsultas/CTE, `JSONB`, window functions e views

Tag: `prova-2`.

| # | Item | Arquivo | O que entregar |
|---|---|---|---|
| 1 | Funções SQL | `sql/04_consultas.sql` | 10 consultas, entre elas: número do contrato com `LPAD`, nome do cliente formatado, duração da locação (`AGE` ou diferença de datas), dias para o vencimento da CNH, locações por mês (`DATE_TRUNC`), dia da semana com mais retiradas (`TO_CHAR`), quilômetros rodados, valor das diárias com desconto (`ROUND`), situação (`CASE`: em andamento, devolvida no prazo, atrasada), `COALESCE` para devolução ainda não realizada |
| 2 | Subconsultas e CTE | `sql/04_consultas.sql` | 3 ou mais: veículos nunca alugados no trimestre, clientes com mais locações que a média, taxa de ocupação da frota por filial feita com CTE em etapas (dias alugados, dias do período, percentual) |
| 3 | `JSONB` | `sql/04_consultas.sql` | 3 consultas sobre `dados_vistoria` (devoluções com avaria registrada, retiradas com combustível abaixo de meio tanque, listar os acessórios de uma vistoria) |
| 4 | Window functions | `sql/05_janelas_views.sql` | 2 consultas: ranking de veículos por faturamento dentro do grupo (`RANK`) e faturamento acumulado por mês |
| 5 | Views | `sql/05_janelas_views.sql` | `vw_frota_disponivel` (veículos livres agora, por filial) e uma view materializada com ocupação e faturamento mensais por filial, com atualização |
| 6 | Decisões | `README.md` | Decisões, o que a IA errou, divisão do trabalho |

Dado na aula: funções SQL (13), subconsultas, CTE e `JSONB` (14), window functions e views (15).

## Entrega 3 — Prova 3 (aula 21): índice, funções, procedures e triggers

Tag: `prova-3`. Com o bloco de `PL/pgSQL` em três dias (aulas 18 a 20, com 40 min de projeto por dia), a entrega pede
**mais rotinas e testadas**, e a parte de índice segue enxuta.

| # | Item | Arquivo | O que entregar |
|---|---|---|---|
| 1 | Índice | `sql/06_indices.sql` + `evidencias/` | Carga em volume (100 mil locações ou mais, com `generate_series`), **1 consulta lenta** (locações de um veículo em um período, usada para checar conflito), `EXPLAIN` antes e depois do índice e explicação |
| 2 | Funções | `sql/07_funcoes.sql` | 3 ou mais: `calcular_valor_locacao(grupo, retirada, devolucao)` (diárias, desconto e horas extras), `veiculo_disponivel(veiculo, inicio, fim)` (sem sobreposição e fora da manutenção, retornando o motivo) e `cliente_pode_alugar(cliente, grupo)` (idade, validade da CNH e tempo de habilitação, retornando o motivo). Cada uma com chamada de teste e resultado em `evidencias/` |
| 3 | Procedures | `sql/08_procedures.sql` | 3: `fazer_reserva(cliente, grupo, retirada, devolucao)` (cliente apto e grupo com veículo livre no período), `retirar_veiculo(reserva, veiculo)` (confere disponibilidade, cria a locação e a vistoria) e `devolver_veiculo(locacao, km, combustivel)` (atraso, taxas e valor final). Erros com `RAISE EXCEPTION` e mensagens claras, cada uma com um teste que dá certo e um que falha |
| 4 | Triggers | `sql/09_triggers.sql` | 2: **auditoria** das mudanças de status do veículo (quem, quando, antes e depois) e **regra de negócio** (ao devolver, o veículo volta a `disponivel` ou vai para `manutencao` se passou de 10.000 km desde a revisão), com um teste de cada |
| 5 | Decisões | `README.md` | Onde cada regra ficou (função, procedure, trigger ou `CHECK`) e por quê, divisão do trabalho, uso de IA |

Dado na aula: índices e `generate_series` (17), funções (18), procedures (19), triggers (20).

## Entrega final — Prova 4 (aulas 23 e 24): apresentação

Tag: `final`.

- **Demonstração (6 min):** um cenário de ponta a ponta: o cliente reserva um SUV, a locadora recusa o cliente com CNH
  vencendo antes da devolução, outro cliente retira o veículo, uma segunda tentativa de alugar o mesmo carro no mesmo período
  é bloqueada, a devolução com atraso e combustível baixo calcula o valor final, o veículo vai para manutenção ao passar do
  limite e o relatório mostra a ocupação da frota. Executado ao vivo por uma procedure.
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

- O ponto forte é a **disponibilidade por período**: um veículo está livre ou não **em um intervalo**, não só "agora". A
  consulta de sobreposição (`inicio < fim_outro AND fim > inicio`) aparece na função da prova 3 e na concorrência da prova 1.
- O **cálculo do valor** combina tarifa vigente, desconto por duração, horas extras e taxas, ótimo para uma função com teste.
- A **multa de trânsito** exige descobrir o cliente por data e hora, que é um `JOIN` por intervalo.
- O `JSONB` guarda a vistoria (avarias, acessórios, combustível), que varia de uma locação para outra.
