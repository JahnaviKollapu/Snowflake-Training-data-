CREATE OR REPLACE TABLE PRODUCT(PID INT,PNAME STRING, CATEGORY STRING,BRAND STRING);
CREATE OR REPLACE TABLE CUSTOMER(CID INT,CNAME STRING,CITY STRING,COUNTRY STRING);
CREATE OR REPLACE TABLE SALES(SID INT,PID INT,CID INT,SALE_DATE DATE,QUANTITY INT,SALES_AMOUNT DECIMAL(10,2));
INSERT INTO PRODUCT VALUES(1,'Laptop','Electronics','Dell'),(2,'Mobile','Electronics','Samsung'),(3,'Mouse','Accessories','LG'),(4,'Keyboard','Accessories','HP'),(5,'Monitor','Electronics','LG');
INSERT INTO CUSTOMER VALUES(101,'Ravi','Hyderabad','India'),(102,'Sita','Chennai','India'),(103,'John','New York','USA'),(104,'Amit','Mumbai','India'),(105,'Sara','London','UK');
INSERT INTO SALES VALUES(1,1,101,'2025-05-01',1,55000),(2,2,102,'2025-05-03',2,40000),(3,3,101,'2025-05-05',3,1500),(4,4,103,'2025-06-10',1,2000),
(5,5,104,'2025-06-15',2,30000),(6,1,105,'2025-07-01',1,56000),(7,2,101,'2025-07-05',1,20000),(8,3,102,'2025-05-20',5,2500);
SHOW TABLES;
SELECT SUM(SALES_AMOUNT) AS TOTAL_SALES FROM SALES;
SELECT SUM(QUANTITY) FROM SALES;
SELECT ROUND(AVG(SALES_AMOUNT),2) AS AVG FROM SALES;
SELECT * FROM SALES WHERE SALE_DATE BETWEEN '2025-05-01' AND '2025-05-31';
SELECT * FROM SALES WHERE MONTH(SALE_DATE)='05'AND YEAR(SALE_DATE)='2025';
SELECT * FROM SALES WHERE SALES_AMOUNT>20000;
SELECT * FROM CUSTOMER WHERE COUNTRY= 'India';
SELECT SUM(s.SALES_AMOUNT),p.category from sales s join product p on s.pid=p.pid group by p.category;
SELECT SUM(s.SALES_AMOUNT),p.pname from sales s join product p on s.pid=p.pid group by p.pname;
SELECT SUM(SALES_AMOUNT),month(sale_date) from sales group by month(sale_date);
SELECT p.category,SUM(s.quantity) AS TotalQuantitySold 
FROM Product p JOIN sales s ON p.PID = s.PID GROUP BY p.category ORDER BY TotalQuantitySold DESC LIMIT 1;
-- 1. Identify Fact table.SALES TABLE 

-- 2. Identify Dimension tables. PRODUCT,CUSTOMER TABLE

-- 3. Why sales_amount belongs to fact table? BECAUSE ITS A QUANTITATIVE MEASURE




CREATE OR REPLACE DATABASE INTRO_DW_DB;
USE DATABASE INTRO_DW_DB;
CREATE OR REPLACE SCHEMA SALES;
CREATE OR REPLACE TABLE SALES.DIM_PRODUCT (
    PRODUCT_ID INT,
    PRODUCT_NAME STRING,
    CATEGORY STRING
);
CREATE OR REPLACE TABLE SALES.DIM_CUSTOMER (
    CUSTOMER_ID INT,
    CUSTOMER_NAME STRING,
    CITY STRING
);
CREATE OR REPLACE TABLE SALES.FACT_SALES (
    SALE_ID INT,
    PRODUCT_ID INT,
    CUSTOMER_ID INT,
    SALE_DATE DATE,
    QUANTITY INT,
    TOTAL_AMOUNT NUMBER(10,2)
);
INSERT INTO SALES.DIM_PRODUCT VALUES
(1,'Laptop','Electronics'),
(2,'Mobile','Electronics'),
(3,'Chair','Furniture');

INSERT INTO SALES.DIM_CUSTOMER VALUES
(1,'Ravi','Hyderabad'),
(2,'John','New York'),
(3,'Sita','Chennai');

INSERT INTO SALES.FACT_SALES VALUES
(101,1,1,CURRENT_DATE,2,120000),
(102,2,2,CURRENT_DATE,1,30000),
(103,3,3,CURRENT_DATE,5,15000);

select p.product_name,c.customer_name,f.total_amount from sales.fact_sales f join sales.dim_product p on f.product_id=p.product_id join sales.dim_customer c on f.customer_id=c.customer_id;
--ETL
create or replace table sales.daily_revenue as select sale_date,sum(total_amount) as total_revenue from sales.fact_sales group by sale_date;
--json and semi-structtured data
create or replace table sales.json_orders(data variant);
insert into sales.json_orders select parse_json('{
"order_id" :1001,
"customer":{"name":"Ravi","city":"Hyderabad"},
"items":[{"product":"Laptop","price":60000},{"product":"mouse","price":1000}]}');
select data:order_id::int as order_id,data:customer.name::string as customer_name,data:customer.city::string as city from sales.json_orders;
--flatten json array
select data:order_id::int as order_id,
item.value:product::string as product,item.value:price::number as price from sales.json_orders,lateral flatten(input=>data:items) item;