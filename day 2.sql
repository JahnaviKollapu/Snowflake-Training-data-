create warehouse time_wh
with
warehouse_size='small'
auto_suspend=60
auto_resume=TRUE
min_cluster_count=2
max_cluster_count=5
scaling_policy='ECONOMY';
drop warehouse time_wh;
create database health_db;
use health_db;
create schema health_schema;
CREATE OR REPLACE SCHEMA HEALTH_DB.RAW;
CREATE OR REPLACE SCHEMA HEALTH_DB.STAGE;
CREATE OR REPLACE SCHEMA HEALTH_DB.ANALYTICS;
CREATE OR REPLACE TABLE RAW.PATIENTS (
    PATIENT_ID INT,
    PATIENT_NAME STRING,
    GENDER STRING,
    DOB DATE,
    CITY STRING
);

INSERT INTO RAW.PATIENTS VALUES
(1,'Ravi Kumar','M','1985-02-10','Hyderabad'),
(2,'Anita Rao','F','1990-07-15','Bangalore'),
(3,'Suresh Reddy','M','1978-09-20','Chennai'),
(4,'Meena Sharma','F','1995-03-05','Mumbai'),
(5,'Arjun Patel','M','1988-12-12','Ahmedabad'),
(6,'Priya Nair','F','1992-11-22','Kochi');
CREATE OR REPLACE TABLE RAW.APPOINTMENTS (
    APPOINTMENT_ID INT,
    PATIENT_ID INT,
    DOCTOR_NAME STRING,
    VISIT_DATE DATE,
    DEPARTMENT STRING
);
INSERT INTO RAW.APPOINTMENTS VALUES
(101,1,'Dr. Raj','2024-01-10','Cardiology'),
(102,2,'Dr. Mehta','2024-01-11','Dermatology'),
(103,1,'Dr. Raj','2024-01-15','Cardiology'),
(104,3,'Dr. Singh','2024-01-16','Orthopedic'),
(105,4,'Dr. Mehta','2024-01-17','Dermatology'),
(106,5,'Dr. Raj','2024-01-18','Cardiology'),
(107,1,'Dr. Singh','2024-01-20','Orthopedic');
CREATE OR REPLACE TABLE RAW.BILLING (
    BILL_ID INT,
    PATIENT_ID INT,
    BILL_AMOUNT NUMBER(10,2),
    BILL_DATE DATE
);
INSERT INTO RAW.BILLING VALUES
(1001,1,5000,'2024-01-10'),
(1002,2,3000,'2024-01-11'),
(1003,3,7000,'2024-01-16'),
(1004,1,2000,'2024-01-15'),
(1005,4,3500,'2024-01-17'),
(1006,5,4500,'2024-01-18'),
(1007,1,1500,'2024-01-20');
CREATE OR REPLACE TABLE STAGE.PATIENTS AS
SELECT
    PATIENT_ID,
    UPPER(PATIENT_NAME) AS PATIENT_NAME,
    GENDER,
    DOB,
    CITY
FROM RAW.PATIENTS;
CREATE OR REPLACE TABLE STAGE.BILLING AS
SELECT
    BILL_ID,
    PATIENT_ID,
    BILL_AMOUNT,
    BILL_DATE
FROM RAW.BILLING;

select * from billing;

select patient_name from raw.patients where city='Hyderabad';

select department,count(*)from raw.appointments group by department;

select sum(bill_amount),patient_id from stage.billing group by patient_id;

select doctor_name,count(patient_id) from raw.appointments group by doctor_name;

select patient_id,count(*) from raw.appointments group by patient_id having count(*)>1;

select a.department,sum(b.bill_amount) 
from raw.billing b join raw.appointments a 
on a.patient_id=b.patient_id group by a.department;
select doctor_name,count(*) from raw.appointments group by doctor_name;

select p.patient_name,max(a.visit_date) from patientraw.appointments group by patient_id;

select p.patient_id,p.patient_name from patients p left join billing b on p.patient_id=b.patient_id where b.patient_id is null;
select a.patient_id,a.visit_date from raw.appointments a left 
join stage.billing b on a.patient_id=b.patient_id
and a.visit_date=b.bill_date where b.bill_id is null;

select patient_id,sum(bill_amount) as total_revenue from stage.billing group by patient_id order by total_revenue desc limit 2;
select a.doctor_name,sum(b.bill_amount) as total_rev from raw.appointments a join stage.billing b on a.patient_id=b.patient_id and a.visit_date=b.bill_date 
group by a.doctor_name order by total_rev desc limit 1;

select patient_id,bill_date,bill_amount,sum(bill_amount) over ( partition by patient_id order by bill_date) as running_total from stage.billing;

select patient_id,sum(bill_amount) as total_rev,rank() over( order by sum(bill_amount) desc) as rev 
from stage.billing group by patient_id;

select patient_id,doctor_name,visit_date,count(*) from raw.
appointments group by patient_id,doctor_name,visit_date having count(*)>1;

create table health_table(
Product_id varchar,productndc varchar, ndcpackagecode varchar, productdescription varchar 
);
select productndc,ndcpackagecode from health_table group by productndc,ndcpackagecode order by ndcpackagecode;
select productndc,count(*) AS DUPLICATES from HEALTH_TABLE GROUP BY productndc HAVING COUNT(*)>1 ORDER BY DUPLICATES DESC;
SELECT * FROM HEALTH_TABLE WHERE PRODUCTNDC IN
(SELECT PRODUCTNDC FROM HEALTH_TABLE GROUP BY PRODUCTNDC HAVING COUNT(*)>1)
ORDER BY PRODUCTNDC DESC;
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY PRODUCTNDC ORDER BY PRODUCTNDC DESC) AS ROW_NUM
    FROM HEALTH_TABLE
)
WHERE ROW_NUM > 1;
SELECT *,COUNT(*) CNT FROM HEALTH_TABLE GROUP  BY PRODUCT_ID,PRODUCTNDC,NDCPACKAGECODE,PRODUCTDESCRIPTION HAVING CNT>1;
select current_timestamp();
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
ORDER BY START_TIME DESC;

