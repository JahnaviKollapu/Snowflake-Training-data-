use snowflake_learning_db;
create or replace table sales_data(
sales_price float,cost_price float
);
INSERT INTO sales_data VALUES
(100,60),
(200,120),
(300,150);
create or replace function calc_profit(sale float,cost float)
returns float
as 
$$
sale-cost
$$;
select sales_price,cost_price,calc_profit(sales_price,cost_price) as profit from sales_data;
create or replace function calc_tax(sales_price float) 
returns float
language javascript 
as 
$$
return SALES_PRICE*0.18;--CASE SENSITIVE
$$;
select sales_price,calc_tax(sales_price) as tax from sales_data;
desc table sales_data;
show user functions;
