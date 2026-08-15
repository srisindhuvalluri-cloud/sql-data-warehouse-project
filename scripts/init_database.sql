/*
==================================================
    create database and schemas
==================================================
Script Purpose:
      This script creates a new database named 'DataWarehouse' after checking if it already exists
      if the database exists, it is dropped and recreated. Additionaly, the script setups the three schemas
      within the database: 'bronze', 'silver', and 'gold',

WARNING:
      Running this script will drop the entire 'DataWarehouse' database if it exists.
      All the data in the database will be permanently deleted. proceed with caution
      and ensure you have proper backups before running this script
*/



USE Master;
GO

--Drop and recreate DataWarehouse database
IF EXISTS (SELECT 1 FROM sys.databses WHERE name= 'DataWarehouse')
BEGIN 
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse
END;
GO


--create Database 'DataWarehouse'
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO


--create schemas
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO 
CREATE SCHEMA gold;
GO
