# Banco de perguntas da prova 4

Banco de Dados 2 · Turma MBI-08

Na prova 4, o professor sorteia **2 perguntas desta lista** (de 1 a 100) para a dupla. Cada uma vale **2 pontos**.

**Como estudar:**

1. Leia **todas** as perguntas deste arquivo.
2. Tente responder cada uma **sozinho**, com as suas palavras. Use o material e os exercícios.
3. Só depois abra o arquivo de respostas, [banco-de-perguntas-prova-4-respostas.md](banco-de-perguntas-prova-4-respostas.md), e confira.

Na mesa do professor, responda **com as suas palavras, sem ler**. Uma boa resposta diz **o que é**, **para que serve** e dá **um exemplo** da Loja Virtual.

Siglas: SQL: *Structured Query Language*. DDL: *Data Definition Language*. DML: *Data Manipulation Language*. PK: *Primary Key* (chave primária). FK: *Foreign Key* (chave estrangeira). MER: Modelo Entidade-Relacionamento. CTE: *Common Table Expression*. PL/pgSQL: *Procedural Language/PostgreSQL*. 1FN, 2FN, 3FN: primeira, segunda e terceira formas normais.

## Parte 1 · Modelo e normalização (1 a 12)

1. O que é uma tabela, uma linha e uma coluna?
2. O que é uma chave primária (PK)? Por que toda tabela precisa de uma?
3. O que é uma chave estrangeira (FK)?
4. O que é um MER (o diagrama do modelo)?
5. O que é um relacionamento 1:N? Dê um exemplo da loja.
6. O que é um relacionamento N:N? Como ele vira tabela?
7. Para que serve a normalização?
8. Que problema a planilha com tudo junto causa?
9. O que a 1FN (primeira forma normal) pede?
10. O que a 2FN (segunda forma normal) pede?
11. O que a 3FN (terceira forma normal) pede?
12. O que é um dicionário de dados?

## Parte 2 · DDL, tipos e regras (13 a 28)

13. Qual a diferença entre DDL e DML?
14. O que faz o `CREATE TABLE`?
15. O que é um schema? Para que serve o `SET search_path`?
16. O que significa `GENERATED ALWAYS AS IDENTITY`?
17. Por que preferir `IDENTITY` a `serial`?
18. Quando usar `varchar(n)` e quando usar `char(n)`?
19. Por que usar `numeric(10,2)` para dinheiro?
20. Para que servem os tipos `date`, `timestamp` e `boolean`?
21. O que faz o `NOT NULL`?
22. O que faz o `UNIQUE`?
23. O que faz o `DEFAULT`?
24. O que faz o `CHECK`?
25. O que faz o `REFERENCES` numa coluna?
26. Por que a ordem dos `CREATE TABLE` importa?
27. O que diz o guia de estilo sobre os nomes?
28. O que acontece ao apagar um «pai» que tem «filhos» (`ON DELETE`)?

## Parte 3 · `INSERT`, `UPDATE` e `DELETE` (29 a 36)

29. Para que serve o `INSERT`? Como inserir várias linhas de uma vez?
30. Por que a ordem das colunas no `INSERT` importa?
31. Por que cadastrar a tabela «pai» antes da «filha»?
32. Para que serve o `UPDATE`?
33. O que acontece num `UPDATE` sem `WHERE`?
34. Para que serve o `DELETE`?
35. Por que apagar primeiro as linhas «filhas»?
36. O que significa a mensagem `UPDATE 0`?

## Parte 4 · `SELECT` (37 a 50)

37. Para que serve o `SELECT`?
38. Para que serve o `FROM`?
39. Para que serve o `WHERE`?
40. Por que evitar o `SELECT *` na entrega?
41. Para que serve o `ORDER BY`? O que o `DESC` faz?
42. Para que serve o `AS`?
43. O que fazem o `AND`, o `OR` e o `NOT`?
44. Para que serve o `IN`?
45. Para que serve o `BETWEEN`?
46. Para que serve o `LIKE`? O que o `%` significa?
47. Por que se escreve `IS NULL`, e não `= NULL`?
48. O que é `NULL`? É o mesmo que zero?
49. Para que serve o `LIMIT`?
50. Qual a ordem das partes de um `SELECT`?

## Parte 5 · Agregação e `JOIN` (51 a 62)

51. O que é uma função de agregação? Cite três.
52. Qual a diferença entre `count(*)` e `count(coluna)`?
53. O que faz o `count(DISTINCT coluna)`?
54. Para que serve o `GROUP BY`?
55. Por que aparece o erro «a coluna deve aparecer no `GROUP BY`»?
56. Para que serve o `JOIN`? O que vai no `ON`?
57. Qual a diferença entre `JOIN` e `LEFT JOIN`?
58. Como achar «quem nunca comprou» com `LEFT JOIN`?
59. O que quer dizer o erro «a referência à coluna é ambígua»?
60. Para que serve o apelido da tabela (`cliente c`)?
61. Como somar quanto cada cliente gastou?
62. Por que filtrar o status antes de somar as vendas?

## Parte 6 · Funções SQL (63 a 72)

63. O que faz o `LPAD`? Dê um exemplo.
64. O que fazem `UPPER`, `LOWER` e `INITCAP`?
65. Para que servem o `TRIM` e o `REPLACE`?
66. Como juntar dois textos?
67. Qual a diferença entre `ROUND`, `CEIL` e `FLOOR`?
68. Para que servem o `CURRENT_DATE` e o `INTERVAL`?
69. Como saber quantos dias faltam até uma data?
70. Para que servem `EXTRACT`, `DATE_TRUNC` e `TO_CHAR`?
71. Para que serve o `CASE`?
72. Para que serve o `COALESCE`?

## Parte 7 · View, subconsulta, CTE e `RANK` (73 a 80)

73. O que é uma view?
74. Que vantagem a view traz?
75. O que é uma subconsulta?
76. Dê um exemplo de subconsulta com `NOT IN`.
77. Dê um exemplo de subconsulta que devolve um valor só.
78. O que é uma CTE (`WITH`)?
79. Qual a vantagem da CTE sobre a subconsulta?
80. O que o `RANK` faz? O que acontece no empate?

## Parte 8 · Funções, procedures e triggers (81 a 100)

81. O que é um bloco anônimo (`DO`)?
82. O que o bloco anônimo não faz que a função faz?
83. O que é uma função no banco? Por que guardar uma regra como função?
84. Qual a diferença entre `LANGUAGE sql` e `LANGUAGE plpgsql`?
85. Qual a diferença entre o `RETURNS` e o `RETURN`?
86. O que é um parâmetro? Por que o nome começa com `p_`?
87. Para que servem o `DECLARE` e as variáveis (`v_`)?
88. O que faz o `SELECT ... INTO`?
89. O que o `IF NOT FOUND` testa?
90. O que o `RAISE EXCEPTION` faz?
91. Para que serve o `IF ... ELSIF ... ELSE`?
92. Como se chama uma função que devolve um valor? E uma que devolve uma tabela (`RETURNS TABLE`)?
93. O que é uma procedure? Como ela é chamada?
94. Qual a diferença entre uma função e uma procedure?
95. Por que a procedure testa as regras antes do `INSERT` ou do `UPDATE`?
96. O que é um trigger? Quem o chama?
97. Quais são as duas partes de um trigger?
98. Qual a diferença entre `BEFORE` e `AFTER`? Qual pode recusar um dado?
99. O que `OLD` e `NEW` guardam? Em qual comando existem os dois?
100. O que fazem o `FOR EACH ROW` e o `AFTER UPDATE OF status`?
