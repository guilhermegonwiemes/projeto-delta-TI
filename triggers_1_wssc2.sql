USE wssc2;

DELIMITER //

-- 1. INSERT em blocos
CREATE TRIGGER blocos_before_insert BEFORE INSERT ON blocos
FOR EACH ROW BEGIN
    CALL validar_alocacao_armazem(NEW.storageId, NEW.position);
END; //

-- 2. UPDATE em blocos
CREATE TRIGGER blocos_before_update BEFORE UPDATE ON blocos
FOR EACH ROW BEGIN
    IF OLD.storageId <> NEW.storageId OR OLD.position <> NEW.position THEN
        CALL validar_alocacao_armazem(NEW.storageId, NEW.position);
    END IF;
END; //

-- 3. INSERT em ops
CREATE TRIGGER ops_before_insert BEFORE INSERT ON ops
FOR EACH ROW BEGIN
    CALL validar_alocacao_armazem(NEW.storageId, NEW.position);
END; //

-- 4. UPDATE em ops
CREATE TRIGGER ops_before_update BEFORE UPDATE ON ops
FOR EACH ROW BEGIN
    IF OLD.storageId <> NEW.storageId OR OLD.position <> NEW.position THEN
        CALL validar_alocacao_armazem(NEW.storageId, NEW.position);
    END IF;
END; //

DELIMITER ;