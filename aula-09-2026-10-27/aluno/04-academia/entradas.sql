-- Academia · entradas.sql
-- As 5 entradas do pedido de validação, na ordem. Rode num banco com a estrutura criada (sql/01_ddl.sql) e SEM dados.
-- Datas relativas a hoje: current_date - 10 = «10 dias atrás» (o arquivo serve em qualquer período).
SET search_path TO academia;

-- ===== Entrada 1 · cadastros =====
INSERT INTO modalidade (nome) VALUES ('Musculação'), ('Spinning'), ('Funcional'), ('Yoga');

INSERT INTO plano (nome, meses) VALUES ('Básico Mensal', 1), ('Completo Mensal', 1), ('Completo Anual', 12);

INSERT INTO plano_modalidade (plano_id, modalidade_id)
SELECT p.id, m.id FROM plano p JOIN modalidade m ON (p.nome = 'Básico Mensal' AND m.nome = 'Musculação') OR p.nome <> 'Básico Mensal';

INSERT INTO preco_plano (plano_id, valor_mensal, vigencia_inicio)
SELECT (SELECT id FROM plano WHERE nome = v.plano), v.valor, current_date - 300
FROM (VALUES ('Básico Mensal', 90), ('Completo Mensal', 140), ('Completo Anual', 120)) AS v (plano, valor);

INSERT INTO aluno (nome, email, nascimento, dia_vencimento)
SELECT a.nome, a.email, current_date - (a.anos * interval '1 year') - interval '45 days', a.dia
FROM (VALUES
    ('Bia Campos',   'bia.campos@academia.example',   28, 10),
    ('Caio Mendes',  'caio.mendes@academia.example',  41,  5),
    ('Dani Rocha',   'dani.rocha@academia.example',   33, 15),
    ('Enzo Pires',   'enzo.pires@academia.example',   25, 10),
    ('Flávia Lopes', 'flavia.lopes@academia.example', 52, 20),
    ('Gabi Torres',  'gabi.torres@academia.example',  30, 10),
    ('Heitor Vaz',   'heitor.vaz@academia.example',   37, 10)
) AS a (nome, email, anos, dia);

INSERT INTO instrutor (nome, cref) VALUES ('Gil Prado', 'CREF-001'), ('Hana Cruz', 'CREF-002'), ('Igor Silva', 'CREF-003');

INSERT INTO instrutor_modalidade (instrutor_id, modalidade_id)
SELECT (SELECT id FROM instrutor WHERE nome = x.instrutor), (SELECT id FROM modalidade WHERE nome = x.modalidade)
FROM (VALUES ('Gil Prado', 'Musculação'), ('Gil Prado', 'Funcional'), ('Hana Cruz', 'Spinning'), ('Hana Cruz', 'Yoga'),
             ('Igor Silva', 'Musculação')) AS x (instrutor, modalidade);

-- 0 = domingo, 1 = segunda, ...
INSERT INTO turma (modalidade_id, instrutor_id, dia_semana, hora_inicio, duracao_min, capacidade)
SELECT (SELECT id FROM modalidade WHERE nome = t.modalidade), (SELECT id FROM instrutor WHERE nome = t.instrutor), t.dia, t.hora::time, 50, t.cap
FROM (VALUES ('Spinning', 'Hana Cruz', 1, '18:00', 2), ('Funcional', 'Gil Prado', 2, '07:00', 20), ('Yoga', 'Hana Cruz', 4, '19:00', 15))
     AS t (modalidade, instrutor, dia, hora, cap);

-- ===== Entrada 2 · matrículas antigas, mensalidades e pagamentos =====
INSERT INTO matricula (aluno_id, plano_id, valor_mensal, inicio, fim, status)
SELECT (SELECT id FROM aluno WHERE nome = m.aluno), (SELECT id FROM plano WHERE nome = m.plano), m.valor,
       current_date + m.ini, current_date + m.fim, m.status
FROM (VALUES
    ('Bia Campos',  'Completo Mensal', 140, -200, -170, 'vencida'),     -- a Bia saiu e voltou depois com uma nova matrícula
    ('Bia Campos',  'Completo Anual',  120,  -70,  295, 'ativa'),
    ('Caio Mendes', 'Básico Mensal',    90,  -45,   20, 'ativa'),
    ('Enzo Pires',  'Básico Mensal',    90, -100,  -70, 'cancelada')
) AS m (aluno, plano, valor, ini, fim, status);

-- mensalidades: vencimento em dias a partir de hoje; a competência é o 1º dia do mês do vencimento
INSERT INTO mensalidade (matricula_id, competencia, vencimento, valor)
SELECT (SELECT ma.id FROM matricula ma JOIN aluno a ON a.id = ma.aluno_id WHERE a.nome = m.aluno AND ma.inicio = current_date + m.ini),
       date_trunc('month', current_date + m.venc)::date, current_date + m.venc, m.valor
FROM (VALUES
    ('Bia Campos',  -70, -70, 120), ('Bia Campos',  -70, -35, 120), ('Bia Campos',  -70, 0, 120), ('Bia Campos', -70, 35, 120),
    ('Caio Mendes', -45, -40,  90), ('Caio Mendes', -45,  -5,  90)
) AS m (aluno, ini, venc, valor);

