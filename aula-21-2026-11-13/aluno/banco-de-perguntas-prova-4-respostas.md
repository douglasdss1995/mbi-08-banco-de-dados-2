# Banco de perguntas da prova 4 — perguntas e respostas

Banco de Dados 2 · Turma MBI-08

**Antes de abrir este arquivo**, leia todas as perguntas em [banco-de-perguntas-prova-4.md](banco-de-perguntas-prova-4.md) e tente responder cada uma sozinho. Só depois venha conferir aqui.

Na prova, responda **com as suas palavras**: o que é, para que serve e um exemplo. Não decore o texto daqui.

Siglas: SQL: *Structured Query Language*. DDL: *Data Definition Language*. DML: *Data Manipulation Language*. PK: *Primary Key* (chave primária). FK: *Foreign Key* (chave estrangeira). MER: Modelo Entidade-Relacionamento. CTE: *Common Table Expression*. PL/pgSQL: *Procedural Language/PostgreSQL*. 1FN, 2FN, 3FN: primeira, segunda e terceira formas normais.

## Parte 1 · Modelo e normalização (1 a 12)

**1. O que é uma tabela, uma linha e uma coluna?**  
	A tabela guarda um tipo de coisa (por exemplo, `cliente`). Cada linha é uma coisa daquele tipo (um cliente). Cada coluna é uma informação sobre ela (`nome`, `email`).

**2. O que é uma chave primária (PK)? Por que toda tabela precisa de uma?**  
	É a coluna que identifica cada linha: não repete e não fica vazia. Sem ela, não dá para achar ou ligar uma linha com certeza. Exemplo: `cliente.id`.

**3. O que é uma chave estrangeira (FK)?**  
	É a coluna que guarda a PK de outra tabela e liga as duas. O banco não aceita um valor que não existe na outra tabela. Exemplo: `pedido.cliente_id` aponta para `cliente.id`.

**4. O que é um MER (o diagrama do modelo)?**  
	É o desenho das tabelas, das colunas e das ligações entre elas. Ele mostra o banco antes de escrever o SQL.

**5. O que é um relacionamento 1:N? Dê um exemplo da loja.**  
	Uma linha de uma tabela se liga a várias de outra. Um cliente tem vários pedidos, e cada pedido é de um cliente só. A FK fica no lado N: `pedido.cliente_id`.

**6. O que é um relacionamento N:N? Como ele vira tabela?**  
	Muitos de um lado se ligam a muitos do outro. Um pedido tem vários produtos, e um produto está em vários pedidos. Vira uma tabela de ligação com as duas FK: `item_pedido` (`pedido_id`, `produto_id`).

**7. Para que serve a normalização?**  
	Para separar os dados em tabelas e não repetir a mesma informação. Assim, mudar um dado muda num lugar só, e o banco não se contradiz.

**8. Que problema a planilha com tudo junto causa?**  
	O mesmo dado aparece em várias linhas (o nome do cliente em cada pedido). Se mudar em uma linha e não nas outras, a planilha passa a mentir.

**9. O que a 1FN (primeira forma normal) pede?**  
	Cada célula guarda um valor só. Nada de «telefone 1, telefone 2» na mesma coluna nem de listas separadas por vírgula.

**10. O que a 2FN (segunda forma normal) pede?**  
	Que cada coluna dependa da chave inteira. Numa tabela com chave de duas colunas (`pedido_id`, `produto_id`), o nome do produto depende só do produto, então vai para `produto`.

**11. O que a 3FN (terceira forma normal) pede?**  
	Que uma coluna não dependa de outra coluna que não é a chave. Exemplo: o nome da categoria não fica em `produto`; fica em `categoria`, e o produto guarda `categoria_id`.

**12. O que é um dicionário de dados?**  
	A descrição de cada tabela e de cada coluna: nome, tipo, se aceita vazio, se é PK ou FK e o que significa. É dele que sai o `CREATE TABLE`.

## Parte 2 · DDL, tipos e regras (13 a 28)

**13. Qual a diferença entre DDL e DML?**  
	DDL cria e muda a estrutura: `CREATE TABLE`, `ALTER TABLE`, `DROP TABLE`. DML mexe nos dados: `INSERT`, `UPDATE`, `DELETE` e `SELECT`.

**14. O que faz o `CREATE TABLE`?**  
	Cria uma tabela, com as colunas, os tipos e as regras de cada uma. Exemplo: `CREATE TABLE categoria (id integer ..., nome varchar(50) NOT NULL);`.

