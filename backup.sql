-- MariaDB dump 10.19  Distrib 10.4.32-MariaDB, for Win64 (AMD64)
--
-- Host: bibliora.c9m8a4s4ubga.us-east-1.rds.amazonaws.com    Database: general_db
-- ------------------------------------------------------
-- Server version	8.0.39

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `Author`
--

DROP TABLE IF EXISTS `Author`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Author` (
  `AuthorID` bigint NOT NULL,
  `Name` varchar(255) NOT NULL,
  `Bio` text,
  PRIMARY KEY (`AuthorID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Author`
--

LOCK TABLES `Author` WRITE;
/*!40000 ALTER TABLE `Author` DISABLE KEYS */;
INSERT INTO `Author` VALUES (1,'Héctor García and Francesc Miralles',NULL),(2,'Miguel de Cervantes',NULL),(3,'Carlos Ruiz Zafón',NULL),(4,'Delia Balmer',NULL),(5,'Guinness World Records',NULL);
/*!40000 ALTER TABLE `Author` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Book`
--

DROP TABLE IF EXISTS `Book`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Book` (
  `ISBN` varchar(13) NOT NULL,
  `Title` varchar(255) NOT NULL,
  `Description` text,
  `Format` enum('Digital','Physical') NOT NULL,
  `DigitalLink` text,
  `DigitalVersion` text,
  `BorrowLink` text,
  `IsAvailableForBorrow` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`ISBN`),
  CONSTRAINT `Book_chk_1` CHECK (((`DigitalLink` is not null) or (`DigitalVersion` is not null) or (`BorrowLink` is not null)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Book`
--

