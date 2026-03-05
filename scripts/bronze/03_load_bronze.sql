/*
==================================================================
	CREATE STORE PROCEDURE: LOAD RAW DATA TO BRONZE LAYER
==================================================================
DESCRIPTION:
			Create a procedure to load all data into bronze layer
		table from source.
			There are no filtering, cleaning or standardization 
		processes.
==================================================================
PARAMETER:
		None. 
==================================================================
USAGE EXAMPLE:
				EXEC bronze.load_bronze;
==================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME -- Create variable for metadata
	BEGIN TRY
	SET @start_time = GETDATE();
		-- Truncate old data of table
		TRUNCATE TABLE bronze.amazon_sales_report;
		-- If there is a view delete it
		IF OBJECT_ID('bronze.vw_amazon_sales_report', 'V') IS NOT NULL
		BEGIN
			EXEC('DROP VIEW bronze.vw_amazon_sales_report')
		END
		-- Create a view
		EXEC(
		'CREATE VIEW bronze.vw_amazon_sales_report AS
		SELECT 
			index_id, order_id, order_date, status, fulfilment, sales_channel, 
			ship_service_level, style, sku, category, size, asin, courier_status, 
			qty, currency, amount, ship_city, ship_state, ship_postal_code, 
			ship_country, promotion_ids, b2b, fulfilled_by, unnamed_22
		FROM bronze.amazon_sales_report');
		--Insert new data into table
		BULK INSERT bronze.vw_amazon_sales_report
		FROM 'C:\Users\monst\OneDrive\Masaüstü\Datawarehouse_Project\Amazon Sale Report.csv'
		WITH(
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '0x0a',
			FIRSTROW = 2,
			FORMAT = 'CSV',
			FIELDQUOTE = '"',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '==> Data have been inserted table';
		PRINT '==> Elapsed time: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + 'second';
	END TRY
	BEGIN CATCH
		PRINT '==> There is an error occur!' + ERROR_MESSAGE();
	END CATCH
END
GO
