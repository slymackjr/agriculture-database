-- database agriculture and tables created
CREATE DATABASE agriculture;

USE agriculture;

CREATE TABLE Residence (
    residence_id VARCHAR(255) PRIMARY KEY,
    village_name VARCHAR(255) NOT NULL,
    district_name VARCHAR(255) NOT NULL,
    region_name VARCHAR(255) NOT NULL
);

CREATE TABLE Farm (
    farmer_email VARCHAR(255) NOT NULL,
    farm_name VARCHAR(100) NOT NULL,
    farm_id VARCHAR(255) PRIMARY KEY,
    crop_type VARCHAR(255),
    size VARCHAR(255) NOT NULL
);

CREATE TABLE Veo (
    username VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    job_title VARCHAR(255),
    residence_id VARCHAR(255),
    phone_number VARCHAR(10),
    email VARCHAR(255) PRIMARY KEY,
    FOREIGN KEY (residence_id) REFERENCES Residence(residence_id)
);

CREATE TABLE Farmer (
    username VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    residence_id VARCHAR(255),
    farm_id VARCHAR(255),
    phone_number VARCHAR(10),
    email VARCHAR(255) PRIMARY KEY,
    FOREIGN KEY (residence_id) REFERENCES Residence(residence_id),
    FOREIGN KEY (farm_id) REFERENCES Farm(farm_id)
);

CREATE TABLE FarmerMessages (
    message_id INT PRIMARY KEY AUTO_INCREMENT,
    sender_email VARCHAR(255),
    recipient_email VARCHAR(255),
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    sent_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    type ENUM('information', 'pestOutbreak', 'diseaseOutbreak', 'farmProgress', 'other') NOT NULL,
    FOREIGN KEY (sender_email) REFERENCES Farmer(email),
    FOREIGN KEY (recipient_email) REFERENCES Veo(email)
);

CREATE TABLE VeoMessages (
    message_id INT PRIMARY KEY AUTO_INCREMENT,
    sender_email VARCHAR(255),
    recipient_email VARCHAR(255),
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    sent_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    type ENUM('information', 'pestOutbreak', 'diseaseOutbreak', 'farmProgress', 'other') NOT NULL,
    FOREIGN KEY (sender_email) REFERENCES Veo(email),
    FOREIGN KEY (recipient_email) REFERENCES Farmer(email)
);

CREATE TABLE Logs (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    user_email VARCHAR(255),
    action VARCHAR(255) NOT NULL,
    table_name VARCHAR(255),
    logged_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    details VARCHAR(255)
);


-- Triggers for Logs table for insertion queries.
DELIMITER //

CREATE TRIGGER LogInsertFarmerMessages
AFTER INSERT ON FarmerMessages
FOR EACH ROW
BEGIN
  INSERT INTO Logs (user_email,action,table_name,logged_at,details)
  VALUES (NEW.sender_email, 'SENT MESSAGE', 'FarmerMessages', NOW(), CONCAT('Farmer Messaged Veo: ', NEW.recipient_email));
END//

CREATE TRIGGER LogInsertVeoMessages
AFTER INSERT ON VeoMessages
FOR EACH ROW
BEGIN  INSERT INTO Logs (user_email,action,table_name,logged_at,details)
  VALUES (NEW.sender_email, 'SENT MESSAGE', 'VeoMessages', NOW(), CONCAT('Veo Messaged Farmer: ', NEW.recipient_email));
END//

CREATE TRIGGER LogInsertFarmer
AFTER INSERT ON Farmer
FOR EACH ROW
BEGIN
  INSERT INTO Logs (user_email,action,table_name,logged_at,details)
  VALUES (NEW.email, 'REGISTER', 'Farmer', NOW(), CONCAT('New Farmer Registered: ', NEW.username));
END//

CREATE TRIGGER LogInsertVeo
AFTER INSERT ON Veo
FOR EACH ROW
BEGIN
  INSERT INTO Logs (user_email,action,table_name,logged_at,details)
  VALUES (NEW.email, 'REGISTER', 'Veo', NOW(), CONCAT('New Veo Registered: ', NEW.username));
END//

CREATE TRIGGER LogInsertFarm
AFTER INSERT ON farm
FOR EACH ROW
BEGIN
    INSERT INTO Logs (user_email, action, table_name, logged_at, details)
    VALUES (NEW.farmer_email, 'INSERT FARM', 'Farm', NOW(), CONCAT('New Farm Inserted: ', NEW.farm_id));
END//

DELIMITER ;


 -- trigger for logging updates in the database
