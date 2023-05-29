# Module 2 - Homework

## 1. Installing the database and SQL-client. Connecting to the database

Our first task in this module was to install the database (PostgreSQL) and the SQL client (Dbeaver). I have sucсessfuly installed them on my local machine (Windows 10).

## 2. Loading data into the database. Creating SQL tables from Excel spreadsheets

Then we needed to load data into the database from the Superstore.xlsx file. I used SQL scripts prepared by the course team. But there are other ways for doing that, like converting Excel spreadsheets into .csv files and loading them directly into Dbeaver or using SQL Alchemy (DB-framework for Python).

## 3. SQL queries to database

Below are examples of my SQL queries to the Superstore database.

### 3.1. Overview
```sql
select round(sum(sales), 2) as total_sales,
	   round(sum(profit), 2) as total_profit,
	   round(sum(profit) / sum(sales) * 100, 2) as profit_ratio,
	   round(sum(profit) / count(distinct order_id), 2) as profit_per_order,
	   round(sum(sales) / count(distinct customer_id), 2) as sales_per_customer,
	   round(avg(discount), 2) as avg_discount,
	   count(distinct product_id) as products_count,	
	   count(distinct order_id) as orders_count
from orders;
```
### 3.2. Monthly sales by Segment
```sql
select extract(year from order_date) as year,
	   extract(month from order_date) as month,
	   segment,
	   round(sum(sales), 2) as sum_sales
from orders
group by year, month, segment
order by 1, 2, 3;
```
### 3.3. Monthly sales by Product Category
```sql
select extract(year from order_date) as year,
	   extract(month from order_date) as month,
	   category,
	   round(sum(sales), 2) as sum_sales
from orders
group by year, month, category 
order by 1, 2, 3;
```
### 3.4. Sales and profit over time by product category and subcategory
```sql
select category, 
	   subcategory, 
	   sum(sales) as sum_sales, 
	   sum(profit) as sum_profit
from orders
group by category, subcategory
order by 1, 4 desc
```
### 3.5 Sales, profit and orders count over time by manager
```sql
with managers_results(person, count_orders, sum_sales, sum_profit) 
as
(select person, 
		count(order_id), 
		round(sum(sales), 2), 
		round(sum(profit), 2)
from people
join orders on people.region = orders.region 
group by person),
total_results(person, count_orders, sum_sales, sum_profit) 
as
(select 'total', 
		count(order_id), 
		round(sum(sales), 2), 
		round(sum(profit), 2)
from orders)
select * from managers_results
union
select * from total_results
order by 4 desc;
```
### 3.6. Annual profit and YoY dynamics by customer segment
```sql
with segment_profit_year(year, segment, profit)
as
(select extract(year from order_date) as year, 
		segment, 
		profit
from orders)
select year, 
	   segment, 
	   sum(profit) as year_profit, 
	   round((sum(profit) * 100 / lag(sum(profit)) over(partition by segment order by year) ) - 100, 2) 
	   as yoy_dynamics
from segment_profit_year
group by year, segment 
order by 2, 1; 
```
### 3.7. Sales over time by region and state
```sql
select region, 
	   state, 
	   sum(sales) as sum_sales
from orders
group by region, state
order by 1, 3 desc;
```

## 4. Creating data model 

At this step we need to create dimensional data model (conceptual, logical and phisical). I used SQLdbm for it, a tool suggested by course author.