**15. O que é um schema? Para que serve o `SET search_path`?**  
	O schema é uma pasta de tabelas dentro do banco (a loja usa o schema `loja`). O `SET search_path TO loja;` diz onde procurar as tabelas, para não escrever `loja.cliente` toda vez.

**16. O que significa `GENERATED ALWAYS AS IDENTITY`?**  
	O banco numera a coluna sozinho (1, 2, 3...). Você não informa o `id` no `INSERT`; se informar, o banco recusa.

**17. Por que preferir `IDENTITY` a `serial`?**  
	O `IDENTITY` é o padrão do SQL, recusa o número digitado à mão e a sequência faz parte da coluna. O `serial` é um atalho antigo do PostgreSQL.

**18. Quando usar `varchar(n)` e quando usar `char(n)`?**  
	`varchar(n)` para textos de tamanho variado, até `n` letras (nome, e-mail). `char(n)` para textos de tamanho fixo (UF com 2 letras, CPF com 11).

**19. Por que usar `numeric(10,2)` para dinheiro?**  
	Porque guarda o valor exato, com 2 casas decimais. Tipos aproximados podem errar nos centavos.

**20. Para que servem os tipos `date`, `timestamp` e `boolean`?**  
	`date` guarda só a data; `timestamp`, a data e a hora; `boolean`, verdadeiro ou falso (`produto.ativo`).

**21. O que faz o `NOT NULL`?**  
	Torna a coluna obrigatória: o banco recusa a linha sem esse valor. Exemplo: `cliente.nome`.

**22. O que faz o `UNIQUE`?**  
	Impede que o valor se repita na tabela. Exemplo: dois clientes não podem ter o mesmo `email`.

**23. O que faz o `DEFAULT`?**  
	Dá um valor quando o `INSERT` não informa a coluna. Exemplo: `status` começa como `'carrinho'`.

**24. O que faz o `CHECK`?**  
	Recusa a linha que não obedece a uma condição. Exemplo: `CHECK (estoque >= 0)` não deixa o estoque ficar negativo.

**25. O que faz o `REFERENCES` numa coluna?**  
	Cria a FK: liga a coluna à PK de outra tabela. Exemplo: `cliente_id integer NOT NULL REFERENCES cliente (id)`.

**26. Por que a ordem dos `CREATE TABLE` importa?**  
	A tabela citada no `REFERENCES` precisa existir antes. Primeiro `cliente`, depois `pedido`; senão aparece o erro «relação não existe».

**27. O que diz o guia de estilo sobre os nomes?**  
	Letras minúsculas com `_` entre as palavras (`data_nascimento`), sem acento e sem espaço, sem prefixo como `tbl_`, e a FK como `tabela_id` (`cliente_id`).

**28. O que acontece ao apagar um «pai» que tem «filhos» (`ON DELETE`)?**  
	Por padrão, o banco recusa. Com `CASCADE`, apaga os filhos junto; com `SET NULL`, deixa a FK do filho vazia.

## Parte 3 · `INSERT`, `UPDATE` e `DELETE` (29 a 36)

**29. Para que serve o `INSERT`? Como inserir várias linhas de uma vez?**  
	Cadastra linhas novas. Para várias, separe os parênteses do `VALUES` por vírgula: `INSERT INTO categoria (nome) VALUES ('Áudio'), ('Vídeo');`.

**30. Por que a ordem das colunas no `INSERT` importa?**  
	Os valores entram na ordem das colunas listadas. Se trocar a ordem, o nome vai para o e-mail, por exemplo.

**31. Por que cadastrar a tabela «pai» antes da «filha»?**  
	A filha guarda o id do pai na FK. Se o pai ainda não existe, o banco recusa o `INSERT` da filha.

**32. Para que serve o `UPDATE`?**  
	Muda valores de linhas que já existem. Exemplo: `UPDATE pedido SET status = 'enviado' WHERE id = 2;`.

**33. O que acontece num `UPDATE` sem `WHERE`?**  
	Muda **todas** as linhas da tabela. Por isso, rode antes um `SELECT` com o mesmo `WHERE` para ver o que vai mudar.

**34. Para que serve o `DELETE`?**  
	Apaga linhas. Exemplo: `DELETE FROM avaliacao WHERE id = 10;`. Sem `WHERE`, apaga todas.

**35. Por que apagar primeiro as linhas «filhas»?**  
	Se um pedido ainda tem itens, apagar o pedido viola a FK de `item_pedido`. Apaga-se primeiro o item, depois o pedido.

**36. O que significa a mensagem `UPDATE 0`?**  
	O `WHERE` não achou nenhuma linha: o valor está escrito diferente (acento, espaço) ou a linha não existe.

