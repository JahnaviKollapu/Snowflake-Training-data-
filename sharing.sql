use role accountadmin;
create role share_admin_role;
grant role share_admin_role to role sysadmin;
use role share_admin_role;
use role sysadmin;
create or replace database enterprise_db;
CREATE OR REPLACE SCHEMA ENTERPRISE_DB.SALES;

CREATE OR REPLACE TABLE ENTERPRISE_DB.SALES.ORDERS (
ORDER_ID INT,
CUSTOMER_NAME STRING,
AMOUNT NUMBER(10,2),
ORDER_DATE DATE
);
INSERT INTO ENTERPRISE_DB.SALES.ORDERS VALUES
(1,'Ravi',1000,CURRENT_DATE),
(2,'John',2000,CURRENT_DATE),
(3,'Sita',3000,CURRENT_DATE);

create or replace secure view enterprise_db.sales.secure_orders as 
select order_id,customer_name,amount from 
enterprise_db.sales.orders;
create or replace share enterprise_share;

grant usage on database enterprise_db to share enterprise_share;
grant usage on schema enterprise_db.sales to share enterprise_share;
grant select on view enterprise_db.sales.secure_orders to share enterprise_share;
Select current_role();
alter share enterprise_share add accounts= IV21255;--consumer account
select current_account();
SELECT CURRENT_ACCOUNT(), CURRENT_REGION();
--reader accounts
create managed account vendor_reader
admin_name=vendor_admin,
admin_password ='VendorReader@2026!'
type= reader;
show password policies;
show managed accounts;
show shares;
alter share enterprise_share add accounts = VS13452;
select current_account();
--replication and failover
select current_account();
select current_role();
select current_organization_name();
SELECT CURRENT_REGION();
USE ROLE ORGADMIN;
show accounts;
CREATE ACCOUNT DR_ACCOUNT 
ADMIN_NAME= dr_admin
ADMIN_PASSWORD ="StrongPassword@Data#2026"
EMAIL = 'jaanu@gmail.com'
edition = enterprise
region ='AWS_AP_SOUTH_1';
select current_account();
show warehouses;
SELECT CURRENT_ROLE();
SELECT CURRENT_ACCOUNT();
SELECT CURRENT_ORGANIZATION_NAME();
SHOW ORGANIZATION ACCOUNTS;
ALTER DATABASE ENTERPRISE_DB
ENABLE REPLICATION TO ACCOUNTS PNEDQXQ.DR_ACCOUNT;
--Promote Secondary to Primary (Failover Scenario):
ALTER DATABASE ENTERPRISE_DB_REPLICA PRIMARY;
CREATE FAILOVER GROUP DR_GROUP
OBJECT_TYPES = DATABASES
ALLOWED_DATABASES = ENTERPRISE_DB
ALLOWED_ACCOUNTS = DR_ACCOUNT;
ALTER FAILOVER GROUP DR_GROUP ENABLE REPLICATION TO ACCOUNTS <SECONDARY_ACCOUNT>;
--Replication works across AWS, Azure, GCP.
ALTER DATABASE ENTERPRISE_DB ENABLE REPLICATION TO ACCOUNTS <CROSS_CLOUD_ACCOUNT>;
CREATE DATABASE CROSS_CLOUD_REPLICA
AS REPLICA OF <PROVIDER_ACCOUNT>.ENTERPRISE_DB;
SHOW REPLICATION ACCOUNTS;
SHOW FAILOVER GROUPS;
SELECT SYSTEM$DATABASE_REFRESH_PROGRESS('ENTERPRISE_DB_REPLICA');




