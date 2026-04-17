/*
==========================================================================
    
        CREATE STORE PROCEDURE: LOAD TRANSFORMED DATA TO GOLD LAYER
==========================================================================
DESCRIPTION:
            Create a procedure to load transformed data into gold layer
		tables from silver layer table.
			There are star schema creation, dimension mapping and 
		foreign key assignment processes occurred.
=========================================================================
PARAMETER:
			No parameter
=========================================================================
USAGE EXAMPLE:
		EXEC gold.load_gold;
=========================================================================

*/
USE DataWareHouse
GO

CREATE OR ALTER PROCEDURE gold.load_gold AS
BEGIN

DECLARE @start DATETIME, @end DATETIME;

BEGIN TRY
SET @start = GETDATE();

BEGIN TRAN;

-- Drop Foreign Key constraint from gold.fact_sales table
ALTER TABLE gold.fact_sales DROP CONSTRAINT FK_Fact_Product;
ALTER TABLE gold.fact_sales DROP CONSTRAINT FK_Fact_Location;
ALTER TABLE gold.fact_sales DROP CONSTRAINT FK_Fact_Date;

-- Truncate tables
TRUNCATE TABLE gold.fact_sales;
TRUNCATE TABLE gold.dim_product;
TRUNCATE TABLE gold.dim_location;
TRUNCATE TABLE gold.dim_date;


-- Load data to gold.dim_product table
INSERT INTO gold.dim_product (sku, asin, style, category, size)
SELECT DISTINCT
    sku, 
    asin, 
    style, 
    category, 
    size
FROM silver.amazon_sales_report 
WHERE sku IS NOT NULL

-- Load data to gold.dim_location table
INSERT INTO gold.dim_location (ship_city, ship_state, ship_postal_code, ship_country)
SELECT DISTINCT 
    ship_city, 
    ship_state, 
    ship_postal_code, 
    ship_country
FROM silver.amazon_sales_report
WHERE ship_city IS NOT NULL; 

-- Declare variables to use in table which will be created CTE table
DECLARE @start_date DATE = '2020-01-01';
DECLARE @end_date DATE = '2022-12-31';

-- Crate CTE table named DateCTE
WITH DateCTE AS(
    SELECT @start_date AS DateValue
    UNION ALL
    SELECT DATEADD(DAY,1,DateValue)
    FROM DateCTE
    WHERE DateValue < @end_date
)

-- Load data to gold.dim_date table
INSERT INTO gold.dim_date (
    date_key, 
    full_date, 
    year, 
    quarter, 
    month, 
    month_name, 
    day, 
    day_of_week, 
    day_name, 
    is_weekend)
SELECT
    CAST(FORMAT(DateValue, 'yyyyMMdd') AS INT), -- Converts the date into an integer smart key (YYYYMMDD) for faster JOIN operations
    DateValue,
    YEAR(DateValue),
    DATEPART(QUARTER,DateValue),
    MONTH(DateValue),
    DATENAME(MONTH,DateValue),
    DAY(DateValue),
    DATEPART(WEEKDAY,DateValue),
    DATENAME(WEEKDAY, DateValue),
    CASE WHEN DATEPART(WEEKDAY, DateValue) IN (1,7) THEN 1 ELSE 0 END
FROM DateCTE
OPTION (MAXRECURSION 0); -- Remove 100 row limit

-- Load data to gold.fact_sales table
INSERT INTO gold.fact_sales(
    order_id,
    date_key,
    product_key,
    location_key,
    qty,
    amount)
SELECT
    s.order_id,
    d.date_key,
    p.product_key,
    l.location_key,
    s.qty,
    s.amount
FROM silver.amazon_sales_report AS s
LEFT JOIN gold.dim_product AS p
    ON s.sku = p.sku
LEFT JOIN gold.dim_location AS l
    ON s.ship_city = l.ship_city
    AND s.ship_country = l.ship_country
    AND s.ship_state = l.ship_state
    AND s.ship_postal_code = l.ship_postal_code
LEFT JOIN gold.dim_date AS d
    ON CAST(FORMAT(s.order_date, 'yyyyMMdd') AS INT) = d.date_key

PRINT'==> Data have been inserted into tables'

-- Add Foreign Key constraint to gold.fact_sales table
ALTER TABLE gold.fact_sales ADD CONSTRAINT FK_Fact_Product FOREIGN KEY (product_key) REFERENCES gold.dim_product(product_key);
ALTER TABLE gold.fact_sales ADD CONSTRAINT FK_Fact_Location FOREIGN KEY (location_key) REFERENCES gold.dim_location(location_key);
ALTER TABLE gold.fact_sales ADD CONSTRAINT FK_Fact_Date FOREIGN KEY (date_key) REFERENCES gold.dim_date(date_key);

SET @end = GETDATE();
PRINT'Elapsed time: ' + CAST(DATEDIFF(SECOND,@start,@end) AS NVARCHAR) + ' seconds'
COMMIT TRAN;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRAN; -- Undo all changes if an error occurs
    PRINT'==> An error occurred. ' + ERROR_MESSAGE();
END CATCH
END
GO
