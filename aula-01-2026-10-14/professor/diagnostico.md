# Aula 01 — Diagnóstico de Banco de Dados 1

Texto do formulário para colar no Google Forms: [`formulario-diagnostico.md`](formulario-diagnostico.md).

Quiz **anônimo e sem nota**, de 10 minutos (09:00–09:10), no Google Forms **sem exigir login** e sem coletar nome ou e-mail.
Objetivo: calibrar as aulas 2 a 5 e confirmar se a turma já viu normalização (ver D-07 no `TODO.md`, decidida).

Avise antes: "Não vale nota e não tem nome. É para eu saber onde começar."

## Perguntas

Questões 1 a 7 de múltipla escolha, 8 e 9 de autoavaliação.

**1. Qual é a função de uma chave estrangeira (`FOREIGN KEY`)?**

- a) Identificar de forma única cada linha de uma tabela
- b) Ligar uma linha de uma tabela a uma linha de outra tabela e impedir referências inexistentes ✔
- c) Acelerar as consultas
- d) Impedir valores nulos

**2. A tabela `cliente` tem 10 linhas e 3 delas não têm pedido. O que `cliente LEFT JOIN pedido` devolve para esses 3 clientes?**

- a) Eles não aparecem no resultado
- b) Aparecem com as colunas de `pedido` nulas ✔
- c) Dá erro
- d) Aparecem repetidos

**3. Qual a diferença entre `WHERE` e `HAVING`?**

- a) Nenhuma, são sinônimos
- b) `WHERE` filtra linhas antes de agrupar; `HAVING` filtra os grupos depois de agregar ✔
- c) `HAVING` só funciona com `JOIN`
- d) `WHERE` só funciona com números

**4. Em `pedido(id, cliente, endereco_cliente, produto, preco)`, o endereço do cliente se repete em cada pedido. Qual é o problema?**

- a) Nenhum, só ocupa espaço
- b) Se o cliente mudar de endereço, é preciso alterar várias linhas, e é fácil ficar inconsistente ✔
- c) A tabela não tem chave primária
- d) O preço está na tabela errada

**5. O que faz um `ROLLBACK`?**

- a) Salva as alterações da transação
- b) Desfaz as alterações da transação ainda não confirmada ✔
- c) Apaga a tabela
- d) Cria um backup

**6. Para impedir que o preço de um produto seja negativo, o ideal é:**

- a) Conferir só na aplicação
- b) `CHECK (preco >= 0)` na coluna ✔
- c) Usar `UNIQUE`
- d) Usar `DEFAULT 0`

**7. Alunos podem se matricular em vários cursos e cada curso tem vários alunos. Como isso vira tabelas?**

- a) Uma coluna `curso` na tabela `aluno`
- b) Uma terceira tabela (`matricula`) com as chaves de `aluno` e de `curso` ✔
- c) Uma coluna com a lista de alunos dentro de `curso`
- d) Duas tabelas independentes, sem ligação

**8. De 1 (nunca usei) a 4 (uso com segurança): você já usou Git ou GitHub?**

**9. Você já ouviu falar de normalização (1FN, 2FN, 3FN)?** Sim, e sei explicar · Já ouvi, mas não sei explicar · Nunca ouvi

## O que olhar no resultado

| Resultado | O que fazer |
|---|---|
| Questão 4 com menos de 50% de acerto, ou questão 9 com maioria em "nunca ouvi" | A normalização é conteúdo novo (confirma a premissa do doc 09): manter os 10 min de exposição da aula 2 |
| Questão 2 ou 3 com menos de 50% | Reforçar `JOIN` e `GROUP BY` na aula 4; a maratona da aula 5 entra com trio misto |
| Questão 8 com maioria em 1 ou 2 | Na aula 1, o repositório do grupo é criado com o professor mostrando, e o `git` na aula 2 ganha 10 min de demonstração |
| Questões 1, 5, 6 e 7 com mais de 80% | Pular a revisão de chaves e de `ROLLBACK` na aula 3 |

Compartilhe o resultado geral (sem identificar ninguém) com a turma ao fim do quiz: ajuda a mostrar que a turma é
heterogênea e que todos podem ajudar os colegas.
