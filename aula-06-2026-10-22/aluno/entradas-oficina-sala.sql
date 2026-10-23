-- Oficina Mecânica · entradas-oficina-sala.sql
-- Exemplo guiado da aula 6 (segundo tempo): o professor carrega a Oficina ao vivo, seguindo as Entradas 1, 2 e 4 do pedido de validação.
-- Rode DEPOIS do 01_ddl.sql, num banco recém-criado. Para repetir: rode o 01_ddl.sql de novo e depois este arquivo.
-- As Entradas 3 (reajuste) e 5 (correção) ficam para a aula 7: elas usam UPDATE e DELETE.
-- As datas usam um mês qualquer (o pedido dá só o dia); aqui, março de 2025. Cada aluno escolhe o seu mês.

SET search_path TO oficina;

-- ===== Entrada 1 · cadastros (as tabelas «pai» primeiro) =====

-- Várias linhas em um comando só. A coluna id NÃO entra: o banco numera sozinho (1, 2, 3...).
INSERT INTO cliente (nome, telefone) VALUES
    ('Ana Souza',    '(47) 99111-0001'),   -- id 1
    ('Bruno Reis',   '(47) 99222-0002'),   -- id 2
    ('Carla Dias',   '(47) 99333-0003'),   -- id 3
    ('Davi Lopes',   '(47) 99444-0004'),   -- id 4
    ('Eva Costa',    '(47) 99555-0005'),   -- id 5
    ('Fábio Mendes', '(47) 99666-0006');   -- id 6 (ainda sem veículo)

INSERT INTO modelo (nome, marca) VALUES
    ('Gol',     'Volkswagen'),   -- id 1
    ('Onix',    'Chevrolet'),    -- id 2
    ('Uno',     'Fiat'),         -- id 3
    ('Civic',   'Honda'),        -- id 4
    ('Corolla', 'Toyota');       -- id 5

-- especialidade pode ficar vazia: o Paulo entra com NULL
INSERT INTO mecanico (nome, especialidade) VALUES
    ('Carlos Lima', 'Motor'),       -- id 1
    ('Marta Alves', 'Suspensão'),   -- id 2
    ('Paulo Neri',  NULL),          -- id 3
    ('Rita Gomes',  'Freios');      -- id 4 (ainda sem nenhuma OS)

INSERT INTO servico (descricao, valor) VALUES
    ('Troca de óleo',      120.00),   -- id 1
    ('Alinhamento',         90.00),   -- id 2
    ('Troca de pastilhas', 180.00),   -- id 3
    ('Troca de filtro',     60.00),   -- id 4
    ('Balanceamento',       80.00),   -- id 5
    ('Revisão completa',   350.00);   -- id 6 (nunca será feita nos dados do pedido)

-- veiculo depende de modelo e de cliente: vem DEPOIS deles. modelo_id e cliente_id são os ids acima.
INSERT INTO veiculo (placa, modelo_id, cliente_id) VALUES
    ('ABC1D23', 1, 1),   -- Gol da Ana          (id 1)
    ('DEF4G56', 3, 1),   -- Uno da Ana          (id 2)
    ('XYZ9K88', 2, 2),   -- Onix do Bruno       (id 3)
    ('QWE4R56', 2, 3),   -- Onix da Carla       (id 4)
    ('HND2E45', 4, 4),   -- Civic do Davi       (id 5)
    ('TYT7F90', 5, 5);   -- Corolla da Eva      (id 6)

-- ===== Entrada 2 · ordens de serviço 1001 a 1006 =====

-- veiculo_id e mecanico_id são ids, não placa nem nome. O «numero» é o número da OS (1001...), diferente do id (1, 2, 3...).
INSERT INTO ordem_servico (numero, data_abertura, veiculo_id, mecanico_id) VALUES
    (1001, '2025-03-02', 1, 1),   -- ABC1D23, Carlos
    (1002, '2025-03-02', 3, 2),   -- XYZ9K88, Marta
    (1003, '2025-03-05', 1, 2),   -- ABC1D23, Marta
    (1004, '2025-03-06', 4, 1),   -- QWE4R56, Carlos
    (1005, '2025-03-07', 3, 1),   -- XYZ9K88, Carlos
    (1006, '2025-03-08', 5, 2);   -- HND2E45, Marta