DELIMITER //

CREATE TRIGGER LogUpdateFarmerMessages
AFTER UPDATE ON FarmerMessages
FOR EACH ROW
BEGIN
  INSERT INTO Logs (user_email,action,table_name,logged_at,details)
  VALUES (NEW.sender_email, 'UPDATE MESSAGE', 'FarmerMessages', NOW(), CONCAT('Farmer Message Updated for: ', NEW.recipient_email));
END//

CREATE TRIGGER LogUpdateVeoMessages
AFTER UPDATE ON VeoMessages
FOR EACH ROW
BEGIN
  INSERT INTO Logs (user_email,action,table_name,logged_at,details)
  VALUES (NEW.sender_email, 'UPDATE MESSAGE', 'VeoMessages', NOW(), CONCAT('Veo Message Updated for: ', NEW.recipient_email));
END//

CREATE TRIGGER LogUpdateFarmer
AFTER UPDATE ON Farmer
FOR EACH ROW
BEGIN
  INSERT INTO Logs (user_email,action,table_name,logged_at,details)
  VALUES (NEW.email, 'UPDATE PROFILE', 'Farmer', NOW(), CONCAT('Farmer Update their Info: ', NEW.username));
END//

CREATE TRIGGER LogUpdateVeo
AFTER UPDATE ON Veo
FOR EACH ROW
BEGIN
  INSERT INTO Logs (user_email,action,table_name,logged_at,details)
  VALUES (NEW.email, 'UPDATE PROFILE', 'Veo', NOW(), CONCAT('Veo Update their Info: ', NEW.username));
END//

CREATE TRIGGER LogUpdateFarm
AFTER UPDATE ON farm
FOR EACH ROW
BEGIN
    INSERT INTO Logs (user_email, action, table_name, logged_at, details)
    VALUES (NEW.farmer_email, 'UPDATE FARM', 'Farm', NOW(), CONCAT('Farm Updated: ', NEW.farm_id));
END//

DELIMITER ;


-- trigger for logging deletes
DELIMITER //

CREATE TRIGGER LogDeleteFarmerMessages
BEFORE DELETE ON FarmerMessages
FOR EACH ROW
BEGIN
  INSERT INTO Logs (user_email,action,table_name,logged_at,details)
  VALUES (OLD.sender_email, 'DELETE MESSAGE', 'FarmerMessages', NOW(), CONCAT('Farmer Deleted Message to: ', OLD.recipient_email));
END//

CREATE TRIGGER LogDeleteVeoMessages
BEFORE DELETE ON VeoMessages
FOR EACH ROW
BEGIN
  INSERT INTO Logs (user_email,action,table_name,logged_at,details)
  VALUES (OLD.sender_email, 'DELETE MESSAGE', 'VeoMessages', NOW(), CONCAT('Veo Deleted Message to: ', OLD.recipient_email));
END//

CREATE TRIGGER LogDeleteFarmer
BEFORE DELETE ON Farmer
FOR EACH ROW
BEGIN
  INSERT INTO Logs (user_email,action,table_name,logged_at,details)
  VALUES (OLD.email, 'DELETE ACCOUNT', 'Farmer', NOW(), CONCAT('Farmer Deleted Account: ', OLD.username));
END//

CREATE TRIGGER LogDeleteVeo
BEFORE DELETE ON Veo
FOR EACH ROW
BEGIN
  INSERT INTO Logs (user_email,action,table_name,logged_at,details)
  VALUES (OLD.email, 'DELETE ACCOUNT', 'Veo', NOW(), CONCAT('Veo Deleted Account: ', OLD.username));
END//

CREATE TRIGGER LogDeleteFarm
BEFORE DELETE ON farm
FOR EACH ROW
BEGIN
    INSERT INTO Logs (user_email, action, table_name, logged_at, details)
    VALUES (OLD.farmer_email, 'DELETE FARM', 'Farm', NOW(), CONCAT('Farm Deleted: ', OLD.farm_id));
END//

DELIMITER ;


-- function to validate user authentication to the agriculture system
DELIMITER //
CREATE FUNCTION ValidatePasswordFarmer(email VARCHAR(255), password VARCHAR(255))
RETURNS BOOLEAN
BEGIN
    DECLARE stored_hash CHAR(64);
    SELECT password INTO stored_hash FROM Farmer WHERE email = email;
    RETURN stored_hash = SHA2(password, 512);
END //

