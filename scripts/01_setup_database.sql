/*=================================================================
  CREATE DATABASE AND SCHEMAS
===================================================================
WARNING:
    THESE CODES DROP EXIST DATABASE
===================================================================
*/
USE master;
GO

-- Check whether database exists and if exists, drop it
IF EXISTS ( SELECT 1 FROM sys.databases WHERE NAME = 'DataWareHouse')
BEGIN
 ALTER DATABASE DataWareHouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
 DROP DATABASE DataWareHouse;
 PRINT '==> Old database has been deleted';
END
GO

-- Create 'DataWareHouse' database
CREATE DATABASE DataWareHouse;
PRINT '==> New database has been created';
GO

USE DataWareHouse;
GO

--Create schemas
CREATE SCHEMA bronze;  -- The layer where raw data are stored
GO
CREATE SCHEMA silver; -- The layer where cleansed and standardized data are stored
GO
CREATE SCHEMA gold; -- The business-ready layer where containing aggregated data
GO
PRINT '==> Medallion schemas have been created';
