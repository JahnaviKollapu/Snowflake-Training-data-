create or replace database task_demo_db;
use database task_demo_db;

create or replace schema demo;
use schema demo;
--target table
create or replace table task_log(
id int, created_time timestamp default current_timestamp());
--task runs every 1 minute
create or replace task insert_task
warehouse= compute_wh
schedule = '1 minute'
as
insert into task_log(id) values(1);

alter task insert_task resume;
ALTER TASK insert_task SUSPEND;
select * from task_log;
show tasks;

--conditional task
create or replace table source_table(id int, name string,amount float);
drop stream my_stream;
create or replace stream my_stream on table source_table;

create or replace table target_table like source_table;

CREATE OR REPLACE TASK merge_task 
WAREHOUSE = compute_wh
SCHEDULE = '1 minute'
WHEN SYSTEM$STREAM_HAS_DATA('MY_STREAM')
AS

MERGE INTO target_table tgt
USING my_stream src
ON tgt.id = src.id

WHEN NOT MATCHED
     AND src.metadata$action = 'INSERT'
     AND src.metadata$isupdate = FALSE
THEN INSERT (id, name, amount)
VALUES (src.id, src.name, src.amount)

WHEN MATCHED
     AND src.metadata$action = 'INSERT'
     AND src.metadata$isupdate = TRUE
THEN UPDATE SET
     tgt.name = src.name,
     tgt.amount = src.amount

WHEN MATCHED
     AND src.metadata$action = 'DELETE'
     AND src.metadata$isupdate = FALSE
THEN DELETE;

alter task merge_task resume;
alter task merge_task suspend;
alter warehouse compute_wh suspend; 
TRUNCATE TABLE source_table;
TRUNCATE TABLE target_table;
show tasks;
show warehouses;
SELECT SYSTEM$STREAM_HAS_DATA('MY_STREAM');

insert into source_table values(101,'jahnavi',8000);
insert into source_table values(102,'Rishika',9000);
select * from source_table;
select * from target_table;
select * from my_stream;
SELECT *
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY())
ORDER BY SCHEDULED_TIME DESC;
UPDATE source_table
SET amount = 500
WHERE id = 101;
DELETE FROM source_table WHERE id = 101;
--task execution of a stored procedure
create or replace procedure log_insert()
returns string 
language sql
as
$$ 
begin
insert into task_log(id) values(999);
return 'inserted successfully';
end;
$$;
call log_insert();
SELECT * FROM task_log;
create or replace task procedure_task
warehouse =compute_wh
schedule ='1 minute'
as 
call log_insert();
alter task procedure_task suspend;
alter warehouse compute_wh suspend;
show warehouses;
show tasks;

create or replace task parent_task
warehouse=compute_wh
schedule = '1 minute'
as
insert into task_log values(100,current_timestamp());
create or replace task child_task
warehouse=compute_wh
after parent_task
as 
insert into task_log values(200,current_timestamp());
alter task parent_task suspend;
execute task parent_task;
alter task child_task suspend;
show tasks;
show tasks like 'parent_task';
describe task merge_task;


