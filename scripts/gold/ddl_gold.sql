/*
===============================================================================
GOLD LAYER DEFINITION
Description: 
    This script creates the final business-level views for the Data Warehouse.
    - dim_customers: Integrated CRM & ERP customer data.
    - dim_products: Integrated Product & Category data with naming fixes.
    - fact_sales: Transactional sales with surrogate key lookups.
===============================================================================
*/

-- =============================================================================
-- 1. Create gold.dim_customers
-- =============================================================================
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY c.cus_id) AS customer_key,
    c.cus_id          AS customer_id,
    c.cus_key         AS customer_number,
    c.cus_firstname   AS first_name,
    c.cus_lastname    AS last_name,
    la.cntry          AS country,
    c.cus_marital_sts AS marital_status,
    c.cus_gndr        AS gender,
    c.cus_bdate       AS birthdate,
    c.dwh_create_date AS create_date
FROM silver.crm_cust_info c
LEFT JOIN silver.erp_loc_a1v2 la 
    ON c.cus_key = la.id;
GO

-- =============================================================================
-- 2. Create gold.dim_products
-- =============================================================================
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER (ORDER BY pn.prd_id) AS product_key,
    pn.prd_id          AS product_id,
    pn.prd_key         AS product_number,
    pn.prd_nm          AS product_name,
    pn.cat_id          AS category_id,
    pc.cat             AS category,
    pc.subcat          AS subcategory,
    pc.maintenance     AS maintenance,
    pn.prd_cost        AS product_cost,
    pn.prd_line        AS product_line,
    pn.prd_start_dt    AS start_date
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc 
    -- Fix: Replacing hyphen with underscore to bridge CRM and ERP formats
    ON REPLACE(pn.cat_id, '-', '_') = pc.id 
WHERE pn.prd_end_dt IS NULL;
GO

-- =============================================================================
-- 3. Create gold.fact_sales
-- =============================================================================
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT
    sd.sls_ord_num       AS order_number,
    sd.sls_order_dt      AS order_date,
    sd.sls_ship_dt       AS shipping_date,
    sd.sls_due_dt        AS due_date,
    cus.customer_key,    -- Data Lookup
    prd.product_key,     -- Data Lookup
    sd.sls_sales         AS sales_amount,
    sd.sls_quantity      AS quantity,
    sd.sls_price         AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_customers cus
    ON  sd.sls_cust_id = cus.customer_id
LEFT JOIN gold.dim_products prd
    ON  sd.sls_prd_key = prd.product_number;
GO
