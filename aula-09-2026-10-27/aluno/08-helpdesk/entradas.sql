-- Helpdesk · entradas.sql
-- As 5 entradas do pedido de validação, na ordem. Rode num banco com a estrutura criada (sql/01_ddl.sql) e SEM dados.
-- Datas relativas a hoje: current_date - 10 = «10 dias atrás» (o arquivo serve em qualquer período).
SET search_path TO helpdesk;

-- ===== Entrada 1 · cadastros =====
INSERT INTO setor (nome) VALUES ('TI'), ('Financeiro'), ('RH'), ('Comercial');

INSERT INTO solicitante (nome, email, setor_id)
SELECT s.nome, s.email, (SELECT id FROM setor WHERE nome = s.setor)
FROM (VALUES
    ('Alê Nunes', 'ale.nunes@empresa.example', 'Financeiro'), ('Beto Ramos', 'beto.ramos@empresa.example', 'RH'),
    ('Cris Lima', 'cris.lima@empresa.example', 'Financeiro'), ('Dora Pires', 'dora.pires@empresa.example', 'Comercial')
) AS s (nome, email, setor);

INSERT INTO categoria (nome) VALUES ('Acesso e senhas'), ('Equipamentos'), ('Rede'), ('Sistemas');

-- cada categoria tem uma fila N1 (triagem) e uma N2 (especialistas)
INSERT INTO fila (categoria_id, nivel) SELECT c.id, n.nivel FROM categoria c CROSS JOIN (VALUES ('N1'), ('N2')) AS n (nivel);

INSERT INTO atendente (nome, nivel) VALUES ('Iara Costa', 'N1'), ('Jonas Reis', 'N1'), ('Kátia Moura', 'N2'), ('Léo Prado', 'N2');

INSERT INTO atendente_fila (atendente_id, fila_id)
SELECT (SELECT id FROM atendente WHERE nome = x.atendente),
       (SELECT f.id FROM fila f JOIN categoria c ON c.id = f.categoria_id WHERE c.nome = x.cat AND f.nivel = x.nivel)
FROM (VALUES
    ('Iara Costa', 'Acesso e senhas', 'N1'), ('Iara Costa', 'Equipamentos', 'N1'), ('Jonas Reis', 'Rede', 'N1'),
    ('Kátia Moura', 'Rede', 'N2'), ('Kátia Moura', 'Sistemas', 'N2'), ('Léo Prado', 'Sistemas', 'N2'), ('Léo Prado', 'Equipamentos', 'N2')
) AS x (atendente, cat, nivel);

-- SLA em horas corridas (resposta, resolução), desde 300 dias atrás
INSERT INTO sla (prioridade, horas_resposta, horas_resolucao, vigencia_inicio)
SELECT s.prio, s.resp, s.res, current_date - 300
FROM (VALUES ('critica', 1, 4), ('alta', 4, 8), ('media', 8, 24), ('baixa', 24, 72)) AS s (prio, resp, res);

INSERT INTO ativo (patrimonio, tipo, modelo, setor_id)
SELECT a.pat, a.tipo, a.modelo, (SELECT id FROM setor WHERE nome = a.setor)
FROM (VALUES ('PAT-0001', 'Notebook', 'Latitude 5420', 'Financeiro'), ('PAT-0002', 'Roteador', 'Cisco RV340', 'TI'),
             ('PAT-0003', 'Impressora', 'HP LaserJet', 'RH')) AS a (pat, tipo, modelo, setor);

-- ===== Entrada 2 · chamados antigos, com comentários, histórico e pesquisa =====
-- Os prazos de resposta e de resolução são gravados no chamado, com o SLA vigente no dia da abertura.
INSERT INTO chamado (solicitante_id, categoria_id, fila_id, atendente_id, ativo_id, descricao, prioridade_sugerida, prioridade, status,
                     aberto_em, primeira_resposta_em, resolvido_em, fechado_em, prazo_resposta, prazo_resolucao)
