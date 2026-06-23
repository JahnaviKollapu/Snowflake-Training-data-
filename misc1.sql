CREATE TABLE gold_bookings (
    booking_id INT,
    customer_name VARCHAR(50),
    booking_date DATE,
    gold_weight_grams DECIMAL(6,2),
    price_per_gram DECIMAL(8,2),
    total_amount DECIMAL(10,2),
    city VARCHAR(50)
);
create or replace file format my_csv
type='csv'
field_optionally_enclosed_by='"'
skip_header=1;
select * from gold_bookings;
create view total_view as select sum(total_amount) as final_amount,max(price_per_gram) as max_price_per_gram from gold_bookings;

create table total_table as select sum(total_amount) as final_amount,max(price_per_gram) as max_price_per_gram from gold_bookings;
select sum(total_amount) from gold_bookings;
select * from total_table;
select * from total_view;
update gold_bookings set total_amount=70000 where gold_weight_grams>10;
select sum(total_amount) from gold_bookings;
create secure view total_secure_view as select sum(total_amount) as final_amount,max(price_per_gram) as max_price_per_gram from gold_bookings;
show roles;
grant usage on warehouse compute_wh to role analyst_role;
grant usage on database health_db to role analyst_role;
create user janu password="temp@1234"
default_role=analyst_role must_change_password=false;
grant role analyst_role to user janu;
grant select on view total_secure_view to role analyst_role;
use role analyst_role;
show file formats;
use role accountadmin;

create stage stage_ecomm 
file_format = my_csv;

create or replace table ecomm_sales(
id int,name string,department string,
salary int
);

copy into ecomm_sales 
from @stage_ecomm 
file_format = (format_name= my_csv)
on_error='continue';
drop stage stage_ecomm;
drop table ecomm_sales;

