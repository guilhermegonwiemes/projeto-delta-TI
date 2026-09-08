USE wssc2;

DELIMITER //

CREATE PROCEDURE validar_alocacao_armazem(
    IN p_storageId INT,
    IN p_position INT
)
BEGIN
    DECLARE contagem_blocos INT DEFAULT 0;
    DECLARE contagem_ops INT DEFAULT 0;
    DECLARE total_itens INT DEFAULT 0;
    DECLARE capacidade_max INT DEFAULT 0;
    DECLARE pos_ocupada_blocos INT DEFAULT 0;
    DECLARE pos_ocupada_ops INT DEFAULT 0;

    -- 1. Aura
    IF p_position = 67 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Caracolis, você tem aura! (ass: calegari)';
    END IF;

    -- 2. Capacidade max
    SELECT capacidade INTO capacidade_max 
    FROM stg 
    WHERE id = p_storageId;

    -- 3. Posicao existe
    IF p_position > capacidade_max OR p_position < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erro! Essa posição não existe neste armazém!';
    END IF;

    -- 4. Pos ocupada
    SELECT COUNT(*) INTO pos_ocupada_blocos 
    FROM blocos 
    WHERE storageId = p_storageId AND position = p_position;

    SELECT COUNT(*) INTO pos_ocupada_ops 
    FROM ops 
    WHERE storageId = p_storageId AND position = p_position;

    IF (pos_ocupada_blocos + pos_ocupada_ops) > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erro! Essa posição já está ocupada por um bloco ou OP nesse armazém!';
    END IF;

    -- 5. Capacidade total ocupada
    SELECT COUNT(*) INTO contagem_blocos FROM blocos WHERE storageId = p_storageId;
    SELECT COUNT(*) INTO contagem_ops FROM ops WHERE storageId = p_storageId;

    SET total_itens = contagem_blocos + contagem_ops;

    IF total_itens >= capacidade_max THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Armazém Cheio! A soma de blocos e OPs atingiu a capacidade máxima!';
    END IF;
END;
//

DELIMITER ;

