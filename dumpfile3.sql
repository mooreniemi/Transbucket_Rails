-- MySQL dump 10.13  Distrib 5.6.10, for osx10.7 (x86_64)
--
-- Host: localhost    Database: transb6_results
-- ------------------------------------------------------
-- Server version	5.5.29

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `results`
--

DROP TABLE IF EXISTS `results`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `results` (
  `ID` int(4) NOT NULL AUTO_INCREMENT,
  `username` varchar(40) NOT NULL,
  `surgeryDate` date DEFAULT NULL,
  `surgeon` varchar(40) NOT NULL DEFAULT 'other',
  `surgeryType` varchar(40) NOT NULL,
  `cost` int(8) DEFAULT NULL,
  `comments` varchar(1000) DEFAULT NULL,
  `wantRevision` varchar(20) DEFAULT NULL,
  `img1` varchar(40) DEFAULT NULL,
  `img2` varchar(40) DEFAULT NULL,
  `img3` varchar(40) DEFAULT NULL,
  `img4` varchar(40) DEFAULT NULL,
  `img1date` date DEFAULT NULL,
  `img2date` date DEFAULT NULL,
  `img3date` date DEFAULT NULL,
  `img4date` date DEFAULT NULL,
  `img1com` varchar(400) DEFAULT NULL,
  `img2com` varchar(400) DEFAULT NULL,
  `img3com` varchar(400) DEFAULT NULL,
  `img4com` varchar(400) DEFAULT NULL,
  `anonymous` varchar(4) NOT NULL DEFAULT 'no',
  `insurance` varchar(4) NOT NULL DEFAULT 'no',
  `moderated` varchar(4) NOT NULL DEFAULT '0',
  `dateApproved` datetime NOT NULL,
  `currencyCode` varchar(3) NOT NULL DEFAULT 'USD',
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=13335 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2013-03-31 17:13:23