LOCK TABLES `Book` WRITE;
/*!40000 ALTER TABLE `Book` DISABLE KEYS */;
INSERT INTO `Book` VALUES ('9780008501839','Babel','Babel is a work of speculative fiction and so takes place \n\nin a fantastical version of Oxford in the 1830s, whose history was \n throughly altered by silver-work.','Physical',NULL,NULL,'https://www.overdrive.com/media/7975485/babel',1),('9780297857136','The Shadow of the Wind','Barcelona, 1945: A city slowly heals from its war wounds, and Daniel, an antiquarian book dealer\'s son who mourns the loss of his mother, finds solace in a mysterious book entitled The Shadow of the Wind, by one Julian Carax. But when he sets out to find the author\'s other works, he makes a shocking discovery: someone has been systematically destroying every copy of every book Carax has written. In fact, Daniel may have the last of Carax\'s books in existence. Soon Daniel\'s seemingly innocent quest opens a door into one of Barcelona\'s darkest secrets--an epic story of murder, madness, and doomed love.','Physical',NULL,NULL,'https://www.goodreads.com/book/show/1232.The_Shadow_of_the_Wind',1),('9781529920321','Until I Kill You','When Delia Balmer entered into a relationship with the attentive John Sweeney, she had no idea he was a serial killer. At first he was caring but over the course of their relationship he became violent and controlling.','Physical',NULL,NULL,'https://www.amazon.co.uk/Until-Kill-You-shocking-survived/dp/1529920329',1),('9781786330895','Ikigai','The people of Japan believe that everyone has an ikigai - a reason to jump out of bed each morning. Inspiring and comforting, this book will give you the life-changing tools to uncover your personal ikigai. It will show you how to leave urgency behind, find your purpose, nurture friendships and throw yourself into your passions.','Physical',NULL,NULL,'https://www.easons.com/ikigai-hector-garcia-9781786330895',1),('9781853260360','Don Quixote','A middle-aged man named Alonso Quixano, a skinny bachelor and a lover of chivalry romances, loses his mind and decides to become a valiant knight. He names himself Don Quixote de la Mancha, names his bony horse Rocinante, and gives his beloved the sweet name Dulcinea.','Physical',NULL,NULL,'https://www.dubraybooks.ie/product/don-quixote-9781853260360',1),('9781913484552','Guinness World Records 2025','After 70 years, open the next chapter of record breaking! Filled with thousands of awesome facts and feats for the whole family, this year\'s edition celebrates Guinness World Records 70th anniversary.','Physical',NULL,NULL,'https://www.amazon.co.uk/Guinness-World-Records-2025/dp/1913484556',1);
/*!40000 ALTER TABLE `Book` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `BookAuthor`
--

DROP TABLE IF EXISTS `BookAuthor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `BookAuthor` (
  `BookISBN` varchar(13) NOT NULL,
  `AuthorID` bigint NOT NULL,
  PRIMARY KEY (`BookISBN`,`AuthorID`),
  KEY `AuthorID` (`AuthorID`),
  CONSTRAINT `BookAuthor_ibfk_1` FOREIGN KEY (`BookISBN`) REFERENCES `Book` (`ISBN`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `BookAuthor_ibfk_2` FOREIGN KEY (`AuthorID`) REFERENCES `Author` (`AuthorID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `BookAuthor`
--

LOCK TABLES `BookAuthor` WRITE;
/*!40000 ALTER TABLE `BookAuthor` DISABLE KEYS */;
INSERT INTO `BookAuthor` VALUES ('9781786330895',1),('9781853260360',2),('9780297857136',3),('9781529920321',4),('9781913484552',5);
/*!40000 ALTER TABLE `BookAuthor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `BookClub`
--

DROP TABLE IF EXISTS `BookClub`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `BookClub` (
  `BookClubID` bigint NOT NULL,
  `Name` varchar(255) NOT NULL,
  `Description` text,
  PRIMARY KEY (`BookClubID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `BookClub`
--

LOCK TABLES `BookClub` WRITE;
/*!40000 ALTER TABLE `BookClub` DISABLE KEYS */;
INSERT INTO `BookClub` VALUES (1,'Literary Enthusasists','A club for those who love to read and discuss books');
/*!40000 ALTER TABLE `BookClub` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `BookGenre`
--

DROP TABLE IF EXISTS `BookGenre`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `BookGenre` (
  `BookISBN` varchar(13) NOT NULL,
  `GenreID` bigint NOT NULL,
  PRIMARY KEY (`BookISBN`,`GenreID`),
  KEY `GenreID` (`GenreID`),
  CONSTRAINT `BookGenre_ibfk_1` FOREIGN KEY (`BookISBN`) REFERENCES `Book` (`ISBN`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `BookGenre_ibfk_2` FOREIGN KEY (`GenreID`) REFERENCES `Genre` (`GenreID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `BookGenre`
--

LOCK TABLES `BookGenre` WRITE;
/*!40000 ALTER TABLE `BookGenre` DISABLE KEYS */;
INSERT INTO `BookGenre` VALUES ('9781786330895',1),('9781853260360',2),('9780297857136',3),('9781529920321',4),('9781913484552',5);
/*!40000 ALTER TABLE `BookGenre` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Genre`
--

DROP TABLE IF EXISTS `Genre`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Genre` (
  `GenreID` bigint NOT NULL,
  `Name` varchar(100) NOT NULL,
  PRIMARY KEY (`GenreID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Genre`
--

LOCK TABLES `Genre` WRITE;
/*!40000 ALTER TABLE `Genre` DISABLE KEYS */;
INSERT INTO `Genre` VALUES (1,'Self-help'),(2,'Classic Fiction'),(3,'Mystery'),(4,'True Crime'),(5,'Reference');
/*!40000 ALTER TABLE `Genre` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `User`
--

DROP TABLE IF EXISTS `User`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `User` (
  `UserID` bigint NOT NULL,
  `Username` varchar(100) NOT NULL,
  `Email` varchar(255) NOT NULL,
  `Password` varchar(255) NOT NULL,
  PRIMARY KEY (`UserID`),
  UNIQUE KEY `Email` (`Email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `User`
--

LOCK TABLES `User` WRITE;
/*!40000 ALTER TABLE `User` DISABLE KEYS */;
INSERT INTO `User` VALUES (1,'elizabeth_brown','elizabeth@example.com','hashed_pasword');
/*!40000 ALTER TABLE `User` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-11-09 16:10:02
