-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jan 24, 2024 at 05:20 PM
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
CREATE DEFINER=`jerry`@`localhost` PROCEDURE `AuthenticateFarmer` (IN `p_email` VARCHAR(255), IN `p_password` VARCHAR(255), OUT `is_authenticated` BOOLEAN)   BEGIN
    IF ValidatePasswordFarmer(p_email, p_password) THEN  
       SET is_authenticated = TRUE;
    END IF;
    IF is_authenticated IS NULL THEN
        SET is_authenticated = FALSE;
  END IF;
END$$

CREATE DEFINER=`jerry`@`localhost` PROCEDURE `AuthenticateVeo` (IN `p_email` VARCHAR(255), IN `p_password` VARCHAR(255), OUT `is_authenticated` BOOLEAN)   BEGIN
    IF ValidatePasswordVeo(p_email, p_password) THEN  
       SET is_authenticated = TRUE;
    END IF;
    IF is_authenticated IS NULL THEN
        SET is_authenticated = FALSE;
  END IF;
END$$

CREATE DEFINER=`jerry`@`localhost` PROCEDURE `DeleteFarm` (IN `p_farm_id` VARCHAR(255))   BEGIN
    DELETE FROM `farm`
    WHERE
        `farm_id` = p_farm_id;
END$$

CREATE DEFINER=`jerry`@`localhost` PROCEDURE `DeleteFarmer` (IN `p_email` VARCHAR(255))   BEGIN
    DELETE FROM farmer
    WHERE email = p_email;
END$$

CREATE DEFINER=`jerry`@`localhost` PROCEDURE `DeleteFarmerMessage` (IN `p_message_id` INT)   BEGIN
    DELETE FROM FarmerMessages
    WHERE
        `message_id` = p_message_id;
END$$

CREATE DEFINER=`jerry`@`localhost` PROCEDURE `DeleteVeo` (IN `p_email` VARCHAR(255))   BEGIN
    DELETE FROM veo
    WHERE email = p_email;
END$$

CREATE DEFINER=`jerry`@`localhost` PROCEDURE `DeleteVeoMessage` (IN `p_message_id` INT)   BEGIN
    DELETE FROM VeoMessages
    WHERE
        `message_id` = p_message_id;
END$$

CREATE DEFINER=`jerry`@`localhost` PROCEDURE `InsertFarm` (IN `p_farmer_email` VARCHAR(255), IN `p_farm_name` VARCHAR(100), IN `p_farm_id` VARCHAR(255), IN `p_crop_type` VARCHAR(255), IN `p_size` VARCHAR(255))   BEGIN
    INSERT INTO farm (farmer_email, farm_name, farm_id, crop_type, size)
    VALUES (p_farmer_email, p_farm_name, p_farm_id, p_crop_type, p_size);
END$$

CREATE DEFINER=`jerry`@`localhost` PROCEDURE `InsertFarmer` (IN `p_username` VARCHAR(255), IN `p_password` VARCHAR(255), IN `p_first_name` VARCHAR(255), IN `p_last_name` VARCHAR(255), IN `p_residence_id` VARCHAR(255), IN `p_farm_id` VARCHAR(255), IN `p_phone_number` VARCHAR(20), IN `p_email` VARCHAR(255))   BEGIN
    DECLARE hashed_password CHAR(64);
    SET hashed_password = SHA2(p_password, 512);

    INSERT INTO Farmer (farm_id, username, password, first_name, last_name, residence_id, phone_number, email)
    VALUES (p_farm_id, p_username, hashed_password, p_first_name, p_last_name, p_residence_id, p_phone_number, p_email);
END$$

CREATE DEFINER=`jerry`@`localhost` PROCEDURE `InsertFarmerMessage` (IN `p_sender_email` VARCHAR(255), IN `p_recipient_email` VARCHAR(255), IN `p_title` VARCHAR(255), IN `p_content` TEXT, IN `p_type` ENUM('information','pestOutbreak','diseaseOutbreak','farmProgress','other'))   BEGIN
    INSERT INTO FarmerMessages (sender_email, recipient_email, title, content, type)
    VALUES (p_sender_email, p_recipient_email, p_title, p_content, p_type);