CREATE FUNCTION ValidatePasswordVeo(email VARCHAR(255), password VARCHAR(255))
RETURNS BOOLEAN
BEGIN
    DECLARE stored_hash CHAR(64);
    SELECT password INTO stored_hash FROM Veo WHERE email = email;
    RETURN stored_hash = SHA2(password, 512);
END //
DELIMITER ;


-- stored procedure for user authentication
DELIMITER $$
CREATE PROCEDURE AuthenticateFarmer(
  IN p_email VARCHAR(255),
  IN p_password VARCHAR(255),
  OUT is_authenticated BOOLEAN
)
BEGIN
    IF ValidatePasswordFarmer(p_email, p_password) THEN  
       SET is_authenticated = TRUE;
    END IF;
    IF is_authenticated IS NULL THEN
        SET is_authenticated = FALSE;
  END IF;
END $$

CREATE PROCEDURE AuthenticateVeo(
  IN p_email VARCHAR(255),
  IN p_password VARCHAR(255),
  OUT is_authenticated BOOLEAN
)
BEGIN
    IF ValidatePasswordVeo(p_email, p_password) THEN  
       SET is_authenticated = TRUE;
    END IF;
    IF is_authenticated IS NULL THEN
        SET is_authenticated = FALSE;
  END IF;
END $$

DELIMITER ;


-- PROCEDURES TO INSERT DATA INTO TABLES
DELIMITER //

CREATE PROCEDURE InsertFarmer(
    IN p_username VARCHAR(255),
    IN p_password VARCHAR(255),
    IN p_first_name VARCHAR(255),
    IN p_last_name VARCHAR(255),
    IN p_residence_id VARCHAR(255),
    IN p_farm_id VARCHAR(255),    
    IN p_phone_number VARCHAR(20),
    IN p_email VARCHAR(255)
)
BEGIN
    DECLARE hashed_password CHAR(64);
    SET hashed_password = SHA2(p_password, 512);

    INSERT INTO Farmer (farm_id, username, password, first_name, last_name, residence_id, phone_number, email)
    VALUES (p_farm_id, p_username, hashed_password, p_first_name, p_last_name, p_residence_id, p_phone_number, p_email);
END//

CREATE PROCEDURE InsertVeo(
    IN p_username VARCHAR(255),
    IN p_password VARCHAR(255),
    IN p_first_name VARCHAR(255),
    IN p_last_name VARCHAR(255),
    IN p_job_title VARCHAR(255),    
    IN p_residence_id VARCHAR(255),    
    IN p_phone_number VARCHAR(20),
    IN p_email VARCHAR(255)
)
BEGIN
    DECLARE hashed_password CHAR(64);
    SET hashed_password = SHA2(p_password, 512);

    INSERT INTO Veo (username, password, first_name, last_name, job_title, residence_id, phone_number, email)
    VALUES (p_username, hashed_password, p_first_name, p_last_name, p_job_title, p_residence_id, p_phone_number, p_email);
END//


CREATE PROCEDURE InsertFarm (
    IN `p_farmer_email` VARCHAR(255),
    IN `p_farm_name` VARCHAR(100),
    IN `p_farm_id` VARCHAR(255),
    IN `p_crop_type` VARCHAR(255),
    IN `p_size` VARCHAR(255)
)
BEGIN
    INSERT INTO farm (farmer_email, farm_name, farm_id, crop_type, size)
    VALUES (p_farmer_email, p_farm_name, p_farm_id, p_crop_type, p_size);
END//


CREATE PROCEDURE InsertFarmerMessage(
    IN p_sender_email VARCHAR(255),
    IN p_recipient_email VARCHAR(255),
    IN p_title VARCHAR(255),
    IN p_content TEXT,
    IN p_type ENUM('information', 'pestOutbreak', 'diseaseOutbreak', 'farmProgress', 'other')
)
BEGIN
    INSERT INTO FarmerMessages (sender_email, recipient_email, title, content, type)
    VALUES (p_sender_email, p_recipient_email, p_title, p_content, p_type);
END//
CREATE PROCEDURE InsertVeoMessage(
    IN p_sender_email VARCHAR(255),
    IN p_recipient_email VARCHAR(255),
    IN p_title VARCHAR(255),
    IN p_content TEXT,
    IN p_type ENUM('information', 'pestOutbreak', 'diseaseOutbreak', 'farmProgress', 'other')
)
BEGIN
    INSERT INTO VeoMessages (sender_email, recipient_email, title, content, type)
    VALUES (p_sender_email, p_recipient_email, p_title, p_content, p_type);
END//

DELIMITER ;


-- ProcedureS to Update Information in agriculture system

