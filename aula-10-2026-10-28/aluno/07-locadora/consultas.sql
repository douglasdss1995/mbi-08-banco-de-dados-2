-- Locadora de veículos · consultas.sql
-- As 16 consultas de validação (C1 a C16), depois das 5 entradas. Só leem: não alteram o banco.
-- «Hoje» é current_date. Datas aparecem como «dias a partir de hoje» (negativo = no passado).
SET search_path TO locadora;

-- C1 · Quantas locações, veículos e clientes existem
SELECT (SELECT count(*) FROM locacao) AS locacoes, (SELECT count(*) FROM veiculo) AS veiculos, (SELECT count(*) FROM cliente) AS clientes;

-- C2 · Quantos veículos em cada situação
SELECT status, count(*) AS veiculos FROM veiculo GROUP BY status ORDER BY veiculos DESC, status;

-- C3 · Vistorias: por locação encerrada com vistoria, placa, quilômetros rodados (devolução menos retirada), combustível na retirada e na devolução (em quartos) e avarias
SELECT v.placa, vd.km - vr.km AS km_rodados, (vr.dados_vistoria ->> 'combustivel_quartos')::int AS combustivel_retirada,
       (vd.dados_vistoria ->> 'combustivel_quartos')::int AS combustivel_devolucao, vd.dados_vistoria ->> 'avarias' AS avarias
FROM locacao l JOIN veiculo v ON v.id = l.veiculo_id
JOIN vistoria vr ON vr.locacao_id = l.id AND vr.tipo = 'retirada' JOIN vistoria vd ON vd.locacao_id = l.id AND vd.tipo = 'devolucao' ORDER BY v.placa;

-- C4 · Locações em andamento: cliente, placa e devolução prevista (dias a partir de hoje)
SELECT c.nome, v.placa, l.devolucao_prevista::date - current_date AS prevista_em_dias
FROM locacao l JOIN cliente c ON c.id = l.cliente_id JOIN veiculo v ON v.id = l.veiculo_id WHERE l.status = 'em_andamento' ORDER BY l.devolucao_prevista;

-- C5 · Diária de cada locação do grupo Econômico, e a diária de hoje do grupo
SELECT current_date - l.retirada::date AS retirada_dias_atras, l.diaria_valor,
       (SELECT t.diaria FROM tarifa_grupo t WHERE t.grupo_id = g.id AND t.vigencia_inicio <= current_date ORDER BY t.vigencia_inicio DESC LIMIT 1) AS diaria_hoje
FROM locacao l JOIN grupo g ON g.id = l.grupo_id WHERE g.nome = 'Econômico' ORDER BY l.retirada;

-- C6 · Valor final de cada locação encerrada: cliente, placa e valor
SELECT c.nome, v.placa, l.valor_final FROM locacao l JOIN cliente c ON c.id = l.cliente_id JOIN veiculo v ON v.id = l.veiculo_id
WHERE l.status = 'encerrada' ORDER BY l.retirada;

-- C7 · Faturamento: soma do valor final das locações encerradas
SELECT SUM(valor_final) AS faturamento FROM locacao WHERE status = 'encerrada';

-- C8 · Locações por grupo (todo grupo aparece)
SELECT g.nome, count(l.id) AS locacoes FROM grupo g LEFT JOIN locacao l ON l.grupo_id = g.id GROUP BY g.nome ORDER BY locacoes DESC, g.nome;

-- C9 · Locações devolvidas em outra filial: cliente, filial de retirada e filial de devolução
SELECT c.nome, fr.nome AS retirada, fd.nome AS devolucao
FROM locacao l JOIN cliente c ON c.id = l.cliente_id JOIN filial fr ON fr.id = l.filial_retirada_id JOIN filial fd ON fd.id = l.filial_devolucao_id
WHERE l.filial_devolucao_id <> l.filial_retirada_id;

-- C10 · Veículos que precisam de revisão (10.000 km ou mais desde a última, ou mais de 6 meses): placa e motivo
SELECT v.placa, CASE WHEN v.km_atual - v.km_ultima_revisao >= 10000 THEN 'quilometragem' ELSE 'tempo' END AS motivo
FROM veiculo v WHERE v.km_atual - v.km_ultima_revisao >= 10000 OR v.data_ultima_revisao <= current_date - interval '6 months' ORDER BY v.placa;

-- C11 · Multas de trânsito: placa, dias atrás, valor e o cliente que estava com o carro naquela hora (vazio se ninguém)
SELECT v.placa, current_date - m.ocorrida_em::date AS dias_atras, m.valor,
       (SELECT c.nome FROM locacao l JOIN cliente c ON c.id = l.cliente_id
        WHERE l.veiculo_id = m.veiculo_id AND m.ocorrida_em >= l.retirada AND m.ocorrida_em <= COALESCE(l.devolucao_real, l.devolucao_prevista)) AS cliente
FROM multa_transito m JOIN veiculo v ON v.id = m.veiculo_id ORDER BY m.ocorrida_em;

-- C12 · Clientes que nunca alugaram
SELECT c.nome FROM cliente c WHERE NOT EXISTS (SELECT 1 FROM locacao l WHERE l.cliente_id = c.id);

-- C13 · Clientes com a CNH vencendo nos próximos 30 dias
SELECT c.nome, c.cnh_validade - current_date AS vence_em_dias FROM cliente c WHERE c.cnh_validade BETWEEN current_date AND current_date + 30;

-- C14 · Clientes que podem alugar grupo premium (SUV e utilitário): CNH com 2 anos ou mais
SELECT c.nome FROM cliente c WHERE c.cnh_primeira_emissao <= current_date - interval '2 years' ORDER BY c.nome;

-- C15 · Reservas por situação
SELECT status, count(*) AS reservas FROM reserva GROUP BY status ORDER BY status;

-- C16 · Quantas vezes cada adicional foi usado e o valor por diária da época (todo adicional aparece)
SELECT a.nome, count(al.locacao_id) AS usos, a.valor_diaria AS valor_de_hoje, string_agg(al.valor_diaria::text, ', ') AS valor_na_locacao
FROM adicional a LEFT JOIN adicional_locacao al ON al.adicional_id = a.id GROUP BY a.nome, a.valor_diaria ORDER BY usos DESC, a.nome;
