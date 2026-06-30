1. Create_table in Pgadmin
CREATE TABLE Superstore_dataset (
    ship_mode TEXT,
    segment TEXT,
    country TEXT,
    city TEXT,
    state TEXT,
    postal_code INT,
    region TEXT,
    category TEXT,
    sub_category TEXT,
    sales NUMERIC,
    quantity INT,
    discount NUMERIC,
    profit NUMERIC,
	pl_identifier TEXT
    -- continue for all remaining columns
);

2. Imported CSV using pgAdmin Import/Export Wizard
 Go to table->Superstore_dataset-> Right Cick-> Import/Export

3. Business Questions

a. Executive Summary
select sum(sales) as total_revenue, 
sum(profit) as total_profit, 
avg(sales) as Average_Order_Value, 
count(*)  as total_order_count
from superstore_dataset

b. Sales Performance

select region, sum(sales) as Revenue, 
sum(profit) as Regional_Profit 
from superstore_dataset
group by region
order by 2 desc, Regional_Profit desc

c. Product Performance
select category, sum(sales) as Revenue, sum(profit) as "Category Profit"
from superstore_dataset
group by category
order by 2 desc, "Category Profit" desc

d. Top 10 profit making products
WITH tik AS (
    SELECT
        sub_category,
        SUM(profit) AS product_profit
    FROM superstore_dataset
    GROUP BY sub_category
)

select sub_category,product_profit,
rank() over (order by product_profit desc)
from tik
limit 10

e. Loss making products
WITH loss_summary AS (
    SELECT
        sub_category,
        SUM(profit) AS product_profit
    FROM superstore_dataset
    GROUP BY sub_category
	having sum(profit)<0
)

select sub_category,product_profit,
rank() over (order by product_profit)
from loss_summary
limit 10

f. Loss-Making Sub-Categories by Region
WITH loss_summary AS (
    SELECT
        region, sub_category,
        SUM(profit) AS product_profit
    FROM superstore_dataset
    GROUP BY region,sub_category
	having sum(profit)<0
)

select region,sub_category,product_profit,
rank() over (partition by region order by product_profit asc) as loss_rank
from loss_summary
order by region, loss_rank

g. Number of discounted Orders in each region
WITH discount_summary AS (
    SELECT
        region, sub_category,
        sum(case when discount>0 then 1 else 0 end) AS discounted_orders
    FROM superstore_dataset
    GROUP BY region,sub_category
	
)

select region,sub_category,discounted_orders,
rank() over (partition by region order by discounted_orders desc) as discount_rank
from discount_summary
order by region, discount_rank


h. Total Loss with Running Total by Sub-Category within Each Region
WITH loss_data as (
    SELECT
        region,
        sub_category,
        SUM(profit) as total_profit
    FROM superstore_dataset
    GROUP BY region, sub_category
)

SELECT
    region,
    sub_category,
    total_profit,
    SUM(total_profit) OVER (
        PARTITION BY region
        ORDER BY total_profit
    ) as running_total_loss
FROM loss_data
ORDER BY region, total_profit


i. Profit analysis for each segment across all regions
Select 
	region, 
	segment, 
	sub_category, 
	total_profit,
	rank() over (partition by region, segment order by total_profit desc) as segment_rank
from( 
SELECT
      region,
	  segment,
      sub_category,
      SUM(profit) AS total_profit
    FROM superstore_dataset
    GROUP BY region, segment, sub_category

) as segment_analysis
order by region,segment,segment_rank
    
j. Sub-Categories with Above-Average Order Value
with avg_order as (
    select
        region,
        sub_category,
        avg(sales) as avg_order_value
    from superstore_dataset
    group by region, sub_category
)

Select
    region,
    sub_category,
    avg_order_value
from avg_order
where avg_order_value > (
    select avg(sales)
    from superstore_dataset
)
order by region, avg_order_value desc;



