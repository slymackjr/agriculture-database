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
    phone_number VARCHAR(20),
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
    phone_number VARCHAR(20),
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


-- Triggers for logging
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

DELIMITER ;


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

DELIMITER ;


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


-- Create a stored procedure for user authentication
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

-- create user jerry to access the database if it fails to import normally

CREATE USER 'jerry'@'localhost' IDENTIFIED BY 'password';

GRANT ALL PRIVILEGES ON *.* TO 'jerry'@'localhost' IDENTIFIED BY 'jerry' WITH GRANT OPTION;

FLUSH PRIVILEGES;


