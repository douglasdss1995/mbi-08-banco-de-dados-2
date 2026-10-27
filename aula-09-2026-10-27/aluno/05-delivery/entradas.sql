-- Delivery de comida · entradas.sql
-- As 5 entradas do pedido de validação, na ordem. Rode num banco com a estrutura criada (sql/01_ddl.sql) e SEM dados.
-- Datas relativas a hoje: current_date - 10 = «10 dias atrás» (o arquivo serve em qualquer período).
SET search_path TO delivery;

-- ===== Entrada 1 · cadastros =====
INSERT INTO categoria_culinaria (nome) VALUES ('Pizza'), ('Japonesa'), ('Lanches'), ('Doces');

INSERT INTO restaurante (nome, categoria_id, pedido_minimo, comissao_pct, preparo_min, ativo)
SELECT r.nome, (SELECT id FROM categoria_culinaria WHERE nome = r.cat), r.minimo, r.comissao, r.preparo, r.ativo
FROM (VALUES
    ('Pizzaria Forno',  'Pizza',    30, 15, 40, true),
    ('Sushi Kai',       'Japonesa', 25, 18, 35, true),
    ('Lanches do Zé',   'Lanches',  20, 15, 20, true),
    ('Café Aurora',     'Doces',     0, 15, 15, false)      -- inativo, sem pedidos
) AS r (nome, cat, minimo, comissao, preparo, ativo);

-- 0 = domingo; quem fecha depois da meia-noite tem «fecha» menor que «abre»
INSERT INTO horario_funcionamento (restaurante_id, dia_semana, abre, fecha)
SELECT (SELECT id FROM restaurante WHERE nome = h.rest), h.dia, h.abre::time, h.fecha::time
FROM (VALUES ('Pizzaria Forno', 5, '18:00', '02:00'), ('Sushi Kai', 6, '12:00', '15:00'), ('Sushi Kai', 6, '18:00', '23:00'),
             ('Lanches do Zé', 1, '10:00', '22:00')) AS h (rest, dia, abre, fecha);

INSERT INTO item_cardapio (restaurante_id, nome, disponivel)
SELECT (SELECT id FROM restaurante WHERE nome = i.rest), i.nome, i.disp
FROM (VALUES
    ('Pizzaria Forno', 'Pizza Margherita', true), ('Pizzaria Forno', 'Pizza Calabresa', true), ('Pizzaria Forno', 'Refrigerante 2 L', false),
    ('Sushi Kai', 'Combo 20 peças', true), ('Sushi Kai', 'Temaki Salmão', true),
    ('Lanches do Zé', 'X-Burger', true), ('Lanches do Zé', 'Batata Frita', true), ('Lanches do Zé', 'Milkshake', true)
) AS i (rest, nome, disp);

INSERT INTO preco_item (item_id, preco, vigencia_inicio)
SELECT (SELECT id FROM item_cardapio WHERE nome = p.nome), p.preco, now() - interval '60 days'
FROM (VALUES ('Pizza Margherita', 50), ('Pizza Calabresa', 55), ('Refrigerante 2 L', 12), ('Combo 20 peças', 90), ('Temaki Salmão', 28),
             ('X-Burger', 22), ('Batata Frita', 15), ('Milkshake', 18)) AS p (nome, preco);

INSERT INTO cliente (nome, email, telefone) VALUES
    ('Rafa Gomes',  'rafa.gomes@delivery.example',  '(47) 98800-0001'),
    ('Sílvia Neto', 'silvia.neto@delivery.example', '(47) 98800-0002'),
    ('Tomás Braga', 'tomas.braga@delivery.example', NULL),
    ('Úrsula Dias', 'ursula.dias@delivery.example', '(47) 98800-0004'),
    ('Vitor Ramos', 'vitor.ramos@delivery.example', '(47) 98800-0005');

INSERT INTO endereco (cliente_id, logradouro, numero, bairro, distancia_km)
SELECT (SELECT id FROM cliente WHERE nome = e.cliente), e.logr, e.num, e.bairro, e.km
FROM (VALUES
    ('Rafa Gomes',  'Rua A',     '10',  'Centro',  2.0),
    ('Rafa Gomes',  'Rua B',     '200', 'Jardim',  7.5),
    ('Sílvia Neto', 'Avenida Sul', '55', 'Sul',    4.5),
    ('Tomás Braga', 'Rua C',     '3',   'Norte',   1.0),
    ('Úrsula Dias', 'Rua D',     '9',   'Leste',   5.0),
    ('Vitor Ramos', 'Rua E',     '80',  'Oeste',   3.0)
) AS e (cliente, logr, num, bairro, km);

