/*
======================================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
=======================================================================================
Script Purpose:
	This stored procedure loads data into the 'bronze' schema from external
	CSV files. It performs the following functions:
	-Truncates the bronze tables before loading data.
	-Uses the 'BULK INSERT' command to load data from csv files to bronze tables.

Parameters:
	None.
	This stored procedure does not accept any parameters or return any values.

Usage example:
EXEC bronze.load_bronze;
======================================================================================
*/
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME;
	BEGIN TRY
		SET @start_time = GETDATE();
		PRINT '==========================================';
		PRINT 'Loading Bronze Layer';
		PRINT '==========================================';

		PRINT '-----------------------------------------';
		PRINT 'Loading Table';
		PRINT '-----------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.dirty_cafe_sales';
		TRUNCATE TABLE bronze.dirty_cafe_sales

		PRINT '>> Inserting Data Into: bronze.dirty_cafe_sales';
		BULK INSERT bronze.dirty_cafe_sales
		FROM 'C:\Users\mmbesu\Desktop\_SQL projects\SQL Project #1\dirty_cafe_sales.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '*****************'
	END TRY
	BEGIN CATCH
		PRINT '============================================='
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '============================================='
	END CATCH
END
