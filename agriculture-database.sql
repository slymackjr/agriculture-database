-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jan 04, 2024 at 10:27 PM
-- Server version: 10.4.24-MariaDB
-- PHP Version: 8.1.6

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `agriculture`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`jerry`@`localhost` PROCEDURE `AuthenticateUser` (IN `p_username` VARCHAR(255), IN `p_password` VARCHAR(255), IN `user_type` ENUM('Farmer','VEO'), OUT `is_authenticated` BOOLEAN)   BEGIN
    IF ValidatePassword(p_username, p_password,user_type) THEN  
       SET is_authenticated = TRUE;
    END IF;
    IF is_authenticated IS NULL THEN
        SET is_authenticated = FALSE;
  END IF;
END$$

CREATE DEFINER=`jerry`@`localhost` PROCEDURE `InsertDistrict` (IN `p_district_name` VARCHAR(255), IN `p_region_id` INT)   BEGIN
    INSERT INTO Districts (district_name, region_id)
    VALUES (p_district_name, p_region_id);
END$$

CREATE DEFINER=`jerry`@`localhost` PROCEDURE `InsertMessage` (IN `p_sender_id` INT, IN `p_recipient_id` INT, IN `p_title` VARCHAR(255), IN `p_content` TEXT, IN `p_type` ENUM('information','pestOutbreak','diseaseOutbreak','farmProgress','other'))   BEGIN
    INSERT INTO Messages (sender_id, recipient_id, title, content, type)
    VALUES (p_sender_id, p_recipient_id, p_title, p_content, p_type);
END$$

CREATE DEFINER=`jerry`@`localhost` PROCEDURE `InsertRegion` (IN `p_region_name` VARCHAR(255))   BEGIN
    INSERT INTO Regions (region_name)
    VALUES (p_region_name);
END$$

CREATE DEFINER=`jerry`@`localhost` PROCEDURE `InsertUser` (IN `p_user_type` ENUM('farmer','VEO'), IN `p_username` VARCHAR(255), IN `p_password` VARCHAR(255), IN `p_first_name` VARCHAR(255), IN `p_last_name` VARCHAR(255), IN `p_village_id` INT, IN `p_phone_number` VARCHAR(20), IN `p_email` VARCHAR(255))   BEGIN
    INSERT INTO Users (user_type, username, password, first_name, last_name, village_id, phone_number, email)
    VALUES (p_user_type, p_username, p_password, p_first_name, p_last_name, p_village_id, p_phone_number, p_email);
END$$

CREATE DEFINER=`jerry`@`localhost` PROCEDURE `InsertUserAndFarm` (IN `p_user_type` ENUM('farmer','VEO'), IN `p_username` VARCHAR(255), IN `p_password` VARCHAR(255), IN `p_first_name` VARCHAR(255), IN `p_last_name` VARCHAR(255), IN `p_village_id` INT, IN `p_phone_number` VARCHAR(20), IN `p_email` VARCHAR(255), IN `p_farm_name` VARCHAR(100), IN `p_crop_type` VARCHAR(100), IN `p_size` DECIMAL(4,2))   BEGIN
    DECLARE user_id INT;

    
    INSERT INTO Users (user_type, username, password, first_name, last_name, village_id, phone_number, email)
    VALUES (p_user_type, p_username, p_password, p_first_name, p_last_name, p_village_id, p_phone_number, p_email);

    
    SET user_id = LAST_INSERT_ID();

    
    IF p_user_type = 'farmer' THEN
        INSERT INTO Farm (user_id, farm_name, crop_type, size)
        VALUES (user_id, p_farm_name, p_crop_type, p_size);
    END IF;
END$$

CREATE DEFINER=`jerry`@`localhost` PROCEDURE `InsertVillage` (IN `p_village_name` VARCHAR(255), IN `p_district_id` INT)   BEGIN
    INSERT INTO Villages (village_name, district_id)
    VALUES (p_village_name, p_district_id);
END$$

--
-- Functions
--
CREATE DEFINER=`jerry`@`localhost` FUNCTION `ValidatePassword` (`username` VARCHAR(50), `password` VARCHAR(255), `usertype` VARCHAR(50)) RETURNS TINYINT(1)  BEGIN
    DECLARE stored_hash CHAR(60);
    SELECT password INTO stored_hash FROM Users WHERE type = usertype AND username = username;
    RETURN stored_hash = SHA2(password, 512);
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `districts`
--

