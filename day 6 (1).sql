use SNOWFLAKE_LEARNING_DB;
show tables;
select * from employees;
CREATE OR REPLACE FUNCTION calculate_discount(price FLOAT, discount_pct FLOAT)
RETURNS FLOAT
AS
$$
    price * (1 - discount_pct/100)
$$;
select NAME,salary,calculate_discount(salary,5) as changed_sal from employees;

create or replace function mask_email(email string) returns string as
$$
case when email is null then null
when charindex('@',email)=0 then '***invalid***'
else 
concat(left(email,2),'***',substring(email,charindex('@',email))) 
end
$$;
select * from employees;
alter table employees add column email varchar2(20);
update employees set email='jahnavi@gmail.com' where empid=105;
select mask_email(email) from employees;