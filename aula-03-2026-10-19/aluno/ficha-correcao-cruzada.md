# Ficha de correção cruzada — Exercício 2 (DDL e DML)

Banco de Dados 2 · Turma MCI-05 · Aula 4

Você corrige o trabalho de um colega do **outro grupo** que normalizou a mesma planilha. Baixe a pasta
`exercicio-2/<nome-do-colega>/` do repositório do grupo dele e **rode os scripts na sua máquina**, do zero.

DDL: *Data Definition Language* (comandos que criam a estrutura). DML: *Data Manipulation Language* (comandos que
inserem, alteram e apagam linhas).

|                 |     |
| --------------- | --- |
| **Quem corrige** |     |
| **Quem fez**     |     |
| **Planilha**     |     |

## Regras da correção

- Corrija o **trabalho**, não a pessoa. Diga o que está errado, **onde** (arquivo e linha) e **como arrumar**.
- Se a solução do colega é diferente da sua mas funciona, **não é erro**. Anote como diferença e converse.
- Se você usar IA para ajudar, confira o que ela disse rodando o script.

## 1 · Modelagem (as tabelas do `01_ddl.sql`)

Responda **sim** ou **não** e, se for «não», explique em uma linha.

| #   | Pergunta                                                                                                       | Sim/Não | Observação |
| --- | -------------------------------------------------------------------------------------------------------------- | ------- | ---------- |
| 1.1 | Não há célula com lista de valores nem colunas repetidas (1FN, primeira forma normal)?                         |         |            |
| 1.2 | Cada tabela tem chave primária, e nas tabelas de itens ou de ligação ela é composta (2FN)?                     |         |            |
| 1.3 | Nenhuma coluna depende de outra coluna que não é a chave (3FN, terceira forma normal)?                         |         |            |
| 1.4 | Toda chave estrangeira aponta para a chave primária da tabela certa?                                           |         |            |
| 1.5 | As tabelas são as mesmas do seu grupo? Se não, a diferença tem justificativa?                                  |         |            |

## 2 · Scripts (`01_ddl.sql` e `02_carga.sql`)

| #   | Pergunta                                                                                                            | Sim/Não | Observação |
| --- | ------------------------------------------------------------------------------------------------------------------- | ------- | ---------- |
| 2.1 | O `01_ddl.sql` roda duas vezes seguidas sem erro (`DROP TABLE IF EXISTS` na ordem certa)?                           |         |            |
| 2.2 | As tabelas do script são as da planilha do grupo (aula 2), com as mesmas chaves?                                    |         |            |
| 2.3 | Há chave composta onde precisa, `NOT NULL` onde a informação é obrigatória e pelo menos um `DEFAULT`?               |         |            |
| 2.4 | Os tipos fazem sentido (dinheiro em `numeric`, data em `date`, telefone em texto)?                                  |         |            |
| 2.5 | Os 3 `ALTER TABLE` pedidos estão no fim do script e funcionam?                                                      |         |            |
| 2.6 | O `02_carga.sql` roda depois do DDL sem erro, com pelo menos 5 linhas por tabela, na ordem das chaves estrangeiras? |         |            |

## 3 · Alterar, apagar e errar (`03_dml.sql`)

| #   | Pergunta                                                                                       | Sim/Não | Observação |
| --- | ---------------------------------------------------------------------------------------------- | ------- | ---------- |
| 3.1 | Todo `UPDATE` e `DELETE` tem `WHERE`, com `SELECT` antes e depois para conferir?               |         |            |
| 3.2 | O `DELETE` apaga primeiro os itens e depois a ocorrência principal?                            |         |            |
| 3.3 | Os três erros foram provocados, com a mensagem copiada?                                        |         |            |
| 3.4 | A explicação de cada erro diz **por que** o banco recusou, e não só repete a mensagem?         |         |            |

## 4 · Fechamento

- **Três acertos do trabalho:**
  1.
  2.
  3.
- **Até cinco problemas, do mais importante ao menos** (arquivo, linha e como arrumar):
  1.
  2.
  3.
- **Uma pergunta que você faria ao colega sobre o trabalho dele:**

Entregue a ficha ao colega e **converse 5 minutos** sobre ela. O colega corrige o próprio trabalho e, se quiser,
entrega de novo no Classroom até 18/11.
