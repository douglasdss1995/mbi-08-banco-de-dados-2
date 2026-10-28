-- Escola · consultas.sql
-- As 16 consultas de validação (C1 a C16), depois das 5 entradas. Só leem: não alteram o banco.
-- «Hoje» é current_date. Datas aparecem como «dias a partir de hoje» (negativo = no passado).
SET search_path TO escola;

-- C1 · Quantos alunos, matrículas, turmas e ofertas (disciplina numa turma) existem
SELECT (SELECT count(*) FROM aluno) AS alunos, (SELECT count(*) FROM matricula) AS matriculas,
       (SELECT count(*) FROM turma) AS turmas, (SELECT count(*) FROM oferta) AS ofertas;

-- C2 · Turma atual de cada aluno (aluno sem matrícula aparece sem turma)
SELECT a.nome, t.nome AS turma
FROM aluno a LEFT JOIN matricula ma ON ma.aluno_id = a.id
LEFT JOIN matricula_turma mt ON mt.matricula_id = ma.id AND mt.fim IS NULL
LEFT JOIN turma t ON t.id = mt.turma_id ORDER BY a.nome;

-- C3 · Histórico de turmas do Hugo Lemos: turma, início e fim (em dias a partir de hoje; fim vazio = turma atual)
SELECT t.nome AS turma, mt.inicio - current_date AS inicio_dias, mt.fim - current_date AS fim_dias
FROM matricula_turma mt JOIN matricula ma ON ma.id = mt.matricula_id JOIN aluno a ON a.id = ma.aluno_id JOIN turma t ON t.id = mt.turma_id
WHERE a.nome = 'Hugo Lemos' ORDER BY mt.inicio;

-- C4 · Quem deu Matemática na 1A e em que período (início e fim em dias a partir de hoje; fim vazio = atual)
SELECT p.nome, op.inicio - current_date AS inicio_dias, op.fim - current_date AS fim_dias
FROM oferta_professor op JOIN oferta o ON o.id = op.oferta_id JOIN turma t ON t.id = o.turma_id JOIN disciplina d ON d.id = o.disciplina_id
JOIN professor p ON p.id = op.professor_id WHERE t.nome = '1A' AND d.nome = 'Matemática' ORDER BY op.inicio;

-- C5 · Português da 1A, 1º bimestre: média ponderada de cada aluno (só entram as notas lançadas)
SELECT a.nome, ROUND(SUM(n.valor * av.peso) / SUM(av.peso), 2) AS media
FROM nota n JOIN avaliacao av ON av.id = n.avaliacao_id JOIN bimestre b ON b.id = av.bimestre_id JOIN oferta o ON o.id = av.oferta_id
JOIN turma t ON t.id = o.turma_id JOIN disciplina d ON d.id = o.disciplina_id JOIN matricula ma ON ma.id = n.matricula_id JOIN aluno a ON a.id = ma.aluno_id
WHERE t.nome = '1A' AND d.nome = 'Português' AND b.numero = 1 GROUP BY a.nome ORDER BY a.nome;

-- C6 · Alunos com bimestre incompleto em Português da 1A, 1º bimestre (falta nota de alguma avaliação)
SELECT a.nome, count(*) AS avaliacoes_sem_nota
FROM avaliacao av JOIN bimestre b ON b.id = av.bimestre_id JOIN oferta o ON o.id = av.oferta_id JOIN turma t ON t.id = o.turma_id JOIN disciplina d ON d.id = o.disciplina_id
JOIN matricula ma ON ma.status = 'ativa' JOIN aluno a ON a.id = ma.aluno_id
WHERE t.nome = '1A' AND d.nome = 'Português' AND b.numero = 1
  AND EXISTS (SELECT 1 FROM nota x WHERE x.matricula_id = ma.id AND x.avaliacao_id IN (SELECT id FROM avaliacao WHERE oferta_id = o.id AND bimestre_id = b.id))
  AND NOT EXISTS (SELECT 1 FROM nota x WHERE x.matricula_id = ma.id AND x.avaliacao_id = av.id)
GROUP BY a.nome;

-- C7 · Português da 1A: média anual parcial (média simples das médias dos bimestres 1 e 2) dos alunos com os dois bimestres completos
WITH medias AS (
    SELECT n.matricula_id, b.numero, SUM(n.valor * av.peso) / SUM(av.peso) AS media
    FROM nota n JOIN avaliacao av ON av.id = n.avaliacao_id JOIN bimestre b ON b.id = av.bimestre_id JOIN oferta o ON o.id = av.oferta_id
    JOIN turma t ON t.id = o.turma_id JOIN disciplina d ON d.id = o.disciplina_id WHERE t.nome = '1A' AND d.nome = 'Português' GROUP BY n.matricula_id, b.numero)
SELECT a.nome, ROUND(AVG(m.media), 2) AS media_anual
FROM medias m JOIN matricula ma ON ma.id = m.matricula_id JOIN aluno a ON a.id = ma.aluno_id
GROUP BY a.nome HAVING count(*) = 2 ORDER BY a.nome;