END$$

CREATE DEFINER=`jerry`@`localhost` PROCEDURE `InsertVeo` (IN `p_username` VARCHAR(255), IN `p_password` VARCHAR(255), IN `p_first_name` VARCHAR(255), IN `p_last_name` VARCHAR(255), IN `p_job_title` VARCHAR(255), IN `p_residence_id` VARCHAR(255), IN `p_phone_number` VARCHAR(20), IN `p_email` VARCHAR(255))   BEGIN
    DECLARE hashed_password CHAR(64);
    SET hashed_password = SHA2(p_password, 512);

    INSERT INTO Veo (username, password, first_name, last_name, job_title, residence_id, phone_number, email)
    VALUES (p_username, hashed_password, p_first_name, p_last_name, p_job_title, p_residence_id, p_phone_number, p_email);
END$$

CREATE DEFINER=`jerry`@`localhost` PROCEDURE `InsertVeoMessage` (IN `p_sender_email` VARCHAR(255), IN `p_recipient_email` VARCHAR(255), IN `p_title` VARCHAR(255), IN `p_content` TEXT, IN `p_type` ENUM('information','pestOutbreak','diseaseOutbreak','farmProgress','other'))   BEGIN
    INSERT INTO VeoMessages (sender_email, recipient_email, title, content, type)
    VALUES (p_sender_email, p_recipient_email, p_title, p_content, p_type);
END$$

CREATE DEFINER=`jerry`@`localhost` PROCEDURE `UpdateFarm` (IN `p_farm_id` VARCHAR(255), IN `p_farm_name` VARCHAR(100), IN `p_crop_type` VARCHAR(255), IN `p_size` VARCHAR(255))   BEGIN
    UPDATE `farm`
    SET
        `farm_name` = COALESCE(p_farm_name, `farm_name`),
        `crop_type` = COALESCE(p_crop_type, `crop_type`),
        `size` = COALESCE(p_size, `size`)
    WHERE
        `farm_id` = p_farm_id;
END$$

CREATE DEFINER=`jerry`@`localhost` PROCEDURE `UpdateFarmer` (IN `p_email` VARCHAR(255), IN `p_new_first_name` VARCHAR(255), IN `p_new_last_name` VARCHAR(255), IN `p_new_residence_id` VARCHAR(255), IN `p_new_farm_id` VARCHAR(255), IN `p_new_phone_number` VARCHAR(20))   BEGIN
    
    UPDATE farmer
    SET 
        first_name = IFNULL(p_new_first_name, first_name),
        last_name = IFNULL(p_new_last_name, last_name),
        residence_id = IFNULL(p_new_residence_id, residence_id),
        farm_id = IFNULL(p_new_farm_id, farm_id),
        phone_number = IFNULL(p_new_phone_number, phone_number)
    WHERE email = p_email;
END$$

CREATE DEFINER=`jerry`@`localhost` PROCEDURE `UpdateFarmerMessage` (IN `p_message_id` INT, IN `p_title` VARCHAR(255), IN `p_content` TEXT, IN `p_type` ENUM('information','pestOutbreak','diseaseOutbreak','farmProgress','other'))   BEGIN
    UPDATE FarmerMessages
    SET
        `title` = COALESCE(p_title, `title`),
        `content` = COALESCE(p_content, `content`),
        `type` = COALESCE(p_type, `type`)
    WHERE
        `message_id` = p_message_id;
END$$

CREATE DEFINER=`jerry`@`localhost` PROCEDURE `UpdateVeo` (IN `p_email` VARCHAR(255), IN `p_new_first_name` VARCHAR(255), IN `p_new_last_name` VARCHAR(255), IN `p_new_job_title` VARCHAR(255), IN `p_new_residence_id` VARCHAR(255), IN `p_new_phone_number` VARCHAR(20))   BEGIN
    
    UPDATE veo
    SET 
        first_name = IFNULL(p_new_first_name, first_name),
        last_name = IFNULL(p_new_last_name, last_name),
        job_title = IFNULL(p_new_job_title, job_title),
        residence_id = IFNULL(p_new_residence_id, residence_id),
        phone_number = IFNULL(p_new_phone_number, phone_number)
    WHERE email = p_email;
