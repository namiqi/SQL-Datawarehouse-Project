
/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the existing bronze tables to ensure a clean load.
    - Uses the 'BULK INSERT' command to load data from specified file paths.
    - Includes error handling (TRY...CATCH) and execution timing for each table.
    - Uses Dynamic SQL (EXEC) to catch file-level errors during bulk loading.

Parameters:
    None

Usage:
    EXEC bronze.load_bronze;
===============================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    -- Global tracking for the entire batch
    DECLARE @batch_start_time DATETIME = GETDATE();
    
    -- Per-table tracking variables
    DECLARE @start_time DATETIME;
    DECLARE @end_time DATETIME;

    BEGIN TRY
        PRINT '=======================================================================';
        PRINT 'Loading Bronze Layer';
        PRINT '=======================================================================';
        PRINT '-----------------------------------------------------------------------';
        PRINT 'Batch Start: ' + CONVERT(VARCHAR, @batch_start_time, 121);
        PRINT '-----------------------------------------------------------------------';

        -- =============================================================================
        -- 1. LOADING CRM TABLES
        -- =============================================================================
        PRINT '-----------------------------------------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '-----------------------------------------------------------------------';

        -- crm_cust_info
        SET @start_time = GETDATE();
        BEGIN TRY
            PRINT '>> Loading: [bronze].[crm_cust_info]';
            PRINT '   Start Time: ' + CONVERT(VARCHAR, @start_time, 108);
            TRUNCATE TABLE bronze.crm_cust_info;
            EXEC('BULK INSERT bronze.crm_cust_info 
                  FROM ''C:\Users\namiq\Desktop\DataWarehouse\sql-data-warehouse-project\datasets\source_crm\cust_info.csv''
                  WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', TABLOCK);');
            SET @end_time = GETDATE();
            PRINT '   End Time:   ' + CONVERT(VARCHAR, @end_time, 108);
            PRINT '>> Success: [bronze].[crm_cust_info] | Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';
        END TRY
        BEGIN CATCH
            PRINT '!! ERROR loading [bronze].[crm_cust_info]: ' + ERROR_MESSAGE();
        END CATCH

        -- crm_prd_info
        SET @start_time = GETDATE();
        BEGIN TRY
            PRINT '>> Loading: [bronze].[crm_prd_info]';
            PRINT '   Start Time: ' + CONVERT(VARCHAR, @start_time, 108);
            TRUNCATE TABLE bronze.crm_prd_info;
            EXEC('BULK INSERT bronze.crm_prd_info 
                  FROM ''C:\Users\namiq\Desktop\DataWarehouse\sql-data-warehouse-project\datasets\source_crm\prd_info.csv''
                  WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', TABLOCK);');
            SET @end_time = GETDATE();
            PRINT '   End Time:   ' + CONVERT(VARCHAR, @end_time, 108);
            PRINT '>> Success: [bronze].[crm_prd_info] | Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';
        END TRY
        BEGIN CATCH
            PRINT '!! ERROR loading [bronze].[crm_prd_info]: ' + ERROR_MESSAGE();
        END CATCH

        -- crm_sales_details
        SET @start_time = GETDATE();
        BEGIN TRY
            PRINT '>> Loading: [bronze].[crm_sales_details]';
            PRINT '   Start Time: ' + CONVERT(VARCHAR, @start_time, 108);
            TRUNCATE TABLE bronze.crm_sales_details;
            EXEC('BULK INSERT bronze.crm_sales_details 
                  FROM ''C:\Users\namiq\Desktop\DataWarehouse\sql-data-warehouse-project\datasets\source_crm\sales_details.csv''
                  WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', TABLOCK);');
            SET @end_time = GETDATE();
            PRINT '   End Time:   ' + CONVERT(VARCHAR, @end_time, 108);
            PRINT '>> Success: [bronze].[crm_sales_details] | Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';
        END TRY
        BEGIN CATCH
            PRINT '!! ERROR loading [bronze].[crm_sales_details]: ' + ERROR_MESSAGE();
        END CATCH

        -- =============================================================================
        -- 2. LOADING ERP TABLES
        -- =============================================================================
        PRINT '-----------------------------------------------------------------------';
        PRINT 'Loading ERP Tables';
        PRINT '-----------------------------------------------------------------------';

        -- erp_cust_az12
        SET @start_time = GETDATE();
        BEGIN TRY
            PRINT '>> Loading: [bronze].[erp_cust_az12]';
            PRINT '   Start Time: ' + CONVERT(VARCHAR, @start_time, 108);
            TRUNCATE TABLE bronze.erp_cust_az12;
            EXEC('BULK INSERT bronze.erp_cust_az12 
                  FROM ''C:\Users\namiq\Desktop\DataWarehouse\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv''
                  WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', TABLOCK);');
            SET @end_time = GETDATE();
            PRINT '   End Time:   ' + CONVERT(VARCHAR, @end_time, 108);
            PRINT '>> Success: [bronze].[erp_cust_az12] | Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';
        END TRY
        BEGIN CATCH
            PRINT '!! ERROR loading [bronze].[erp_cust_az12]: ' + ERROR_MESSAGE();
        END CATCH

        -- erp_loc_a101
        SET @start_time = GETDATE();
        BEGIN TRY
            PRINT '>> Loading: [bronze].[erp_loc_a101]';
            PRINT '   Start Time: ' + CONVERT(VARCHAR, @start_time, 108);
            TRUNCATE TABLE bronze.erp_loc_a101;
            EXEC('BULK INSERT bronze.erp_loc_a101 
                  FROM ''C:\Users\namiq\Desktop\DataWarehouse\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv''
                  WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', TABLOCK);');
            SET @end_time = GETDATE();
            PRINT '   End Time:   ' + CONVERT(VARCHAR, @end_time, 108);
            PRINT '>> Success: [bronze].[erp_loc_a101] | Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';
        END TRY
        BEGIN CATCH
            PRINT '!! ERROR loading [bronze].[erp_loc_a101]: ' + ERROR_MESSAGE();
        END CATCH

        -- erp_px_cat_g1v2
        SET @start_time = GETDATE();
        BEGIN TRY
            PRINT '>> Loading: [bronze].[erp_px_cat_g1v2]';
            PRINT '   Start Time: ' + CONVERT(VARCHAR, @start_time, 108);
            TRUNCATE TABLE bronze.erp_px_cat_g1v2;
            EXEC('BULK INSERT bronze.erp_px_cat_g1v2 
                  FROM ''C:\Users\namiq\Desktop\DataWarehouse\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv''
                  WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', TABLOCK);');
            SET @end_time = GETDATE();
            PRINT '   End Time:   ' + CONVERT(VARCHAR, @end_time, 108);
            PRINT '>> Success: [bronze].[erp_px_cat_g1v2] | Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';
        END TRY
        BEGIN CATCH
            PRINT '!! ERROR loading [bronze].[erp_px_cat_g1v2]: ' + ERROR_MESSAGE();
        END CATCH

        PRINT '=======================================================================';
        PRINT 'Bronze Layer Load Process Finished';
        PRINT 'Total Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, GETDATE()) AS VARCHAR) + ' seconds';
        PRINT '=======================================================================';

    END TRY
    BEGIN CATCH
        PRINT 'CRITICAL ERROR: The main procedure failed logic.';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
    END CATCH
END;
