/*
===============================================================
        CREATE BRONZE LAYER TABLE
===============================================================
DESCRIPTION:
           This script creates a table to hold raw amazon data.
           All data types set as NVARCHAR to prevent data loss.
===============================================================
WARNING:
        THESE CODES DROP TABLE
===============================================================

*/
USE DataWareHouse
GO

IF OBJECT_ID('bronze.amazon_sales_report','U') IS NOT NULL
BEGIN
 DROP TABLE bronze.amazon_sales_report
 PRINT '==> Old bronze layer table has been deleted';
END
-- Create table for bronze layer
CREATE TABLE bronze.amazon_sales_report(
index_id nvarchar(100),
order_id nvarchar(100),
order_date nvarchar(100),
status nvarchar(100),
fulfilment nvarchar(100),
sales_channel nvarchar(100),
ship_service_level nvarchar(100),
style nvarchar(100),
sku nvarchar(100),
category nvarchar(100),
size nvarchar(100),
asin nvarchar(100),
courier_status nvarchar(100),
qty nvarchar(100),
currency nvarchar(100),
amount nvarchar(100),
ship_city nvarchar(100),
ship_state nvarchar(100),
ship_postal_code nvarchar(100),
ship_country nvarchar(100),
promotion_ids nvarchar(MAX),
b2b nvarchar(100),
fulfilled_by nvarchar(100),
unnamed_22  nvarchar(100),
ingested_at DATETIME DEFAULT GETDATE()
);
GO
PRINT '==> New bronze layer table has been created';
