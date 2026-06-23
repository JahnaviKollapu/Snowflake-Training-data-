alter warehouse compute_wh suspend;
use database snowflake_learning_db;
create table sales_tt(id int,amount number);
INSERT INTO sales_tt VALUES (1,1000),(2,2000);
update sales_tt set amount =3000 where id =1;
select * from sales_tt;
select * from sales_tt at (offset=>-30);
drop table sales_tt;
undrop table sales_tt;
select * from sales_tt;
--permanent table
create table perm_table(id int);
insert into perm_table values(1);
--transient table
create transient table trans_table(id int);
insert into trans_table values(1);
create temp table temp_table(id int);
insert into temp_table values(1);
select * from temp_table;
show tables;
select * from sales_tt;
create materialized view mv_sales as 
select id,sum(amount)as total_amount from sales_tt group by id;
select id,sum(amount)as total_amount from sales_tt group by id;
select * from mv_sales;
-- materialized view:Stores data, faster reads, requires storage, needs refreshing.
-- Standard View: Stores only the SQL query, virtual, always shows real-time data, no storage cost.
show warehouses;
alter warehouse compute_wh suspend;

show tables;
show storage integrations;