-- taxa de entrega por distância: até 3 km, R$ 5; até 6 km, R$ 8; acima, R$ 12 (grátis se os itens somam R$ 80 ou mais)
INSERT INTO faixa_taxa (km_ate, taxa) VALUES (3, 5), (6, 8), (NULL, 12);

INSERT INTO entregador (nome, status) VALUES ('Wagner Lopes', 'disponivel'), ('Yara Costa', 'offline'), ('Zeca Moura', 'offline');

-- ===== Entrada 2 · pedidos antigos, com itens, entregas, pagamentos e avaliações =====
INSERT INTO pedido (cliente_id, restaurante_id, status, criado_em, prometido_ate, entregue_em, dest_logradouro, dest_numero, dest_bairro,
                    dest_distancia_km, subtotal, taxa_entrega, total, comissao_pct, cancelado_por, cobranca_cancelamento)
SELECT c.id, r.id, k.status, now() - k.dias * interval '1 day', now() - k.dias * interval '1 day' + k.prom * interval '1 minute',
       CASE WHEN k.status = 'entregue' THEN now() - k.dias * interval '1 day' + k.ent * interval '1 minute' END,
       e.logradouro, e.numero, e.bairro, e.distancia_km, k.subtotal, k.taxa, k.subtotal + k.taxa, k.comissao,
       CASE WHEN k.status = 'cancelado' THEN 'cliente' END, k.cobranca
FROM (VALUES
    ('Rafa Gomes',  'Pizzaria Forno', 'Rua A',        20, 'entregue',  60, 50, 155, 0, 15, NULL),
    ('Sílvia Neto', 'Sushi Kai',      'Avenida Sul',  15, 'entregue',  50, 75,  28, 8, 18, NULL),
    ('Tomás Braga', 'Lanches do Zé',  'Rua C',        10, 'entregue',  40, 30,  59, 5, 15, NULL),
    ('Rafa Gomes',  'Sushi Kai',      'Rua A',         8, 'cancelado', 50, NULL, 90, 0, 18, 45)    -- cancelado pelo cliente depois do aceite: paga 50% dos itens
) AS k (cliente, rest, logr, dias, status, prom, ent, subtotal, taxa, comissao, cobranca)
JOIN cliente c ON c.nome = k.cliente JOIN restaurante r ON r.nome = k.rest
JOIN endereco e ON e.cliente_id = c.id AND e.logradouro = k.logr;

INSERT INTO item_pedido (pedido_id, item_id, quantidade, preco_unitario, opcoes)
SELECT (SELECT p.id FROM pedido p JOIN cliente c ON c.id = p.cliente_id JOIN restaurante r ON r.id = p.restaurante_id
        WHERE c.nome = i.cliente AND r.nome = i.rest AND p.criado_em::date = current_date - i.dias),
       (SELECT id FROM item_cardapio WHERE nome = i.item), i.qtd, i.preco, i.opcoes::jsonb
FROM (VALUES
    ('Rafa Gomes',  'Pizzaria Forno', 20, 'Pizza Margherita', 2, 50, '{}'), ('Rafa Gomes', 'Pizzaria Forno', 20, 'Pizza Calabresa', 1, 55, '{}'),
    ('Sílvia Neto', 'Sushi Kai',      15, 'Temaki Salmão',    1, 28, '{}'),
    ('Tomás Braga', 'Lanches do Zé',  10, 'X-Burger',         2, 22, '{"obs": "sem cebola"}'), ('Tomás Braga', 'Lanches do Zé', 10, 'Batata Frita', 1, 15, '{}'),
    ('Rafa Gomes',  'Sushi Kai',       8, 'Combo 20 peças',   1, 90, '{}')
) AS i (cliente, rest, dias, item, qtd, preco, opcoes);

-- cada mudança de status com a hora (aqui só dos pedidos do Rafa)
INSERT INTO historico_status (pedido_id, status_antes, status_depois, quando)
SELECT (SELECT p.id FROM pedido p JOIN cliente c ON c.id = p.cliente_id JOIN restaurante r ON r.id = p.restaurante_id
        WHERE c.nome = h.cliente AND r.nome = h.rest AND p.criado_em::date = current_date - h.dias),
       h.antes, h.depois, (now() - h.dias * interval '1 day') + h.min * interval '1 minute'
