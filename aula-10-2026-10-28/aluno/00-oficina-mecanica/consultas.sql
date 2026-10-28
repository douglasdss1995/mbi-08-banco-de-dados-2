-- Oficina Mecânica · consultas.sql
-- As 16 consultas de validação (C1 a C16), depois das 5 entradas (entradas.sql). Só leem: não alteram o banco.
--
-- Cada consulta vem com quatro blocos de comentário:
--   Texto do pedido  : a pergunta, como está no pedido de validação da Oficina (aula 6).
--   O que sai        : o resultado esperado com os dados do pedido.
--   Como funciona    : o raciocínio da consulta, passo a passo.
--   Funções          : as funções e os operadores que ela usa, um por linha.
SET search_path TO oficina;

select * from cliente c;
select * from item_servico c;
select * from mecanico c;
select * from modelo c;
select * from ordem_servico c;
select * from servico c;
select * from veiculo c;

-- C1 · Quantas OS e quantos serviços lançados no total
--
-- Texto do pedido:
--   «Quantas ordens de serviço existem e quantos serviços foram lançados nelas, no total?»
-- O que sai:
--   9 ordens de serviço e 13 serviços lançados.
-- Como funciona:
--   1. Não há ligação entre tabelas: são duas contagens independentes, uma em ordem_servico e outra em item_servico.
--   2. Cada contagem é uma subconsulta entre parênteses, usada como se fosse uma coluna do SELECT (subconsulta escalar: devolve um único valor).
--   3. O resultado é uma única linha com duas colunas, os apelidos «os» e «itens».
-- Funções:
--   count(*): conta as linhas da tabela, sem olhar o conteúdo de nenhuma coluna.
--   AS: dá um nome (apelido) à coluna do resultado.
SELECT (SELECT count(*) FROM ordem_servico) AS os, (SELECT count(*) FROM item_servico) AS itens;

-- C2 · Clientes com seus veículos (placa, modelo, marca); todo cliente aparece
--
-- Texto do pedido:
--   «Liste todos os clientes com os seus veículos (placa, modelo e marca). Todo cliente aparece, mesmo sem veículo.»
-- O que sai:
--   7 linhas: Ana (ABC1D23 Gol Volkswagen), Ana (DEF4G56 Uno Fiat), Bruno (XYZ9K88 Onix Chevrolet), Carla (QWE4R56 Onix Chevrolet),
--   Davi (HND2E45 Civic Honda), Eva (TYT7F90 Corolla Toyota), Fábio (sem veículo).
-- Como funciona:
--   1. Parte-se de cliente, porque todo cliente precisa aparecer.
--   2. LEFT JOIN veiculo: traz os veículos de cada cliente. Cliente sem veículo continua na lista, com placa vazia (NULL). Um INNER JOIN tiraria o Fábio.
--   3. LEFT JOIN modelo: traz o modelo e a marca do veículo. Precisa ser LEFT também, senão a linha do Fábio (sem modelo) sumiria aqui.
--   4. ORDER BY ordena pelo nome do cliente e, dentro dele, pela placa.
-- Funções:
--   Sem funções: a consulta usa só junções (LEFT JOIN) e ordenação (ORDER BY).
SELECT c.nome, v.placa, m.nome AS modelo, m.marca
FROM cliente c
LEFT JOIN veiculo v ON v.cliente_id = c.id
LEFT JOIN modelo m  ON m.id = v.modelo_id
ORDER BY c.nome, v.placa;

-- C3 · Total de cada OS com o nome do cliente (OS sem serviço = 0)
--
-- Texto do pedido:
--   «Qual o total de cada OS, com o nome do cliente? Uma OS sem serviço tem total 0.»
-- O que sai:
--   1001 Ana 210 · 1002 Bruno 90 · 1003 Ana 180 · 1004 Carla 180 · 1005 Bruno 120 · 1006 Davi 150 · 1007 Ana 195 · 1009 Bruno 140 · 1010 Ana 0.
-- Como funciona:
--   1. Parte-se de ordem_servico. O nome do cliente está duas tabelas adiante: OS → veículo → cliente. Os dois JOIN normais bastam, porque toda OS tem veículo e todo veículo tem cliente.
--   2. LEFT JOIN item_servico: traz os itens de cada OS. A OS sem item continua na lista, com valor vazio (NULL).
--   3. GROUP BY junta as linhas de cada OS em uma só. Toda coluna do SELECT que não está dentro de uma função de agregação precisa estar no GROUP BY (por isso o número e o nome).
--   4. SUM soma os valores cobrados de cada grupo. Na OS sem item o SUM devolve NULL, e o COALESCE troca esse NULL por 0.
-- Funções:
--   SUM(coluna): soma os valores não nulos do grupo; se todos forem nulos (ou não houver linhas), devolve NULL.
--   COALESCE(a, b): devolve o primeiro argumento que não é NULL. Aqui, o total ou 0.
SELECT o.numero, c.nome, COALESCE(SUM(i.valor_cobrado), 0) AS total
FROM ordem_servico o
JOIN veiculo v ON v.id = o.veiculo_id
JOIN cliente c ON c.id = v.cliente_id
LEFT JOIN item_servico i ON i.ordem_servico_id = o.id
GROUP BY o.numero, c.nome
ORDER BY o.numero;

