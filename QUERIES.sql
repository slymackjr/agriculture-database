CREATE TABLE Users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    user_type ENUM('farmer', 'VEO') NOT NULL,
    username VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    village_id INT,
    phone_number VARCHAR(20),
    email VARCHAR(255),
    FOREIGN KEY (village_id) REFERENCES Villages(village_id)
);

CREATE TABLE Villages (
    village_id INT PRIMARY KEY AUTO_INCREMENT,
    village_name VARCHAR(255) NOT NULL,
    district_id INT,
    FOREIGN KEY (district_id) REFERENCES Districts(district_id)
);

CREATE TABLE Districts (
    district_id INT PRIMARY KEY AUTO_INCREMENT,
    district_name VARCHAR(255) NOT NULL,
    region_id INT,
    FOREIGN KEY (region_id) REFERENCES Regions(region_id)
);

CREATE TABLE Regions (
    region_id INT PRIMARY KEY AUTO_INCREMENT,
    region_name VARCHAR(255) NOT NULL
);

CREATE TABLE Messages (
    message_id INT PRIMARY KEY AUTO_INCREMENT,
    sender_id INT,
    recipient_id INT,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    sent_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    type ENUM('information', 'pestOutbreak', 'diseaseOutbreak', 'farmProgress', 'other') NOT NULL,
    FOREIGN KEY (sender_id) REFERENCES Users(user_id),
    FOREIGN KEY (recipient_id) REFERENCES Users(user_id)
);

CREATE TABLE Logs (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    action VARCHAR(255) NOT NULL,
    table_name VARCHAR(255),
    logged_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    details VARCHAR(255),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);


CREATE TABLE Farm (
    farm_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    farm_name VARCHAR(100) NOT NULL,
    crop_type VARCHAR(100),
    size DECIMAL(4,2) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);


-- Triggers for logging
DELIMITER //

CREATE TRIGGER LogInsertMessages
AFTER INSERT ON messages
FOR EACH ROW
BEGIN
  INSERT INTO Logs (user_id,action,table_name,logged_at,details)
  VALUES (NEW.sender_id, 'INSERT', 'messages', NOW(), CONCAT('messages: ', NEW.type));
END//

CREATE TRIGGER LogInsertUsers
AFTER INSERT ON Users
FOR EACH ROW
BEGIN
  INSERT INTO Logs (user_id,action,table_name,logged_at,details)
  VALUES (NEW.user_id, 'INSERT', 'Users', NOW(), CONCAT('User: ', NEW.user_type, ' - ', NEW.username));
END//

DELIMITER ;


DELIMITER //

CREATE TRIGGER LogUpdateMessages
AFTER UPDATE ON messages
FOR EACH ROW
BEGIN
  INSERT INTO Logs (user_id,action,table_name,logged_at,details)
  VALUES (NEW.sender_id, 'UPDATE', 'messages', NOW(), CONCAT('messages: ', NEW.type));
END//

CREATE TRIGGER LogUpdateUsers
AFTER UPDATE ON Users
FOR EACH ROW
BEGIN
  INSERT INTO Logs (user_id,action,table_name,logged_at,details)
  VALUES (NEW.user_id, 'UPDATE', 'Users', NOW(), CONCAT('User: ', NEW.user_type, ' - ', NEW.username));
END//

DELIMITER ;


DELIMITER //

CREATE TRIGGER LogDeleteMessages
BEFORE DELETE ON messages
FOR EACH ROW
BEGIN
  INSERT INTO Logs (user_id,action,table_name,logged_at,details)
  VALUES (OLD.sender_id, 'DELETE', 'messages', NOW(), CONCAT('messages: ', OLD.type));
END//

CREATE TRIGGER LogDeleteUsers
BEFORE DELETE ON Users
FOR EACH ROW
BEGIN
  INSERT INTO Logs (user_id,action,table_name,logged_at,details)
  VALUES (OLD.user_id, 'DELETE', 'Users', NOW(), CONCAT('User: ', OLD.user_type, ' - ', OLD.username));
END//

DELIMITER ;


-- Triggers for logging on the Farm table
DELIMITER //

CREATE TRIGGER LogFarmInsert
AFTER INSERT ON Farm
FOR EACH ROW
BEGIN
  INSERT INTO logs (user_id, action, table_name, logged_at, details)
  VALUES (NEW.user_id, 'INSERT', 'Farm', NOW(), CONCAT('FarmID: ', NEW.farm_id, ', FarmName: ', NEW.farm_name));
END//  

CREATE TRIGGER LogFarmUpdate
AFTER UPDATE ON Farm
FOR EACH ROW
BEGIN
  INSERT INTO logs (user_id, action, table_name, logged_at, details)
  VALUES (NEW.user_id, 'UPDATE', 'Farm', NOW(), CONCAT('FarmID: ', NEW.farm_id, ', FarmName: ', NEW.farm_name));
