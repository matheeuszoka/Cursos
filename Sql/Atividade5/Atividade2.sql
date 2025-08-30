CREATE DATABASE IF NOT EXISTS empresa_ecommerce;
USE empresa_ecommerce;

CREATE TABLE IF NOT EXISTS localidade (
    id_localidade INT PRIMARY KEY AUTO_INCREMENT,
    cidade VARCHAR(50) NOT NULL,
    estado VARCHAR(50) NOT NULL,
    pais VARCHAR(50) NOT NULL DEFAULT 'Brasil'
);

CREATE TABLE IF NOT EXISTS departamento (
    id_departamento INT PRIMARY KEY AUTO_INCREMENT,
    nome_dept VARCHAR(100) NOT NULL,
    id_gerente INT,
    id_localidade INT,
    FOREIGN KEY (id_localidade) REFERENCES localidade(id_localidade)
);

CREATE TABLE IF NOT EXISTS empregado (
    id_empregado INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) UNIQUE NOT NULL,
    salario DECIMAL(10,2),
    id_departamento INT,
    id_gerente INT,
    data_admissao DATE DEFAULT (CURRENT_DATE),
    ativo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (id_departamento) REFERENCES departamento(id_departamento),
    FOREIGN KEY (id_gerente) REFERENCES empregado(id_empregado)
);

ALTER TABLE departamento 
ADD FOREIGN KEY (id_gerente) REFERENCES empregado(id_empregado);

CREATE TABLE IF NOT EXISTS projeto (
    id_projeto INT PRIMARY KEY AUTO_INCREMENT,
    nome_projeto VARCHAR(100) NOT NULL,
    descricao TEXT,
    id_departamento INT,
    data_inicio DATE,
    data_fim DATE,
    FOREIGN KEY (id_departamento) REFERENCES departamento(id_departamento)
);

CREATE TABLE IF NOT EXISTS empregado_projeto (
    id_empregado INT,
    id_projeto INT,
    horas_trabalhadas DECIMAL(5,2) DEFAULT 0,
    PRIMARY KEY (id_empregado, id_projeto),
    FOREIGN KEY (id_empregado) REFERENCES empregado(id_empregado),
    FOREIGN KEY (id_projeto) REFERENCES projeto(id_projeto)
);

CREATE TABLE IF NOT EXISTS dependente (
    id_dependente INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    parentesco VARCHAR(50),
    data_nascimento DATE,
    id_empregado INT,
    FOREIGN KEY (id_empregado) REFERENCES empregado(id_empregado)
);

