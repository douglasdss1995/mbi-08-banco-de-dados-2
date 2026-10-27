-- Locadora de veículos · entradas.sql
-- As 5 entradas do pedido de validação, na ordem. Rode num banco com a estrutura criada (sql/01_ddl.sql) e SEM dados.
-- Datas relativas a hoje: current_date - 10 = «10 dias atrás» (o arquivo serve em qualquer período).
SET search_path TO locadora;

-- ===== Entrada 1 · cadastros =====
INSERT INTO filial (nome, cidade) VALUES ('Centro', 'Joinville'), ('Aeroporto', 'Florianópolis'), ('Norte', 'Blumenau');

INSERT INTO grupo (nome, caucao, premium) VALUES ('Econômico', 500, false), ('Sedã', 800, false), ('SUV', 1500, true), ('Utilitário', 1200, true);

INSERT INTO tarifa_grupo (grupo_id, diaria, vigencia_inicio)
SELECT (SELECT id FROM grupo WHERE nome = t.grupo), t.diaria, current_date - 300
FROM (VALUES ('Econômico', 100), ('Sedã', 150), ('SUV', 250), ('Utilitário', 220)) AS t (grupo, diaria);

INSERT INTO modelo (nome, grupo_id)
SELECT m.nome, (SELECT id FROM grupo WHERE nome = m.grupo)
FROM (VALUES ('Onix', 'Econômico'), ('Mobi', 'Econômico'), ('Corolla', 'Sedã'), ('Compass', 'SUV'), ('Strada', 'Utilitário')) AS m (nome, grupo);

INSERT INTO veiculo (placa, modelo_id, filial_id, status, km_atual, km_ultima_revisao, data_ultima_revisao)
SELECT v.placa, (SELECT id FROM modelo WHERE nome = v.modelo), (SELECT id FROM filial WHERE nome = v.filial), v.status, v.km, v.km_rev, current_date - v.dias_rev
FROM (VALUES
    ('ABC1A11', 'Onix',    'Centro',    'disponivel', 30000, 25000, 100),
    ('DEF2B22', 'Mobi',    'Centro',    'disponivel', 15000, 10000,  50),
    ('GHI3C33', 'Corolla', 'Aeroporto', 'disponivel', 18000,  9000,  60),
    ('JKL4D44', 'Compass', 'Aeroporto', 'manutencao', 20000, 15000, 200),
    ('MNO5E55', 'Onix',    'Norte',     'disponivel', 41000, 30000,  90)
) AS v (placa, modelo, filial, status, km, km_rev, dias_rev);

INSERT INTO cliente (nome, nascimento, cnh_numero, cnh_validade, cnh_primeira_emissao)
SELECT c.nome, current_date - (c.idade * interval '1 year') - interval '60 days', c.cnh, current_date + c.validade,
       current_date - (c.emissao * interval '1 year')
FROM (VALUES
    ('Lúcio Prado', 35, 'CNH-0001',  400, 10),
    ('Mônica Reis', 28, 'CNH-0002',  300,  1),
    ('Nando Cruz',  40, 'CNH-0003',   20, 15),
    ('Olga Silva',  50, 'CNH-0004',  800, 25),
    ('Pablo Dias',  26, 'CNH-0005',  500,  5)
) AS c (nome, idade, cnh, validade, emissao);

INSERT INTO adicional (nome, valor_diaria) VALUES ('Seguro', 30), ('Cadeirinha', 15), ('GPS', 20), ('Motorista adicional', 25);

-- ===== Entrada 2 · reservas e locações antigas (encerradas), com vistorias e adicionais =====
INSERT INTO reserva (cliente_id, grupo_id, filial_retirada_id, retirada_prevista, devolucao_prevista, criada_em, status)
SELECT (SELECT id FROM cliente WHERE nome = r.cliente), (SELECT id FROM grupo WHERE nome = r.grupo), (SELECT id FROM filial WHERE nome = r.filial),
       (current_date + r.ret) + time '10:00', (current_date + r.dev) + time '10:00', (current_date + r.criada) + time '09:00', r.status
