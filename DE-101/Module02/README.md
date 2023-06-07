# Module 2 - Homework

## 1. Installing the database and SQL-client. Connecting to the database

Our first task in this module was to install the database [PostgreSQL](https://www.postgresql.org/) and the SQL client [Dbeaver](https://dbeaver.io/). I have sucсessfuly installed them on my local machine (Windows 10).

## 2. Loading data into the database. Creating SQL tables from Excel spreadsheets

Then we needed to load data into the database from the Superstore.xlsx file. I used SQL scripts prepared by the course team. But there are other ways for doing that, like converting Excel spreadsheets into .csv files and loading them directly into Dbeaver or using [SQL Alchemy](https://www.sqlalchemy.org/).

```python
import pandas as pd 
from sqlalchemy import create_engine

pip install psycopg2

# connection
# pass - your pass, localhost:5432 - connection to local host, postgres - the name of your db
con = create_engine('postgresql+psycopg2://postgres:pass @localhost:5432/postgres')

#creating dataframe from csv
df = pd.read_csv('<path_to_csv>')

#loading into the database
df.to_sql('<the_name_of_your_db>', con, index=False, if_exists='replace', method='multi')
```
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
### 3.2. Monthly sales by segment
```sql
select extract(year from order_date) as year,
	extract(month from order_date) as month,
	segment,
	round(sum(sales), 2) as sum_sales
from orders
group by year, month, segment
order by 1, 2, 3;
```
### 3.3. Monthly sales by product category
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
### 3.6. Annual profit and YoY profit dynamics by segment
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

At this step we needed to create dimensional data model (conceptual, logical and physical schema schema). I used [SQLdbm](https://app.sqldbm.com/) for it, a tool suggested by the course author.

### Conceptual scheme

![conceptual_scheme](https://github.com/eskapandr/DataLearn/blob/295d0ce08f967542ef7b5c669e926780a2562ce2/DE-101/Module02/images/conceptual_scheme.png)

### Physical scheme

![physical_scheme](https://github.com/eskapandr/DataLearn/blob/295d0ce08f967542ef7b5c669e926780a2562ce2/DE-101/Module02/images/physical_scheme.png)

## 5. Connecting to the cloud database

Our next task was to create a database on AWS Lightsail cloud server and upload our data for staging layer and dimensional model for business layer from sql files there.
- Staging [stg.orders.sql](https://github.com/Data-Learn/data-engineering/blob/03f51ea85791fb1d6a86659bba3040db0b98471b/DE-101%20Modules/Module02/DE%20-%20101%20Lab%202.1/stg.orders.sql)
- Business Layer [from_stg_to_dw_sql](https://github.com/Data-Learn/data-engineering/blob/03f51ea85791fb1d6a86659bba3040db0b98471b/DE-101%20Modules/Module02/DE%20-%20101%20Lab%202.1/from_stg_to_dw.sql)

### My cloud database on AWS Lightsail
![aws_lightsail_db](https://github.com/eskapandr/DataLearn/blob/008836014c5fa14e5b8a7b8b97ac6378d19de637/DE-101/Module02/images/db_lightsail.png)

### Updatated database in Dbeaver
![aws_db_connection](https://github.com/eskapandr/DataLearn/blob/008836014c5fa14e5b8a7b8b97ac6378d19de637/DE-101/Module02/images/aws_db_connection.png)

## 6. Creating Dashboard in Looker Data Studio

In the last part of the module, we tried to connect in Looker Data Studio to the cloud database created in the previous step and extract data to create an online dashboard.

Here are some screenshots from my dashboard Superstore Key Metrics

And [online dashboard](https://lookerstudio.google.com/s/lzI2Dc-IdPk)