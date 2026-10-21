-- Planilha E · B.2, B.3 e B.4

-- B.2.1 · trocar o fone de um fornecedor
SELECT nome, fone FROM fornecedor WHERE nome = 'Tintas Sol';
UPDATE fornecedor SET fone = '(47) 3999-0002' WHERE nome = 'Tintas Sol';
SELECT nome, fone FROM fornecedor WHERE nome = 'Tintas Sol';

-- B.2.2 · reajuste de 10% no custo dos produtos de um fornecedor: várias linhas
SELECT nome, custo_unit FROM produto WHERE cod_fornecedor = (SELECT cod_fornecedor FROM fornecedor WHERE nome = 'Metalúrgica Sul') ORDER BY 1;
UPDATE produto SET custo_unit = round(custo_unit * 1.10, 2)
 WHERE cod_fornecedor = (SELECT cod_fornecedor FROM fornecedor WHERE nome = 'Metalúrgica Sul');
SELECT nome, custo_unit FROM produto WHERE cod_fornecedor = (SELECT cod_fornecedor FROM fornecedor WHERE nome = 'Metalúrgica Sul') ORDER BY 1;

-- B.3 · apagar a linha da Porca M6 no Depósito Norte (não há itens)
DELETE FROM estoque WHERE cod_produto = 2 AND cod_deposito = 1;

-- B.4 · os três erros de propósito (cada comando abaixo falha de propósito)
INSERT INTO estoque (cod_produto, cod_deposito, quantidade) VALUES (1, 99, 10);
DELETE FROM fornecedor WHERE nome = 'Luz & Cia';
INSERT INTO produto (nome, categoria, custo_unit, cod_fornecedor) VALUES (NULL, 'Fixação', 1, 1);