END$$

CREATE DEFINER=`jerry`@`localhost` PROCEDURE `UpdateVeoMessage` (IN `p_message_id` INT, IN `p_title` VARCHAR(255), IN `p_content` TEXT, IN `p_type` ENUM('information','pestOutbreak','diseaseOutbreak','farmProgress','other'))   BEGIN
    UPDATE VeoMessages
    SET
        `title` = COALESCE(p_title, `title`),
        `content` = COALESCE(p_content, `content`),
        `type` = COALESCE(p_type, `type`)
    WHERE
        `message_id` = p_message_id;
END$$

--
-- Functions
--
CREATE DEFINER=`jerry`@`localhost` FUNCTION `ValidatePasswordFarmer` (`email` VARCHAR(255), `password` VARCHAR(255)) RETURNS TINYINT(1)  BEGIN
    DECLARE stored_hash CHAR(64);
    SELECT password INTO stored_hash FROM Farmer WHERE email = email;
    RETURN stored_hash = SHA2(password, 512);
END$$

CREATE DEFINER=`jerry`@`localhost` FUNCTION `ValidatePasswordVeo` (`email` VARCHAR(255), `password` VARCHAR(255)) RETURNS TINYINT(1)  BEGIN
    DECLARE stored_hash CHAR(64);
    SELECT password INTO stored_hash FROM Veo WHERE email = email;
    RETURN stored_hash = SHA2(password, 512);
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `farm`
--

