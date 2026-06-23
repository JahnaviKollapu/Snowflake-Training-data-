use snowflake_learning_db;
--time travel 
create or replace table student_sales(id int,name string,amount number);
insert into student_sales values(1, 'Jahnavi', 1000),
(2, 'Rahul', 1500),(3, 'Sneha', 2000),(4, 'Arjun', 2500),(5, 'Meena', 3000);
delete from student_sales where id in (3,5);
select * from student_sales;
select * from student_sales at (offset =>-60);//60 seconds ago
insert into student_sales select * from student_sales at 
(offset =>-150) where id in (3,5); //restoring deleted data

--zero copy cloning
create or replace table sales_data as select seq4() as id,
'product ' || seq4() as product, uniform(100,500,random()) as
amount from table(generator(rowcount=>10)); --generates 10 rows with random values from 100 to 500
create or replace table sales_clone clone sales_data;
select * from sales_clone;
update sales_clone set amount=499 where id in (1,2);
select * from sales_data;
--streams and cdc:
create or replace table orders(oid int, customer string,amount number);
create or replace stream orders_stream on table orders;
insert into orders values(1,'jahnavi',1000);
update orders set amount=1200 where oid=1;
select * from orders_stream;
create or replace table orders_history like orders;
create or replace task move_orders_task warehouse=compute_wh
schedule='1 minute' as 
insert into orders_history select oid,customer,amount from orders_stream;
alter task move_orders_task resume;
alter task move_orders_task suspend;
alter warehouse compute_wh suspend;
show warehouses;
select * from orders_history;

--virtual warehouse scaling
create or replace table large_table as select seq4() as id,uniform(1,1000,random()) as amount from table(generator(rowcount=>50000));

select * from large_table limit 20;
alter warehouse compute_wh set warehouse_size='small';
select sum(amount),count(*) from large_table group by amount;--320ms
alter warehouse compute_wh set warehouse_size='medium';
select sum(amount),count(*) from large_table group by amount;--24ms
alter warehouse compute_wh suspend;
alter warehouse compute_wh set warehouse_size='x-small';
show warehouses;
--secure views and RBAC
create or replace table customer_data(id int,name string,email string,city string);
INSERT INTO customer_data (id, name, email, city) VALUES
(1, 'Aarav Sharma', 'aarav.sharma@gmail.com', 'Mumbai'),
(2, 'Diya Reddy', 'diya.reddy@yahoo.com', 'Hyderabad'),
(3, 'Arjun Verma', 'arjun.verma@outlook.com', 'Delhi'),
(4, 'Meera Iyer', 'meera.iyer@gmail.com', 'Chennai'),
(5, 'Rohan Gupta', 'rohan.gupta@gmail.com', 'Bangalore'),
(6, 'Sneha Kapoor', 'sneha.kapoor@yahoo.com', 'Kolkata'),
(7, 'Vikram Singh', 'vikram.singh@outlook.com', 'Pune'),
(8, 'Ananya Das', 'ananya.das@gmail.com', 'Ahmedabad'),
(9, 'Kiran Patel', 'kiran.patel@yahoo.com', 'Surat'),
(10, 'Priya Nair', 'priya.nair@outlook.com', 'Kochi');
use role securityadmin;
grant create view on schema public to role sysadmin;
select current_user();
create or replace secure view cust_public_view as 
select id,name,city from customer_data;
create role analyst_role;
grant role analyst_role to user jahnavi04;
grant select on view cust_public_view to role analyst_role;
use role analyst_role;
select * from cust_public_view;


