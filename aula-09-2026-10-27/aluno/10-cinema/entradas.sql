-- Cinema · entradas.sql
-- As 5 entradas do pedido de validação, na ordem. Rode num banco com a estrutura criada (sql/01_ddl.sql) e SEM dados.
-- Datas relativas a hoje: current_date - 10 = «10 dias atrás» (o arquivo serve em qualquer período).
SET search_path TO cinema;

-- ===== Entrada 1 · cadastros =====
INSERT INTO genero (nome) VALUES ('Ação'), ('Animação'), ('Drama'), ('Terror');

INSERT INTO filme (titulo, genero_id, duracao_min, classificacao, idioma)
SELECT f.titulo, (SELECT id FROM genero WHERE nome = f.genero), f.duracao, f.classif, f.idioma
FROM (VALUES
    ('Aventura Estelar',    'Ação',     120, '12',    'Inglês'),
    ('Pequeno Dragão',      'Animação',  90, 'livre', 'Português'),
    ('Noite Silenciosa',    'Drama',    100, '16',    'Francês'),
    ('Sombras do Passado',  'Drama',    110, '18',    'Português')
) AS f (titulo, genero, duracao, classif, idioma);

INSERT INTO sala (nome, tipo) VALUES ('Sala 1', '2D'), ('Sala 2', '3D'), ('Sala VIP', 'VIP');

INSERT INTO assento (sala_id, fileira, numero, especial)
SELECT (SELECT id FROM sala WHERE nome = a.sala), a.fileira, a.numero, a.especial
FROM (VALUES
    ('Sala 1', 'A', 1, NULL), ('Sala 1', 'A', 2, NULL), ('Sala 1', 'A', 3, 'cadeirante'),
    ('Sala 1', 'B', 1, NULL), ('Sala 1', 'B', 2, NULL), ('Sala 1', 'B', 3, 'casal'),
    ('Sala 2', 'A', 1, NULL), ('Sala 2', 'A', 2, NULL), ('Sala 2', 'A', 3, NULL), ('Sala 2', 'A', 4, NULL),
    ('Sala VIP', 'A', 1, NULL), ('Sala VIP', 'A', 2, NULL), ('Sala VIP', 'A', 3, NULL)
) AS a (sala, fileira, numero, especial);

-- preço da inteira por tipo de sala e tipo de dia (a quarta-feira é promocional), desde 300 dias atrás
INSERT INTO preco (tipo_sala, dia, valor, vigencia_inicio)
SELECT p.tipo, p.dia, p.valor, current_date - 300
FROM (VALUES ('2D', 'normal', 30), ('2D', 'quarta', 20), ('3D', 'normal', 40), ('3D', 'quarta', 30), ('VIP', 'normal', 60), ('VIP', 'quarta', 50)) AS p (tipo, dia, valor);

INSERT INTO tipo_ingresso (nome, percentual) VALUES ('inteira', 100), ('meia', 50);

INSERT INTO cliente (nome, email, nascimento)
SELECT c.nome, c.email, current_date - (c.idade * interval '1 year') - interval '60 days'
FROM (VALUES
    ('Gabi Pinto',     'gabi.pinto@cinema.example',     30), ('Hélio Cunha',    'helio.cunha@cinema.example',    65),
    ('Ivo Lemos',      'ivo.lemos@cinema.example',      15), ('Jussara Rocha',  'jussara.rocha@cinema.example',  28),
    ('Kauê Brito',     'kaue.brito@cinema.example',     20)
) AS c (nome, email, idade);

-- ===== Entrada 2 · sessões e compras antigas =====
-- fim da sessão = início + duração do filme + 20 minutos de limpeza
INSERT INTO sessao (filme_id, sala_id, inicio, fim, formato, status)
SELECT f.id, s.id, (current_date + x.dia) + x.hora::time, (current_date + x.dia) + x.hora::time + (f.duracao_min + 20) * interval '1 minute', x.formato, x.status
FROM (VALUES
    ('Aventura Estelar', 'Sala 2',   -20, '19:00', 'legendado', 'encerrada'),
    ('Pequeno Dragão',   'Sala 1',   -10, '15:00', 'dublado',   'encerrada'),
    ('Pequeno Dragão',   'Sala 1',    -9, '15:00', 'dublado',   'encerrada')
) AS x (filme, sala, dia, hora, formato, status)
JOIN filme f ON f.titulo = x.filme JOIN sala s ON s.nome = x.sala;

