/*
==========================================================
WARNING: THIS SCRIPT ISN'T FINISHED YET
==========================================================
		CREATE SILVER LAYER TABLE
==========================================================
DESCRIPTION:
		This scripts creates a table to hold cleaned
	and filtered data.
		Borders of types are selected according to max 
	length of column instance.
==========================================================
WARNING:
		THESE CODES DROP TABLE
==========================================================
*/

USE DataWareHouse
GO

-- Drop table if already exist
IF OBJECT_ID('silver.amazon_sales_report' , 'U') IS NOT NULL
BEGIN
	DROP TABLE silver.amazon_sales_report
	PRINT '==> Old silver layer table has been deleted';
END

-- Create table for silver layer
CREATE TABLE silver.amazon_sales_report (
sale_id INT IDENTITY(1,1) PRIMARY KEY, -- Adding 'Surrogate Key'
index_id INT,
order_id VARCHAR(25),
order_date DATE,
status VARCHAR(100),
fulfilment VARCHAR(15),
sales_channel VARCHAR(15),
ship_service_level VARCHAR(15),
style VARCHAR(15),
sku VARCHAR(50),
category VARCHAR(20),
size VARCHAR(10),
asin VARCHAR(10),
courier_status VARCHAR(15),
qty INT,
currency VARCHAR(3),
amount DECIMAL(12,2),
ship_city VARCHAR(100),
ship_state VARCHAR(50),
ship_postal_code INT
);
GO
PRINT '==> New silver layer table has been created';
