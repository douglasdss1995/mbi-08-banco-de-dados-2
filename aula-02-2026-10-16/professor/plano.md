# Aula 02 — 16/10/2026 (sexta-feira)

Semana do curso: 1 · Tipo: Revisão de BD1 · 3 h · Status: **rascunho**

**Tema:** Prática: modelagem relacional e oficina de normalização (1FN a 3FN); diagrama do tema do grupo e primeiro commit

## Objetivos

- Rever o modelo relacional e normalizar uma planilha até a 3FN, justificando cada passo.
- Reconhecer anomalias e dependências parciais e transitivas.
- Desenhar o primeiro diagrama do tema do grupo no ERD Concepts e enviá-lo ao repositório com o GitKraken (cada membro faz
  um commit).

## Roteiro

A aula começa às 09:00 (o 1º tempo é de outro professor). Não há correção neste dia: a entrega do exercício é livre.

| Horário | Atividade | Dinâmica |
|---|---|---|
| 08:00 – 09:00 | Aula de outro professor (sem aula desta disciplina) | |
| 09:00 | **1ª chamada** | |
| 09:00 – 09:10 | Pendências da aula 1 (instalação, repositório do grupo, convite de colaborador) e o resultado do diagnóstico (perguntas 4 e 9) | Rápido |
| 09:10 – 09:40 | **Exposição com exemplo ao vivo:** modelo relacional (entidade, chave, relacionamento), as três anomalias e 1FN, 2FN e 3FN com a planilha de um campeonato. A turma diz o próximo passo | Exposição dialogada |
| 09:40 – 10:00 | Intervalo | |
| 10:00 – 10:40 | **Oficina de normalização:** cada grupo recebe uma das 5 planilhas (A a E; dois grupos por planilha) e a normaliza em 5 passos, com o roteiro `aluno/roteiro-oficina-mecanica.md` | Grupos; um digita e outro dita; o professor circula |
| 10:40 – 10:50 | **Confronto:** os dois grupos com a mesma planilha comparam as tabelas finais e defendem as diferenças | Entre grupos |
| 10:50 – 11:00 | **Git com GitKraken:** demonstração de clone, stage, commit e push, com o `aluno/guia-gitkraken.md` | Demonstração ao vivo |
| 11:00 – 11:30 | **Diagrama do tema** no ERD Concepts e **o primeiro commit** de cada membro (parte 2.7 do exercício) | Grupos |
| 11:30 | **2ª chamada** · atendimento até 11:40 | |

## Exposição (09:10 às 09:40)

Usar a planilha de um campeonato amador (não é tema de grupo):

| jogo | data | time_casa | tecnico_casa | estadio | cidade | arbitros |
|---|---|---|---|---|---|---|
| 1 | 03/10 | Leões | Paulo | Arena Norte | Joinville | Rui; Ana |
| 2 | 03/10 | Tigres | Marta | Arena Sul | Blumenau | Rui |
| 3 | 10/10 | Leões | Paulo | Arena Norte | Joinville | Ana |
| 4 | 10/10 | Águias | Caio | Arena Sul | Blumenau | Rui; Ana |

Sequência (a turma responde cada pergunta antes de o professor mostrar):

1. **Anomalias:** mudou o técnico do Leões (quantas linhas?). Dá para cadastrar um time sem jogo? Apagar o jogo 2 faz sumir
   o quê? (o Tigres e a técnica Marta.)
2. **1FN:** a coluna `arbitros` tem uma lista. Uma linha por jogo e árbitro; a chave passa a ser `(jogo, arbitro)`.
3. **2FN:** `data` e `time_casa` dependem só de `jogo` (parte da chave). Separar `jogo` de `arbitragem`.
4. **3FN:** `time_casa → tecnico_casa, estadio` e `estadio → cidade`: dependências transitivas. Separar `time`, `estadio` e
   `cidade`.
5. **Fechamento:** as tabelas são ligadas por chaves primárias e estrangeiras; juntando-as, reconstrói-se a planilha.

Tabelas finais do exemplo:

```
cidade(cod_cidade PK, nome)
estadio(cod_estadio PK, nome, cod_cidade FK)
time(cod_time PK, nome, tecnico, cod_estadio FK)
arbitro(cod_arbitro PK, nome)
jogo(numero PK, data, cod_time_casa FK)
arbitragem(numero FK, cod_arbitro FK)    -- PK (numero, cod_arbitro)
```

## Oficina

