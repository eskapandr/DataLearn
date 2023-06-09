# Module 2 - Homework

## 1. Installing the database and SQL-client. Connecting to the database

Our first task in this module was to install the database [PostgreSQL](https://www.postgresql.org/) and the SQL client [Dbeaver](https://dbeaver.io/). I have sucсessfuly installed them on my local machine (Windows 10).

## 2. Loading data into the database. Creating SQL tables from Excel spreadsheets

Then we needed to load data into the database from the Superstore.xlsx file. I used SQL scripts prepared by the course team. But there are other ways for doing that, like converting Excel spreadsheets into .csv files and loading them directly into Dbeaver or like using [SQL Alchemy](https://www.sqlalchemy.org/).

```python
#installing and import packages
pip install sqlalchemy
pip install psycopg2
import pandas as pd 
from sqlalchemy import create_engine

# connection
engine = create_engine('postgresql://username:password@localhost/database_name')

#creating dataframe from csv
df = pd.read_csv('<path_to_file.csv>')

#loading into the database
df.to_sql('table_name', engine, if_exists='replace', index=False)
```
## 3. SQL queries to the database

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
[result](https://github.com/eskapandr/DataLearn/blob/591cfd6a561d8e1bb2989c64615bc713ff6480dc/DE-101/Module02/images/sql_querie_1.png)

### 3.2. Monthly sales by segment
```sql
select extract(year from order_date) as year,
	extract(month from order_date) as month,
	segment,
	round(sum(sales), 2) as monthly_sales
from orders
group by year, month, segment
order by 1, 2, 3;
```
[result](https://github.com/eskapandr/DataLearn/blob/591cfd6a561d8e1bb2989c64615bc713ff6480dc/DE-101/Module02/images/sql_querie_2.png)

### 3.3. Monthly sales by product category
```sql
select extract(year from order_date) as year,
       extract(month from order_date) as month,
       category,
       round(sum(sales), 2) as monthly_sales
from orders
group by year, month, category 
order by 1, 2, 3;
```
[result](https://github.com/eskapandr/DataLearn/blob/591cfd6a561d8e1bb2989c64615bc713ff6480dc/DE-101/Module02/images/sql_querie_3.png)

### 3.4. Sales and profit over time by product category and subcategory
```sql
select category, 
       subcategory, 
       sum(sales) as total_sales, 
       sum(profit) as total_profit
from orders
group by category, subcategory
order by 1, 4 desc
```
[result](https://github.com/eskapandr/DataLearn/blob/591cfd6a561d8e1bb2989c64615bc713ff6480dc/DE-101/Module02/images/sql_querie_4.png)

### 3.5 Sales, profit and orders count over time by manager
```sql
with managers_results(person, orders_count, total_sales, total_profit) 
as
(select person, 
	count(distinct order_id), 
	round(sum(sales), 2), 
	round(sum(profit), 2)
from people
join orders on people.region = orders.region 
group by person),
total_results(person, orders_count, total_sales, total_profit) 
as
(select 'total', 
	 count(distinct order_id), 
	 round(sum(sales), 2), 
	 round(sum(profit), 2)
from orders)
select * from managers_results
union
select * from total_results
order by 4 desc;
```
[result](https://github.com/eskapandr/DataLearn/blob/591cfd6a561d8e1bb2989c64615bc713ff6480dc/DE-101/Module02/images/sql_querie_5.png)

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
[result](https://github.com/eskapandr/DataLearn/blob/591cfd6a561d8e1bb2989c64615bc713ff6480dc/DE-101/Module02/images/sql_querie_6.png)

### 3.7. Top-10 states by sales over time
```sql
select region, 
       state, 
       round(sum(sales), 2) as total_sales
from orders
group by region, state
order by 3 desc
limit 10
```
[result](https://github.com/eskapandr/DataLearn/blob/591cfd6a561d8e1bb2989c64615bc713ff6480dc/DE-101/Module02/images/sql_querie_7.png)

## 4. Creating the data model 

At this step we were asked to create a dimensional data model (conceptual, logical and physical schema). I used [SQLdbm](https://app.sqldbm.com/) for it, a tool suggested by the course author.

### Conceptual scheme

![](images/conceptual_scheme.png)

### Physical scheme

![](images/physical_scheme.png)

My [SQL-script](https://github.com/eskapandr/DataLearn/blob/a843751eaed6ac9e4a8b2a17b30ec55e2bf03147/DE-101/Module02/scripts/supersales_db.sql) for creating the data model

## 5. Connecting to the cloud database

Our next task was to create a database on AWS Lightsail cloud server and upload our data for staging layer and dimensional model for business layer. I used SQL files for it prepared by the course author.
- Staging [stg.orders.sql](https://github.com/Data-Learn/data-engineering/blob/03f51ea85791fb1d6a86659bba3040db0b98471b/DE-101%20Modules/Module02/DE%20-%20101%20Lab%202.1/stg.orders.sql)
- Business Layer [from_stg_to_dw_sql](https://github.com/Data-Learn/data-engineering/blob/03f51ea85791fb1d6a86659bba3040db0b98471b/DE-101%20Modules/Module02/DE%20-%20101%20Lab%202.1/from_stg_to_dw.sql)

### My cloud database on AWS Lightsail
![](images/db_lightsail.png)

### Updated database in Dbeaver
![](images/aws_db_connection.png)

## 6. Creating the dashboard in Looker Data Studio

In the last part of the module, we tried to connect in Looker Data Studio to the cloud database created in the previous step and extract data to build the online dashboard.

Here are some screenshots from my dashboard Superstore Key Metrics
![](images/dashboard_1.png)
![](images/dashboard_2.png)
![](images/dashboard_3.png)

And finally [the online dashboard](https://lookerstudio.google.com/s/lzI2Dc-IdPk)