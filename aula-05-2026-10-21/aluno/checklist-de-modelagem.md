# Checklist de modelagem

Banco de Dados 2 · Turma MBI-08 · Aula 5

Use esta lista para conferir o **seu** modelo e para corrigir o modelo de um colega. A turma completa a lista na aula,
a partir dos erros e acertos que apareceram nas apresentações.

Siglas: **PK** (*Primary Key*, chave primária), **FK** (*Foreign Key*, chave estrangeira), **N:N** (muitos para muitos),
**1:N** (um para muitos).

## 1. Do relato às tabelas

- [ ] Cada **substantivo importante** do relato do cliente virou uma tabela ou um campo (e você sabe dizer qual).
- [ ] Cada **planilha ou caderno** que o cliente usa hoje está representado.
- [ ] Cada **pergunta** que o cliente quer responder («o que vence hoje?») pode ser respondida com as suas tabelas.
- [ ] Cada **regra** que ele contou (prazos, limites, valores) tem um lugar no modelo: uma tabela de regras ou um campo.

## 2. Tabelas e chaves

- [ ] Toda tabela tem **PK** (uma coluna `id`, ou uma chave composta quando a tabela só liga duas outras).
- [ ] Nenhuma tabela mistura **duas coisas** diferentes (ex.: título do livro e a cópia que está emprestada).
- [ ] O mesmo dado **não aparece em dois lugares** (nome da editora repetido em cada livro).
- [ ] Cada tabela tem **nome no singular** e campos com nome claro.

## 3. Ligações

- [ ] Toda ligação **1:N** tem a **FK** do lado do «N» (muitos).
- [ ] Toda ligação **N:N** virou uma **tabela de ligação** (ex.: livro e autor → `livro_autor`), com as duas FK.
- [ ] A tabela de ligação precisa de **mais um dado**? (ordem, papel, valor da época): coloque nela.
- [ ] Cada FK aponta para uma PK que **existe** e está no diagrama.

## 4. O que muda com o tempo

- [ ] Valores que **mudam** (preço, tarifa, prazo) têm **histórico** (uma linha por período, com data de início) ou são
      **copiados** para o registro na hora da venda, da locação, do empréstimo.
- [ ] Dados que o cliente **pode mudar depois** (endereço, contato) e que não podem alterar o passado são **copiados**.
- [ ] Um **status** (aberto, pago, cancelado) está em um campo com valores combinados; mudanças importantes têm **registro**.
- [ ] Algo que dá para **calcular** (total, atraso, saldo) está claro se será gravado ou calculado, e você sabe justificar.

## 5. Antes de entregar

- [ ] O diagrama está legível, com as PK e as FK marcadas.
- [ ] Você consegue explicar em **1 minuto** o modelo inteiro e **uma decisão difícil**.
- [ ] Anotou o que a IA sugeriu e o que você mudou.
