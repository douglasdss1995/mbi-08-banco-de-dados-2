-- Escola · entradas.sql
-- As 5 entradas do pedido de validação, na ordem. Rode num banco com a estrutura criada (sql/01_ddl.sql) e SEM dados.
-- Datas relativas a hoje: current_date - 10 = «10 dias atrás» (o arquivo serve em qualquer período).
SET search_path TO escola;

-- ===== Entrada 1 · cadastros =====
-- O ano letivo é o ano de hoje; os bimestres são dados em dias a partir de hoje.
INSERT INTO bimestre (ano, numero, inicio, fim)
SELECT EXTRACT(YEAR FROM current_date)::int, b.numero, current_date + b.ini, current_date + b.fim
FROM (VALUES (1, -200, -120), (2, -119, -40), (3, -39, 40), (4, 41, 120)) AS b (numero, ini, fim);

INSERT INTO disciplina (nome) VALUES ('Português'), ('Matemática'), ('História');
INSERT INTO professor (nome) VALUES ('Clara Dias'), ('Dario Luz'), ('Elis Mota');

INSERT INTO turma (nome, serie, turno, ano)
SELECT t.nome, t.serie, t.turno, EXTRACT(YEAR FROM current_date)::int
FROM (VALUES ('1A', 1, 'manha'), ('2B', 2, 'tarde'), ('3C', 3, 'noite')) AS t (nome, serie, turno);

INSERT INTO aluno (nome, nascimento)
SELECT a.nome, current_date - (a.anos * interval '1 year') - interval '60 days'
FROM (VALUES ('Fábia Teles', 15), ('Gui Pacheco', 15), ('Hugo Lemos', 16), ('Íris Barros', 16), ('Jota Maciel', 17)) AS a (nome, anos);

-- uma matrícula por aluno e ano; a turma fica em outra linha (matricula_turma), para a transferência guardar o histórico
INSERT INTO matricula (aluno_id, ano, status)
SELECT (SELECT id FROM aluno WHERE nome = m.aluno), EXTRACT(YEAR FROM current_date)::int, 'ativa'
FROM (VALUES ('Fábia Teles'), ('Gui Pacheco'), ('Hugo Lemos'), ('Íris Barros')) AS m (aluno);

INSERT INTO matricula_turma (matricula_id, turma_id, inicio)
SELECT (SELECT ma.id FROM matricula ma JOIN aluno a ON a.id = ma.aluno_id WHERE a.nome = m.aluno),
       (SELECT id FROM turma WHERE nome = m.turma), current_date - 200
FROM (VALUES ('Fábia Teles', '1A'), ('Gui Pacheco', '1A'), ('Hugo Lemos', '1A'), ('Íris Barros', '2B')) AS m (aluno, turma);

INSERT INTO oferta (turma_id, disciplina_id, aulas_semana)
SELECT (SELECT id FROM turma WHERE nome = o.turma), (SELECT id FROM disciplina WHERE nome = o.disc), o.aulas
FROM (VALUES ('1A', 'Português', 4), ('1A', 'Matemática', 5), ('2B', 'Português', 4)) AS o (turma, disc, aulas);

INSERT INTO oferta_professor (oferta_id, professor_id, inicio)
SELECT (SELECT o.id FROM oferta o JOIN turma t ON t.id = o.turma_id JOIN disciplina d ON d.id = o.disciplina_id WHERE t.nome = x.turma AND d.nome = x.disc),
       (SELECT id FROM professor WHERE nome = x.prof), current_date - 200
FROM (VALUES ('1A', 'Português', 'Clara Dias'), ('1A', 'Matemática', 'Dario Luz'), ('2B', 'Português', 'Dario Luz')) AS x (turma, disc, prof);

-- ===== Entrada 2 · avaliações, notas, aulas, chamadas e fechamento (Português da 1A, bimestres 1 e 2) =====
INSERT INTO avaliacao (oferta_id, bimestre_id, nome, tipo, peso)
SELECT (SELECT o.id FROM oferta o JOIN turma t ON t.id = o.turma_id JOIN disciplina d ON d.id = o.disciplina_id WHERE t.nome = a.turma AND d.nome = a.disc),
       (SELECT id FROM bimestre WHERE numero = a.bim AND ano = EXTRACT(YEAR FROM current_date)::int), a.nome, a.tipo, a.peso