-- compras pagas: valor_total e valor pago em cada ingresso (inteira ou meia = 50%)
INSERT INTO compra (cliente_id, sessao_id, status, criada_em, valor_total)
SELECT (SELECT id FROM cliente WHERE nome = k.cliente),
       (SELECT s.id FROM sessao s JOIN filme f ON f.id = s.filme_id WHERE f.titulo = k.filme AND s.inicio::date = current_date + k.dia),
       'paga', (current_date + k.criada) + time '12:00', k.total
FROM (VALUES
    ('Gabi Pinto',  'Aventura Estelar', -20, -21, 60),
    ('Hélio Cunha', 'Pequeno Dragão',   -10, -11, 15),
    ('Ivo Lemos',   'Pequeno Dragão',    -9, -12, 15)     -- compra de 12 dias atrás, sessão de 9 dias atrás
) AS k (cliente, filme, dia, criada, total);

INSERT INTO ingresso (compra_id, sessao_id, assento_id, tipo_ingresso_id, valor_pago)
SELECT c.id, c.sessao_id,
       (SELECT a.id FROM assento a JOIN sessao s ON s.sala_id = a.sala_id WHERE s.id = c.sessao_id AND a.fileira = x.fileira AND a.numero = x.numero),
       (SELECT id FROM tipo_ingresso WHERE nome = x.tipo), x.valor
FROM (VALUES
    ('Gabi Pinto',  'Aventura Estelar', 'A', 1, 'inteira', 40), ('Gabi Pinto', 'Aventura Estelar', 'A', 2, 'meia', 20),
    ('Hélio Cunha', 'Pequeno Dragão',   'A', 1, 'meia',    15),
    ('Ivo Lemos',   'Pequeno Dragão',   'A', 1, 'meia',    15)
) AS x (cliente, filme, fileira, numero, tipo, valor)
JOIN cliente cl ON cl.nome = x.cliente
JOIN compra c ON c.cliente_id = cl.id AND c.sessao_id IN (SELECT s.id FROM sessao s JOIN filme f ON f.id = s.filme_id WHERE f.titulo = x.filme);

INSERT INTO pagamento (compra_id, forma, valor, pago_em)
SELECT c.id, g.forma, c.valor_total, c.criada_em + interval '2 minutes'
FROM (VALUES ('Gabi Pinto', 'pix'), ('Hélio Cunha', 'cartao'), ('Ivo Lemos', 'pix')) AS g (cliente, forma)
JOIN cliente cl ON cl.nome = g.cliente JOIN compra c ON c.cliente_id = cl.id;

-- ===== Entrada 3 · reajuste: a inteira 2D em dia normal passa de R$ 30 para R$ 35 (desde 10 dias atrás) =====
INSERT INTO preco (tipo_sala, dia, valor, vigencia_inicio) VALUES ('2D', 'normal', 35, current_date - 10);

-- ===== Entrada 4 · sessões futuras, compras, cancelamentos e uma reserva de assento =====
INSERT INTO sessao (filme_id, sala_id, inicio, fim, formato, status)
SELECT f.id, s.id, (current_date + x.dia) + x.hora::time, (current_date + x.dia) + x.hora::time + (f.duracao_min + 20) * interval '1 minute', x.formato, x.status
FROM (VALUES
    ('Noite Silenciosa', 'Sala VIP', 1, '21:00', 'legendado', 'esgotada'),
    ('Aventura Estelar', 'Sala 2',   2, '19:00', 'legendado', 'aberta'),
    ('Pequeno Dragão',   'Sala 1',   3, '14:00', 'dublado',   'cancelada'),
    ('Pequeno Dragão',   'Sala 1',   4, '16:00', 'dublado',   'aberta')        -- esta sessão será criada por engano e apagada
) AS x (filme, sala, dia, hora, formato, status)
JOIN filme f ON f.titulo = x.filme JOIN sala s ON s.nome = x.sala;

INSERT INTO compra (cliente_id, sessao_id, status, criada_em, valor_total, cancelada_em, reembolso)
SELECT (SELECT id FROM cliente WHERE nome = k.cliente),
       (SELECT s.id FROM sessao s JOIN filme f ON f.id = s.filme_id WHERE f.titulo = k.filme AND s.inicio::date = current_date + k.dia),
       k.status, now() - k.horas * interval '1 hour', k.total, CASE WHEN k.status = 'cancelada' THEN now() - interval '1 hour' END, k.reembolso
