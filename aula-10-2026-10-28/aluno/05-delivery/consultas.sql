-- Delivery de comida · consultas.sql
-- As 16 consultas de validação (C1 a C16), depois das 5 entradas. Só leem: não alteram o banco.
-- «Hoje» é current_date. Datas aparecem como «dias atrás».
SET search_path TO delivery;

-- C1 · Quantos pedidos, restaurantes e clientes existem
SELECT (SELECT count(*) FROM pedido) AS pedidos, (SELECT count(*) FROM restaurante) AS restaurantes, (SELECT count(*) FROM cliente) AS clientes;

-- C2 · Quantos pedidos em cada situação
SELECT status, count(*) AS pedidos FROM pedido GROUP BY status ORDER BY pedidos DESC, status;

-- C3 · Pizza Margherita: preço cobrado em cada pedido (dias atrás) e preço de hoje
SELECT current_date - p.criado_em::date AS dias_atras, i.preco_unitario AS preco_cobrado,
       (SELECT pi.preco FROM preco_item pi WHERE pi.item_id = ic.id AND pi.vigencia_inicio <= now() ORDER BY pi.vigencia_inicio DESC LIMIT 1) AS preco_hoje
FROM item_pedido i JOIN item_cardapio ic ON ic.id = i.item_id JOIN pedido p ON p.id = i.pedido_id
WHERE ic.nome = 'Pizza Margherita' ORDER BY p.criado_em;

-- C4 · Pedidos entregues com atraso: restaurante e minutos de atraso
SELECT r.nome, ROUND(EXTRACT(EPOCH FROM (p.entregue_em - p.prometido_ate)) / 60) AS minutos_atraso
FROM pedido p JOIN restaurante r ON r.id = p.restaurante_id WHERE p.entregue_em > p.prometido_ate;

-- C5 · Todos os pedidos: dias atrás, cliente, restaurante, distância, subtotal, taxa de entrega e total
SELECT current_date - p.criado_em::date AS dias_atras, c.nome AS cliente, r.nome AS restaurante, p.dest_distancia_km AS km, p.subtotal, p.taxa_entrega, p.total
FROM pedido p JOIN cliente c ON c.id = p.cliente_id JOIN restaurante r ON r.id = p.restaurante_id ORDER BY p.criado_em, c.nome;

-- C6 · Por restaurante, nos pedidos entregues: itens vendidos, comissão da plataforma (pela comissão do dia do pedido) e repasse
SELECT r.nome, COALESCE(SUM(p.subtotal), 0) AS itens, COALESCE(ROUND(SUM(p.subtotal * p.comissao_pct / 100), 2), 0) AS comissao,
       COALESCE(SUM(p.subtotal) - ROUND(SUM(p.subtotal * p.comissao_pct / 100), 2), 0) AS repasse
FROM restaurante r LEFT JOIN pedido p ON p.restaurante_id = r.id AND p.status = 'entregue' GROUP BY r.nome ORDER BY r.nome;

-- C7 · Restaurantes sem nenhum pedido
SELECT r.nome FROM restaurante r WHERE NOT EXISTS (SELECT 1 FROM pedido p WHERE p.restaurante_id = r.id);

-- C8 · Itens do cardápio indisponíveis
SELECT r.nome AS restaurante, ic.nome AS item FROM item_cardapio ic JOIN restaurante r ON r.id = ic.restaurante_id WHERE NOT ic.disponivel;

-- C9 · Horários que passam da meia-noite (fecha depois de abrir no dia seguinte)
SELECT r.nome, h.dia_semana, h.abre, h.fecha FROM horario_funcionamento h JOIN restaurante r ON r.id = h.restaurante_id WHERE h.fecha < h.abre;

-- C10 · Histórico de status do pedido do Rafa Gomes na Pizzaria Forno: de, para e minutos desde o início
SELECT hs.status_antes, hs.status_depois,
       ROUND(EXTRACT(EPOCH FROM (hs.quando - (SELECT min(x.quando) FROM historico_status x WHERE x.pedido_id = hs.pedido_id))) / 60) AS minutos
FROM historico_status hs JOIN pedido p ON p.id = hs.pedido_id JOIN cliente c ON c.id = p.cliente_id JOIN restaurante r ON r.id = p.restaurante_id
WHERE c.nome = 'Rafa Gomes' AND r.nome = 'Pizzaria Forno' ORDER BY hs.quando;

-- C11 · Por entregador: situação atual, entregas concluídas e desistências (todo entregador aparece)
SELECT e.nome, e.status, count(g.id) FILTER (WHERE g.status = 'concluida') AS concluidas, count(g.id) FILTER (WHERE g.status = 'desistiu') AS desistencias
FROM entregador e LEFT JOIN entrega g ON g.entregador_id = e.id GROUP BY e.nome, e.status ORDER BY e.nome;

-- C12 · Itens de pedido com observação: pedido (cliente), item e observação
SELECT c.nome, ic.nome AS item, ip.opcoes ->> 'obs' AS observacao
FROM item_pedido ip JOIN pedido p ON p.id = ip.pedido_id JOIN cliente c ON c.id = p.cliente_id JOIN item_cardapio ic ON ic.id = ip.item_id
WHERE ip.opcoes ->> 'obs' IS NOT NULL;

-- C13 · Média das notas do restaurante (todo restaurante aparece)
SELECT r.nome, ROUND(AVG(a.nota_restaurante), 1) AS media, count(a.id) AS avaliacoes
FROM restaurante r LEFT JOIN pedido p ON p.restaurante_id = r.id LEFT JOIN avaliacao a ON a.pedido_id = p.id
GROUP BY r.nome ORDER BY media DESC NULLS LAST, r.nome;

-- C14 · Pedidos cancelados: cliente, restaurante, quem cancelou e quanto foi cobrado
SELECT c.nome, r.nome AS restaurante, p.cancelado_por, p.cobranca_cancelamento
FROM pedido p JOIN cliente c ON c.id = p.cliente_id JOIN restaurante r ON r.id = p.restaurante_id WHERE p.status = 'cancelado';

-- C15 · Pedidos do Rafa Gomes: endereço usado em cada um e o endereço dele hoje na Rua A
SELECT current_date - p.criado_em::date AS dias_atras, p.dest_logradouro || ' ' || p.dest_numero AS endereco_usado,
       (SELECT e.logradouro || ' ' || e.numero FROM endereco e WHERE e.cliente_id = c.id AND e.logradouro = 'Rua A') AS rua_a_hoje
FROM pedido p JOIN cliente c ON c.id = p.cliente_id WHERE c.nome = 'Rafa Gomes' ORDER BY p.criado_em;

-- C16 · Pagamentos por forma: quantidade e valor
SELECT forma, count(*) AS pagamentos, SUM(valor) AS total FROM pagamento GROUP BY forma ORDER BY total DESC;
