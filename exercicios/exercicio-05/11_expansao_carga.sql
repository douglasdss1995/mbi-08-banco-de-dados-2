-- Projeto 3 · Loja virtual · 11_expansao_carga.sql (expansão)
-- Dados dos módulos novos, em fase com a carga da base (pedidos 1 a 120). Rode depois do 10_expansao_ddl.sql.
-- Para repetir, rode tudo de novo a partir de 01_ddl.sql (rodar só este arquivo de novo dá erro).
-- Casos para exercitar as regras:
--   Compras:   10 compras recebidas, 2 enviadas, 2 abertas, 1 cancelada; cerca de 1 em cada 3 produtos abaixo do estoque mínimo.
--   Entregas:  uma remessa para cada pedido enviado ou entregue; remessas enviadas e já vencidas; entregas fora do prazo.
--   Financeiro: parcelas a receber (algumas em 3x no cartão) e contas a pagar (compras, comissões, estornos).
--   Equipe:    8 funcionários (uma vendedora inativa), pedidos com vendedor, comissões fechadas até dois meses atrás
--              (o mês passado fica sem comissão fechada).
--   Devolução: 3 devoluções antigas (2 concluídas e 1 recusada).
--   Fidelidade: pontos de todos os pedidos pagos, 3 níveis, 2 resgates que viraram cupom.
-- Os dados são fictícios; as datas são relativas a agora.
SET search_path TO loja;

-- ===== Módulo 1 · Compras e fornecedores =====
INSERT INTO fornecedor (nome, cnpj, email, prazo_entrega_dias) VALUES
    ('Alfa Distribuidora',  '10000000000101', 'vendas@alfa.exemplo.test',   3),
    ('Beta Importadora',    '10000000000202', 'vendas@beta.exemplo.test',   7),
    ('Gama Atacado',        '10000000000303', 'vendas@gama.exemplo.test',   5),
    ('Delta Tech',          '10000000000404', 'vendas@delta.exemplo.test',  10),
    ('Ômega Componentes',   '10000000000505', 'vendas@omega.exemplo.test',  4);

-- cada produto tem dois fornecedores: o principal (fornecedor 1 + id % 5, custo de 60% do preço inicial)
-- e o secundário (custo de 66%)
INSERT INTO produto_fornecedor (produto_id, fornecedor_id, custo_unitario)
SELECT p.id, 1 + p.id % 5, ROUND(pp.preco * 0.60, 2)
FROM produto p JOIN preco_produto pp ON pp.produto_id = p.id AND pp.vigencia_inicio = TIMESTAMP '2025-01-01';
INSERT INTO produto_fornecedor (produto_id, fornecedor_id, custo_unitario)
SELECT p.id, 1 + (p.id + 2) % 5, ROUND(pp.preco * 0.66, 2)
FROM produto p JOIN preco_produto pp ON pp.produto_id = p.id AND pp.vigencia_inicio = TIMESTAMP '2025-01-01';

-- 15 compras: 1 a 10 recebidas (de 92 a 20 dias atrás), 11 e 12 enviadas, 13 e 14 abertas, 15 cancelada
-- previsão = data da compra + prazo do fornecedor; as recebidas chegaram 1 dia depois do previsto
INSERT INTO pedido_compra (fornecedor_id, status, criado_em, previsto_para, recebido_em)
SELECT f.id, s.status, c.criado_em, (c.criado_em + f.prazo_entrega_dias * interval '1 day')::date,
       CASE WHEN s.status = 'recebido'
            THEN (c.criado_em + (f.prazo_entrega_dias + 1) * interval '1 day')::date + time '10:00' END
FROM generate_series(1, 15) AS g
CROSS JOIN LATERAL (SELECT CASE WHEN g <= 10 THEN 'recebido' WHEN g <= 12 THEN 'enviado'
                                WHEN g <= 14 THEN 'aberto' ELSE 'cancelado' END AS status) s