FROM (VALUES
    ('Rafa Gomes', 'Pizzaria Forno', 20, NULL,         'criado',     0),
    ('Rafa Gomes', 'Pizzaria Forno', 20, 'criado',     'aceito',     3),
    ('Rafa Gomes', 'Pizzaria Forno', 20, 'aceito',     'em_preparo', 5),
    ('Rafa Gomes', 'Pizzaria Forno', 20, 'em_preparo', 'pronto',    35),
    ('Rafa Gomes', 'Pizzaria Forno', 20, 'pronto',     'a_caminho', 38),
    ('Rafa Gomes', 'Pizzaria Forno', 20, 'a_caminho',  'entregue',  50),
    ('Rafa Gomes', 'Sushi Kai',       8, NULL,         'criado',     0),
    ('Rafa Gomes', 'Sushi Kai',       8, 'criado',     'aceito',     4),
    ('Rafa Gomes', 'Sushi Kai',       8, 'aceito',     'cancelado',  9)
) AS h (cliente, rest, dias, antes, depois, min);

INSERT INTO entrega (pedido_id, entregador_id, atribuida_em, concluida_em, status)
SELECT (SELECT p.id FROM pedido p JOIN cliente c ON c.id = p.cliente_id JOIN restaurante r ON r.id = p.restaurante_id
        WHERE c.nome = g.cliente AND r.nome = g.rest AND p.criado_em::date = current_date - g.dias),
       (SELECT id FROM entregador WHERE nome = g.entregador),
       (now() - g.dias * interval '1 day') + g.ini * interval '1 minute',
       CASE WHEN g.status = 'concluida' THEN (now() - g.dias * interval '1 day') + g.fim * interval '1 minute' END, g.status
FROM (VALUES
    ('Rafa Gomes',  'Pizzaria Forno', 20, 'Wagner Lopes', 38, 50, 'concluida'),
    ('Sílvia Neto', 'Sushi Kai',      15, 'Wagner Lopes', 40, 75, 'concluida'),
    ('Tomás Braga', 'Lanches do Zé',  10, 'Yara Costa',   15, 30, 'concluida')
) AS g (cliente, rest, dias, entregador, ini, fim, status);

INSERT INTO pagamento (pedido_id, forma, valor, situacao, pago_em)
SELECT p.id, g.forma, p.total, 'pago', p.criado_em + interval '1 minute'
FROM (VALUES ('Rafa Gomes', 'Pizzaria Forno', 'pix'), ('Sílvia Neto', 'Sushi Kai', 'cartao'), ('Tomás Braga', 'Lanches do Zé', 'dinheiro'))
     AS g (cliente, rest, forma)
JOIN cliente c ON c.nome = g.cliente JOIN restaurante r ON r.nome = g.rest
JOIN pedido p ON p.cliente_id = c.id AND p.restaurante_id = r.id AND p.status = 'entregue';

INSERT INTO avaliacao (pedido_id, nota_restaurante, nota_entregador, comentario)
SELECT p.id, g.nr, g.ne, g.com
FROM (VALUES ('Rafa Gomes', 'Pizzaria Forno', 5, 4, 'Chegou quente'), ('Sílvia Neto', 'Sushi Kai', 3, 2, 'Demorou'),
             ('Tomás Braga', 'Lanches do Zé', 5, 5, NULL)) AS g (cliente, rest, nr, ne, com)
JOIN cliente c ON c.nome = g.cliente JOIN restaurante r ON r.nome = g.rest
JOIN pedido p ON p.cliente_id = c.id AND p.restaurante_id = r.id AND p.status = 'entregue';

-- ===== Entrada 3 · reajuste de preço, nova comissão e mudança de endereço =====
INSERT INTO preco_item (item_id, preco, vigencia_inicio)
VALUES ((SELECT id FROM item_cardapio WHERE nome = 'Pizza Margherita'), 56, now() - interval '7 days');

UPDATE restaurante SET comissao_pct = 20 WHERE nome = 'Sushi Kai';

UPDATE endereco SET numero = '12'
WHERE cliente_id = (SELECT id FROM cliente WHERE nome = 'Rafa Gomes') AND logradouro = 'Rua A';

-- ===== Entrada 4 · pedidos recentes =====
INSERT INTO pedido (cliente_id, restaurante_id, status, criado_em, prometido_ate, entregue_em, dest_logradouro, dest_numero, dest_bairro,
                    dest_distancia_km, subtotal, taxa_entrega, total, comissao_pct)
SELECT c.id, r.id, k.status, now() - k.dias * interval '1 day' - k.min * interval '1 minute',
       now() - k.dias * interval '1 day' - k.min * interval '1 minute' + k.prom * interval '1 minute',
       CASE WHEN k.status = 'entregue' THEN now() - k.dias * interval '1 day' - k.min * interval '1 minute' + k.ent * interval '1 minute' END,
       e.logradouro, e.numero, e.bairro, e.distancia_km, k.subtotal, k.taxa, k.subtotal + k.taxa,
       CASE WHEN r.nome = 'Sushi Kai' THEN 20 ELSE r.comissao_pct END
