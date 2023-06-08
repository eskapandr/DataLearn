
-- ************************************** calendar_dim
--CALENDAR use function instead 
-- example https://tapoueh.org/blog/2017/06/postgresql-and-the-calendar/

--creating a table
drop table if exists calendar_dim ;
CREATE TABLE calendar_dim
(
date_id     int NOT NULL,
year        int NOT NULL,
quarter     int NOT NULL,
month       int NOT NULL,
week        int NOT NULL,
date        date NOT NULL,
week_day    varchar(20) NOT NULL,
leap  varchar(20) NOT NULL,
CONSTRAINT PK_calendar_dim PRIMARY KEY ( date_id )
);

--deleting rows
truncate table calendar_dim;
--
insert into calendar_dim 
select 
to_char(date,'yyyymmdd')::int as date_id,  
       extract('year' from date)::int as year,
       extract('quarter' from date)::int as quarter,
       extract('month' from date)::int as month,
       extract('week' from date)::int as week,
       date::date,
       to_char(date, 'dy') as week_day,
       extract('day' from
               (date + interval '2 month - 1 day')
              ) = 29
       as leap
  from generate_series(date '2000-01-01',
                       date '2030-01-01',
                       interval '1 day')
       as t(date);

-- check data 
select * from calendar_dim 
limit 10;
 
-- ************************************** geography_dim
drop table if exists geography_dim; 
CREATE TABLE geography_dim
(
 geo_id      int NOT NULL,
 country     varchar(30) NOT NULL,
 region      varchar(30) NOT NULL,
 state       varchar(30) NOT NULL,
 city        varchar(30) NOT NULL,
 postal_code int NOT NULL,
 CONSTRAINT PK_geography_dim PRIMARY KEY ( geo_id )
);

-- clean table
truncate table geography_dim; 

-- insert data
insert into geography_dim
select row_number() over(), country, region, state, city, postal_code from
(select distinct country, region, state, city, postal_code from orders 
order by 1, 2, 3, 4, 5) a;

-- City Burlington, Vermont doesn't have postal code
update geography_dim
set postal_code = 05401
where city = 'Burlington'  and postal_code is null;
	   
-- check data
select * from geography_dim; 

select * from geography_dim
where city = 'Burlington'


-- ************************************** product_dim
drop table if exists product_dim; 
CREATE TABLE product_dim
(
 prod_id      int NOT NULL,
 category     varchar(15) NOT NULL,
 subcategory  varchar(17) NOT NULL,
 product_name varchar(127) NOT NULL,
 product_id   varchar(50) NOT NULL,
 CONSTRAINT PK_product_dim PRIMARY KEY ( prod_id )
);


-- clean table
truncate table product_dim; 

--insert data 
insert into product_dim 
select row_number() over(), category, subcategory, product_name, product_id from
(select distinct category, subcategory, product_name, product_id from orders 
order by 1, 2, 3) a;

-- check data
select * from product_dim; 

-- ************************************** customer_dim
drop table if exists customer_dim; 
CREATE TABLE customer_dim
(
 cust_id       int NOT NULL,
 customer_id   varchar(50) NOT NULL,
 customer_name varchar(22) NOT NULL,
 segment       varchar(11) NOT NULL,
 CONSTRAINT PK_customer_dim PRIMARY KEY ( cust_id )
);

-- clean table
truncate table customer_dim; 

-- insert data 
insert into customer_dim 
select row_number() over(), customer_id, customer_name, segment from
(select distinct customer_id, customer_name, segment from orders 
order by 1) a;

-- check data
select * from customer_dim; 

-- ************************************** managers_dim
drop table if exists managers_dim;
CREATE TABLE managers_dim
(
 manager_id   int NOT NULL,
 manager_name varchar(17) NOT NULL,
 CONSTRAINT PK_managers_dim PRIMARY KEY ( manager_id )
);

-- clean table
truncate table managers_dim; 

-- insert data 
insert into managers_dim 
select row_number() over(), person from
(select distinct person from people) a;

-- check data
select * from managers_dim; 

-- ************************************** ship_dim
drop table if exists ship_dim;
CREATE TABLE ship_dim
(
 ship_id   int NOT NULL,
 ship_mode varchar(14) NOT NULL,
 CONSTRAINT PK_ship_dim PRIMARY KEY ( ship_id )
);

-- clean table
truncate table ship_dim; 

-- insert data 
insert into ship_dim 
select row_number() over(), ship_mode from
(select distinct ship_mode from orders) a;

-- check data
select * from ship_dim; 

-- ************************************** sales_fact
drop table if exists sales_fact;
CREATE TABLE sales_fact
(
 sales_id   int NOT NULL,
 order_id   varchar(14) NOT NULL,
 quantity   int4 NOT NULL,
 sales      numeric(9, 4) NOT NULL,
 profit     numeric(21, 16) NOT NULL,
 discount   numeric(4, 2) NOT NULL,
 returned   boolean NOT NULL,
 geo_id     int NOT NULL,
 ship_id    int NOT NULL,
 manager_id int NOT NULL,
 prod_id    int NOT NULL,
 cust_id    int NOT NULL,
 order_date_id integer NOT NULL,
 ship_date_id integer NOT NULL,
 CONSTRAINT PK_sales_fact PRIMARY KEY ( sales_id )
);


-- clean table
truncate table sales_fact; 

-- insert data 
insert into sales_fact 
select row_number() over(), 
	   o.order_id,
	   quantity,
	   sales,
	   profit,
	   discount,
	   case when returned = 'Yes' then true else false end as returned,
	   geo_id,
	   ship_id,
	   manager_id,
	   prod_id,
	   cust_id,
	   to_char(order_date,'yyyymmdd')::int as  order_date_id,
	   to_char(ship_date,'yyyymmdd')::int as  ship_date_id
from orders o left join (select distinct(order_id), returned
                         from returns) as r on o.order_id = r.order_id
              join geography_dim gd on o.city = gd.city 
                         		    and o.postal_code = gd.postal_code
              join product_dim pd on o.product_id = pd.product_id
              					  and o.product_name = pd.product_name
              join ship_dim sd on o.ship_mode = sd.ship_mode
              join customer_dim cd on o.customer_id = cd.customer_id 
              					   and o.customer_name = cd.customer_name
              join people pl on o.region = pl.region
              join managers_dim md on pl.person = md.manager_name

-- check data
select count(*) from sales_fact sf
join ship_dim s on sf.ship_id=s.ship_id
join geography_dim g on sf.geo_id=g.geo_id
join product_dim p on sf.prod_id=p.prod_id
join customer_dim cd on sf.cust_id=cd.cust_id;

