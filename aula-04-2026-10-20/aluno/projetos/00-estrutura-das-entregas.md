# Estrutura das entregas dos projetos (vale para os 10 projetos)

Cada aluno desenvolve **o seu projeto**, sorteado entre os 10 temas, durante todo o curso e entrega uma versão a cada uma
das provas 1, 2 e 3, mais a apresentação final (prova 4). As entregas são **individuais**; alunos com o mesmo tema
podem trocar ideias. O que é específico de cada tema está no arquivo do projeto.

## Regras comuns

- **Consulta e IA liberadas.** Por isso, a entrega precisa mostrar **evidência e justificativa**, não só o código:
  cada item pede o resultado de execução, o motivo da decisão e o que foi testado.
- **Tudo o que cai foi dado em aula** antes da prova (ver a coluna "Dado na aula" em cada projeto).
- O banco é recriado do zero rodando os scripts na ordem. **Entrega que não roda do zero perde pontos.**
- Cada versão **acrescenta** à anterior; não se refaz o projeto a cada prova.
- O `LEIAME.md` registra o uso de IA (o que a IA sugeriu, o que o aluno corrigiu) e **com quem o aluno conversou** sobre o
  projeto (colegas do mesmo tema ou de outros). Ver «Colaboração entre colegas» em [avaliação](.

## Entrega pelo Classroom

Cada aluno entrega os arquivos do projeto na atividade de cada prova no **Google Classroom**.

- **Como enviar:** os arquivos da estrutura abaixo, em uma pasta compactada (`.zip`) ou um a um. O nome da entrega é `prova-1`,
  `prova-2`, `prova-3` ou `final`.
- **Prazo:** o horário da prova (até **11:30 do dia da prova**); o que for enviado depois não conta.
- Cada versão **acrescenta** à anterior; entregue sempre o projeto completo até aquele ponto.
- Nada de senhas, dumps com dados pessoais reais ou arquivos grandes demais.

## Estrutura da pasta de entrega

```
README.md                   (ou LEIAME.md) decisões, regras de negócio, colaboração, uso de IA
diagrama/                   arquivo do ERD Concepts + imagem (PNG ou PDF)
sql/
  01_ddl.sql                estrutura (prova 1)
  02_carga.sql              dados de teste (prova 1)
  03_transacoes.sql         transações e concorrência (prova 1)
  04_consultas.sql          funções SQL, subconsultas, CTE, JSONB (prova 2)
  05_janelas_views.sql      window functions e views (prova 2)
  06_indices.sql            índice e EXPLAIN (prova 3)
  07_funcoes.sql            funções em PL/pgSQL (prova 3)
  08_procedures.sql         procedures (prova 3)
  09_triggers.sql           triggers: auditoria e regra de negócio (prova 3)
evidencias/                 prints ou saídas de EXPLAIN, sessões simultâneas e testes manuais
validacao/                  pedido de validação (prova 1): entradas.sql, consultas.sql, resultados.md, ataques.sql e achados.md
instalar.sql                recria o banco do zero (entrega final)
```

## O que se avalia em cada prova

| Prova | Aula | Entrega | Conteúdo cobrado |
|---|---|---|---|
| 1 | 12 | Modelo, DDL, carga, consultas do pedido de validação, integridade, transações e concorrência | Aulas 1–11 (revisão, modelagem do projeto, DDL e carga, consultas, `UPDATE`/`DELETE`, integridade, transações e ACID) |
| 2 | 16 | Funções SQL, subconsultas/CTE, `JSONB` básico, window functions, views | Aulas 13–15 |
| 3 | 21 | Índice, funções, procedures, triggers | Aulas 17–20 |
| 4 | 23 e 24 | Apresentação final: demonstração e desenvolvimento do projeto | Todo o curso |

## Nota

- **60% a entrega** (10 pontos pela rubrica de cada projeto) e **40% a explicação individual** (apresentação curta ou
  pergunta individual sobre a própria entrega).
- Provas 1 a 3: **um terço da turma, sorteado, apresenta** (cerca de 5 minutos) e cada aluno apresenta uma vez nas três
  provas; **os demais respondem uma pergunta individual por escrito** no Classroom. As perguntas de cada prova são definidas
  quando o banco for montado (T-05): um banco por prova, em `professor/` de cada aula. As regras de pergunta oral sorteada e
  de troca por reserva (D-11, D-35 e D-36) ficam **só para a prova 4**, a pergunta de 1 minuto na apresentação final.
- A nota de explicação individual (40%) nunca é compartilhada com colegas: cada aluno responde pelo que entregou.

## Apresentação curta (provas 1 a 3)

Cerca de 5 minutos para os alunos sorteados na prova. Mostrar: o que foi feito desde a última entrega, **uma decisão
difícil** e **um problema que a IA errou ou que o aluno corrigiu**. Com 24 alunos, são 8 apresentações por prova (cerca de
40 minutos).

## Apresentação final (prova 4, aulas 23 e 24)

Metade da turma apresenta na aula 23 e a outra metade na aula 24. A entrega `final`
vale até as 10:00 do dia em que o aluno apresenta. 6 minutos por aluno: demonstração de ponta a ponta (3 min),
desenvolvimento do projeto (2 min), perguntas (1 min). Entrega final: a pasta `final` no Classroom, que **recria o banco
do zero** com um único script (`instalar.sql`). O desenvolvimento do projeto conta: linha do tempo, decisões,
dificuldades, uso de IA e aprendizados.

**Rubrica da prova 4 (parte da entrega, 10 pontos):**

| Critério | Pontos |
|---|---|
| Demonstração: cenário de ponta a ponta, regras de negócio funcionando ao vivo | 4,0 |
| Desenvolvimento do projeto: linha do tempo, decisões e dificuldades | 2,5 |
| Uso de IA: o que a IA errou e o que o aluno corrigiu | 1,5 |
| Entrega: `instalar.sql` que recria o banco do zero, `README.md` e colaboração registrada | 2,0 |

A pergunta do professor (1 min) alimenta a parte individual (40%), não a da entrega. Não há penalidade à parte.
