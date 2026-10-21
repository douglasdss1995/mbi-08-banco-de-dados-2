# Notas do orador dos slides — aula 3

Texto que o professor fala em cada slide. Os slides em si estão em [../aluno/slides.md](../aluno/slides.md).

## Slide 1 — DDL e DML

Hoje o modelo da Oficina Mecânica vira um banco de verdade, com scripts que rodam do zero.

## Slide 2 — Hoje o modelo vira um banco de verdade

Retome o diagrama do exercício 1 (as 7 tabelas em 3FN) e diga que hoje cada tabela vira um CREATE TABLE.

## Slide 3 — DDL: definir a estrutura

Demonstre ao vivo: crie o banco, depois cliente e veiculo. Mostre o erro ao criar veiculo antes de cliente.

## Slide 4 — Os tipos que vamos usar

Telefone é texto, não número. Dinheiro em numeric(10,2). Use GENERATED ALWAYS AS IDENTITY, o modo atual do PostgreSQL.

## Slide 5 — A ordem importa

Deixe a turma errar de propósito: criar veiculo antes de cliente. Leia a mensagem de erro em voz alta e pergunte o que ela diz.

## Slide 6 — DML: mexer nos dados

Mostre, só como SELECT, o efeito de um UPDATE sem WHERE (todas as linhas). Conferir antes com SELECT é o tema da aula 4.

## Slide 7 — Três erros que o banco recusa

Provoque os três erros ao vivo e pergunte, antes de mostrar a mensagem, o que o banco vai fazer. O erro 2 abre o gancho para o ON DELETE, na aula 8.

## Slide 8 — Agora, a prática

Circule. O erro mais provável é a ordem da criação ou da carga. Deixe a mensagem aparecer e pergunte o que ela diz. Não ensine CHECK, UNIQUE nem ON DELETE hoje.
