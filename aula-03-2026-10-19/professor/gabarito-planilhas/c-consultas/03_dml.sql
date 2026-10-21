-- Planilha C · B.2, B.3 e B.4

-- B.2.1 · trocar o convênio de um paciente (Caio Pires passa para o Bradesco)
SELECT p.nome, c.nome AS convenio FROM paciente p JOIN convenio c USING (cod_convenio) WHERE p.nome = 'Caio Pires';
UPDATE paciente SET cod_convenio = (SELECT cod_convenio FROM convenio WHERE nome = 'Bradesco') WHERE nome = 'Caio Pires';
SELECT p.nome, c.nome AS convenio FROM paciente p JOIN convenio c USING (cod_convenio) WHERE p.nome = 'Caio Pires';

-- B.2.2 · reajuste de 10% nas especialidades com valor base acima de R$ 200: várias linhas
SELECT nome, valor_base FROM especialidade WHERE valor_base > 200 ORDER BY 1;
UPDATE especialidade SET valor_base = round(valor_base * 1.10, 2) WHERE valor_base > 200;
SELECT nome, valor_base FROM especialidade WHERE valor_base > 200 ORDER BY 1;

-- B.3 · apagar a consulta 5 (não há itens)
DELETE FROM consulta WHERE numero = 5;

-- B.4 · os três erros de propósito (cada comando abaixo falha de propósito)
INSERT INTO consulta (numero, data, cod_paciente, cod_medico) VALUES (20, '2026-10-19', 99, 1);
DELETE FROM convenio WHERE nome = 'Unimed';
INSERT INTO paciente (nome, cod_convenio) VALUES (NULL, 1);