DELIMITER //

CREATE PROCEDURE UpdateFarmer (
    IN `p_email` VARCHAR(255),
    IN `p_new_first_name` VARCHAR(255),
    IN `p_new_last_name` VARCHAR(255),
    IN `p_new_residence_id` VARCHAR(255),
    IN `p_new_farm_id` VARCHAR(255),
    IN `p_new_phone_number` VARCHAR(20)
)
BEGIN
    -- Updating Farmer Information
    UPDATE farmer
    SET 
        first_name = IFNULL(p_new_first_name, first_name),
        last_name = IFNULL(p_new_last_name, last_name),
        residence_id = IFNULL(p_new_residence_id, residence_id),
        farm_id = IFNULL(p_new_farm_id, farm_id),
        phone_number = IFNULL(p_new_phone_number, phone_number)
    WHERE email = p_email;
END//

-- Procedure to Update Veo Information
CREATE PROCEDURE UpdateVeo (
    IN `p_email` VARCHAR(255),
    IN `p_new_first_name` VARCHAR(255),
    IN `p_new_last_name` VARCHAR(255),
    IN `p_new_job_title` VARCHAR(255),
    IN `p_new_residence_id` VARCHAR(255),
    IN `p_new_phone_number` VARCHAR(20)
)
BEGIN
    -- Updating Veo Information
    UPDATE veo
    SET 
        first_name = IFNULL(p_new_first_name, first_name),
        last_name = IFNULL(p_new_last_name, last_name),
        job_title = IFNULL(p_new_job_title, job_title),
        residence_id = IFNULL(p_new_residence_id, residence_id),
        phone_number = IFNULL(p_new_phone_number, phone_number)
    WHERE email = p_email;
END//

CREATE PROCEDURE UpdateVeoMessage (
    IN `p_message_id` INT,
    IN `p_title` VARCHAR(255),
    IN `p_content` TEXT,
    IN `p_type` ENUM('information','pestOutbreak','diseaseOutbreak','farmProgress','other')
)
BEGIN
    UPDATE VeoMessages
    SET
        `title` = COALESCE(p_title, `title`),
        `content` = COALESCE(p_content, `content`),
        `type` = COALESCE(p_type, `type`)
    WHERE
        `message_id` = p_message_id;
END//

CREATE PROCEDURE UpdateFarmerMessage (
    IN `p_message_id` INT,
    IN `p_title` VARCHAR(255),
    IN `p_content` TEXT,
    IN `p_type` ENUM('information','pestOutbreak','diseaseOutbreak','farmProgress','other')
)
BEGIN
    UPDATE FarmerMessages
    SET
        `title` = COALESCE(p_title, `title`),
        `content` = COALESCE(p_content, `content`),
        `type` = COALESCE(p_type, `type`)
    WHERE
        `message_id` = p_message_id;
END//

CREATE PROCEDURE UpdateFarm (
    IN `p_farm_id` VARCHAR(255),
    IN `p_farm_name` VARCHAR(100),
    IN `p_crop_type` VARCHAR(255),
    IN `p_size` VARCHAR(255)
)
BEGIN
    UPDATE `farm`
    SET
        `farm_name` = COALESCE(p_farm_name, `farm_name`),
        `crop_type` = COALESCE(p_crop_type, `crop_type`),
        `size` = COALESCE(p_size, `size`)
    WHERE
        `farm_id` = p_farm_id;
END//

DELIMITER ;


-- Procedure to Delete Information in the agriculture database system

DELIMITER //

CREATE PROCEDURE DeleteFarmer (
    IN `p_email` VARCHAR(255)
)
BEGIN
    DELETE FROM farmer
    WHERE email = p_email;
END//

CREATE PROCEDURE DeleteVeo (
    IN `p_email` VARCHAR(255)
)
BEGIN
    DELETE FROM veo
    WHERE email = p_email;
END//

CREATE PROCEDURE DeleteVeoMessage (
    IN `p_message_id` INT
)
BEGIN
    DELETE FROM VeoMessages
    WHERE
        `message_id` = p_message_id;
END//

CREATE PROCEDURE DeleteFarmerMessage (
    IN `p_message_id` INT
)
BEGIN
    DELETE FROM FarmerMessages
    WHERE
        `message_id` = p_message_id;
END//

CREATE PROCEDURE DeleteFarm (
    IN `p_farm_id` VARCHAR(255)
)
BEGIN
    DELETE FROM `farm`
    WHERE
        `farm_id` = p_farm_id;
END//

DELIMITER ;