-- Bia: a 1ª mensalidade foi paga no vencimento; a 2ª foi paga com 10 dias de atraso (multa 2% e juros 0,033% ao dia)
INSERT INTO pagamento (mensalidade_id, pago_em, valor_base, multa, juros, valor_pago, forma)
SELECT (SELECT me.id FROM mensalidade me JOIN matricula ma ON ma.id = me.matricula_id JOIN aluno a ON a.id = ma.aluno_id
        WHERE a.nome = 'Bia Campos' AND me.vencimento = current_date + g.venc),
       current_date + g.pago, 120, g.multa, g.juros, 120 + g.multa + g.juros, g.forma
FROM (VALUES (-70, -70, 0.00, 0.00, 'pix'), (-35, -25, 2.40, 0.40, 'cartao')) AS g (venc, pago, multa, juros, forma);

-- ===== Entrada 3 · reajuste: o plano Completo Mensal passa de R$ 140 para R$ 160 por mês (desde 10 dias atrás) =====
INSERT INTO preco_plano (plano_id, valor_mensal, vigencia_inicio)
VALUES ((SELECT id FROM plano WHERE nome = 'Completo Mensal'), 160, current_date - 10);

-- ===== Entrada 4 · matrículas novas, reservas, acessos e avaliações físicas =====
INSERT INTO matricula (aluno_id, plano_id, valor_mensal, inicio, fim, status)
SELECT (SELECT id FROM aluno WHERE nome = m.aluno), (SELECT id FROM plano WHERE nome = m.plano), m.valor,
       current_date + m.ini, current_date + m.fim, 'ativa'
FROM (VALUES
    ('Dani Rocha',  'Completo Mensal', 160, -3, 27),
    ('Gabi Torres', 'Completo Mensal', 160, -2, 28),
    ('Heitor Vaz',  'Básico Mensal',    90, -1, 29)     -- esta matrícula será apagada (engano)
) AS m (aluno, plano, valor, ini, fim);

INSERT INTO mensalidade (matricula_id, competencia, vencimento, valor)
SELECT (SELECT ma.id FROM matricula ma JOIN aluno a ON a.id = ma.aluno_id WHERE a.nome = m.aluno),
       date_trunc('month', current_date + m.venc)::date, current_date + m.venc, m.valor
FROM (VALUES ('Dani Rocha', 12, 160), ('Gabi Torres', 13, 160), ('Heitor Vaz', 14, 90)) AS m (aluno, venc, valor);

-- Reservas por data da aula. O Spinning de daqui a 3 dias tem 2 vagas: Bia e Dani confirmadas, Gabi na lista de espera.
INSERT INTO reserva (aluno_id, turma_id, data_aula, criada_em, situacao)
SELECT (SELECT id FROM aluno WHERE nome = r.aluno), (SELECT t.id FROM turma t JOIN modalidade m ON m.id = t.modalidade_id WHERE m.nome = r.modalidade),
       current_date + r.dia, now() - r.horas * interval '1 hour', r.situacao
FROM (VALUES
    ('Bia Campos',  'Spinning',  3,  30, 'confirmada'),
    ('Dani Rocha',  'Spinning',  3,  20, 'confirmada'),
    ('Gabi Torres', 'Spinning',  3,  10, 'espera'),
    ('Bia Campos',  'Funcional', 4,  30, 'confirmada'),
    ('Dani Rocha',  'Funcional', 4,  20, 'cancelada'),
    ('Bia Campos',  'Funcional', -14, 400, 'presente'),
    ('Bia Campos',  'Yoga',      -7, 300, 'faltou')
) AS r (aluno, modalidade, dia, horas, situacao);

-- Acessos (catraca): a Bia está dentro agora (sem saída)
INSERT INTO acesso (aluno_id, entrada, saida)
SELECT (SELECT id FROM aluno WHERE nome = x.aluno), now() - x.h_ent * interval '1 hour',
       CASE WHEN x.h_sai IS NULL THEN NULL ELSE now() - x.h_sai * interval '1 hour' END
FROM (VALUES ('Bia Campos', 49, 47.5), ('Dani Rocha', 25, 24), ('Bia Campos', 1, NULL)) AS x (aluno, h_ent, h_sai);

INSERT INTO avaliacao_fisica (aluno_id, data, peso_kg, altura_m)
SELECT (SELECT id FROM aluno WHERE nome = v.aluno), current_date - v.dias, v.peso, v.altura
FROM (VALUES ('Bia Campos', 90, 62.0, 1.65), ('Bia Campos', 5, 60.5, 1.65), ('Caio Mendes', 20, 85.0, 1.80)) AS v (aluno, dias, peso, altura);

-- ===== Entrada 5 · a matrícula do Heitor Vaz foi feita por engano: sai com as mensalidades =====
DELETE FROM mensalidade WHERE matricula_id = (SELECT ma.id FROM matricula ma JOIN aluno a ON a.id = ma.aluno_id WHERE a.nome = 'Heitor Vaz');
DELETE FROM matricula   WHERE aluno_id = (SELECT id FROM aluno WHERE nome = 'Heitor Vaz');
