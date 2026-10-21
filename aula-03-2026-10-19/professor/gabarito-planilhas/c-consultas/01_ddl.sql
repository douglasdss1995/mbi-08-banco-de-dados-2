-- Planilha C · Consultas (clínica) · estrutura do banco (aula 3, gabarito do professor)
-- Pode ser executado quantas vezes quiser: apaga e recria as tabelas.

DROP TABLE IF EXISTS consulta;
DROP TABLE IF EXISTS medico;
DROP TABLE IF EXISTS especialidade;
DROP TABLE IF EXISTS paciente;
DROP TABLE IF EXISTS convenio;

CREATE TABLE convenio (
    cod_convenio integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome         varchar(60)  NOT NULL,
    desconto     numeric(5,2) NOT NULL DEFAULT 0   -- em percentual
);

CREATE TABLE paciente (
    cod_paciente integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome         varchar(100) NOT NULL,
    cod_convenio integer      NOT NULL REFERENCES convenio (cod_convenio)
);

CREATE TABLE especialidade (
    cod_especialidade integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome              varchar(60)   NOT NULL,
    valor_base        numeric(10,2) NOT NULL
);

CREATE TABLE medico (
    cod_medico        integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome              varchar(100) NOT NULL,
    cod_especialidade integer      NOT NULL REFERENCES especialidade (cod_especialidade)
);

CREATE TABLE consulta (
    numero       integer PRIMARY KEY,
    data         date    NOT NULL DEFAULT CURRENT_DATE,
    cod_paciente integer NOT NULL REFERENCES paciente (cod_paciente),
    cod_medico   integer NOT NULL REFERENCES medico (cod_medico)
);

ALTER TABLE paciente ADD COLUMN email varchar(100);
ALTER TABLE consulta ADD COLUMN observacao text;
ALTER TABLE medico   ADD COLUMN ativo boolean NOT NULL DEFAULT true;
