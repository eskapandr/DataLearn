# Module 2 - Homework

## 1. Installing the database and SQL-client. Connecting to the database

Our first task in this module was to install the database (PostgreSQL) and the SQL client (Dbeaver). I have sucсessfuly installed them on my local machine (Windows 10).

## 2. Loading data into the database. Creating SQL tables from Excel spreadsheets

Then we needed to load the data into the database from the Superstore .xlsx file. I used SQL scripts prepared by the course team. But there are other ways, like converting Excel spreadsheets into .csv files and loading them directly into Dbeaver or SQL Alchemy (DB-framework for Python).

## 3. SQL queries to database

Below are examples of my SQL queries to the Superstore database.

### 3.1. Sum of sales and profits for product categories and subcategories

```sql
select category, subcategory, sum(sales) as sum_sales, sum(profit) as sum_profit
from orders
group by category, subcategory
order by 4 desc
```
![categories_sales_profit](https://github.com/eskapandr/DataLearn/blob/ddc3095754ff403d886f290348cab35dd621ba1c/DE-101/Module02/images/categories_sales_profit.png)

### 3.2. Aggregated results of sales managers

```sql
with managers_results(person, count_orders, sum_sales, sum_profit) 
as
(select person, count(order_id), sum(sales), sum(profit)
from people
join orders on people.region = orders.region 
group by person),
total_results(person, count_orders, sum_sales, sum_profit) 
as
(select 'total', count(order_id), sum(sales), sum(profit)
from orders)
select * from managers_results
union
select * from total_results
order by 4 desc
```
![managers_sales_profit](https://github.com/eskapandr/DataLearn/blob/ddc3095754ff403d886f290348cab35dd621ba1c/DE-101/Module02/images/managers_sales_profit.png)

### 3.3. Annual profit and YoY dynamics by product segment

```sql
with segment_profit_year(year, segment, profit)
as
(select extract(year from order_date) as year, segment, profit
from orders)
select year, segment, sum(profit) as year_profit, 
	   round((sum(profit) * 100 / lag(sum(profit)) over(partition by segment order by year) ) - 100, 2) as yoy_dynamics
from segment_profit_year
group by year, segment 
order by 2, 1 
```