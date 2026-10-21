# Gabarito — Oficina de normalização (planilhas A a E)

Planilhas: [`../aluno/planilhas-oficina/`](../aluno/planilhas-oficina/) (um `.csv` por planilha). Roteiro do aluno:
[`../aluno/roteiro-oficina-mecanica.md`](../aluno/roteiro-oficina-mecanica.md). Este arquivo é do professor: **não vai para o Classroom**.

A oficina **não é entregue nem vale nota**. O gabarito serve para o professor circular e para o confronto das 10:40.
Cada planilha foi escolhida para exercitar um tipo de problema diferente.

| Planilha | Grupos | Problema principal |
|---|---|---|
| A · Pedidos | 1 e 6 | Colunas repetidas (1FN) e dependência transitiva (cidade → estado) |
| B · Matrículas | 2 e 7 | Chave composta e dependências parciais (2FN) |
| C · Consultas | 3 e 8 | Já está em 1FN e 2FN: só dependências transitivas (3FN) |
| D · Aluguéis | 4 e 9 | Lista dentro da célula, N:N e atributos derivados |
| E · Estoque | 5 e 10 | Chave composta, parcial e transitiva juntas |

A atribuição é `planilha = ((grupo − 1) mod 5) + 1`, de modo que os grupos 1 e 6 têm a mesma planilha, e assim por diante.

---

## A · Pedidos (papelaria)

**Anomalias.** Atualização: a cidade da Lia (Joinville) está em 2 linhas. Inserção: não há onde cadastrar um produto novo
sem pedido. Exclusão: apagar o pedido P-104 faz sumir a cliente Bia Nunes e a cidade Curitiba.

**1FN.** As colunas `item_1`/`qtd_1`/`preco_1` e `item_2`/`qtd_2`/`preco_2` são **grupos repetidos**. Uma linha por
**pedido e item**; chave composta `(pedido, item)`.

**Dependências.**

| Dependência | Tipo |
|---|---|
| `pedido → data, cod_cliente, vendedor` | Parcial |
| `item → preco` | Parcial |
| `cod_cliente → cliente, cidade_cliente` | Transitiva (`pedido → cod_cliente → ...`) |
| `cidade_cliente → estado` | Transitiva |

**Tabelas em 3FN.**

```
cidade(cod_cidade PK, nome, estado)
cliente(cod_cliente PK, nome, cod_cidade FK)
vendedor(cod_vendedor PK, nome)
produto(cod_produto PK, descricao, preco)
pedido(numero PK, data, cod_cliente FK, cod_vendedor FK)
item_pedido(numero FK, cod_produto FK, quantidade, preco_cobrado)   -- PK (numero, cod_produto)
```

**Ponto para o confronto:** `preco_cobrado` no item (o preço muda com o tempo) ou só `produto.preco`? Aceitar as duas,
com justificativa. Aceitar também `vendedor` como coluna de `pedido` se o grupo justificar que não há dado sobre ele.

---

## B · Matrículas (escola de idiomas)

**Anomalias.** Atualização: o telefone do professor Marcos aparece em 4 linhas. Inserção: não dá para cadastrar uma turma
sem aluno. Exclusão: apagar a matrícula do Davi na turma `T-FRA1` faz sumir a turma de Francês e a professora Júlia.

**1FN.** Já está em 1FN (um valor por célula). Chave composta: `(cod_aluno, turma)`.

**Dependências.**

| Dependência | Tipo |
|---|---|
| `cod_aluno → aluno` | Parcial |
| `turma → idioma, nivel, professor, sala, dia_semana, horario` | Parcial |
| `professor → fone_professor` | Transitiva (`turma → professor → fone_professor`) |
| `(cod_aluno, turma) → data_matricula, nota_final` | Completa |

**Tabelas em 3FN.**

```
aluno(cod_aluno PK, nome)
professor(cod_professor PK, nome, fone)
turma(cod_turma PK, idioma, nivel, cod_professor FK, sala, dia_semana, horario)
matricula(cod_aluno FK, cod_turma FK, data_matricula, nota_final)   -- PK (cod_aluno, cod_turma)
```

**Ponto para o confronto:** `idioma` poderia ser uma tabela própria (`idioma`), já que se repete. Aceitar as duas formas;
quem separar deve justificar o ganho.

---

## C · Consultas (clínica)

**Anomalias.** Atualização: o desconto da Unimed (30%) está em 3 linhas. Inserção: não dá para cadastrar um médico novo
sem consulta. Exclusão: apagar a consulta 5 faz sumir o paciente Caio Pires.

**1FN e 2FN.** A planilha **já está em 1FN e em 2FN** (chave simples `consulta`). Os alunos precisam perceber que o
problema está só na 3FN, e não "inventar" separações.

**Dependências (todas transitivas).**

