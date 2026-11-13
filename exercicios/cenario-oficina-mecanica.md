# Banco da Oficina Mecânica — modelo de referência

Aula 3 · 19/10/2026

Este é o modelo em terceira forma normal (3FN) do exercício 1 (parte 2). O professor o transforma em banco de dados
**ao vivo, na frente de todos**, para mostrar o caminho. Depois, **você repete o caminho nas tabelas da planilha do seu
grupo** (aula 2) e, no tempo de projeto, no projeto. Este modelo não é o único jeito de modelar, mas é um jeito certo de
resolver a planilha.

## As regras do negócio

- Um **cliente** pode ter vários **veículos**, e cada veículo pertence a um cliente.
- Cada veículo tem um **modelo**, e cada modelo tem uma marca.
- Uma **ordem de serviço** (OS) é de um veículo e é atendida por um **mecânico**.
- Uma OS tem um ou mais **serviços**, e cada serviço pode estar em várias OS.
- O valor cobrado de um serviço fica registrado no item da OS, porque o preço de tabela muda com o tempo.
- O total de uma OS **não é guardado**: é a soma dos itens.

## As 7 tabelas

```
cliente(cod_cliente PK, nome, telefone)
modelo(cod_modelo PK, nome, marca)
veiculo(placa PK, cod_modelo FK, cod_cliente FK)
mecanico(cod_mecanico PK, nome, especialidade)
servico(cod_servico PK, descricao, valor)
ordem_servico(numero PK, data, placa FK, cod_mecanico FK)
item_servico(numero FK, cod_servico FK, valor_cobrado)     -- PK (numero, cod_servico)
```

## Os relacionamentos

| De | Para | Cardinalidade |
|---|---|---|
| `cliente` | `veiculo` | 1:N |
| `modelo` | `veiculo` | 1:N |
| `veiculo` | `ordem_servico` | 1:N |
| `mecanico` | `ordem_servico` | 1:N |
| `ordem_servico` | `servico` | N:N, resolvido por `item_servico` |

## Tipos sugeridos

| Coluna | Tipo | Por quê |
|---|---|---|
| Códigos (`cod_...`) | `integer GENERATED ALWAYS AS IDENTITY` | O banco gera o número sozinho |
| `placa` | `char(7)` | Tamanho fixo |
| `nome`, `descricao`, `marca`, `especialidade` | `varchar(n)` | Texto com limite |
| `telefone` | `varchar(20)` | Telefone não é número para somar |
| `valor`, `valor_cobrado` | `numeric(10,2)` | Dinheiro nunca em `float` |
| `data` | `date` | Só o dia |
| `numero` (da OS) | `integer` | O número da OS é do negócio, não gerado |

## Dados de partida

Estes são os dados da planilha original, usados na demonstração:

| OS | Data | Cliente | Placa | Modelo | Mecânico | Serviços |
|---|---|---|---|---|---|---|
| 1001 | 02/10/2026 | Ana Souza | ABC1D23 | Gol | Carlos Lima | Troca de óleo (120), Alinhamento (90) |
| 1002 | 02/10/2026 | Bruno Reis | XYZ9K88 | Onix | Marta Alves | Alinhamento (90) |
| 1003 | 05/10/2026 | Ana Souza | ABC1D23 | Gol | Marta Alves | Troca de pastilhas (180) |
| 1004 | 06/10/2026 | Carla Dias | QWE4R56 | Onix | Carlos Lima | Troca de óleo (120), Troca de filtro (60) |
| 1005 | 07/10/2026 | Bruno Reis | XYZ9K88 | Onix | Carlos Lima | Troca de óleo (120) |

Telefones: Ana `(47) 99111-0001`, Bruno `(47) 99222-0002`, Carla `(47) 99333-0003`.