CROSS JOIN LATERAL (SELECT CASE s.status
                        WHEN 'recebido' THEN date_trunc('minute', LOCALTIMESTAMP) - (100 - g * 8) * interval '1 day'
                        WHEN 'enviado'  THEN date_trunc('minute', LOCALTIMESTAMP) - interval '3 days'
                        WHEN 'aberto'   THEN date_trunc('minute', LOCALTIMESTAMP) - interval '1 day'
                        ELSE date_trunc('minute', LOCALTIMESTAMP) - interval '40 days' END AS criado_em) c
JOIN fornecedor f ON f.id = 1 + g % 5
ORDER BY g;

-- itens: 3 produtos do fornecedor principal, nunca o produto 30 (ele é o caso de «última unidade»)
INSERT INTO item_pedido_compra (pedido_compra_id, produto_id, quantidade, custo_unitario)
SELECT pc.id, x.produto_id, 30 + (pc.id * 7 + x.produto_id * 3) % 50, pf.custo_unitario
FROM pedido_compra pc
CROSS JOIN LATERAL (SELECT p.id AS produto_id FROM produto p
                    WHERE 1 + p.id % 5 = pc.fornecedor_id AND p.id <> 30
                    ORDER BY p.id OFFSET (pc.id / 5) % 3 LIMIT 3) x
JOIN produto_fornecedor pf ON pf.produto_id = x.produto_id AND pf.fornecedor_id = pc.fornecedor_id;

-- as compras ainda não recebidas já saem com o reajuste de 10% que os fornecedores aplicaram (o custo médio vai subir ao receber)
UPDATE item_pedido_compra i SET custo_unitario = ROUND(i.custo_unitario * 1.10, 2)
FROM pedido_compra pc WHERE pc.id = i.pedido_compra_id AND pc.status IN ('aberto', 'enviado');

-- entrada de estoque das compras recebidas
INSERT INTO movimento_estoque (produto_id, tipo, quantidade, pedido_compra_id, criado_em)
SELECT i.produto_id, 'entrada', i.quantidade, pc.id, pc.recebido_em
FROM item_pedido_compra i JOIN pedido_compra pc ON pc.id = i.pedido_compra_id WHERE pc.status = 'recebido';
UPDATE produto p SET estoque = estoque + e.qtd
FROM (SELECT produto_id, SUM(quantidade) AS qtd FROM movimento_estoque
      WHERE pedido_compra_id IS NOT NULL GROUP BY produto_id) e
WHERE e.produto_id = p.id;

-- custo médio: as 200 unidades iniciais custaram o do fornecedor principal; as compras recebidas, o custo da época
UPDATE produto p
SET custo_medio = ROUND((200 * pf.custo_unitario + COALESCE(c.valor, 0)) / (200 + COALESCE(c.qtd, 0)), 2)
FROM produto_fornecedor pf
LEFT JOIN (SELECT i.produto_id, SUM(i.quantidade) AS qtd, SUM(i.quantidade * i.custo_unitario) AS valor
           FROM item_pedido_compra i JOIN pedido_compra pc ON pc.id = i.pedido_compra_id
           WHERE pc.status = 'recebido' GROUP BY i.produto_id) c ON c.produto_id = pf.produto_id
WHERE pf.produto_id = p.id AND pf.fornecedor_id = 1 + p.id % 5;

-- estoque mínimo: a cada 3 produtos, 1 fica abaixo do mínimo (precisa repor); os outros ficam folgados
UPDATE produto SET estoque_minimo = CASE WHEN id % 3 = 0 THEN estoque + 15 + id % 20 ELSE 20 + (id * 7) % 40 END;

-- contas a pagar das compras recebidas: vencem 30 dias depois do recebimento e já estão pagas se venceram
INSERT INTO conta_pagar (categoria, descricao, valor, vencimento, pago_em, pedido_compra_id)
SELECT 'compra', 'Compra ' || pc.id || ' - ' || f.nome, SUM(i.quantidade * i.custo_unitario),
       (pc.recebido_em + interval '30 days')::date,
       CASE WHEN (pc.recebido_em + interval '30 days')::date <= CURRENT_DATE
            THEN (pc.recebido_em + interval '30 days')::date + time '09:00' END,
       pc.id
FROM pedido_compra pc
JOIN fornecedor f ON f.id = pc.fornecedor_id
JOIN item_pedido_compra i ON i.pedido_compra_id = pc.id
WHERE pc.status = 'recebido'
GROUP BY pc.id, f.nome, pc.recebido_em;

