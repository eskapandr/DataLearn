# Module 2 - Homework

## 1. Installing the database and SQL-client. Connecting to the database

Our first task in this module was to install the database (PostgreSQL) and the SQL client (Dbeaver). I have sucсessfuly installed them and ran them on my local machine (Windows 10).

## 2. Loading data into the database. Creating SQL tables from Excel spreadsheets

Then we needed to load the data into the database from the Superstore .xlsx file. I used SQL scripts prepared by the course team. But there are other ways, like converting Excel spreadsheets into .csv files and loading them directly into Dbeaver or SQL Alchemy (DB-framework for Python).

## 3. SQL queries to database

Below are examples of my SQL queries to the Superstore database.

1. Sum of sales and profits for product categories and subcategories.

```sql
select category, subcategory, sum(sales) as sum_sales, sum(profit) as sum_profit
from orders
group by category, subcategory
order by 4 desc
```
![categories_sales_profit](https://github.com/eskapandr/DataLearn/blob/ddc3095754ff403d886f290348cab35dd621ba1c/DE-101/Module02/images/categories_sales_profit.png)

2. Aggregated results of sales managers.

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