-- Helpdesk · consultas.sql
-- As 16 consultas de validação (C1 a C16), depois das 5 entradas. Só leem: não alteram o banco.
-- «Hoje» é current_date. Datas aparecem como «dias atrás».
SET search_path TO helpdesk;

-- C1 · Quantos chamados, solicitantes e atendentes existem
SELECT (SELECT count(*) FROM chamado) AS chamados, (SELECT count(*) FROM solicitante) AS solicitantes, (SELECT count(*) FROM atendente) AS atendentes;

-- C2 · Quantos chamados em cada situação
SELECT status, count(*) AS chamados FROM chamado GROUP BY status ORDER BY chamados DESC, status;

-- C3 · Chamados em aberto (nem resolvidos, nem fechados, nem cancelados): descrição, solicitante, categoria e prioridade
SELECT ch.descricao, s.nome AS solicitante, c.nome AS categoria, ch.prioridade
FROM chamado ch JOIN solicitante s ON s.id = ch.solicitante_id JOIN categoria c ON c.id = ch.categoria_id
WHERE ch.status NOT IN ('resolvido', 'fechado', 'cancelado') ORDER BY ch.aberto_em;

-- C4 · Chamados de prioridade alta: prazo de resposta e de resolução gravados (em horas depois da abertura) e o SLA de hoje
SELECT ch.descricao, EXTRACT(EPOCH FROM ch.prazo_resposta - ch.aberto_em) / 3600 AS horas_resposta, EXTRACT(EPOCH FROM ch.prazo_resolucao - ch.aberto_em) / 3600 AS horas_resolucao,
       (SELECT s.horas_resposta || ' h / ' || s.horas_resolucao || ' h' FROM sla s WHERE s.prioridade = 'alta' AND s.vigencia_inicio <= current_date ORDER BY s.vigencia_inicio DESC LIMIT 1) AS sla_de_hoje
FROM chamado ch WHERE ch.prioridade = 'alta' ORDER BY ch.aberto_em;

-- C5 · Chamados cuja primeira resposta passou do prazo: descrição e horas de atraso
SELECT ch.descricao, EXTRACT(EPOCH FROM ch.primeira_resposta_em - ch.prazo_resposta) / 3600 AS horas_de_atraso
FROM chamado ch WHERE ch.primeira_resposta_em > ch.prazo_resposta;

-- C6 · Chamados resolvidos depois do prazo de resolução: descrição e horas de atraso
SELECT ch.descricao, EXTRACT(EPOCH FROM ch.resolvido_em - ch.prazo_resolucao) / 3600 AS horas_de_atraso
FROM chamado ch WHERE ch.resolvido_em > ch.prazo_resolucao;

-- C7 · Chamados em atendimento por atendente (todo atendente aparece)
SELECT a.nome, count(ch.id) FILTER (WHERE ch.status = 'em_atendimento') AS em_atendimento
FROM atendente a LEFT JOIN chamado ch ON ch.atendente_id = a.id GROUP BY a.nome ORDER BY em_atendimento DESC, a.nome;

-- C8 · Chamados por categoria (toda categoria aparece)
SELECT c.nome, count(ch.id) AS chamados FROM categoria c LEFT JOIN chamado ch ON ch.categoria_id = c.id GROUP BY c.nome ORDER BY chamados DESC, c.nome;

-- C9 · Chamados por setor do solicitante (todo setor aparece)
SELECT st.nome, count(ch.id) AS chamados
FROM setor st LEFT JOIN solicitante s ON s.setor_id = st.id LEFT JOIN chamado ch ON ch.solicitante_id = s.id GROUP BY st.nome ORDER BY chamados DESC, st.nome;

-- C10 · Trocas de prioridade: chamado, de, para, atendente e justificativa
SELECT ch.descricao, hp.de, hp.para, a.nome AS atendente, hp.justificativa
FROM historico_prioridade hp JOIN chamado ch ON ch.id = hp.chamado_id JOIN atendente a ON a.id = hp.atendente_id;

-- C11 · Chamados ligados a um chamado anterior (reabertura): o novo e o original
SELECT n.descricao AS novo, o.descricao AS original FROM chamado n JOIN chamado o ON o.id = n.chamado_origem_id;

-- C12 · Comentários por chamado: públicos e internos (só chamados com comentário)
SELECT ch.descricao, count(*) FILTER (WHERE NOT co.interno) AS publicos, count(*) FILTER (WHERE co.interno) AS internos
FROM comentario co JOIN chamado ch ON ch.id = co.chamado_id GROUP BY ch.descricao ORDER BY ch.descricao;

-- C13 · Chamados por equipamento (todo equipamento aparece)
SELECT a.patrimonio, a.tipo, count(ch.id) AS chamados FROM ativo a LEFT JOIN chamado ch ON ch.ativo_id = a.id GROUP BY a.patrimonio, a.tipo ORDER BY a.patrimonio;

-- C14 · Média da nota de satisfação por atendente (todo atendente aparece; sem nota fica vazio)
SELECT a.nome, ROUND(AVG(p.nota), 1) AS media, count(p.chamado_id) AS notas
FROM atendente a LEFT JOIN chamado ch ON ch.atendente_id = a.id LEFT JOIN pesquisa_satisfacao p ON p.chamado_id = ch.id
GROUP BY a.nome ORDER BY media DESC NULLS LAST, a.nome;

-- C15 · Horas até a primeira resposta de cada chamado respondido
SELECT ch.descricao, EXTRACT(EPOCH FROM ch.primeira_resposta_em - ch.aberto_em) / 3600 AS horas
FROM chamado ch WHERE ch.primeira_resposta_em IS NOT NULL ORDER BY ch.aberto_em;

-- C16 · Quantos atendentes cada fila tem (toda fila aparece)
SELECT c.nome AS categoria, f.nivel, count(af.atendente_id) AS atendentes
FROM fila f JOIN categoria c ON c.id = f.categoria_id LEFT JOIN atendente_fila af ON af.fila_id = f.id GROUP BY c.nome, f.nivel ORDER BY c.nome, f.nivel;
