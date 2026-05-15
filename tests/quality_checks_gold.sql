
/* ===============================================================================
GOLD LAYER QUALITY CHECK
===============================================================================
*/

-- 1. Referential Integrity (The "Lookup" Test)
-- Check if any sales records failed to find a matching customer or product
PRINT 'Checking for broken links between Fact and Dimensions...';
SELECT 
    COUNT(*) AS total_sales,
    SUM(CASE WHEN customer_key IS NULL THEN 1 ELSE 0 END) AS orphaned_customers,
    SUM(CASE WHEN product_key IS NULL THEN 1 ELSE 0 END) AS orphaned_products
FROM gold.fact_sales;

-- 2. Star Schema Uniqueness
-- Every Dimension Key must be unique
PRINT 'Checking for duplicate Surrogate Keys...';
SELECT customer_key, COUNT(*) 
FROM gold.dim_customers 
GROUP BY customer_key 
HAVING COUNT(*) > 1;

-- 3. Business Math Validation
-- Checking if Sales = Quantity * Price
PRINT 'Checking for calculation errors in Fact table...';
SELECT * FROM gold.fact_sales 
WHERE sales_amount != (quantity * price);

-- 4. Hierarchy Completeness
-- Ensure all products have a category (No "Unknown" categories)
PRINT 'Checking for products missing category information...';
SELECT * FROM gold.dim_products 
WHERE category IS NULL OR subcategory IS NULL;
