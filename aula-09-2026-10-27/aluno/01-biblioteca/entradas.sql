-- Biblioteca escolar · entradas.sql
-- As 5 entradas do pedido de validação, na ordem. Rode num banco com a estrutura criada (sql/01_ddl.sql) e SEM dados.
-- Datas relativas a hoje: current_date - 10 = «10 dias atrás» (o arquivo serve em qualquer período).
SET search_path TO biblioteca;

-- ===== Entrada 1 · cadastros =====
INSERT INTO editora (nome) VALUES ('Rocco'), ('Companhia das Letras'), ('Novatec');
INSERT INTO categoria (nome) VALUES ('Fantasia'), ('Literatura'), ('Tecnologia'), ('Poesia');
INSERT INTO autor (nome) VALUES ('J.K. Rowling'), ('Machado de Assis'), ('Ana Beatriz Lemos'), ('Rui Carvalho'),
                                ('Marcos Teles'), ('Clarice Lispector');

INSERT INTO livro (titulo, editora_id, categoria_id)
SELECT l.titulo, (SELECT id FROM editora WHERE nome = l.editora), (SELECT id FROM categoria WHERE nome = l.categoria)
FROM (VALUES
    ('Harry Potter e a Pedra Filosofal',          'Rocco',                'Fantasia'),
    ('Harry Potter e a Câmara Secreta',           'Rocco',                'Fantasia'),
    ('Harry Potter e o Prisioneiro de Azkaban',   'Rocco',                'Fantasia'),
    ('Dom Casmurro',                              'Companhia das Letras', 'Literatura'),
    ('Banco de Dados Relacional',                 'Novatec',              'Tecnologia'),
    ('Redes de Computadores',                     'Novatec',              'Tecnologia'),
    ('Algoritmos na Prática',                     'Novatec',              'Tecnologia')
) AS l (titulo, editora, categoria);

INSERT INTO livro_autor (livro_id, autor_id, ordem)
SELECT (SELECT id FROM livro WHERE titulo = a.titulo), (SELECT id FROM autor WHERE nome = a.autor), a.ordem
FROM (VALUES
    ('Harry Potter e a Pedra Filosofal', 'J.K. Rowling', 1),
    ('Harry Potter e a Câmara Secreta', 'J.K. Rowling', 1),
    ('Harry Potter e o Prisioneiro de Azkaban', 'J.K. Rowling', 1),
    ('Dom Casmurro', 'Machado de Assis', 1),
    ('Banco de Dados Relacional', 'Ana Beatriz Lemos', 1),
    ('Banco de Dados Relacional', 'Rui Carvalho', 2),
    ('Redes de Computadores', 'Marcos Teles', 1),
    ('Algoritmos na Prática', 'Rui Carvalho', 1)
) AS a (titulo, autor, ordem);

-- Exemplares (o tombo EX-000001... sai do id): o 1º e o 2º são os dois da Pedra Filosofal (A e B).
INSERT INTO exemplar (livro_id, estado)
SELECT (SELECT id FROM livro WHERE titulo = e.titulo), e.estado
FROM (VALUES
    ('Harry Potter e a Pedra Filosofal',        'emprestado'),   -- EX-000001 (A)
    ('Harry Potter e a Pedra Filosofal',        'disponivel'),   -- EX-000002 (B)
    ('Harry Potter e a Câmara Secreta',         'emprestado'),   -- EX-000003
    ('Harry Potter e o Prisioneiro de Azkaban', 'emprestado'),   -- EX-000004
    ('Dom Casmurro',                            'emprestado'),   -- EX-000005
    ('Banco de Dados Relacional',               'disponivel'),   -- EX-000006
    ('Redes de Computadores',                   'disponivel'),   -- EX-000007
    ('Algoritmos na Prática',                   'manutencao')    -- EX-000008
) AS e (titulo, estado);

INSERT INTO tipo_leitor (nome, prazo_dias, limite_emprestimos) VALUES ('aluno', 7, 3), ('professor', 15, 5), ('funcionario', 10, 3);
INSERT INTO tarifa_multa (tipo_leitor_id, valor_dia, vigencia_inicio)
SELECT (SELECT id FROM tipo_leitor WHERE nome = t.tipo), t.valor, current_date - 90
FROM (VALUES ('aluno', 0.50), ('professor', 0.25), ('funcionario', 0.25)) AS t (tipo, valor);

INSERT INTO leitor (nome, registro, email, telefone, tipo_leitor_id)
SELECT l.nome, l.registro, l.email, l.fone, (SELECT id FROM tipo_leitor WHERE nome = l.tipo)
FROM (VALUES
    ('Lia Torres',   'A-1001', 'lia.torres@escola.example',   '(47) 99100-0001', 'aluno'),
    ('Caio Ramos',   'A-1002', 'caio.ramos@escola.example',   '(47) 99100-0002', 'aluno'),
    ('Nina Prado',   'A-1003', 'nina.prado@escola.example',   '(47) 99100-0003', 'aluno'),
    ('Helena Vaz',   'P-2001', 'helena.vaz@escola.example',   '(47) 99100-0004', 'professor'),
    ('Otávio Lins',  'F-3001', 'otavio.lins@escola.example',  '(47) 99100-0005', 'funcionario'),
    ('Paulo Reis',   'F-3002', 'paulo.reis@escola.example',   '(47) 99100-0006', 'funcionario')
) AS l (nome, registro, email, fone, tipo);

