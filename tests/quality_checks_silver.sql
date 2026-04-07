/*
================================================================
			QUALITY CHECKS
================================================================
PURPOSE: 
		This script is prepared to check data quality and data trust
		This script has several test like:
		- Nulls or duplications
		- Data standardization
		- Unwanted spaces
		- Invalid date ranges
		- Business logic and rules
================================================================
*/

USE DataWareHouse

/*
==================================================================
TABLE: silver.amazon_sales_report
==================================================================
*/

-- COLUMN index_id
-- Check for nulls and duplicates
SELECT 
index_id,
COUNT(*)
FROM silver.amazon_sales_report
GROUP BY index_id
HAVING COUNT(*)>1 OR index_id IS NULL

/*
================================================================
*/
-- COLUMN order_id
-- Check for nulls
SELECT 
order_id
FROM silver.amazon_sales_report WHERE order_id IS NULL

-- Check unwanted spaces
SELECT 
order_id
FROM silver.amazon_sales_report WHERE order_id != TRIM(order_id)

/*
================================================================
*/

-- COLUMN order_date
-- Check for nulls
SELECT 
order_date
FROM silver.amazon_sales_report WHERE order_date IS NULL

-- Check for date logic
SELECT 
order_date
FROM silver.amazon_sales_report WHERE order_date > GETDATE() OR (order_date < CAST('1994-07-05' AS DATE) AND order_date != CAST('1111-01-01' AS DATE))

/*
================================================================
*/

-- COLUMN status
-- Check for standardization
SELECT 
DISTINCT(status)
FROM silver.amazon_sales_report

-- Check for nulls
SELECT
status
FROM silver.amazon_sales_report WHERE status IS NULL

-- Check unwanted spaces
SELECT 
status
FROM silver.amazon_sales_report WHERE status != TRIM(status)


/*
================================================================
*/

-- COLUMN fulfilment
-- Check for standardization
SELECT
DISTINCT(fulfilment)
FROM silver.amazon_sales_report

-- Check for nulls
SELECT
fulfilment
FROM silver.amazon_sales_report WHERE fulfilment IS NULL


-- Check unwanted spaces
SELECT 
fulfilment
FROM silver.amazon_sales_report WHERE fulfilment != TRIM(fulfilment)

/*
================================================================
*/

-- COLUMN sales_channel
-- Check for standardization
SELECT 
DISTINCT(sales_channel)
FROM silver.amazon_sales_report

-- Check for nulls
SELECT
sales_channel
FROM silver.amazon_sales_report WHERE sales_channel IS NULL

-- Check unwanted spaces
SELECT 
sales_channel
FROM silver.amazon_sales_report WHERE sales_channel != TRIM(sales_channel)

/*
================================================================
*/

-- COLUMN ship_service_level
-- Check for standardization
SELECT 
DISTINCT(ship_service_level)
FROM silver.amazon_sales_report

-- Check for nulls
SELECT
ship_service_level
FROM silver.amazon_sales_report WHERE ship_service_level IS NULL

-- Check unwanted spaces
SELECT 
ship_service_level
FROM silver.amazon_sales_report WHERE ship_service_level != TRIM(ship_service_level)

/*
================================================================
*/

-- COLUMN style
-- Check for standardization
SELECT 
DISTINCT(style)
FROM silver.amazon_sales_report

-- Check for nulls
SELECT
style
FROM silver.amazon_sales_report WHERE style IS NULL

-- Check unwanted spaces
SELECT 
style
FROM silver.amazon_sales_report WHERE style != TRIM(style)

/*
================================================================
*/

-- COLUMN sku
-- Check for standardization
SELECT 
DISTINCT(sku)
FROM silver.amazon_sales_report

-- Check for nulls
SELECT
sku
FROM silver.amazon_sales_report WHERE sku IS NULL

-- Check unwanted spaces
SELECT 
sku
FROM silver.amazon_sales_report WHERE sku != TRIM(sku)

/*
================================================================
*/

-- COLUMN category
-- Check for standardization
SELECT 
DISTINCT(category)
FROM silver.amazon_sales_report

-- Check for nulls
SELECT
category
FROM silver.amazon_sales_report WHERE category IS NULL

-- Check unwanted spaces
SELECT 
category
FROM silver.amazon_sales_report WHERE category != TRIM(category)

/*
================================================================
*/

-- COLUMN size
-- Check for standardization
SELECT 
DISTINCT(size)
FROM silver.amazon_sales_report

-- Check for nulls
SELECT
size
FROM silver.amazon_sales_report WHERE size IS NULL

-- Check unwanted spaces
SELECT 
size
FROM silver.amazon_sales_report WHERE size != TRIM(size)

/*
================================================================
*/

-- COLUMN asin
-- Check for standardization
SELECT 
DISTINCT(asin)
FROM silver.amazon_sales_report

-- Check for nulls
SELECT
asin
FROM silver.amazon_sales_report WHERE asin IS NULL

-- Check unwanted spaces
SELECT 
asin
FROM silver.amazon_sales_report WHERE asin != TRIM(asin)

