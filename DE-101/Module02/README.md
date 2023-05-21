# Module 2 - Homework

## 1. Installing database and SQL-client. Connecting to database

Our first task in this module was to install database (PostgreSQL) and SQL-client (Dbeaver). I have sucсessfuly installed them and run on my local machine (Windows 10).

![postgres_dbeaver](https://github.com/eskapandr/DataLearn/blob/4952a7488f9ceabf7b8b26c67579de8b48224095/DE-101/Module02/dbeaver_postgres.png)

## 2. Uploading data to database. Creating SQL tables from Excel tables

Then we needed to load the data into the database from .xlsx file Superstore. I used SQL-scripts prepared by course team. But there are also other ways like transforming Excel tables to .csv files and direct loading them in Dbeaver or SQL Alchemy (DB-framework for Python).  

Result:
![sql_tables](https://github.com/eskapandr/DataLearn/blob/4e254d77da12715d7779395339a36187d5bbc754/DE-101/Module02/sql_tables.png)

## 3. SQL queries to database

Below are some examples of my SQL queries to database Superstore.

1. Sum of sales and profits for product categories and subcategories.

```sql
select category, subcategory, sum(sales) as sum_sales, sum(profit) as sum_profit
from orders
group by category, subcategory
order by 4 desc
```

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