-- Hotel ou pousada · entradas.sql
-- As 5 entradas do pedido de validação, na ordem. Rode num banco com a estrutura criada (sql/01_ddl.sql) e SEM dados.
-- Datas relativas a hoje: current_date - 10 = «10 dias atrás» (o arquivo serve em qualquer período).
SET search_path TO hotel;

-- ===== Entrada 1 · cadastros =====
INSERT INTO tipo_quarto (nome, capacidade) VALUES ('Standard', 2), ('Superior', 3), ('Suíte', 4);

INSERT INTO quarto (numero, andar, tipo_id, status)
SELECT q.numero, q.andar, (SELECT id FROM tipo_quarto WHERE nome = q.tipo), q.status
FROM (VALUES
    ('101', 1, 'Standard', 'livre'), ('102', 1, 'Standard', 'ocupado'), ('201', 2, 'Superior', 'livre'),
    ('202', 2, 'Superior', 'aguardando_limpeza'), ('301', 3, 'Suíte', 'manutencao')
) AS q (numero, andar, tipo, status);

-- o que não está em nenhum período é temporada baixa
INSERT INTO temporada (nome, inicio, fim) VALUES ('alta', current_date + 30, current_date + 60), ('feriado', current_date + 90, current_date + 92);

INSERT INTO tarifa (tipo_id, temporada, diaria, adicional_pessoa, vigencia_inicio)
SELECT (SELECT id FROM tipo_quarto WHERE nome = t.tipo), t.temp, t.diaria, t.adic, current_date - 300
FROM (VALUES
    ('Standard', 'baixa', 200, 40), ('Standard', 'alta', 300, 50), ('Standard', 'feriado', 400, 60),
    ('Superior', 'baixa', 300, 50), ('Superior', 'alta', 450, 60), ('Suíte', 'baixa', 500, 80)
) AS t (tipo, temp, diaria, adic);

INSERT INTO hospede (nome, documento, nascimento)
SELECT h.nome, h.doc, current_date - (h.idade * interval '1 year') - interval '60 days'
FROM (VALUES ('Ana Leal', 'DOC-0001', 34), ('Bruno Sá', 'DOC-0002', 41), ('Carol Dias', 'DOC-0003', 29), ('Dino Faria', 'DOC-0004', 52),
             ('Edu Mota', 'DOC-0005', 38), ('Fani Reis', 'DOC-0006', 47)) AS h (nome, doc, idade);

INSERT INTO item_consumo (nome, preco) VALUES ('Água mineral', 8), ('Refeição no restaurante', 60), ('Lavanderia (peça)', 35);

INSERT INTO manutencao_quarto (quarto_id, inicio, fim, motivo)
VALUES ((SELECT id FROM quarto WHERE numero = '301'), current_date - 3, current_date + 5, 'Troca do ar-condicionado');

-- ===== Entrada 2 · reservas e estadias antigas, com consumo e pagamento =====
-- A reserva é de um TIPO de quarto; o valor das diárias é o da época e o sinal é de 30%.
INSERT INTO reserva (hospede_id, tipo_id, entrada, saida, num_hospedes, num_criancas, status, valor_diarias, sinal)
SELECT (SELECT id FROM hospede WHERE nome = r.hospede), (SELECT id FROM tipo_quarto WHERE nome = r.tipo), current_date + r.ent, current_date + r.sai,
       r.pessoas, r.criancas, r.status, r.valor, ROUND(r.valor * 0.30, 2)
FROM (VALUES
    ('Ana Leal',   'Standard', -30, -28, 2, 0, 'checkin',   400),    -- 2 noites a R$ 200
    ('Bruno Sá',   'Superior', -20, -17, 3, 1, 'checkin',   900),    -- 3 noites a R$ 300; a criança de 4 anos não paga adicional
    ('Carol Dias', 'Standard', -10,  -7, 2, 0, 'cancelada', 660),    -- cancelada com mais de 7 dias de antecedência: sem custo; 3 noites a R$ 220
    ('Dino Faria', 'Standard',  -5,  -4, 2, 0, 'noshow',    220)     -- não apareceu: paga 50% do valor das diárias
) AS r (hospede, tipo, ent, sai, pessoas, criancas, status, valor);

INSERT INTO estadia (reserva_id, quarto_id, checkin_em, saida_prevista, checkout_em, num_hospedes, num_criancas, diaria_valor, adicional_valor, valor_final, status)
SELECT (SELECT r.id FROM reserva r JOIN hospede h ON h.id = r.hospede_id WHERE h.nome = e.hospede AND r.entrada = current_date + e.ent),
       (SELECT id FROM quarto WHERE numero = e.quarto), (current_date + e.ent) + time '14:00', current_date + e.sai,
       (current_date + e.sai) + e.saida_hora::time, e.pessoas, e.criancas, e.diaria, 0, e.valor, 'encerrada'
