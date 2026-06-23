use snowflake_learning_db;
CREATE TABLE EMPLOYEES(EMPID INT,NAME VARCHAR,DEPARTMENT VARCHAR,SALARY DECIMAL(10,2));
INSERT INTO EMPLOYEES VALUES(101,'Alice','HR',60000),(102,'Bob','IT',75000),(102,'Carol','Finance',80000),(104,'David','IT',60000),(105,'Jahnavi','HR',780000),(101,'Alice','HR',60000),(105,'Jahnavi','HR',780000);
select * from employees;
create table emp_clone clone employees;
select * from emp_clone;
select get_ddl('Table','emp_clone');
create table emp(emp_id int primary key not null,ename varchar,phone_num int,DEPARTMENT VARCHAR,SALARY DECIMAL(10,2));
insert into employees values(104,'Rishika','HR',40000);
select * from emp_clone;
insert into emp_clone values(104,'Rishika','HR',40000);
drop table employees;
select * from emp_clone;
create table emp1 clone emp_clone;
select * from emp_clone;

SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1000.CUSTOMER LIMIT
1000000;--RESULT CACHE--3.9s-->41ms
SELECT MAX(C_ACCTBAL) FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1000.CUSTOMER;-- 461ms-->53ms
SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1000.CUSTOMER ORDER BY C_NAME DESC LIMIT 2000000;-- SSD cache more than 1 min later 55ms;

create or replace table orders(raw variant);
select * from orders;
select raw:id::number as id,from orders;
select raw:name:: varchar name from orders;
select raw:age:: number from orders;
select raw:email:: varchar from orders;
select raw:id::number as id,raw:name:: varchar as name,raw:age:: number as age,raw:email:: varchar as email,raw:address:street::varchar as street,raw:address:postalCode::varchar as postalCode from orders;
show tables;
select * from employees;
select substr('1234567 890102 98347',1,9);
select lpad(substr('123478902341',1,4),14,'*');
select rpad(substr('2143 3546 ',1,10),14,'*');
insert into employees values(109,'Harika','HR',75000),(110,'Asrar','IT','80000');
select * from employees;
alter table employees cluster by (salary,department);
select get_ddl('table','employees');
create or replace resource monitor etl_monitor with
credit_quota=500
frequency=monthly
start_timestamp=immediately
triggers 
on 80 percent do notify 
on 90 percent do suspend 
on 100 percent do suspend_immediate;
drop resource monitor etl_monitor;