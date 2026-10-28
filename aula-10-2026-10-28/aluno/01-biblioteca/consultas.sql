-- Biblioteca escolar · consultas.sql
-- As 16 consultas de validação (C1 a C16), depois das 5 entradas. Só leem: não alteram o banco.
-- «Hoje» é current_date. Datas aparecem como «dias a partir de hoje» (negativo = no passado).
SET search_path TO biblioteca;

-- C1 · Quantos exemplares, quantos empréstimos e quantos leitores existem
SELECT (SELECT count(*) FROM exemplar) AS exemplares, (SELECT count(*) FROM emprestimo) AS emprestimos, (SELECT count(*) FROM leitor) AS leitores;

-- C2 · Livros emprestados agora (empréstimo em aberto): leitor, livro e data prevista de devolução (em dias a partir de hoje)
SELECT l.nome AS leitor, lv.titulo, e.data_prevista - current_date AS prevista_em_dias
FROM emprestimo e
JOIN leitor l ON l.id = e.leitor_id
JOIN exemplar x ON x.id = e.exemplar_id
JOIN livro lv ON lv.id = x.livro_id
WHERE e.data_devolucao IS NULL
ORDER BY e.data_prevista, lv.titulo;

-- C3 · Estoque de cada livro da autora J.K. Rowling: exemplares no total e disponíveis agora
SELECT lv.titulo, count(x.id) AS exemplares, count(x.id) FILTER (WHERE x.estado = 'disponivel') AS disponiveis
FROM autor a
JOIN livro_autor la ON la.autor_id = a.id
JOIN livro lv ON lv.id = la.livro_id
LEFT JOIN exemplar x ON x.livro_id = lv.id
WHERE a.nome = 'J.K. Rowling'
GROUP BY lv.titulo
ORDER BY lv.titulo;

-- C4 · Atrasados hoje: leitor, telefone, e-mail, livro e dias de atraso
SELECT l.nome, l.telefone, l.email, lv.titulo, current_date - e.data_prevista AS dias_atraso
FROM emprestimo e
JOIN leitor l ON l.id = e.leitor_id
JOIN exemplar x ON x.id = e.exemplar_id
JOIN livro lv ON lv.id = x.livro_id
WHERE e.data_devolucao IS NULL AND e.data_prevista < current_date
ORDER BY dias_atraso DESC;

-- C5 · Livros com mais de um autor, com os autores na ordem
SELECT lv.titulo, string_agg(a.nome, ', ' ORDER BY la.ordem) AS autores
FROM livro lv JOIN livro_autor la ON la.livro_id = lv.id JOIN autor a ON a.id = la.autor_id
GROUP BY lv.titulo HAVING count(*) > 1;

-- C6 · Quantos livros cada autor tem (todo autor aparece)
SELECT a.nome, count(la.livro_id) AS livros
FROM autor a LEFT JOIN livro_autor la ON la.autor_id = a.id
GROUP BY a.nome ORDER BY livros DESC, a.nome;

-- C7 · Livros que nunca foram emprestados
SELECT lv.titulo FROM livro lv
WHERE NOT EXISTS (SELECT 1 FROM exemplar x JOIN emprestimo e ON e.exemplar_id = x.id WHERE x.livro_id = lv.id);

-- C8 · Ranking dos livros mais emprestados (todos aparecem; empate em ordem alfabética)
SELECT lv.titulo, count(e.id) AS emprestimos
FROM livro lv LEFT JOIN exemplar x ON x.livro_id = lv.id LEFT JOIN emprestimo e ON e.exemplar_id = x.id
GROUP BY lv.titulo ORDER BY emprestimos DESC, lv.titulo;

-- C9 · Total de multas geradas e total ainda pendente (não pago)
SELECT SUM(valor) AS gerado, COALESCE(SUM(valor) FILTER (WHERE NOT paga), 0) AS pendente FROM multa;

-- C10 · Para cada multa de aluno: leitor, dias de atraso, valor e valor cobrado por dia; e a tarifa de hoje do aluno
SELECT l.nome, m.dias_atraso, m.valor, ROUND(m.valor / m.dias_atraso, 2) AS valor_por_dia,
       (SELECT t.valor_dia FROM tarifa_multa t WHERE t.tipo_leitor_id = l.tipo_leitor_id AND t.vigencia_inicio <= current_date
        ORDER BY t.vigencia_inicio DESC LIMIT 1) AS tarifa_de_hoje
FROM multa m JOIN emprestimo e ON e.id = m.emprestimo_id JOIN leitor l ON l.id = e.leitor_id JOIN tipo_leitor t ON t.id = l.tipo_leitor_id
WHERE t.nome = 'aluno' ORDER BY m.dias_atraso DESC;

-- C11 · Fila de reservas do livro Prisioneiro de Azkaban, na ordem
SELECT l.nome FROM reserva r JOIN leitor l ON l.id = r.leitor_id JOIN livro lv ON lv.id = r.livro_id
WHERE lv.titulo = 'Harry Potter e o Prisioneiro de Azkaban' ORDER BY r.criada_em;

-- C12 · Leitores que nunca pegaram um livro
SELECT l.nome FROM leitor l WHERE NOT EXISTS (SELECT 1 FROM emprestimo e WHERE e.leitor_id = l.id);

-- C13 · Por leitor: empréstimos em aberto e o limite do tipo (todo leitor aparece)
SELECT l.nome, count(e.id) AS em_aberto, t.limite_emprestimos AS limite
FROM leitor l JOIN tipo_leitor t ON t.id = l.tipo_leitor_id
LEFT JOIN emprestimo e ON e.leitor_id = l.id AND e.data_devolucao IS NULL
GROUP BY l.nome, t.limite_emprestimos ORDER BY l.nome;

-- C14 · Atrasados que ainda NÃO receberam aviso enviado
SELECT l.nome, lv.titulo
FROM emprestimo e JOIN leitor l ON l.id = e.leitor_id JOIN exemplar x ON x.id = e.exemplar_id JOIN livro lv ON lv.id = x.livro_id
WHERE e.data_devolucao IS NULL AND e.data_prevista < current_date
  AND NOT EXISTS (SELECT 1 FROM notificacao n WHERE n.emprestimo_id = e.id AND n.situacao = 'enviada')
ORDER BY l.nome;

-- C15 · Os avisos: leitor, canal e situação
SELECT l.nome, n.canal, n.situacao
FROM notificacao n JOIN emprestimo e ON e.id = n.emprestimo_id JOIN leitor l ON l.id = e.leitor_id ORDER BY l.nome;

-- C16 · Por categoria: quantos livros e quantos exemplares (toda categoria aparece)
SELECT c.nome, count(DISTINCT lv.id) AS livros, count(x.id) AS exemplares
FROM categoria c LEFT JOIN livro lv ON lv.categoria_id = c.id LEFT JOIN exemplar x ON x.livro_id = lv.id
GROUP BY c.nome ORDER BY livros DESC, c.nome;
