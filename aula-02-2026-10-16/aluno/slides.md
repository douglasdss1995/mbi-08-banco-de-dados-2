# Normalização

Banco de Dados 2 · aula 2

16/10/2026 · da planilha às tabelas

## Slide 2 — Quando a planilha mente

*Três problemas que aparecem quando a informação se repete*

- ATUALIZAÇÃO
- O técnico do Leões mudou. Preciso corrigir em 2 linhas, e é fácil esquecer uma.
- INSERÇÃO
- Quero cadastrar um time novo, mas ele só existe dentro de um jogo.
- EXCLUSÃO
- Apago o jogo 2 e somem juntos o Tigres e a técnica Marta.
- Em todos os casos, a planilha obriga a repetir informação, ou a perdê-la.

## Slide 3 — A planilha do campeonato

*Onde estão os problemas?*

- jogo | data | time_casa | tecnico_casa | estadio | cidade | arbitros
- 1 | 03/10 | Leões | Paulo | Arena Norte | Joinville | Rui; Ana
- 2 | 03/10 | Tigres | Marta | Arena Sul | Blumenau | Rui
- 3 | 10/10 | Leões | Paulo | Arena Norte | Joinville | Ana
- 4 | 10/10 | Águias | Caio | Arena Sul | Blumenau | Rui; Ana
- Que coluna tem mais de um valor? E que colunas dependem de outras?

## Slide 4 — As três formas normais

*Uma pergunta para cada forma*

- 1FN · uma coisa por célula
- Há célula com lista ou colunas repetidas? Separe em linhas.
- 3FN · só a chave
- Há coluna que depende de outra que não é a chave? Mova para outra tabela.
- 2FN · a chave inteira
- Há coluna que depende de só parte da chave? Mova para outra tabela.
- Tabelas ligadas
- Cada tabela tem uma chave primária, e a chave estrangeira liga uma à outra.

## Slide 5 — Oficina em 5 passos

*Um digita, o outro dita, e trocam a cada passo*

- Passo 1 · 5 min
- Ache 3 problemas (atualização, inserção e exclusão)
- Passo 2 · 8 min
- 1FN: uma informação por célula e defina a chave
- Passo 3 · 8 min
- Dependências: liste X → Y, parciais e transitivas
- Passo 4 · 10 min
- 2FN e 3FN: separe em tabelas com PK e FK
- Passo 5 · 9 min
- Desenhe no ERD Concepts e justifique uma decisão
- Confronto · 10 min
- Compare com o grupo que tem a mesma planilha

## Slide 6 — Qual é a planilha do seu grupo

*Cada planilha é um arquivo .csv na pasta planilhas-oficina*

- A
- Pedidos
- Grupos 1 e 6
- colunas repetidas
- B
- Matrículas
- Grupos 2 e 7
- chave composta
- C
- Consultas
- Grupos 3 e 8
- só a 3FN
- D
- Aluguéis
- Grupos 4 e 9
- lista na célula e N:N
- E
- Estoque
- Grupos 5 e 10
- parcial e transitiva

## Slide 7 — Git com GitKraken, em 4 passos

*O repositório do grupo é público*

- Clone o repositório, copie o diagrama para a pasta, coloque na área de envio, faça o commit com uma mensagem clara e envie com o push. Só dados fictícios: qualquer pessoa pode ver o repositório.
- Os 4 passos:
- 1 · Clone
- 2 · Stage
- 3 · Commit
- 4 · Push

## Slide 8 — Agora é com o grupo

*O que fazer agora*

- Diagrama
- As entidades principais e os relacionamentos 1:N, com chaves e cardinalidade.
- Desenhem as tabelas do tema no ERD Concepts. É uma primeira versão: ela vai mudar na aula 3.
- Commit
- Cada integrante envia o arquivo e a imagem para a pasta diagrama/ com o GitKraken.
- A parte 2 do exercício continua depois da aula, sem horário limite.
