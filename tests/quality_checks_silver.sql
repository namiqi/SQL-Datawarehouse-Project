
/* ===============================================================================
SILVER LAYER QUALITY CHECK
===============================================================================
*/

-- 1. Check for Invalid Dates (Common in CRM data)
PRINT 'Checking for invalid birthdates...';
SELECT * FROM silver.crm_cust_info 
WHERE cus_bdate > GETDATE() OR cus_bdate < '1920-01-01';

-- 2. Check for Nulls in Critical Business Columns
PRINT 'Checking for NULLs in mandatory fields...';
SELECT 'crm_cust_info' AS table_name, COUNT(*) AS null_names
FROM silver.crm_cust_info WHERE cus_firstname IS NULL;

-- 3. Check for Data Consistency (Gender mapping)
PRINT 'Verifying gender standardization...';
SELECT DISTINCT cus_gndr FROM silver.crm_cust_info; -- Should only show M, F, or n/a

-- 4. Check for Unwanted Characters or Spaces
PRINT 'Checking for un-trimmed strings...';
SELECT * FROM silver.crm_prd_info 
WHERE prd_nm != TRIM(prd_nm);
