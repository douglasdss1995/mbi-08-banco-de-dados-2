-- Clínica médica · entradas.sql
-- As 5 entradas do pedido de validação, na ordem. Rode num banco com a estrutura criada (sql/01_ddl.sql) e SEM dados.
-- Datas relativas a hoje: current_date - 10 = «10 dias atrás» (o arquivo serve em qualquer período).
SET search_path TO clinica, prontuario;

-- ===== Entrada 1 · cadastros =====
INSERT INTO especialidade (nome) VALUES ('Cardiologia'), ('Clínica Geral'), ('Pediatria'), ('Dermatologia'), ('Ortopedia'), ('Neurologia');

INSERT INTO medico (nome, crm, sexo) VALUES
    ('Helena Costa', 'CRM-1001', 'F'), ('Rui Matos', 'CRM-1002', 'M'), ('Sofia Lins', 'CRM-1003', 'F'), ('Téo Alves', 'CRM-1004', 'M');

INSERT INTO medico_especialidade (medico_id, especialidade_id)
SELECT (SELECT id FROM medico WHERE nome = m.medico), (SELECT id FROM especialidade WHERE nome = m.esp)
FROM (VALUES ('Helena Costa', 'Cardiologia'), ('Helena Costa', 'Clínica Geral'), ('Rui Matos', 'Pediatria'),
             ('Sofia Lins', 'Dermatologia'), ('Téo Alves', 'Ortopedia')) AS m (medico, esp);

INSERT INTO convenio (nome, percentual_cobertura) VALUES ('Saúde Mais', 70), ('VidaPlena', 50);

INSERT INTO paciente (nome, nascimento, convenio_id)
SELECT p.nome, current_date - (p.anos * interval '1 year') - interval '45 days', (SELECT id FROM convenio WHERE nome = p.conv)
FROM (VALUES ('Alice Pires', 34, 'Saúde Mais'), ('Bento Rocha', 8, NULL), ('Cecília Souza', 61, 'VidaPlena'),
             ('Davi Nunes', 45, NULL), ('Elisa Moraes', 29, 'Saúde Mais')) AS p (nome, anos, conv);

INSERT INTO tipo_consulta (nome, duracao_min, valor) VALUES ('Primeira consulta', 30, 200), ('Retorno', 20, 120), ('Exame de rotina', 45, 300);

-- 0 = domingo, 1 = segunda, ...
INSERT INTO horario_atendimento (medico_id, dia_semana, inicio, fim)
SELECT (SELECT id FROM medico WHERE nome = h.medico), h.dia, h.ini::time, h.fim::time
FROM (VALUES ('Helena Costa', 1, '08:00', '12:00'), ('Helena Costa', 1, '14:00', '18:00'), ('Rui Matos', 2, '08:00', '12:00'),
             ('Sofia Lins', 3, '13:00', '17:00'), ('Téo Alves', 5, '08:00', '12:00')) AS h (medico, dia, ini, fim);

INSERT INTO bloqueio_agenda (medico_id, inicio, fim, motivo)
VALUES ((SELECT id FROM medico WHERE nome = 'Sofia Lins'), (current_date + 10)::timestamp, (current_date + 12)::timestamp + time '23:59', 'Congresso');

-- ===== Entrada 2 · consultas antigas (já aconteceram), pagamentos e prontuários =====
INSERT INTO consulta (paciente_id, medico_id, tipo_id, convenio_id, inicio, fim, valor_tabela, status, cancelada_em)
SELECT p.id, m.id, t.id, p.convenio_id, (current_date + k.dia) + k.hora::time, (current_date + k.dia) + k.hora::time + t.duracao_min * interval '1 minute',
       k.valor, k.status, CASE WHEN k.status = 'cancelada' THEN (current_date + k.dia) + time '02:00' END
FROM (VALUES
    (-40, '09:00', 'Alice Pires',   'Helena Costa', 'Primeira consulta', 200, 'realizada'),
    (-20, '10:00', 'Bento Rocha',   'Rui Matos',    'Primeira consulta', 200, 'realizada'),
    (-15, '09:30', 'Alice Pires',   'Helena Costa', 'Retorno',           120, 'realizada'),
    (-12, '08:00', 'Cecília Souza', 'Sofia Lins',   'Exame de rotina',   300, 'realizada'),
    (-10, '14:00', 'Bento Rocha',   'Rui Matos',    'Retorno',           120, 'realizada'),
    ( -9, '15:00', 'Davi Nunes',    'Helena Costa', 'Primeira consulta', 200, 'faltou'),
    ( -8, '10:00', 'Davi Nunes',    'Helena Costa', 'Primeira consulta', 200, 'cancelada')   -- cancelada 8 horas antes: cobra metade
) AS k (dia, hora, paciente, medico, tipo, valor, status)
JOIN paciente p ON p.nome = k.paciente JOIN medico m ON m.nome = k.medico JOIN tipo_consulta t ON t.nome = k.tipo
ORDER BY k.dia;

-- pagamento: total, parte do convênio, parte do paciente
INSERT INTO pagamento (consulta_id, valor_total, valor_convenio, valor_paciente, situacao)
SELECT (SELECT c.id FROM consulta c JOIN paciente p ON p.id = c.paciente_id WHERE p.nome = g.paciente AND c.inicio::date = current_date + g.dia),
       g.total, g.conv, g.total - g.conv, g.situacao
