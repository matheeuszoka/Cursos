CREATE DATABASE IF NOT EXISTS ecommerce;
USE ecommerce;

-- ========================================
-- TABELA CLIENTS - MODIFICADA
-- ========================================
CREATE TABLE clients(
    idClient INT AUTO_INCREMENT PRIMARY KEY,
    clientType ENUM('PF', 'PJ') NOT NULL,
    Fname VARCHAR(10),
    Minit CHAR(3),
    Lname VARCHAR(20),
    CPF CHAR(11),
	CompanyName VARCHAR(50),
    CNPJ CHAR(14),
	Address VARCHAR(30),
    CONSTRAINT unique_cpf_client UNIQUE(CPF),
    CONSTRAINT unique_cnpj_client UNIQUE(CNPJ)
    
);
ALTER TABLE clients AUTO_INCREMENT=1;

CREATE TABLE product(
    idProduct INT AUTO_INCREMENT PRIMARY KEY,
    Pname VARCHAR(10) NOT NULL,
    classification_kids BOOL DEFAULT FALSE,
    category ENUM('Eletronico','Vestimenta', 'Brinquedos','Alimentos','Moveis') NOT NULL,
    avalicao FLOAT DEFAULT 0,
    size VARCHAR(10)
);


CREATE TABLE payments(
    idPayment INT AUTO_INCREMENT PRIMARY KEY,
    idClient INT NOT NULL,
    typePayment ENUM('Boleto','Cartão Crédito','Cartão Débito','PIX','Transferência') NOT NULL,
	cardNumber VARCHAR(20), -- últimos 4 dígitos
    cardLimit FLOAT,
    pixKey VARCHAR(100),
    isDefault BOOL DEFAULT FALSE,
    isActive BOOL DEFAULT TRUE,
    CONSTRAINT fk_payments_client FOREIGN KEY(idClient) REFERENCES clients(idClient)
);

CREATE TABLE orders(
    idOrder INT AUTO_INCREMENT PRIMARY KEY,
    idOrderClient INT,
    orderStatus ENUM('Cancelado', 'Confirmado','Em processamento') DEFAULT "Em processamento",
    orderDescription VARCHAR(255),
    sendValue FLOAT DEFAULT 10,
    paymentCash BOOL DEFAULT FALSE,
    orderDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_orders_client FOREIGN KEY(idOrderClient) REFERENCES clients(idClient)
);

CREATE TABLE delivery(
    idDelivery INT AUTO_INCREMENT PRIMARY KEY,
    idOrder INT NOT NULL,
    trackingCode VARCHAR(50) UNIQUE NOT NULL,
    deliveryStatus ENUM('Preparando','Enviado','Em trânsito','Entregue','Devolvido') DEFAULT 'Preparando',
    shippingCompany VARCHAR(50),
    estimatedDate DATE,
    deliveryDate DATE,
    deliveryAddress VARCHAR(255),
    
    CONSTRAINT fk_delivery_order FOREIGN KEY(idOrder) REFERENCES orders(idOrder),
    CONSTRAINT unique_order_delivery UNIQUE(idOrder)
);

CREATE TABLE productStorage(
    idProdStorage INT AUTO_INCREMENT PRIMARY KEY,
    storageLocation VARCHAR(255),
    quantity INT DEFAULT 0
);

CREATE TABLE supplier(
    idSupplier INT AUTO_INCREMENT PRIMARY KEY,
    SocialName VARCHAR(255) NOT NULL,
    CNPJ CHAR(15) NOT NULL,
    contact CHAR(11) DEFAULT 0,
    CONSTRAINT unique_supplier UNIQUE(CNPJ)
);

CREATE TABLE seller(
    idSeller INT AUTO_INCREMENT PRIMARY KEY,
    SocialName VARCHAR(255) NOT NULL,
    AbstName VARCHAR(255), 
    CNPJ CHAR(15),
    CPF CHAR(9),
    location VARCHAR(255),
    contact CHAR(11) DEFAULT 0,
    CONSTRAINT unique_cnpj_seller UNIQUE(CNPJ),
    CONSTRAINT unique_cpf_seller UNIQUE(CPF)
);