## Parte 4 · `SELECT` (37 a 50)

**37. Para que serve o `SELECT`?**  
	Para consultar dados. Ele diz quais colunas aparecem: `SELECT nome, email FROM cliente;`.

**38. Para que serve o `FROM`?**  
	Diz de qual tabela vêm as linhas.

**39. Para que serve o `WHERE`?**  
	Filtra as linhas. Exemplo: `SELECT * FROM pedido WHERE status = 'pago';`.

**40. Por que evitar o `SELECT *` na entrega?**  
	Ele traz todas as colunas, até as que não interessam. É bom para olhar a tabela; na resposta, liste só as colunas pedidas.

**41. Para que serve o `ORDER BY`? O que o `DESC` faz?**  
	Ordena o resultado. `DESC` põe do maior para o menor: `ORDER BY total DESC`.

**42. Para que serve o `AS`?**  
	Dá um apelido a uma coluna ou tabela: `SUM(total) AS faturamento`, ou `cliente AS c`.

**43. O que fazem o `AND`, o `OR` e o `NOT`?**  
	`AND` exige as duas condições; `OR`, pelo menos uma; `NOT` inverte. Ao misturar `AND` e `OR`, use parênteses.

**44. Para que serve o `IN`?**  
	Testa se o valor está numa lista: `WHERE status IN ('pago', 'enviado', 'entregue')`.

**45. Para que serve o `BETWEEN`?**  
	Testa se o valor está entre dois limites, incluindo as duas pontas: `WHERE total BETWEEN 100 AND 200`.

**46. Para que serve o `LIKE`? O que o `%` significa?**  
	Busca texto por um padrão. O `%` é «qualquer coisa»: `WHERE nome LIKE 'Mouse%'` acha os nomes que começam com «Mouse».

**47. Por que se escreve `IS NULL`, e não `= NULL`?**  
	`NULL` é «sem valor»; comparar com `=` não dá verdadeiro nem falso, e a linha não aparece. `IS NULL` é o teste próprio.

**48. O que é `NULL`? É o mesmo que zero?**  
	É a ausência de valor. Não é zero nem texto vazio: um pedido sem `total` não tem total, o que é diferente de total 0.

**49. Para que serve o `LIMIT`?**  
	Corta o número de linhas do resultado: `LIMIT 5` traz as 5 primeiras. Use com `ORDER BY`, senão as 5 são quaisquer.

**50. Qual a ordem das partes de um `SELECT`?**  
	`SELECT`, `FROM`, `JOIN`, `WHERE`, `GROUP BY`, `ORDER BY` e `LIMIT`.

## Parte 5 · Agregação e `JOIN` (51 a 62)

**51. O que é uma função de agregação? Cite três.**  
	Uma função que resume várias linhas em um valor: `COUNT`, `SUM`, `AVG`, `MIN` e `MAX`.

**52. Qual a diferença entre `count(*)` e `count(coluna)`?**  
	`count(*)` conta todas as linhas. `count(coluna)` conta só as linhas em que a coluna está preenchida (ignora `NULL`).

**53. O que faz o `count(DISTINCT coluna)`?**  
	Conta quantos valores diferentes existem. Exemplo: quantos clientes diferentes fizeram pedido.

**54. Para que serve o `GROUP BY`?**  
	Junta as linhas com o mesmo valor para calcular um total por grupo: `SELECT status, COUNT(*) FROM pedido GROUP BY status;`.

**55. Por que aparece o erro «a coluna deve aparecer no `GROUP BY`»?**  
	Há uma coluna no `SELECT` que não está no `GROUP BY` nem dentro de uma agregação. O banco não sabe qual valor mostrar no grupo.

**56. Para que serve o `JOIN`? O que vai no `ON`?**  
	Liga duas tabelas. O `ON` diz qual coluna casa com qual: `JOIN cliente c ON c.id = p.cliente_id`.

**57. Qual a diferença entre `JOIN` e `LEFT JOIN`?**  
	`JOIN` traz só as linhas com par nas duas tabelas. `LEFT JOIN` traz todas as da esquerda; sem par, as colunas da direita vêm `NULL`.

**58. Como achar «quem nunca comprou» com `LEFT JOIN`?**  
	Faça `cliente LEFT JOIN pedido` e filtre `WHERE pedido.id IS NULL`: sobram os clientes sem par.

**59. O que quer dizer o erro «a referência à coluna é ambígua»?**  
	Duas tabelas do `JOIN` têm a coluna com o mesmo nome (`id`). Escreva de qual: `c.id` ou `p.id`.

