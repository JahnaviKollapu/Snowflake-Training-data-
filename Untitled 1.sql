--create intial frame
create database ecommerce_demo;
create schema raw;

--switch to our schema;
use database ecommerce_demo;
use schema raw;
--create file format
create or replace file format csv_format
type= 'csv'
field_optionally_enclosed_by='"'
field_delimiter=','
skip_header=1
null_if=('NULL','null','');
select current_region();
--storage integration
create 