-- ===== Entrada 2 · empréstimos antigos (já devolvidos) e as multas deles =====
INSERT INTO emprestimo (leitor_id, exemplar_id, data_emprestimo, data_prevista, data_devolucao)
SELECT (SELECT id FROM leitor WHERE nome = e.leitor), (SELECT id FROM exemplar WHERE tombo = e.tombo),
       current_date - e.ini, current_date - e.prev, current_date - e.dev
FROM (VALUES
    ('Nina Prado',  'EX-000007', 50, 43, 39),   -- Redes de Computadores: 4 dias de atraso
    ('Lia Torres',  'EX-000006', 40, 33, 35),   -- Banco de Dados Relacional: devolvido antes do prazo
    ('Otávio Lins', 'EX-000005', 30, 20, 12)    -- Dom Casmurro: 8 dias de atraso
) AS e (leitor, tombo, ini, prev, dev);

INSERT INTO multa (emprestimo_id, dias_atraso, valor, paga, gerada_em)
SELECT (SELECT em.id FROM emprestimo em JOIN leitor l ON l.id = em.leitor_id
        WHERE l.nome = m.leitor AND em.data_emprestimo = current_date - m.ini),
       m.dias, m.valor, m.paga, current_date - m.gerada
FROM (VALUES
    ('Nina Prado',  50, 4, 2.00, true,  39),    -- 4 dias x 0,50
    ('Otávio Lins', 30, 8, 2.00, false, 12)     -- 8 dias x 0,25
) AS m (leitor, ini, dias, valor, paga, gerada);

-- ===== Entrada 3 · a tarifa do aluno sobe de 0,50 para 0,75 (vale a partir de 30 dias atrás) =====
INSERT INTO tarifa_multa (tipo_leitor_id, valor_dia, vigencia_inicio)
VALUES ((SELECT id FROM tipo_leitor WHERE nome = 'aluno'), 0.75, current_date - 30);

-- ===== Entrada 4 · empréstimos recentes, multa, reservas e avisos =====
INSERT INTO emprestimo (leitor_id, exemplar_id, data_emprestimo, data_prevista, data_devolucao)
SELECT (SELECT id FROM leitor WHERE nome = e.leitor), (SELECT id FROM exemplar WHERE tombo = e.tombo),
       current_date - e.ini, current_date - e.prev, CASE WHEN e.dev IS NULL THEN NULL ELSE current_date - e.dev END
FROM (VALUES
    ('Caio Ramos',  'EX-000006', 25, 18, 16),     -- Banco de Dados Relacional: 2 dias de atraso, devolvido
    ('Lia Torres',  'EX-000001', 10,  3, NULL),   -- Pedra Filosofal (A): em aberto, 3 dias de atraso
    ('Caio Ramos',  'EX-000003',  5, -2, NULL),   -- Câmara Secreta: em aberto, no prazo (vence daqui a 2 dias)
    ('Helena Vaz',  'EX-000004', 20,  5, NULL),   -- Prisioneiro de Azkaban: em aberto, 5 dias de atraso
    ('Nina Prado',  'EX-000005',  9,  2, NULL)    -- Dom Casmurro: em aberto, 2 dias de atraso
) AS e (leitor, tombo, ini, prev, dev);

INSERT INTO multa (emprestimo_id, dias_atraso, valor, paga, gerada_em)
VALUES ((SELECT em.id FROM emprestimo em JOIN leitor l ON l.id = em.leitor_id
         WHERE l.nome = 'Caio Ramos' AND em.data_emprestimo = current_date - 25), 2, 1.50, true, current_date - 16);   -- 2 dias x 0,75

INSERT INTO reserva (leitor_id, livro_id, criada_em)
SELECT (SELECT id FROM leitor WHERE nome = r.leitor), (SELECT id FROM livro WHERE titulo = 'Harry Potter e o Prisioneiro de Azkaban'),
       now() - r.dias * interval '1 day'
FROM (VALUES ('Nina Prado', 4), ('Otávio Lins', 2)) AS r (leitor, dias);

INSERT INTO notificacao (emprestimo_id, canal, destino, mensagem, situacao, enviada_em)
VALUES
 ((SELECT em.id FROM emprestimo em JOIN leitor l ON l.id = em.leitor_id WHERE l.nome = 'Lia Torres' AND em.data_devolucao IS NULL),
  'email', 'lia.torres@escola.example', 'Seu livro está atrasado.', 'enviada', now() - interval '1 day'),
 ((SELECT em.id FROM emprestimo em JOIN leitor l ON l.id = em.leitor_id WHERE l.nome = 'Helena Vaz' AND em.data_devolucao IS NULL),
  'whatsapp', '(47) 99100-0004', 'Seu livro está atrasado.', 'pendente', NULL);

-- ===== Entrada 5 · um empréstimo lançado por engano =====
-- Paulo Reis «pegou» Redes de Computadores ontem, mas foi engano. Lança e apaga o empréstimo; o exemplar volta a ficar disponível.
INSERT INTO emprestimo (leitor_id, exemplar_id, data_emprestimo, data_prevista)
VALUES ((SELECT id FROM leitor WHERE nome = 'Paulo Reis'), (SELECT id FROM exemplar WHERE tombo = 'EX-000007'),
        current_date - 1, current_date + 9);
UPDATE exemplar SET estado = 'emprestado' WHERE tombo = 'EX-000007';
DELETE FROM emprestimo WHERE leitor_id = (SELECT id FROM leitor WHERE nome = 'Paulo Reis');
UPDATE exemplar SET estado = 'disponivel' WHERE tombo = 'EX-000007';