FROM (VALUES
    ('Gabi Pinto',  'Noite Silenciosa', 1, 'paga',      30, 150.00, NULL),
    ('Kauê Brito',  'Aventura Estelar', 2, 'paga',      26,  60.00, NULL),
    ('Kauê Brito',  'Aventura Estelar', 2, 'cancelada', 25,  40.00, 40.00),     -- cancelada pelo cliente com mais de 2 horas de antecedência: reembolso total
    ('Hélio Cunha', 'Pequeno Dragão',   3, 'cancelada', 24,  17.50, 17.50)      -- sessão cancelada pelo cinema: reembolso total
) AS k (cliente, filme, dia, status, horas, total, reembolso);

INSERT INTO ingresso (compra_id, sessao_id, assento_id, tipo_ingresso_id, valor_pago, situacao)
SELECT c.id, c.sessao_id,
       (SELECT a.id FROM assento a JOIN sessao s ON s.sala_id = a.sala_id WHERE s.id = c.sessao_id AND a.fileira = x.fileira AND a.numero = x.numero),
       (SELECT id FROM tipo_ingresso WHERE nome = x.tipo), x.valor, x.situacao
FROM (VALUES
    ('Gabi Pinto',  'Noite Silenciosa', 'A', 1, 'inteira', 60, 'vendido'), ('Gabi Pinto', 'Noite Silenciosa', 'A', 2, 'inteira', 60, 'vendido'),
    ('Gabi Pinto',  'Noite Silenciosa', 'A', 3, 'meia',    30, 'vendido'),
    ('Kauê Brito',  'Aventura Estelar', 'A', 1, 'meia',    20, 'vendido'), ('Kauê Brito', 'Aventura Estelar', 'A', 2, 'inteira', 40, 'vendido'),
    ('Hélio Cunha', 'Pequeno Dragão',   'A', 3, 'meia',  17.50, 'cancelado')
) AS x (cliente, filme, fileira, numero, tipo, valor, situacao)
JOIN cliente cl ON cl.nome = x.cliente
JOIN compra c ON c.cliente_id = cl.id AND c.valor_total = (CASE x.cliente WHEN 'Gabi Pinto' THEN 150 WHEN 'Hélio Cunha' THEN 17.5 ELSE 60 END)
             AND c.sessao_id IN (SELECT s.id FROM sessao s JOIN filme f ON f.id = s.filme_id WHERE f.titulo = x.filme);
-- o ingresso cancelado do Kauê (assento A3, já cancelado): o assento voltou a ficar livre
INSERT INTO ingresso (compra_id, sessao_id, assento_id, tipo_ingresso_id, valor_pago, situacao)
SELECT c.id, c.sessao_id, (SELECT a.id FROM assento a WHERE a.sala_id = (SELECT sala_id FROM sessao WHERE id = c.sessao_id) AND a.fileira = 'A' AND a.numero = 3),
       (SELECT id FROM tipo_ingresso WHERE nome = 'inteira'), 40, 'cancelado'
FROM compra c WHERE c.status = 'cancelada' AND c.valor_total = 40;

INSERT INTO pagamento (compra_id, forma, valor, pago_em)
SELECT c.id, g.forma, c.valor_total, c.criada_em + interval '2 minutes'
FROM (VALUES ('Gabi Pinto', 150, 'cartao'), ('Kauê Brito', 60, 'pix')) AS g (cliente, total, forma)
JOIN cliente cl ON cl.nome = g.cliente JOIN compra c ON c.cliente_id = cl.id AND c.valor_total = g.total AND c.status = 'paga' AND c.criada_em > now() - interval '2 days';

-- reserva de assento por 10 minutos: a Jussara segurou o assento A4 da sessão de daqui a 2 dias e ainda não pagou
INSERT INTO reserva_assento (sessao_id, assento_id, cliente_id, criada_em, expira_em)
SELECT s.id, (SELECT a.id FROM assento a WHERE a.sala_id = s.sala_id AND a.fileira = 'A' AND a.numero = 4), (SELECT id FROM cliente WHERE nome = 'Jussara Rocha'),
       now() - interval '3 minutes', now() + interval '7 minutes'
FROM sessao s JOIN filme f ON f.id = s.filme_id WHERE f.titulo = 'Aventura Estelar' AND s.inicio::date = current_date + 2;

-- ===== Entrada 5 · a sessão de Pequeno Dragão de daqui a 4 dias foi criada por engano: sai =====
DELETE FROM sessao WHERE inicio::date = current_date + 4;
