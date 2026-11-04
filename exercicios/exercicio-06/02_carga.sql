-- Projeto 3 · Loja virtual · 02_carga.sql (prova 1)
-- 30 produtos em 5 categorias (alguns com dois preços ao longo do tempo), 40 clientes com 60 endereços,
-- 8 cupons (válido, vencido, esgotado, no último uso), 120 pedidos em todos os status, com itens e pagamentos.
-- Casos para exercitar as regras: produto 30 com 1 unidade em estoque; 5 pedidos aguardando pagamento há mais de
-- 48 horas (pedidos 1, 13, 25, 37 e 49); cupom ULTIMO30 no último uso; cupom ESGOTADO5 sem usos restantes.
-- Os dados são fictícios; as datas são relativas a agora.
SET search_path TO loja;

INSERT INTO categoria (nome) VALUES
    ('Periféricos'), ('Componentes'), ('Cabos e adaptadores'), ('Armazenamento'), ('Gadgets');

-- 30 produtos (6 por categoria); a especificação muda conforme a categoria (JSONB)
INSERT INTO produto (sku, nome, categoria_id, especificacoes)
SELECT 'SKU-' || LPAD(g::text, 4, '0'),
       (ARRAY['Teclado', 'Mouse', 'Headset', 'Monitor', 'Webcam', 'Mousepad',
              'Memória RAM', 'SSD interno', 'Placa de vídeo', 'Fonte', 'Cooler', 'Placa-mãe',
              'Cabo HDMI', 'Cabo USB-C', 'Adaptador VGA', 'Hub USB', 'Cabo de rede', 'Carregador',
              'Pen drive', 'HD externo', 'Cartão SD', 'SSD portátil', 'Gaveta HD', 'NAS pessoal',
              'Smartwatch', 'Caixa de som', 'Fone Bluetooth', 'Carregador sem fio', 'Power bank', 'Ring light'])[g]
           || ' ' || (ARRAY['Pro', 'Plus', 'Lite', 'Max'])[1 + g % 4],
       1 + (g - 1) / 6,
       jsonb_build_object(
           'marca', (ARRAY['Alfa', 'Beta', 'Gama', 'Delta', 'Ômega'])[1 + g % 5],
           'cor', (ARRAY['preto', 'branco', 'cinza', 'azul'])[1 + g % 4],
           'garantia_meses', (ARRAY[6, 12, 12, 24, 36])[1 + g % 5],
           'dimensoes_mm', jsonb_build_object('largura', 50 + g * 7, 'altura', 20 + g * 3, 'profundidade', 30 + g * 4))
       || CASE WHEN g <= 6 THEN jsonb_build_object('conexao', (ARRAY['USB', 'Bluetooth', 'USB', 'Bluetooth', 'USB', 'USB'])[g])
               WHEN g <= 12 THEN jsonb_build_object('voltagem', (ARRAY['bivolt', '110V', '220V', 'bivolt'])[1 + g % 4],
                                                    'capacidade_gb', (ARRAY[8, 16, 32, 512, 1024, 2048])[1 + g % 6])
               WHEN g <= 18 THEN jsonb_build_object('comprimento_m', (ARRAY[1, 1.5, 2, 3, 5])[1 + g % 5])
               WHEN g <= 24 THEN jsonb_build_object('capacidade_gb', (ARRAY[32, 64, 128, 500, 1000, 2000])[1 + g % 6],
                                                    'voltagem', 'bivolt')
               ELSE jsonb_build_object('voltagem', (ARRAY['bivolt', '110V', '220V'])[1 + g % 3],
                                       'bateria_mah', 1000 + g * 150) END
FROM generate_series(1, 30) AS g;

-- preço inicial de todos os produtos; os de código múltiplo de 4 sobem 10% há 60 dias
INSERT INTO preco_produto (produto_id, preco, vigencia_inicio)
SELECT id, ROUND((10 + (id * 37) % 90) * (ARRAY[3, 6, 1, 3, 2])[categoria_id] + 0.90, 2), TIMESTAMP '2025-01-01'
FROM produto;
INSERT INTO preco_produto (produto_id, preco, vigencia_inicio)
SELECT pp.produto_id, ROUND(pp.preco * 1.10, 2), date_trunc('minute', LOCALTIMESTAMP) - interval '60 days'
FROM preco_produto pp WHERE pp.produto_id % 4 = 0;

-- 40 clientes, 60 endereços (os clientes 1 a 20 têm dois)
INSERT INTO cliente (nome, email, cpf)
SELECT 'Cliente ' || LPAD(g::text, 2, '0'), 'cliente' || LPAD(g::text, 2, '0') || '@exemplo.test',
       LPAD((11111111000 + g * 7919)::text, 11, '0')
