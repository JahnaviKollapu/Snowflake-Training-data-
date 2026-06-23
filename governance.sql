create or replace database gov_demo_db;
use database gov_demo_db;
create or replace schema finance;
create or replace table customers(
cid int,cname string,email string,phone string,ssn string,city string,acc_no number(12,2),created_date date
);
INSERT INTO FINANCE.CUSTOMERS VALUES
(1,'Ravi','ravi@email.com','9999999999','123-45-6789','Hyderabad',100000,CURRENT_DATE),
(2,'John','john@email.com','8888888888','234-56-7890','New York',250000,CURRENT_DATE),
(3,'Sita','sita@email.com','7777777777','345-67-8901','Chennai',150000,CURRENT_DATE);
select * from customers;

create or replace tag sensitive_data_tag;
alter table customers modify column SSN set tag sensitive_data_tag='highly_sensitive';
alter table customers modify column email set tag sensitive_data_tag='Personal_info';
--to view tagged columns
select * from table(information_schema.tag_references_all_columns('Finance.customers','table'));
show tags;

--masking policy (dynamic data masking)
create or replace masking policy ssn_mask as
(val string) returns string ->
case 
    when current_role() in ('ACCOUNTADMIN') then val
    else 'XXX-XX-XXXX'
end;

alter tag sensitive_data_tag set masking policy ssn_mask;
alter table customers modify column ssn set tag sensitive_data_tag='highly_sensitive';
select * from table(information_schema.tag_references_all_columns('customers','table'));
use role accountadmin;
select cname,ssn from customers;
create role jahnavi;
grant role jahnavi to user JAHNAVI04;
use role jahnavi;
select current_role();
select cname,ssn from customers;
--access history and obj dependencies
select * from snowflake.account_usage.access_history order by
query_start_time desc;
select * from snowflake.account_usage.object_dependencies where referenced_object_name='customers';
use role accountadmin;
--resource monitor
create or replace resource monitor finance_monitor with credit_quota =30 triggers on 80 percent do notify
on 100 percent do suspend;
alter warehouse compute_wh set resource_monitor =finance_monitor;
show warehouses;
alter warehouse compute_wh suspend;
--search optimisation service
alter table customers add search optimization on equality(cid);-- fast lookup without full table scan 
select * from customers where cid=2;
--external functions and tokenisation
--api integration
create or replace api integration my_api_integration 
api_provider=aws_api_gateway 
api_aws_role_arn = 'arn:aws:iam::996345187237:role/service-role/mask-email-function-role-uuf41khw'
enabled=true
api_allowed_prefixes=('https://ze2wt8fjdd.execute-api.ap-south-2.amazonaws.com/');
show integrations;
desc integration my_api_integration;
create or replace external function mask_email(email string)
returns string
api_integration=my_api_integration
as 'https://ze2wt8fjdd.execute-api.ap-south-2.amazonaws.com/prod/mask';
SELECT mask_email(email)
FROM customers;
show warehouses;
SELECT mask_email('john@gmail.com');


