# Guia de correção dos modelos — aula 5

Para o professor. Para cada um dos 10 projetos: o que esperar no modelo do aluno e as armadilhas que mais aparecem.
A régua completa é o `dicionario-de-dados.md` de cada pasta em `projetos-referencia/` (**não mostrar ao aluno antes da entrega**).
Os 6 «pontos que exigem decisão» de cada projeto estão em `projetos-referencia/NN-tema/NN-tema.md`.

## Erros que se repetem em qualquer projeto

| Erro | Pergunta para a turma |
|---|---|
| Dois conceitos numa tabela só (o título e a cópia física; o quarto e a reserva) | «Quantas vezes esse dado se repete se houver 3 cópias?» |
| N:N sem tabela de ligação (ou com os ids em uma lista dentro do campo) | «Como você liga um livro a dois autores?» |
| Preço, tarifa ou prazo só na tabela principal | «Se o valor mudar amanhã, o que acontece com o que já foi vendido?» |
| Endereço ou contato só no cadastro | «Se o cliente mudar de endereço, o pedido antigo muda?» |
| Status como texto livre, sem valores combinados | «Quais são os status possíveis? Quem muda cada um?» |
| Dado calculado gravado sem pensar (total, saldo, atraso) | «Se um item mudar, esse total fica certo?» |
| Falta uma tabela que o relato pede (aviso de cobrança, histórico) | «Onde você vê o que a cliente pediu no item 2 das dificuldades?» |
| Tabela sem PK, ou FK apontando para algo que não está no desenho | «Qual é a PK? Para onde essa seta vai?» |

---

## 01 · Biblioteca

**Núcleo esperado:** `livro`, `autor` (+ ligação com ordem), `editora`, `categoria`, `exemplar`, `tipo_leitor`, `leitor`,
`emprestimo`, `reserva`, `multa`, histórico da tarifa de multa, aviso de cobrança.
**Armadilhas:**
- Livro e exemplar na mesma tabela (a Marta fala em «tombo» e em «vários exemplares do mesmo título»).
- Multa como campo no empréstimo, sem histórico da tarifa (ela diz que o valor «já mudou duas vezes»).
- Reserva sem ordem da fila.
- Aviso de cobrança por e-mail e WhatsApp esquecido; ou sem registrar **quem já foi avisado**.

## 02 · Clínica médica

**Núcleo esperado:** `medico`, `especialidade` (+ ligação), `paciente`, `convenio`, `tipo_consulta`, horário de atendimento
semanal, bloqueio de agenda, `consulta`, `pagamento`, e o prontuário (atendimento, prescrição, exame) à parte.
**Armadilhas:**
- Consulta e atendimento (o que aconteceu) na mesma tabela, misturando agenda com dado sensível.
- Médico com uma especialidade só (o relato diz que pode ter mais de uma).
- Horário livre gravado em vez de calculado.
- Convênio só no paciente: a consulta antiga muda se ele trocar de convênio.
- Valor da consulta sem a data (a tabela de valores muda).

## 03 · Loja virtual

**Núcleo esperado:** `produto`, `categoria`, histórico de preço, movimento de estoque, `cliente`, `endereco`, `cupom`, `pedido`,
`item_pedido`, `pagamento`, `frete` por estado, `avaliacao`.
**Armadilhas:**
- Preço só em `produto` (o Rafael pede que o pedido antigo mantenha o valor da época).
- Endereço do pedido apontando para o cadastro, sem cópia.
- Contador de usos do cupom gravado em vez de contar os pedidos.
- Carrinho em tabela separada sem necessidade (pode ser um pedido com status `carrinho`).
- Estoque como único campo, sem saber de onde vem o número.

## 04 · Academia

**Núcleo esperado:** `aluno`, `matricula`, `plano`, histórico do preço do plano, `modalidade`, `mensalidade`, `pagamento`,
`instrutor`, `turma`, `reserva` de aula, `acesso` (catraca), `avaliacao_fisica`.
**Armadilhas:**
- Aluno e matrícula juntos (o aluno volta com nova matrícula).
- Status de inadimplência gravado no aluno em vez de ser derivado das mensalidades.
- Vagas da turma como campo (conta-se as reservas); lista de espera sem ordem.
- Acesso com uma linha para entrada e outra para saída, sem saber quem está dentro agora.

## 05 · Delivery de comida

