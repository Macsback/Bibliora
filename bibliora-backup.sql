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
  `AuthorID` bigint NOT NULL AUTO_INCREMENT,
  `Name` varchar(255) NOT NULL,
  PRIMARY KEY (`AuthorID`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Author`
--

LOCK TABLES `Author` WRITE;
/*!40000 ALTER TABLE `Author` DISABLE KEYS */;
INSERT INTO `Author` VALUES (1,'R.F. Kuang'),(2,'Harper Lee'),(3,'Victoria Aveyard'),(4,'Jeff Kinney'),(5,'John Flanagan'),(6,'Lois Lowry'),(7,'J.K. Rowling'),(8,'Rick Riordan'),(9,'Dawn Ius'),(10,'H├®ctor Garc├¡a & Francesc Miralles'),(11,'Frank Hebert'),(13,'Frank Herbert');
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
  `DigitalVersion` varchar(50) DEFAULT NULL,
  `BorrowLink` varchar(255) DEFAULT NULL,
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
INSERT INTO `Book` VALUES ('9780008501839','Babel','Babel is a work of speculative fiction and so takes place \n\nin a fantastical version of Oxford in the 1830s, whose history was \n throughly altered by silver-work.','Physical',NULL,NULL,'https://www.overdrive.com/media/7975485/babel',1),('9780061120084','To Kill a Mockingbird','To Kill a Mockingbird, by Harper Lee, is a novel set in the Depression-era South, focusing on racial injustice, moral growth, and the loss of innocence as seen through the eyes of Scout Finch, a young girl.','Physical',NULL,NULL,'',1),('9780062315007','Red Queen','','Physical','','','',0),('9780141324903','Diary of a Wimpy Kid','The humorous diary entries of Greg Heffley as he navigates his middle school years.','Physical','','','',0),('9780399244568','Ranger\'s Apprentice','Will, an orphan, is chosen as a ranger apprentice and learns the ways of stealth, survival, and battle.','Physical','','','',0),('9780441172719','Dune','Set in the distant future...','Digital','',NULL,NULL,0),('9780544336261','The Giver','The Giver, by Lois Lowry, tells the story of Jonas, a young boy living in a society that has eliminated pain and strife by converting to \"Sameness,\" a plan that eradicates emotional depth. Jonas is selected to inherit the position of Receiver of Memory, where he will learn from the current Receiver, an elderly man known as The Giver. As Jonas learns about the past, he begins to question the concept of Sameness and the cost of living in such a controlled society.','Physical',NULL,NULL,'',1),('9780747532699','Harry Potter','A young wizard, Harry Potter, embarks on his first year at Hogwarts School of Witchcraft and Wizardry.','Physical','','','',0),('9780786838653','Percy Jackson','Percy Jackson, a demigod, embarks on a quest to prevent a war among the gods of Mount Olympus.','Physical','','','',0),('9781423103349','Heroes of Olympus','A spin-off series from Percy Jackson, following new heroes as they face a prophecy and the rise of a new enemy.','Physical','','','',0),('9781529920321','Until I Kill You','When Delia Balmer entered into a relationship with the attentive John Sweeney, she had no idea he was a serial killer. At first he was caring but over the course of their relationship he became violent and controlling.','Physical',NULL,NULL,'https://www.amazon.co.uk/Until-Kill-You-shocking-survived/dp/1529920329',1),('9781786330895','Ikigai','The people of Japan believe that everyone has an ikigai - a reason to jump out of bed each morning. Inspiring and comforting, this book will give you the life-changing tools to uncover your personal ikigai. It will show you how to leave urgency behind, find your purpose, nurture friendships and throw yourself into your passions.','Physical',NULL,NULL,'https://www.easons.com/ikigai-hector-garcia-9781786330895',1);
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
INSERT INTO `BookAuthor` VALUES ('9780008501839',1),('9780061120084',2),('9780062315007',3),('9780141324903',4),('9780399244568',5),('9780544336261',6),('9780747532699',7),('9780786838653',8),('9781423103349',8),('9781529920321',9),('9781786330895',10),('9780441172719',11),('9780441172719',13);
/*!40000 ALTER TABLE `BookAuthor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `BookClub`
--

DROP TABLE IF EXISTS `BookClub`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `BookClub` (
  `BookClubID` bigint NOT NULL AUTO_INCREMENT,
  `Name` varchar(255) NOT NULL,
  `Description` text NOT NULL,
  PRIMARY KEY (`BookClubID`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `BookClub`
--

LOCK TABLES `BookClub` WRITE;
/*!40000 ALTER TABLE `BookClub` DISABLE KEYS */;
INSERT INTO `BookClub` VALUES (1,'Mystery Lovers Club','Join us for thrilling mysteries and exciting plots that will keep you up at night. Our club dives deep into classic whodunnit tales as well as the latest mystery novels.'),(2,'Fantasy Realm','Dive into magical worlds with epic adventures and mythical creatures. Fantasy Realm is where fans of fantasy genres unite to explore worlds full of magic, dragons, and fantastical beings.'),(3,'Historical Fiction Group','Explore the past through captivating historical tales and stories. From ancient civilizations to modern history, we explore the richness of historical fiction through insightful discussions.');
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
INSERT INTO `BookGenre` VALUES ('9780008501839',1),('9780062315007',1),('9780399244568',1),('9780747532699',1),('9780786838653',1),('9781423103349',1),('9781786330895',2),('9780061120084',3),('9780141324903',9),('9780544336261',10),('9781529920321',11),('9780441172719',15);
/*!40000 ALTER TABLE `BookGenre` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Genre`
--

DROP TABLE IF EXISTS `Genre`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Genre` (
  `GenreID` bigint NOT NULL AUTO_INCREMENT,
  `Name` varchar(100) NOT NULL,
  PRIMARY KEY (`GenreID`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Genre`
--

LOCK TABLES `Genre` WRITE;
/*!40000 ALTER TABLE `Genre` DISABLE KEYS */;
INSERT INTO `Genre` VALUES (1,'Fantasy'),(2,'Self-help'),(3,'Classic Fiction'),(5,'True Crime'),(6,'Fiction'),(8,'Classic Fiction'),(9,'Children\'s Fiction'),(10,'Dystopian Fiction'),(11,'Thriller'),(15,'Science Fiction');
/*!40000 ALTER TABLE `Genre` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Messages`
--

DROP TABLE IF EXISTS `Messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Messages` (
  `MessageID` bigint NOT NULL AUTO_INCREMENT,
  `UserID` bigint NOT NULL,
  `BookClubID` bigint NOT NULL,
  `Content` text NOT NULL,
  `Time` timestamp NOT NULL,
  PRIMARY KEY (`MessageID`),
  KEY `UserID` (`UserID`),
  KEY `BookClubID` (`BookClubID`),
  CONSTRAINT `Messages_ibfk_1` FOREIGN KEY (`UserID`) REFERENCES `User` (`UserID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `Messages_ibfk_2` FOREIGN KEY (`BookClubID`) REFERENCES `BookClub` (`BookClubID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Messages`
--

LOCK TABLES `Messages` WRITE;
/*!40000 ALTER TABLE `Messages` DISABLE KEYS */;
/*!40000 ALTER TABLE `Messages` ENABLE KEYS */;
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
  `ProfilePicture` text,
  `NotificationPreferences` tinyint(1) DEFAULT NULL,
  `MemberSince` date DEFAULT NULL,
  PRIMARY KEY (`UserID`),
  UNIQUE KEY `Email` (`Email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `User`
--

LOCK TABLES `User` WRITE;
/*!40000 ALTER TABLE `User` DISABLE KEYS */;
INSERT INTO `User` VALUES (1,'Elizabeth Brown','elizabeth_brown@gmail.com','pw',NULL,NULL,'2021-01-01');
/*!40000 ALTER TABLE `User` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `UserBook`
--

DROP TABLE IF EXISTS `UserBook`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `UserBook` (
  `UserID` bigint NOT NULL AUTO_INCREMENT,
  `BookISBN` varchar(13) NOT NULL,
  `IsDownloaded` tinyint(1) DEFAULT '0',
  `IsBorrowed` tinyint(1) DEFAULT '0',
  `BorrowStartDate` date DEFAULT NULL,
  `BorrowEndDate` date DEFAULT NULL,
  PRIMARY KEY (`UserID`,`BookISBN`),
  KEY `BookISBN` (`BookISBN`),
  CONSTRAINT `UserBook_ibfk_1` FOREIGN KEY (`UserID`) REFERENCES `User` (`UserID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `UserBook_ibfk_2` FOREIGN KEY (`BookISBN`) REFERENCES `Book` (`ISBN`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `UserBook`
--

LOCK TABLES `UserBook` WRITE;
/*!40000 ALTER TABLE `UserBook` DISABLE KEYS */;
INSERT INTO `UserBook` VALUES (1,'9780008501839',0,0,NULL,NULL),(1,'9780061120084',0,0,NULL,NULL),(1,'9780062315007',0,0,NULL,NULL),(1,'9780141324903',0,0,NULL,NULL),(1,'9780399244568',0,0,NULL,NULL),(1,'9780747532699',0,0,NULL,NULL);
/*!40000 ALTER TABLE `UserBook` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `UserBookClub`
--

DROP TABLE IF EXISTS `UserBookClub`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `UserBookClub` (
  `UserID` bigint NOT NULL,
  `BookClubID` bigint NOT NULL,
  PRIMARY KEY (`UserID`,`BookClubID`),
  KEY `BookClubID` (`BookClubID`),
  CONSTRAINT `UserBookClub_ibfk_1` FOREIGN KEY (`UserID`) REFERENCES `User` (`UserID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `UserBookClub`
--

LOCK TABLES `UserBookClub` WRITE;
/*!40000 ALTER TABLE `UserBookClub` DISABLE KEYS */;
INSERT INTO `UserBookClub` VALUES (1,1);
/*!40000 ALTER TABLE `UserBookClub` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `alembic_version`
--

DROP TABLE IF EXISTS `alembic_version`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `alembic_version` (
  `version_num` varchar(32) NOT NULL,
  PRIMARY KEY (`version_num`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `alembic_version`
--

LOCK TABLES `alembic_version` WRITE;
/*!40000 ALTER TABLE `alembic_version` DISABLE KEYS */;
INSERT INTO `alembic_version` VALUES ('e4eb386c41b4');
/*!40000 ALTER TABLE `alembic_version` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-11-24  2:04:37