-- item_servico liga a OS ao serviço e guarda o valor COBRADO. ordem_servico_id é o id da OS, não o numero:
-- por isso procuramos o id pelo numero com uma subconsulta, que é mais seguro do que contar de cabeça.
INSERT INTO item_servico (ordem_servico_id, servico_id, valor_cobrado) VALUES
    ((SELECT id FROM ordem_servico WHERE numero = 1001), 1, 120.00),   -- Troca de óleo
    ((SELECT id FROM ordem_servico WHERE numero = 1001), 2,  90.00),   -- Alinhamento
    ((SELECT id FROM ordem_servico WHERE numero = 1002), 2,  90.00),
    ((SELECT id FROM ordem_servico WHERE numero = 1003), 3, 180.00),   -- Troca de pastilhas
    ((SELECT id FROM ordem_servico WHERE numero = 1004), 1, 120.00),
    ((SELECT id FROM ordem_servico WHERE numero = 1004), 4,  60.00),   -- Troca de filtro
    ((SELECT id FROM ordem_servico WHERE numero = 1005), 1, 120.00),
    ((SELECT id FROM ordem_servico WHERE numero = 1006), 2,  70.00),   -- Alinhamento com desconto: a tabela diz 90
    ((SELECT id FROM ordem_servico WHERE numero = 1006), 5,  80.00);   -- Balanceamento

-- ===== Entrada 4 · ordens de serviço 1007 a 1010 =====
-- (a Entrada 3, o reajuste da troca de óleo, é UPDATE: aula 7. Aqui o valor cobrado já vem como 135.)

INSERT INTO ordem_servico (numero, data_abertura, veiculo_id, mecanico_id) VALUES
    (1007, '2025-03-12', 2, 1),   -- DEF4G56, Carlos
    (1008, '2025-03-13', 4, 2),   -- QWE4R56, Marta (aberta por engano; a aula 7 apaga)
    (1009, '2025-03-14', 3, 3),   -- XYZ9K88, Paulo
    (1010, '2025-03-20', 1, 1);   -- ABC1D23, Carlos (nenhum serviço lançado ainda)

INSERT INTO item_servico (ordem_servico_id, servico_id, valor_cobrado) VALUES
    ((SELECT id FROM ordem_servico WHERE numero = 1007), 1, 135.00),   -- Troca de óleo já a 135
    ((SELECT id FROM ordem_servico WHERE numero = 1007), 4,  60.00),
    ((SELECT id FROM ordem_servico WHERE numero = 1008), 5,  80.00),
    ((SELECT id FROM ordem_servico WHERE numero = 1009), 4,  60.00),
    ((SELECT id FROM ordem_servico WHERE numero = 1009), 5,  80.00);

-- ===== Conferir =====
SELECT 'cliente' AS tabela, count(*) FROM cliente
UNION ALL SELECT 'modelo', count(*) FROM modelo
UNION ALL SELECT 'mecanico', count(*) FROM mecanico
UNION ALL SELECT 'servico', count(*) FROM servico
UNION ALL SELECT 'veiculo', count(*) FROM veiculo
UNION ALL SELECT 'ordem_servico', count(*) FROM ordem_servico
UNION ALL SELECT 'item_servico', count(*) FROM item_servico;
-- esperado: 6, 5, 4, 6, 6, 10 e 14

-- ===== Erros de propósito (rode UM de cada vez, no banco já carregado) =====

-- Erro 1 · ordem errada (num banco recém-criado, ANTES de cadastrar o cliente):
--   INSERT INTO veiculo (placa, modelo_id, cliente_id) VALUES ('ABC1D23', 1, 1);
--   -> violates foreign key constraint: o cliente 1 ainda não existe.

-- R1 · OS para um veículo que não existe (o veículo 9999 não está cadastrado):
--   INSERT INTO ordem_servico (numero, data_abertura, veiculo_id, mecanico_id) VALUES (1011, '2025-03-21', 9999, 1);
--   -> violates foreign key constraint: Key (veiculo_id)=(9999) is not present in table "veiculo".

-- Erro 3 · número da OS repetido (numero é UNIQUE):
--   INSERT INTO ordem_servico (numero, data_abertura, veiculo_id, mecanico_id) VALUES (1001, '2025-03-21', 1, 1);
--   -> duplicate key value violates unique constraint.

-- Erro 4 · campo obrigatório vazio (telefone é NOT NULL):
--   INSERT INTO cliente (nome, telefone) VALUES ('Gil Prado', NULL);
--   -> null value in column "telefone" violates not-null constraint.
