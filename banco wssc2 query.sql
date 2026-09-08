CREATE DATABASE IF NOT EXISTS wssc2;

USE wssc2;

CREATE TABLE stg(
	id INT AUTO_INCREMENT PRIMARY KEY,
    capacidade INT,
    nome VARCHAR(20)
);

CREATE TABLE buffers(
	id INT AUTO_INCREMENT PRIMARY KEY,
    capacidade INT,
    nome VARCHAR(20)
);

CREATE TABLE cores_lams(
	id INT PRIMARY KEY,
    nome VARCHAR(20)
);

CREATE TABLE lams (
    id INT AUTO_INCREMENT PRIMARY KEY,
    color INT,
    bufferId INT,
    andarId INT,
    CONSTRAINT fk_bufferId_lam FOREIGN KEY (bufferId) REFERENCES buffers(id),
    CONSTRAINT fk_color FOREIGN KEY (color) REFERENCES cores_lams(id),
    CONSTRAINT fk_andarId_lam FOREIGN KEY (andarId) REFERENCES andares(id)
);

CREATE TABLE tampas(
	id INT AUTO_INCREMENT PRIMARY KEY,
    bufferId INT,
    CONSTRAINT fk_bufferId_tampas
    FOREIGN KEY (bufferId) REFERENCES buffers(id)
);

CREATE TABLE blocos(
	id INT AUTO_INCREMENT PRIMARY KEY,
    position INT,
    color INT,
    storageId INT,
    CONSTRAINT fk_storageId_blocos
    FOREIGN KEY (storageId) REFERENCES stg(id)
);

CREATE TABLE ops(
	id VARCHAR(10) PRIMARY KEY,
    id_tampa INT,
    storageId INT,
    CONSTRAINT fk_storageId_ops
    FOREIGN KEY (storageId) REFERENCES stg(id),
    CONSTRAINT fk_id_tampa
    FOREIGN KEY (id_tampa) REFERENCES tampas(id)
);

CREATE TABLE andares (
    id INT AUTO_INCREMENT PRIMARY KEY,
    bloco INT UNIQUE,
    productionOrder VARCHAR(10),
    posicao_andar INT NOT NULL,
    CONSTRAINT fk_id_bloco FOREIGN KEY (bloco) REFERENCES blocos(id),
    CONSTRAINT fk_op FOREIGN KEY (productionOrder) REFERENCES ops(id)
);

INSERT INTO cores_lams(id, nome) VALUES(1, "Vermelha"), (2, "Azul"), (3, "Amarela"), (4, "Verde"), (5, "Preta"), (6, "Branca");


INSERT INTO stg(nome, capacidade) VALUES("Estoque", 28) ,("Expedição", 12);

ALTER TABLE lams ADD COLUMN posicao_lam INT;

ALTER TABLE andares DROP COLUMN laminasIds ;

ALTER TABLE lams RENAME COLUMN posicao_lam TO posicaoLam ;

ALTER TABLE andares RENAME COLUMN posicao_andar TO posicaoAndar ;

ALTER TABLE cores_lams MODIFY COLUMN id INT AUTO_INCREMENT;

ALTER TABLE ops RENAME COLUMN id_tampa TO tampaId;

DROP TABLE wssc2.lams;

DROP TABLE wssc2.andares;