-- Oficina Mecânica · entradas-oficina.sql
-- Exemplo guiado: o professor carrega a Oficina por completo (as 5 entradas do pedido de validação) e compartilha com a turma.
-- Aula 6: Entradas 1, 2 e 4 (INSERT). Aula 7: Entradas 3 e 5 (UPDATE e DELETE).
-- As 5 entradas do pedido de validação, na ordem, em um arquivo só (é o que o aluno entrega no Classroom).
-- Rode num banco com a estrutura criada e SEM dados (01_ddl.sql). Para repetir, rode o 01_ddl.sql antes.
-- Datas: o pedido dá só o DIA; o mês é o mês corrente (inicio do mês + dia - 1), assim o arquivo serve em qualquer período.
SET search_path TO oficina;

-- ===== Entrada 1 · cadastros =====
INSERT INTO cliente (nome, telefone) VALUES
    ('Ana Souza',    '(47) 99111-0001'),
    ('Bruno Reis',   '(47) 99222-0002'),
    ('Carla Dias',   '(47) 99333-0003'),
    ('Davi Lopes',   '(47) 99444-0004'),
    ('Eva Costa',    '(47) 99555-0005'),
    ('Fábio Mendes', '(47) 99666-0006');

INSERT INTO modelo (nome, marca) VALUES
    ('Gol', 'Volkswagen'), ('Onix', 'Chevrolet'), ('Uno', 'Fiat'), ('Civic', 'Honda'), ('Corolla', 'Toyota');

INSERT INTO veiculo (placa, modelo_id, cliente_id) VALUES
    ('ABC1D23', (SELECT id FROM modelo WHERE nome = 'Gol'),     (SELECT id FROM cliente WHERE nome = 'Ana Souza')),
    ('DEF4G56', (SELECT id FROM modelo WHERE nome = 'Uno'),     (SELECT id FROM cliente WHERE nome = 'Ana Souza')),
    ('XYZ9K88', (SELECT id FROM modelo WHERE nome = 'Onix'),    (SELECT id FROM cliente WHERE nome = 'Bruno Reis')),
    ('QWE4R56', (SELECT id FROM modelo WHERE nome = 'Onix'),    (SELECT id FROM cliente WHERE nome = 'Carla Dias')),
    ('HND2E45', (SELECT id FROM modelo WHERE nome = 'Civic'),   (SELECT id FROM cliente WHERE nome = 'Davi Lopes')),
    ('TYT7F90', (SELECT id FROM modelo WHERE nome = 'Corolla'), (SELECT id FROM cliente WHERE nome = 'Eva Costa'));

INSERT INTO mecanico (nome, especialidade) VALUES
    ('Carlos Lima', 'Motor'), ('Marta Alves', 'Suspensão'), ('Paulo Neri', NULL), ('Rita Gomes', 'Freios');

INSERT INTO servico (descricao, valor) VALUES
    ('Troca de óleo', 120.00), ('Alinhamento', 90.00), ('Troca de pastilhas', 180.00),
    ('Troca de filtro', 60.00), ('Balanceamento', 80.00), ('Revisão completa', 350.00);

-- ===== Entrada 2 · ordens de serviço 1001 a 1006 =====
WITH m AS (SELECT date_trunc('month', current_date)::date AS ini)
INSERT INTO ordem_servico (numero, data_abertura, veiculo_id, mecanico_id)
SELECT o.numero, m.ini + o.dia - 1,
       (SELECT id FROM veiculo  WHERE placa = o.placa),
       (SELECT id FROM mecanico WHERE nome  = o.mecanico)
FROM m, (VALUES
    (1001, 2, 'ABC1D23', 'Carlos Lima'),
    (1002, 2, 'XYZ9K88', 'Marta Alves'),
    (1003, 5, 'ABC1D23', 'Marta Alves'),
    (1004, 6, 'QWE4R56', 'Carlos Lima'),
    (1005, 7, 'XYZ9K88', 'Carlos Lima'),
    (1006, 8, 'HND2E45', 'Marta Alves')
) AS o (numero, dia, placa, mecanico);

INSERT INTO item_servico (ordem_servico_id, servico_id, valor_cobrado)
SELECT (SELECT id FROM ordem_servico WHERE numero = i.numero),
       (SELECT id FROM servico WHERE descricao = i.servico), i.valor
FROM (VALUES
    (1001, 'Troca de óleo', 120.00), (1001, 'Alinhamento', 90.00),
    (1002, 'Alinhamento', 90.00),
    (1003, 'Troca de pastilhas', 180.00),
    (1004, 'Troca de óleo', 120.00), (1004, 'Troca de filtro', 60.00),
    (1005, 'Troca de óleo', 120.00),
    (1006, 'Alinhamento', 70.00),    -- desconto: a tabela diz 90
    (1006, 'Balanceamento', 80.00)
) AS i (numero, servico, valor);

-- ===== Entrada 3 · reajuste: troca de óleo de 120 para 135 =====
UPDATE servico SET valor = 135.00 WHERE descricao = 'Troca de óleo';

-- ===== Entrada 4 · ordens de serviço 1007 a 1010 =====
WITH m AS (SELECT date_trunc('month', current_date)::date AS ini)
INSERT INTO ordem_servico (numero, data_abertura, veiculo_id, mecanico_id)
SELECT o.numero, m.ini + o.dia - 1,
       (SELECT id FROM veiculo  WHERE placa = o.placa),
       (SELECT id FROM mecanico WHERE nome  = o.mecanico)
FROM m, (VALUES
    (1007, 12, 'DEF4G56', 'Carlos Lima'),
    (1008, 13, 'QWE4R56', 'Marta Alves'),
    (1009, 14, 'XYZ9K88', 'Paulo Neri'),
    (1010, 20, 'ABC1D23', 'Carlos Lima')
) AS o (numero, dia, placa, mecanico);

INSERT INTO item_servico (ordem_servico_id, servico_id, valor_cobrado)
SELECT (SELECT id FROM ordem_servico WHERE numero = i.numero),
       (SELECT id FROM servico WHERE descricao = i.servico), i.valor
FROM (VALUES
    (1007, 'Troca de óleo', 135.00), (1007, 'Troca de filtro', 60.00),
    (1008, 'Balanceamento', 80.00),
    (1009, 'Troca de filtro', 60.00), (1009, 'Balanceamento', 80.00)
    -- 1010: nenhum serviço lançado ainda
) AS i (numero, servico, valor);

-- ===== Entrada 5 · a OS 1008 foi aberta por engano: sai com tudo o que pertence a ela =====
DELETE FROM item_servico  WHERE ordem_servico_id = (SELECT id FROM ordem_servico WHERE numero = 1008);
DELETE FROM ordem_servico WHERE numero = 1008;
