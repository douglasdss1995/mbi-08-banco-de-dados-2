# Gabarito — Exercício 1: Ambiente, modelo relacional e normalização

Enunciado: [`../../aula-01-2026-10-14/aluno/exercicio.md`](../../aula-01-2026-10-14/aluno/exercicio.md).
Este arquivo é do professor: **não vai para o Classroom** (regra 2 do `CLAUDE.md` da raiz).

A resolução é comentada nos 30 primeiros minutos da aula 3 (19/10, 09:00 às 09:30). Não há horário limite de entrega:
conferir no Classroom o que já chegou antes de comentar.

## Passo 1 · Problemas da tabela

1. **Atualização:** 2 linhas (OS 1001 e 1003). Se esquecer uma, a Ana passa a ter dois telefones e não há como saber qual vale.
2. **Inserção:** não. Mecânico, serviço, cliente e veículo só existem dentro de uma OS, então não há onde guardá-los antes
   do primeiro atendimento.
3. **Exclusão:** ao apagar a OS 1004, perde-se a cliente **Carla Dias (C03)** e o telefone, o veículo **QWE4R56** e o
   serviço **Troca de filtro (R$ 60)**, que não aparece em nenhuma outra OS.

## Passo 2 · 1FN - Primeira forma normal

- A coluna `servicos` viola a 1FN: guarda **vários valores na mesma célula** (serviço e valor, separados por `;`).
  Também mistura dois dados (descrição e valor) em uma célula só.
- Planilha em 1FN, com a coluna `total` já fora (ver 2.5):

| os   | data       | cod_cliente | cliente    | telefone        | placa   | modelo | marca      | cod_mecanico | mecanico    | especialidade | servico            | valor |
| ---- | ---------- | ----------- | ---------- | --------------- | ------- | ------ | ---------- | ------------ | ----------- | ------------- | ------------------ | ----- |
| 1001 | 02/10/2026 | C01         | Ana Souza  | (47) 99111-0001 | ABC1D23 | Gol    | Volkswagen | M1           | Carlos Lima | Motor         | Troca de óleo      | 120   |
| 1001 | 02/10/2026 | C01         | Ana Souza  | (47) 99111-0001 | ABC1D23 | Gol    | Volkswagen | M1           | Carlos Lima | Motor         | Alinhamento        | 90    |
| 1002 | 02/10/2026 | C02         | Bruno Reis | (47) 99222-0002 | XYZ9K88 | Onix   | Chevrolet  | M2           | Marta Alves | Suspensão     | Alinhamento        | 90    |
| 1003 | 05/10/2026 | C01         | Ana Souza  | (47) 99111-0001 | ABC1D23 | Gol    | Volkswagen | M2           | Marta Alves | Suspensão     | Troca de pastilhas | 180   |
| 1004 | 06/10/2026 | C03         | Carla Dias | (47) 99333-0003 | QWE4R56 | Onix   | Chevrolet  | M1           | Carlos Lima | Motor         | Troca de óleo      | 120   |
| 1004 | 06/10/2026 | C03         | Carla Dias | (47) 99333-0003 | QWE4R56 | Onix   | Chevrolet  | M1           | Carlos Lima | Motor         | Troca de filtro    | 60    |
| 1005 | 07/10/2026 | C02         | Bruno Reis | (47) 99222-0002 | XYZ9K88 | Onix   | Chevrolet  | M1           | Carlos Lima | Motor         | Troca de óleo      | 120   |

- **Chave primária:** composta, `(os, servico)`.

Critério: coluna correta com justificativa, tabela com uma linha por OS e serviço, chave composta.
Erro comum: dizer que a chave é só `os` (a tabela passaria a ter duas linhas com a mesma OS).

## Passo 3 · Dependências funcionais

| Dependência                              | Tipo (chave `os, servico`)                             |
| ---------------------------------------- | ------------------------------------------------------ |
| `os → data, placa, cod_mecanico`         | **Parcial** (depende só de `os`)                       |
| `servico → valor`                        | **Parcial** (depende só de `servico`; preço de tabela) |
| `placa → modelo, cod_cliente`            | **Transitiva** (`os → placa → ...`)                    |
| `modelo → marca`                         | **Transitiva** (`os → placa → modelo → marca`)         |
| `cod_cliente → cliente, telefone`        | **Transitiva** (`os → placa → cod_cliente → ...`)      |
| `cod_mecanico → mecanico, especialidade` | **Transitiva** (`os → cod_mecanico → ...`)             |