-- C4 · Faturamento das OS do dia 2 ao dia 7 do mês (inclusive)
--
-- Texto do pedido:
--   «Quanto a oficina faturou nas OS do dia 02 ao dia 07 (inclusive)?»
-- O que sai:
--   780.
-- Como funciona:
--   1. O faturamento é a soma dos valores cobrados nos itens; a data está na OS. Por isso item_servico se liga a ordem_servico.
--   2. O pedido dá só o dia e o mês é livre: a consulta usa o mês atual. date_trunc('month', current_date) devolve o dia 1 do mês; somar 1 dá o dia 2, e somar 6 dá o dia 7.
--   3. BETWEEN inclui as duas pontas, que é o «inclusive» do pedido.
--   4. Como a consulta só faz uma soma geral, não precisa de GROUP BY.
-- Funções:
--   SUM(coluna): soma os valores cobrados.
--   current_date: a data de hoje, sem hora.
--   date_trunc('month', data): corta a data no começo do mês (dia 1, hora zero). Outras unidades: 'day', 'year', 'week'.
--   ::date: conversão de tipo. date_trunc devolve data com hora; ::date deixa só a data, para poder somar dias (data + 1 = o dia seguinte).
--   BETWEEN a AND b: verdadeiro quando o valor está entre a e b, incluindo as duas pontas.
SELECT SUM(i.valor_cobrado) AS faturamento
FROM item_servico i
JOIN ordem_servico o ON o.id = i.ordem_servico_id
WHERE o.data_abertura BETWEEN date_trunc('month', current_date)::date + 1
                          AND date_trunc('month', current_date)::date + 6;

-- C5 · Troca de óleo: valor cobrado em cada OS e o preço de tabela de hoje
--
-- Texto do pedido:
--   «Em cada OS que teve troca de óleo, qual valor foi cobrado? E qual é hoje o preço de tabela?»
-- O que sai:
--   1001 cobrou 120 · 1004 cobrou 120 · 1005 cobrou 120 · 1007 cobrou 135 · preço de tabela hoje: 135.
-- Como funciona:
--   1. O valor cobrado está em item_servico; o preço de tabela está em servico; o número da OS, em ordem_servico. As três se ligam.
--   2. O WHERE filtra só o serviço «Troca de óleo». Texto vai entre aspas simples.
--   3. O valor cobrado (do item, gravado na hora) e o valor de tabela (do serviço, o preço de hoje) vêm de colunas diferentes: é por isso que o reajuste da Entrada 3 não muda as OS antigas.
-- Funções:
--   Sem funções: a consulta usa só junções, filtro (WHERE) e ordenação (ORDER BY).
SELECT o.numero, i.valor_cobrado, s.valor AS preco_tabela_hoje
FROM item_servico i
JOIN servico s ON s.id = i.servico_id
JOIN ordem_servico o ON o.id = i.ordem_servico_id
WHERE s.descricao = 'Troca de óleo'
ORDER BY o.numero;

-- C6 · OS em que o Alinhamento foi cobrado diferente da tabela
--
-- Texto do pedido:
--   «Em quais OS o Alinhamento foi cobrado por um valor diferente do preço de tabela?»
-- O que sai:
--   OS 1006, cobrado 70 (tabela 90). Só essa.
-- Como funciona:
--   1. Mesmas três tabelas da C5.
--   2. O WHERE tem duas condições ligadas por AND: o serviço é «Alinhamento» e o valor cobrado é diferente do valor de tabela.
--   3. Comparar duas colunas na mesma linha é o jeito de achar o desconto ou o acréscimo.
-- Funções:
--   <>: operador «diferente de». Também se escreve !=.
--   AND: as duas condições precisam ser verdadeiras ao mesmo tempo.
SELECT o.numero, i.valor_cobrado, s.valor AS tabela
FROM item_servico i
JOIN servico s ON s.id = i.servico_id
JOIN ordem_servico o ON o.id = i.ordem_servico_id
WHERE s.descricao = 'Alinhamento' AND i.valor_cobrado <> s.valor;