| Dependência | Tipo |
|---|---|
| `consulta → data, cod_paciente, medico` | Completa |
| `cod_paciente → paciente, convenio` | Transitiva |
| `convenio → desconto` | Transitiva (`consulta → cod_paciente → convenio → desconto`) |
| `medico → especialidade` | Transitiva |
| `especialidade → valor_base` | Transitiva |
| `valor_final = valor_base × (1 − desconto)` | **Derivado** |

**Tabelas em 3FN.**

```
convenio(cod_convenio PK, nome, desconto)
paciente(cod_paciente PK, nome, cod_convenio FK)
especialidade(cod_especialidade PK, nome, valor_base)
medico(cod_medico PK, nome, cod_especialidade FK)
consulta(numero PK, data, cod_paciente FK, cod_medico FK)
```

**Ponto para o confronto:** `valor_final` é derivado: **calcular**, não guardar. Se o grupo guardar, deve justificar (por
exemplo, o valor cobrado não pode mudar se o desconto mudar depois). Ligue com a aula 9 (desnormalização).

---

## D · Aluguéis (equipamentos)

**Anomalias.** Atualização: o telefone do Hugo está em 2 linhas. Inserção: não dá para cadastrar um equipamento novo
sem contrato. Exclusão: apagar o contrato L-06 faz sumir a cliente Kátia Dias.

**1FN.** A coluna `equipamentos` guarda **uma lista** (equipamento e diária, separados por `;`). Uma linha por **contrato
e equipamento**; chave composta `(contrato, equipamento)`. As colunas `dias` e `total` são **derivadas** (de `retirada`
e `devolucao`, e das diárias).

**Dependências.**

| Dependência | Tipo |
|---|---|
| `contrato → retirada, devolucao, cod_cliente` | Parcial |
| `equipamento → diaria` | Parcial |
| `cod_cliente → cliente, telefone` | Transitiva |
| `dias = devolucao − retirada` | **Derivado** |
| `total = dias × soma das diárias` | **Derivado** |

**Tabelas em 3FN.**

```
cliente(cod_cliente PK, nome, telefone)
equipamento(cod_equipamento PK, descricao, diaria)
contrato(numero PK, retirada, devolucao, cod_cliente FK)
item_contrato(numero FK, cod_equipamento FK, diaria_cobrada)   -- PK (numero, cod_equipamento)
```

**Diagrama:** `contrato` e `equipamento` são **N:N**, resolvido por `item_contrato`.

**Ponto para o confronto:** `dias` e `total` não são guardados. Conferir a conta: L-04 = (30 + 80 + 20) × 3 = R$ 390.

---

## E · Estoque (depósitos)

**Anomalias.** Atualização: o telefone da Metalúrgica Sul está em 3 linhas. Inserção: não dá para cadastrar um depósito
novo sem produto, nem um produto novo sem depósito. Exclusão: apagar a linha da `Porca M6` no Depósito Norte faz sumir a
própria porca.

**1FN.** Já está em 1FN. Chave composta: `(cod_produto, cod_deposito)`.

**Dependências.**

| Dependência | Tipo |
|---|---|
| `cod_produto → produto, categoria, cod_fornecedor, custo_unit` | Parcial |
| `cod_deposito → deposito, cidade_deposito` | Parcial |
| `cod_fornecedor → fornecedor, fone_fornecedor` | Transitiva |
| `(cod_produto, cod_deposito) → quantidade` | Completa |

**Tabelas em 3FN.**

```
fornecedor(cod_fornecedor PK, nome, fone)
produto(cod_produto PK, nome, categoria, custo_unit, cod_fornecedor FK)
deposito(cod_deposito PK, nome, cidade)
estoque(cod_produto FK, cod_deposito FK, quantidade)   -- PK (cod_produto, cod_deposito)
```

**Ponto para o confronto:** `categoria` pode ser uma tabela própria. `estoque` é a tabela associativa N:N entre produto e
depósito, com a `quantidade` como atributo do **relacionamento**.

---

## Roteiro do confronto (10:40 às 10:50)

1. Cada dupla de grupos (mesma planilha) projeta ou mostra as tabelas finais ao lado uma da outra.
2. Pergunta-guia do professor: **"o que cada tabela tem que a outra não tem?"**
3. Se houver erro, perguntar a anomalia que ele causa (não corrigir direto).
4. Fechar com a diferença mais interessante de cada planilha (ver "Ponto para o confronto").

## Erros comuns (todas as planilhas)

- Dizer que a chave é só a primeira coluna, sem reparar na chave composta.
- Separar tabelas sem criar a chave estrangeira que as liga.
- Guardar valor derivado (total, dias, valor final) sem justificar.
- Criar tabela para uma coluna que **não** se repete e não depende de outra (normalizar demais).
