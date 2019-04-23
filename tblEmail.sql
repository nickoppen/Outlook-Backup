-- phpMyAdmin SQL Dump
-- version 3.2.0.1
-- http://www.phpmyadmin.net
--
-- Host: 127.0.0.1
-- Generation Time: Apr 23, 2019 at 02:19 PM
-- Server version: 5.0.27
-- PHP Version: 5.2.9

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `dbEmail`
--

-- --------------------------------------------------------

--
-- Table structure for table `tblEmail`
--

CREATE TABLE IF NOT EXISTS `tblEmail` (
  `conversationId` varchar(32) collate utf8_unicode_ci NOT NULL,
  `conversationIndex` varchar(256) collate utf8_unicode_ci NOT NULL,
  `sourceFile` varchar(64) collate utf8_unicode_ci NOT NULL COMMENT 'the pst file',
  `topFolder` varchar(24) collate utf8_unicode_ci NOT NULL COMMENT 'Inbox or Sent Items',
  `Subject` varchar(255) collate utf8_unicode_ci default NULL,
  `Sender` varchar(255) collate utf8_unicode_ci NOT NULL,
  `SenderEmailAddress` varchar(255) collate utf8_unicode_ci default NULL,
  `CC` varchar(255) collate utf8_unicode_ci default NULL,
  `To` varchar(255) collate utf8_unicode_ci NOT NULL,
  `recievedDate` datetime default NULL,
  `sentDate` datetime default NULL,
  `recipients` varchar(255) collate utf8_unicode_ci default NULL COMMENT 'All listed recipients separated by ;',
  `Content` longtext collate utf8_unicode_ci COMMENT 'The email body as text.',
  `attachmentLocation` varchar(255) collate utf8_unicode_ci default NULL COMMENT 'The folder where the attachments are saved (currently the data of arrival in YYYY-MM-DD format).',
  `attachments` varchar(255) collate utf8_unicode_ci default NULL COMMENT 'Contains a ; separated list of the attachments found with this email (or unk# for attachments with no name)',
  PRIMARY KEY  (`conversationId`,`conversationIndex`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
