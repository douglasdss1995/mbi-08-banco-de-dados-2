-- Cinema · consultas.sql
-- As 16 consultas de validação (C1 a C16), depois das 5 entradas. Só leem: não alteram o banco.
-- «Hoje» é current_date. Datas aparecem como «dias a partir de hoje» (negativo = no passado).
SET search_path TO cinema;

-- C1 · Quantos filmes, sessões, compras e ingressos existem
SELECT (SELECT count(*) FROM filme) AS filmes, (SELECT count(*) FROM sessao) AS sessoes, (SELECT count(*) FROM compra) AS compras, (SELECT count(*) FROM ingresso) AS ingressos;

-- C2 · Quantas sessões em cada situação
SELECT status, count(*) AS sessoes FROM sessao GROUP BY status ORDER BY sessoes DESC, status;

-- C3 · Sessões futuras: filme, sala, dia (a partir de hoje), hora, formato e situação
SELECT f.titulo, sa.nome AS sala, s.inicio::date - current_date AS dia, to_char(s.inicio, 'HH24:MI') AS hora, s.formato, s.status
FROM sessao s JOIN filme f ON f.id = s.filme_id JOIN sala sa ON sa.id = s.sala_id WHERE s.inicio::date > current_date - 1 AND s.inicio > now() ORDER BY s.inicio;

-- C4 · Aventura Estelar de daqui a 2 dias: situação de cada assento da sala (vendido, reservado ou livre)
SELECT a.fileira || a.numero AS assento,
       CASE WHEN EXISTS (SELECT 1 FROM ingresso i WHERE i.sessao_id = s.id AND i.assento_id = a.id AND i.situacao = 'vendido') THEN 'vendido'
            WHEN EXISTS (SELECT 1 FROM reserva_assento r WHERE r.sessao_id = s.id AND r.assento_id = a.id AND r.situacao = 'ativa') THEN 'reservado'
            ELSE 'livre' END AS situacao
FROM sessao s JOIN filme f ON f.id = s.filme_id JOIN assento a ON a.sala_id = s.sala_id
WHERE f.titulo = 'Aventura Estelar' AND s.inicio::date = current_date + 2 ORDER BY a.fileira, a.numero;

-- C5 · Assentos especiais: sala, assento e tipo
SELECT sa.nome, a.fileira || a.numero AS assento, a.especial FROM assento a JOIN sala sa ON sa.id = a.sala_id WHERE a.especial IS NOT NULL ORDER BY sa.nome, a.fileira, a.numero;

-- C6 · Faturamento: soma do valor total das compras pagas
SELECT SUM(valor_total) AS faturamento FROM compra WHERE status = 'paga';

-- C7 · Ingressos vendidos (não cancelados) por tipo: quantidade e valor
SELECT ti.nome, count(i.id) AS ingressos, COALESCE(SUM(i.valor_pago), 0) AS valor
FROM tipo_ingresso ti LEFT JOIN ingresso i ON i.tipo_ingresso_id = ti.id AND i.situacao = 'vendido' GROUP BY ti.nome ORDER BY ti.nome;

-- C8 · Sala 1 (2D): ingressos com cliente, valor pago e situação do ingresso; e a inteira 2D em dia normal hoje
SELECT cl.nome, i.valor_pago, i.situacao,
       (SELECT p.valor FROM preco p WHERE p.tipo_sala = '2D' AND p.dia = 'normal' AND p.vigencia_inicio <= current_date ORDER BY p.vigencia_inicio DESC LIMIT 1) AS inteira_2d_hoje
FROM ingresso i JOIN compra c ON c.id = i.compra_id JOIN cliente cl ON cl.id = c.cliente_id JOIN sessao s ON s.id = i.sessao_id JOIN sala sa ON sa.id = s.sala_id
WHERE sa.nome = 'Sala 1' ORDER BY c.criada_em, cl.nome;

-- C9 · Quantas compras em cada situação
SELECT status, count(*) AS compras FROM compra GROUP BY status ORDER BY compras DESC, status;

-- C10 · Reembolsos: cliente, valor e total
SELECT cl.nome, c.reembolso FROM compra c JOIN cliente cl ON cl.id = c.cliente_id WHERE c.reembolso IS NOT NULL ORDER BY cl.nome;

-- C11 · Sessões esgotadas: filme, sala, assentos da sala e assentos vendidos
SELECT f.titulo, sa.nome AS sala, (SELECT count(*) FROM assento a WHERE a.sala_id = sa.id) AS assentos,
       (SELECT count(*) FROM ingresso i WHERE i.sessao_id = s.id AND i.situacao = 'vendido') AS vendidos
FROM sessao s JOIN filme f ON f.id = s.filme_id JOIN sala sa ON sa.id = s.sala_id WHERE s.status = 'esgotada';

-- C12 · Filmes sem nenhuma sessão e gêneros sem nenhum filme
SELECT 'filme' AS tipo, f.titulo AS nome FROM filme f WHERE NOT EXISTS (SELECT 1 FROM sessao s WHERE s.filme_id = f.id)
UNION ALL
SELECT 'genero', g.nome FROM genero g WHERE NOT EXISTS (SELECT 1 FROM filme f WHERE f.genero_id = g.id) ORDER BY 1, 2;

-- C13 · Ingressos vendidos (não cancelados) por filme (todo filme aparece)
SELECT f.titulo, count(i.id) FILTER (WHERE i.situacao = 'vendido') AS ingressos
FROM filme f LEFT JOIN sessao s ON s.filme_id = f.id LEFT JOIN ingresso i ON i.sessao_id = s.id GROUP BY f.titulo ORDER BY ingressos DESC, f.titulo;

-- C14 · Clientes que nunca compraram
SELECT cl.nome FROM cliente cl WHERE NOT EXISTS (SELECT 1 FROM compra c WHERE c.cliente_id = cl.id);

-- C15 · Reservas de assento ativas: cliente, filme, assento e quantos minutos faltam para expirar (arredondado)
SELECT cl.nome, f.titulo, a.fileira || a.numero AS assento, ROUND(EXTRACT(EPOCH FROM r.expira_em - now()) / 60) AS minutos_restantes
FROM reserva_assento r JOIN cliente cl ON cl.id = r.cliente_id JOIN sessao s ON s.id = r.sessao_id JOIN filme f ON f.id = s.filme_id JOIN assento a ON a.id = r.assento_id
WHERE r.situacao = 'ativa';

-- C16 · Assentos por sala: total e especiais (toda sala aparece)
SELECT sa.nome, sa.tipo, count(a.id) AS assentos, count(a.id) FILTER (WHERE a.especial IS NOT NULL) AS especiais
FROM sala sa LEFT JOIN assento a ON a.sala_id = sa.id GROUP BY sa.nome, sa.tipo ORDER BY sa.nome;
