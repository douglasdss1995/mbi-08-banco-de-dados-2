# A Loja Virtual agora é uma empresa

Banco de Dados 2 · Turma MBI-08 · Projeto único da turma

SQL: *Structured Query Language*. SKU: *Stock Keeping Unit* (código interno do produto). UF: unidade da federação (o estado). CNPJ: *Cadastro Nacional da Pessoa Jurídica*. CPF: *Cadastro de Pessoas Físicas*.

O Rafael cresceu. Além de vender, ele agora **compra de fornecedores, entrega com transportadoras, controla o dinheiro, tem funcionários, aceita devoluções e premia clientes fiéis**. O banco ganhou 17 tabelas novas. As 13 da loja continuam iguais.

## Como instalar

Rode os arquivos **nesta ordem**, no banco `loja`:

1. `01_ddl.sql`: as 13 tabelas da loja.
2. `02_carga.sql`: os dados da loja.
3. `10_expansao_ddl.sql`: as 17 tabelas novas.
4. `11_expansao_carga.sql`: os dados das tabelas novas.

Para rodar de novo, **comece sempre pelo `01_ddl.sql`** e rode os quatro arquivos na ordem. O `01_ddl.sql` apaga e recria o schema. Rodar só o `02` ou só o `11` de novo dá erro. Os dados são fictícios.

Colunas novas em tabelas antigas: `produto.estoque_minimo`, `produto.custo_medio`, `pedido.vendedor_id` (opcional) e `movimento_estoque.pedido_compra_id` (opcional).

## 1. Compras e fornecedores

A loja repõe o estoque comprando de fornecedores.

| Tabela | O que guarda |
|---|---|
| `fornecedor` | Quem vende para a loja, com CNPJ, e-mail e prazo de entrega |
| `produto_fornecedor` | Quem vende cada produto e por quanto (um produto tem 2 fornecedores) |
| `pedido_compra` | A compra: `aberto`, `enviado`, `recebido` ou `cancelado` |
| `item_pedido_compra` | Os produtos da compra, com o custo da época |

Regras do negócio:

- Produto abaixo do `estoque_minimo` precisa de reposição.
- Compra recebida dá entrada no estoque.
- O `custo_medio` do produto muda a cada compra recebida.
- Os itens só mudam enquanto a compra está aberta.

## 2. Entregas

Cada transportadora entrega em algumas UFs, num prazo.

| Tabela | O que guarda |
|---|---|
| `transportadora` | Quem entrega |
| `transportadora_uf` | Em quais UFs entrega e em quantos dias |
| `remessa` | O envio de um pedido, com o código de rastreio e o prazo previsto |
| `evento_remessa` | Cada passo do rastreio: `coletado`, `em_transito`, `saiu_para_entrega`, `entregue` ou `extraviado` |

Regras do negócio:

- Só pedido pago pode ser despachado.
- A transportadora escolhida é a mais rápida para a UF do pedido.
- Quando a remessa é entregue, o pedido também fica entregue.
- Depois de entregue, a remessa não recebe mais eventos.

## 3. Financeiro

| Tabela | O que guarda |
|---|---|
| `conta_receber` | O que a loja vai receber, por parcela. Vazio em `recebido_em` = ainda não recebeu |
| `conta_pagar` | O que a loja deve: compras, comissões, estornos e despesas. Vazio em `pago_em` = em aberto |

Regras do negócio:

- Pix cai na hora. Boleto cai em 2 dias. Cartão cai em 30 dias.
- Pagamento no cartão pode ser parcelado em 2 a 12 vezes, e a soma das parcelas fecha com o valor.
- Compra recebida vira conta a pagar, com vencimento em 30 dias.
- Cada conta a pagar tem a sua origem: compra, estorno, comissão ou despesa avulsa.

## 4. Equipe e comissão

| Tabela | O que guarda |
|---|---|
| `cargo` | Nome, salário e percentual de comissão |
| `funcionario` | Quem trabalha na empresa e se ainda está ativo |
| `comissao` | A comissão de cada pedido entregue que teve vendedor |
| `pedido.vendedor_id` | O vendedor do pedido. Vazio = pedido feito direto no site |

Regras do negócio:

- Só funcionário ativo, de cargo de vendas, pode ser vendedor.
- A comissão é o percentual do cargo sobre o pedido, sem o frete.
- A comissão é fechada por mês, só depois de o mês terminar.
- Cada vendedor recebe uma conta a pagar por mês.

## 5. Devolução

| Tabela | O que guarda |
|---|---|
| `devolucao` | O pedido de devolução: `solicitada`, `concluida` ou `recusada` |
| `item_devolucao` | Quais produtos voltam e quantos |

Regras do negócio:

- Só pedido entregue há no máximo 7 dias pode ter devolução.
- Não se devolve mais do que se comprou.
- O reembolso é o valor dos itens devolvidos, com o desconto do cupom na mesma proporção. O frete não volta.
- Devolução concluída devolve o produto ao estoque e vira um estorno a pagar.

## 6. Fidelidade

| Tabela | O que guarda |
|---|---|
| `nivel_fidelidade` | Bronze, Prata e Ouro, com os pontos mínimos e o multiplicador |
| `movimento_pontos` | O extrato de pontos do cliente: `credito`, `resgate` ou `estorno` |

Regras do negócio:

- O saldo de pontos **não é uma coluna**: é a soma do extrato.
- 1 ponto a cada R$ 10 do pedido (sem frete), vezes o multiplicador do nível do cliente.
- Os pontos entram quando o pedido é pago. Se o pedido pago for cancelado, eles saem.
- 100 pontos viram um cupom de R$ 10.

## O que vem pela frente

Nas aulas de funções, procedures e triggers, a dupla vai **programar estas regras no banco**. Leia as regras de cada módulo com atenção: elas viram perguntas da prova.