FROM (VALUES
    ('1A', 'Português', 1, 'Prova 1',        'prova',        2),
    ('1A', 'Português', 1, 'Trabalho 1',     'trabalho',     1),
    ('1A', 'Português', 2, 'Prova 2',        'prova',        3),
    ('1A', 'Português', 2, 'Participação 2', 'participacao', 1)
) AS a (turma, disc, bim, nome, tipo, peso);

INSERT INTO nota (avaliacao_id, matricula_id, valor)
SELECT (SELECT av.id FROM avaliacao av WHERE av.nome = n.avaliacao),
       (SELECT ma.id FROM matricula ma JOIN aluno a ON a.id = ma.aluno_id WHERE a.nome = n.aluno), n.valor
FROM (VALUES
    ('Prova 1',        'Fábia Teles', 8), ('Trabalho 1', 'Fábia Teles', 6), ('Prova 2', 'Fábia Teles', 7), ('Participação 2', 'Fábia Teles', 9),
    ('Prova 1',        'Gui Pacheco', 5), ('Trabalho 1', 'Gui Pacheco', 7), ('Prova 2', 'Gui Pacheco', 6), ('Participação 2', 'Gui Pacheco', 4),
    ('Prova 1',        'Hugo Lemos',  9)                                        -- o Hugo não tem nota do Trabalho 1
) AS n (avaliacao, aluno, valor);

-- aulas de Português da 1A (Clara Dias, 08:00): chamada de 3 alunos
INSERT INTO aula (oferta_id, professor_id, data, horario)
SELECT (SELECT o.id FROM oferta o JOIN turma t ON t.id = o.turma_id JOIN disciplina d ON d.id = o.disciplina_id WHERE t.nome = '1A' AND d.nome = 'Português'),
       (SELECT id FROM professor WHERE nome = 'Clara Dias'), current_date - d.dia, '08:00'
FROM (VALUES (50), (49), (48), (47), (46)) AS d (dia);

INSERT INTO frequencia (aula_id, matricula_id, situacao)
SELECT (SELECT au.id FROM aula au WHERE au.data = current_date - f.dia),
       (SELECT ma.id FROM matricula ma JOIN aluno a ON a.id = ma.aluno_id WHERE a.nome = f.aluno), f.situacao
FROM (VALUES
    (50, 'Fábia Teles', 'presente'), (50, 'Gui Pacheco', 'presente'),    (50, 'Hugo Lemos', 'presente'),
    (49, 'Fábia Teles', 'presente'), (49, 'Gui Pacheco', 'ausente'),     (49, 'Hugo Lemos', 'presente'),
    (48, 'Fábia Teles', 'presente'), (48, 'Gui Pacheco', 'ausente'),     (48, 'Hugo Lemos', 'justificada'),
    (47, 'Fábia Teles', 'ausente'),  (47, 'Gui Pacheco', 'ausente'),     (47, 'Hugo Lemos', 'presente'),
    (46, 'Fábia Teles', 'presente'), (46, 'Gui Pacheco', 'presente'),    (46, 'Hugo Lemos', 'presente')
) AS f (dia, aluno, situacao);

INSERT INTO fechamento (turma_id, bimestre_id, fechado_em)
SELECT (SELECT id FROM turma WHERE nome = '1A'), (SELECT id FROM bimestre WHERE numero = f.bim AND ano = EXTRACT(YEAR FROM current_date)::int),
       current_date + f.dia
FROM (VALUES (1, -115), (2, -35)) AS f (bim, dia);

-- ===== Entrada 3 · troca de professor, transferência de aluno e correção de nota =====
-- Matemática da 1A: o Dario Luz deixa a disciplina 60 dias atrás e a Clara Dias assume. O histórico fica.
UPDATE oferta_professor SET fim = current_date - 60
WHERE oferta_id = (SELECT o.id FROM oferta o JOIN turma t ON t.id = o.turma_id JOIN disciplina d ON d.id = o.disciplina_id WHERE t.nome = '1A' AND d.nome = 'Matemática')
  AND fim IS NULL;
INSERT INTO oferta_professor (oferta_id, professor_id, inicio)
SELECT (SELECT o.id FROM oferta o JOIN turma t ON t.id = o.turma_id JOIN disciplina d ON d.id = o.disciplina_id WHERE t.nome = '1A' AND d.nome = 'Matemática'),
       (SELECT id FROM professor WHERE nome = 'Clara Dias'), current_date - 59;

