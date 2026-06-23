CREATE OR REPLACE DATABASE CACHE_DEMO_DB;

USE DATABASE CACHE_DEMO_DB;

CREATE OR REPLACE SCHEMA CACHE_TEST;

USE SCHEMA CACHE_TEST;
CREATE OR REPLACE TABLE SALES_DATA (
    ORDER_ID NUMBER,
    CUSTOMER_NAME STRING,
    PRODUCT STRING,
    AMOUNT NUMBER,
    ORDER_DATE DATE
);
INSERT INTO SALES_DATA VALUES
(1,'A','Laptop',50000,'2025-01-01'),
(2,'B','Mobile',20000,'2025-01-02'),
(3,'C','Tablet',15000,'2025-01-03'),
(4,'D','Laptop',55000,'2025-01-04'),
(5,'E','Mobile',25000,'2025-01-05');
USE WAREHOUSE COMPUTE_WH;
/* =========================================================
   TASK 1 — RESULT CACHE PRACTICAL
   Run twice and observe performance improvement
   ========================================================= */

SELECT PRODUCT, SUM(AMOUNT)
FROM SALES_DATA
GROUP BY PRODUCT;--186ms--22ms


/* Run same query again */

SELECT PRODUCT, SUM(AMOUNT)
FROM SALES_DATA
GROUP BY PRODUCT;--37ms--32ms


/* CHECK QUERY HISTORY */

SELECT QUERY_TEXT,
       START_TIME,
       TOTAL_ELAPSED_TIME,
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
ORDER BY START_TIME DESC;


/* =========================================================
   TASK 2 — METADATA CACHE PRACTICAL
   ========================================================= */

SELECT COUNT(*) FROM SALES_DATA;--27ms

SELECT COUNT(*) FROM SALES_DATA;--21ms


/* =========================================================
   TASK 3 — LOCAL DISK CACHE (WAREHOUSE CACHE)
   ========================================================= */

SELECT * FROM SALES_DATA;--52ms

SELECT * FROM SALES_DATA;--42ms


/* SUSPEND WAREHOUSE (CACHE CLEARED) */

ALTER WAREHOUSE COMPUTE_WH SUSPEND;--local disk storage drops


/* RESUME WAREHOUSE */

ALTER WAREHOUSE COMPUTE_WH RESUME;


/* RUN AGAIN */

SELECT * FROM SALES_DATA;--290ms-->37ms


/* =========================================================
   TASK 4 — CACHE INVALIDATION
   ========================================================= */

INSERT INTO SALES_DATA VALUES
(6,'F','Laptop',60000,'2025-01-06');


SELECT PRODUCT, SUM(AMOUNT)
FROM SALES_DATA
GROUP BY PRODUCT;

use role accountadmin;
show roles;

use role sysadmin;

create or replace user Jahnavi 
password='janu@1234'
default_role=AccountAdmin
default_warehouse='compute_warehouse'
must_change_password=false;
create role learning_snowflake;
create table emp(empid int,ename varchar,salary int);
insert into emp values(1001,'Jahnavi',60000),(1002,'Harika',40000),(1003,'Asrar',31000);
create role role1;
create role role2;
create or replace user user1
password='12345'
default_role=AccountAdmin
default_warehouse='compute_warehouse'
must_change_password=false;
create or replace user user2
password='janu'
default_role=AccountAdmin
default_warehouse='compute_warehouse';
grant role1 to user user1;
show tables;

--CSV FORMAT
create or replace file format csv_format 
type='CSV' field_delimiter=',' record_delimiter='\n'
skip_header=1 field_optionally_enclosed_by='"' null_if=('NULL','NULL','') empty_field_as_null=true
trim_space=true date_format='YYYY-MM-DD'
TIMESTAMP_FORMAT = 'YYYY-MM-DD HH24:MI:SS';

-- JSON FORMAT
create or replace file format json_format 
type='JSON' strip_outer_array=true
strip_null_values=false
ignore_utf8_errors=false
compression='auto';
show file formats;
desc file format json_format;
--parquet format- Columnar binary format. Highly efficient for analytics and large datasets.
CREATE OR REPLACE FILE FORMAT parquet_ff
TYPE= 'PARQUET'
SNAPPY_COMPRESSION = TRUE
BINARY_AS_TEXT = FALSE;
--Avro Binary format with schema embedded. Good for big data pipelines (Kafka, Hadoop).
CREATE OR REPLACE FILE FORMAT avro_format
TYPE = 'AVRO'
COMPRESSION = 'AUTO';


