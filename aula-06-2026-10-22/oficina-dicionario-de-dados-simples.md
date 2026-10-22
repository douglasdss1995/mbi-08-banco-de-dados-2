# Dicionário de dados simples — Oficina Mecânica

Banco de Dados 2 · Turma MBI-08 · Aula 6

Este é o dicionário da **Oficina Mecânica**, o exemplo que o professor transforma em banco de dados **ao vivo**, na frente
de todos. Depois, você faz o mesmo com o dicionário do **seu** projeto.

Siglas: **PK** (*Primary Key*, chave primária), **FK** (*Foreign Key*, chave estrangeira), **N:N** (muitos para muitos).

## O negócio

- Um **cliente** pode ter vários **veículos**, e cada veículo é de um cliente.
- Cada veículo tem um **modelo**, e cada modelo tem uma marca.
- Uma **ordem de serviço** (OS) é de um veículo e é atendida por um **mecânico**.
- Uma OS tem um ou mais **serviços**, e cada serviço pode estar em várias OS.
- O valor cobrado de um serviço fica registrado na OS, porque o preço de tabela muda com o tempo.
- O total de uma OS **não é guardado**: é a soma dos itens.

## As 7 tabelas

### Tabela: `cliente`

**Para que serve:** a pessoa que leva o carro para consertar.

| Campo | Explicação |
|---|---|
| `id` | Identifica cada cliente |
| `nome` | Nome completo |
| `telefone` | Telefone para contato |

### Tabela: `modelo`

**Para que serve:** o modelo do carro e sua marca.

| Campo | Explicação |
|---|---|
| `id` | Identifica cada modelo |
| `nome` | Nome do modelo (Gol, Onix...) |
| `marca` | Marca do modelo |

### Tabela: `mecanico`

**Para que serve:** quem faz o conserto.

| Campo | Explicação |
|---|---|
| `id` | Identifica cada mecânico |
| `nome` | Nome do mecânico |
| `especialidade` | Em que o mecânico é especialista; pode ficar vazio |

### Tabela: `servico`

**Para que serve:** o catálogo do que a oficina faz.

| Campo | Explicação |
|---|---|
| `id` | Identifica cada serviço |
| `descricao` | Nome do serviço (Troca de óleo...); não se repete |
| `valor` | Preço de tabela de hoje |

### Tabela: `veiculo`

**Para que serve:** o carro que o cliente leva.

| Campo | Explicação |
|---|---|
| `id` | Identifica cada veículo |
| `placa` | Placa do carro; não se repete |
| `modelo_id` | Modelo do veículo (liga a `modelo`) |
| `cliente_id` | Dono do veículo (liga a `cliente`) |

### Tabela: `ordem_servico`

**Para que serve:** um conserto, do pedido à entrega.

| Campo | Explicação |
|---|---|
| `id` | Identifica cada ordem de serviço |
| `numero` | Número da OS usado pela oficina (1001, 1002...); não se repete |
| `data_abertura` | Dia em que o carro chegou |
| `veiculo_id` | Veículo consertado (liga a `veiculo`) |
| `mecanico_id` | Mecânico responsável (liga a `mecanico`) |

### Tabela: `item_servico`

**Para que serve:** liga a OS aos serviços feitos nela (N:N).

| Campo | Explicação |
|---|---|
| `ordem_servico_id` | A OS (liga a `ordem_servico`) |
| `servico_id` | O serviço feito (liga a `servico`) |
| `valor_cobrado` | Quanto foi cobrado nesse serviço, nessa OS |

A **PK** de `item_servico` é a combinação dos dois primeiros campos: o mesmo serviço não entra duas vezes na mesma OS.
