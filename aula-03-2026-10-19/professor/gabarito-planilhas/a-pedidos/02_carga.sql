-- Planilha A · carga. Os códigos gerados (1, 2, 3...) seguem a ordem dos INSERT.
INSERT INTO cidade (nome, estado) VALUES
    ('Joinville', 'SC'), ('Blumenau', 'SC'), ('Curitiba', 'PR'), ('Florianópolis', 'SC'), ('Londrina', 'PR');

INSERT INTO cliente (nome, cod_cidade) VALUES
    ('Lia Prado', 1), ('Teo Alves', 2), ('Bia Nunes', 3), ('Davi Lopes', 3), ('Nina Rocha', 4);

INSERT INTO vendedor (nome) VALUES ('Rui'), ('Ana'), ('Paulo'), ('Marta'), ('Caio');

INSERT INTO produto (descricao, preco) VALUES
    ('Caderno 10 matérias', 18.00), ('Caneta azul', 2.50), ('Mochila', 120.00),
    ('Papel A4 (resma)', 28.00), ('Lápis de cor (caixa)', 15.00);

INSERT INTO pedido (numero, data, cod_cliente, cod_vendedor) VALUES
    (101, '2026-10-05', 1, 1), (102, '2026-10-05', 2, 1), (103, '2026-10-06', 1, 2),
    (104, '2026-10-07', 3, 2), (105, '2026-10-08', 2, 1), (106, '2026-10-08', 4, 2);

INSERT INTO item_pedido (numero, cod_produto, quantidade, preco_cobrado) VALUES
    (101, 1, 2, 18.00), (101, 2, 10, 2.50),
    (102, 2, 5, 2.50),
    (103, 3, 1, 120.00), (103, 1, 1, 18.00),
    (104, 4, 3, 28.00),
    (105, 4, 2, 28.00), (105, 2, 20, 2.50),
    (106, 3, 1, 120.00);