-- O Hugo Lemos foi transferido da 1A para a 2B há 30 dias.
UPDATE matricula_turma SET fim = current_date - 31
WHERE matricula_id = (SELECT ma.id FROM matricula ma JOIN aluno a ON a.id = ma.aluno_id WHERE a.nome = 'Hugo Lemos') AND fim IS NULL;
INSERT INTO matricula_turma (matricula_id, turma_id, inicio)
SELECT (SELECT ma.id FROM matricula ma JOIN aluno a ON a.id = ma.aluno_id WHERE a.nome = 'Hugo Lemos'), (SELECT id FROM turma WHERE nome = '2B'), current_date - 30;

-- Correção depois do fechamento: a Prova 1 do Gui Pacheco passa de 5 para 6, com justificativa.
INSERT INTO historico_nota (nota_id, avaliacao_id, matricula_id, valor_antes, valor_depois, justificativa)
SELECT n.id, n.avaliacao_id, n.matricula_id, 5, 6, 'Erro na soma da prova'
FROM nota n JOIN avaliacao av ON av.id = n.avaliacao_id JOIN matricula ma ON ma.id = n.matricula_id JOIN aluno a ON a.id = ma.aluno_id
WHERE av.nome = 'Prova 1' AND a.nome = 'Gui Pacheco';
UPDATE nota SET valor = 6, justificativa = 'Erro na soma da prova'
WHERE avaliacao_id = (SELECT id FROM avaliacao WHERE nome = 'Prova 1')
  AND matricula_id = (SELECT ma.id FROM matricula ma JOIN aluno a ON a.id = ma.aluno_id WHERE a.nome = 'Gui Pacheco');

-- ===== Entrada 4 · mais notas e aulas, e uma matrícula nova =====
INSERT INTO avaliacao (oferta_id, bimestre_id, nome, tipo, peso)
SELECT (SELECT o.id FROM oferta o JOIN turma t ON t.id = o.turma_id JOIN disciplina d ON d.id = o.disciplina_id WHERE t.nome = a.turma AND d.nome = a.disc),
       (SELECT id FROM bimestre WHERE numero = a.bim AND ano = EXTRACT(YEAR FROM current_date)::int), a.nome, 'prova', 1
FROM (VALUES ('1A', 'Matemática', 1, 'Prova de Matemática 1'), ('2B', 'Português', 3, 'Prova de Português 3')) AS a (turma, disc, bim, nome);

INSERT INTO nota (avaliacao_id, matricula_id, valor)
SELECT (SELECT av.id FROM avaliacao av WHERE av.nome = n.avaliacao),
       (SELECT ma.id FROM matricula ma JOIN aluno a ON a.id = ma.aluno_id WHERE a.nome = n.aluno), n.valor
FROM (VALUES
    ('Prova de Matemática 1', 'Fábia Teles', 9), ('Prova de Matemática 1', 'Gui Pacheco', 3), ('Prova de Matemática 1', 'Hugo Lemos', 6),
    ('Prova de Português 3',  'Íris Barros', 10), ('Prova de Português 3',  'Hugo Lemos', 7)
) AS n (avaliacao, aluno, valor);

-- duas aulas de Matemática da 1A, dadas pelo Dario Luz (09:00), antes de ele deixar a disciplina
INSERT INTO aula (oferta_id, professor_id, data, horario)
SELECT (SELECT o.id FROM oferta o JOIN turma t ON t.id = o.turma_id JOIN disciplina d ON d.id = o.disciplina_id WHERE t.nome = '1A' AND d.nome = 'Matemática'),
       (SELECT id FROM professor WHERE nome = 'Dario Luz'), current_date - d.dia, '09:00'
FROM (VALUES (100), (99)) AS d (dia);

-- Jota Maciel: matrícula na 3C feita por engano (será apagada)
INSERT INTO matricula (aluno_id, ano, status) VALUES ((SELECT id FROM aluno WHERE nome = 'Jota Maciel'), EXTRACT(YEAR FROM current_date)::int, 'ativa');
INSERT INTO matricula_turma (matricula_id, turma_id, inicio)
SELECT (SELECT ma.id FROM matricula ma JOIN aluno a ON a.id = ma.aluno_id WHERE a.nome = 'Jota Maciel'), (SELECT id FROM turma WHERE nome = '3C'), current_date - 1;

-- ===== Entrada 5 · a matrícula do Jota Maciel foi lançada por engano: sai com a turma =====
DELETE FROM matricula_turma WHERE matricula_id = (SELECT ma.id FROM matricula ma JOIN aluno a ON a.id = ma.aluno_id WHERE a.nome = 'Jota Maciel');
DELETE FROM matricula WHERE aluno_id = (SELECT id FROM aluno WHERE nome = 'Jota Maciel');