CREATE TABLE productSeller(
    idPseller INT,
    idPproduct INT,
    prodQuantity INT DEFAULT 1,
    PRIMARY KEY(idPseller, idPproduct),
    CONSTRAINT fk_product_seller FOREIGN KEY (idPseller) REFERENCES seller(idSeller),
    CONSTRAINT fk_product_product FOREIGN KEY(idPproduct) REFERENCES product(idProduct)
);

CREATE TABLE productOrder(
    idPOproduct INT,
    idPOorder INT,
    poQuantity INT DEFAULT 1,
    poStatus ENUM('Disponivel', 'Sem estoque') DEFAULT 'Disponivel',
    PRIMARY KEY (idPOproduct, idPOorder),
    CONSTRAINT fk_productorder_seller FOREIGN KEY (idPOproduct) REFERENCES product(idProduct),
    CONSTRAINT fk_productorder_product FOREIGN KEY (idPOorder) REFERENCES orders(idOrder)
);

CREATE TABLE storageLocation(
    idLproduct INT,
    idLstorage INT, 
    location VARCHAR(255) NOT NULL,
    PRIMARY KEY (idLproduct, idLstorage),
    CONSTRAINT fk_storage_location_product FOREIGN KEY(idLproduct) REFERENCES product(idProduct),
    CONSTRAINT fk_storage_location_storage FOREIGN KEY (idLstorage) REFERENCES productStorage(idProdStorage)
);

CREATE TABLE productSupplier(
    idPsSupplier INT,
    idPsProduct INT,
    quantity INT NOT NULL,
    PRIMARY KEY (idPsSupplier, idPsProduct),
    CONSTRAINT fk_product_supplier_seller FOREIGN KEY (idPsSupplier) REFERENCES supplier(idSupplier),
    CONSTRAINT fk_productsupplier_product FOREIGN KEY (idPsProduct) REFERENCES product(idProduct)
);

-- ========================================
-- INSERÇÃO DE DADOS 
-- ========================================

-- Clientes Pessoa Física
INSERT INTO clients (clientType, Fname, Minit, Lname, CPF, Address) VALUES
('PF', 'João', 'S', 'Santos', '12345678901', 'Rua A, 123, São Paulo'),
('PF', 'Maria', 'O', 'Costa', '23456789012', 'Rua B, 456, Rio de Janeiro'),
('PF', 'Pedro', 'L', 'Silva', '34567890123', 'Rua C, 789, Belo Horizonte');

-- Clientes Pessoa Jurídica
INSERT INTO clients (clientType, CompanyName, CNPJ, Address) VALUES
('PJ', 'Tech Solutions Ltda', '12345678000195', 'Av. Paulista, 1000, São Paulo'),
('PJ', 'Comércio Geral S/A', '23456789000186', 'Rua do Comércio, 500, Curitiba');

-- Produtos
INSERT INTO product (Pname, classification_kids, category, avalicao, size) VALUES
('Smartphone', FALSE, 'Eletronico', 4.5, 'M'),
('Camiseta', FALSE, 'Vestimenta', 4.0, 'G'),
('Boneca', TRUE, 'Brinquedos', 4.8, 'P'),
('Chocolate', FALSE, 'Alimentos', 4.2, 'P'),
('Mesa', FALSE, 'Moveis', 4.1, 'G');

-- Formas de pagamento
INSERT INTO payments (idClient, typePayment, cardNumber, cardLimit, isDefault) VALUES
(1, 'Cartão Crédito', '**** 1234', 5000.00, TRUE),
(1, 'PIX', NULL, NULL, FALSE),
(2, 'Cartão Débito', '**** 5678', 2000.00, TRUE),
(3, 'Boleto', NULL, NULL, TRUE),
(4, 'Cartão Crédito', '**** 9012', 10000.00, TRUE),
(4, 'PIX', NULL, NULL, FALSE),
(5, 'Transferência', NULL, NULL, TRUE);

-- Pedidos
INSERT INTO orders (idOrderClient, orderStatus, orderDescription, sendValue) VALUES
(1, 'Confirmado', 'Compra de smartphone', 15.50),
(2, 'Em processamento', 'Compra de roupas', 12.00),
(3, 'Confirmado', 'Compra de brinquedos', 8.90),
(4, 'Confirmado', 'Compra para escritório', 25.00),
(5, 'Em processamento', 'Compra de móveis', 50.00);

