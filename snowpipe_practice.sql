CREATE OR REPLACE DATABASE snowpipe_db;
USE DATABASE snowpipe_db;

CREATE OR REPLACE SCHEMA pipe_demo;
USE SCHEMA pipe_demo;

CREATE OR REPLACE TABLE sales_pipe (
id INT,
name STRING,
department string,
amount NUMBER(10,2)
);

CREATE OR REPLACE FILE FORMAT csv_format
TYPE = CSV
SKIP_HEADER = 1
FIELD_OPTIONALLY_ENCLOSED_BY = '"';

CREATE OR REPLACE STORAGE INTEGRATION s3_int
TYPE = EXTERNAL_STAGE
STORAGE_PROVIDER = S3
ENABLED = TRUE
STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::996345187237:role/Snowflake_s3_role'
STORAGE_ALLOWED_LOCATIONS = ('s3://hyd-snowflake-demo-bucket/');

DESC INTEGRATION s3_int;
--create notification INTEGRATION
use role accountadmin;

SHOW PARAMETERS LIKE 'ENABLE_NOTIFICATION_INTEGRATIONS';
CREATE OR REPLACE NOTIFICATION INTEGRATION s3_notification
TYPE = QUEUE
NOTIFICATION_PROVIDER = AWS_SQS
DIRECTION = INBOUND
ENABLED =TRUE
AWS_SQS_ARN = 'arn:aws:sqs:us-east-1:996345187237:snowpipe-queue';

show integrations;

CREATE OR REPLACE STAGE my_s3_stage
URL='s3://hyd-snowflake-demo-bucket/'
STORAGE_INTEGRATION = s3_int
FILE_FORMAT = csv_format;

CREATE OR REPLACE PIPE MY_PIPE AS
COPY INTO sales_pipe
FROM @my_s3_stage
FILE_FORMAT = (FORMAT_NAME = csv_format);

list @my_s3_stage;
SELECT SYSTEM$PIPE_STATUS('MY_PIPE');
alter pipe my_pipe refresh;
SELECT * FROM sales_pipe;
show warehouses;
alter warehouse compute_wh suspend;
--create stream 
create stream sales_stream on table sales_pipe;
insert into sales_pipe values(6,'Rishika','HR',70000);
select * from sales_stream;
delete from sales_pipe where id=2;
insert into sales_pipe values(2,'Rahul','Engineering',72000);

create or replace table sales_clean(sales_department string,
salary number);
--task creation
CREATE OR REPLACE TASK sales_merge_task 
WAREHOUSE = compute_wh
SCHEDULE = '1 minute'
AS
MERGE INTO sales_clean AS tgt
USING (
    SELECT 
        department AS emp_dept,
        amount AS salary,
        METADATA$ACTION AS action
    FROM sales_stream
) src
ON tgt.sales_department = src.emp_dept

WHEN MATCHED AND src.action = 'DELETE' THEN 
    DELETE

WHEN MATCHED AND src.action = 'INSERT' THEN 
    UPDATE SET 
        tgt.salary = src.salary

WHEN NOT MATCHED AND src.action = 'INSERT' THEN 
    INSERT (sales_department, salary)
    VALUES (src.emp_dept, src.salary);
ALTER TASK sales_merge_task resume;
ALTER TASK sales_merge_task suspend;
ALTER WAREHOUSE compute_wh resume;
ALTER WAREHOUSE compute_wh suspend;
INSERT INTO sales_pipe VALUES (7,'Test1','IT',54000);
INSERT INTO sales_pipe VALUES (8,'Anush','Finance',89000);
SELECT * FROM sales_clean;
show tasks;
SELECT *
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY())
ORDER BY SCHEDULED_TIME DESC;
select * from sales_pipe;
delete from sales_pipe where id=8;
INSERT INTO sales_pipe VALUES (8,'Ray','HR',84000);
CREATE TABLE sales_pipe_restore CLONE sales_pipe
BEFORE (STATEMENT => '01c348d8-3202-7c2d-0014-3a52000aca26');
select * from sales_pipe_restore;
show warehouses;
show tables;
select * from sales_clean;