-- C7 · Quantas vezes cada serviço foi prestado (todo serviço aparece)
--
-- Texto do pedido:
--   «Quantas vezes cada serviço foi prestado? Todo serviço aparece, mesmo o nunca prestado.»
-- O que sai:
--   Troca de óleo 4 · Alinhamento 3 · Troca de filtro 3 · Balanceamento 2 · Troca de pastilhas 1 · Revisão completa 0.
-- Como funciona:
--   1. Parte-se de servico, porque todo serviço precisa aparecer. O LEFT JOIN traz os itens; o serviço nunca prestado fica com a coluna do item vazia (NULL).
--   2. O GROUP BY agrupa por descrição do serviço, e o count conta as linhas de cada grupo.
--   3. O detalhe é contar uma coluna do item (i.servico_id), e não usar count(*). count(*) contaria 1 para a «Revisão completa» (a linha do LEFT JOIN existe); count(coluna) ignora o NULL e dá 0.
--   4. ORDER BY vezes DESC ordena do mais prestado para o menos; o empate é desfeito pela descrição.
-- Funções:
--   count(coluna): conta as linhas em que a coluna não é NULL. (count(*) conta todas as linhas.)
--   DESC: ordem decrescente (o padrão é ASC, crescente).
SELECT s.descricao, count(i.servico_id) AS vezes
FROM servico s LEFT JOIN item_servico i ON i.servico_id = s.id
GROUP BY s.descricao
ORDER BY vezes DESC, s.descricao;

-- C8 · Quanto cada serviço rendeu (todo serviço aparece)
--
-- Texto do pedido:
--   «Quanto cada serviço rendeu (soma do valor cobrado)? Todo serviço aparece.»
-- O que sai:
--   Troca de óleo 495 · Alinhamento 250 · Troca de filtro 180 · Troca de pastilhas 180 · Balanceamento 160 · Revisão completa 0.
-- Como funciona:
--   1. Mesma estrutura da C7: parte-se de servico e usa-se LEFT JOIN para o serviço nunca prestado continuar na lista.
--   2. Em vez de contar, soma-se o valor cobrado de cada grupo.
--   3. O serviço sem nenhum item tem SUM igual a NULL; o COALESCE troca por 0.
--   4. A ordenação é do que mais rendeu para o que menos rendeu.
-- Funções:
--   SUM(coluna): soma os valores não nulos do grupo.
--   COALESCE(a, b): devolve o primeiro argumento que não é NULL. Aqui, a receita ou 0.
SELECT s.descricao, COALESCE(SUM(i.valor_cobrado), 0) AS receita
FROM servico s LEFT JOIN item_servico i ON i.servico_id = s.id
GROUP BY s.descricao
ORDER BY receita DESC, s.descricao;

-- C9 · Por mecânico: OS atendidas e total em serviços (todo mecânico aparece)
--
-- Texto do pedido:
--   «Para cada mecânico: quantas OS atendeu e quanto somou em serviços? Todo mecânico aparece.»
-- O que sai:
--   Carlos 5 OS e 705 · Marta 3 OS e 420 · Paulo 1 OS e 140 · Rita 0 OS e 0.
-- Como funciona:
--   1. Parte-se de mecanico, com LEFT JOIN em ordem_servico e depois em item_servico. Assim a Rita, que não atendeu nenhuma OS, continua na lista.
--   2. Ao ligar a OS aos itens, cada OS se repete uma vez por item. Se contássemos as linhas, uma OS com 2 serviços seria contada 2 vezes.
--      O count(DISTINCT o.id) conta cada OS uma vez só.
--   3. Já o SUM não tem esse problema: cada item aparece uma vez, e a soma de todos os itens do mecânico é a certa.
--   4. Para a Rita, o.id é NULL: count(DISTINCT) dá 0 e o SUM é NULL, trocado por 0 pelo COALESCE.
-- Funções:
--   count(DISTINCT coluna): conta quantos valores diferentes (e não nulos) a coluna tem no grupo.
--   SUM(coluna): soma os valores cobrados.
--   COALESCE(a, b): troca o NULL por 0.
SELECT m.nome, count(DISTINCT o.id) AS os, COALESCE(SUM(i.valor_cobrado), 0) AS total
FROM mecanico m
LEFT JOIN ordem_servico o ON o.mecanico_id = m.id
LEFT JOIN item_servico i  ON i.ordem_servico_id = o.id
GROUP BY m.nome
ORDER BY total DESC;