**60. Para que serve o apelido da tabela (`cliente c`)?**  
	Encurta o nome e diz de qual tabela vem cada coluna: `c.nome`, `p.total`.

**61. Como somar quanto cada cliente gastou?**  
	Ligue `cliente` e `pedido`, agrupe por cliente e some o total: `SELECT c.nome, SUM(p.total) FROM cliente c JOIN pedido p ON p.cliente_id = c.id GROUP BY c.nome;`.

**62. Por que filtrar o status antes de somar as vendas?**  
	Carrinho, pedido aguardando pagamento e pedido cancelado não são venda. Sem o filtro, a soma fica maior que o real.

## Parte 6 · Funções SQL (63 a 72)

**63. O que faz o `LPAD`? Dê um exemplo.**  
	Completa o texto à esquerda até um tamanho. `LPAD('7', 6, '0')` dá `000007`: é assim que sai o número do pedido.

**64. O que fazem `UPPER`, `LOWER` e `INITCAP`?**  
	Deixam o texto em maiúsculas, em minúsculas ou com a primeira letra de cada palavra maiúscula (`INITCAP('maria silva')` dá `Maria Silva`).

**65. Para que servem o `TRIM` e o `REPLACE`?**  
	O `TRIM` tira os espaços das pontas. O `REPLACE` troca um trecho: `REPLACE('SKU-0001', 'SKU-', '')` dá `0001`.

**66. Como juntar dois textos?**  
	Com `||`: `'PD-' || '000001'` dá `PD-000001`.

**67. Qual a diferença entre `ROUND`, `CEIL` e `FLOOR`?**  
	`ROUND` arredonda para o mais perto (`ROUND(71.866, 2)` dá `71.87`); `CEIL` sempre para cima; `FLOOR` sempre para baixo.

**68. Para que servem o `CURRENT_DATE` e o `INTERVAL`?**  
	`CURRENT_DATE` é a data de hoje. `INTERVAL` soma ou tira um tempo: `fechado_em + INTERVAL '48 hours'`.

**69. Como saber quantos dias faltam até uma data?**  
	Subtraia as datas: `valido_ate - CURRENT_DATE` dá o número de dias.

**70. Para que servem `EXTRACT`, `DATE_TRUNC` e `TO_CHAR`?**  
	`EXTRACT` tira um pedaço da data (o mês, o dia da semana). `DATE_TRUNC('month', d)` volta ao início do mês, para agrupar por mês. `TO_CHAR` mostra a data como texto (`'DD/MM/YYYY'`).

**71. Para que serve o `CASE`?**  
	Escolhe um valor conforme uma condição, como um «se»: `CASE WHEN total < 150 THEN 'pequeno' ELSE 'grande' END`.

**72. Para que serve o `COALESCE`?**  
	Devolve o primeiro valor que não é vazio. `COALESCE(SUM(total), 0)` troca o vazio por zero.

## Parte 7 · View, subconsulta, CTE e `RANK` (73 a 80)

**73. O que é uma view?**  
	Uma consulta guardada com um nome (`CREATE VIEW vw_... AS SELECT ...`). Usa-se como se fosse uma tabela.

**74. Que vantagem a view traz?**  
	Quem consulta não precisa reescrever a consulta inteira, e todos usam a mesma regra. A view não guarda os dados: roda a consulta a cada uso.

**75. O que é uma subconsulta?**  
	Uma consulta dentro de outra, entre parênteses. O resultado de dentro é usado pela de fora.

**76. Dê um exemplo de subconsulta com `NOT IN`.**  
	Produtos nunca vendidos: `SELECT nome FROM produto WHERE id NOT IN (SELECT produto_id FROM item_pedido);`.

**77. Dê um exemplo de subconsulta que devolve um valor só.**  
	Pedidos acima da média: `WHERE total > (SELECT AVG(total) FROM pedido)`.

**78. O que é uma CTE (`WITH`)?**  
	Uma consulta com nome, escrita antes da consulta principal: `WITH vendas AS (SELECT ...) SELECT ... FROM vendas;`.

**79. Qual a vantagem da CTE sobre a subconsulta?**  
	É mais fácil de ler: cada parte tem um nome e pode ser testada sozinha, em vez de ficar no meio do `WHERE`.

**80. O que o `RANK` faz? O que acontece no empate?**  
	Dá a posição de cada linha numa ordem: `RANK() OVER (ORDER BY total DESC)`. No empate, as linhas recebem a mesma posição, e a seguinte pula (1, 1, 3).

## Parte 8 · Funções, procedures e triggers (81 a 100)

**81. O que é um bloco anônimo (`DO`)?**  
	Um trecho de `PL/pgSQL` que roda uma vez e não fica guardado no banco. Serve para testar um código.

