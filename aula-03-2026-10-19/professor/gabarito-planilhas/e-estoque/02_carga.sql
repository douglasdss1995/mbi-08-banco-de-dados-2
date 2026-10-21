-- Planilha E · carga. Os códigos gerados (1, 2, 3...) seguem a ordem dos INSERT.
INSERT INTO fornecedor (nome, fone) VALUES
    ('Metalúrgica Sul', '(47) 3001-0001'), ('Tintas Sol', '(47) 3002-0002'), ('Luz & Cia', '(47) 3003-0003'),
    ('Ferragens Vale', '(47) 3004-0004'), ('Plásticos Norte', '(47) 3005-0005');

INSERT INTO produto (nome, categoria, custo_unit, cod_fornecedor) VALUES
    ('Parafuso M6', 'Fixação', 0.20, 1), ('Porca M6', 'Fixação', 0.15, 1),
    ('Tinta branca 18 L', 'Pintura', 210.00, 2), ('Pincel 2 polegadas', 'Pintura', 6.50, 2),
    ('Lâmpada LED 9 W', 'Elétrica', 7.90, 3);

INSERT INTO deposito (nome, cidade) VALUES
    ('Depósito Norte', 'Joinville'), ('Depósito Sul', 'Blumenau'), ('Depósito Leste', 'Itajaí'),
    ('Depósito Oeste', 'Chapecó'), ('Depósito Central', 'Florianópolis');

INSERT INTO estoque (cod_produto, cod_deposito, quantidade) VALUES
    (1, 1, 500), (1, 2, 300), (2, 1, 450), (3, 2, 40), (3, 1, 25), (4, 2, 120), (5, 1, 200), (5, 2, 180);
