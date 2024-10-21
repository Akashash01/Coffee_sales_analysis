-- Data cleaning:

select * from coffee_sales;

update coffee_sales
set transaction_date = str_to_date(transaction_date, '%d-%m-%Y');

alter table coffee_sales
modify column transaction_date date;

update coffee_sales
set transaction_time = str_to_date(transaction_time, '%H:%i:%s');

alter table coffee_sales
modify column transaction_time time;

describe coffee_sales;
------------------------------------------------------------------------------------------------------------------
-- KPI Requirements:
-- Total sales analysis:
-- calculate total sales per month

select month(transaction_date) as months, round(sum(unit_price * transaction_qty), 2) as total_sales
from coffee_sales
group by month(transaction_date) 
order by month(transaction_date) asc;

-- month over month sales analysis 

with cte as (select month(transaction_date) as months, round(sum(unit_price * transaction_qty), 2) as total_sales,
	lag(round(sum(unit_price * transaction_qty), 2)) over (order by month(transaction_date)) as previous_month
from coffee_sales
group by month(transaction_date) 
order by month(transaction_date) asc) 

select months, (total_sales - previous_month) / previous_month * 100 as per_diff
from cte;

-- sales diff b/w month

with cte as (select month(transaction_date) as months, round(sum(unit_price * transaction_qty), 2) as total_sales,
	lag(round(sum(unit_price * transaction_qty), 2)) over (order by month(transaction_date)) as previous_month
from coffee_sales
group by month(transaction_date) 
order by month(transaction_date) asc) 

select months, (total_sales - previous_month) as sales_diff
from cte;
------------------------------------------------------------------------------------------------------------------
-- total order analysis
-- total order over month

select month(transaction_date) as months, count(transaction_id) as total_orders
from coffee_sales
group by month(transaction_date) 
order by month(transaction_date) asc;

-- month over month diff on orders

with cte as (select month(transaction_date) as months, count(transaction_id)as total_orders,
	lag(count(transaction_id)) over (order by month(transaction_date)) as previous_month
from coffee_sales
group by month(transaction_date) 
order by month(transaction_date) asc) 

select months, (total_orders - previous_month) / previous_month * 100 as per_diff
from cte;

-- orders diff over month

with cte as (select month(transaction_date) as months, count(transaction_id) as total_orders,
	lag(count(transaction_id)) over (order by month(transaction_date)) as previous_month
from coffee_sales
group by month(transaction_date) 
order by month(transaction_date) asc) 

select months, total_orders, (total_orders - previous_month) as orders_diff
from cte;
-------------------------------------------------------------------------------------------------------------------
-- total quantity sold over month, month-on-month diff

with cte as (select month(transaction_date) as months, sum(transaction_qty) as total_qty,
	lag(sum(transaction_qty)) over (order by month(transaction_date)) as previous_month
from coffee_sales
group by month(transaction_date) 
order by month(transaction_date) asc) 

select months, total_qty, (total_qty - previous_month) / previous_month * 100 as per_diff
from cte;
-------------------------------------------------------------------------------------------------------------------
-- top sales over dates & month

select
month(transaction_date) as months, transaction_date as date, 
concat(round(sum(unit_price * transaction_qty)/1000, 1), 'K') as total_sales,
concat(round(sum(transaction_qty)/1000, 1), 'K') as total_qty,
concat(round(count(transaction_qty)/1000, 1), 'K') as total_orders
from coffee_sales
group by month(transaction_date), transaction_date
order by total_sales desc, total_qty desc, total_orders desc, month(transaction_date);
-------------------------------------------------------------------------------------------------------------------
-- sales over weekends & weekdays

select
	month(transaction_date),
	case when dayofweek(transaction_date) in (1,7) then 'weekends' else 'weekdays' end as day_of_week,
    concat(round(sum(unit_price * transaction_qty)/1000, 1), 'K') as total_sales,
	concat(round(sum(transaction_qty)/1000, 1), 'K') as total_qty,
	concat(round(count(transaction_qty)/1000, 1), 'K') as total_orders
from coffee_sales
group by case when dayofweek(transaction_date) in (1,7) then 'weekends' else 'weekdays' end , month(transaction_date)
order by month(transaction_date), total_sales desc;
--------------------------------------------------------------------------------------------------------------------
-- sales over loaction

select 
	store_location,
    concat(round(sum(unit_price * transaction_qty)/1000, 1), 'K') as total_sales,
	concat(round(sum(transaction_qty)/1000, 1), 'K') as total_qty,
	concat(round(count(transaction_qty)/1000, 1), 'K') as total_orders
from coffee_sales
group by store_location
order by total_sales desc;
--------------------------------------------------------------------------------------------------------------------
-- avg sales lines overall month

select avg(total_sales) as avg_sales
from( select 
    round(sum(unit_price * transaction_qty), 2) as total_sales
from coffee_sales
group by transaction_date ) as a;
---------------------------------------------------------------------------------------------------------------------
-- sales over product category

select
	product_category,
    round(sum(unit_price * transaction_qty), 2) as total_sales
from coffee_sales
group by product_category
order by total_sales desc;

-- top 10 products

select
	product_type,
    round(sum(unit_price * transaction_qty), 2) as total_sales
from coffee_sales
group by product_type
order by total_sales desc
limit 10;
--------------------------------------------------------------------------------------------------------------------
-- sales ove time

select hour(transaction_time) as time,
	concat(round(sum(unit_price * transaction_qty)/1000, 1), 'K') as total_sales,
	concat(round(sum(transaction_qty)/1000, 1), 'K') as total_qty,
	concat(round(count(transaction_qty)/1000, 1), 'K') as total_orders
from coffee_sales
group by hour(transaction_time)
order by hour(transaction_time);

-- sales over time & day of week

select 
	case when dayofweek(transaction_date) = 2 then 'mon'
		when dayofweek(transaction_date) = 3 then 'tue' 
		when dayofweek(transaction_date) = 4 then 'wed'
		when dayofweek(transaction_date) = 5 then  'thu'
		when dayofweek(transaction_date) = 6 then  'fri'
		when dayofweek(transaction_date) = 7 then  'sat'
        else 'sun'
        end as day_type,
concat(round(sum(unit_price * transaction_qty)/1000, 1), 'K') as total_sales
from coffee_sales
group by case when dayofweek(transaction_date) = 2 then 'mon'
		when dayofweek(transaction_date) = 3 then 'tue' 
		when dayofweek(transaction_date) = 4 then 'wed'
		when dayofweek(transaction_date) = 5 then  'thu'
		when dayofweek(transaction_date) = 6 then  'fri'
		when dayofweek(transaction_date) = 7 then  'sat'
        else 'sun'
        end	 
