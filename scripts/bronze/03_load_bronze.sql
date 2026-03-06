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
		@file_path: The full path of the source CSV file
==================================================================
USAGE EXAMPLE:
		EXEC bronze.load_bronze @file_path = 'C:\YOUR_PATH\Amazon Sale Report.csv' ;
==================================================================
*/
USE DataWareHouse
GO
	
CREATE OR ALTER PROCEDURE bronze.load_bronze
	@file_path NVARCHAR(MAX) -- Take file path from outside
AS	
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME -- Create variable for metadata
	DECLARE @dynamic_sql NVARCHAR(MAX) -- Create variable for dynamic query
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

		-- Create a executable string to use parameter in bulk insert
		SET @dynamic_sql = 'BULK INSERT bronze.vw_amazon_sales_report
		FROM ''' + @file_path + '''
		WITH(
			FIELDTERMINATOR = '','',
			ROWTERMINATOR = ''0x0a'',
			FIRSTROW = 2,
			FORMAT = ''CSV'',
			FIELDQUOTE = ''"'',
			TABLOCK
		);';

		--Run @dynamic_sql and insert new data into table
		EXEC sp_executesql @dynamic_sql;

		SET @end_time = GETDATE();
		PRINT '==> Data have been inserted into table';
		PRINT '==> Elapsed time: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' seconds';
	END TRY
	BEGIN CATCH
		PRINT '==> An error occured!' + ERROR_MESSAGE();
	END CATCH
END
GO
