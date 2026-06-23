create or replace storage integration
s3_int type= external_stage
storage_provider = 'S3'
enabled = true
storage_allowed_locations 
= ('s3://hyd-snowflake-demo-bucket/')
storage_aws_role_arn = 'arn:aws:iam::996345187237:role/Snowflake_s3_role' ;

desc integration s3_int;

create or replace database snowpipe_db;
use database snowpipe_db;

create or replace schema pipe_demo;
use schema pipe_demo;
--external stage
create or replace stage my_s3_stage
url = 's3://hyd-snowflake-demo-bucket/'
storage_integration = s3_int;

list @my_s3_stage;

CREATE OR REPLACE TABLE sales_pipe (
id INT,
name STRING,
department string,
salary NUMBER(10,2)
);

create or replace file format csv_format type=csv 
skip_header=1 
field_optionally_enclosed_by='"';

copy into sales_pipe from @my_s3_stage file_format=csv_format
on_error ='CONTINUE';

copy into sales_pipe from @my_s3_stage file_format=csv_format
validation_mode= return_errors ;
--snowpipe
create or replace pipe my_pipe auto_ingest=true as 
copy into sales_pipe from @my_s3_stage file_format=csv_format;

show pipes;
SELECT SYSTEM$PIPE_STATUS('my_pipe');

CREATE STAGE my_internal_stage;

list @my_internal_stage;

CREATE TABLE sales_data(
id INT,
name STRING,
department STRING,
salary NUMBER(10,2)
);
select * from sales_data;
COPY INTO sales_data
FROM @my_internal_stage
FILE_FORMAT=csv_format;

SELECT  METADATA$FILENAME,METADATA$FILE_ROW_NUMBER FROM @my_s3_stage (FILE_FORMAT => csv_format);

CREATE TABLE EMPLOYEES_HISTORY (
    EMP_ID INT,
    EMP_NAME VARCHAR(50),
    GENDER VARCHAR(10),
    DEPARTMENT VARCHAR(50),
    SALARY NUMBER(10,2)
);
CREATE TABLE EMPLOYEE (
    EMP_ID INT,
    EMP_NAME VARCHAR(50),
    GENDER VARCHAR(10),
    DEPARTMENT VARCHAR(50),
    SALARY NUMBER(10,2)
);

INSERT INTO EMPLOYEE VALUES
(101, 'Aarav Sharma', 'Male', 'IT', 85000),
(102, 'Diya Reddy', 'Female', 'HR', 60000),
(103, 'Vihaan Patel', 'Male', 'Finance', 75000),
(104, 'Ananya Singh', 'Female', 'IT', 92000),
(105, 'Arjun Kumar', 'Male', 'IT', 70000),
(106, 'Ishita Rao', 'Female', 'HR', 58000),
(107, 'Krishna Verma', 'Male', 'Finance', 80000),
(108, 'Meera Iyer', 'Female', 'IT', 88000),
(109, 'Rohan Das', 'Male', 'Marketing', 65000),
(110, 'Sneha Kapoor', 'Female', 'Marketing', 72000),
(111, 'Aditya Nair', 'Male', 'IT', 95000),
(112, 'Pooja Mehta', 'Female', 'Finance', 78000),
(113, 'Rahul Jain', 'Male', 'HR', 62000),
(114, 'Kavya Pillai', 'Female', 'IT', 87000),
(115, 'Siddharth Roy', 'Male', 'Finance', 82000);
--procedure
CREATE OR REPLACE PROCEDURE load_history() returns string 
language sql
as
$$
BEGIN
truncate table employees_history;
insert into employees_history 
select * from employee;
return 'load completed';
end;
$$;

call load_history();
--HISTORY REPORT OF MY SNOWPIPE ACTIVITY
SELECT * FROM TABLE(INFORMATION_SCHEMA.PIPE_USAGE_HISTORY(
DATE_RANGE_START=> dateadd('hour',-24,current_timestamp()),
DATE_RANGE_END => CURRENT_TIMESTAMP()
)) WHERE PIPE_NAME ='MY_PIPE';

show pipes;
alter pipe my_pipe set pipe_execution_paused = TRUE;