FROM (VALUES
    ('Ana Leal', '101', -30, -28, '11:00', 2, 0, 200,  451),    -- 400 de diárias + consumo (2 águas e 1 lavanderia)
    ('Bruno Sá', '201', -20, -17, '17:00', 3, 1, 300, 1110)     -- 900 de diárias + meia diária (saiu às 17:00) + 1 refeição
) AS e (hospede, quarto, ent, sai, saida_hora, pessoas, criancas, diaria, valor);

-- hóspedes de balcão (sem reserva): Carol saiu hoje, Dino está hospedado agora
INSERT INTO estadia (reserva_id, quarto_id, checkin_em, saida_prevista, checkout_em, num_hospedes, diaria_valor, valor_final, status)
VALUES ((SELECT NULL::integer), (SELECT id FROM quarto WHERE numero = '202'), (current_date - 1) + time '14:00', current_date,
        current_date + time '11:00', 1, 300, 300, 'encerrada');

INSERT INTO estadia_hospede (estadia_id, hospede_id, papel)
SELECT e.id, (SELECT id FROM hospede WHERE nome = x.hospede), x.papel
FROM (VALUES ('101', 'Ana Leal', 'responsavel'), ('201', 'Bruno Sá', 'responsavel'), ('201', 'Carol Dias', 'acompanhante'),
             ('202', 'Carol Dias', 'responsavel')) AS x (quarto, hospede, papel)
JOIN estadia e ON e.quarto_id = (SELECT id FROM quarto WHERE numero = x.quarto);

INSERT INTO consumo (estadia_id, item_id, quantidade, preco_unitario)
SELECT (SELECT e.id FROM estadia e WHERE e.quarto_id = (SELECT id FROM quarto WHERE numero = c.quarto)), (SELECT id FROM item_consumo WHERE nome = c.item), c.qtd, c.preco
FROM (VALUES ('101', 'Água mineral', 2, 8), ('101', 'Lavanderia (peça)', 1, 35), ('201', 'Refeição no restaurante', 1, 60)) AS c (quarto, item, qtd, preco);

-- pagamento no check-out (o sinal já pago na reserva é abatido: 451 - 120 = 331; 1110 - 270 = 840)
INSERT INTO pagamento (estadia_id, forma, valor)
SELECT (SELECT e.id FROM estadia e WHERE e.quarto_id = (SELECT id FROM quarto WHERE numero = p.quarto)), p.forma, p.valor
FROM (VALUES ('101', 'pix', 200), ('101', 'cartao', 131), ('201', 'dinheiro', 500), ('201', 'cartao', 340), ('202', 'dinheiro', 300)) AS p (quarto, forma, valor);

-- ===== Entrada 3 · reajuste: a diária Standard na temporada baixa passa de R$ 200 para R$ 220 (desde 15 dias atrás) =====
INSERT INTO tarifa (tipo_id, temporada, diaria, adicional_pessoa, vigencia_inicio)
VALUES ((SELECT id FROM tipo_quarto WHERE nome = 'Standard'), 'baixa', 220, 40, current_date - 15);

-- ===== Entrada 4 · hospedagem em curso e reservas futuras =====
INSERT INTO estadia (quarto_id, checkin_em, saida_prevista, num_hospedes, diaria_valor)
VALUES ((SELECT id FROM quarto WHERE numero = '102'), (current_date - 3) + time '14:00', current_date + 1, 2, 220);

INSERT INTO estadia_hospede (estadia_id, hospede_id, papel)
SELECT (SELECT id FROM estadia WHERE status = 'em_curso'), (SELECT id FROM hospede WHERE nome = x.hospede), x.papel
FROM (VALUES ('Dino Faria', 'responsavel'), ('Fani Reis', 'acompanhante')) AS x (hospede, papel);

INSERT INTO consumo (estadia_id, item_id, quantidade, preco_unitario)
VALUES ((SELECT id FROM estadia WHERE status = 'em_curso'), (SELECT id FROM item_consumo WHERE nome = 'Água mineral'), 2, 8);

INSERT INTO reserva (hospede_id, tipo_id, entrada, saida, num_hospedes, status, valor_diarias, sinal)
SELECT (SELECT id FROM hospede WHERE nome = r.hospede), (SELECT id FROM tipo_quarto WHERE nome = r.tipo), current_date + r.ent, current_date + r.sai,
       r.pessoas, 'confirmada', r.valor, ROUND(r.valor * 0.30, 2)
FROM (VALUES
    ('Bruno Sá', 'Suíte',    10, 12, 2, 1000),      -- 2 noites a R$ 500
    ('Ana Leal', 'Superior', 35, 38, 2, 1350),      -- 3 noites na alta temporada, R$ 450
    ('Edu Mota', 'Standard',  2,  3, 2,  220)       -- esta reserva será apagada (engano)
) AS r (hospede, tipo, ent, sai, pessoas, valor);

-- ===== Entrada 5 · a reserva do Edu Mota foi lançada por engano: sai, e ele continua cadastrado como hóspede =====
DELETE FROM reserva WHERE hospede_id = (SELECT id FROM hospede WHERE nome = 'Edu Mota');
