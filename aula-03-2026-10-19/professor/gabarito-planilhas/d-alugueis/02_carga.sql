-- Planilha D · carga. Os códigos gerados (1, 2, 3...) seguem a ordem dos INSERT.
-- Dias e total NÃO são guardados: dias = devolucao - retirada; total = dias * soma das diárias cobradas.
INSERT INTO cliente (nome, telefone) VALUES
    ('Hugo Vaz', '(47) 99111-0001'), ('Iara Melo', '(47) 99222-0002'), ('Jonas Reis', '(47) 99333-0003'),
    ('Kátia Dias', '(47) 99444-0004'), ('Lucas Pina', '(47) 99555-0005');

INSERT INTO equipamento (descricao, diaria) VALUES
    ('Furadeira', 30), ('Escada', 20), ('Betoneira', 80), ('Serra circular', 45), ('Andaime', 60);

INSERT INTO contrato (numero, retirada, devolucao, cod_cliente) VALUES
    ('L-01', '2026-10-01', '2026-10-03', 1), ('L-02', '2026-10-02', '2026-10-05', 2),
    ('L-03', '2026-10-04', '2026-10-05', 1), ('L-04', '2026-10-06', '2026-10-09', 3),
    ('L-05', '2026-10-07', '2026-10-08', 2), ('L-06', '2026-10-08', '2026-10-10', 4);

INSERT INTO item_contrato (numero, cod_equipamento, diaria_cobrada) VALUES
    ('L-01', 1, 30), ('L-01', 2, 20),
    ('L-02', 3, 80),
    ('L-03', 2, 20),
    ('L-04', 1, 30), ('L-04', 3, 80), ('L-04', 2, 20),
    ('L-05', 1, 30),
    ('L-06', 3, 80), ('L-06', 2, 20);
