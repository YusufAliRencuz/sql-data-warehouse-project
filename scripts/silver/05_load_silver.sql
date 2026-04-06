/*
=========================================================================
WARNING: THIS SCRIPT ISN'T FINISHED YET
=========================================================================
	CREATE STORE PROCEDURE: LOAD CLEANED AND FILTERED DATA TO SILVER LAYER
=========================================================================
DESCRIPTION:
			Create a procedure to load cleaned data into silver layer
		table from bronze layer table.
			There are filtering, cleaning and standardization 
		processes occurred.
=========================================================================
PARAMETER:
			No parameter
=========================================================================
USAGE EXAMPLE:
		EXEC silver.load_silver;
=========================================================================
*/

USE DataWareHouse
GO

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME; -- Create variable for metadata 
	BEGIN TRY
		SET @start_time = GETDATE();
		-- Truncate table
		TRUNCATE TABLE silver.amazon_sales_report;
		PRINT '==> Table is truncated: silver.amazon_sales_report'

		-- Insert cleaned data
		INSERT INTO silver.amazon_sales_report(
		index_id,
		order_id,
		order_date,
		status,
		fulfilment,
		sales_channel,
		ship_service_level,
		style,
		sku,
		category,
		size,
		asin,
		courier_status,
		qty,
		currency,
		amount,
		ship_city,
		ship_state,
		ship_postal_code
		)
		SELECT 
		ISNULL(TRY_CAST(TRIM(index_id) AS INT), -1) AS index_id,
		order_id,
		CASE 
			WHEN TRY_CONVERT(DATE ,order_date, 10) IS NULL THEN CAST('1111-01-01' AS DATE)
			WHEN TRY_CONVERT(DATE ,order_date, 10) > GETDATE() THEN CAST('1111-01-01' AS DATE)
			WHEN TRY_CONVERT(DATE ,order_date, 10)  < CAST('1994-07-05' AS DATE) THEN CAST('1111-01-01' AS DATE)
			ELSE TRY_CONVERT(DATE ,order_date, 10)
		END AS order_date,
		CASE 
			WHEN LOWER(status COLLATE Latin1_General_CS_AS) LIKE '%shipping%' THEN 'shipped'
			WHEN LOWER(status COLLATE Latin1_General_CS_AS) LIKE '%returning%' THEN 'shipped - returned to seller'
			WHEN status IS NULL THEN 'n/a'
			ELSE LOWER(TRIM(status) COLLATE Latin1_General_CS_AS)
		END AS status,
		LOWER(TRIM(fulfilment) COLLATE Latin1_General_CS_AS) AS fulfilment,
		LOWER(TRIM(sales_channel) COLLATE Latin1_General_CS_AS) AS sales_channel,
		LOWER(TRIM(ship_service_level) COLLATE Latin1_General_CS_AS) AS ship_service_level,
		UPPER(TRIM(style) COLLATE Latin1_General_CS_AS) AS style,
		UPPER(TRIM(sku) COLLATE Latin1_General_CS_AS) AS sku,
		LOWER(TRIM(category) COLLATE Latin1_General_CS_AS) AS category,
		UPPER(TRIM(size) COLLATE Latin1_General_CS_AS) AS size,
		UPPER(TRIM(asin) COLLATE Latin1_General_CS_AS) AS asin,
		ISNULL(LOWER(TRIM(courier_status) COLLATE Latin1_General_CS_AS), 'n/a') AS courier_status,
		ISNULL(TRY_CAST(TRIM(qty) AS INT), -1) AS qty,
		ISNULL(UPPER(TRIM(currency) COLLATE Latin1_General_CS_AS), 'n/a') AS currency,
		ISNULL(TRY_CONVERT(DECIMAL(12,2), TRIM(amount)), -1) AS amount,
		ISNULL(TRIM(LOWER(ship_city) COLLATE Latin1_General_CS_AS), 'n/a') AS ship_city,
		ISNULL(TRIM(LOWER(ship_state) COLLATE Latin1_General_CS_AS), 'n/a') AS ship_city,
		CASE 
			WHEN ship_postal_code NOT LIKE '%.[1-9]%' THEN CAST(CAST(ship_postal_code AS FLOAT) AS INT)
			ELSE -1
		END AS ship_postal_code
		FROM(
		SELECT 
		*,
		ROW_NUMBER() OVER (PARTITION BY order_id, sku, style, asin, category, size, qty, amount ORDER BY TRY_CONVERT(DATE ,order_date, 10) DESC ) AS duplicate_row
		FROM bronze.amazon_sales_report
		)t WHERE duplicate_row = 1
		SET @end_time = GETDATE();
		PRINT '==> Data have been inserted into table';
		PRINT '==> Elapsed time:' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
	END TRY
	BEGIN CATCH
		PRINT '==> An error occured!' + ERROR_MESSAGE();
	END CATCH
END
GO
