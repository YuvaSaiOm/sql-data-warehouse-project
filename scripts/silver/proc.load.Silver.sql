

CREATE OR ALTER PROCEDURE Silver.load_silver
AS
BEGIN
   declare @start_time datetime, @end_time datetime , @batch_start_time datetime , @batch_end_time datetime
		begin try 
        			set  @batch_start_time = getdate();

     print '=============================================='
	 print 'Loading Silver  Layer ';
	 print '=============================================='


	 print '-----------------------------------------------'
	 print 'Loading CRM Tables';
	 print '-----------------------------------------------';

 set @start_time = GETDATE();


    PRINT '>> Truncating Table: silver.crm_cust_info';
    TRUNCATE TABLE silver.crm_cust_info;

    PRINT '>> Inserting Data Into: silver.crm_cust_info';
    INSERT INTO silver.crm_cust_info (
        cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_marital_status,
        cst_gndr,
        cst_create_date
    )
    SELECT
        cst_id,
        cst_key,
        TRIM(cst_firstname) AS cst_firstname,
        TRIM(cst_lastname) AS cst_lastname,
        CASE
            WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
            WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
            ELSE 'n/a'
        END AS cst_marital_status,
        CASE
            WHEN UPPER(TRIM(cst_gnder)) = 'F' THEN 'Female'
            WHEN UPPER(TRIM(cst_gnder)) = 'M' THEN 'Male'
            ELSE 'n/a'
        END AS cst_gndr,
        cst_create_date
    FROM (
        SELECT
            *,
            ROW_NUMBER() OVER (
                PARTITION BY cst_id
                ORDER BY cst_create_date DESC
            ) AS flag_last
        FROM bronze.crm_cust_info
        WHERE cst_id IS NOT NULL
    ) t
    WHERE flag_last = 1;
 set @end_time = getdate();
print '>> Load duration : ' + cast(datediff(second, @start_time,@end_time) as nvarchar) +'seconds' ;
print '>>-----------------';

 set @start_time = GETDATE();
  PRINT '>> Truncating Table: silver.crm_prd_info';
  TRUNCATE TABLE silver.crm_prd_info;
    PRINT '>> Inserting Data Into: silver.crm_prd_info'
    INSERT INTO silver.crm_prd_info (
        prd_id,
        prd_key,
        cat_id,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt
    )
    SELECT
        prd_id,
                -- cat_id
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
             -- prd_key
      SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,

        prd_nm,

        ISNULL(prd_cost, 0) AS prd_cost,

        CASE
            WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
            WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
            WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
            WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
            ELSE 'n/a'
        END AS prd_line,

        CAST(prd_start_dt AS DATE) AS prd_start_dt,

        CAST(
            LEAD(prd_start_dt) OVER (
                PARTITION BY prd_key
                ORDER BY prd_start_dt
            ) - 1
            AS DATE
        ) AS prd_end_dt

    FROM bronze.crm_prd_info;
    set @end_time = getdate();
print '>> Load duration : ' + cast(datediff(second, @start_time,@end_time) as nvarchar) +'seconds' ;
print'>>----------------'

set @start_time = GETDATE()
    PRINT '>> Truncating Table: silver.crm_sales_details';
    TRUNCATE TABLE silver.crm_sales_details 
     PRINT '>> Inserting Data Into: silver.erp_cust_az12';
    INSERT INTO  silver.crm_sales_details   (
sls_ord_num,	
sls_prd_key ,
sls_cust_id ,
sls_order_dt  ,
sls_ship_dt  ,
sls_due_dt  ,
sls_sales  ,
sls_quantity   ,
sls_price    
)
 select 
 sls_ord_num,
 sls_prd_key,
 sls_cust_id,

  case 
    WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
    ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
END AS sls_order_dt ,

 case 
    WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
    ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
END AS sls_ship_dt,

CASE
    WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
    ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
END AS sls_due_dt,

CASE
    WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
    THEN sls_quantity * ABS(sls_price)
    ELSE sls_sales
END AS sls_sales,

sls_quantity,

CASE
    WHEN sls_price IS NULL OR sls_price <= 0
        THEN sls_sales / NULLIF(sls_quantity, 0)
    ELSE sls_price
END AS sls_price
FROM bronze.crm_sales_details;
SET @end_time = GETDATE();
PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
PRINT '>> Load Duration: ';


--Loading  silver.erp_cust_az12
 set @start_time = GETDATE();
  PRINT '>> T runcating Table: silver.erp_cust_az12';
  TRUNCATE TABLE silver.erp_cust_az12;
    PRINT '>> Inserting Data Into: silver.erp_cust_az12';
    INSERT INTO silver.erp_cust_az12 (
        cid,
        bdate,
        gen
    )
    SELECT
        CASE
            WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
            ELSE cid
        END AS cid,

        CASE
            WHEN bdate > GETDATE() THEN NULL
            ELSE bdate
        END AS bdate,

        CASE
            WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
            WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
            ELSE 'n/a'
        END AS gen

    FROM bronze.erp_cust_az12;
    set @end_time = GETDATE();
print '>> Load duration : ' + cast(datediff(second, @start_time,@end_time) as nvarchar) +'seconds' ;
print'>>----------------'

print '------------------------------------------------------------------------';
print 'Loading ERP Tables';
print '------------------------------------------------------------------------';


set @start_time =  getdate();
    PRINT '>> Truncating Table: silver.erp_loc_a101';
    TRUNCATE TABLE silver.erp_loc_a101;

    PRINT '>> Inserting Data Into: silver.erp_loc_a101';

    INSERT INTO silver.erp_loc_a101 (
        cid,
        cntry
    )
    SELECT
        REPLACE(cid, '-', '') AS cid,
        CASE
            WHEN TRIM(cntry) = 'DE' THEN 'Germany'
            WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
            WHEN TRIM(cntry) = ''
                 OR cntry IS NULL THEN 'n/a'
            ELSE TRIM(cntry)
        END AS cntry
    FROM bronze.erp_loc_a101;
    set @end_time = getdate();
    print '>> Load duration : ' + cast(datediff(second, @start_time,@end_time) as nvarchar) +'seconds' ;
    print '>>----------------';

set @start_time = GETDATE();
    PRINT '>> Truncating Table: silver.erp_px_cat_g1v2';
    TRUNCATE TABLE silver.erp_px_cat_g1v2;
    PRINT '>> Inserting Data Into: silver.erp_px_cat_g1v2';
    INSERT INTO silver.erp_px_cat_g1v2 (
        id,
        cat,
        subcat,
        maintenance
    )
    SELECT
        id,
        cat,
        subcat,
        maintenance
    FROM bronze.erp_px_cat_g1v2;
   
SET @end_time = GETDATE();
PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
PRINT '>> ----------------';

SET @batch_end_time = GETDATE();
PRINT '==============================================';
PRINT 'Loading Silver Layer is Completed';
PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
PRINT '==============================================';

END TRY
BEGIN CATCH
    PRINT '==============================================';
    PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
    PRINT 'Error Message' + ERROR_MESSAGE();
    PRINT 'Error Number' + CAST(ERROR_NUMBER() AS NVARCHAR);
    PRINT 'Error Message' + CAST(ERROR_STATE() AS NVARCHAR);
    PRINT '==============================================';
END CATCH
END