-- Entregas
INSERT INTO delivery (idOrder, trackingCode, deliveryStatus, shippingCompany, estimatedDate, deliveryAddress) VALUES
(1, 'BR123456789', 'Enviado', 'Correios', '2024-01-15', 'Rua A, 123, São Paulo'),
(3, 'BR987654321', 'Em trânsito', 'Sedex', '2024-01-12', 'Rua C, 789, Belo Horizonte'),
(4, 'BR456789123', 'Entregue', 'Jadlog', '2024-01-10', 'Av. Paulista, 1000, São Paulo');

-- Itens dos pedidos
INSERT INTO productOrder (idPOproduct, idPOorder, poQuantity, poStatus) VALUES
(1, 1, 1, 'Disponivel'),
(2, 2, 2, 'Disponivel'),
(3, 3, 1, 'Disponivel'),
(4, 4, 5, 'Disponivel'),
(5, 5, 1, 'Disponivel');

-- ========================================
-- QUERIES 
-- ========================================

-- 1. RECUPERAÇÕES SIMPLES COM SELECT
-- Pergunta: Quais são todos os clientes cadastrados?
SELECT * FROM clients;

-- Pergunta: Quais produtos estão disponíveis na categoria Eletrônicos?
SELECT * FROM product WHERE category = 'Eletronico';

-- 2. FILTROS COM WHERE
-- Pergunta: Quais são os clientes pessoa física com CPF específico?
SELECT Fname, Lname, CPF FROM clients WHERE clientType = 'PF' AND CPF IS NOT NULL;

-- Pergunta: Quais pedidos estão confirmados?
SELECT * FROM orders WHERE orderStatus = 'Confirmado';

-- 3. EXPRESSÕES PARA ATRIBUTOS DERIVADOS
-- Pergunta: Qual o nome completo dos clientes PF e valor total com frete dos pedidos?
SELECT 
    CONCAT(Fname, ' ', Lname) AS NomeCompleto,
    CPF,
    'Cliente Pessoa Física' AS TipoCliente
FROM clients WHERE clientType = 'PF'
UNION
SELECT 
    CompanyName AS NomeCompleto,
    CNPJ,
    'Cliente Pessoa Jurídica' AS TipoCliente  
FROM clients WHERE clientType = 'PJ';

-- Pergunta: Qual o valor total com frete de cada pedido?
SELECT 
    idOrder,
    orderDescription,
    sendValue AS ValorFrete,
    (sendValue * 1.1) AS ValorComTaxa,
    CASE 
        WHEN sendValue > 20 THEN 'Frete Caro'
        WHEN sendValue > 10 THEN 'Frete Médio'
        ELSE 'Frete Barato'
    END AS CategoriaFrete
FROM orders;

-- 4. ORDENAÇÃO COM ORDER BY
-- Pergunta: Quais produtos têm melhor avaliação?
SELECT Pname, category, avalicao 
FROM product 
WHERE avalicao > 0 
ORDER BY avalicao DESC, Pname ASC;

-- Pergunta: Quais são os pedidos mais recentes?
SELECT idOrder, idOrderClient, orderStatus, orderDate
FROM orders 
ORDER BY orderDate DESC, idOrder DESC;

-- 5. CONDIÇÕES DE FILTROS AOS GRUPOS - HAVING
-- Pergunta: Quais clientes têm mais de uma forma de pagamento?
SELECT 
    c.idClient,
    CASE 
        WHEN c.clientType = 'PF' THEN CONCAT(c.Fname, ' ', c.Lname)
        ELSE c.CompanyName
    END AS NomeCliente,
    COUNT(p.idPayment) as QtdFormasPagamento
FROM clients c
INNER JOIN payments p ON c.idClient = p.idClient
GROUP BY c.idClient
HAVING COUNT(p.idPayment) > 1
ORDER BY QtdFormasPagamento DESC;

-- Pergunta: Quais categorias de produtos têm avaliação média superior a 4.0?
SELECT 
    category,
    COUNT(*) as QtdProdutos,
    AVG(avalicao) as AvaliacaoMedia,
    MAX(avalicao) as MelhorAvaliacao
FROM product 
WHERE avalicao > 0
GROUP BY category
HAVING AVG(avalicao) > 4.0
ORDER BY AvaliacaoMedia DESC;