END//  

CREATE TRIGGER LogFarmDelete
BEFORE DELETE ON Farm
FOR EACH ROW
BEGIN
  INSERT INTO logs (user_id, action, table_name, logged_at, details)
  VALUES (OLD.user_id, 'DELETE', 'Farm', NOW(), CONCAT('FarmID: ', OLD.farm_id, ', FarmName: ', OLD.farm_name));
END//  

DELIMITER ;

-- function to validate user authentication to the agriculture system
DELIMITER //
CREATE FUNCTION ValidatePassword(username VARCHAR(50), password VARCHAR(255),usertype VARCHAR(50))
RETURNS BOOLEAN
BEGIN
    DECLARE stored_hash CHAR(60);
    SELECT password INTO stored_hash FROM Users WHERE type = usertype AND username = username;
    RETURN stored_hash = SHA2(password, 512);
END //
DELIMITER ;


-- Create a stored procedure for user authentication
DELIMITER $$
CREATE PROCEDURE AuthenticateUser(
  IN p_username VARCHAR(255),
  IN p_password VARCHAR(255),
  IN user_type ENUM('Farmer', 'VEO'),
  OUT is_authenticated BOOLEAN
)
BEGIN
    IF ValidatePassword(p_username, p_password,user_type) THEN  
       SET is_authenticated = TRUE;
    END IF;
    IF is_authenticated IS NULL THEN
        SET is_authenticated = FALSE;
  END IF;
END $$

DELIMITER ;


-- PROCEDURES TO INSERT DATA INTO TABLES
DELIMITER //

CREATE PROCEDURE InsertUser(
    IN p_user_type ENUM('farmer', 'VEO'),
    IN p_username VARCHAR(255),
    IN p_password VARCHAR(255),
    IN p_first_name VARCHAR(255),
    IN p_last_name VARCHAR(255),
    IN p_village_id INT,
    IN p_phone_number VARCHAR(20),
    IN p_email VARCHAR(255)
)
BEGIN
    INSERT INTO Users (user_type, username, password, first_name, last_name, village_id, phone_number, email)
    VALUES (p_user_type, p_username, p_password, p_first_name, p_last_name, p_village_id, p_phone_number, p_email);
END//

CREATE PROCEDURE InsertVillage(
    IN p_village_name VARCHAR(255),
    IN p_district_id INT
)
BEGIN
    INSERT INTO Villages (village_name, district_id)
    VALUES (p_village_name, p_district_id);
END//

CREATE PROCEDURE InsertDistrict(
    IN p_district_name VARCHAR(255),
    IN p_region_id INT
)
BEGIN
    INSERT INTO Districts (district_name, region_id)
    VALUES (p_district_name, p_region_id);
END//

CREATE PROCEDURE InsertRegion(
    IN p_region_name VARCHAR(255)
)
BEGIN
    INSERT INTO Regions (region_name)
    VALUES (p_region_name);
END//

CREATE PROCEDURE InsertMessage(
    IN p_sender_id INT,
    IN p_recipient_id INT,
    IN p_title VARCHAR(255),
    IN p_content TEXT,
    IN p_type ENUM('information', 'pestOutbreak', 'diseaseOutbreak', 'farmProgress', 'other')
)
BEGIN
    INSERT INTO Messages (sender_id, recipient_id, title, content, type)
    VALUES (p_sender_id, p_recipient_id, p_title, p_content, p_type);
END//

CREATE PROCEDURE InsertUserAndFarm(
    IN p_user_type ENUM('farmer', 'VEO'),
    IN p_username VARCHAR(255),
    IN p_password VARCHAR(255),
    IN p_first_name VARCHAR(255),
    IN p_last_name VARCHAR(255),
    IN p_village_id INT,
    IN p_phone_number VARCHAR(20),
    IN p_email VARCHAR(255),
    IN p_farm_name VARCHAR(100),
    IN p_crop_type VARCHAR(100),
    IN p_size DECIMAL(4,2)
)
BEGIN
    DECLARE user_id INT;

    -- Insert into Users table
    INSERT INTO Users (user_type, username, password, first_name, last_name, village_id, phone_number, email)
    VALUES (p_user_type, p_username, p_password, p_first_name, p_last_name, p_village_id, p_phone_number, p_email);

    -- Get the user_id of the inserted user
    SET user_id = LAST_INSERT_ID();

    -- Insert into Farm table if user_type is 'farmer'
    IF p_user_type = 'farmer' THEN
        INSERT INTO Farm (user_id, farm_name, crop_type, size)
        VALUES (user_id, p_farm_name, p_crop_type, p_size);
    END IF;
END//

DELIMITER ;




