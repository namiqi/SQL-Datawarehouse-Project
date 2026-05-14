/*
===============================================================================
Script Name: 02_load_silver_layer.sql
Description: 
    This script implements the "Silver Layer" of the Medallion Architecture.
    It performs the ETL (Extract, Transform, Load) process to move data from 
    the Bronze (Raw) layer to the Silver (Cleaned) layer.

Purpose:
    - Data Cleansing: Trims whitespace and handles null values.
    - Standardization: Normalizes codes (e.g., 'M'/'F' to 'Male'/'Female').
    - Data Integrity: Validates business logic (e.g., Sales = Price * Quantity).
    - Deduplication: Ensures unique records using ROW_NUMBER() logic.

Tables Processed:
    - silver.crm_cust_info
    - silver.crm_prd_info
    - silver.crm_sales_details
    - silver.erp_cust_az12
    - silver.erp_loc_a101
    - silver.erp_px_cat1
    - silver.erp_px_cat_g1v2

Execution:
    - Run this script after the Bronze load is complete to refresh the 
      cleaned data warehouse environment.
===============================================================================
*/
	SET NOCOUNT ON;

	PRINT '=======================================================================';
	PRINT 'STARTING SILVER LAYER REFRESH';
	PRINT '=======================================================================';

	DECLARE @StartTime DATETIME = GETDATE();

	-------------------------------------------------------------------------------
	-- 1. CRM_CUST_INFO
	-------------------------------------------------------------------------------
	PRINT '>> Truncating Table: [silver.crm_cust_info]';
	TRUNCATE TABLE silver.crm_cust_info;
	PRINT '>> Inserting Data Into: [silver.crm_cust_info]';
	INSERT INTO silver.crm_cust_info (cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date)
	SELECT cst_id, cst_key, TRIM(cst_firstname), TRIM(cst_lastname),
		CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single' WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married' ELSE 'n/a' END,
		CASE WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male' WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female' ELSE 'n/a' END,
		cst_create_date
	FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag FROM bronze.crm_cust_info WHERE cst_id IS NOT NULL) t WHERE flag = 1;
	PRINT '   (' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows affected)';

	-------------------------------------------------------------------------------
	-- 2. CRM_PRD_INFO
	-------------------------------------------------------------------------------
	PRINT '>> Truncating Table: [silver.crm_prd_info]';
	TRUNCATE TABLE silver.crm_prd_info;
	PRINT '>> Inserting Data Into: [silver.crm_prd_info]';
	INSERT INTO silver.crm_prd_info (prd_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt)
	SELECT prd_id, REPLACE(prd_key, '-', ''), TRIM(prd_nm), ISNULL(prd_cost, 0), UPPER(TRIM(prd_line)), prd_start_dt, prd_end_dt FROM bronze.crm_prd_info;
	PRINT '   (' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows affected)';

	-------------------------------------------------------------------------------
	-- 3. CRM_SALES_DETAILS
	-------------------------------------------------------------------------------
	PRINT '>> Truncating Table: [silver.crm_sales_details]';
	TRUNCATE TABLE silver.crm_sales_details;
	PRINT '>> Inserting Data Into: [silver.crm_sales_details]';
	INSERT INTO silver.crm_sales_details (sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price)
	SELECT sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt,
		CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != (sls_quantity * ABS(sls_price)) THEN sls_quantity * ABS(sls_price) ELSE sls_sales END,
		sls_quantity, CASE WHEN sls_price IS NULL OR sls_price <= 0 THEN sls_sales / NULLIF(sls_quantity, 0) ELSE ABS(sls_price) END
	FROM (SELECT sls_ord_num, sls_prd_key, sls_cust_id, sls_quantity, sls_sales, sls_price,
		CASE WHEN sls_order_dt = 0 OR LEN(CAST(sls_order_dt AS VARCHAR)) != 8 THEN NULL ELSE TRY_CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) END AS sls_order_dt,
		CASE WHEN sls_ship_dt = 0 OR LEN(CAST(sls_ship_dt AS VARCHAR)) != 8 OR TRY_CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE) < TRY_CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) THEN NULL ELSE TRY_CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE) END AS sls_ship_dt,
		CASE WHEN sls_due_dt = 0 OR LEN(CAST(sls_due_dt AS VARCHAR)) != 8 OR TRY_CAST(CAST(sls_due_dt AS VARCHAR) AS DATE) < TRY_CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) THEN NULL ELSE TRY_CAST(CAST(sls_due_dt AS VARCHAR) AS DATE) END AS sls_due_dt
		FROM bronze.crm_sales_details) t;
	PRINT '   (' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows affected)';

	-------------------------------------------------------------------------------
	-- 4. ERP_CUST_AZ12
	-------------------------------------------------------------------------------
	PRINT '>> Truncating Table: [silver.erp_cust_az12]';
	TRUNCATE TABLE silver.erp_cust_az12;
	PRINT '>> Inserting Data Into: [silver.erp_cust_az12]';
	INSERT INTO silver.erp_cust_az12 (cid, bdate, gen)
	SELECT CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid)) ELSE cid END,
		   CASE WHEN bdate > GETDATE() THEN NULL ELSE bdate END,
		   CASE WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male' WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female' ELSE 'Unknown' END
	FROM bronze.erp_cust_az12;
	PRINT '   (' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows affected)';

	-------------------------------------------------------------------------------
	-- 5. ERP_LOC_A101
	-------------------------------------------------------------------------------
	PRINT '>> Truncating Table: [silver.erp_loc_a101]';
	TRUNCATE TABLE silver.erp_loc_a101;
	PRINT '>> Inserting Data Into: [silver.erp_loc_a101]';
	INSERT INTO silver.erp_loc_a101 (cid, cntry)
	SELECT REPLACE(cid, '-', ''),
		CASE 
			WHEN TRIM(UPPER(cntry)) IN ('US', 'USA', 'UNITED STATES') THEN 'United States' 
			WHEN TRIM(UPPER(cntry)) = 'DE' THEN 'Germany' 
			WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a' 
			ELSE TRIM(cntry) 
		END
	FROM bronze.erp_loc_a101;
	PRINT '   (' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows affected)';

	-------------------------------------------------------------------------------
	-- 6. ERP_PX_CAT1
	-------------------------------------------------------------------------------
	-------------------------------------------------------------------------------
	-- 7. ERP_PX_CAT_G1V2 (Verified Correct Filename)
	-------------------------------------------------------------------------------
	PRINT '>> Truncating Table: [silver.erp_px_cat_g1v2]';
	-- The 'silver.' prefix is required here to avoid "Object Not Found" errors
	IF OBJECT_ID('silver.erp_px_cat_g1v2', 'U') IS NOT NULL 
		TRUNCATE TABLE silver.erp_px_cat_g1v2;

	PRINT '>> Inserting Data Into: [silver.erp_px_cat_g1v2]';
	INSERT INTO silver.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
	SELECT 
		TRIM(id), 
		TRIM(cat), 
		TRIM(subcat), 
		CASE 
			WHEN TRIM(UPPER(maintenance)) = 'YES' THEN 'Yes' 
			WHEN TRIM(UPPER(maintenance)) = 'NO'  THEN 'No' 
			ELSE 'n/a' 
		END 
	FROM bronze.erp_px_cat_g1v2;

	PRINT '   (' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows affected)';

	-------------------------------------------------------------------------------
	-- 7. ERP_PX_CAT_G1V2 (Corrected Name)
	-------------------------------------------------------------------------------
	PRINT '>> Truncating Table: [silver.erp_px_cat_g1v2]';
	TRUNCATE TABLE silver.erp_px_cat_g1v2;
	PRINT '>> Inserting Data Into: [silver.erp_px_cat_g1v2]';
	INSERT INTO silver.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
	SELECT TRIM(id), TRIM(cat), TRIM(subcat), 
		CASE WHEN TRIM(UPPER(maintenance)) = 'YES' THEN 'Yes' WHEN TRIM(UPPER(maintenance)) = 'NO' THEN 'No' ELSE 'n/a' END 
	FROM bronze.erp_px_cat_g1v2;
	PRINT '   (' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows affected)';

	PRINT '=======================================================================';
	PRINT 'SUCCESS: SILVER LAYER REFRESH COMPLETE';
	PRINT 'Total Duration: ' + CAST(DATEDIFF(SECOND, @StartTime, GETDATE()) AS VARCHAR) + ' seconds';
	PRINT '=======================================================================';
