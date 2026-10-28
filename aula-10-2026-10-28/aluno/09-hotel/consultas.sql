-- Hotel ou pousada · consultas.sql
-- As 16 consultas de validação (C1 a C16), depois das 5 entradas. Só leem: não alteram o banco.
-- «Hoje» é current_date. Datas aparecem como «dias a partir de hoje» (negativo = no passado).
SET search_path TO hotel;

-- C1 · Quantas reservas, estadias, hóspedes e quartos existem
SELECT (SELECT count(*) FROM reserva) AS reservas, (SELECT count(*) FROM estadia) AS estadias, (SELECT count(*) FROM hospede) AS hospedes, (SELECT count(*) FROM quarto) AS quartos;

-- C2 · Quantos quartos em cada situação
SELECT status, count(*) AS quartos FROM quarto GROUP BY status ORDER BY quartos DESC, status;

-- C3 · Reservas Standard: hóspede, noites, valor das diárias e valor por noite; e a diária Standard (temporada baixa) de hoje
SELECT h.nome, r.saida - r.entrada AS noites, r.valor_diarias, ROUND(r.valor_diarias / (r.saida - r.entrada), 2) AS por_noite,
       (SELECT t.diaria FROM tarifa t WHERE t.tipo_id = r.tipo_id AND t.temporada = 'baixa' AND t.vigencia_inicio <= current_date ORDER BY t.vigencia_inicio DESC LIMIT 1) AS diaria_hoje
FROM reserva r JOIN hospede h ON h.id = r.hospede_id JOIN tipo_quarto tq ON tq.id = r.tipo_id WHERE tq.nome = 'Standard' ORDER BY r.entrada;

-- C4 · Quantas reservas em cada situação
SELECT status, count(*) AS reservas FROM reserva GROUP BY status ORDER BY reservas DESC, status;

-- C5 · Reservas futuras (confirmadas): hóspede, tipo, entrada e saída (dias a partir de hoje), valor das diárias e sinal
SELECT h.nome, tq.nome AS tipo, r.entrada - current_date AS entrada_dias, r.saida - current_date AS saida_dias, r.valor_diarias, r.sinal
FROM reserva r JOIN hospede h ON h.id = r.hospede_id JOIN tipo_quarto tq ON tq.id = r.tipo_id WHERE r.status = 'confirmada' ORDER BY r.entrada;

-- C6 · Hóspedes que nunca estiveram em uma reserva ou estadia
SELECT h.nome FROM hospede h
WHERE NOT EXISTS (SELECT 1 FROM reserva r WHERE r.hospede_id = h.id) AND NOT EXISTS (SELECT 1 FROM estadia_hospede eh WHERE eh.hospede_id = h.id);

-- C7 · Quem está hospedado agora: quarto, responsável e acompanhantes
SELECT q.numero, string_agg(h.nome || ' (' || eh.papel || ')', ', ' ORDER BY eh.papel DESC, h.nome) AS hospedes
FROM estadia e JOIN quarto q ON q.id = e.quarto_id JOIN estadia_hospede eh ON eh.estadia_id = e.id JOIN hospede h ON h.id = eh.hospede_id
WHERE e.checkout_em IS NULL GROUP BY q.numero;

-- C8 · Faturamento: soma do valor final das estadias encerradas
SELECT SUM(valor_final) AS faturamento FROM estadia WHERE status = 'encerrada';

-- C9 · Estadia do Bruno Sá: diárias, meia diária de saída tardia, consumo, valor final, sinal e pago no check-out
SELECT e.diaria_valor * (e.saida_prevista - e.checkin_em::date) AS diarias, e.valor_final
       - e.diaria_valor * (e.saida_prevista - e.checkin_em::date)
       - (SELECT COALESCE(SUM(c.quantidade * c.preco_unitario), 0) FROM consumo c WHERE c.estadia_id = e.id) AS meia_diaria,
       (SELECT COALESCE(SUM(c.quantidade * c.preco_unitario), 0) FROM consumo c WHERE c.estadia_id = e.id) AS consumo,
       e.valor_final, r.sinal, (SELECT SUM(p.valor) FROM pagamento p WHERE p.estadia_id = e.id) AS pago_no_checkout
FROM estadia e JOIN reserva r ON r.id = e.reserva_id JOIN hospede h ON h.id = r.hospede_id WHERE h.nome = 'Bruno Sá';

-- C10 · Consumo total de cada estadia (por quarto; estadia sem consumo = 0)
SELECT q.numero, COALESCE(SUM(c.quantidade * c.preco_unitario), 0) AS consumo
FROM estadia e JOIN quarto q ON q.id = e.quarto_id LEFT JOIN consumo c ON c.estadia_id = e.id GROUP BY q.numero ORDER BY q.numero;

-- C11 · Pagamentos por forma: quantidade e valor
SELECT forma, count(*) AS pagamentos, SUM(valor) AS total FROM pagamento GROUP BY forma ORDER BY total DESC, forma;

-- C12 · Por tipo de quarto: quartos no total e quartos livres agora (todo tipo aparece)
SELECT tq.nome, count(q.id) AS quartos, count(q.id) FILTER (WHERE q.status = 'livre') AS livres
FROM tipo_quarto tq LEFT JOIN quarto q ON q.tipo_id = tq.id GROUP BY tq.nome ORDER BY tq.nome;

-- C13 · Quartos em manutenção: número, motivo, início e fim (dias a partir de hoje)
SELECT q.numero, m.motivo, m.inicio - current_date AS inicio_dias, m.fim - current_date AS fim_dias
FROM manutencao_quarto m JOIN quarto q ON q.id = m.quarto_id;

-- C14 · Reservas canceladas ou não comparecidas: hóspede, situação e quanto deve (cancelada com mais de 7 dias de antecedência: 0; no-show: 50% das diárias)
SELECT h.nome, r.status, CASE WHEN r.status = 'noshow' THEN r.valor_diarias * 0.5 ELSE 0 END AS deve
FROM reserva r JOIN hospede h ON h.id = r.hospede_id WHERE r.status IN ('cancelada', 'noshow') ORDER BY h.nome;

-- C15 · Tarifa vigente hoje: tipo, temporada e diária
SELECT tq.nome, t.temporada, t.diaria
FROM tarifa t JOIN tipo_quarto tq ON tq.id = t.tipo_id
WHERE t.vigencia_inicio = (SELECT max(x.vigencia_inicio) FROM tarifa x WHERE x.tipo_id = t.tipo_id AND x.temporada = t.temporada AND x.vigencia_inicio <= current_date)
ORDER BY tq.nome, t.temporada;

-- C16 · Hóspedes por estadia: quarto, responsável e número de acompanhantes
SELECT q.numero, (SELECT h.nome FROM estadia_hospede eh JOIN hospede h ON h.id = eh.hospede_id WHERE eh.estadia_id = e.id AND eh.papel = 'responsavel') AS responsavel,
       (SELECT count(*) FROM estadia_hospede eh WHERE eh.estadia_id = e.id AND eh.papel = 'acompanhante') AS acompanhantes
FROM estadia e JOIN quarto q ON q.id = e.quarto_id ORDER BY q.numero;