-- Check length standardization
SELECT 
DISTINCT(asin),
LEN(TRIM(asin)) AS length
FROM silver.amazon_sales_report WHERE LEN(TRIM(asin)) != 10

/*
================================================================
*/

-- COLUMN courier_status
-- Check for standardization
SELECT 
DISTINCT(courier_status)
FROM silver.amazon_sales_report

-- Check for nulls
SELECT
courier_status
FROM silver.amazon_sales_report WHERE courier_status IS NULL

-- Check unwanted spaces
SELECT 
courier_status
FROM silver.amazon_sales_report WHERE courier_status != TRIM(courier_status)

/*
================================================================
*/

-- COLUMN qty
-- Check for negative numbers except of 'fault value'
SELECT 
qty
FROM silver.amazon_sales_report WHERE qty < 0 AND qty != -1

-- Check for nulls
SELECT
qty
FROM silver.amazon_sales_report WHERE qty IS NULL


/*
================================================================
*/

-- COLUMN currency
-- Check for standardization
SELECT 
DISTINCT(currency)
FROM silver.amazon_sales_report

-- Check for nulls
SELECT
currency
FROM silver.amazon_sales_report WHERE currency IS NULL

-- Check unwanted spaces
SELECT 
currency
FROM silver.amazon_sales_report WHERE currency != TRIM(currency)

/*
================================================================
*/

-- COLUMN amount
-- Check for negative numbers except of 'fault value'
SELECT 
amount
FROM silver.amazon_sales_report WHERE amount < 0 AND amount != -1

-- Check for nulls
SELECT
amount
FROM silver.amazon_sales_report WHERE amount IS NULL


/*
================================================================
*/

-- COLUMN ship_city
-- Check for standardization
SELECT 
DISTINCT(ship_city)
FROM silver.amazon_sales_report

-- Check for nulls
SELECT
ship_city
FROM silver.amazon_sales_report WHERE ship_city IS NULL

-- Check unwanted spaces
SELECT 
ship_city
FROM silver.amazon_sales_report WHERE ship_city != TRIM(ship_city)


/*
================================================================
*/

-- COLUMN ship_state
-- Check for standardization
SELECT 
DISTINCT(ship_state)
FROM silver.amazon_sales_report

-- Check for nulls
SELECT
ship_state
FROM silver.amazon_sales_report WHERE ship_state IS NULL

-- Check unwanted spaces
SELECT 
ship_state
FROM silver.amazon_sales_report WHERE ship_state != TRIM(ship_state)

/*
================================================================
*/

-- COLUMN ship_postal_code
-- Check whether is any records in raw data shouldn't be converted to integer
SELECT 
    COUNT(*) AS Hatali_Kayit_Sayisi
FROM bronze.amazon_sales_report
WHERE ship_postal_code LIKE '%.[1-9]%' OR ship_postal_code LIKE '%[^0-9.]%'

-- Check for negative numbers except of 'fault value'
SELECT 
ship_postal_code
FROM silver.amazon_sales_report WHERE ship_postal_code < 0 AND ship_postal_code != -1

-- Check for nulls
SELECT
ship_postal_code
FROM silver.amazon_sales_report WHERE ship_postal_code IS NULL


/*
================================================================
*/

-- COLUMN ship_country
-- Check for standardization
SELECT 
DISTINCT(ship_country)
FROM silver.amazon_sales_report

-- Check for nulls
SELECT
ship_country
FROM silver.amazon_sales_report WHERE ship_country IS NULL

-- Check unwanted spaces
SELECT 
ship_country
FROM silver.amazon_sales_report WHERE ship_country != TRIM(ship_country)

/*
================================================================
*/

-- COLUMN b2b
-- Check for standardization
SELECT 
DISTINCT(b2b)
FROM silver.amazon_sales_report

-- Check for nulls
SELECT
b2b
FROM silver.amazon_sales_report WHERE b2b IS NULL

-- Check unwanted spaces
SELECT 
b2b
FROM silver.amazon_sales_report WHERE b2b != TRIM(b2b)

/*
================================================================
*/

-- COLUMN fulfilled_by
-- Check for standardization
SELECT 
DISTINCT(fulfilled_by)
FROM silver.amazon_sales_report

-- Check for nulls
SELECT
fulfilled_by
FROM silver.amazon_sales_report WHERE fulfilled_by IS NULL

-- Check unwanted spaces
SELECT 
fulfilled_by
FROM silver.amazon_sales_report WHERE fulfilled_by != TRIM(fulfilled_by)

/*
==================================================================
TABLE: silver.amazon_sales_promotions
==================================================================
*/

-- COLUMN promotion_id
-- Check for standardization
SELECT 
DISTINCT(promotion_id)
FROM silver.amazon_sales_promotions

-- Check for nulls
SELECT
promotion_id
FROM silver.amazon_sales_promotions WHERE promotion_id IS NULL

-- Check unwanted spaces
SELECT 
promotion_id
FROM silver.amazon_sales_promotions WHERE promotion_id != TRIM(promotion_id)
