create database json_db;
create schema json_schema;
create table json_table(col variant);
SELECT * FROM JSON_TABLE;
select col:id::number as id,col:type::string as type,
col:name::string as name,
col:ppu::string  as price,
B.value:id::string as batter_id,
B.value:type::string as batter_type,
T.value:id::string as topping_id,
T.value:type::string as topping_type
from json_table,
lateral flatten(input=> col:batters:batter) B,
lateral flatten(input=> col:topping) T;
show tables;
use snowflake_learning_db;
select * from sales_data;
select current_timestamp;
update sales_data set amount=900 where id=3;
update sales_data set amount=900 where id=1;
delete from sales_data where id=3;
select * from sales_data;
select * from sales_data at (timestamp=> '2026-03-11 08:43:54'::timestamp with local time zone);//original data before updation 
select * from sales_data at (offset=> -600);//ten minutes ago
select * from sales_data;
insert into sales_data 
select * from sales_data at(offset=>-600)
where id=3;

select * from sales;//deleted record is added as the latest row

select * from sales_data;
create or replace table clone_sales clone sales_data at
(offset=>-300);
create or replace schema cache_test_clone clone cache_test;
use schema cache_test_clone;
show schemas;
select * from clone_sales;
update cache_test_clone.clone_sales set amount=amount+1000 where order_id=3;
insert into cache_test_clone.clone_sales values(10,'Kenny','laptop',40000,'2026-02-19');
--activity
drop schema cache_test_clone;
create or replace schema SNOWFLAKE_LEARNING_DB.prod_schema;
use schema prod_schema;
create or replace table products(
product_id int,product_name string,price float,category string);
CREATE OR REPLACE TABLE customers (customer_id INT,name STRING,email STRING,city STRING
);
INSERT INTO products VALUES 
(1, 'Laptop',  999.99, 'Electronics'),
(2, 'Phone',   699.99, 'Electronics'),
(3, 'Desk',    299.99, 'Furniture');
INSERT INTO customers VALUES 
(1, 'Alice', 'alice@email.com', 'NYC'),
(2, 'Bob',   'bob@email.com',   'LA'),
(3, 'Carol', 'carol@email.com', 'Chicago');
create or replace view elec_view as 
select * from products where category='Electronics';
create or replace schema SNOWFLAKE_LEARNING_DB.dev_schema clone SNOWFLAKE_LEARNING_DB.prod_schema;
use schema SNOWFLAKE_LEARNING_DB.dev_schema;
show tables;
show views;
select * from products;
select * from customers;
select * from elec_view;
update dev_schema.products set price=0.01 where product_id=1;
INSERT INTO dev_schema.customers VALUES (4, 'Dave', 'dave@email.com', 'Boston');
SELECT * FROM prod_schema.products;  
SELECT * FROM prod_schema.customers;
SELECT * FROM dev_schema.products;   -- Laptop now 0.01
SELECT * FROM dev_schema.customers; 
CREATE OR REPLACE TABLE dev_schema.products_backup 
CLONE prod_schema.products
AT (OFFSET => -300);  -- Clone as it was 5 minutes ago
SELECT * FROM dev_schema.products_backup;



