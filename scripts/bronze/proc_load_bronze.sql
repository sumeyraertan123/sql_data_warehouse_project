/*
====================================================================
STORED PRECEDURE: LOAD BRONZE LAYER (SOURCE -> BRONZE)
====================================================================
Script Purpose:
  This stored procedure loads data into the bronze schema from external CSV files.
  It performs the following actions:
  - Truncates the bronze tables before loading data.
  - Uses the 'BULK INSERT' command to load data from csv files to bronze tables 

Parameters:
  None.
  This stored procedure does not accept any parameters or return any values.

Usage Example:
  EXEC bronze.load.bronze;
*/


CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	/* DECLARE ile değişken tanımlarsın
	normalde bu işlemler uzun sürdüğü için başlangıç ve bitiş zamanlarını 
	görmek istedim bundan dolayı değişken oluşturdum*/
	DECLARE @start_time DATETIME , @end_time DATETIME
	BEGIN TRY  -- error handling için kullanıyoruz
		PRINT '========================================';
		PRINT 'loading bronze layer';
		PRINT '========================================';

		PRINT '----------------------------------------';
		PRINT 'loading CRM tables';
		PRINT '----------------------------------------';

		SET @start_time = GETDATE(); -- değişkenleri zaman olarak atadım şimdi print ile kullanıcam
		PRINT '>> Truncating Table: bronze.crm_cust_info'
		-- full load yapmadan önce tabloyu boşaltıyoruz yoksa her çalıştırdığımızda üstüne yükler
		-- yani aslında refresh edebiliyoruz bu şekilde
		-- eğer crm'den gelen dosyada bir değişiklik varsa güncellenmi olucak tekrar çalıştırıldığında
		TRUNCATE TABLE bronze.crm_cust_info;

		PRINT '>> Insserting Data Into: bronze.crm_cust_info'
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Temp\DWH\sql_dwh\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2, -- eğer crm_cust_info bakarsan ilk satırın data değil başlık olduğunu görürsün burada diyorumki ilk satır olarak ikinci satırı al
			FIELDTERMINATOR= ',',-- bu dosyada veriler , ile ayrılmış
			TABLOCK -- tabloyu kilitliyorum
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_prd_info'
		TRUNCATE TABLE bronze.crm_prd_info;

		PRINT '>> Insserting Data Into: bronze.crm_prd_info'
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Temp\DWH\sql_dwh\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2, 
			FIELDTERMINATOR= ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_sales_details'
		TRUNCATE TABLE bronze.crm_sales_details;

		PRINT '>> Insserting Data Into: bronze.crm_sales_details'
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Temp\DWH\sql_dwh\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2, 
			FIELDTERMINATOR= ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------';

		PRINT '----------------------------------------';
		PRINT 'loading ERP tables';
		PRINT '----------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_cust_az12'
		TRUNCATE TABLE bronze.erp_cust_az12;

		PRINT '>> Insserting Data Into: bronze.erp_cust_az12'
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Temp\DWH\sql_dwh\datasets\source_erp\CUST_AZ12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_loc_a101'
		TRUNCATE TABLE bronze.erp_loc_a101;

		PRINT '>> Insserting Data Into: bronze.erp_loc_a101'
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Temp\DWH\sql_dwh\datasets\source_erp\LOC_A101.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2'
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;

		PRINT '>> Insserting Data Into: bronze.erp_px_cat_g1v2'
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Temp\DWH\sql_dwh\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------';
	END TRY
	BEGIN CATCH -- buranın içine hata bulunca ne yapacağını yazabilirsin
		PRINT '=============================================='
		PRINT 'ERROR OCCURED DURİNG LOADİND BRONZE LAYER'
		PRINT 'Error Massage' + ERROR_MESSAGE();
		PRINT 'Error Massage' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT '=============================================='
	END CATCH
END