FROM generate_series(1, 40) AS g;

INSERT INTO frete_uf (uf, valor) VALUES
    ('SP', 15), ('RJ', 20), ('MG', 22), ('PR', 25), ('RS', 30), ('BA', 35), ('PE', 38), ('DF', 28);

INSERT INTO endereco (cliente_id, logradouro, numero, cidade, uf, cep)
SELECT c.id, 'Rua ' || (ARRAY['das Flores', 'do Comércio', 'Central', 'Nova', 'das Palmeiras'])[1 + (c.id + n) % 5],
       (10 + c.id * 3 + n)::text,
       (ARRAY['São Paulo', 'Rio de Janeiro', 'Belo Horizonte', 'Curitiba', 'Porto Alegre', 'Salvador', 'Recife', 'Brasília'])[1 + (c.id + n) % 8],
       (ARRAY['SP', 'RJ', 'MG', 'PR', 'RS', 'BA', 'PE', 'DF'])[1 + (c.id + n) % 8],
       LPAD((1000000 + c.id * 311 + n)::text, 8, '0')
FROM cliente c CROSS JOIN LATERAL generate_series(0, CASE WHEN c.id <= 20 THEN 1 ELSE 0 END) AS n;

INSERT INTO cupom (codigo, tipo, valor, valido_ate, limite_usos, valor_minimo) VALUES
    ('BEMVINDO10', 'percentual', 10, CURRENT_DATE + 90, 1000,   0),
    ('FRETE50',    'fixo',       50, CURRENT_DATE + 60,  100, 200),
    ('NATAL20',    'percentual', 20, CURRENT_DATE + 90,   50, 150),
    ('VENCIDO15',  'percentual', 15, CURRENT_DATE - 30,  100,   0),
    ('ESGOTADO5',  'fixo',        5, CURRENT_DATE + 30,    3,   0),
    ('ULTIMO30',   'percentual', 30, CURRENT_DATE + 30,    5,   0),
    ('MINIMO500',  'fixo',      100, CURRENT_DATE + 30,   20, 500),
    ('VIP25',      'percentual', 25, CURRENT_DATE + 45,   20,  80);

-- 120 pedidos. Status pelo resto de i por 12: 0 carrinho, 1 aguardando pagamento, 2-4 pago, 5-6 enviado,
-- 7-10 entregue, 11 cancelado. Cupons: ESGOTADO5 nos pedidos 14, 15 e 26; ULTIMO30 em 38 a 41 (4 de 5 usos);
-- BEMVINDO10 nos demais múltiplos de 7 que não são carrinho nem aguardando.
INSERT INTO pedido (cliente_id, status, criado_em, fechado_em, enviado_em, entregue_em, cupom_id,
                    dest_logradouro, dest_numero, dest_cidade, dest_uf, dest_cep)
SELECT b.cliente_id, b.status, b.criado_em,
       CASE WHEN b.status <> 'carrinho' THEN b.criado_em + interval '1 hour' END,
       CASE WHEN b.status IN ('enviado', 'entregue') THEN b.criado_em + interval '1 day' END,
       CASE WHEN b.status = 'entregue' THEN b.criado_em + interval '4 days' END,
       CASE WHEN b.i IN (14, 15, 26) THEN 5
            WHEN b.i BETWEEN 38 AND 41 THEN 6
            WHEN b.i % 7 = 0 AND b.status NOT IN ('carrinho', 'aguardando_pagamento') THEN 1 END,
       e.logradouro, e.numero, e.cidade, e.uf, e.cep
FROM (
    SELECT i, 1 + (i % 40) AS cliente_id,
           s.status,
           CASE
               WHEN s.status = 'carrinho' THEN date_trunc('minute', LOCALTIMESTAMP) - (i / 12) * interval '3 hours'
               WHEN s.status = 'aguardando_pagamento' AND i > 60
                    THEN date_trunc('minute', LOCALTIMESTAMP) - (2 + (i - 60) / 12 * 4) * interval '1 hour'
               WHEN s.status = 'enviado' THEN date_trunc('minute', LOCALTIMESTAMP) - (1 + i / 12) * interval '1 day'
               ELSE date_trunc('minute', LOCALTIMESTAMP) - (130 - i) * interval '19 hours'
           END AS criado_em
    FROM generate_series(1, 120) AS i
    CROSS JOIN LATERAL (SELECT (ARRAY['carrinho', 'aguardando_pagamento', 'pago', 'pago', 'pago', 'enviado', 'enviado',
                                      'entregue', 'entregue', 'entregue', 'entregue', 'cancelado'])[1 + i % 12] AS status) s
) b
CROSS JOIN LATERAL (SELECT * FROM endereco WHERE cliente_id = b.cliente_id ORDER BY id LIMIT 1) e
ORDER BY b.i;