FROM (VALUES
    (-40, 'Alice Pires',   200, 140, 'pago'),       -- convênio cobre 70%
    (-20, 'Bento Rocha',   200,   0, 'pago'),       -- particular
    (-15, 'Alice Pires',     0,   0, 'isento'),     -- retorno em até 30 dias: gratuito
    (-12, 'Cecília Souza', 300, 150, 'pago'),       -- convênio cobre 50%
    (-10, 'Bento Rocha',     0,   0, 'isento'),     -- retorno gratuito
    ( -8, 'Davi Nunes',    100,   0, 'pendente')    -- cancelamento tardio: metade de 200
) AS g (dia, paciente, total, conv, situacao);

INSERT INTO atendimento (consulta_id, anamnese, diagnostico_cid)
SELECT (SELECT c.id FROM consulta c JOIN paciente p ON p.id = c.paciente_id WHERE p.nome = a.paciente AND c.inicio::date = current_date + a.dia),
       a.queixa, a.cid
FROM (VALUES (-40, 'Alice Pires', 'Dor no peito ao esforço', 'R07'), (-20, 'Bento Rocha', 'Febre há dois dias', 'R50'),
             (-12, 'Cecília Souza', 'Manchas na pele', 'L30')) AS a (dia, paciente, queixa, cid);

INSERT INTO prescricao (atendimento_id, medicamento, posologia)
SELECT (SELECT a.id FROM atendimento a JOIN consulta c ON c.id = a.consulta_id JOIN paciente p ON p.id = c.paciente_id WHERE p.nome = r.paciente),
       r.med, r.pos
FROM (VALUES ('Alice Pires', 'AAS 100 mg', '1 comprimido ao dia'), ('Alice Pires', 'Atenolol 25 mg', '1 comprimido pela manhã'),
             ('Bento Rocha', 'Paracetamol gotas', '10 gotas a cada 6 horas')) AS r (paciente, med, pos);

INSERT INTO exame_solicitado (atendimento_id, exame)
SELECT (SELECT a.id FROM atendimento a JOIN consulta c ON c.id = a.consulta_id JOIN paciente p ON p.id = c.paciente_id WHERE p.nome = x.paciente), x.exame
FROM (VALUES ('Alice Pires', 'Eletrocardiograma'), ('Cecília Souza', 'Biópsia de pele')) AS x (paciente, exame);

-- ===== Entrada 3 · reajuste: a primeira consulta passa de R$ 200 para R$ 240 =====
UPDATE tipo_consulta SET valor = 240 WHERE nome = 'Primeira consulta';

-- ===== Entrada 4 · consultas de hoje e futuras, com pagamento =====
INSERT INTO consulta (paciente_id, medico_id, tipo_id, convenio_id, inicio, fim, valor_tabela, status)
SELECT p.id, m.id, t.id, p.convenio_id, (current_date + k.dia) + k.hora::time, (current_date + k.dia) + k.hora::time + t.duracao_min * interval '1 minute',
       CASE WHEN k.gratis THEN 0 ELSE t.valor END, k.status
FROM (VALUES
    (0, '09:00', 'Alice Pires',   'Helena Costa', 'Retorno',           'confirmada', true),    -- retorno em até 30 dias da consulta anterior: gratuito
    (0, '09:30', 'Cecília Souza', 'Helena Costa', 'Primeira consulta', 'agendada',   false),
    (0, '14:00', 'Bento Rocha',   'Rui Matos',    'Exame de rotina',   'confirmada', false),
    (1, '08:00', 'Alice Pires',   'Sofia Lins',   'Primeira consulta', 'agendada',   false),
    (2, '10:00', 'Elisa Moraes',  'Helena Costa', 'Primeira consulta', 'agendada',   false)   -- esta será a consulta lançada por engano
) AS k (dia, hora, paciente, medico, tipo, status, gratis)
JOIN paciente p ON p.nome = k.paciente JOIN medico m ON m.nome = k.medico JOIN tipo_consulta t ON t.nome = k.tipo;

INSERT INTO pagamento (consulta_id, valor_total, valor_convenio, valor_paciente, situacao)
SELECT (SELECT c.id FROM consulta c JOIN paciente p ON p.id = c.paciente_id WHERE p.nome = g.paciente AND c.inicio::date = current_date + g.dia),
       g.total, g.conv, g.total - g.conv, g.situacao
FROM (VALUES
    (0, 'Alice Pires',   0,   0, 'isento'),
    (0, 'Cecília Souza', 240, 120, 'pendente'),    -- convênio cobre 50% do valor novo
    (0, 'Bento Rocha',   300,   0, 'pendente'),
    (1, 'Alice Pires',   240, 168, 'pendente'),    -- convênio cobre 70%
    (2, 'Elisa Moraes',  240, 168, 'pendente')
) AS g (dia, paciente, total, conv, situacao);

-- ===== Entrada 5 · a consulta da Elisa Moraes foi marcada por engano: sai com o pagamento =====
DELETE FROM pagamento WHERE consulta_id = (SELECT c.id FROM consulta c JOIN paciente p ON p.id = c.paciente_id WHERE p.nome = 'Elisa Moraes');
DELETE FROM consulta  WHERE paciente_id = (SELECT id FROM paciente WHERE nome = 'Elisa Moraes');
