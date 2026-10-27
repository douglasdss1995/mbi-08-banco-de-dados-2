-- Loja virtual · entradas.sql
-- As 5 entradas do pedido de validação, na ordem. Rode num banco com a estrutura criada (sql/01_ddl.sql) e SEM dados.
-- Datas relativas a hoje: current_date - 10 = «10 dias atrás» (o arquivo serve em qualquer período).
SET search_path TO loja;

-- ===== Entrada 1 · cadastros =====
INSERT INTO categoria (nome) VALUES ('Periféricos'), ('Componentes'), ('Cabos'), ('Gadgets');

INSERT INTO produto (sku, nome, categoria_id, estoque)
SELECT p.sku, p.nome, (SELECT id FROM categoria WHERE nome = p.cat), p.estoque
FROM (VALUES
    ('TEC-001',  'Teclado Mecânico',  'Periféricos', 20),
    ('MOU-001',  'Mouse Sem Fio',     'Periféricos', 30),
    ('RAM-008',  'Memória RAM 8 GB',  'Componentes', 15),
    ('CAB-HDMI', 'Cabo HDMI 2 m',     'Cabos',       50),
    ('SSD-240',  'SSD 240 GB',        'Componentes', 10),
    ('CAM-HD',   'Webcam HD',         'Periféricos',  0)
) AS p (sku, nome, cat, estoque);

INSERT INTO preco_produto (produto_id, preco, vigencia_inicio)
SELECT (SELECT id FROM produto WHERE sku = p.sku), p.preco, current_date - 60
FROM (VALUES ('TEC-001', 250), ('MOU-001', 80), ('RAM-008', 200), ('CAB-HDMI', 30), ('SSD-240', 220), ('CAM-HD', 150)) AS p (sku, preco);

INSERT INTO cliente (nome, email, cpf) VALUES
    ('Marcos Dias', 'marcos.dias@loja.example', '11111111101'),
    ('Luana Reis',  'luana.reis@loja.example',  '11111111102'),
    ('Pedro Alves', 'pedro.alves@loja.example', '11111111103'),
    ('Sara Lima',   'sara.lima@loja.example',   '11111111104'),
    ('Tiago Neves', 'tiago.neves@loja.example', '11111111105');

INSERT INTO frete_uf (uf, valor) VALUES ('SP', 20), ('RJ', 30), ('MG', 35), ('PR', 40);

INSERT INTO endereco (cliente_id, logradouro, numero, cidade, uf, cep)
SELECT (SELECT id FROM cliente WHERE nome = e.cliente), e.logr, e.num, e.cidade, e.uf, e.cep
FROM (VALUES
    ('Marcos Dias', 'Rua das Flores',  '100', 'São Paulo',      'SP', '01000000'),
    ('Marcos Dias', 'Avenida Central', '500', 'Campinas',       'SP', '13000000'),
    ('Luana Reis',  'Rua do Mar',      '20',  'Rio de Janeiro', 'RJ', '20000000'),
    ('Pedro Alves', 'Rua da Serra',    '35',  'Belo Horizonte', 'MG', '30000000'),
    ('Sara Lima',   'Rua Nova',        '7',   'São Paulo',      'SP', '01100000'),
    ('Tiago Neves', 'Rua do Porto',    '88',  'Curitiba',       'PR', '80000000')
) AS e (cliente, logr, num, cidade, uf, cep);

INSERT INTO cupom (codigo, tipo, valor, valido_ate, limite_usos, valor_minimo) VALUES
    ('PROMO10', 'percentual', 10, current_date + 30, 2, 100),
    ('FIXO20',  'fixo',       20, current_date - 30, 5, 0);

-- ===== Entrada 2 · pedidos antigos, com itens e pagamento =====
-- Frete: por UF; grátis se o pedido (já com desconto) chega a R$ 300. O endereço é copiado para o pedido.
INSERT INTO pedido (cliente_id, status, criado_em, fechado_em, enviado_em, entregue_em, cupom_id,
                    dest_logradouro, dest_numero, dest_cidade, dest_uf, dest_cep, subtotal, desconto, frete, total)
