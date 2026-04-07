/*
==========================================================
		CREATE SILVER LAYER TABLES
==========================================================
DESCRIPTION:
		This scripts creates two tables,which are report and 
	promotions tables, to hold cleaned and filtered data.
		Borders of types are selected according to max 
	length of column instance.
==========================================================
WARNING:
		THESE CODES DROP TABLES
==========================================================
*/

USE DataWareHouse
GO

-- Drop promotions table if already exists
IF OBJECT_ID('silver.amazon_sales_promotions', 'U') IS NOT NULL
	BEGIN
		DROP TABLE silver.amazon_sales_promotions
		PRINT '==> Old silver layer promotions table has been deleted';
	END
GO

-- Drop report table if already exist
IF OBJECT_ID('silver.amazon_sales_report' , 'U') IS NOT NULL
	BEGIN
		DROP TABLE silver.amazon_sales_report
		PRINT '==> Old silver layer report table has been deleted';
	END
GO

-- Create report table for silver layer
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
	ship_postal_code INT,
	ship_country VARCHAR(3),
	b2b VARCHAR(5),
	fulfilled_by VARCHAR(15)
);
PRINT '==> New report table has been created in silver layer';
GO

-- Create promotions table for silver layer
CREATE TABLE silver.amazon_sales_promotions (
	promotion_entry_id INT IDENTITY(1,1) PRIMARY KEY, -- Adding 'Surrogate Key'
	sale_id INT,
	promotion_id VARCHAR(150),
	CONSTRAINT FK_Promotions_Sales FOREIGN KEY (sale_id) REFERENCES silver.amazon_sales_report (sale_id)
);
PRINT '==> New promotion table has been created in silver layer';
GO
