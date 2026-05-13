/*******************************************************************************
Script:         01_Initialize_Warehouse.sql
Description:    Create Database and Schemas
================================================================================
Script Purpose:
    This script creates a new database named 'DataWarehouse' after checking if 
    it already exists. If the database exists, it is dropped and recreated. 
    Additionally, the script sets up three schemas within the database: 
    'bronze', 'silver', and 'gold'.

WARNING:
    Running this script will drop the entire 'DataWarehouse' database if it exists.
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
================================================================================
Author:         Namiq Ismayilov
Date:           2026-05-13
Version:        1.4
*******************************************************************************/

USE master;
GO

-- 1. Check if the database exists
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    -- 2. Force the database into Single User mode to kill active connections.
    -- This prevents the "Database is in use" error during the DROP command.
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    
    -- 3. Drop the database
    DROP DATABASE DataWarehouse;
    PRINT 'Existing Database [DataWarehouse] has been dropped.';
END
GO

-- 4. Create a fresh instance of the database
CREATE DATABASE DataWarehouse;
PRINT 'Database [DataWarehouse] created successfully.';
GO

USE DataWarehouse;
GO

-- 5. Create the Medallion Architecture schemas
-- We use EXEC here so the script can be parsed cleanly as a single batch
EXEC('CREATE SCHEMA bronze');
GO
EXEC('CREATE SCHEMA silver');
GO
EXEC('CREATE SCHEMA gold');
GO

PRINT 'Schemas [bronze], [silver], and [gold] created.';
GO