-- C8 · Português da 1A: frequência de cada aluno (presentes ÷ aulas contadas; a falta justificada fica fora da conta)
SELECT a.nome, ROUND(100.0 * count(*) FILTER (WHERE f.situacao = 'presente') / NULLIF(count(*) FILTER (WHERE f.situacao <> 'justificada'), 0), 0) AS frequencia_pct
FROM frequencia f JOIN matricula ma ON ma.id = f.matricula_id JOIN aluno a ON a.id = ma.aluno_id JOIN aula au ON au.id = f.aula_id
JOIN oferta o ON o.id = au.oferta_id JOIN disciplina d ON d.id = o.disciplina_id WHERE d.nome = 'Português' GROUP BY a.nome ORDER BY a.nome;

-- C9 · Situação em Português da 1A (aprovado: média >= 6 e frequência >= 75; recuperação: média de 4 a 5,9 com frequência suficiente; reprovado: o resto)
WITH m AS (
    SELECT n.matricula_id, AVG(x.media) AS media FROM nota n
    JOIN (SELECT n2.matricula_id, av.bimestre_id, SUM(n2.valor * av.peso) / SUM(av.peso) AS media
          FROM nota n2 JOIN avaliacao av ON av.id = n2.avaliacao_id JOIN oferta o ON o.id = av.oferta_id JOIN turma t ON t.id = o.turma_id
          JOIN disciplina d ON d.id = o.disciplina_id WHERE t.nome = '1A' AND d.nome = 'Português' GROUP BY n2.matricula_id, av.bimestre_id) x ON x.matricula_id = n.matricula_id
    GROUP BY n.matricula_id HAVING count(DISTINCT x.bimestre_id) = 2),
f AS (
    SELECT f.matricula_id, 100.0 * count(*) FILTER (WHERE f.situacao = 'presente') / NULLIF(count(*) FILTER (WHERE f.situacao <> 'justificada'), 0) AS freq
    FROM frequencia f GROUP BY f.matricula_id)
SELECT a.nome, ROUND(m.media, 2) AS media, ROUND(f.freq, 0) AS freq,
       CASE WHEN f.freq < 75 OR m.media < 4 THEN 'reprovado' WHEN m.media < 6 THEN 'recuperação' ELSE 'aprovado' END AS situacao
FROM m JOIN f ON f.matricula_id = m.matricula_id JOIN matricula ma ON ma.id = m.matricula_id JOIN aluno a ON a.id = ma.aluno_id ORDER BY a.nome;

-- C10 · Alunos em risco por frequência (abaixo de 75%) em Português da 1A
SELECT a.nome FROM frequencia f JOIN matricula ma ON ma.id = f.matricula_id JOIN aluno a ON a.id = ma.aluno_id
GROUP BY a.nome HAVING 100.0 * count(*) FILTER (WHERE f.situacao = 'presente') / NULLIF(count(*) FILTER (WHERE f.situacao <> 'justificada'), 0) < 75;

-- C11 · Nota corrigida: aluno, avaliação, nota antes, nota depois e justificativa
SELECT a.nome, av.nome AS avaliacao, h.valor_antes, h.valor_depois, h.justificativa
FROM historico_nota h JOIN avaliacao av ON av.id = h.avaliacao_id JOIN matricula ma ON ma.id = h.matricula_id JOIN aluno a ON a.id = ma.aluno_id;

-- C12 · Disciplinas que ninguém dá (sem oferta) e professores sem nenhuma aula atribuída
SELECT 'disciplina' AS tipo, d.nome FROM disciplina d WHERE NOT EXISTS (SELECT 1 FROM oferta o WHERE o.disciplina_id = d.id)
UNION ALL
SELECT 'professor', p.nome FROM professor p WHERE NOT EXISTS (SELECT 1 FROM oferta_professor op WHERE op.professor_id = p.id) ORDER BY 1, 2;

-- C13 · Aulas dadas por professor (todo professor aparece)
SELECT p.nome, count(au.id) AS aulas FROM professor p LEFT JOIN aula au ON au.professor_id = p.id GROUP BY p.nome ORDER BY aulas DESC, p.nome;

-- C14 · Alunos sem matrícula neste ano
SELECT a.nome FROM aluno a WHERE NOT EXISTS (SELECT 1 FROM matricula ma WHERE ma.aluno_id = a.id);

-- C15 · Alunos atualmente em cada turma (toda turma aparece)
SELECT t.nome, count(mt.id) AS alunos FROM turma t LEFT JOIN matricula_turma mt ON mt.turma_id = t.id AND mt.fim IS NULL GROUP BY t.nome ORDER BY t.nome;

-- C16 · Português da 1A: por bimestre, quantas avaliações e a soma dos pesos
SELECT b.numero AS bimestre, count(av.id) AS avaliacoes, SUM(av.peso) AS soma_pesos
FROM avaliacao av JOIN bimestre b ON b.id = av.bimestre_id JOIN oferta o ON o.id = av.oferta_id JOIN turma t ON t.id = o.turma_id JOIN disciplina d ON d.id = o.disciplina_id
WHERE t.nome = '1A' AND d.nome = 'Português' GROUP BY b.numero ORDER BY b.numero;
