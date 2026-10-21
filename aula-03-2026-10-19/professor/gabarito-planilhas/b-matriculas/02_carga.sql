-- Planilha B · carga. Os códigos gerados (1, 2, 3...) seguem a ordem dos INSERT.
INSERT INTO aluno (nome) VALUES ('Ana Lima'), ('Bruno Reis'), ('Carla Dias'), ('Davi Souza'), ('Eva Costa');

INSERT INTO professor (nome, fone) VALUES
    ('Marcos Silva', '(47) 99001-0001'), ('Clara Mendes', '(47) 99002-0002'), ('Júlia Rocha', '(47) 99003-0003'),
    ('Pedro Lara', '(47) 99004-0004'), ('Sara Nunes', '(47) 99005-0005');

INSERT INTO turma (cod_turma, idioma, nivel, cod_professor, sala, dia_semana, horario) VALUES
    ('T-ING1', 'Inglês',   'Básico',        1, 'Sala 3', 'Seg e Qua', '19:00'),
    ('T-ING2', 'Inglês',   'Intermediário', 1, 'Sala 2', 'Ter e Qui', '20:00'),
    ('T-ESP1', 'Espanhol', 'Básico',        2, 'Sala 1', 'Ter e Qui', '19:00'),
    ('T-FRA1', 'Francês',  'Básico',        3, 'Sala 1', 'Sex',       '18:00'),
    ('T-ALE1', 'Alemão',   'Básico',        4, 'Sala 4', 'Seg e Qua', '20:00');

INSERT INTO matricula (cod_aluno, cod_turma, data_matricula, nota_final) VALUES
    (1, 'T-ING1', '2026-10-01', 8.5), (1, 'T-ESP1', '2026-10-01', 9.0),
    (2, 'T-ING1', '2026-10-02', 7.0), (3, 'T-ING2', '2026-10-02', 6.5),
    (3, 'T-ESP1', '2026-10-03', 8.0), (4, 'T-ING2', '2026-10-03', 9.5),
    (4, 'T-FRA1', '2026-10-04', 7.5), (5, 'T-ING1', '2026-10-04', 10.0);