-- ===== Módulo 2 · Entregas e logística =====
INSERT INTO transportadora (nome, cnpj) VALUES
    ('TransExpress', '20000000000101'), ('LogMais', '20000000000202'), ('EntregaJá', '20000000000303');

INSERT INTO transportadora_uf (transportadora_id, uf, prazo_dias) VALUES
    (1, 'SP', 2), (1, 'RJ', 3), (1, 'MG', 3), (1, 'PR', 4), (1, 'RS', 5),
    (2, 'SP', 3), (2, 'RJ', 4), (2, 'MG', 4), (2, 'PR', 5), (2, 'RS', 6), (2, 'BA', 7), (2, 'PE', 8), (2, 'DF', 5),
    (3, 'SP', 4), (3, 'MG', 5), (3, 'DF', 3), (3, 'BA', 4), (3, 'PE', 5);

-- uma remessa para cada pedido enviado ou entregue: a transportadora mais rápida da UF
-- (nos pedidos de número múltiplo de 3, a segunda mais rápida, para variar)
INSERT INTO remessa (pedido_id, transportadora_id, codigo_rastreio, despachada_em, prazo_previsto)
SELECT p.id, t.transportadora_id, 'BR' || LPAD(p.id::text, 9, '0') || 'LJ', p.enviado_em,
       (p.enviado_em + t.prazo_dias * interval '1 day')::date
FROM pedido p
CROSS JOIN LATERAL (
    SELECT x.transportadora_id, x.prazo_dias
    FROM (SELECT tu.transportadora_id, tu.prazo_dias,
                 ROW_NUMBER() OVER (ORDER BY tu.prazo_dias, tu.transportadora_id) AS pos,
                 COUNT(*) OVER () AS total
          FROM transportadora_uf tu WHERE tu.uf = p.dest_uf) x
    WHERE x.pos = CASE WHEN p.id % 3 = 0 AND x.total > 1 THEN 2 ELSE 1 END
) t
WHERE p.id <= 120 AND p.status IN ('enviado', 'entregue');

-- eventos de rastreio: coletado, em trânsito (1 dia depois) e, nos entregues, saiu para entrega e entregue
INSERT INTO evento_remessa (remessa_id, tipo, local, ocorrido_em)
SELECT r.id, 'coletado', 'Depósito da loja', r.despachada_em FROM remessa r;
INSERT INTO evento_remessa (remessa_id, tipo, local, ocorrido_em)
SELECT r.id, 'em_transito', 'Centro de distribuição', r.despachada_em + interval '1 day'
FROM remessa r WHERE r.despachada_em + interval '1 day' <= LOCALTIMESTAMP;
INSERT INTO evento_remessa (remessa_id, tipo, local, ocorrido_em)
SELECT r.id, 'saiu_para_entrega', 'Unidade de entrega', p.entregue_em - interval '6 hours'
FROM remessa r JOIN pedido p ON p.id = r.pedido_id WHERE p.status = 'entregue';
INSERT INTO evento_remessa (remessa_id, tipo, local, ocorrido_em)
SELECT r.id, 'entregue', 'Endereço do cliente', p.entregue_em
FROM remessa r JOIN pedido p ON p.id = r.pedido_id WHERE p.status = 'entregue';

-- ===== Módulo 4 · Equipe e comissão =====
INSERT INTO cargo (nome, salario_base, comissao_percentual) VALUES
    ('Gerente de vendas', 5500, 1.00), ('Vendedor sênior', 2800, 3.00), ('Vendedor', 2200, 2.00),
    ('Estoquista', 1900, 0), ('Atendente', 2000, 0), ('Analista financeiro', 3800, 0);