SELECT c.id, k.status, now() - k.dias * interval '1 day', now() - k.dias * interval '1 day',
       CASE WHEN k.status IN ('enviado', 'entregue') THEN now() - (k.dias - 1) * interval '1 day' END,
       CASE WHEN k.status = 'entregue' THEN now() - (k.dias - 3) * interval '1 day' END,
       (SELECT id FROM cupom WHERE codigo = k.cupom),
       e.logradouro, e.numero, e.cidade, e.uf, e.cep, k.subtotal, k.desconto, k.frete, k.subtotal - k.desconto + k.frete
FROM (VALUES
    ('Marcos Dias', 'Rua das Flores', 30, 'entregue', 'PROMO10', 410, 41,  0),
    ('Luana Reis',  'Rua do Mar',      20, 'entregue', NULL,      220,  0, 30),
    ('Pedro Alves', 'Rua da Serra',    10, 'enviado',  'PROMO10', 320, 32, 35)
) AS k (cliente, logr, dias, status, cupom, subtotal, desconto, frete)
JOIN cliente c ON c.nome = k.cliente
JOIN endereco e ON e.cliente_id = c.id AND e.logradouro = k.logr;

INSERT INTO item_pedido (pedido_id, produto_id, quantidade, preco_unitario)
SELECT (SELECT p.id FROM pedido p JOIN cliente c ON c.id = p.cliente_id WHERE c.nome = i.cliente AND p.criado_em::date = current_date - i.dias),
       (SELECT id FROM produto WHERE sku = i.sku), i.qtd, i.preco
FROM (VALUES
    ('Marcos Dias', 30, 'TEC-001',  1, 250), ('Marcos Dias', 30, 'MOU-001', 2, 80),
    ('Luana Reis',  20, 'SSD-240',  1, 220),
    ('Pedro Alves', 10, 'CAB-HDMI', 4, 30),  ('Pedro Alves', 10, 'RAM-008', 1, 200)
) AS i (cliente, dias, sku, qtd, preco);

INSERT INTO pagamento (pedido_id, forma, valor, pago_em)
SELECT p.id, g.forma, p.total, p.criado_em + interval '1 hour'
FROM (VALUES ('Marcos Dias', 30, 'pix'), ('Luana Reis', 20, 'cartao'), ('Pedro Alves', 10, 'boleto')) AS g (cliente, dias, forma)
JOIN cliente c ON c.nome = g.cliente
JOIN pedido p ON p.cliente_id = c.id AND p.criado_em::date = current_date - g.dias;

-- baixa do estoque dos pedidos fechados
UPDATE produto SET estoque = estoque - b.qtd FROM (VALUES ('TEC-001', 1), ('MOU-001', 2), ('SSD-240', 1), ('CAB-HDMI', 4), ('RAM-008', 1)) AS b (sku, qtd)
WHERE produto.sku = b.sku;

-- ===== Entrada 3 · reajuste do teclado (250 -> 280, desde 5 dias atrás) e mudança de endereço =====
INSERT INTO preco_produto (produto_id, preco, vigencia_inicio)
VALUES ((SELECT id FROM produto WHERE sku = 'TEC-001'), 280, current_date - 5);

-- O Marcos corrigiu o número da casa: de 100 para 120. Os pedidos antigos continuam com o endereço que usaram.
UPDATE endereco SET numero = '120'
WHERE cliente_id = (SELECT id FROM cliente WHERE nome = 'Marcos Dias') AND logradouro = 'Rua das Flores';

-- ===== Entrada 4 · pedidos recentes, avaliações =====
INSERT INTO pedido (cliente_id, status, criado_em, fechado_em, cupom_id,
                    dest_logradouro, dest_numero, dest_cidade, dest_uf, dest_cep, subtotal, desconto, frete, total)
