/*
========================================================================================
Stored Procedure : Load bronze layer (source - > bronze)
========================================================================================
Script purpose :
This stored procedure loads into the 'bronze' schema from external csv files.
It performs the following actions:
-Truncates the bronze tables before loading data.
- Uses the "BULK INSERT' command to load data from csv files to bronze tables.

Parameters:
None.
This stored procedure does not accept any parameters or return any values.

usage Example :
    EXEC bronze.load-bronze;
=========================================================================================
*/


create  or alter  procedure bronze.load_bronze as
	begin
	declare @start_time datetime, @end_time datetime , @batch_start_time datetime , @batch_end_time datetime
		 
	begin try
		set  @batch_start_time = getdate();
	 print '=============================================='
	 print 'Loading Bronze Layer ';
	 print '=============================================='


	 print '-----------------------------------------------'
	 print 'Loading CRM Tables';
	 print '-----------------------------------------------';


	 set @start_time = GETDATE();
	
		print '>> Truncating Table : bronze.crm_cust_info '
	truncate table Bronze.crm_cust_info

		print '>> Insering Data Into : bronze.crm_cust_info'
			bulk insert Bronze.crm_cust_info
			from 'C:\Users\omyuv\Downloads\sql-data-warehouse-project (1)\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
			with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
			);
	set @end_time = GETDATE();
		print '>> Load duration : ' + cast(datediff(second, @start_time,@end_time) as nvarchar) +'seconds' ;
		print '>> --------------';

		--select  count (*)from Bronze.crm_cust_info


	set @start_time = GETDATE();
		print '>> Load duration : ' + cast(datediff(second, @start_time,@end_time) as nvarchar) +' seconds' ;
		print '>> --------------';

	--set @start_time = getdate ();
		print '>>Truncating Table: bronze.crm_prd_info';
	truncate table Bronze.crm_prd_info

		print'>> Inserting Data Into :Bronze.crm_prd_info';
			bulk insert Bronze.crm_prd_info
			from 'C:\Users\omyuv\Downloads\sql-data-warehouse-project (1)\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
			with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
			);
	set @end_time = GETDATE();
		print '>> Load duration : ' + cast(datediff(second, @start_time,@end_time) as nvarchar) +' seconds' ;
		print '>> --------------';

		--select  count (*)from Bronze.crm_prd_info


	set @start_time = GETDATE();
		 print '>> Truncating Table : crm_sales_details';
	truncate table Bronze.crm_sales_details

	 print '>> Insering Data : crm_sales_details';
			bulk insert Bronze.crm_sales_details
			from 'C:\Users\omyuv\Downloads\sql-data-warehouse-project (1)\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
			with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
			)

	set @end_time = GETDATE();
		print '>> Load duration : ' + cast(datediff(second, @start_time,@end_time) as nvarchar) +' seconds' ;
		print '>> --------------';



		--select  count (*)from Bronze.crm_sales_details

	set @start_time = GETDATE();
		 print '>> Truncating Table : Bronze.erp_cust_az12'
	truncate table Bronze.erp_cust_az12
		 print '>> Insering Data :Bronze.erp_cust_az12'
				bulk insert  Bronze.erp_cust_az12
				from 'C:\Users\omyuv\Downloads\sql-data-warehouse-project (1)\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
				with (
				firstrow = 2 ,
				fieldterminator = ',',
				tablock
				)
	set @end_time = GETDATE();
		print '>> Load duration : ' + cast(datediff(second, @start_time,@end_time) as nvarchar) +' seconds' ;
		print '>> --------------';


		--select count (*) from  Bronze.erp_cust_az12

	set @start_time = GETDATE();
		 print '>> Truncating Table :Bronze.erp_loc_a101 '
	truncate table Bronze.erp_loc_a101
		 print '>> Insering Data :Bronze.erp_loc_a101'
			bulk insert  Bronze.erp_loc_a101
			from 'C:\Users\omyuv\Downloads\sql-data-warehouse-project (1)\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
			with (
			firstrow = 2 ,
			fieldterminator = ',',
			tablock
			)
	set @end_time = GETDATE();
		print '>> Load duration : ' + cast(datediff(second, @start_time,@end_time) as nvarchar) +' seconds' ;
		print '>> --------------';
		--select count (*) from  Bronze.erp_loc_a101


	set @start_time = GETDATE();
		 print '>> Truncating Table :Bronze.erp_px_cat_g1v2'
	truncate table Bronze.erp_px_cat_g1v2
		print '>> Insering Data :Bronze.erp_px_cat_g1v2'
			bulk insert  Bronze.erp_px_cat_g1v2
			from 'C:\Users\omyuv\Downloads\sql-data-warehouse-project (1)\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
			with (
			firstrow = 2 ,
			fieldterminator = ',',
			tablock
			);
	set @end_time = GETDATE();
		print '>> Load duration : ' + cast(datediff(second, @start_time,@end_time) as nvarchar) +' seconds' ;
		print '>> --------------';

	--  select count (*) from  Bronze.erp_px_cat_g1v2

	set @batch_end_time = GETDATE();
	print '================================'
	print 'Loading bronze layer is completed';
	print ' -  total load duration ' + cast(datediff(second,@batch_start_time,@batch_end_time) as nvarchar ) + 'seconds';
	print '================================'

	end try 
	begin catch
	print '======================================'
	print 'Error Occurred during Loading bronze layer '
	print 'Error Message '+ error_message ();
	print 'error Message ' + cast (error_number() as nvarchar);
	print 'error Message ' + cast (error_state() as nvarchar);
	print '======================================'
	end catch

	end
