create database Project_BikeStore 
use Project_BikeStore
----1 create Satging tables
--1.1
create table staging_categories (
    category_id int,
    category_name varchar(50));
--1.2
create table staging_brands (
    brand_id int,
    brand_name varchar(50)
);
--1.3
create table staging_stores (
    store_id int,
	store_name varchar(50) ,
	phone varchar(100) ,
	email varchar(50) ,
	street varchar(50) ,
	city varchar(50) ,
	state varchar(2),
	zip_code bigint 
    );
--1.4
create table staging_customers (
    customer_id int,
    first_name varchar(50),
	last_name varchar(50),
	phone varchar(20),
	email varchar(50),
	street varchar(50),
	city varchar(50),
	state varchar(2),
	zip_code bigint
);
--1.5
create table staging_products (
    product_id int primary key,
    product_name varchar(100),
	brand_id int,
	category_id int,
	model_year int,
	list_price DECIMAL(10, 2),
	cost_price DECIMAL(10, 2));

--1.6
create table staging_staffs (
    staff_id int primary key,
    first_name varchar(50),
	last_name varchar(50),
	email varchar(50),
	phone varchar(20),
	active int,
	store_id  int,
	manager_id int);
--1.7
create table staging_orders (
    order_id int primary key,
    customer_id int,
	order_status int,
	order_date date,
	required_date date,
shipped_date date  ,
	store_id int,
	staff_id int );
--1.8
create table staging_order_items (
    order_id int,
    item_id int,
	product_id int,
	quantity int,
	list_price DECIMAL(10, 2),
	discount DECIMAL(10, 2));
--1.9
create table staging_stocks (
    store_id int ,
	product_id int ,
	quantity int);