-- itens: 1 a 3 por pedido, com o preço vigente na data do pedido
INSERT INTO item_pedido (pedido_id, produto_id, quantidade, preco_unitario)
SELECT p.id, pr.id, 1 + (p.id + k) % 3, pv.preco
FROM pedido p
CROSS JOIN LATERAL generate_series(1, 1 + p.id % 3) AS k
JOIN produto pr ON pr.id = 1 + ((p.id * 7 + k * 11) % 28)   -- os produtos 29 e 30 nunca foram vendidos
CROSS JOIN LATERAL (SELECT preco FROM preco_produto
                    WHERE produto_id = pr.id AND vigencia_inicio <= p.criado_em
                    ORDER BY vigencia_inicio DESC LIMIT 1) pv;

-- totais dos pedidos fechados: subtotal, desconto do cupom, frete (grátis a partir de R$ 300 já com desconto)
UPDATE pedido p
SET subtotal = x.subtotal, desconto = x.desconto,
    frete = CASE WHEN x.subtotal - x.desconto >= 300 THEN 0 ELSE f.valor END,
    total = x.subtotal - x.desconto + CASE WHEN x.subtotal - x.desconto >= 300 THEN 0 ELSE f.valor END
FROM (
    SELECT p2.id, s.subtotal,
           CASE WHEN c.id IS NULL THEN 0   -- cuidado: LEAST ignora NULL, então sem cupom daria desconto = subtotal
                WHEN c.tipo = 'percentual' THEN ROUND(s.subtotal * c.valor / 100, 2)
                ELSE LEAST(c.valor, s.subtotal) END AS desconto
    FROM pedido p2
    CROSS JOIN LATERAL (SELECT SUM(quantidade * preco_unitario) AS subtotal FROM item_pedido WHERE pedido_id = p2.id) s
    LEFT JOIN cupom c ON c.id = p2.cupom_id
    WHERE p2.status <> 'carrinho'
) x, frete_uf f
WHERE p.id = x.id AND f.uf = p.dest_uf;

-- pagamentos dos pedidos pagos, enviados e entregues
INSERT INTO pagamento (pedido_id, forma, valor, pago_em)
SELECT id, (ARRAY['pix', 'cartao', 'boleto'])[1 + id % 3], total, fechado_em + interval '2 hours'
FROM pedido WHERE status IN ('pago', 'enviado', 'entregue');

-- estoque: entrada inicial de 200 unidades por produto, saída de cada pedido fechado e estorno dos cancelados
INSERT INTO movimento_estoque (produto_id, tipo, quantidade, criado_em)
SELECT id, 'entrada', 200, TIMESTAMP '2025-01-01' FROM produto;
INSERT INTO movimento_estoque (produto_id, tipo, quantidade, pedido_id, criado_em)
SELECT i.produto_id, 'saida', -i.quantidade, p.id, p.fechado_em
FROM item_pedido i JOIN pedido p ON p.id = i.pedido_id WHERE p.status <> 'carrinho';
INSERT INTO movimento_estoque (produto_id, tipo, quantidade, pedido_id, criado_em)
SELECT i.produto_id, 'estorno', i.quantidade, p.id, p.fechado_em + interval '1 day'
FROM item_pedido i JOIN pedido p ON p.id = i.pedido_id WHERE p.status = 'cancelado';
-- o produto 30 fica com 1 unidade (caso de teste da última unidade)
INSERT INTO movimento_estoque (produto_id, tipo, quantidade)
SELECT 30, 'ajuste', 1 - SUM(quantidade) FROM movimento_estoque WHERE produto_id = 30;
UPDATE produto p SET estoque = m.saldo
FROM (SELECT produto_id, SUM(quantidade) AS saldo FROM movimento_estoque GROUP BY produto_id) m
WHERE m.produto_id = p.id;

-- avaliações de quem recebeu o produto: uma por cliente e produto
INSERT INTO avaliacao (cliente_id, produto_id, nota, comentario, criada_em)
SELECT DISTINCT ON (p.cliente_id, i.produto_id)
       p.cliente_id, i.produto_id, 1 + (p.id + i.produto_id) % 5,
       (ARRAY['Chegou rápido.', 'Bom custo-benefício.', 'Esperava mais.', 'Excelente!', NULL])[1 + p.id % 5],
       p.entregue_em + interval '2 days'
FROM pedido p JOIN item_pedido i ON i.pedido_id = p.id
WHERE p.status = 'entregue' AND p.id % 2 = 0
ORDER BY p.cliente_id, i.produto_id, p.id;