CREATE TABLE IF NOT EXISTS usuario (
    id_usuario INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ativo BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS usuario_backup (
    id_usuario INT,
    nome VARCHAR(100),
    email VARCHAR(100),
    data_cadastro TIMESTAMP,
    data_remocao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    motivo_remocao VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS colaborador (
    id_colaborador INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    cargo VARCHAR(50),
    salario_base DECIMAL(10,2),
    data_contratacao DATE DEFAULT (CURRENT_DATE),
    ativo BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS historico_salario (
    id_historico INT PRIMARY KEY AUTO_INCREMENT,
    id_colaborador INT,
    salario_anterior DECIMAL(10,2),
    salario_novo DECIMAL(10,2),
    data_alteracao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario_alteracao VARCHAR(100),
    FOREIGN KEY (id_colaborador) REFERENCES colaborador(id_colaborador)
);

INSERT INTO localidade (cidade, estado, pais) VALUES
('São Paulo', 'SP', 'Brasil'),
('Rio de Janeiro', 'RJ', 'Brasil'),
('Belo Horizonte', 'MG', 'Brasil'),
('Porto Alegre', 'RS', 'Brasil');

INSERT INTO empregado (nome, cpf, salario, data_admissao) VALUES
('Maria Silva', '111.111.111-11', 8000.00, '2020-01-15'),
('João Santos', '222.222.222-22', 6500.00, '2020-03-20'),
('Ana Costa', '333.333.333-33', 7200.00, '2019-08-10'),
('Pedro Oliveira', '444.444.444-44', 5800.00, '2021-02-05'),
('Carlos Souza', '555.555.555-55', 6800.00, '2020-11-12');

INSERT INTO departamento (nome_dept, id_gerente, id_localidade) VALUES
('Tecnologia', 1, 1),
('Recursos Humanos', 2, 2),
('Financeiro', 3, 3),
('Marketing', 4, 1);

UPDATE empregado SET id_departamento = 1, id_gerente = 1 WHERE id_empregado IN (2, 5);
UPDATE empregado SET id_departamento = 2, id_gerente = 2 WHERE id_empregado = 4;
UPDATE empregado SET id_departamento = 3, id_gerente = 3 WHERE id_empregado = 1;
UPDATE empregado SET id_departamento = 1 WHERE id_empregado = 3;

INSERT INTO projeto (nome_projeto, descricao, id_departamento, data_inicio, data_fim) VALUES
('Sistema ERP', 'Desenvolvimento de sistema ERP corporativo', 1, '2024-01-01', '2024-12-31'),
('Campanha Digital', 'Campanha de marketing digital', 4, '2024-03-01', '2024-06-30'),
('Reestruturação RH', 'Modernização dos processos de RH', 2, '2024-02-01', '2024-08-31'),
('Auditoria Financeira', 'Auditoria interna dos processos', 3, '2024-01-15', '2024-05-15');

INSERT INTO empregado_projeto (id_empregado, id_projeto, horas_trabalhadas) VALUES
(1, 1, 40.0), (2, 1, 35.0), (5, 1, 30.0),  -- Projeto ERP com 3 empregados
(4, 2, 25.0),                               -- Campanha Digital com 1 empregado
(2, 3, 20.0), (4, 3, 30.0),                 -- Reestruturação RH com 2 empregados
(3, 4, 35.0);                               -- Auditoria com 1 empregado

INSERT INTO dependente (nome, parentesco, data_nascimento, id_empregado) VALUES
('Lucas Silva', 'Filho', '2015-05-10', 1),
('Sofia Santos', 'Filha', '2012-08-22', 2),
('Miguel Costa', 'Filho', '2018-03-15', 3),
('Elena Oliveira', 'Filha', '2016-11-08', 4);

INSERT INTO usuario (nome, email, senha) VALUES
('Cliente A', 'clientea@email.com', 'senha123'),
('Cliente B', 'clienteb@email.com', 'senha456'),
('Cliente C', 'clientec@email.com', 'senha789');

INSERT INTO colaborador (nome, cargo, salario_base) VALUES
('José Manager', 'Gerente', 5000.00),
('Ana Developer', 'Desenvolvedora', 4000.00),
('Paulo Analyst', 'Analista', 3500.00);

CREATE OR REPLACE VIEW vw_empregados_por_dept_localidade AS
SELECT 
    d.nome_dept AS departamento,
    l.cidade,
    l.estado,
    COUNT(e.id_empregado) AS total_empregados
FROM departamento d
LEFT JOIN empregado e ON d.id_departamento = e.id_departamento
LEFT JOIN localidade l ON d.id_localidade = l.id_localidade
WHERE e.ativo = TRUE OR e.ativo IS NULL
GROUP BY d.id_departamento, d.nome_dept, l.cidade, l.estado
ORDER BY total_empregados DESC, d.nome_dept;

CREATE OR REPLACE VIEW vw_departamentos_gerentes AS
SELECT 
    d.nome_dept AS departamento,
    COALESCE(g.nome, 'Sem gerente') AS gerente,
    g.cpf AS cpf_gerente,
    g.salario AS salario_gerente,
    l.cidade,
    l.estado
FROM departamento d
LEFT JOIN empregado g ON d.id_gerente = g.id_empregado
LEFT JOIN localidade l ON d.id_localidade = l.id_localidade
ORDER BY d.nome_dept;

CREATE OR REPLACE VIEW vw_projetos_mais_empregados AS
SELECT 
    p.nome_projeto,
    p.descricao,
    d.nome_dept AS departamento,
    COUNT(ep.id_empregado) AS total_empregados,
    SUM(ep.horas_trabalhadas) AS total_horas,
    p.data_inicio,
    p.data_fim
FROM projeto p
LEFT JOIN empregado_projeto ep ON p.id_projeto = ep.id_projeto
LEFT JOIN departamento d ON p.id_departamento = d.id_departamento
GROUP BY p.id_projeto, p.nome_projeto, p.descricao, d.nome_dept, p.data_inicio, p.data_fim
ORDER BY total_empregados DESC, total_horas DESC;

CREATE OR REPLACE VIEW vw_projetos_dept_gerentes AS
SELECT 
    p.nome_projeto,
    p.descricao,
    d.nome_dept AS departamento,
    COALESCE(g.nome, 'Sem gerente') AS gerente_departamento,
    COUNT(ep.id_empregado) AS empregados_no_projeto,
    p.data_inicio,
    p.data_fim,
    CASE 
        WHEN p.data_fim < CURDATE() THEN 'Finalizado'
        WHEN p.data_inicio <= CURDATE() AND p.data_fim >= CURDATE() THEN 'Em andamento'
        ELSE 'Não iniciado'
    END AS status_projeto
FROM projeto p
LEFT JOIN departamento d ON p.id_departamento = d.id_departamento
LEFT JOIN empregado g ON d.id_gerente = g.id_empregado
LEFT JOIN empregado_projeto ep ON p.id_projeto = ep.id_projeto
GROUP BY p.id_projeto, p.nome_projeto, p.descricao, d.nome_dept, g.nome, p.data_inicio, p.data_fim
ORDER BY p.nome_projeto;

CREATE OR REPLACE VIEW vw_empregados_dependentes_gerentes AS
SELECT 
    e.nome AS empregado,
    e.cpf,
    d.nome_dept AS departamento,
    COUNT(dep.id_dependente) AS total_dependentes,
    CASE 
        WHEN dept_gerenciado.id_departamento IS NOT NULL THEN 'Sim'
        ELSE 'Não'
    END AS eh_gerente,
    dept_gerenciado.nome_dept AS departamento_que_gerencia,
    e.salario
FROM empregado e
INNER JOIN dependente dep ON e.id_empregado = dep.id_empregado
LEFT JOIN departamento d ON e.id_departamento = d.id_departamento
LEFT JOIN departamento dept_gerenciado ON e.id_empregado = dept_gerenciado.id_gerente
WHERE e.ativo = TRUE
GROUP BY e.id_empregado, e.nome, e.cpf, d.nome_dept, dept_gerenciado.id_departamento, 
         dept_gerenciado.nome_dept, e.salario
ORDER BY total_dependentes DESC, e.nome;

CREATE USER IF NOT EXISTS 'gerente'@'localhost' IDENTIFIED BY 'senha_gerente_123';
GRANT SELECT ON empresa_ecommerce.vw_empregados_por_dept_localidade TO 'gerente'@'localhost';
GRANT SELECT ON empresa_ecommerce.vw_departamentos_gerentes TO 'gerente'@'localhost';
GRANT SELECT ON empresa_ecommerce.vw_projetos_mais_empregados TO 'gerente'@'localhost';
GRANT SELECT ON empresa_ecommerce.vw_projetos_dept_gerentes TO 'gerente'@'localhost';
GRANT SELECT ON empresa_ecommerce.vw_empregados_dependentes_gerentes TO 'gerente'@'localhost';
GRANT SELECT, INSERT, UPDATE ON empresa_ecommerce.empregado TO 'gerente'@'localhost';
GRANT SELECT, INSERT, UPDATE ON empresa_ecommerce.departamento TO 'gerente'@'localhost';

CREATE USER IF NOT EXISTS 'empregado'@'localhost' IDENTIFIED BY 'senha_empregado_123';
GRANT SELECT ON empresa_ecommerce.vw_projetos_mais_empregados TO 'empregado'@'localhost';
GRANT SELECT ON empresa_ecommerce.empregado TO 'empregado'@'localhost';

FLUSH PRIVILEGES;

DELIMITER //
CREATE OR REPLACE TRIGGER tg_backup_usuario_antes_remocao
BEFORE DELETE ON usuario
FOR EACH ROW
BEGIN
    -- Inserir dados do usuário na tabela de backup antes da remoção
    INSERT INTO usuario_backup (
        id_usuario, 
        nome, 
        email, 
        data_cadastro, 
        data_remocao,
        motivo_remocao
    ) VALUES (
        OLD.id_usuario,
        OLD.nome,
        OLD.email,
        OLD.data_cadastro,
        NOW(),
        'Usuário solicitou exclusão da conta'
    );
END//
DELIMITER ;

DELIMITER //
CREATE OR REPLACE TRIGGER tg_historico_salario_antes_atualizacao
BEFORE UPDATE ON colaborador
FOR EACH ROW
BEGIN
    
    IF OLD.salario_base != NEW.salario_base THEN
        -- Registrar a alteração no histórico
        INSERT INTO historico_salario (
            id_colaborador,
            salario_anterior,
            salario_novo,
            data_alteracao,
            usuario_alteracao
        ) VALUES (
            NEW.id_colaborador,
            OLD.salario_base,
            NEW.salario_base,
            NOW(),
            USER()
        );
    END IF;
END//
DELIMITER ;

CREATE TABLE IF NOT EXISTS log_colaboradores (
    id_log INT PRIMARY KEY AUTO_INCREMENT,
    id_colaborador INT,
    nome VARCHAR(100),
    cargo VARCHAR(50),
    salario_base DECIMAL(10,2),
    data_contratacao DATE,
    data_log TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    acao VARCHAR(20) DEFAULT 'INSERT'
);

DELIMITER //
CREATE OR REPLACE TRIGGER tg_log_novo_colaborador
AFTER INSERT ON colaborador
FOR EACH ROW
BEGIN
    INSERT INTO log_colaboradores (
        id_colaborador,
        nome,
        cargo,
        salario_base,
        data_contratacao,
        acao
    ) VALUES (
        NEW.id_colaborador,
        NEW.nome,
        NEW.cargo,
        NEW.salario_base,
        NEW.data_contratacao,
        'INSERT'
    );
END//
DELIMITER ;

SELECT 'TESTE 1: Empregados por Departamento e Localidade' AS teste;
SELECT * FROM vw_empregados_por_dept_localidade;

SELECT 'TESTE 2: Departamentos e Gerentes' AS teste;
SELECT * FROM vw_departamentos_gerentes;

SELECT 'TESTE 3: Projetos com Mais Empregados' AS teste;
SELECT * FROM vw_projetos_mais_empregados;

SELECT 'TESTE 4: Projetos, Departamentos e Gerentes' AS teste;
SELECT * FROM vw_projetos_dept_gerentes;

SELECT 'TESTE 5: Empregados com Dependentes e Status de Gerente' AS teste;
SELECT * FROM vw_empregados_dependentes_gerentes;

-- Testar triggers
SELECT 'TESTANDO TRIGGERS...' AS teste;

-- Teste trigger de inserção de colaborador
INSERT INTO colaborador (nome, cargo, salario_base) VALUES 
('Novo Funcionário', 'Estagiário', 1500.00);

-- Verificar log
SELECT 'Log de Novos Colaboradores:' AS info;
SELECT * FROM log_colaboradores;

-- Teste trigger de atualização salarial
UPDATE colaborador SET salario_base = 6000.00 WHERE nome = 'José Manager';

-- Verificar histórico
SELECT 'Histórico de Alterações Salariais:' AS info;
SELECT * FROM historico_salario;

-- Teste trigger de remoção (cuidado - vai deletar o usuário!)
-- Vamos criar um usuário de teste para deletar
INSERT INTO usuario (nome, email, senha) VALUES 
('Usuário Teste Delete', 'teste@delete.com', 'senha123');

-- Deletar o usuário (trigger será executado)
DELETE FROM usuario WHERE email = 'teste@delete.com';

-- Verificar backup
SELECT 'Backup de Usuários Removidos:' AS info;
SELECT * FROM usuario_backup;

SELECT 'RELATÓRIO EXECUTIVO - RESUMO GERAL' AS relatorio;

SELECT 
    'Total de Departamentos' AS metrica, 
    COUNT(*) AS valor 
FROM vw_departamentos_gerentes
UNION ALL
SELECT 
    'Total de Projetos Ativos', 
    COUNT(*) 
FROM vw_projetos_dept_gerentes 
WHERE status_projeto = 'Em andamento'
UNION ALL
SELECT 
    'Empregados com Dependentes', 
    COUNT(DISTINCT empregado) 
FROM vw_empregados_dependentes_gerentes
UNION ALL
SELECT 
    'Total de Gerentes', 
    COUNT(*) 
FROM vw_departamentos_gerentes 
WHERE gerente != 'Sem gerente';
