/*
=====================================================================
Create Database and Schemas
======================================================================
Script Purpose:
  This script creates a new database named 'CafeSales' after checking if it already exists.
  If the database exists, it is dropped and recreated. Additionally, the script sets up three
  schemas within the database: 'bronze', 'silver', and 'gold'.
/*



--Drop and recreate the 'CafeSales' database
IF EXISTS (SELECT 1 FROM sys.databses WHERE name = 'CafeSales')
BEGIN
  ALTER DATABASE CafeSales SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
  DROP DATABASE CafeSales
END;
GO

--Create the 'CafeSales' database
CREATE DATABASE CafeSales;
GO

USE CafeSales;
GO

--Create Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
