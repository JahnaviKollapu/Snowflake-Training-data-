create database scdORcdcprac;
use scdORcdcprac;
--SOURCE TABLLE
create or replace table source_customer(
cid int,cname varchar,city varchar
);
INSERT INTO scdorcdcprac.public.source_customer values
    (101, 'Alice Smith', 'New York'),
    (102, 'Bob Jones', 'Chicago'),
    (103, 'Charlie Brown', 'Dallas'),
    (104, 'David Miller', NULL),         -- Testing NULL handling
    (105, 'Eve Williams', 'Miami');
-- TARGET TABLE
create or replace table target_cust_dim(
cust_sk int autoincrement,--surrogate key(auto-fill)
cid int,cname varchar,city varchar,start_date date default current_date(),
end_date date default null,is_currrent boolean default true 
);
select * from source_customer;
select * from target_cust_dim;

MERGE INTO target_cust_dim AS target
USING (
    -- PART 1: Identify records that need to be INSERTED (New or Updated)
    SELECT 
        src.cid, src.cname, src.city, 
        NULL AS target_sk  -- NULL ensures 'NOT MATCHED' for the new record
    FROM source_customer AS src
    LEFT JOIN target_cust_dim AS target 
        ON src.cid = target.cid AND target.is_currrent = TRUE
    WHERE target.cid IS NULL -- Brand new records
       OR (src.city IS DISTINCT FROM target.city OR src.cname IS DISTINCT FROM target.cname)

    UNION ALL

    -- PART 2: Identify records that need to be EXPIRED (The old version)
    SELECT 
        src.cid, src.cname, src.city, 
        target.cust_sk AS target_sk -- The SK ensures 'MATCHED' for the old record
    FROM source_customer AS src
    JOIN target_cust_dim AS target 
        ON src.cid = target.cid AND target.is_currrent = TRUE
    WHERE (src.city IS DISTINCT FROM target.city OR src.cname IS DISTINCT FROM target.cname)
) AS incoming
ON target.cust_sk = incoming.target_sk

-- ACTION 1: EXPIRE OLD RECORDS
WHEN MATCHED THEN 
    UPDATE SET 
        target.end_date = CURRENT_DATE(),
        target.is_currrent = FALSE

-- ACTION 2: INSERT NEW RECORDS
WHEN NOT MATCHED THEN 
    INSERT (cid, cname, city, start_date, end_date, is_currrent) 
    VALUES (incoming.cid, incoming.cname, incoming.city, CURRENT_DATE(), NULL, TRUE);
insert into target_cust_dim(cid,cname,city,start_date,end_date,is_currrent)
select s.cid,s.cname,s.city,current_date(),null,true from source_customer s join target_cust_dim t on s.cid=t.cid where t.end_date=current_date() and t.is_currrent=false;
commit;
--NEXT TIME IF YOU RUN THE SAME QUERY
--INSERT SHOULD NOT HAPPEN AT TARGET 
--BCZ THERE IS NO ANY CHANGES IN SOURCE TABLE ( RUN THE FULL SCD2 QUERY & CHECK ONCE )
  
--history tracking
update source_customer set city='Miami' where cid=101;

insert into source_customer values(106,'Frank Miller','Denver');
drop stream cust_str;

CREATE OR REPLACE STREAM cust_str ON TABLE source_customer;
 -- 2. Single Transactional Merge (Processes everything at once)
MERGE INTO target_cust_dim AS target
USING (
    -- Group 1: The 'Expire' records (Rows that were updated or deleted)
    SELECT 
        cid, cname, city, metadata$action, metadata$isupdate,
        cid AS join_key -- Use the actual ID to match existing rows
    FROM cust_str
    WHERE (metadata$isupdate = TRUE OR metadata$action = 'DELETE')

    UNION ALL

    -- Group 2: The 'New' records (Rows that were inserted or are the new half of an update)
    SELECT 
        cid, cname, city, metadata$action, metadata$isupdate,
        NULL AS join_key -- NULL ensures we 'NOT MATCHED' to trigger an INSERT
    FROM cust_str
    WHERE metadata$action = 'INSERT'
) AS cdc
ON target.cid = cdc.join_key 
   AND target.is_currrent = TRUE

-- ACTION: EXPIRE
WHEN MATCHED THEN 
    UPDATE SET target.end_date = CURRENT_DATE(), target.is_currrent = FALSE

-- ACTION: INSERT NEW VERSION
WHEN NOT MATCHED THEN 
    INSERT (cid, cname, city, start_date, end_date, is_currrent)
    VALUES (cdc.cid, cdc.cname, cdc.city, CURRENT_DATE(), NULL, TRUE);

INSERT INTO source_customer (cid, cname, city) VALUES (107, 'George Harris', 'Phoenix');
INSERT INTO source_customer (cid, cname, city) VALUES (888, 'Automation test', 'Banglore');