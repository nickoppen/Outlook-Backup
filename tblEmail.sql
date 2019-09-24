-- phpMyAdmin SQL Dump
-- version 4.9.0.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Sep 24, 2019 at 08:51 PM
-- Server version: 10.3.11-MariaDB
-- PHP Version: 5.6.40

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `dbEmail`
--
DROP DATABASE IF EXISTS `dbEmail`;
CREATE DATABASE IF NOT EXISTS `dbEmail` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
USE `dbEmail`;

-- --------------------------------------------------------

--
-- Stand-in structure for view `latest`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `latest`;
CREATE TABLE `latest` (
`MAX(``tblEmail``.``recievedDate``)` datetime
,`MAX(``tblEmail``.``sentDate``)` datetime
);

-- --------------------------------------------------------

--
-- Table structure for table `tblEmail`
--

DROP TABLE IF EXISTS `tblEmail`;
CREATE TABLE `tblEmail` (
  `conversationId` varchar(32) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `conversationIndex` varchar(256) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `sourceFile` varchar(64) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL COMMENT 'the pst file',
  `topFolder` varchar(24) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL COMMENT 'Inbox or Sent Items',
  `Subject` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  `Sender` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `SenderEmailAddress` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL,
  `CC` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL,
  `To` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `recievedDate` datetime DEFAULT NULL,
  `sentDate` datetime DEFAULT NULL,
  `recipients` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'All listed recipients separated by ;',
  `Content` longtext COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'The email body as text.',
  `attachmentLocation` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'The folder where the attachments are saved (currently the data of arrival in YYYY-MM-DD format).',
  `attachments` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Contains a ; separated list of the attachments found with this email (or unk# for attachments with no name)',
  `backupDate` date NOT NULL DEFAULT current_timestamp()
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- --------------------------------------------------------

--
-- Table structure for table `tblEmailOld`
--

DROP TABLE IF EXISTS `tblEmailOld`;
CREATE TABLE `tblEmailOld` (
  `conversationId` varchar(32) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `conversationIndex` varchar(256) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `sourceFile` varchar(64) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL COMMENT 'the pst file',
  `topFolder` varchar(24) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL COMMENT 'Inbox or Sent Items',
  `Subject` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  `Sender` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `SenderEmailAddress` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL,
  `CC` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL,
  `To` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `recievedDate` datetime DEFAULT NULL,
  `sentDate` datetime DEFAULT NULL,
  `recipients` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'All listed recipients separated by ;',
  `Content` longtext CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'The email body as text.',
  `attachmentLocation` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'The folder where the attachments are saved (currently the data of arrival in YYYY-MM-DD format).',
  `attachments` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Contains a ; separated list of the attachments found with this email (or unk# for attachments with no name)',
  `backupDate` date NOT NULL DEFAULT current_timestamp()
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- --------------------------------------------------------

--
-- Structure for view `latest`
--
DROP TABLE IF EXISTS `latest`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `latest`  AS  select max(`tblEmail`.`recievedDate`) AS `MAX(``tblEmail``.``recievedDate``)`,max(`tblEmail`.`sentDate`) AS `MAX(``tblEmail``.``sentDate``)` from `tblEmail` ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `tblEmailOld`
--
ALTER TABLE `tblEmailOld`
  ADD PRIMARY KEY (`conversationId`,`conversationIndex`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
