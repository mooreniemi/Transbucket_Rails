-- MySQL dump 10.13  Distrib 5.6.10, for osx10.7 (x86_64)
--
-- Host: localhost    Database: transb6_surgeons
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
-- Table structure for table `physicians`
--

DROP TABLE IF EXISTS `physicians`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `physicians` (
  `id` varchar(4) NOT NULL,
  `physicianName` varchar(40) NOT NULL,
  `specialty` varchar(40) NOT NULL,
  `address` varchar(80) DEFAULT NULL,
  `city` varchar(80) NOT NULL,
  `state` varchar(2) NOT NULL,
  `phone` varchar(40) DEFAULT NULL,
  `email` varchar(40) DEFAULT NULL,
  `website` varchar(80) DEFAULT NULL,
  `notes` varchar(400) DEFAULT NULL,
  KEY `id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `surgeons`
--

DROP TABLE IF EXISTS `surgeons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `surgeons` (
  `id` varchar(4) NOT NULL,
  `SurgeonName` varchar(40) NOT NULL,
  `Address` varchar(400) DEFAULT NULL,
  `City` varchar(40) DEFAULT NULL,
  `State` varchar(20) DEFAULT NULL,
  `ZIP` varchar(5) DEFAULT NULL,
  `Country` varchar(40) NOT NULL,
  `Phone` varchar(20) DEFAULT NULL,
  `Email` varchar(40) DEFAULT NULL,
  `URL` varchar(80) DEFAULT NULL,
  `Procedures` varchar(400) DEFAULT NULL,
  `FTM-Bottom` varchar(1) NOT NULL DEFAULT '0',
  `FTM-Top` varchar(1) NOT NULL DEFAULT '0',
  `MTF-Bottom` varchar(1) NOT NULL DEFAULT '0',
  `MTF-Top` varchar(1) NOT NULL DEFAULT '0',
  `Facial` varchar(1) NOT NULL DEFAULT '0',
  `HairRemoval` varchar(1) NOT NULL DEFAULT '0',
  `Notes` varchar(800) DEFAULT NULL,
  KEY `id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `therapists`
--

DROP TABLE IF EXISTS `therapists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `therapists` (
  `id` varchar(4) NOT NULL,
  `therapistName` varchar(40) NOT NULL,
  `affiliation` varchar(100) DEFAULT NULL,
  `address` varchar(80) DEFAULT NULL,
  `city` varchar(80) NOT NULL,
  `state` varchar(2) NOT NULL,
  `Country` varchar(16) NOT NULL DEFAULT 'USA',
  `phone` varchar(40) DEFAULT NULL,
  `email` varchar(40) DEFAULT NULL,
  `website` varchar(80) DEFAULT NULL,
  `notes` varchar(800) DEFAULT NULL,
  KEY `id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2013-03-31 17:11:41
