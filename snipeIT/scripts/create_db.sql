-- Script to create additional databases in MariaDB

-- Create custom databases it it doesnt exist  
CREATE DATABASE IF NOT EXISTS `company_database`;

-- Create a second database
CREATE DATABASE IF NOT EXISTS `dev_project_db`;

-- Create a database and specify a character set and collation
-- Use utf8mb4 for full Unicode support (including emojis).
CREATE DATABASE IF NOT EXISTS `cms_data`
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- Use the database created automatically by the Docker entrypoint (DB_DATABASE='snipeit')
USE snipeit; 

-- Check and alter it to ensure the correct settings for Unicode.
ALTER DATABASE snipeit
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- Grant all privileges to the user created by the Docker entrypoint (DB_USERNAME='snipeit')
GRANT ALL PRIVILEGES ON snipeit.* TO 'snipeit'@'%';

-- Flush privileges to apply changes immediately
FLUSH PRIVILEGES;
 