-- C10 · Veículos que nunca passaram pela oficina
--
-- Texto do pedido:
--   «Quais veículos nunca passaram pela oficina?»
-- O que sai:
--   TYT7F90 (só ele).
-- Como funciona:
--   1. É o padrão «quem nunca...»: parte-se de veiculo e faz-se LEFT JOIN com ordem_servico.
--   2. O veículo que nunca teve OS fica com todas as colunas da OS vazias (NULL).
--   3. O WHERE o.id IS NULL deixa só essas linhas. O id da OS nunca é NULL numa OS de verdade, então NULL significa «não achou».
-- Funções:
--   IS NULL: verdadeiro quando o valor é NULL. Não se usa = NULL, porque NULL não é igual a nada, nem a ele mesmo.
SELECT v.placa
FROM veiculo v LEFT JOIN ordem_servico o ON o.veiculo_id = v.id
WHERE o.id IS NULL;

-- C11 · Clientes que nunca tiveram uma OS
--
-- Texto do pedido:
--   «Quais clientes nunca tiveram uma OS?»
-- O que sai:
--   Eva Costa e Fábio Mendes.
-- Como funciona:
--   1. Mesmo tipo de pergunta da C10 («quem nunca...»), agora com outro jeito: NOT EXISTS.
--   2. A subconsulta procura, para o cliente da linha atual, alguma OS dos veículos dele. Ela referencia c.id de fora: é uma subconsulta correlacionada.
--   3. NOT EXISTS é verdadeiro quando a subconsulta não devolve nenhuma linha. O cliente passa no filtro se não tem nenhuma OS.
--   4. O ponto de ligação é veículo, porque a OS pertence ao veículo e o veículo ao cliente. Por isso a subconsulta tem o JOIN.
--   5. O SELECT 1 dentro da subconsulta é só convenção: o que importa é se existe linha, não o valor dela.
-- Funções:
--   EXISTS (subconsulta): verdadeiro quando a subconsulta devolve pelo menos uma linha.
--   NOT EXISTS (subconsulta): o contrário; verdadeiro quando ela não devolve nenhuma.
SELECT c.nome
FROM cliente c
WHERE NOT EXISTS (SELECT 1 FROM veiculo v JOIN ordem_servico o ON o.veiculo_id = v.id WHERE v.cliente_id = c.id)
ORDER BY c.nome;

-- C12 · Quanto cada cliente já gastou, somando todos os veículos (todo cliente aparece)
--
-- Texto do pedido:
--   «Quanto cada cliente já gastou na oficina, somando todos os seus veículos? Todo cliente aparece.»
-- O que sai:
--   Ana 585 · Bruno 350 · Carla 180 · Davi 150 · Eva 0 · Fábio 0.
-- Como funciona:
--   1. Parte-se de cliente e desce-se pela cadeia cliente → veículo → OS → item, sempre com LEFT JOIN. Assim o cliente sem veículo (Fábio) e o sem OS (Eva) continuam na lista.
--   2. O GROUP BY por nome junta todos os veículos do cliente numa linha só, e o SUM soma todos os itens de todas as OS.
--   3. Quem não tem nenhum item tem SUM igual a NULL; o COALESCE troca por 0.
--   4. Observação: dois clientes com o mesmo nome seriam somados juntos. Em um banco real o GROUP BY seria por c.id.
-- Funções:
--   SUM(coluna): soma os valores cobrados.
--   COALESCE(a, b): troca o NULL por 0.
SELECT c.nome, COALESCE(SUM(i.valor_cobrado), 0) AS gasto
FROM cliente c
LEFT JOIN veiculo v ON v.cliente_id = c.id
LEFT JOIN ordem_servico o ON o.veiculo_id = v.id
LEFT JOIN item_servico i ON i.ordem_servico_id = o.id
GROUP BY c.nome
ORDER BY gasto DESC, c.nome;

