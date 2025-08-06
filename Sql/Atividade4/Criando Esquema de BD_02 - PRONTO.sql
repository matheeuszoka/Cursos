-- =====================================================
-- SISTEMA DE BANCO DE DADOS - OFICINA MECÂNICA
-- =====================================================

-- Criação do banco de dados
CREATE DATABASE IF NOT EXISTS oficina_mecanica;
USE oficina_mecanica;

-- =====================================================
-- CRIAÇÃO DAS TABELAS (DDL)
-- =====================================================

-- Tabela de Clientes
CREATE TABLE clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    sobrenome VARCHAR(50) NOT NULL,
    cpf CHAR(11) NOT NULL UNIQUE,
    telefone CHAR(11),
    email VARCHAR(100),
    endereco VARCHAR(255),
    data_cadastro DATE DEFAULT (CURRENT_DATE),
    CONSTRAINT unique_cpf_cliente UNIQUE (cpf)
);

-- Tabela de Veículos
CREATE TABLE veiculos (
    id_veiculo INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    marca VARCHAR(30) NOT NULL,
    modelo VARCHAR(50) NOT NULL,
    ano YEAR NOT NULL,
    placa CHAR(7) NOT NULL UNIQUE,
    cor VARCHAR(20),
    km_atual INT DEFAULT 0,
    combustivel ENUM('Gasolina', 'Etanol', 'Diesel', 'Flex', 'Eletrico') NOT NULL,
    CONSTRAINT fk_veiculo_cliente FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

-- Tabela de Mecânicos
CREATE TABLE mecanicos (
    id_mecanico INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    sobrenome VARCHAR(50) NOT NULL,
    cpf CHAR(11) NOT NULL UNIQUE,
    telefone CHAR(11),
    especialidade VARCHAR(50),
    salario DECIMAL(8,2),
    data_contratacao DATE NOT NULL,
    status_funcionario ENUM('Ativo', 'Inativo', 'Licenca') DEFAULT 'Ativo'
);

-- Tabela de Serviços
CREATE TABLE servicos (
    id_servico INT AUTO_INCREMENT PRIMARY KEY,
    nome_servico VARCHAR(100) NOT NULL,
    descricao TEXT,
    categoria ENUM('Preventiva', 'Corretiva', 'Revisao', 'Emergencia') NOT NULL,
    tempo_estimado INT, -- em minutos
    preco_base DECIMAL(8,2) NOT NULL
);

-- Tabela de Peças
CREATE TABLE pecas (
    id_peca INT AUTO_INCREMENT PRIMARY KEY,
    nome_peca VARCHAR(100) NOT NULL,
    codigo_peca VARCHAR(50) UNIQUE,
    categoria VARCHAR(50),
    preco_unitario DECIMAL(8,2) NOT NULL,
    estoque_atual INT DEFAULT 0,
    estoque_minimo INT DEFAULT 5,
    fornecedor VARCHAR(100)
);

-- Tabela de Ordens de Serviço
CREATE TABLE ordens_servico (
    id_ordem INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    id_veiculo INT NOT NULL,
    id_mecanico INT NOT NULL,
    data_entrada DATETIME DEFAULT CURRENT_TIMESTAMP,
    data_saida DATETIME NULL,
    status_ordem ENUM('Aberta', 'Em andamento', 'Aguardando peças', 'Concluida', 'Cancelada') DEFAULT 'Aberta',
    descricao_problema TEXT,
    km_veiculo INT,
    valor_total DECIMAL(10,2) DEFAULT 0.00,
    desconto_aplicado DECIMAL(5,2) DEFAULT 0.00,
    forma_pagamento ENUM('Dinheiro', 'Cartao Debito', 'Cartao Credito', 'PIX', 'Parcelado') NULL,
    CONSTRAINT fk_ordem_cliente FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
    CONSTRAINT fk_ordem_veiculo FOREIGN KEY (id_veiculo) REFERENCES veiculos(id_veiculo),
    CONSTRAINT fk_ordem_mecanico FOREIGN KEY (id_mecanico) REFERENCES mecanicos(id_mecanico)
);

-- Tabela de Serviços da Ordem (Relacionamento N:M)
CREATE TABLE ordem_servicos (
    id_ordem INT,
    id_servico INT,
    quantidade INT DEFAULT 1,
    preco_servico DECIMAL(8,2) NOT NULL,
    observacoes TEXT,
    PRIMARY KEY (id_ordem, id_servico),
    CONSTRAINT fk_ordem_servicos_ordem FOREIGN KEY (id_ordem) REFERENCES ordens_servico(id_ordem),
    CONSTRAINT fk_ordem_servicos_servico FOREIGN KEY (id_servico) REFERENCES servicos(id_servico)
);

-- Tabela de Peças da Ordem (Relacionamento N:M)
CREATE TABLE ordem_pecas (
    id_ordem INT,
    id_peca INT,
    quantidade INT NOT NULL,
    preco_peca DECIMAL(8,2) NOT NULL,
    PRIMARY KEY (id_ordem, id_peca),
    CONSTRAINT fk_ordem_pecas_ordem FOREIGN KEY (id_ordem) REFERENCES ordens_servico(id_ordem),
    CONSTRAINT fk_ordem_pecas_peca FOREIGN KEY (id_peca) REFERENCES pecas(id_peca)
);

-- =====================================================
-- INSERÇÃO DE DADOS PARA TESTE (DML)
-- =====================================================

-- Inserir Clientes
INSERT INTO clientes (nome, sobrenome, cpf, telefone, email, endereco, data_cadastro) VALUES
('João', 'Silva', '12345678901', '11987654321', 'joao.silva@email.com', 'Rua das Flores, 123', '2024-01-15'),
('Maria', 'Santos', '98765432109', '11876543210', 'maria.santos@email.com', 'Av. Paulista, 456', '2024-02-20'),
('Pedro', 'Oliveira', '45678912345', '11765432109', 'pedro.oliveira@email.com', 'Rua da Paz, 789', '2024-03-10'),
('Ana', 'Costa', '78912345678', '11654321098', 'ana.costa@email.com', 'Alameda Santos, 321', '2024-04-05'),
('Carlos', 'Ferreira', '32165498712', '11543210987', 'carlos.ferreira@email.com', 'Rua Augusta, 654', '2024-05-12');

-- Inserir Veículos
INSERT INTO veiculos (id_cliente, marca, modelo, ano, placa, cor, km_atual, combustivel) VALUES
(1, 'Toyota', 'Corolla', 2020, 'ABC1234', 'Prata', 45000, 'Flex'),
(2, 'Honda', 'Civic', 2019, 'DEF5678', 'Preto', 52000, 'Flex'),
(3, 'Volkswagen', 'Gol', 2018, 'GHI9012', 'Branco', 78000, 'Flex'),
(4, 'Ford', 'EcoSport', 2021, 'JKL3456', 'Azul', 23000, 'Flex'),
(5, 'Chevrolet', 'Onix', 2022, 'MNO7890', 'Vermelho', 15000, 'Flex'),
(1, 'Fiat', 'Uno', 2015, 'PQR1357', 'Branco', 95000, 'Flex');

-- Inserir Mecânicos
INSERT INTO mecanicos (nome, sobrenome, cpf, telefone, especialidade, salario, data_contratacao) VALUES
('Roberto', 'Almeida', '11122233344', '11111222333', 'Motor', 3500.00, '2020-01-15'),
('José', 'Pereira', '22233344455', '11222333444', 'Suspensão', 3200.00, '2021-03-20'),
('Marcos', 'Lima', '33344455566', '11333444555', 'Freios', 3000.00, '2022-05-10'),
('Antonio', 'Souza', '44455566677', '11444555666', 'Elétrica', 3800.00, '2019-08-30'),
('Fernando', 'Rodrigues', '55566677788', '11555666777', 'Geral', 3300.00, '2023-02-15');

-- Inserir Serviços
INSERT INTO servicos (nome_servico, descricao, categoria, tempo_estimado, preco_base) VALUES
('Troca de Óleo', 'Troca de óleo do motor e filtro', 'Preventiva', 60, 80.00),
('Alinhamento', 'Alinhamento de direção', 'Preventiva', 90, 120.00),
('Balanceamento', 'Balanceamento das rodas', 'Preventiva', 45, 80.00),
('Troca de Pastilhas de Freio', 'Substituição das pastilhas de freio', 'Preventiva', 120, 200.00),
('Revisão Completa', 'Revisão geral do veículo', 'Revisao', 240, 350.00),
('Reparo Motor', 'Reparo no motor do veículo', 'Corretiva', 480, 800.00),
('Troca de Bateria', 'Substituição da bateria', 'Corretiva', 30, 150.00),
('Diagnóstico Elétrico', 'Diagnóstico do sistema elétrico', 'Corretiva', 120, 100.00);

-- Inserir Peças
INSERT INTO pecas (nome_peca, codigo_peca, categoria, preco_unitario, estoque_atual, estoque_minimo, fornecedor) VALUES
('Óleo Motor 5W30', 'OL001', 'Lubrificantes', 25.00, 50, 10, 'Petrobrás'),
('Filtro de Óleo', 'FT001', 'Filtros', 15.00, 30, 5, 'Mann Filter'),
('Pastilha de Freio Diant.', 'PF001', 'Freios', 120.00, 20, 4, 'Bosch'),
('Pastilha de Freio Tras.', 'PF002', 'Freios', 100.00, 18, 4, 'Bosch'),
('Bateria 60Ah', 'BT001', 'Elétrica', 280.00, 15, 3, 'Moura'),
('Vela de Ignição', 'VL001', 'Ignição', 35.00, 40, 8, 'NGK'),
('Correia Dentada', 'CR001', 'Motor', 85.00, 12, 2, 'Continental'),
('Amortecedor Diant.', 'AM001', 'Suspensão', 180.00, 8, 2, 'Monroe');

-- Inserir Ordens de Serviço
INSERT INTO ordens_servico (id_cliente, id_veiculo, id_mecanico, data_entrada, data_saida, status_ordem, descricao_problema, km_veiculo, valor_total, forma_pagamento) VALUES
(1, 1, 1, '2024-07-01 08:30:00', '2024-07-01 10:30:00', 'Concluida', 'Troca de óleo e filtro', 45000, 95.00, 'PIX'),
(2, 2, 2, '2024-07-02 09:00:00', '2024-07-02 11:30:00', 'Concluida', 'Alinhamento e balanceamento', 52000, 200.00, 'Cartao Credito'),
(3, 3, 3, '2024-07-03 14:00:00', '2024-07-03 16:00:00', 'Concluida', 'Troca de pastilhas de freio', 78000, 320.00, 'Dinheiro'),
(4, 4, 1, '2024-07-05 08:00:00', '2024-07-05 16:00:00', 'Concluida', 'Revisão completa', 23000, 450.00, 'Cartao Debito'),
(5, 5, 4, '2024-07-08 10:00:00', NULL, 'Em andamento', 'Problema elétrico - não liga', 15000, 0.00, NULL),
(1, 6, 5, '2024-07-10 07:30:00', NULL, 'Aguardando peças', 'Motor fazendo ruído', 95000, 0.00, NULL),
(2, 2, 2, '2024-07-12 13:00:00', NULL, 'Aberta', 'Barulho na suspensão', 53500, 0.00, NULL);

-- Inserir Serviços das Ordens
INSERT INTO ordem_servicos (id_ordem, id_servico, quantidade, preco_servico, observacoes) VALUES
(1, 1, 1, 80.00, 'Óleo sintético usado'),
(2, 2, 1, 120.00, 'Alinhamento OK'),
(2, 3, 1, 80.00, 'Balanceamento realizado'),
(3, 4, 1, 200.00, 'Pastilhas dianteiras e traseiras'),
(4, 5, 1, 350.00, 'Revisão dos 20.000 km'),
(5, 8, 1, 100.00, 'Diagnóstico em andamento'),
(6, 6, 1, 800.00, 'Aguardando peças do motor');

-- Inserir Peças das Ordens
INSERT INTO ordem_pecas (id_ordem, id_peca, quantidade, preco_peca) VALUES
(1, 1, 1, 25.00), -- Óleo
(1, 2, 1, 15.00), -- Filtro óleo
(3, 3, 1, 120.00), -- Pastilha diant.
(3, 4, 1, 100.00), -- Pastilha tras.
(4, 1, 1, 25.00), -- Óleo (revisão)
(4, 2, 1, 15.00), -- Filtro (revisão)
(4, 6, 4, 35.00); -- Velas (revisão)

-- =====================================================
-- QUERIES COMPLEXAS
-- =====================================================

-- 1. RECUPERAÇÕES SIMPLES COM SELECT
-- Pergunta: Quais são todos os clientes cadastrados?
SELECT * FROM clientes;

-- Pergunta: Quais mecânicos estão ativos?
SELECT nome, sobrenome, especialidade, salario 
FROM mecanicos 
WHERE status_funcionario = 'Ativo';

-- 2. FILTROS COM WHERE
-- Pergunta: Quais veículos são da marca Toyota ou Honda?
SELECT v.marca, v.modelo, v.ano, v.placa, c.nome as proprietario
FROM veiculos v
JOIN clientes c ON v.id_cliente = c.id_cliente
WHERE v.marca IN ('Toyota', 'Honda');

-- Pergunta: Quais ordens de serviço foram concluídas em julho de 2024?
SELECT os.id_ordem, c.nome, v.marca, v.modelo, os.data_entrada, os.valor_total
FROM ordens_servico os
JOIN clientes c ON os.id_cliente = c.id_cliente
JOIN veiculos v ON os.id_veiculo = v.id_veiculo
WHERE os.status_ordem = 'Concluida' 
AND MONTH(os.data_entrada) = 7 
AND YEAR(os.data_entrada) = 2024;

-- 3. EXPRESSÕES PARA GERAR ATRIBUTOS DERIVADOS
-- Pergunta: Qual o valor total com desconto de cada ordem de serviço?
SELECT 
    id_ordem,
    valor_total as valor_original,
    desconto_aplicado as desconto_percentual,
    ROUND(valor_total * (1 - desconto_aplicado/100), 2) as valor_final,
    ROUND(valor_total * desconto_aplicado/100, 2) as valor_desconto
FROM ordens_servico
WHERE valor_total > 0;

-- Pergunta: Há quanto tempo cada mecânico trabalha na oficina?
SELECT 
    nome,
    sobrenome,
    data_contratacao,
    DATEDIFF(CURDATE(), data_contratacao) as dias_trabalhados,
    ROUND(DATEDIFF(CURDATE(), data_contratacao)/365, 1) as anos_experiencia,
    CONCAT('R$ ', FORMAT(salario, 2)) as salario_formatado
FROM mecanicos
WHERE status_funcionario = 'Ativo';

-- 4. ORDENAÇÕES COM ORDER BY
-- Pergunta: Quais são os serviços ordenados por preço (do mais caro para o mais barato)?
SELECT nome_servico, categoria, preco_base, tempo_estimado
FROM servicos
ORDER BY preco_base DESC, tempo_estimado ASC;

-- Pergunta: Quais clientes têm mais veículos cadastrados?
SELECT 
    c.nome, 
    c.sobrenome, 
    COUNT(v.id_veiculo) as total_veiculos,
    c.data_cadastro
FROM clientes c
LEFT JOIN veiculos v ON c.id_cliente = v.id_cliente
GROUP BY c.id_cliente, c.nome, c.sobrenome, c.data_cadastro
ORDER BY total_veiculos DESC, c.data_cadastro ASC;

-- 5. CONDIÇÕES DE FILTRO AOS GRUPOS - HAVING
-- Pergunta: Quais mecânicos atenderam mais de 1 ordem de serviço?
SELECT 
    m.nome, 
    m.sobrenome, 
    m.especialidade,
    COUNT(os.id_ordem) as total_ordens,
    AVG(os.valor_total) as ticket_medio
FROM mecanicos m
JOIN ordens_servico os ON m.id_mecanico = os.id_mecanico
GROUP BY m.id_mecanico, m.nome, m.sobrenome, m.especialidade
HAVING COUNT(os.id_ordem) > 1
ORDER BY total_ordens DESC;

-- Pergunta: Quais peças têm estoque abaixo do mínimo?
SELECT 
    categoria,
    COUNT(*) as pecas_em_falta,
    AVG(estoque_atual) as media_estoque_atual,
    AVG(estoque_minimo) as media_estoque_minimo
FROM pecas
WHERE estoque_atual < estoque_minimo
GROUP BY categoria
HAVING COUNT(*) > 0
ORDER BY pecas_em_falta DESC;

-- 6. JUNÇÕES ENTRE TABELAS (JOINS COMPLEXOS)
-- Pergunta: Relatório completo de ordens de serviço com detalhes do cliente, veículo e mecânico
SELECT 
    os.id_ordem,
    CONCAT(c.nome, ' ', c.sobrenome) as cliente,
    c.telefone as tel_cliente,
    CONCAT(v.marca, ' ', v.modelo, ' ', v.ano) as veiculo,
    v.placa,
    CONCAT(m.nome, ' ', m.sobrenome) as mecanico,
    m.especialidade,
    os.data_entrada,
    os.data_saida,
    os.status_ordem,
    os.valor_total,
    CASE 
        WHEN os.data_saida IS NOT NULL 
        THEN TIMESTAMPDIFF(HOUR, os.data_entrada, os.data_saida)
        ELSE TIMESTAMPDIFF(HOUR, os.data_entrada, NOW())
    END as horas_servico
FROM ordens_servico os
JOIN clientes c ON os.id_cliente = c.id_cliente
JOIN veiculos v ON os.id_veiculo = v.id_veiculo
JOIN mecanicos m ON os.id_mecanico = m.id_mecanico
ORDER BY os.data_entrada DESC;

-- Pergunta: Quais serviços foram mais realizados e qual o faturamento de cada um?
SELECT 
    s.nome_servico,
    s.categoria,
    COUNT(osv.id_ordem) as vezes_realizado,
    SUM(osv.preco_servico) as faturamento_total,
    AVG(osv.preco_servico) as preco_medio,
    s.preco_base as preco_tabela
FROM servicos s
LEFT JOIN ordem_servicos osv ON s.id_servico = osv.id_servico
GROUP BY s.id_servico, s.nome_servico, s.categoria, s.preco_base
HAVING COUNT(osv.id_ordem) > 0
ORDER BY faturamento_total DESC;

-- Pergunta: Análise de consumo de peças por ordem de serviço
SELECT 
    os.id_ordem,
    CONCAT(c.nome, ' ', c.sobrenome) as cliente,
    CONCAT(v.marca, ' ', v.modelo) as veiculo,
    COUNT(op.id_peca) as total_pecas_usadas,
    SUM(op.quantidade * op.preco_peca) as valor_pecas,
    os.valor_total,
    ROUND((SUM(op.quantidade * op.preco_peca) / os.valor_total) * 100, 2) as percentual_pecas
FROM ordens_servico os
JOIN clientes c ON os.id_cliente = c.id_cliente
JOIN veiculos v ON os.id_veiculo = v.id_veiculo
LEFT JOIN ordem_pecas op ON os.id_ordem = op.id_ordem
WHERE os.valor_total > 0
GROUP BY os.id_ordem, c.nome, c.sobrenome, v.marca, v.modelo, os.valor_total
HAVING COUNT(op.id_peca) > 0
ORDER BY percentual_pecas DESC;

-- Query complexa final: Dashboard gerencial
-- Pergunta: Qual é o resumo geral de performance da oficina?
SELECT 
    'Resumo Geral da Oficina' as relatorio,
    COUNT(DISTINCT c.id_cliente) as total_clientes,
    COUNT(DISTINCT v.id_veiculo) as total_veiculos,
    COUNT(DISTINCT m.id_mecanico) as total_mecanicos,
    COUNT(os.id_ordem) as total_ordens,
    COUNT(CASE WHEN os.status_ordem = 'Concluida' THEN 1 END) as ordens_concluidas,
    ROUND(COUNT(CASE WHEN os.status_ordem = 'Concluida' THEN 1 END) / COUNT(os.id_ordem) * 100, 2) as taxa_conclusao,
    SUM(CASE WHEN os.status_ordem = 'Concluida' THEN os.valor_total ELSE 0 END) as faturamento_total,
    AVG(CASE WHEN os.status_ordem = 'Concluida' THEN os.valor_total END) as ticket_medio
FROM clientes c
LEFT JOIN veiculos v ON c.id_cliente = v.id_cliente
LEFT JOIN ordens_servico os ON v.id_veiculo = os.id_veiculo
LEFT JOIN mecanicos m ON os.id_mecanico = m.id_mecanico;