SELECT (SELECT id FROM solicitante WHERE nome = k.sol), c.id, (SELECT f.id FROM fila f WHERE f.categoria_id = c.id AND f.nivel = k.nivel),
       (SELECT id FROM atendente WHERE nome = k.atend), (SELECT id FROM ativo WHERE patrimonio = k.pat), k.descr, k.sug, k.prio, k.status,
       (current_date + k.dia) + k.hora::time, (current_date + k.dia) + k.hora::time + k.resp * interval '1 hour',
       (current_date + k.dia) + k.hora::time + k.res * interval '1 hour',
       CASE WHEN k.fechado IS NOT NULL THEN (current_date + k.fechado) + time '09:00' END,
       (current_date + k.dia) + k.hora::time + k.p_resp * interval '1 hour', (current_date + k.dia) + k.hora::time + k.p_res * interval '1 hour'
FROM (VALUES
    ('Esqueci a senha do sistema',     'Alê Nunes',  'Acesso e senhas', 'N1', 'Iara Costa',  NULL,       'media',   'media',   'fechado',   -20, '09:00', 2,  5, -15,  8, 24),
    ('Impressora não imprime',         'Beto Ramos', 'Equipamentos',    'N1', 'Iara Costa',  'PAT-0003', 'baixa',   'media',   'resolvido', -12, '10:00', 1, 20, NULL, 8, 24),
    ('Internet fora do ar',            'Cris Lima',  'Rede',            'N2', 'Kátia Moura', 'PAT-0002', 'critica', 'critica', 'resolvido',  -8, '08:00', 3,  9, NULL, 1,  4),
    ('Sistema de vendas com erro',     'Dora Pires', 'Sistemas',        'N2', 'Kátia Moura', NULL,       'alta',    'alta',    'resolvido', -14, '14:00', 2,  6, NULL, 4,  8)
) AS k (descr, sol, cat, nivel, atend, pat, sug, prio, status, dia, hora, resp, res, fechado, p_resp, p_res)
JOIN categoria c ON c.nome = k.cat;

-- a Iara trocou a prioridade do chamado da impressora de baixa para média, com justificativa
INSERT INTO historico_prioridade (chamado_id, atendente_id, de, para, justificativa, quando)
SELECT ch.id, (SELECT id FROM atendente WHERE nome = 'Iara Costa'), 'baixa', 'media', 'Impressora usada por vários colaboradores', ch.aberto_em + interval '30 minutes'
FROM chamado ch WHERE ch.descricao = 'Impressora não imprime';

-- comentários públicos (o solicitante vê) e internos (só atendentes)
INSERT INTO comentario (chamado_id, atendente_id, solicitante_id, interno, texto, criado_em)
SELECT ch.id, (SELECT id FROM atendente WHERE nome = x.atend), (SELECT id FROM solicitante WHERE nome = x.sol), x.interno, x.texto, ch.aberto_em + x.horas * interval '1 hour'
FROM (VALUES
    ('Internet fora do ar', 'Jonas Reis',  NULL, false, 'Reiniciei o roteador e a internet continua fora.', 1),
    ('Internet fora do ar', 'Jonas Reis',  NULL, true,  'Sem resposta do provedor; escalar para o N2.',       2),
    ('Internet fora do ar', 'Kátia Moura', NULL, false, 'Cabo trocado, internet normalizada.',                8)
) AS x (descr, atend, sol, interno, texto, horas)
JOIN chamado ch ON ch.descricao = x.descr;

-- cada mudança de status com a hora (aqui só do chamado da internet)
INSERT INTO historico_status (chamado_id, status_antes, status_depois, quando)
SELECT ch.id, h.antes, h.depois, ch.aberto_em + h.horas * interval '1 hour'
FROM (VALUES (NULL, 'aberto', 0), ('aberto', 'em_atendimento', 3), ('em_atendimento', 'resolvido', 9)) AS h (antes, depois, horas)
JOIN chamado ch ON ch.descricao = 'Internet fora do ar';

INSERT INTO pesquisa_satisfacao (chamado_id, nota, comentario)
SELECT ch.id, p.nota, p.com FROM (VALUES ('Esqueci a senha do sistema', 5, 'Rápido'), ('Impressora não imprime', 4, NULL), ('Internet fora do ar', 2, 'Demorou')) AS p (descr, nota, com)
JOIN chamado ch ON ch.descricao = p.descr;

