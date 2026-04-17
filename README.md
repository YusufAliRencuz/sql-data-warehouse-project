# sql-data-warehouse-project

=> This project implements a Medallion Architecture to process and analyze Amazon sales data using SQL Server.

## BRONZE LAYER 🥉 ##
- => The goal of this layer is to store raw data with zero changes to ensure finding a copy of source data when it is needed.

### Implementation ###
- **Schema Design:** All columns are created with type `NVARCHAR()` to prevent ingestion failure due to mismatch of data type. It is defined in '02_ddl_bronze.sql'.
- **Ingestion Process:** All raw data inserted with using `BULK INSERT` with `TABLOCK` in table. It was essential to minimize transaction logging and maximize performance while handling ~129k rows.

### Challenges ###
**Key Challenges and Solutions:**
- **The Problem:** I added 'ingested_at' metadata column to the bronze layer for tracking. However it caused error while bulk insert process due to schema mismatch (CSV file doesn't have this column). 
- **The Solution:** I implemented an abstraction with using `SQL VIEW`. By mapping the only columns which CSV file has to the view, I enabled to use bulk insert.

## SILVER LAYER 🥈 ##
- => The goal of this layer is transform raw data from bronze layer into clean, standardized and reliable data for analytical processing.
- Quality checks scripts have been developed simultaneously with '05_load_silver.sql'.

### Implementation ###
- **Schema Design:** Borders of types are selected according to max length of column instance. Using `VARCHAR()` to take up less space in memory.
- **Data Normalization:** `promotion_ids` column had multiple comma-separated values. I created a new table for it to prevent data mess and allow advanced queries. The goal is fitting the 1NF rule.
- **Idempotent Design:** Both DDL and Load scripts follow the idempotent principle. Tables are safely dropped/recreated in DDL and truncated before inserting in the Load process. This makes it safe to execute the scripts multiple times without causing errors or data duplication.

### Challenges ###
**Key Challenges and Solutions:**
- **The Problem:** The status column contained inconsistent naming and hidden characters, causing standard `UPPER(TRIM())` functions to fail during normalization.
- **The Solution:** Instead of exact matching, I used `SQL Wildcards (%)` and `LIKE` operators within a `CASE` statement. This allowed me to group varied strings into a standardized status category.

## GOLD LAYER 🥇 ##
- => The goal of this layer is to transform clean data from the silver layer into a Star Schema architecture to provide business-ready data for analytical and reporting tools.

### Implementation ###
- **Schema Design:** Built a Star Schema with one fact table (`fact_sales`) and three dimension tables (`dim_product`, `dim_location`, `dim_date`). Foreign Key constraints are established to maintain referential integrity.
- **Surrogate & Smart Keys:** Converted business keys into Surrogate Keys (`INT IDENTITY`) for dimensions. Formatted dates into integer Smart Keys (e.g., 20220105) using `CAST` and `FORMAT` functions for faster `JOIN` operations.
- **Constraint Toggling:** Implemented dynamic dropping and recreating of Foreign Keys during the load process to allow fast `TRUNCATE` operations without breaking data integrity.

### Challenges ###
**Key Challenges and Solutions:**
- **The Problem:** Generating daily rows for the Date dimension using a `WHILE` loop between 2020-01-01 and 2022-12-31. It was quite inefficient and slow.
- **The Solution:** I replaced the `WHILE` loop with a Recursive `CTE` (Common Table Expression). This optimization made the date generation process significantly more efficient.
- **The Problem:** Joining location data to the fact table only by city, state, and country caused a massive row explosion (Cartesian Product) due to duplicate city names.
- **The Solution:** I added `ship_postal_code` to the `LEFT JOIN` conditions to guarantee a 1:1 match and prevent duplicate rows.
