# sql-data-warehouse-project

## BRONZE LAYER 🥉 ##
=> The goal of this layer is to store raw data with zero changes to ensure finding a copy of source data when it is needed.

### Implementation ###
- **Schema Design:** All columns are created with type `NVARCHAR()` to prevent ingestion failure due to mismatch of data type. It defined in '02_ddl_bronze.sql'.
- **Ingestion Process:** All raw data inserted with using `BULK INSERT` with `TABLOCK` in table. It was essential to minimize transaction logging and maximize performance while handling ~129k rows.

### Challenges ###
**Key Challenges and Solutions:**
- **The Problem:** I added 'ingested_at' metadata column to the bronze layer for tracking. However it caused error while bulk insert process due to mismatch of schema (CSV file doesn't have this column). 
- **The Solution:** I implemented an abstraction with using `SQL VIEW`. By mapping the only  columns which CSV file has to the view, I enabled to use bulk insert.