-- 6. JUNÇÕES ENTRE TABELAS
-- Pergunta: Quais são os detalhes completos dos pedidos com informações do cliente?
SELECT 
    o.idOrder,
    CASE 
        WHEN c.clientType = 'PF' THEN CONCAT(c.Fname, ' ', c.Lname)
        ELSE c.CompanyName
    END AS NomeCliente,
    c.clientType,
    o.orderStatus,
    o.orderDescription,
    o.sendValue,
    o.orderDate
FROM orders o
INNER JOIN clients c ON o.idOrderClient = c.idClient
ORDER BY o.orderDate DESC;

-- Pergunta: Quais pedidos têm entrega e qual seu status?
SELECT 
    o.idOrder,
    CASE 
        WHEN c.clientType = 'PF' THEN CONCAT(c.Fname, ' ', c.Lname)
        ELSE c.CompanyName
    END AS Cliente,
    o.orderStatus as StatusPedido,
    d.trackingCode as CodigoRastreio,
    d.deliveryStatus as StatusEntrega,
    d.shippingCompany as Transportadora,
    d.estimatedDate as DataEstimada
FROM orders o
INNER JOIN clients c ON o.idOrderClient = c.idClient
INNER JOIN delivery d ON o.idOrder = d.idOrder
ORDER BY d.estimatedDate;

-- Pergunta: Quais são os produtos mais vendidos com detalhes dos pedidos?
SELECT 
    p.Pname as NomeProduto,
    p.category as Categoria,
    COUNT(po.idPOorder) as QtdVendas,
    SUM(po.poQuantity) as QtdTotalVendida,
    AVG(po.poQuantity) as MediaPorPedido
FROM product p
INNER JOIN productOrder po ON p.idProduct = po.idPOproduct
INNER JOIN orders o ON po.idPOorder = o.idOrder
WHERE o.orderStatus IN ('Confirmado', 'Em processamento')
GROUP BY p.idProduct, p.Pname, p.category
ORDER BY QtdTotalVendida DESC, QtdVendas DESC;

-- Pergunta: Qual o relatório completo de clientes com suas formas de pagamento?
SELECT 
    c.idClient,
    CASE 
        WHEN c.clientType = 'PF' THEN CONCAT(c.Fname, ' ', c.Lname)
        ELSE c.CompanyName
    END AS NomeCliente,
    c.clientType,
    GROUP_CONCAT(
        CONCAT(p.typePayment, 
               CASE WHEN p.isDefault THEN ' (Padrão)' ELSE '' END)
        SEPARATOR ', '
    ) as FormasPagamento,
    COUNT(p.idPayment) as QtdFormasPagamento
FROM clients c
LEFT JOIN payments p ON c.idClient = p.idClient AND p.isActive = TRUE
GROUP BY c.idClient
ORDER BY c.clientType, NomeCliente;

-- CONSULTAS ADICIONAIS PARA DEMONSTRAR COMPLEXIDADE

-- Pergunta: Qual o ranking de clientes por valor total de pedidos?
SELECT 
    c.idClient,
    CASE 
        WHEN c.clientType = 'PF' THEN CONCAT(c.Fname, ' ', c.Lname)
        ELSE c.CompanyName
    END AS Cliente,
    c.clientType,
    COUNT(o.idOrder) as QtdPedidos,
    SUM(o.sendValue) as ValorTotalFrete,
    AVG(o.sendValue) as MediaFrete
FROM clients c
LEFT JOIN orders o ON c.idClient = o.idOrderClient
GROUP BY c.idClient
ORDER BY ValorTotalFrete DESC, QtdPedidos DESC;

-- Pergunta: Quais entregas estão atrasadas?
SELECT 
    d.trackingCode,
    o.idOrder,
    CASE 
        WHEN c.clientType = 'PF' THEN CONCAT(c.Fname, ' ', c.Lname)
        ELSE c.CompanyName
    END AS Cliente,
    d.deliveryStatus,
    d.estimatedDate,
    DATEDIFF(CURDATE(), d.estimatedDate) as DiasAtraso
FROM delivery d
INNER JOIN orders o ON d.idOrder = o.idOrder
INNER JOIN clients c ON o.idOrderClient = c.idClient
WHERE d.estimatedDate < CURDATE() 
  AND d.deliveryStatus NOT IN ('Entregue', 'Devolvido')
ORDER BY DiasAtraso DESC;