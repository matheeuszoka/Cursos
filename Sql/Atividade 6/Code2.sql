DELIMITER //

CREATE PROCEDURE ProcessarPedidoCompleto(
    IN p_cliente_id INT,
    IN p_produto_id INT,
    IN p_quantidade INT
)
BEGIN
    DECLARE v_preco DECIMAL(10,2);
    DECLARE v_estoque INT;
    DECLARE v_saldo_cliente DECIMAL(10,2);
    DECLARE v_total DECIMAL(10,2);
    DECLARE v_pedido_id INT;
    DECLARE erro_flag INT DEFAULT 0;
    
    -- Handler para capturar erros
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION 
    BEGIN
        SET erro_flag = 1;
    END;
    
    START TRANSACTION;
    
    -- SAVEPOINT para rollback parcial se necessário
    SAVEPOINT sp_inicio;
    
    -- Verificar se cliente existe e está ativo
    SELECT saldo INTO v_saldo_cliente 
    FROM clientes 
    WHERE id = p_cliente_id AND status = 'ativo';
    
    IF v_saldo_cliente IS NULL THEN
        ROLLBACK TO SAVEPOINT sp_inicio;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cliente não encontrado ou inativo';
    END IF;
    
    -- Verificar produto e estoque
    SELECT preco, estoque INTO v_preco, v_estoque
    FROM produtos 
    WHERE id = p_produto_id AND status = 'disponivel';
    
    IF v_preco IS NULL THEN
        ROLLBACK TO SAVEPOINT sp_inicio;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Produto não encontrado ou indisponível';
    END IF;
    
    IF v_estoque < p_quantidade THEN
        ROLLBACK TO SAVEPOINT sp_inicio;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Estoque insuficiente';
    END IF;
    
    -- Calcular total
    SET v_total = v_preco * p_quantidade;
    
    -- Verificar saldo suficiente
    IF v_saldo_cliente < v_total THEN
        ROLLBACK TO SAVEPOINT sp_inicio;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Saldo insuficiente';
    END IF;
    
    -- Se chegou até aqui, pode processar o pedido
    SAVEPOINT sp_criar_pedido;
    
    -- Criar pedido
    INSERT INTO pedidos (cliente_id, total, status)
    VALUES (p_cliente_id, v_total, 'confirmado');
    
    IF erro_flag = 1 THEN
        ROLLBACK TO SAVEPOINT sp_criar_pedido;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro ao criar pedido';
    END IF;
    
    SET v_pedido_id = LAST_INSERT_ID();
    
    -- Adicionar item ao pedido
    INSERT INTO itens_pedido (pedido_id, produto_id, quantidade, preco_unitario, subtotal)
    VALUES (v_pedido_id, p_produto_id, p_quantidade, v_preco, v_total);
    
    IF erro_flag = 1 THEN
        ROLLBACK TO SAVEPOINT sp_criar_pedido;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro ao adicionar item ao pedido';
    END IF;
    
    -- Atualizar estoque
    UPDATE produtos 
    SET estoque = estoque - p_quantidade 
    WHERE id = p_produto_id;
    
    IF erro_flag = 1 THEN
        ROLLBACK TO SAVEPOINT sp_criar_pedido;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro ao atualizar estoque';
    END IF;
    
    -- Debitar saldo do cliente
    UPDATE clientes 
    SET saldo = saldo - v_total 
    WHERE id = p_cliente_id;
    
    IF erro_flag = 1 THEN
        ROLLBACK TO SAVEPOINT sp_criar_pedido;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro ao debitar saldo do cliente';
    END IF;
    
    -- Se tudo deu certo, confirmar transação
    COMMIT;
    
    -- Retornar sucesso
    SELECT 'Pedido processado com sucesso!' AS resultado, v_pedido_id AS pedido_id;
    
END //

DELIMITER ;

-- Exemplo de uso da procedure
CALL ProcessarPedidoCompleto(2, 3, 1);