FROM (VALUES
    ('Mônica Reis', 'Econômico', 'Centro',   -40, -30, -45, 'retirada'),
    ('Nando Cruz',  'SUV',       'Aeroporto', -25, -22, -30, 'cancelada'),
    ('Lúcio Prado', 'Econômico', 'Centro',   -90, -88, -95, 'noshow'),
    ('Lúcio Prado', 'Sedã',      'Centro',     3,   6,   0, 'ativa')
) AS r (cliente, grupo, filial, ret, dev, criada, status);

INSERT INTO locacao (reserva_id, cliente_id, veiculo_id, grupo_id, filial_retirada_id, filial_devolucao_id, retirada, devolucao_prevista, devolucao_real,
                     diaria_valor, caucao, valor_final, status)
SELECT (SELECT r.id FROM reserva r JOIN cliente c ON c.id = r.cliente_id WHERE c.nome = l.cliente AND r.status = 'retirada'),
       c.id, v.id, g.id, (SELECT id FROM filial WHERE nome = l.fil_ret), (SELECT id FROM filial WHERE nome = l.fil_dev),
       (current_date + l.ret) + time '09:00', (current_date + l.prev) + time '09:00', (current_date + l.real) + time '08:30',
       l.diaria, g.caucao, l.valor, 'encerrada'
FROM (VALUES
    ('Lúcio Prado', 'ABC1A11', 'Centro',   'Centro',    -60, -55, -55, 100,  650),   -- 5 diárias de 100 + Seguro (30 x 5)
    ('Mônica Reis', 'DEF2B22', 'Centro',   'Aeroporto', -40, -30, -30, 100, 1200),   -- 10 diárias (10% de desconto) + Cadeirinha + R$ 150 de devolução em outra filial
    ('Lúcio Prado', 'GHI3C33', 'Aeroporto','Aeroporto', -12,  -5,  -5, 150, 1085)    -- 7 diárias (10% de desconto) + GPS
) AS l (cliente, placa, fil_ret, fil_dev, ret, prev, real, diaria, valor)
JOIN cliente c ON c.nome = l.cliente JOIN veiculo v ON v.placa = l.placa JOIN modelo mo ON mo.id = v.modelo_id JOIN grupo g ON g.id = mo.grupo_id;

INSERT INTO adicional_locacao (locacao_id, adicional_id, valor_diaria)
SELECT (SELECT l.id FROM locacao l JOIN veiculo v ON v.id = l.veiculo_id WHERE v.placa = x.placa),
       (SELECT id FROM adicional WHERE nome = x.adic), x.valor
FROM (VALUES ('ABC1A11', 'Seguro', 30), ('DEF2B22', 'Cadeirinha', 15), ('GHI3C33', 'GPS', 20)) AS x (placa, adic, valor);

INSERT INTO vistoria (locacao_id, tipo, km, feita_em, dados_vistoria)
SELECT (SELECT l.id FROM locacao l JOIN veiculo v ON v.id = l.veiculo_id WHERE v.placa = x.placa),
       x.tipo, x.km, (current_date + x.dia) + time '09:00', x.dados::jsonb
FROM (VALUES
    ('ABC1A11', 'retirada',  25000, -60, '{"combustivel_quartos": 4}'),
    ('ABC1A11', 'devolucao', 25800, -55, '{"combustivel_quartos": 3, "avarias": "arranhão no para-choque"}'),
    ('DEF2B22', 'retirada',  14000, -40, '{"combustivel_quartos": 4}'),
    ('DEF2B22', 'devolucao', 15000, -30, '{"combustivel_quartos": 4}')
) AS x (placa, tipo, km, dia, dados);

-- ===== Entrada 3 · reajuste: a diária do grupo Econômico passa de R$ 100 para R$ 120 (desde 20 dias atrás) =====
INSERT INTO tarifa_grupo (grupo_id, diaria, vigencia_inicio) VALUES ((SELECT id FROM grupo WHERE nome = 'Econômico'), 120, current_date - 20);

