-- Loja virtual · consultas.sql
-- As 16 consultas de validação (C1 a C16), depois das 5 entradas. Só leem: não alteram o banco.
-- «Hoje» é current_date. Datas aparecem como «dias atrás».
SET search_path TO loja;

-- C1 · Quantos pedidos, produtos e clientes existem
SELECT (SELECT count(*) FROM pedido) AS pedidos, (SELECT count(*) FROM produto) AS produtos, (SELECT count(*) FROM cliente) AS clientes;

-- C2 · Quantos pedidos em cada situação
SELECT status, count(*) AS pedidos FROM pedido GROUP BY status ORDER BY pedidos DESC, status;

-- C3 · Estoque atual de cada produto
SELECT nome, estoque FROM produto ORDER BY nome;

-- C4 · Produtos que nunca apareceram em nenhum pedido
SELECT p.nome FROM produto p WHERE NOT EXISTS (SELECT 1 FROM item_pedido i WHERE i.produto_id = p.id);

-- C5 · Teclado Mecânico: preço pago em cada pedido (dias atrás) e preço de hoje
SELECT current_date - p.criado_em::date AS dias_atras, i.preco_unitario AS preco_pago,
       (SELECT pp.preco FROM preco_produto pp WHERE pp.produto_id = pr.id AND pp.vigencia_inicio <= now() ORDER BY pp.vigencia_inicio DESC LIMIT 1) AS preco_hoje
FROM item_pedido i JOIN produto pr ON pr.id = i.produto_id JOIN pedido p ON p.id = i.pedido_id
WHERE pr.nome = 'Teclado Mecânico' ORDER BY p.criado_em;

-- C6 · Total de cada pedido: dias atrás, cliente, subtotal, desconto, frete e total
SELECT current_date - p.criado_em::date AS dias_atras, c.nome, p.subtotal, p.desconto, p.frete, p.total
FROM pedido p JOIN cliente c ON c.id = p.cliente_id ORDER BY p.criado_em;

-- C7 · Faturamento: soma do total dos pedidos pagos, enviados e entregues
SELECT SUM(total) AS faturamento FROM pedido WHERE status IN ('pago', 'enviado', 'entregue');

-- C8 · Unidades vendidas por categoria (pedidos pagos, enviados e entregues; toda categoria aparece)
SELECT c.nome, COALESCE(SUM(i.quantidade) FILTER (WHERE p.status IN ('pago', 'enviado', 'entregue')), 0) AS unidades
FROM categoria c LEFT JOIN produto pr ON pr.categoria_id = c.id LEFT JOIN item_pedido i ON i.produto_id = pr.id LEFT JOIN pedido p ON p.id = i.pedido_id
GROUP BY c.nome ORDER BY unidades DESC, c.nome;

-- C9 · Produtos mais vendidos em unidades (pedidos pagos, enviados e entregues; todos aparecem; empate em ordem alfabética)
SELECT pr.nome, COALESCE(SUM(i.quantidade) FILTER (WHERE p.status IN ('pago', 'enviado', 'entregue')), 0) AS unidades
FROM produto pr LEFT JOIN item_pedido i ON i.produto_id = pr.id LEFT JOIN pedido p ON p.id = i.pedido_id
GROUP BY pr.nome ORDER BY unidades DESC, pr.nome;

-- C10 · Pedidos com frete grátis
SELECT current_date - p.criado_em::date AS dias_atras, c.nome, p.total
FROM pedido p JOIN cliente c ON c.id = p.cliente_id WHERE p.frete = 0 ORDER BY p.criado_em;

-- C11 · Pedidos do Marcos Dias: dias atrás, endereço de entrega usado, e o endereço dele hoje
SELECT current_date - p.criado_em::date AS dias_atras, p.dest_logradouro || ', ' || p.dest_numero AS entregue_em,
       (SELECT e.logradouro || ', ' || e.numero FROM endereco e WHERE e.cliente_id = c.id AND e.logradouro = 'Rua das Flores') AS endereco_hoje
FROM pedido p JOIN cliente c ON c.id = p.cliente_id WHERE c.nome = 'Marcos Dias' ORDER BY p.criado_em;

-- C12 · Cupons: quantos usos válidos (pedidos não cancelados) e o limite
SELECT cp.codigo, count(p.id) FILTER (WHERE p.status <> 'cancelado') AS usos, cp.limite_usos AS limite
FROM cupom cp LEFT JOIN pedido p ON p.cupom_id = cp.id GROUP BY cp.codigo, cp.limite_usos ORDER BY cp.codigo;

-- C13 · Pedidos que usaram cupom: cliente, cupom e desconto
SELECT c.nome, cp.codigo, p.desconto FROM pedido p JOIN cliente c ON c.id = p.cliente_id JOIN cupom cp ON cp.id = p.cupom_id ORDER BY p.criado_em;

-- C14 · Clientes que nunca fizeram um pedido
SELECT c.nome FROM cliente c WHERE NOT EXISTS (SELECT 1 FROM pedido p WHERE p.cliente_id = c.id);

-- C15 · Média das notas por produto (todo produto aparece; sem avaliação fica vazio)
SELECT pr.nome, ROUND(AVG(a.nota), 1) AS media, count(a.id) AS avaliacoes
FROM produto pr LEFT JOIN avaliacao a ON a.produto_id = pr.id GROUP BY pr.nome ORDER BY media DESC NULLS LAST, pr.nome;

-- C16 · Pagamentos por forma: quantidade e valor total
SELECT forma, count(*) AS pagamentos, SUM(valor) AS total FROM pagamento GROUP BY forma ORDER BY total DESC;
