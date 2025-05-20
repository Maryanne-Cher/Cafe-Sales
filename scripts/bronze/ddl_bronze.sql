/*
================================================================
DDL Script: Create Bronze Tables
================================================================
Script Purpose:
  This script creates tables in the 'bronze' schema, dropping
  existing tables if they already exist.
================================================================
/*


IF OBJECT_ID ('bronze.dirty_cafe_sales', 'U') IS NOT NULL
DROP TABLE bronze.dirty_cafe_sales;
GO

CREATE TABLE bronze.dirty_cafe_sales (
transaction_id NVARCHAR(50),
item NVARCHAR(50),
quantity NVARCHAR(50),
price_per_unit NVARCHAR(50),
total_spent NVARCHAR(50),
payment_method NVARCHAR(50),
location NVARCHAR(50),
transaction_date NVARCHAR(50)
);