CREATE TABLE `farm` (
  `farmer_email` varchar(255) NOT NULL,
  `farm_name` varchar(100) NOT NULL,
  `farm_id` varchar(255) NOT NULL,
  `crop_type` varchar(255) DEFAULT NULL,
  `size` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Triggers `farm`
--
DELIMITER $$
CREATE TRIGGER `LogDeleteFarm` BEFORE DELETE ON `farm` FOR EACH ROW BEGIN
    INSERT INTO Logs (user_email, action, table_name, logged_at, details)
    VALUES (OLD.farmer_email, 'DELETE FARM', 'Farm', NOW(), CONCAT('Farm Deleted: ', OLD.farm_id));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `LogInsertFarm` AFTER INSERT ON `farm` FOR EACH ROW BEGIN
    INSERT INTO Logs (user_email, action, table_name, logged_at, details)
    VALUES (NEW.farmer_email, 'INSERT FARM', 'Farm', NOW(), CONCAT('New Farm Inserted: ', NEW.farm_id));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `LogUpdateFarm` AFTER UPDATE ON `farm` FOR EACH ROW BEGIN
    INSERT INTO Logs (user_email, action, table_name, logged_at, details)
    VALUES (NEW.farmer_email, 'UPDATE FARM', 'Farm', NOW(), CONCAT('Farm Updated: ', NEW.farm_id));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `farmer`
--

CREATE TABLE `farmer` (
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `residence_id` varchar(255) DEFAULT NULL,
  `farm_id` varchar(255) DEFAULT NULL,
  `phone_number` varchar(10) DEFAULT NULL,
  `email` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Triggers `farmer`
--
DELIMITER $$
CREATE TRIGGER `LogDeleteFarmer` BEFORE DELETE ON `farmer` FOR EACH ROW BEGIN
  INSERT INTO Logs (user_email,action,table_name,logged_at,details)
  VALUES (OLD.email, 'DELETE ACCOUNT', 'Farmer', NOW(), CONCAT('Farmer Deleted Account: ', OLD.username));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `LogInsertFarmer` AFTER INSERT ON `farmer` FOR EACH ROW BEGIN
  INSERT INTO Logs (user_email,action,table_name,logged_at,details)
  VALUES (NEW.email, 'REGISTER', 'Farmer', NOW(), CONCAT('New Farmer Registered: ', NEW.username));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `LogUpdateFarmer` AFTER UPDATE ON `farmer` FOR EACH ROW BEGIN
  INSERT INTO Logs (user_email,action,table_name,logged_at,details)
  VALUES (NEW.email, 'UPDATE PROFILE', 'Farmer', NOW(), CONCAT('Farmer Update their Info: ', NEW.username));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `farmermessages`
--

CREATE TABLE `farmermessages` (
  `message_id` int(11) NOT NULL,
  `sender_email` varchar(255) DEFAULT NULL,
  `recipient_email` varchar(255) DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `content` text NOT NULL,
  `sent_at` datetime NOT NULL DEFAULT current_timestamp(),
  `type` enum('information','pestOutbreak','diseaseOutbreak','farmProgress','other') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Triggers `farmermessages`
--
DELIMITER $$
CREATE TRIGGER `LogDeleteFarmerMessages` BEFORE DELETE ON `farmermessages` FOR EACH ROW BEGIN
  INSERT INTO Logs (user_email,action,table_name,logged_at,details)
  VALUES (OLD.sender_email, 'DELETE MESSAGE', 'FarmerMessages', NOW(), CONCAT('Farmer Deleted Message to: ', OLD.recipient_email));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `LogInsertFarmerMessages` AFTER INSERT ON `farmermessages` FOR EACH ROW BEGIN
  INSERT INTO Logs (user_email,action,table_name,logged_at,details)
  VALUES (NEW.sender_email, 'SENT MESSAGE', 'FarmerMessages', NOW(), CONCAT('Farmer Messaged Veo: ', NEW.recipient_email));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `LogUpdateFarmerMessages` AFTER UPDATE ON `farmermessages` FOR EACH ROW BEGIN
  INSERT INTO Logs (user_email,action,table_name,logged_at,details)
  VALUES (NEW.sender_email, 'UPDATE MESSAGE', 'FarmerMessages', NOW(), CONCAT('Farmer Message Updated for: ', NEW.recipient_email));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `logs`
--

CREATE TABLE `logs` (
  `log_id` int(11) NOT NULL,
  `user_email` varchar(255) DEFAULT NULL,
  `action` varchar(255) NOT NULL,
  `table_name` varchar(255) DEFAULT NULL,
  `logged_at` datetime NOT NULL DEFAULT current_timestamp(),
  `details` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `residence`
--

CREATE TABLE `residence` (
  `residence_id` varchar(255) NOT NULL,
  `village_name` varchar(255) NOT NULL,
  `district_name` varchar(255) NOT NULL,
  `region_name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `veo`
--

CREATE TABLE `veo` (
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `job_title` varchar(255) DEFAULT NULL,
  `residence_id` varchar(255) DEFAULT NULL,
  `phone_number` varchar(10) DEFAULT NULL,
  `email` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Triggers `veo`
--
DELIMITER $$
CREATE TRIGGER `LogDeleteVeo` BEFORE DELETE ON `veo` FOR EACH ROW BEGIN
  INSERT INTO Logs (user_email,action,table_name,logged_at,details)
  VALUES (OLD.email, 'DELETE ACCOUNT', 'Veo', NOW(), CONCAT('Veo Deleted Account: ', OLD.username));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `LogInsertVeo` AFTER INSERT ON `veo` FOR EACH ROW BEGIN
  INSERT INTO Logs (user_email,action,table_name,logged_at,details)
  VALUES (NEW.email, 'REGISTER', 'Veo', NOW(), CONCAT('New Veo Registered: ', NEW.username));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `LogUpdateVeo` AFTER UPDATE ON `veo` FOR EACH ROW BEGIN
  INSERT INTO Logs (user_email,action,table_name,logged_at,details)
  VALUES (NEW.email, 'UPDATE PROFILE', 'Veo', NOW(), CONCAT('Veo Update their Info: ', NEW.username));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `veomessages`
--

CREATE TABLE `veomessages` (
  `message_id` int(11) NOT NULL,
  `sender_email` varchar(255) DEFAULT NULL,
  `recipient_email` varchar(255) DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `content` text NOT NULL,
  `sent_at` datetime NOT NULL DEFAULT current_timestamp(),
  `type` enum('information','pestOutbreak','diseaseOutbreak','farmProgress','other') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Triggers `veomessages`
--
DELIMITER $$
CREATE TRIGGER `LogDeleteVeoMessages` BEFORE DELETE ON `veomessages` FOR EACH ROW BEGIN
  INSERT INTO Logs (user_email,action,table_name,logged_at,details)
  VALUES (OLD.sender_email, 'DELETE MESSAGE', 'VeoMessages', NOW(), CONCAT('Veo Deleted Message to: ', OLD.recipient_email));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `LogInsertVeoMessages` AFTER INSERT ON `veomessages` FOR EACH ROW BEGIN  INSERT INTO Logs (user_email,action,table_name,logged_at,details)
  VALUES (NEW.sender_email, 'SENT MESSAGE', 'VeoMessages', NOW(), CONCAT('Veo Messaged Farmer: ', NEW.recipient_email));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `LogUpdateVeoMessages` AFTER UPDATE ON `veomessages` FOR EACH ROW BEGIN
  INSERT INTO Logs (user_email,action,table_name,logged_at,details)
  VALUES (NEW.sender_email, 'UPDATE MESSAGE', 'VeoMessages', NOW(), CONCAT('Veo Message Updated for: ', NEW.recipient_email));
END
$$
DELIMITER ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `farm`
--
ALTER TABLE `farm`
  ADD PRIMARY KEY (`farm_id`);

--
-- Indexes for table `farmer`
--
ALTER TABLE `farmer`
  ADD PRIMARY KEY (`email`),
  ADD UNIQUE KEY `username` (`username`),
  ADD KEY `residence_id` (`residence_id`),
  ADD KEY `farm_id` (`farm_id`);

--
-- Indexes for table `farmermessages`
--
ALTER TABLE `farmermessages`
  ADD PRIMARY KEY (`message_id`),
  ADD KEY `sender_email` (`sender_email`),
  ADD KEY `recipient_email` (`recipient_email`);

--
-- Indexes for table `logs`
--
ALTER TABLE `logs`
  ADD PRIMARY KEY (`log_id`);

--
-- Indexes for table `residence`
--
ALTER TABLE `residence`
  ADD PRIMARY KEY (`residence_id`);

--
-- Indexes for table `veo`
--
ALTER TABLE `veo`
  ADD PRIMARY KEY (`email`),
  ADD UNIQUE KEY `username` (`username`),
  ADD KEY `residence_id` (`residence_id`);

--
-- Indexes for table `veomessages`
--
ALTER TABLE `veomessages`
  ADD PRIMARY KEY (`message_id`),
  ADD KEY `sender_email` (`sender_email`),
  ADD KEY `recipient_email` (`recipient_email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `farmermessages`
--
ALTER TABLE `farmermessages`
  MODIFY `message_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `logs`
--
ALTER TABLE `logs`
  MODIFY `log_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `veomessages`
--
ALTER TABLE `veomessages`
  MODIFY `message_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `farmer`
--
ALTER TABLE `farmer`
  ADD CONSTRAINT `farmer_ibfk_1` FOREIGN KEY (`residence_id`) REFERENCES `residence` (`residence_id`),
  ADD CONSTRAINT `farmer_ibfk_2` FOREIGN KEY (`farm_id`) REFERENCES `farm` (`farm_id`);

--
-- Constraints for table `farmermessages`
--
ALTER TABLE `farmermessages`
  ADD CONSTRAINT `farmermessages_ibfk_1` FOREIGN KEY (`sender_email`) REFERENCES `farmer` (`email`),
  ADD CONSTRAINT `farmermessages_ibfk_2` FOREIGN KEY (`recipient_email`) REFERENCES `veo` (`email`);

--
-- Constraints for table `veo`
--
ALTER TABLE `veo`
  ADD CONSTRAINT `veo_ibfk_1` FOREIGN KEY (`residence_id`) REFERENCES `residence` (`residence_id`);

--
-- Constraints for table `veomessages`
--
ALTER TABLE `veomessages`
  ADD CONSTRAINT `veomessages_ibfk_1` FOREIGN KEY (`sender_email`) REFERENCES `veo` (`email`),
  ADD CONSTRAINT `veomessages_ibfk_2` FOREIGN KEY (`recipient_email`) REFERENCES `farmer` (`email`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
