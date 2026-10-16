# Oficina de normalização — roteiro do grupo

Cada grupo recebe **uma planilha** e transforma em tabelas normalizadas. O arquivo com as cinco planilhas é
`planilhas-oficina.xlsx`. Veja no quadro qual é a do seu grupo.

## Qual planilha é do seu grupo

| Planilha | Assunto                             | Grupos |
| -------- | ----------------------------------- | ------ |
| A        | Pedidos de uma papelaria            | 1 e 6  |
| B        | Matrículas de uma escola de idiomas | 2 e 7  |
| C        | Consultas de uma clínica            | 3 e 8  |
| D        | Aluguel de equipamentos             | 4 e 9  |
| E        | Estoque por depósito                | 5 e 10 |
## Os 5 passos

Trabalhem juntos, com **uma pessoa digitando e as outras ditando**, trocando a cada passo. Anotem tudo em um documento
do grupo.

### Passo 1 · Ache os problemas (5 min)

Leiam a planilha e escrevam **3 problemas**: uma anomalia de **atualização**, uma de **inserção** e uma de **exclusão**.

Perguntas que ajudam:

- Se um dado mudar (um telefone, um preço), em quantas linhas é preciso corrigir?
- Dá para cadastrar uma coisa nova (um produto, um médico) antes de ela aparecer em uma linha?
- Se uma linha for apagada, que informação some junto?

### Passo 2 · Dependências funcionais

1. Para cada coluna, perguntem:
   - **Essa coluna depende de outra?** 
   - **Essa coluna tem dependentes?**

Escrevam no formato `X → Y`.

### Passo 3 · 2FN e 3FN

1. Separem as colunas em **tabelas**, de modo que cada coluna dependa da chave inteira e de mais nada.
2. Escrevam cada tabela no formato `tabela(coluna PK, coluna, coluna FK)`.
3. Conferiram: nenhuma informação se repete entre linhas, e dá para reconstruir a planilha juntando as tabelas?

### Passo 4 · Desenhem

1. No **ERD Concepts**, desenhem as tabelas com as chaves e a **cardinalidade** (1:N ou N:N) de cada relacionamento.
2. Escrevam **uma decisão difícil** do grupo e a justificativa em duas linhas. Exemplo: "guardamos o preço no item do
   pedido, e não só no produto, porque o preço muda com o tempo".

## Se terminarem antes do fim da aula

Normalizem também a planilha de **outro tipo** (de um grupo vizinho) e comparem depois.