**82. O que o bloco anônimo não faz que a função faz?**  
	Não tem nome, não recebe parâmetro e não devolve valor. A função tem os três e fica guardada.

**83. O que é uma função no banco? Por que guardar uma regra como função?**  
	Uma regra da loja guardada com nome e parâmetros, que devolve um valor. Assim a mesma conta (frete, desconto) fica num lugar só.

**84. Qual a diferença entre `LANGUAGE sql` e `LANGUAGE plpgsql`?**  
	Em `sql`, o corpo é uma consulta com parâmetros. Em `plpgsql`, o corpo pode ter variáveis, `IF` e mensagem de erro.

**85. Qual a diferença entre o `RETURNS` e o `RETURN`?**  
	`RETURNS` fica no cabeçalho e diz o tipo do que a função devolve. `RETURN` fica no corpo: devolve o valor e encerra a função.

**86. O que é um parâmetro? Por que o nome começa com `p_`?**  
	É o valor que a função recebe (`p_pedido`). O `p_` mostra que é parâmetro e evita confundir com o nome de uma coluna.

**87. Para que servem o `DECLARE` e as variáveis (`v_`)?**  
	O `DECLARE` cria as variáveis, que guardam valores no meio do caminho (`v_estoque integer;`).

**88. O que faz o `SELECT ... INTO`?**  
	Guarda o resultado da consulta em variáveis: `SELECT estoque INTO v_estoque FROM produto WHERE id = p_produto;`.

**89. O que o `IF NOT FOUND` testa?**  
	Se o último `SELECT ... INTO` não achou nenhuma linha. Usa-se logo depois dele, para tratar o «não existe».

**90. O que o `RAISE EXCEPTION` faz?**  
	Para a rotina com uma mensagem de erro, e nada do que ela faria é gravado: `RAISE EXCEPTION 'Produto % não existe', p_produto;` (o `%` recebe o valor).

**91. Para que serve o `IF ... ELSIF ... ELSE`?**  
	Escolhe um caminho entre vários. Exemplo: estoque abaixo do mínimo, `repor`; abaixo de 4 vezes o mínimo, `atenção`; senão, `ok`.

**92. Como se chama uma função que devolve um valor? E uma que devolve uma tabela (`RETURNS TABLE`)?**  
	A de um valor, dentro de um `SELECT`: `SELECT gasto_do_cliente(25);`. A de tabela, no `FROM`: `SELECT * FROM pedidos_do_cliente(25);`.

**93. O que é uma procedure? Como ela é chamada?**  
	Uma rotina que faz uma ação na loja (`INSERT`, `UPDATE`, `DELETE`) e não devolve valor. É chamada com `CALL`: `CALL dar_entrada_estoque(1, 10);`.

**94. Qual a diferença entre uma função e uma procedure?**  
	A função responde (devolve um valor e não grava nada). A procedure faz (grava mudanças) e é chamada com `CALL`.

**95. Por que a procedure testa as regras antes do `INSERT` ou do `UPDATE`?**  
	Para recusar o pedido errado antes de gravar qualquer coisa. Se a regra falha, o `RAISE EXCEPTION` para a procedure e nada muda.

**96. O que é um trigger? Quem o chama?**  
	Uma função que o banco roda sozinho quando um dado muda (`INSERT`, `UPDATE` ou `DELETE`). Ninguém o chama: basta o comando na tabela.

**97. Quais são as duas partes de um trigger?**  
	A função, que `RETURNS trigger` e diz o que fazer, e o `CREATE TRIGGER`, que liga a função à tabela e ao evento.

**98. Qual a diferença entre `BEFORE` e `AFTER`? Qual pode recusar um dado?**  
	`BEFORE` roda antes de gravar: pode recusar (`RAISE EXCEPTION`) ou corrigir o dado, e termina com `RETURN NEW`. `AFTER` roda depois: registra ou reage, e termina com `RETURN NULL`. Só o `BEFORE` recusa antes de gravar.

**99. O que `OLD` e `NEW` guardam? Em qual comando existem os dois?**  
	`OLD` é a linha antes da mudança; `NEW`, a linha depois. Os dois existem no `UPDATE`; no `INSERT` só há `NEW`, e no `DELETE` só há `OLD`.

**100. O que fazem o `FOR EACH ROW` e o `AFTER UPDATE OF status`?**  
	`FOR EACH ROW` roda a função uma vez para cada linha mudada. `AFTER UPDATE OF status` só dispara quando a coluna `status` muda; mudar outra coluna não dispara.