-- C13 · OS sem nenhum serviço lançado (número, data, veículo, mecânico)
--
-- Texto do pedido:
--   «Quais OS estão sem nenhum serviço lançado? Mostre número, dia, veículo e mecânico.»
-- O que sai:
--   OS 1010, dia 20, ABC1D23, Carlos Lima (só ela).
-- Como funciona:
--   1. Parte-se de ordem_servico e liga-se ao veículo (para a placa) e ao mecânico (para o nome). Os dois JOIN normais bastam: toda OS tem os dois.
--   2. O filtro «sem nenhum serviço» usa NOT EXISTS: a OS passa quando a subconsulta não acha nenhum item dela.
--   3. A subconsulta é correlacionada: ela usa o.id, da consulta de fora, para olhar só os itens da OS da linha atual.
-- Funções:
--   NOT EXISTS (subconsulta): verdadeiro quando a subconsulta não devolve nenhuma linha.
SELECT o.numero, o.data_abertura, v.placa, m.nome AS mecanico
FROM ordem_servico o
JOIN veiculo v ON v.id = o.veiculo_id
JOIN mecanico m ON m.id = o.mecanico_id
WHERE NOT EXISTS (SELECT 1 FROM item_servico i WHERE i.ordem_servico_id = o.id);

-- C14 · Quantas OS cada marca teve (toda marca aparece)
--
-- Texto do pedido:
--   «Quantas OS cada marca de veículo teve? Toda marca cadastrada aparece.»
-- O que sai:
--   Chevrolet 4 · Volkswagen 3 · Fiat 1 · Honda 1 · Toyota 0.
-- Como funciona:
--   1. A marca está em modelo; por isso parte-se de modelo, com LEFT JOIN em veículo e depois em OS. A marca sem veículo, ou sem OS, continua na lista.
--   2. Vários modelos podem ter a mesma marca, então o GROUP BY é por marca.
--   3. Cada OS aparece uma vez por linha (não há item aqui), mas o count(DISTINCT o.id) deixa a contagem segura mesmo que a consulta ganhe mais uma junção.
--   4. Para a Toyota, a OS vem NULL e o count dá 0.
-- Funções:
--   count(DISTINCT coluna): conta quantos valores diferentes (e não nulos) a coluna tem no grupo.
SELECT m.marca, count(DISTINCT o.id) AS os
FROM modelo m
LEFT JOIN veiculo v ON v.modelo_id = m.id
LEFT JOIN ordem_servico o ON o.veiculo_id = v.id
GROUP BY m.marca
ORDER BY os DESC, m.marca;

-- C15 · Mecânicos sem especialidade informada
--
-- Texto do pedido:
--   «Quais mecânicos estão sem especialidade informada?»
-- O que sai:
--   Paulo Neri (só ele).
-- Como funciona:
--   1. É uma consulta de uma tabela só, sem junção.
--   2. «Sem especialidade informada» significa que a coluna especialidade ficou vazia (NULL). O filtro é WHERE ... IS NULL.
-- Funções:
--   IS NULL: verdadeiro quando o valor é NULL. Não se usa = NULL, porque NULL não é igual a nada.
SELECT nome FROM mecanico WHERE especialidade IS NULL;

-- C16 · Histórico do veículo ABC1D23
--
-- Texto do pedido:
--   «Mostre o histórico do veículo ABC1D23: número da OS, dia, mecânico e serviços feitos.»
-- O que sai:
--   1001, dia 02, Carlos, Alinhamento e Troca de óleo · 1003, dia 05, Marta, Troca de pastilhas · 1010, dia 20, Carlos, sem serviços.
-- Como funciona:
--   1. Parte-se das OS do veículo (WHERE v.placa = 'ABC1D23'), com o nome do mecânico.
--   2. Cada OS pode ter vários serviços. LEFT JOIN em item_servico e em servico traz um serviço por linha, e a OS sem serviço (1010) não some.
--   3. O GROUP BY volta a uma linha por OS, e o string_agg junta as descrições dos serviços da OS em um só texto, separadas por vírgula e em ordem alfabética.
--   4. Para a OS sem serviço o string_agg devolve NULL (campo vazio), que é a forma de dizer «sem serviços» no resultado.
--   5. O ORDER BY pela data mostra o histórico em ordem de tempo.
-- Funções:
--   string_agg(texto, separador ORDER BY ordem): junta os textos do grupo em uma só cadeia, com o separador entre eles. O ORDER BY dentro dos parênteses define a ordem das partes. Ignora os NULL.
SELECT o.numero, o.data_abertura, m.nome AS mecanico,
       string_agg(s.descricao, ', ' ORDER BY s.descricao) AS servicos
FROM ordem_servico o
JOIN veiculo v ON v.id = o.veiculo_id
JOIN mecanico m ON m.id = o.mecanico_id
LEFT JOIN item_servico i ON i.ordem_servico_id = o.id
LEFT JOIN servico s ON s.id = i.servico_id
WHERE v.placa = 'ABC1D23'
GROUP BY o.numero, o.data_abertura, m.nome
ORDER BY o.data_abertura;
