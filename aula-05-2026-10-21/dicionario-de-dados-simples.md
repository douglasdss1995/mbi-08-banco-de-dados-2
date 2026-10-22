# Dicionário de dados simples

Banco de Dados 2 · Turma MBI-08 · Aula 5

O dicionário de dados é a **lista das tabelas do seu banco e do que cada campo guarda**. Ele é o passo entre o desenho
(o MER) e o `CREATE TABLE` das próximas aulas. O MER (Modelo Entidade-Relacionamento) já mostra as chaves e as ligações; aqui
você só **escreve o que cada tabela e cada campo significa**, com as suas palavras.

Cada projeto do curso já tem um dicionário de dados completo (feito pelo professor, com tipo, chave e regras). O seu é a
**versão simples**: nome da tabela, para que ela serve e, para cada campo, o nome e a explicação.

## Como preencher

Copie o bloco abaixo **uma vez para cada tabela** do seu modelo.

- **Tabela:** o nome, no singular e sem espaços (ex.: `livro`, `exemplar`).
- **Para que serve:** uma frase.
- **Campo:** o nome do campo, sem acento nem espaço (ex.: `data_prevista`).
- **Explicação:** o que o campo guarda. Se o campo é uma ligação com outra tabela, diga com qual.

O nome do campo precisa ser claro o bastante para a explicação caber em uma frase curta. Se você precisar de um parágrafo,
o campo talvez deva ser dividido em dois, ou ser outra tabela.

## Modelo

### Tabela: `nome_da_tabela`

**Para que serve:** uma frase.

| Campo | Explicação |
|---|---|
| `id` | Identifica cada linha da tabela |
| `nome` | O nome da coisa que a tabela guarda |
| `outra_tabela_id` | Liga esta tabela a `outra_tabela` |

## Exemplo (Oficina Mecânica)

### Tabela: `cliente`

**Para que serve:** a pessoa que leva o carro para consertar.

| Campo | Explicação |
|---|---|
| `id` | Identifica cada cliente |
| `nome` | Nome completo do cliente |
| `telefone` | Telefone para contato |

### Tabela: `veiculo`

**Para que serve:** o carro que o cliente leva para consertar.

| Campo | Explicação |
|---|---|
| `id` | Identifica cada veículo |
| `placa` | Placa do carro; não se repete entre veículos |
| `modelo` | Modelo do carro |
| `cliente_id` | Dono do veículo (liga a `cliente`) |

### Tabela: `ordem_servico`

**Para que serve:** um conserto do veículo, do pedido até a entrega.

| Campo | Explicação |
|---|---|
| `id` | Identifica cada ordem de serviço |
| `veiculo_id` | Veículo que está sendo consertado (liga a `veiculo`) |
| `data_abertura` | Dia em que o carro chegou |
| `data_entrega` | Dia em que o carro foi entregue; vazio enquanto não foi |
| `situacao` | Em que ponto está o conserto (aberta, em andamento, concluída) |

## Dica

Comece pelas tabelas que **não dependem de nenhuma outra** (editora, categoria, tipo...) e termine pelas que ligam tudo
(empréstimo, pedido, locação). A ordem é a mesma em que você vai criá-las no banco.
