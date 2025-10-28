/* 
==================================================================
CREATE DATABASE AND SCHEMAS
==================================================================
Script Purpose:
    This script creates a new database named 'datawarehouse'
    and it also creates the 'bronze', 'silver' and 'gold' schemas.
WARNING:
    this script drops the entire database if it exists, proceed with caution
    and make sure you have backups before executing the script.
*/


--switch to the master databse in order to create a new database
-- master is a system database where you can go and create database
USE master;

--DROP and RECREATE if the database already exists
-- sys.databases: a meta table where you can find every databases
--SET SINGLE_USER: puts the database on sıngle user mode because before deleting the db we have to disconnect the users
--WITH ROLLBACK IMMEDIATE: it closes all the ongoing processes so ıt can be on sıngle user mode
--DROP DATABASE: it would delete the database
--WARNİNG!! THIS IF BLOCK IS GETTING USED ON TEST/DEVOLOPMENT ENVIRONMENT !!NOT IN PRODUCTION ENVIRONMENT!! so you make sure you have backup
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'datawarehouse')
BEGIN
    ALTER DATABASE datawarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE datawarehouse;
END;
GO

-- this the command for creating a database
CREATE DATABASE datawarehouse;

/* we were on master and if we wanna do things on the new db,
we have to switch to the db we wanna work on */
USE datawarehouse;

/* schemas are logical structures on SQL and since we are gonna have
three layers for different purposes, we have to build three schemas for this project. */
CREATE SCHEMA bronze;

GO

CREATE SCHEMA silver;

GO

CREATE SCHEMA gold;

GO