FROM (VALUES
    ('Vitor Ramos', 'Pizzaria Forno', 'Rua E',        2, 0, 'entregue',   60, 40, 111,  0),
    ('Rafa Gomes',  'Lanches do Zé',  'Rua B',        0, 5, 'a_caminho',  40, NULL, 40, 12),
    ('Sílvia Neto', 'Pizzaria Forno', 'Avenida Sul',  0, 5, 'em_preparo', 60, NULL, 55,  8),
    ('Tomás Braga', 'Sushi Kai',      'Rua C',        0, 2, 'criado',     50, NULL, 28,  5)      -- este será o pedido lançado por engano
) AS k (cliente, rest, logr, dias, min, status, prom, ent, subtotal, taxa)
JOIN cliente c ON c.nome = k.cliente JOIN restaurante r ON r.nome = k.rest
JOIN endereco e ON e.cliente_id = c.id AND e.logradouro = k.logr;

INSERT INTO item_pedido (pedido_id, item_id, quantidade, preco_unitario)
SELECT (SELECT p.id FROM pedido p JOIN cliente c ON c.id = p.cliente_id JOIN restaurante r ON r.id = p.restaurante_id
        WHERE c.nome = i.cliente AND r.nome = i.rest AND p.criado_em::date = current_date - i.dias),
       (SELECT id FROM item_cardapio WHERE nome = i.item), i.qtd, i.preco
FROM (VALUES
    ('Vitor Ramos', 'Pizzaria Forno', 2, 'Pizza Margherita', 1, 56), ('Vitor Ramos', 'Pizzaria Forno', 2, 'Pizza Calabresa', 1, 55),
    ('Rafa Gomes',  'Lanches do Zé',  0, 'X-Burger',         1, 22), ('Rafa Gomes',  'Lanches do Zé',  0, 'Milkshake',       1, 18),
    ('Sílvia Neto', 'Pizzaria Forno', 0, 'Pizza Calabresa',  1, 55),
    ('Tomás Braga', 'Sushi Kai',      0, 'Temaki Salmão',    1, 28)
) AS i (cliente, rest, dias, item, qtd, preco);

-- Vitor: a primeira entrega foi atribuída ao Zeca, que desistiu; a Yara assumiu e concluiu. Rafa: a Yara está a caminho agora.
INSERT INTO entrega (pedido_id, entregador_id, atribuida_em, concluida_em, status)
SELECT (SELECT p.id FROM pedido p JOIN cliente c ON c.id = p.cliente_id JOIN restaurante r ON r.id = p.restaurante_id
        WHERE c.nome = g.cliente AND r.nome = g.rest AND p.criado_em::date = current_date - g.dias),
       (SELECT id FROM entregador WHERE nome = g.entregador),
       now() - g.dias * interval '1 day' - g.min * interval '1 minute', g.fim, g.status
FROM (VALUES
    ('Vitor Ramos', 'Pizzaria Forno', 2, 'Zeca Moura', 20, NULL::timestamp, 'desistiu'),
    ('Vitor Ramos', 'Pizzaria Forno', 2, 'Yara Costa',  8, now() - interval '2 days' + interval '30 minutes', 'concluida'),
    ('Rafa Gomes',  'Lanches do Zé',  0, 'Yara Costa',  3, NULL::timestamp, 'ativa')
) AS g (cliente, rest, dias, entregador, min, fim, status);

UPDATE entregador SET status = 'em_entrega' WHERE nome = 'Yara Costa';
UPDATE entregador SET status = 'disponivel' WHERE nome = 'Wagner Lopes';

INSERT INTO pagamento (pedido_id, forma, valor, situacao, pago_em)
SELECT p.id, 'pix', p.total, 'pago', p.criado_em + interval '1 minute'
FROM pedido p JOIN cliente c ON c.id = p.cliente_id WHERE c.nome = 'Vitor Ramos';

INSERT INTO avaliacao (pedido_id, nota_restaurante, nota_entregador, comentario)
SELECT p.id, 4, 5, 'Ótima' FROM pedido p JOIN cliente c ON c.id = p.cliente_id WHERE c.nome = 'Vitor Ramos';

-- ===== Entrada 5 · o pedido do Tomás Braga no Sushi Kai foi lançado por engano: sai com os itens =====
DELETE FROM item_pedido WHERE pedido_id = (SELECT p.id FROM pedido p JOIN cliente c ON c.id = p.cliente_id JOIN restaurante r ON r.id = p.restaurante_id
                                           WHERE c.nome = 'Tomás Braga' AND r.nome = 'Sushi Kai');
DELETE FROM pedido WHERE id = (SELECT p.id FROM pedido p JOIN cliente c ON c.id = p.cliente_id JOIN restaurante r ON r.id = p.restaurante_id
                               WHERE c.nome = 'Tomás Braga' AND r.nome = 'Sushi Kai');
