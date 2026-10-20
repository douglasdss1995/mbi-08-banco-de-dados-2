# Aula 01 — Formulário do diagnóstico (texto para o Google Forms)

Texto pronto para colar. As respostas certas, a leitura do resultado e as decisões que dependem dele estão em
[`diagnostico.md`](diagnostico.md). Este arquivo **não vai para o Classroom**: o que o aluno vê é só o formulário.

Tempo de resposta: 10 minutos, das 09:00 às 09:10, logo depois da 1ª chamada.

## 1. Configurações (para o formulário ficar anônimo)

Crie um formulário em branco no Google Forms (conta do professor) e configure:

| Onde | Opção | Valor |
|---|---|---|
| Configurações › Respostas | Coletar endereços de e-mail | **Desativado** |
| Configurações › Respostas | Enviar aos respondentes uma cópia da resposta | **Desativado** |
| Configurações › Respostas | Limitar a uma resposta (exige login) | **Desativado** |
| Configurações › Respostas | Permitir editar depois de enviar | Desativado |
| Configurações › Apresentação | Mostrar link para enviar outra resposta | Desativado |
| Configurações › Apresentação | Embaralhar a ordem das perguntas | Desativado (a ordem importa) |
| Configurações › Testes | Transformar em teste | **Ativado** (só para o Forms contar os acertos) |
| Configurações › Testes | Liberar nota | Depois da revisão manual, ou imediatamente, se quiser que o aluno veja a correção |
| Configurações › Testes | Valor dos pontos | 1 ponto por pergunta de 1 a 7; nenhuma de 8 e 9 |
| Compartilhar | Quem pode responder | Qualquer pessoa com o link (sem exigir login) |

Para a **mesma regra de anonimato** funcionar, não peça nome, e-mail, turma nem número do grupo no formulário.

## 2. Título e descrição

**Título:** Diagnóstico de Banco de Dados — aula 1

**Descrição:**

> Este formulário não vale nota e não pede o seu nome. Serve para o professor saber por onde começar o curso.
> Responda sozinho, sem pesquisar e sem IA, e marque «não sei» (ou a opção mais próxima) quando não souber:
> errar aqui não tem nenhuma consequência. Você tem 10 minutos.

## 3. Perguntas

Em todas, marque **Obrigatória**. Nas perguntas de 1 a 7, ative **Embaralhar a ordem das opções** e marque a resposta
certa (✔) no gabarito do teste.

### Pergunta 1 · Múltipla escolha

**Qual é a função de uma chave estrangeira (`FOREIGN KEY`)?**

- Identificar de forma única cada linha de uma tabela
- Ligar uma linha de uma tabela a uma linha de outra tabela e impedir referências inexistentes ✔
- Acelerar as consultas
- Impedir valores nulos

### Pergunta 2 · Múltipla escolha

**A tabela `cliente` tem 10 linhas e 3 delas não têm pedido. O que `cliente LEFT JOIN pedido` devolve para esses 3 clientes?**

- Eles não aparecem no resultado
- Aparecem com as colunas de `pedido` nulas ✔
- Dá erro
- Aparecem repetidos

### Pergunta 3 · Múltipla escolha

**Qual a diferença entre `WHERE` e `HAVING`?**

- Nenhuma, são sinônimos
- `WHERE` filtra linhas antes de agrupar; `HAVING` filtra os grupos depois de agregar ✔
- `HAVING` só funciona com `JOIN`
- `WHERE` só funciona com números

### Pergunta 4 · Múltipla escolha

**Em `pedido(id, cliente, endereco_cliente, produto, preco)`, o endereço do cliente se repete em cada pedido. Qual é o problema?**

- Nenhum, só ocupa espaço
- Se o cliente mudar de endereço, é preciso alterar várias linhas, e é fácil ficar inconsistente ✔
- A tabela não tem chave primária
- O preço está na tabela errada

### Pergunta 5 · Múltipla escolha

**O que faz um `ROLLBACK`?**

- Salva as alterações da transação
- Desfaz as alterações da transação que ainda não foram confirmadas ✔
- Apaga a tabela
- Cria um backup

### Pergunta 6 · Múltipla escolha

**Para impedir que o preço de um produto seja negativo, o ideal é:**

- Conferir só na aplicação
- Usar `CHECK (preco >= 0)` na coluna ✔
- Usar `UNIQUE`
- Usar `DEFAULT 0`

### Pergunta 7 · Múltipla escolha

**Alunos podem se matricular em vários cursos, e cada curso tem vários alunos. Como isso vira tabelas?**

- Uma coluna `curso` na tabela `aluno`
- Uma terceira tabela (`matricula`) com as chaves de `aluno` e de `curso` ✔
- Uma coluna com a lista de alunos dentro de `curso`
- Duas tabelas independentes, sem ligação

### Pergunta 8 · Escala linear (1 a 4)

**Você já usou Git ou GitHub?**

- Escala de **1** a **4**.
- Rótulo do 1: **Nunca usei**
- Rótulo do 4: **Uso com segurança**

### Pergunta 9 · Múltipla escolha

**Você já ouviu falar de normalização (1FN, 2FN, 3FN)?**

- Sim, e sei explicar
- Já ouvi, mas não sei explicar
- Nunca ouvi

## 4. Mensagem de confirmação

Em Configurações › Apresentação › **Mensagem de confirmação**:

> Obrigado! Suas respostas não têm o seu nome e não valem nota. O professor vai mostrar o resultado da turma em seguida.

## 5. Como publicar e usar

1. **Link:** copie o link do formulário (Enviar › link) e publique no Classroom, no tópico da aula 1, antes da aula. Como a
   turma está no laboratório, cada aluno abre pelo navegador da máquina.
2. **Na aula:** projete o link ou o código QR (o próprio Forms gera o QR) logo depois da 1ª chamada.
3. **Ao fim dos 10 minutos:** abra a aba **Respostas › Resumo**, que mostra o percentual de cada alternativa, e leia
   [`diagnostico.md`](diagnostico.md) para saber o que cada resultado muda no planejamento.
4. **Mostre o resumo à turma** (sem identificar ninguém) e anote as decisões nos planos das aulas 2 a 5.
5. **Depois da aula:** exporte as respostas para uma planilha só se precisar guardar. Não vincule a nenhum aluno.

## 6. Conferência antes de publicar

- [ ] Abra o formulário em uma **janela anônima** do navegador e confira que ele abre sem pedir login.
- [ ] Não existe nenhuma pergunta de nome, e-mail, turma ou grupo.
- [ ] As respostas certas das perguntas 1 a 7 estão marcadas no teste.
- [ ] As perguntas 8 e 9 não valem pontos.