-- Exemplo que causará erro (estoque insuficiente)
-- CALL ProcessarPedidoCompleto(1, 1, 20);

-- ========================================
-- PROCEDURE ADICIONAL COM ROLLBACK PARCIAL
-- ========================================

DELIMITER //

CREATE PROCEDURE AtualizarEstoqueMultiplo(
    IN p_produtos JSON
)
BEGIN
    DECLARE v_produto_id INT;
    DECLARE v_quantidade INT;
    DECLARE v_estoque_atual INT;
    DECLARE v_contador INT DEFAULT 0;
    DECLARE v_total_produtos INT;
    DECLARE erro_flag INT DEFAULT 0;
    
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION 
    BEGIN
        SET erro_flag = 1;
    END;
    
    START TRANSACTION;
    
    -- Contar quantos produtos serão atualizados
    SET v_total_produtos = JSON_LENGTH(p_produtos);
    
    SAVEPOINT sp_inicio_atualizacao;
    
    -- Loop pelos produtos
    WHILE v_contador < v_total_produtos DO
        
        SAVEPOINT sp_produto_atual;
        
        -- Extrair dados do JSON
        SET v_produto_id = JSON_UNQUOTE(JSON_EXTRACT(p_produtos, CONCAT('$[', v_contador, '].id')));
        SET v_quantidade = JSON_UNQUOTE(JSON_EXTRACT(p_produtos, CONCAT('$[', v_contador, '].quantidade')));
        
        -- Verificar estoque atual
        SELECT estoque INTO v_estoque_atual 
        FROM produtos 
        WHERE id = v_produto_id;
        
        IF v_estoque_atual IS NULL THEN
            -- Rollback apenas este produto e continuar
            ROLLBACK TO SAVEPOINT sp_produto_atual;
            INSERT INTO log_erros (descricao, data_erro) 
            VALUES (CONCAT('Produto ID ', v_produto_id, ' não encontrado'), NOW());
        ELSEIF v_estoque_atual < v_quantidade THEN
            -- Rollback apenas este produto e continuar
            ROLLBACK TO SAVEPOINT sp_produto_atual;
            INSERT INTO log_erros (descricao, data_erro) 
            VALUES (CONCAT('Estoque insuficiente para produto ID ', v_produto_id), NOW());
        ELSE
            -- Atualizar estoque
            UPDATE produtos 
            SET estoque = estoque - v_quantidade 
            WHERE id = v_produto_id;
            
            IF erro_flag = 1 THEN
                ROLLBACK TO SAVEPOINT sp_produto_atual;
                INSERT INTO log_erros (descricao, data_erro) 
                VALUES (CONCAT('Erro ao atualizar produto ID ', v_produto_id), NOW());
                SET erro_flag = 0; -- Reset flag para continuar
            END IF;
        END IF;
        
        SET v_contador = v_contador + 1;
    END WHILE;
    
    COMMIT;
    
    SELECT 'Atualização de estoque concluída!' AS resultado;
    
END //

DELIMITER ;

-- Criar tabela de log para a procedure acima
CREATE TABLE IF NOT EXISTS log_erros (
    id INT PRIMARY KEY AUTO_INCREMENT,
    descricao TEXT,
    data_erro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ========================================
-- CONSULTAS PARA VERIFICAR RESULTADOS
-- ========================================

-- Verificar pedidos criados
SELECT p.*, c.nome as cliente_nome 
FROM pedidos p 
JOIN clientes c ON p.cliente_id = c.id;

-- Verificar itens dos pedidos
SELECT ip.*, pr.nome as produto_nome, pe.id as pedido_numero
FROM itens_pedido ip
JOIN produtos pr ON ip.produto_id = pr.id
JOIN pedidos pe ON ip.pedido_id = pe.id;

-- Verificar estoque atual
SELECT id, nome, estoque, preco FROM produtos;

-- Verificar saldo dos clientes
SELECT id, nome, saldo FROM clientes;