----2 Import data in staging tables
--2.1
bulk insert staging_categories
from 'C:\Bikestore\categories.csv'
with (
    FORMAT = 'CSV',
    FIRSTROW = 2,  
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
--2.2
bulk insert staging_brands
from 'C:\Bikestore\brands.csv'
with (
    FORMAT = 'CSV',
    FIRSTROW = 2, 
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
--2.3
bulk insert staging_stores
from 'C:\Bikestore\stores.csv'
with (
    FORMAT = 'CSV',
    FIRSTROW = 2,  
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
--2.4
bulk insert staging_customers
from 'C:\Bikestore\customers.csv'
with (
    FORMAT = 'CSV',
    FIRSTROW = 2,  
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
--2.5
bulk insert staging_products
from 'C:\Bikestore\products.csv'
with (
    FORMAT = 'CSV',
    FIRSTROW = 2,  
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
--2.6
bulk insert staging_staffs
from 'C:\Bikestore\staffs.csv'
with (
    FORMAT = 'CSV',
    FIRSTROW = 2,  
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
	KEEPNULLS,
    TABLOCK
);
--2.7
bulk insert staging_orders
from 'C:\Bikestore\orders.csv'
with (
    FORMAT = 'CSV',
    FIRSTROW = 2,  
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
--2.8
bulk insert staging_order_items
from 'C:\Bikestore\order_items.csv'
with (
    FORMAT = 'CSV',
    FIRSTROW = 2,  
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
	KEEPNULLS,
    TABLOCK
);
--2.9
bulk insert staging_stocks
from 'C:\Bikestore\stocks.csv'
with (
    FORMAT = 'CSV',
    FIRSTROW = 2,  
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
----3 create finaly table 
--3.1
create table categories (
    category_id int primary key,
    category_name varchar(50)
);
--3.2
create table brands (
    brand_id int primary key,
    brand_name varchar(50)
);
--3.3
create table stores (
    store_id int primary key,
	store_name varchar(50) ,
	phone varchar(100) ,
	email varchar(50) ,
	street varchar(50) ,
	city varchar(50) ,
	state varchar(2),
	zip_code bigint 
    );
--3.4
create table customers (
    customer_id int primary key,
    first_name varchar(50),
	last_name varchar(50),
	phone varchar(20) NOT NULL DEFAULT 'Maʼlumot yoʻq',
	email varchar(50),
	street varchar(50),
	city varchar(50),
	state varchar(2),
	zip_code bigint
);
--3.5
create table products (
    product_id int primary key,
    product_name varchar(100),
	brand_id int,
	category_id int,
	model_year int,
	list_price DECIMAL(10, 2),
	cost_price DECIMAL(10, 2),

	CONSTRAINT FK_products_category_id
    FOREIGN KEY (category_id)
    REFERENCES categories(category_id),

	CONSTRAINT FK_products_brand_id
    FOREIGN KEY (brand_id)
    REFERENCES brands(brand_id)
);
--3.6
create table staffs (
    staff_id int primary key,
    first_name varchar(50),
	last_name varchar(50),
	email varchar(50),
	phone varchar(20),
	active int,
	store_id  int,
	manager_id int null,
	
	CONSTRAINT FK_staffs_manager_id
    FOREIGN KEY (manager_id)
    REFERENCES staffs(staff_id),

    CONSTRAINT FK_staffs_store_id
    FOREIGN KEY (store_id)
    REFERENCES stores(store_id)
	);
--3.7
create table orders (
    order_id int primary key,
    customer_id int,
	order_status int,
	order_date date,
	required_date date,
shipped_date date  ,
	store_id int,
	staff_id int ,

	CONSTRAINT FK_orders_store_id
    FOREIGN KEY (store_id)
    REFERENCES stores(store_id),

	CONSTRAINT FK_orders_staff_id
    FOREIGN KEY (staff_id)
    REFERENCES staffs(staff_id),

	CONSTRAINT FK_orders_customer_id
    FOREIGN KEY (customer_id)
    REFERENCES customers(customer_id)
);

--3.8
create table order_items (
    order_id int,
    item_id int,
	product_id int,
	quantity int,
	list_price DECIMAL(10, 2),
	discount DECIMAL(10, 2),

	CONSTRAINT PK_order_items 
	PRIMARY KEY (order_id, item_id),

	CONSTRAINT FK_order_items_product_id
    FOREIGN KEY (product_id)
    REFERENCES products(product_id),

	CONSTRAINT FK_orders_items_order_id
	FOREIGN KEY (order_id)
	REFERENCES orders(order_id)
);

--3.9
create table stocks (
    store_id int ,
	product_id int ,
	quantity int ,

	CONSTRAINT PK_stocks 
	PRIMARY KEY (store_id, product_id),

	CONSTRAINT FK_stocks_product_id
    FOREIGN KEY (product_id)
    REFERENCES products(product_id),

	CONSTRAINT FK_stocks_store_id
    FOREIGN KEY (store_id)
    REFERENCES stores(store_id),
    );
--4 Insert in finally table
--4.1
insert into categories (category_id, category_name )
	select category_id, category_name from staging_categories;
--4.2
insert into brands (brand_id ,brand_name)
	select brand_id ,brand_name from staging_brands;
--4.3
insert into stores (store_id,store_name,phone,email,street,city,state,zip_code)
	select store_id,store_name,phone,email,street,city,state,zip_code from staging_stores;
--4.4
insert into customers (customer_id,first_name,last_name,phone,email,street,city,state,zip_code)
	select customer_id,first_name,last_name,phone,email,street,city,state,zip_code from staging_customers;
--4.5
insert into products (product_id,product_name,brand_id,category_id,model_year,list_price,cost_price)
	select product_id,product_name,brand_id,category_id,model_year,list_price, cost_price from staging_products;
--4.6
insert into staffs (staff_id,first_name,last_name,email,phone,active,store_id,manager_id )
	select staff_id,first_name,last_name,email,phone,active,store_id,manager_id  from staging_staffs;
--4.7
insert into orders (order_id,customer_id,order_status,order_date,required_date,shipped_date,store_id,staff_id)
	select order_id,customer_id,order_status,order_date,required_date,shipped_date,store_id,staff_id  from staging_orders;
--4.8
insert into order_items (order_id,item_id,product_id,quantity,list_price,discount)
	select order_id,item_id,product_id,quantity,list_price,discount from staging_order_items;
--4.9
insert into stocks (store_id,product_id,quantity) 
	select store_id,product_id,quantity from staging_stocks;
