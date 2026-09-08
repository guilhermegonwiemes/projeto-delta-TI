-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: wssc2
-- ------------------------------------------------------
-- Server version	9.7.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
SET @MYSQLDUMP_TEMP_LOG_BIN = @@SESSION.SQL_LOG_BIN;
SET @@SESSION.SQL_LOG_BIN= 0;

--
-- GTID state at the beginning of the backup 
--

SET @@GLOBAL.GTID_PURGED=/*!80000 '+'*/ '7fe5a9d1-9bfc-11f1-b732-0242ac110002:1-389';

--
-- Table structure for table `andares`
--

DROP TABLE IF EXISTS `andares`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `andares` (
  `id` int NOT NULL AUTO_INCREMENT,
  `bloco` int DEFAULT NULL,
  `productionOrder` varchar(10) DEFAULT NULL,
  `posicaoAndar` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `bloco` (`bloco`),
  KEY `fk_op` (`productionOrder`),
  CONSTRAINT `fk_id_bloco` FOREIGN KEY (`bloco`) REFERENCES `blocos` (`id`),
  CONSTRAINT `fk_op` FOREIGN KEY (`productionOrder`) REFERENCES `ops` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `andares`
--

LOCK TABLES `andares` WRITE;
/*!40000 ALTER TABLE `andares` DISABLE KEYS */;
INSERT INTO `andares` VALUES (1,1,'OP800',3),(2,2,'OP800',3);
/*!40000 ALTER TABLE `andares` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `blocos`
--

DROP TABLE IF EXISTS `blocos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `blocos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `position` int DEFAULT NULL,
  `color` int DEFAULT NULL,
  `storageId` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_storageId_blocos` (`storageId`),
  CONSTRAINT `fk_storageId_blocos` FOREIGN KEY (`storageId`) REFERENCES `stg` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `blocos`
--

LOCK TABLES `blocos` WRITE;
/*!40000 ALTER TABLE `blocos` DISABLE KEYS */;
INSERT INTO `blocos` VALUES (1,1,1,NULL),(2,1,1,NULL);
/*!40000 ALTER TABLE `blocos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `buffers`
--

DROP TABLE IF EXISTS `buffers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `buffers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `capacidade` int DEFAULT NULL,
  `nome` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `buffers`
--

LOCK TABLES `buffers` WRITE;
/*!40000 ALTER TABLE `buffers` DISABLE KEYS */;
INSERT INTO `buffers` VALUES (1,18,'Laminas_red'),(2,18,'Laminas_blue'),(3,18,'Laminas_yellow'),(4,18,'Laminas_green'),(5,18,'Laminas_black'),(6,18,'Laminas_white'),(7,16,'Tampas');
/*!40000 ALTER TABLE `buffers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cores_lams`
--

DROP TABLE IF EXISTS `cores_lams`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cores_lams` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cores_lams`
--

LOCK TABLES `cores_lams` WRITE;
/*!40000 ALTER TABLE `cores_lams` DISABLE KEYS */;
INSERT INTO `cores_lams` VALUES (1,'Vermelha'),(2,'Azul'),(3,'Amarela'),(4,'Verde'),(5,'Preta'),(6,'Branca');
/*!40000 ALTER TABLE `cores_lams` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lams`
--

DROP TABLE IF EXISTS `lams`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lams` (
  `id` int NOT NULL AUTO_INCREMENT,
  `color` int DEFAULT NULL,
  `bufferId` int DEFAULT NULL,
  `andarId` int DEFAULT NULL,
  `posicaoLam` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_bufferId_lam` (`bufferId`),
  KEY `fk_color` (`color`),
  KEY `fk_andarId_lam` (`andarId`),
  CONSTRAINT `fk_andarId_lam` FOREIGN KEY (`andarId`) REFERENCES `andares` (`id`),
  CONSTRAINT `fk_bufferId_lam` FOREIGN KEY (`bufferId`) REFERENCES `buffers` (`id`),
  CONSTRAINT `fk_color` FOREIGN KEY (`color`) REFERENCES `cores_lams` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lams`
--

LOCK TABLES `lams` WRITE;
/*!40000 ALTER TABLE `lams` DISABLE KEYS */;
INSERT INTO `lams` VALUES (1,1,1,1,1),(2,2,2,NULL,1),(3,3,NULL,1,1);
/*!40000 ALTER TABLE `lams` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ops`
--

DROP TABLE IF EXISTS `ops`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ops` (
  `id` varchar(10) NOT NULL,
  `tampaId` int DEFAULT NULL,
  `storageId` int DEFAULT NULL,
  `position` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_storageId_ops` (`storageId`),
  KEY `fk_id_tampa` (`tampaId`),
  CONSTRAINT `fk_id_tampa` FOREIGN KEY (`tampaId`) REFERENCES `tampas` (`id`),
  CONSTRAINT `fk_storageId_ops` FOREIGN KEY (`storageId`) REFERENCES `stg` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ops`
--

LOCK TABLES `ops` WRITE;
/*!40000 ALTER TABLE `ops` DISABLE KEYS */;
INSERT INTO `ops` VALUES ('OP3168',5,2,2),('OP800',4,2,1);
/*!40000 ALTER TABLE `ops` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stg`
--

DROP TABLE IF EXISTS `stg`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stg` (
  `id` int NOT NULL AUTO_INCREMENT,
  `capacidade` int DEFAULT NULL,
  `nome` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stg`
--

LOCK TABLES `stg` WRITE;
/*!40000 ALTER TABLE `stg` DISABLE KEYS */;
INSERT INTO `stg` VALUES (1,28,'Estoque'),(2,12,'Expedição'),(3,2,'mesa');
/*!40000 ALTER TABLE `stg` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tampas`
--

DROP TABLE IF EXISTS `tampas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tampas` (
  `id` int NOT NULL AUTO_INCREMENT,
  `bufferId` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_bufferId_tampas` (`bufferId`),
  CONSTRAINT `fk_bufferId_tampas` FOREIGN KEY (`bufferId`) REFERENCES `buffers` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tampas`
--

LOCK TABLES `tampas` WRITE;
/*!40000 ALTER TABLE `tampas` DISABLE KEYS */;
INSERT INTO `tampas` VALUES (4,NULL),(5,NULL),(9,NULL),(6,7),(7,7),(8,7),(11,7),(12,7),(13,7);
/*!40000 ALTER TABLE `tampas` ENABLE KEYS */;
UNLOCK TABLES;
SET @@SESSION.SQL_LOG_BIN = @MYSQLDUMP_TEMP_LOG_BIN;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-09-08 17:17:24
