-- Planilha B · Matrículas (escola de idiomas) · estrutura do banco (aula 3, gabarito do professor)
-- Pode ser executado quantas vezes quiser: apaga e recria as tabelas.

DROP TABLE IF EXISTS matricula;
DROP TABLE IF EXISTS turma;
DROP TABLE IF EXISTS professor;
DROP TABLE IF EXISTS aluno;

CREATE TABLE aluno (
    cod_aluno integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome      varchar(100) NOT NULL
);

CREATE TABLE professor (
    cod_professor integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome          varchar(100) NOT NULL,
    fone          varchar(20)
);

CREATE TABLE turma (
    cod_turma     varchar(10) PRIMARY KEY,
    idioma        varchar(30) NOT NULL,
    nivel         varchar(30) NOT NULL,
    cod_professor integer     NOT NULL REFERENCES professor (cod_professor),
    sala          varchar(20) NOT NULL,
    dia_semana    varchar(20) NOT NULL,
    horario       time        NOT NULL
);

CREATE TABLE matricula (
    cod_aluno      integer     NOT NULL REFERENCES aluno (cod_aluno),
    cod_turma      varchar(10) NOT NULL REFERENCES turma (cod_turma),
    data_matricula date        NOT NULL DEFAULT CURRENT_DATE,
    nota_final     numeric(3,1),
    PRIMARY KEY (cod_aluno, cod_turma)
);

ALTER TABLE aluno     ADD COLUMN email varchar(100);
ALTER TABLE matricula ADD COLUMN observacao text;
ALTER TABLE professor ADD COLUMN ativo boolean NOT NULL DEFAULT true;