- **Planilhas:** `aluno/planilhas-oficina/` (um `.csv` por planilha, A a E). Atribuição: planilha = ((grupo − 1) mod 5) + 1.
- **Roteiro e gabarito:** `aluno/roteiro-oficina-mecanica.md` e `gabarito-oficina-de-normalizacao.md` (somente nesta pasta).
- **Passos (40 min):** problemas (5), 1FN (8), dependências (8), 2FN e 3FN (10), desenho e decisão difícil (9).
- **Circular:** ao passar por um grupo, não corrija; pergunte a anomalia que o erro causaria.
- **Confronto (10 min):** cada grupo mostra as tabelas em 2 min; juntos listam as diferenças e decidem se foi erro ou se são
  soluções válidas. Se um tipo de planilha tiver um grupo só, o confronto é com o professor.

## Git com GitKraken (10:50 às 11:00)

- Demonstrar no projetor, com o repositório de um grupo voluntário: **Clone**, copiar o arquivo, **Stage all**, mensagem,
  **Commit**, **Push** e conferir no GitHub.
- Lembrar: o repositório é **público**; só dados fictícios.
- **Plano B** se o GitKraken ou o login falhar: enviar o arquivo pelo site do GitHub (Add file › Upload files). O commit
  continua sendo de cada aluno.
- Ao fim da aula, **sair da conta** do GitKraken e do GitHub nas máquinas do laboratório.

## Diagrama do tema (11:00 às 11:30)

- Grupo desenha as tabelas do tema, com chaves e cardinalidades, no ERD Concepts. É uma **primeira versão**: a aula 3 reserva
  o tempo de projeto para ajustá-la, e o diagrama volta na aula 8 (checkpoint).
- Meta da aula: pelo menos as entidades principais e os relacionamentos 1:N; refinamento até 3FN fica para depois.
- Exportar uma imagem, subir o arquivo do ERD Concepts e a imagem em `diagrama/` e fazer **o commit de cada membro**.
- Modelos de referência dos temas (só para o professor): [docs/projetos/](../../../docs/projetos/00-estrutura-das-entregas.md).

## Exercício do assunto

- Assunto: «Ambiente, modelo relacional e normalização» (aulas 01 e 02). Enunciado único, na aula 01:
  `../../aula-01-2026-10-14/aluno/exercicio.md`. Resolução: `../aluno/gabarito-oficina-mecanica.md` (entregue aos alunos depois de explicada em aula).
- Parte 2 (7 pontos): normalizar a planilha da Oficina Mecânica até a 3FN, desenhar o diagrama dela e terminar o diagrama do tema.
  As questões 2.1 a 2.6 podem ser feitas depois da aula, sem horário limite. A 2.7 começa hoje, às 11:00.

## Material

| Arquivo | Para quê | Estado |
|---|---|---|
| [`../aluno/planilhas-oficina/`](../aluno/planilhas-oficina/) | As 5 planilhas da oficina (um `.csv` cada, A a E) | pronto |
| [`../aluno/roteiro-oficina-mecanica.md`](../aluno/roteiro-oficina-mecanica.md) | Os 5 passos e o confronto | pronto |
| [`../aluno/guia-gitkraken.md`](../aluno/guia-gitkraken.md) | Clone, commit e push com o GitKraken | pronto |
| [`gabarito-oficina-de-normalizacao.md`](gabarito-oficina-de-normalizacao.md) | Tabelas finais das 5 planilhas e pontos do confronto | pronto |
| [`../aluno/gabarito-oficina-mecanica.md`](../aluno/gabarito-oficina-mecanica.md) | Resolução do exercício 1 (exemplo guiado; vai para os alunos depois de explicada) | pronto |
| [`slides.pptx`](slides.pptx) | 8 slides no modelo da escola, com a fala nas notas do orador | pronto |
| [`slides.md`](slides.md) | Passo a passo da fala, slide por slide, com explicação e informações de apoio | pronto |

## Notas do professor

- Normalização não consta no plano de BD1 ([09](../../../docs/09-bd1-o-que-foi-ensinado.md)). Ajustar a profundidade da
  exposição ao resultado do diagnóstico (perguntas 4 e 9).
- Antes da aula: conferir que o GitKraken abre nas máquinas e que o laboratório não bloqueia `gitkraken.com` nem `github.com`
  (só se vê na sala). Publicar no Classroom, antes da aula, a pasta `planilhas-oficina` (5 `.csv`), o roteiro e o guia.
- Conferir que todos os alunos aceitaram o convite de colaborador do repositório; sem isso o push é recusado.
- Aula de 3 h: sem correção; 80 min de conteúdo novo. Se o ritmo atrasar, corte o confronto (10:40) e deixe o Git para o
  tempo de projeto, nunca a oficina.
