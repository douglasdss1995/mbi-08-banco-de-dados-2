-- Planilha C · carga. Os códigos gerados (1, 2, 3...) seguem a ordem dos INSERT.
-- O valor final da consulta NÃO é guardado: calcula-se valor_base * (1 - desconto / 100).
INSERT INTO convenio (nome, desconto) VALUES
    ('Unimed', 30), ('Particular', 0), ('Bradesco', 20), ('Amil', 25), ('SulAmérica', 15);

INSERT INTO paciente (nome, cod_convenio) VALUES
    ('Maria Souza', 1), ('João Ramos', 2), ('Rita Gomes', 3), ('Caio Pires', 1), ('Lara Teles', 4);

INSERT INTO especialidade (nome, valor_base) VALUES
    ('Cardiologia', 300), ('Dermatologia', 250), ('Pediatria', 200), ('Ortopedia', 280), ('Oftalmologia', 220);

INSERT INTO medico (nome, cod_especialidade) VALUES
    ('Dr. Paulo', 1), ('Dra. Lúcia', 2), ('Dr. Renato', 3), ('Dra. Vera', 4), ('Dr. Otávio', 5);

INSERT INTO consulta (numero, data, cod_paciente, cod_medico) VALUES
    (1, '2026-10-05', 1, 1), (2, '2026-10-05', 2, 2), (3, '2026-10-06', 1, 2), (4, '2026-10-06', 3, 1),
    (5, '2026-10-07', 4, 3), (6, '2026-10-07', 2, 3), (7, '2026-10-08', 3, 2);
