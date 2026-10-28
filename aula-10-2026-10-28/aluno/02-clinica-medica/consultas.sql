-- Clínica médica · consultas.sql
-- As 16 consultas de validação (C1 a C16), depois das 5 entradas. Só leem: não alteram o banco.
-- «Hoje» é current_date.
SET search_path TO clinica, prontuario;

-- C1 · Quantas consultas, pacientes e médicos existem
SELECT (SELECT count(*) FROM consulta) AS consultas, (SELECT count(*) FROM paciente) AS pacientes, (SELECT count(*) FROM medico) AS medicos;

-- C2 · Agenda de hoje: hora, médico, paciente, tipo e status
SELECT to_char(c.inicio, 'HH24:MI') AS hora, m.nome AS medico, p.nome AS paciente, t.nome AS tipo, c.status
FROM consulta c JOIN medico m ON m.id = c.medico_id JOIN paciente p ON p.id = c.paciente_id JOIN tipo_consulta t ON t.id = c.tipo_id
WHERE c.inicio::date = current_date ORDER BY c.inicio;

-- C3 · Quantos médicos cada especialidade tem (toda especialidade aparece)
SELECT e.nome, count(me.medico_id) AS medicos
FROM especialidade e LEFT JOIN medico_especialidade me ON me.especialidade_id = e.id
GROUP BY e.nome ORDER BY medicos DESC, e.nome;

-- C4 · Horários de atendimento da Helena Costa (dia da semana, início e fim)
SELECT h.dia_semana, h.inicio, h.fim FROM horario_atendimento h JOIN medico m ON m.id = h.medico_id
WHERE m.nome = 'Helena Costa' ORDER BY h.dia_semana, h.inicio;

-- C5 · Médicos sem nenhuma consulta
SELECT m.nome FROM medico m WHERE NOT EXISTS (SELECT 1 FROM consulta c WHERE c.medico_id = m.id);

-- C6 · Pacientes sem nenhuma consulta
SELECT p.nome FROM paciente p WHERE NOT EXISTS (SELECT 1 FROM consulta c WHERE c.paciente_id = p.id);

-- C7 · Quanto cada convênio deve pagar nas consultas (soma da parte do convênio; todo convênio aparece)
SELECT cv.nome, COALESCE(SUM(pg.valor_convenio), 0) AS a_receber
FROM convenio cv LEFT JOIN consulta c ON c.convenio_id = cv.id LEFT JOIN pagamento pg ON pg.consulta_id = c.id
GROUP BY cv.nome ORDER BY a_receber DESC;

-- C8 · Retornos gratuitos: paciente, médico e quantos dias depois da consulta anterior do mesmo médico
SELECT p.nome AS paciente, m.nome AS medico, c.inicio::date - (SELECT max(a.inicio::date) FROM consulta a
        WHERE a.paciente_id = c.paciente_id AND a.medico_id = c.medico_id AND a.inicio < c.inicio) AS dias_depois
FROM consulta c JOIN tipo_consulta t ON t.id = c.tipo_id JOIN paciente p ON p.id = c.paciente_id JOIN medico m ON m.id = c.medico_id
JOIN pagamento pg ON pg.consulta_id = c.id
WHERE t.nome = 'Retorno' AND pg.valor_total = 0 ORDER BY c.inicio;

-- C9 · Valor de tabela da Primeira consulta em cada consulta já marcada, e o valor de hoje
SELECT c.inicio::date - current_date AS dia, c.valor_tabela, (SELECT valor FROM tipo_consulta WHERE nome = 'Primeira consulta') AS valor_hoje
FROM consulta c JOIN tipo_consulta t ON t.id = c.tipo_id WHERE t.nome = 'Primeira consulta' ORDER BY c.inicio;

-- C10 · Consultas canceladas: paciente e quanto foi cobrado
SELECT p.nome, pg.valor_total FROM consulta c JOIN paciente p ON p.id = c.paciente_id LEFT JOIN pagamento pg ON pg.consulta_id = c.id
WHERE c.status = 'cancelada';

-- C11 · Faltas por paciente (todo paciente aparece)
SELECT p.nome, count(c.id) FILTER (WHERE c.status = 'faltou') AS faltas
FROM paciente p LEFT JOIN consulta c ON c.paciente_id = p.id GROUP BY p.nome ORDER BY faltas DESC, p.nome;

-- C12 · Consultas por médico (todo médico aparece)
SELECT m.nome, count(c.id) AS consultas FROM medico m LEFT JOIN consulta c ON c.medico_id = m.id GROUP BY m.nome ORDER BY consultas DESC, m.nome;

-- C13 · Por atendimento: paciente, CID, quantos medicamentos e quantos exames
SELECT p.nome, a.diagnostico_cid,
       (SELECT count(*) FROM prescricao r WHERE r.atendimento_id = a.id) AS medicamentos,
       (SELECT count(*) FROM exame_solicitado x WHERE x.atendimento_id = a.id) AS exames
FROM atendimento a JOIN consulta c ON c.id = a.consulta_id JOIN paciente p ON p.id = c.paciente_id ORDER BY p.nome;

-- C14 · Pacientes com o convênio e o percentual de cobertura (particular aparece sem convênio)
SELECT p.nome, cv.nome AS convenio, cv.percentual_cobertura FROM paciente p LEFT JOIN convenio cv ON cv.id = p.convenio_id ORDER BY p.nome;

-- C15 · Quanto cada paciente ainda deve (parte do paciente em pagamentos pendentes)
SELECT p.nome, SUM(pg.valor_paciente) AS deve
FROM pagamento pg JOIN consulta c ON c.id = pg.consulta_id JOIN paciente p ON p.id = c.paciente_id
WHERE pg.situacao = 'pendente' GROUP BY p.nome ORDER BY deve DESC;

-- C16 · Consultas realizadas por tipo (todo tipo aparece)
SELECT t.nome, count(c.id) FILTER (WHERE c.status = 'realizada') AS realizadas
FROM tipo_consulta t LEFT JOIN consulta c ON c.tipo_id = t.id GROUP BY t.nome ORDER BY realizadas DESC, t.nome;
