-- Planilha A · B.2, B.3 e B.4

-- B.2.1 · trocar a cidade de um cliente (Teo Alves passa a ser de Curitiba)
SELECT c.nome, ci.nome AS cidade FROM cliente c JOIN cidade ci USING (cod_cidade) WHERE c.nome = 'Teo Alves';
UPDATE cliente SET cod_cidade = (SELECT cod_cidade FROM cidade WHERE nome = 'Curitiba') WHERE nome = 'Teo Alves';
SELECT c.nome, ci.nome AS cidade FROM cliente c JOIN cidade ci USING (cod_cidade) WHERE c.nome = 'Teo Alves';

-- B.2.2 · reajuste de 10% nos produtos mais baratos (preço abaixo de R$ 20): várias linhas
SELECT cod_produto, descricao, preco FROM produto WHERE preco < 20 ORDER BY 1;
UPDATE produto SET preco = round(preco * 1.10, 2) WHERE preco < 20;
SELECT cod_produto, descricao, preco FROM produto WHERE preco < 20 ORDER BY 1;

-- B.3 · apagar o pedido 104: primeiro os itens, depois o pedido
DELETE FROM item_pedido WHERE numero = 104;
DELETE FROM pedido      WHERE numero = 104;

-- B.4 · os três erros de propósito (cada comando abaixo falha de propósito)
INSERT INTO pedido (numero, data, cod_cliente, cod_vendedor) VALUES (200, '2026-10-19', 99, 1);
DELETE FROM cliente WHERE nome = 'Lia Prado';
INSERT INTO cliente (nome, cod_cidade) VALUES (NULL, 1);