INSERT INTO funcionario (nome, cpf, cargo_id, admitido_em, ativo) VALUES
    ('Ana Teixeira',   '30000000001', 1, DATE '2023-02-01', true),
    ('Bruno Carvalho', '30000000002', 2, DATE '2023-06-15', true),
    ('Carla Mendes',   '30000000003', 3, DATE '2024-03-10', true),
    ('Diego Farias',   '30000000004', 3, DATE '2025-01-20', true),
    ('Elisa Prado',    '30000000005', 3, DATE '2024-08-05', false),   -- saiu da empresa: não pode mais ser vendedora
    ('Fábio Rocha',    '30000000006', 4, DATE '2023-09-01', true),
    ('Gabriela Luz',   '30000000007', 5, DATE '2025-04-14', true),
    ('Hugo Barros',    '30000000008', 6, DATE '2024-11-04', true);

-- vendas assistidas: 2 em cada 5 pedidos fechados têm vendedor (funcionários 2 a 5)
UPDATE pedido SET vendedor_id = 2 + (id / 5) % 4
WHERE id <= 120 AND id % 5 IN (0, 1) AND status <> 'carrinho';

-- comissões já fechadas: pedidos entregues até 2 meses atrás (o mês passado fica para a procedure)
INSERT INTO comissao (funcionario_id, pedido_id, competencia, valor, gerada_em)
SELECT p.vendedor_id, p.id, date_trunc('month', p.entregue_em)::date,
       ROUND((p.subtotal - p.desconto) * c.comissao_percentual / 100, 2),
       date_trunc('month', p.entregue_em) + interval '1 month'
FROM pedido p
JOIN funcionario f ON f.id = p.vendedor_id
JOIN cargo c ON c.id = f.cargo_id
WHERE p.id <= 120 AND p.status = 'entregue' AND c.comissao_percentual > 0
  AND date_trunc('month', p.entregue_em) < date_trunc('month', CURRENT_DATE - interval '1 month');

-- uma conta a pagar por funcionário e mês, vencendo no dia 5 do mês seguinte
INSERT INTO conta_pagar (categoria, descricao, valor, vencimento, pago_em, funcionario_id, competencia)
SELECT 'comissao', 'Comissão ' || TO_CHAR(m.competencia, 'MM/YYYY'), m.valor,
       (m.competencia + interval '1 month' + interval '4 days')::date,
       CASE WHEN (m.competencia + interval '1 month' + interval '4 days')::date <= CURRENT_DATE
            THEN (m.competencia + interval '1 month' + interval '4 days')::date + time '09:00' END,
       m.funcionario_id, m.competencia
FROM (SELECT funcionario_id, competencia, SUM(valor) AS valor FROM comissao
      WHERE valor > 0 GROUP BY funcionario_id, competencia) m;

-- ===== Módulo 3 · Financeiro: contas a receber dos pagamentos =====
-- pix cai na hora; boleto em 2 dias; cartão em 30 dias (3x de 30 em 30 nos pedidos de R$ 300 ou mais com número par)
INSERT INTO conta_receber (pedido_id, parcela, total_parcelas, valor, vencimento, recebido_em)
SELECT v.pedido_id, v.parcela, v.total_parcelas, v.valor, v.vencimento,
       CASE WHEN v.vencimento <= CURRENT_DATE THEN v.vencimento + time '12:00' END
FROM (
    SELECT g.pedido_id, k AS parcela, g.n AS total_parcelas,
           CASE WHEN k < g.n THEN ROUND(g.valor / g.n, 2) ELSE g.valor - (g.n - 1) * ROUND(g.valor / g.n, 2) END AS valor,
           g.base + CASE g.forma WHEN 'pix' THEN 0 WHEN 'boleto' THEN 2 ELSE 30 * k END AS vencimento
    FROM (SELECT pg.pedido_id, pg.forma, pg.valor, pg.pago_em::date AS base,
                 CASE WHEN pg.forma = 'cartao' AND pg.valor >= 300 AND pg.pedido_id % 2 = 0 THEN 3 ELSE 1 END AS n
          FROM pagamento pg WHERE pg.pedido_id <= 120) g
    CROSS JOIN LATERAL generate_series(1, g.n) AS k
) v;

-- ===== Módulo 5 · Devolução =====
-- pedidos entregues 8, 9, 20 e 22; devolução pedida 3 dias depois da entrega (dentro dos 7 dias)
INSERT INTO devolucao (pedido_id, motivo, status, solicitada_em, concluida_em, valor_reembolso)
SELECT p.id, m.motivo, m.status, p.entregue_em + interval '3 days',
       CASE WHEN m.status = 'concluida' THEN p.entregue_em + interval '5 days' END, NULL