SELECT c.id, k.status, now() - k.dias * interval '1 day', now() - k.dias * interval '1 day', NULL,
       e.logradouro, e.numero, e.cidade, e.uf, e.cep, k.subtotal, 0, k.frete, k.subtotal + k.frete
FROM (VALUES
    ('Marcos Dias', 'Rua das Flores', 3, 'pago',                 480,  0),
    ('Tiago Neves', 'Rua do Porto',   2, 'aguardando_pagamento', 310,  0),
    ('Luana Reis',  'Rua do Mar',     1, 'cancelado',            220, 30),
    ('Sara Lima',   'Rua Nova',       0, 'aguardando_pagamento',  60, 20)    -- este será o pedido lançado por engano
) AS k (cliente, logr, dias, status, subtotal, frete)
JOIN cliente c ON c.nome = k.cliente
JOIN endereco e ON e.cliente_id = c.id AND e.logradouro = k.logr;

INSERT INTO item_pedido (pedido_id, produto_id, quantidade, preco_unitario)
SELECT (SELECT p.id FROM pedido p JOIN cliente c ON c.id = p.cliente_id WHERE c.nome = i.cliente AND p.criado_em::date = current_date - i.dias),
       (SELECT id FROM produto WHERE sku = i.sku), i.qtd, i.preco
FROM (VALUES
    ('Marcos Dias', 3, 'RAM-008',  2, 200), ('Marcos Dias', 3, 'MOU-001', 1, 80),
    ('Tiago Neves', 2, 'TEC-001',  1, 280), ('Tiago Neves', 2, 'CAB-HDMI', 1, 30),
    ('Luana Reis',  1, 'SSD-240',  1, 220),
    ('Sara Lima',   0, 'CAB-HDMI', 2, 30)
) AS i (cliente, dias, sku, qtd, preco);

INSERT INTO pagamento (pedido_id, forma, valor, pago_em)
SELECT p.id, 'pix', p.total, p.criado_em + interval '1 hour'
FROM pedido p JOIN cliente c ON c.id = p.cliente_id WHERE c.nome = 'Marcos Dias' AND p.status = 'pago';

-- baixa do estoque: pagos e aguardando pagamento (o cancelado da Luana baixa e devolve: sem efeito final)
UPDATE produto SET estoque = estoque - b.qtd FROM (VALUES ('RAM-008', 2), ('MOU-001', 1), ('TEC-001', 1), ('CAB-HDMI', 3)) AS b (sku, qtd)
WHERE produto.sku = b.sku;

INSERT INTO avaliacao (cliente_id, produto_id, nota, comentario)
SELECT (SELECT id FROM cliente WHERE nome = a.cliente), (SELECT id FROM produto WHERE sku = a.sku), a.nota, a.coment
FROM (VALUES
    ('Marcos Dias', 'TEC-001', 5, 'Ótimo teclado'), ('Marcos Dias', 'MOU-001', 4, 'Bom'),
    ('Luana Reis',  'SSD-240', 4, 'Rápido'),        ('Pedro Alves', 'RAM-008', 3, 'Funciona')
) AS a (cliente, sku, nota, coment);

-- ===== Entrada 5 · o pedido da Sara Lima foi criado por engano: sai com os itens e o estoque volta =====
DELETE FROM item_pedido WHERE pedido_id = (SELECT p.id FROM pedido p JOIN cliente c ON c.id = p.cliente_id WHERE c.nome = 'Sara Lima');
DELETE FROM pedido WHERE cliente_id = (SELECT id FROM cliente WHERE nome = 'Sara Lima');
-- a baixa da Entrada 4 descontou 2 cabos do pedido da Sara: devolve
UPDATE produto SET estoque = estoque + 2 WHERE sku = 'CAB-HDMI';
