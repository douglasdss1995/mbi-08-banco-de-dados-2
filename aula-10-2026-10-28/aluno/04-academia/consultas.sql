-- Academia · consultas.sql
-- As 16 consultas de validação (C1 a C16), depois das 5 entradas. Só leem: não alteram o banco.
-- «Hoje» é current_date.
SET search_path TO academia;

-- C1 · Quantos alunos, matrículas e mensalidades existem
SELECT (SELECT count(*) FROM aluno) AS alunos, (SELECT count(*) FROM matricula) AS matriculas, (SELECT count(*) FROM mensalidade) AS mensalidades;

-- C2 · Matrículas ativas: aluno, plano e valor mensal
SELECT a.nome, p.nome AS plano, m.valor_mensal
FROM matricula m JOIN aluno a ON a.id = m.aluno_id JOIN plano p ON p.id = m.plano_id WHERE m.status = 'ativa' ORDER BY a.nome;

-- C3 · Histórico de matrículas da Bia Campos: plano, valor mensal, início e fim (em dias a partir de hoje) e situação
SELECT p.nome AS plano, m.valor_mensal, m.inicio - current_date AS inicio_dias, m.fim - current_date AS fim_dias, m.status
FROM matricula m JOIN aluno a ON a.id = m.aluno_id JOIN plano p ON p.id = m.plano_id WHERE a.nome = 'Bia Campos' ORDER BY m.inicio;

-- C4 · Quantas modalidades cada plano inclui (todo plano aparece)
SELECT p.nome, count(pm.modalidade_id) AS modalidades FROM plano p LEFT JOIN plano_modalidade pm ON pm.plano_id = p.id GROUP BY p.nome ORDER BY modalidades, p.nome;

-- C5 · Plano Completo Mensal: valor mensal em cada matrícula e o valor de hoje
SELECT a.nome, m.valor_mensal,
       (SELECT pp.valor_mensal FROM preco_plano pp WHERE pp.plano_id = p.id AND pp.vigencia_inicio <= current_date ORDER BY pp.vigencia_inicio DESC LIMIT 1) AS valor_hoje
FROM matricula m JOIN aluno a ON a.id = m.aluno_id JOIN plano p ON p.id = m.plano_id WHERE p.nome = 'Completo Mensal' ORDER BY m.inicio;

-- C6 · Mensalidades em atraso (vencidas e sem pagamento): aluno e dias de atraso
SELECT a.nome, current_date - me.vencimento AS dias_atraso
FROM mensalidade me JOIN matricula m ON m.id = me.matricula_id JOIN aluno a ON a.id = m.aluno_id
WHERE me.vencimento < current_date AND NOT EXISTS (SELECT 1 FROM pagamento pg WHERE pg.mensalidade_id = me.id) ORDER BY dias_atraso DESC;

-- C7 · Alunos bloqueados na catraca (mensalidade em atraso há mais de 15 dias)
SELECT DISTINCT a.nome
FROM mensalidade me JOIN matricula m ON m.id = me.matricula_id JOIN aluno a ON a.id = m.aluno_id
WHERE current_date - me.vencimento > 15 AND NOT EXISTS (SELECT 1 FROM pagamento pg WHERE pg.mensalidade_id = me.id);

-- C8 · Pagamentos feitos com atraso: aluno, valor base, multa, juros e valor pago
SELECT a.nome, pg.valor_base, pg.multa, pg.juros, pg.valor_pago
FROM pagamento pg JOIN mensalidade me ON me.id = pg.mensalidade_id JOIN matricula m ON m.id = me.matricula_id JOIN aluno a ON a.id = m.aluno_id
WHERE pg.pago_em > me.vencimento;

-- C9 · Total recebido (soma do valor pago)
SELECT SUM(valor_pago) AS recebido FROM pagamento;

-- C10 · Alunos que nunca tiveram uma matrícula
SELECT a.nome FROM aluno a WHERE NOT EXISTS (SELECT 1 FROM matricula m WHERE m.aluno_id = a.id) ORDER BY a.nome;

-- C11 · Spinning de daqui a 3 dias: capacidade, vagas confirmadas e pessoas na espera
SELECT t.capacidade, count(r.id) FILTER (WHERE r.situacao = 'confirmada') AS confirmadas, count(r.id) FILTER (WHERE r.situacao = 'espera') AS espera
FROM turma t JOIN modalidade mo ON mo.id = t.modalidade_id LEFT JOIN reserva r ON r.turma_id = t.id AND r.data_aula = current_date + 3
WHERE mo.nome = 'Spinning' GROUP BY t.capacidade;

-- C12 · Reservas da Bia Campos: modalidade, dia da aula (a partir de hoje) e situação
SELECT mo.nome, r.data_aula - current_date AS dia, r.situacao
FROM reserva r JOIN aluno a ON a.id = r.aluno_id JOIN turma t ON t.id = r.turma_id JOIN modalidade mo ON mo.id = t.modalidade_id
WHERE a.nome = 'Bia Campos' ORDER BY r.data_aula;

-- C13 · Quem está dentro da academia agora (entrada sem saída)
SELECT a.nome FROM acesso ac JOIN aluno a ON a.id = ac.aluno_id WHERE ac.saida IS NULL;

-- C14 · Por instrutor: quantas modalidades e quantas turmas (todo instrutor aparece)
SELECT i.nome, (SELECT count(*) FROM instrutor_modalidade im WHERE im.instrutor_id = i.id) AS modalidades,
       (SELECT count(*) FROM turma t WHERE t.instrutor_id = i.id) AS turmas
FROM instrutor i ORDER BY i.nome;

-- C15 · IMC (peso / altura ao quadrado) da avaliação mais recente de cada aluno avaliado
SELECT a.nome, ROUND(av.peso_kg / (av.altura_m * av.altura_m), 1) AS imc
FROM avaliacao_fisica av JOIN aluno a ON a.id = av.aluno_id
WHERE av.data = (SELECT max(x.data) FROM avaliacao_fisica x WHERE x.aluno_id = av.aluno_id) ORDER BY a.nome;

-- C16 · Matrículas ativas por plano (todo plano aparece)
SELECT p.nome, count(m.id) FILTER (WHERE m.status = 'ativa') AS ativas FROM plano p LEFT JOIN matricula m ON m.plano_id = p.id GROUP BY p.nome ORDER BY ativas DESC, p.nome;
