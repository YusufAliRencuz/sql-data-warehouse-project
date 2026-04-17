/*
==========================================================
		CREATE GOLD LAYER TABLES (STAR SCHEMA)
==========================================================
DESCRIPTION:
		This script creates four tables, which are one fact 
	and three dimension tables, to hold business-ready 
	data in a Star Schema architecture.
		Foreign Key constraints are established to maintain 
	referential integrity between tables.
==========================================================
WARNING:
		THESE CODES DROP TABLES
==========================================================
*/

USE DataWareHouse
GO

BEGIN TRY

    BEGIN TRAN; -- Start the transaction

    IF OBJECT_ID('gold.fact_sales', 'U') IS NOT NULL
    BEGIN
        DROP TABLE gold.fact_sales
    END

    IF OBJECT_ID('gold.dim_product', 'U') IS NOT NULL
    BEGIN
        DROP TABLE gold.dim_product
    END

    IF OBJECT_ID('gold.dim_date', 'U') IS NOT NULL
    BEGIN
        DROP TABLE gold.dim_date
    END

    IF OBJECT_ID('gold.dim_location', 'U') IS NOT NULL
    BEGIN
        DROP TABLE gold.dim_location
    END

    PRINT'==> Old gold layer tables have been deleted'

    -- Create Product Dimension table
    CREATE TABLE gold.dim_product(
        product_key INT IDENTITY(1,1) PRIMARY KEY, -- Surrogate Key
        sku VARCHAR(50),
        asin VARCHAR(10),
        style VARCHAR(15),
        category VARCHAR(20),
        size VARCHAR(10)
    );
    PRINT '==> Table gold.dim_product is created.';

    -- Create Location Dimension table
    CREATE TABLE gold.dim_location (
        location_key INT IDENTITY(1,1) PRIMARY KEY,
        ship_city VARCHAR(100),
        ship_state VARCHAR(50),
        ship_postal_code INT,
        ship_country VARCHAR(3)
    );
    PRINT '==> Table gold.dim_location is created.';

    CREATE TABLE gold.dim_date (
        date_key INT PRIMARY KEY,
        full_date DATE,
        year INT,
        quarter INT,
        month INT,
        month_name VARCHAR(15),
        day INT,
        day_of_week INT,
        day_name VARCHAR(15),
        is_weekend BIT
    );
    PRINT '==> Table gold.dim_date is created.';

    -- Create Sales Fact table
    CREATE TABLE gold.fact_sales (
        sale_id INT IDENTITY(1,1) PRIMARY KEY,
        order_id VARCHAR(25),             
        date_key INT,                          
        product_key INT,                       
        location_key INT,                      
        qty INT,                               
        amount DECIMAL(12,2),

        CONSTRAINT FK_Fact_Product FOREIGN KEY (product_key) REFERENCES gold.dim_product(product_key),
        CONSTRAINT FK_Fact_Location FOREIGN KEY (location_key) REFERENCES gold.dim_location(location_key),
        CONSTRAINT FK_Fact_Date FOREIGN KEY (date_key) REFERENCES gold.dim_date(date_key)
        );
     PRINT '==> Table gold.fact_sales is created.';

    COMMIT TRAN -- Save changes permanently
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
            ROLLBACK TRAN; -- Undo all changes if an error occurs
    PRINT'==> An error occurred. ' + ERROR_MESSAGE();
END CATCH
