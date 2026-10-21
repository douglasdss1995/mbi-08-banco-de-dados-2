-- Planilha B · B.2, B.3 e B.4

-- B.2.1 · trocar o fone de um professor
SELECT nome, fone FROM professor WHERE nome = 'Clara Mendes';
UPDATE professor SET fone = '(47) 99888-0002' WHERE nome = 'Clara Mendes';
SELECT nome, fone FROM professor WHERE nome = 'Clara Mendes';

-- B.2.2 · trocar a sala de todas as turmas de um professor: várias linhas
SELECT cod_turma, sala FROM turma WHERE cod_professor = (SELECT cod_professor FROM professor WHERE nome = 'Marcos Silva');
UPDATE turma SET sala = 'Sala 5' WHERE cod_professor = (SELECT cod_professor FROM professor WHERE nome = 'Marcos Silva');
SELECT cod_turma, sala FROM turma WHERE cod_professor = (SELECT cod_professor FROM professor WHERE nome = 'Marcos Silva');

-- B.3 · apagar a matrícula da Eva na turma T-ING1 (não há itens)
DELETE FROM matricula WHERE cod_aluno = 5 AND cod_turma = 'T-ING1';

-- B.4 · os três erros de propósito (cada comando abaixo falha de propósito)
INSERT INTO matricula (cod_aluno, cod_turma) VALUES (99, 'T-ING1');
DELETE FROM professor WHERE nome = 'Marcos Silva';
INSERT INTO aluno (nome) VALUES (NULL);
