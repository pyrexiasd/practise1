SET SESSION bronze.compression_codec = 'ZSTD';
SET SESSION silver.compression_codec = 'ZSTD';
SET SESSION gold.compression_codec = 'ZSTD';

CREATE SCHEMA IF NOT EXISTS bronze.q3_sf10;
CREATE SCHEMA IF NOT EXISTS silver.q3_sf10;
CREATE SCHEMA IF NOT EXISTS gold.q3_sf10;

CREATE TABLE IF NOT EXISTS bronze.q3_sf10.customer
WITH (format = 'PARQUET') AS
SELECT custkey, mktsegment
FROM tpch.sf10.customer;

CREATE TABLE IF NOT EXISTS bronze.q3_sf10.orders
WITH (format = 'PARQUET') AS
SELECT orderkey, custkey, orderdate, shippriority
FROM tpch.sf10.orders;

CREATE TABLE IF NOT EXISTS bronze.q3_sf10.lineitem
WITH (format = 'PARQUET') AS
SELECT orderkey, linenumber, extendedprice, discount, shipdate
FROM tpch.sf10.lineitem;

CREATE TABLE IF NOT EXISTS silver.q3_sf10.shipping_lines
WITH (format = 'PARQUET') AS
SELECT
    l.orderkey,
    l.linenumber,
    o.orderdate,
    o.shippriority,
    l.shipdate,
    l.extendedprice * (1 - l.discount) AS net_revenue
FROM bronze.q3_sf10.customer AS c
JOIN bronze.q3_sf10.orders AS o ON c.custkey = o.custkey
JOIN bronze.q3_sf10.lineitem AS l ON l.orderkey = o.orderkey
WHERE c.mktsegment = 'BUILDING'
  AND o.orderdate < DATE '1995-03-15'
  AND l.shipdate > DATE '1995-03-15';

CREATE TABLE IF NOT EXISTS gold.q3_sf10.shipping_priority
WITH (format = 'PARQUET') AS
SELECT orderkey, sum(net_revenue) AS revenue, orderdate, shippriority
FROM silver.q3_sf10.shipping_lines
GROUP BY orderkey, orderdate, shippriority
ORDER BY revenue DESC, orderdate, orderkey
LIMIT 10;