-- ===== Entrada 3 · mudança de SLA: a prioridade alta passa de 4 h / 8 h para 3 h / 6 h (desde 10 dias atrás) =====
INSERT INTO sla (prioridade, horas_resposta, horas_resolucao, vigencia_inicio) VALUES ('alta', 3, 6, current_date - 10);

-- ===== Entrada 4 · chamados recentes, reabertura e comentários =====
INSERT INTO chamado (solicitante_id, categoria_id, fila_id, atendente_id, ativo_id, chamado_origem_id, descricao, prioridade_sugerida, prioridade, status,
                     aberto_em, primeira_resposta_em, aguardando_desde, prazo_resposta, prazo_resolucao)
SELECT (SELECT id FROM solicitante WHERE nome = k.sol), c.id, (SELECT f.id FROM fila f WHERE f.categoria_id = c.id AND f.nivel = k.nivel),
       (SELECT id FROM atendente WHERE nome = k.atend), (SELECT id FROM ativo WHERE patrimonio = k.pat),
       (SELECT id FROM chamado WHERE descricao = k.origem), k.descr, k.sug, k.prio, k.status,
       k.aberto, CASE WHEN k.resp IS NOT NULL THEN k.aberto + k.resp * interval '1 hour' END,
       CASE WHEN k.status = 'aguardando_solicitante' THEN (current_date - 2) + time '10:00' END,
       k.aberto + k.p_resp * interval '1 hour', k.aberto + k.p_res * interval '1 hour'
FROM (VALUES
    ('Notebook não liga',              'Alê Nunes',  'Equipamentos',    'N1', 'Iara Costa',  'PAT-0001', NULL,                     'alta',  'alta',  'em_atendimento',         (current_date - 6) + time '11:00', 1,    3,  6),
    ('Erro ao emitir relatório',       'Beto Ramos', 'Sistemas',        'N2', 'Kátia Moura', NULL,       NULL,                     'media', 'media', 'aguardando_solicitante', (current_date - 3) + time '09:00', 1,    8, 24),
    ('Pedido de acesso à pasta',       'Dora Pires', 'Acesso e senhas', 'N1', NULL,          NULL,       NULL,                     'baixa', 'baixa', 'aberto',                 now() - interval '1 hour',         NULL, 24, 72),
    ('Impressora voltou a falhar',     'Beto Ramos', 'Equipamentos',    'N1', 'Iara Costa',  'PAT-0003', 'Impressora não imprime', 'media', 'media', 'em_atendimento',         (current_date - 2) + time '15:00', 1,    8, 24),
    ('Chamado criado por engano',      'Cris Lima',  'Rede',            'N1', NULL,          NULL,       NULL,                     'baixa', 'baixa', 'aberto',                 now(),                             NULL, 24, 72)
) AS k (descr, sol, cat, nivel, atend, pat, origem, sug, prio, status, aberto, resp, p_resp, p_res)
JOIN categoria c ON c.nome = k.cat;

INSERT INTO comentario (chamado_id, atendente_id, solicitante_id, interno, texto, criado_em)
SELECT ch.id, (SELECT id FROM atendente WHERE nome = x.atend), (SELECT id FROM solicitante WHERE nome = x.sol), false, x.texto, ch.aberto_em + x.horas * interval '1 hour'
FROM (VALUES
    ('Erro ao emitir relatório',  'Kátia Moura', NULL,         'Pode enviar o print do erro?', 1),
    ('Erro ao emitir relatório',  NULL,          'Beto Ramos', 'Enviei por e-mail.',           2),
    ('Chamado criado por engano', NULL,          'Cris Lima',  'Teste.',                       0)
) AS x (descr, atend, sol, texto, horas)
JOIN chamado ch ON ch.descricao = x.descr;

-- ===== Entrada 5 · o chamado «Chamado criado por engano» sai com os comentários =====
DELETE FROM comentario WHERE chamado_id = (SELECT id FROM chamado WHERE descricao = 'Chamado criado por engano');
DELETE FROM chamado WHERE descricao = 'Chamado criado por engano';
