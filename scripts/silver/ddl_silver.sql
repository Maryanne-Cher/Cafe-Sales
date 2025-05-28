TRUNCATE TABLE silver.dirty_cafe_sales;
DECLARE @avgDate DATETIME;

SELECT @avgDate = CAST(AVG(CAST(CAST(transaction_date AS DATETIME) AS FLOAT)) AS DATETIME)
FROM bronze.dirty_cafe_sales
WHERE transaction_date IS NOT NULL AND ISDATE(transaction_date) = 1;

INSERT INTO silver.dirty_cafe_sales (
	transaction_id,
	item,
	quantity,
	price_per_unit,
	total_spent,
	payment_method,
	location,
	transaction_date)
SELECT 
transaction_id,
item,
quantity,
price_per_unit,
total_spent,
 CASE
	WHEN payment_method IS NULL THEN 'UNKNOWN'
	WHEN payment_method = 'ERROR' THEN 'UNKNOWN'
	ELSE payment_method
END payment_method,
CASE
	WHEN location IS NULL THEN 'UNKNOWN'
	WHEN location = 'ERROR' THEN 'UNKNOWN'
	ELSE location
	END location,
CASE
        WHEN ISDATE(transaction_date) = 1 THEN CAST(transaction_date AS DATETIME)
        ELSE @avgDate
    END AS transaction_date
FROM (
select *,
ROW_NUMBER() OVER (PARTITION BY transaction_id ORDER BY transaction_date DESC) rank_num
from bronze.dirty_cafe_sales)t
WHERE rank_num = 1;
--step #2: averaging out the nulls applying this logic:
--quantity = total_spent/price_per_unit
--price_per_unit = total_spent/quantity
--total_spent = quantity * price_per_unit
WITH cleaned_data AS (
    SELECT
        transaction_id,
        CASE
            WHEN TRY_CAST(quantity AS FLOAT) IS NULL OR quantity IN ('UNKNOWN', 'ERROR')
                THEN TRY_CAST(total_spent AS FLOAT) / TRY_CAST(price_per_unit AS FLOAT)
            ELSE TRY_CAST(quantity AS FLOAT)
        END AS new_quantity,

        CASE
            WHEN TRY_CAST(price_per_unit AS FLOAT) IS NULL OR price_per_unit IN ('UNKNOWN', 'ERROR')
                THEN TRY_CAST(total_spent AS FLOAT) / TRY_CAST(quantity AS FLOAT)
            ELSE TRY_CAST(price_per_unit AS FLOAT)
        END AS new_price_per_unit,

        CASE
            WHEN TRY_CAST(total_spent AS FLOAT) IS NULL OR total_spent IN ('UNKNOWN', 'ERROR')
                THEN TRY_CAST(quantity AS FLOAT) * TRY_CAST(price_per_unit AS FLOAT)
            ELSE TRY_CAST(total_spent AS FLOAT)
        END AS new_total_spent
    FROM silver.dirty_cafe_sales
),
averages AS (
    SELECT
        AVG(new_quantity) AS avg_quantity,
        AVG(new_price_per_unit) AS avg_price_per_unit,
        AVG(new_total_spent) AS avg_total_spent
    FROM cleaned_data
)

UPDATE s
SET 
    quantity = ISNULL(cd.new_quantity, a.avg_quantity),
    price_per_unit = ISNULL(cd.new_price_per_unit, a.avg_price_per_unit),
    total_spent = ISNULL(cd.new_total_spent, a.avg_total_spent)
FROM silver.dirty_cafe_sales s
JOIN cleaned_data cd ON s.transaction_id = cd.transaction_id
CROSS JOIN averages a;