FROM pedido p
JOIN (VALUES (8,  'Veio com defeito',            'concluida'),
             (9,  'Não era o que eu esperava',   'concluida'),
             (20, 'Comprei o produto errado',    'recusada')) AS m (pedido_id, motivo, status) ON m.pedido_id = p.id;

-- cada devolução leva 1 unidade do primeiro item do pedido
INSERT INTO item_devolucao (devolucao_id, produto_id, quantidade)
SELECT d.id, (SELECT MIN(produto_id) FROM item_pedido WHERE pedido_id = d.pedido_id), 1 FROM devolucao d;

-- reembolso: valor dos itens devolvidos, com o desconto do cupom na mesma proporção (o frete não volta)
UPDATE devolucao d
SET valor_reembolso = ROUND((SELECT SUM(idv.quantidade * ip.preco_unitario)
                             FROM item_devolucao idv
                             JOIN item_pedido ip ON ip.pedido_id = d.pedido_id AND ip.produto_id = idv.produto_id
                             WHERE idv.devolucao_id = d.id) * (1 - p.desconto / p.subtotal), 2)
FROM pedido p
WHERE p.id = d.pedido_id AND d.status = 'concluida';

-- devolução concluída: o produto volta ao estoque e o estorno vira conta a pagar (já paga)
INSERT INTO movimento_estoque (produto_id, tipo, quantidade, pedido_id, criado_em)
SELECT idv.produto_id, 'estorno', idv.quantidade, d.pedido_id, d.concluida_em
FROM devolucao d JOIN item_devolucao idv ON idv.devolucao_id = d.id WHERE d.status = 'concluida';
UPDATE produto p SET estoque = estoque + x.qtd
FROM (SELECT idv.produto_id, SUM(idv.quantidade) AS qtd
      FROM devolucao d JOIN item_devolucao idv ON idv.devolucao_id = d.id WHERE d.status = 'concluida'
      GROUP BY idv.produto_id) x
WHERE x.produto_id = p.id;
INSERT INTO conta_pagar (categoria, descricao, valor, vencimento, pago_em, devolucao_id)
SELECT 'estorno', 'Estorno da devolução ' || d.id, d.valor_reembolso, d.concluida_em::date, d.concluida_em, d.id
FROM devolucao d WHERE d.status = 'concluida' AND d.valor_reembolso > 0;

-- ===== Módulo 6 · Fidelidade =====
INSERT INTO nivel_fidelidade (nome, pontos_minimos, multiplicador) VALUES
    ('Bronze', 0, 1.0), ('Prata', 100, 1.2), ('Ouro', 300, 1.5);

-- 1 ponto a cada R$ 10 (já com desconto, sem frete), de todos os pedidos pagos, enviados ou entregues
-- (o histórico entra sem multiplicador: os níveis são novos)
INSERT INTO movimento_pontos (cliente_id, pedido_id, tipo, pontos, criado_em)
SELECT p.cliente_id, p.id, 'credito', FLOOR((p.subtotal - p.desconto) / 10), pg.pago_em
FROM pedido p JOIN pagamento pg ON pg.pedido_id = p.id
WHERE p.id <= 120 AND p.status IN ('pago', 'enviado', 'entregue') AND FLOOR((p.subtotal - p.desconto) / 10) > 0;

-- os 2 clientes com mais pontos já trocaram 100 pontos por um cupom de R$ 10 (que ainda não usaram)
WITH top AS (
    SELECT cliente_id FROM movimento_pontos GROUP BY cliente_id ORDER BY SUM(pontos) DESC, cliente_id LIMIT 2
), resgate AS (
    INSERT INTO movimento_pontos (cliente_id, tipo, pontos)
    SELECT cliente_id, 'resgate', -100 FROM top RETURNING id
)
INSERT INTO cupom (codigo, tipo, valor, valido_ate, limite_usos, valor_minimo)
SELECT 'PTS-' || id, 'fixo', 10, CURRENT_DATE + 20, 1, 50 FROM resgate;
