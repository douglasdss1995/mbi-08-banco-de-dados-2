-- Planilha D · B.2, B.3 e B.4

-- B.2.1 · trocar o telefone de um cliente
SELECT nome, telefone FROM cliente WHERE nome = 'Hugo Vaz';
UPDATE cliente SET telefone = '(47) 99999-0001' WHERE nome = 'Hugo Vaz';
SELECT nome, telefone FROM cliente WHERE nome = 'Hugo Vaz';

-- B.2.2 · reajuste de 10% na diária dos equipamentos mais caros (a partir de R$ 45): várias linhas
SELECT descricao, diaria FROM equipamento WHERE diaria >= 45 ORDER BY 1;
UPDATE equipamento SET diaria = round(diaria * 1.10, 2) WHERE diaria >= 45;
SELECT descricao, diaria FROM equipamento WHERE diaria >= 45 ORDER BY 1;

-- B.3 · apagar o contrato L-06: primeiro os itens, depois o contrato
DELETE FROM item_contrato WHERE numero = 'L-06';
DELETE FROM contrato      WHERE numero = 'L-06';

-- B.4 · os três erros de propósito (cada comando abaixo falha de propósito)
INSERT INTO item_contrato (numero, cod_equipamento, diaria_cobrada) VALUES ('L-01', 99, 10);
DELETE FROM cliente WHERE nome = 'Hugo Vaz';
INSERT INTO cliente (nome, telefone) VALUES (NULL, '(47) 90000-0000');