**Núcleo esperado:** `restaurante`, `categoria`, horário de funcionamento por dia, `item_cardapio`, histórico de preço, `cliente`,
`endereco` (com a distância), faixa de taxa, `pedido`, `item_pedido`, `entregador`, `entrega`, `pagamento`, `avaliacao`,
histórico de status.
**Armadilhas:**
- Pedido e entrega juntos (se o entregador desiste e outro assume?).
- Horário do restaurante sem tratar quem fecha depois da meia-noite.
- Status só como campo, sem histórico para calcular o tempo de cada etapa (a Camila quer o tempo médio).
- Comissão só no restaurante: mudar a comissão muda os pedidos antigos.
- Observações do item («sem cebola») sem lugar.

## 06 · Escola (notas e frequência)

**Núcleo esperado:** `aluno`, `matricula`, `turma` e a ligação do aluno com a turma por período, `disciplina`, `professor`,
oferta (disciplina na turma) e o professor da oferta por período, `bimestre`, `avaliacao` (com peso), `nota`, histórico de nota,
`aula`, `frequencia`, resultado do bimestre.
**Armadilhas:** é o projeto mais pesado; aceite um núcleo menor na aula 5 (aluno, turma, disciplina, avaliação, nota, aula,
frequência).
- Turma gravada direto na matrícula, sem como representar a **transferência**.
- Professor fixo na disciplina, sem como representar a **troca no meio do ano**.
- Nota sobrescrita sem histórico de correção.
- Falta justificada tratada como falta comum.

## 07 · Locadora de veículos

**Núcleo esperado:** `filial`, `grupo` (com diária e caução), histórico da diária, `modelo`, `veiculo`, `cliente`, `reserva`,
`locacao`, `vistoria`, `adicional` (+ ligação com o valor da época), `manutencao`, `multa_transito`.
**Armadilhas:**
- Reserva de um carro específico (o relato diz que é de um **grupo**; o carro só aparece na retirada).
- Diária no veículo ou no modelo em vez de no grupo; sem histórico.
- Adicionais como colunas fixas na locação.
- Multa de trânsito guardando o cliente (a multa tem o carro e o momento; o cliente se descobre pela locação).

## 08 · Sistema de chamados (helpdesk)

**Núcleo esperado:** `solicitante`, `setor`, `categoria`, `fila` (por nível), `atendente` (+ ligação com as filas), histórico do SLA,
`chamado`, `comentario` (público e interno), histórico de status, `ativo`, `pesquisa_satisfacao`.
**Armadilhas:**
- SLA só como regra consultada na hora: os prazos precisam ficar **gravados no chamado** na abertura.
- Pausa do SLA sem campo ou registro para o tempo aguardando o solicitante.
- Comentário público e interno sem distinção.
- Reabertura sem ligação ao chamado anterior.
- Campos que variam por categoria forçados em colunas.

## 09 · Hotel ou pousada

**Núcleo esperado:** `tipo_quarto`, `quarto`, `temporada`, `tarifa` (com vigência), `hospede`, `reserva`, `estadia`,
`estadia_hospede` (responsável e acompanhantes), `item_consumo`, `consumo`, `manutencao_quarto`, `pagamento`.
**Armadilhas:**
- Reserva do quarto específico (a Dona Lúcia só escolhe o quarto no check-in).
- Reserva e estadia na mesma tabela.
- Responsável e acompanhantes sem tabela de ligação.
- Consumo com o preço do item em vez do preço do dia.
- Estado do quarto (livre, ocupado, aguardando limpeza) ignorado.

## 10 · Cinema

**Núcleo esperado:** `filme`, `genero`, `sala`, `assento` (da sala), `sessao`, histórico de preço, `tipo_ingresso`, `cliente`,
`compra`, `ingresso`, reserva temporária de assento, `pagamento`.
**Armadilhas:**
- Assento ligado à sessão em vez de à sala: o assento é da sala e o **ingresso** liga assento e sessão.
- Sem como impedir o mesmo assento vendido duas vezes (discuta, ainda sem implementar).
- Preço só no ingresso ou só na tabela de preços, sem a regra de meia e de quarta-feira.
- Fim da sessão não considerado (duração do filme + limpeza).
- Compra e ingresso numa tabela só.

---

## Fechamento da aula

Ao fim das apresentações, leia em voz alta o que ficou no quadro: os 5 erros que mais apareceram e as 3 melhores decisões.
Diga que, na próxima aula, cada tabela do dicionário de dados simples vira um `CREATE TABLE` no PostgreSQL.