Critério: dependências corretas e classificação em parcial e transitiva.
Pontos para discutir: `cliente` e `telefone` dependem de `cod_cliente`, e **não** de `os`; o cliente não é determinado
pela OS diretamente, e sim pelo veículo (`os → placa → cod_cliente`).

## Passo 4 · 2FN e 3FN

```
cliente(cod_cliente PK, nome, telefone)
modelo(cod_modelo PK, nome, marca)
veiculo(placa PK, cod_modelo FK, cod_cliente FK)
mecanico(cod_mecanico PK, nome, especialidade)
servico(cod_servico PK, descricao, valor)
ordem_servico(numero PK, data, placa FK, cod_mecanico FK)
item_servico(numero FK, cod_servico FK, valor_cobrado)   -- PK (numero, cod_servico)
```

Critério: 2FN (tabelas `ordem_servico` e `servico` separadas), 3FN (`cliente`, `modelo`, `veiculo` e `mecanico`
separados), chaves primárias e estrangeiras corretas.

Pontos que valem uma conversa em sala:

- `cod_cliente` fica em `veiculo`, **não** em `ordem_servico`: o cliente da OS é o dono do veículo (dependência transitiva).
- `valor_cobrado` em `item_servico` guarda o preço **no dia do serviço**. Se o aluno deixar o valor só em `servico`,
  aceitar com a justificativa de que o preço é de tabela, mas apontar que mudar o preço alteraria o histórico das OS antigas.
- Aceitar `modelo(nome PK, marca)` (chave natural) com a ressalva de que dois modelos de marcas diferentes podem ter o mesmo nome.

### Atributo derivado

**Calcular.** O `total` é a soma dos `valor_cobrado` dos itens da OS. Guardá-lo cria redundância: se um item mudar, o total
guardado fica errado (anomalia de atualização). A consulta é simples:

```sql
SELECT numero, SUM(valor_cobrado) AS total
FROM item_servico
GROUP BY numero;
```

Aceitar "guardar" se o aluno justificar com desempenho ou com o fechamento fiscal (total que não pode mudar depois de
emitido). Esse é o tema da **desnormalização**, que volta na aula 9.

## Passo 5 · Diagrama da oficina

| Relacionamento               | Cardinalidade                      |
| ---------------------------- | ---------------------------------- |
| `cliente` — `veiculo`        | 1:N                                |
| `modelo` — `veiculo`         | 1:N                                |
| `veiculo` — `ordem_servico`  | 1:N                                |
| `mecanico` — `ordem_servico` | 1:N                                |
| `ordem_servico` — `servico`  | N:N (resolvido por `item_servico`) |

Critério: 7 tabelas, chaves visíveis, cardinalidades corretas.
Erro comum: desenhar `ordem_servico` ligada direto a `servico` com N:N, sem a tabela associativa.

## Passo 6 · Diagrama do tema

| Critério                                                                       |
| ------------------------------------------------------------------------------ |
| Pelo menos 6 tabelas, com PK e FK                                              |
| Cardinalidades marcadas e coerentes com o tema                                 |
| Em 3FN (sem listas na célula nem dados repetidos que dependem de outra coluna) |
| Imagem no repositório e **commit do próprio aluno** (o link confere)           |

Referência para o professor: os modelos dos 10 temas estão em [docs/projetos/](../../../docs/projetos/00-estrutura-das-entregas.md).
Não compartilhar com os alunos antes da entrega.

## Fechamento em sala (aula 3, 09:00–09:30)

1. 10 min: refazer a normalização da oficina no quadro, a partir da planilha, com os alunos dizendo o próximo passo.
2. 10 min: mostrar 2 ou 3 diagramas de temas (com autorização dos grupos) e comentar o erro mais comum.
3. 10 min: dúvidas e ajustes dos diagramas, que alimentam a aula 3 (DDL do cenário).
