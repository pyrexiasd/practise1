SHOW TABLES IN bronze.q3_sf10;

SELECT custkey, mktsegment
FROM bronze.q3_sf10.customer
ORDER BY custkey
LIMIT 5;

SELECT 'bronze.q3_sf10.customer' AS table_name, count(*) AS rows
FROM bronze.q3_sf10.customer;