-- ===== Entrada 4 · locações em andamento, manutenção e multas de trânsito =====
INSERT INTO locacao (cliente_id, veiculo_id, grupo_id, filial_retirada_id, retirada, devolucao_prevista, diaria_valor, caucao, status)
SELECT c.id, v.id, g.id, v.filial_id, (current_date + l.ret) + time '09:00', (current_date + l.prev) + time '09:00', 120, g.caucao, 'em_andamento'
FROM (VALUES ('Nando Cruz', 'DEF2B22', -3, 4), ('Pablo Dias', 'MNO5E55', -1, 2)) AS l (cliente, placa, ret, prev)
JOIN cliente c ON c.nome = l.cliente JOIN veiculo v ON v.placa = l.placa JOIN modelo mo ON mo.id = v.modelo_id JOIN grupo g ON g.id = mo.grupo_id;
UPDATE veiculo SET status = 'alugado' WHERE placa IN ('DEF2B22', 'MNO5E55');

INSERT INTO manutencao (veiculo_id, tipo, inicio, fim, km)
VALUES ((SELECT id FROM veiculo WHERE placa = 'JKL4D44'), 'revisao', (current_date - 2) + time '08:00', (current_date + 3) + time '18:00', 20000);

INSERT INTO multa_transito (veiculo_id, ocorrida_em, valor, descricao)
SELECT (SELECT id FROM veiculo WHERE placa = m.placa), (current_date + m.dia) + time '14:00', m.valor, m.descr
FROM (VALUES ('GHI3C33', -8, 195, 'Excesso de velocidade'), ('ABC1A11', -57, 130, 'Estacionamento proibido'),
             ('DEF2B22', -20, 88, 'Farol apagado')) AS m (placa, dia, valor, descr);

-- ===== Entrada 5 · uma locação lançada por engano =====
-- Olga Silva «alugou» o ABC1A11 ainda hoje, mas foi engano. Lança (com adicional e vistoria) e apaga tudo; o carro volta a ficar disponível.
INSERT INTO locacao (cliente_id, veiculo_id, grupo_id, filial_retirada_id, retirada, devolucao_prevista, diaria_valor, caucao, status)
SELECT c.id, v.id, g.id, v.filial_id, now(), now() + interval '3 days', 120, g.caucao, 'em_andamento'
FROM cliente c, veiculo v JOIN modelo mo ON mo.id = v.modelo_id JOIN grupo g ON g.id = mo.grupo_id WHERE c.nome = 'Olga Silva' AND v.placa = 'ABC1A11';
UPDATE veiculo SET status = 'alugado' WHERE placa = 'ABC1A11';
INSERT INTO adicional_locacao (locacao_id, adicional_id, valor_diaria)
SELECT l.id, (SELECT id FROM adicional WHERE nome = 'GPS'), 20 FROM locacao l JOIN cliente c ON c.id = l.cliente_id WHERE c.nome = 'Olga Silva';
INSERT INTO vistoria (locacao_id, tipo, km, dados_vistoria)
SELECT l.id, 'retirada', 30000, '{"combustivel_quartos": 4}' FROM locacao l JOIN cliente c ON c.id = l.cliente_id WHERE c.nome = 'Olga Silva';

DELETE FROM vistoria WHERE locacao_id = (SELECT l.id FROM locacao l JOIN cliente c ON c.id = l.cliente_id WHERE c.nome = 'Olga Silva');
DELETE FROM adicional_locacao WHERE locacao_id = (SELECT l.id FROM locacao l JOIN cliente c ON c.id = l.cliente_id WHERE c.nome = 'Olga Silva');
DELETE FROM locacao WHERE cliente_id = (SELECT id FROM cliente WHERE nome = 'Olga Silva');
UPDATE veiculo SET status = 'disponivel' WHERE placa = 'ABC1A11';