CREATE TABLE `districts` (
  `district_id` int(11) NOT NULL,
  `district_name` varchar(255) NOT NULL,
  `region_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `farm`
--

CREATE TABLE `farm` (
  `farm_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `farm_name` varchar(100) NOT NULL,
  `crop_type` varchar(100) DEFAULT NULL,
  `size` decimal(4,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Triggers `farm`
--
DELIMITER $$
CREATE TRIGGER `LogFarmDelete` BEFORE DELETE ON `farm` FOR EACH ROW BEGIN
  INSERT INTO logs (user_id, action, table_name, logged_at, details)
  VALUES (OLD.user_id, 'DELETE', 'Farm', NOW(), CONCAT('FarmID: ', OLD.farm_id, ', FarmName: ', OLD.farm_name));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `LogFarmInsert` AFTER INSERT ON `farm` FOR EACH ROW BEGIN
  INSERT INTO logs (user_id, action, table_name, logged_at, details)
  VALUES (NEW.user_id, 'INSERT', 'Farm', NOW(), CONCAT('FarmID: ', NEW.farm_id, ', FarmName: ', NEW.farm_name));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `LogFarmUpdate` AFTER UPDATE ON `farm` FOR EACH ROW BEGIN
  INSERT INTO logs (user_id, action, table_name, logged_at, details)
  VALUES (NEW.user_id, 'UPDATE', 'Farm', NOW(), CONCAT('FarmID: ', NEW.farm_id, ', FarmName: ', NEW.farm_name));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `logs`
--

CREATE TABLE `logs` (
  `log_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `action` varchar(255) NOT NULL,
  `table_name` varchar(255) DEFAULT NULL,
  `logged_at` datetime NOT NULL DEFAULT current_timestamp(),
  `details` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `messages`
--

CREATE TABLE `messages` (
  `message_id` int(11) NOT NULL,
  `sender_id` int(11) DEFAULT NULL,
  `recipient_id` int(11) DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `content` text NOT NULL,
  `sent_at` datetime NOT NULL DEFAULT current_timestamp(),
  `type` enum('information','pestOutbreak','diseaseOutbreak','farmProgress','other') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Triggers `messages`
--
DELIMITER $$
CREATE TRIGGER `LogDeleteMessages` BEFORE DELETE ON `messages` FOR EACH ROW BEGIN
  INSERT INTO Logs (user_id,action,table_name,logged_at,details)
  VALUES (OLD.sender_id, 'DELETE', 'messages', NOW(), CONCAT('messages: ', OLD.type));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `LogInsertMessages` AFTER INSERT ON `messages` FOR EACH ROW BEGIN
  INSERT INTO Logs (user_id,action,table_name,logged_at,details)
  VALUES (NEW.sender_id, 'INSERT', 'messages', NOW(), CONCAT('messages: ', NEW.type));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `LogUpdateMessages` AFTER UPDATE ON `messages` FOR EACH ROW BEGIN
  INSERT INTO Logs (user_id,action,table_name,logged_at,details)
  VALUES (NEW.sender_id, 'UPDATE', 'messages', NOW(), CONCAT('messages: ', NEW.type));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `regions`
--

CREATE TABLE `regions` (
  `region_id` int(11) NOT NULL,
  `region_name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `user_type` enum('farmer','VEO') NOT NULL,
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `village_id` int(11) DEFAULT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Triggers `users`
--
DELIMITER $$
CREATE TRIGGER `LogDeleteUsers` BEFORE DELETE ON `users` FOR EACH ROW BEGIN
  INSERT INTO Logs (user_id,action,table_name,logged_at,details)
  VALUES (OLD.user_id, 'DELETE', 'Users', NOW(), CONCAT('User: ', OLD.user_type, ' - ', OLD.username));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `LogInsertUsers` AFTER INSERT ON `users` FOR EACH ROW BEGIN
  INSERT INTO Logs (user_id,action,table_name,logged_at,details)
  VALUES (NEW.user_id, 'INSERT', 'Users', NOW(), CONCAT('User: ', NEW.user_type, ' - ', NEW.username));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `LogUpdateUsers` AFTER UPDATE ON `users` FOR EACH ROW BEGIN
  INSERT INTO Logs (user_id,action,table_name,logged_at,details)
  VALUES (NEW.user_id, 'UPDATE', 'Users', NOW(), CONCAT('User: ', NEW.user_type, ' - ', NEW.username));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `villages`
--

CREATE TABLE `villages` (
  `village_id` int(11) NOT NULL,
  `village_name` varchar(255) NOT NULL,
  `district_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `districts`
--
ALTER TABLE `districts`
  ADD PRIMARY KEY (`district_id`),
  ADD KEY `region_id` (`region_id`);

--
-- Indexes for table `farm`
--
ALTER TABLE `farm`
  ADD PRIMARY KEY (`farm_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `logs`
--
ALTER TABLE `logs`
  ADD PRIMARY KEY (`log_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `messages`
--
ALTER TABLE `messages`
  ADD PRIMARY KEY (`message_id`),
  ADD KEY `sender_id` (`sender_id`),
  ADD KEY `recipient_id` (`recipient_id`);

--
-- Indexes for table `regions`
--
ALTER TABLE `regions`
  ADD PRIMARY KEY (`region_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD KEY `village_id` (`village_id`);

--
-- Indexes for table `villages`
--
ALTER TABLE `villages`
  ADD PRIMARY KEY (`village_id`),
  ADD KEY `district_id` (`district_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `districts`
--
ALTER TABLE `districts`
  MODIFY `district_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `farm`
--
ALTER TABLE `farm`
  MODIFY `farm_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `logs`
--
ALTER TABLE `logs`
  MODIFY `log_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `messages`
--
ALTER TABLE `messages`
  MODIFY `message_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `regions`
--
ALTER TABLE `regions`
  MODIFY `region_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `villages`
--
ALTER TABLE `villages`
  MODIFY `village_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `districts`
--
ALTER TABLE `districts`
  ADD CONSTRAINT `districts_ibfk_1` FOREIGN KEY (`region_id`) REFERENCES `regions` (`region_id`);

--
-- Constraints for table `farm`
--
ALTER TABLE `farm`
  ADD CONSTRAINT `farm_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `logs`
--
ALTER TABLE `logs`
  ADD CONSTRAINT `logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `messages`
--
ALTER TABLE `messages`
  ADD CONSTRAINT `messages_ibfk_1` FOREIGN KEY (`sender_id`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `messages_ibfk_2` FOREIGN KEY (`recipient_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`village_id`) REFERENCES `villages` (`village_id`);

--
-- Constraints for table `villages`
--
ALTER TABLE `villages`
  ADD CONSTRAINT `villages_ibfk_1` FOREIGN KEY (`district_id`) REFERENCES `districts` (`district_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
