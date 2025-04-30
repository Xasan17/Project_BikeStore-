create database Project_BikeStore 
use Project_BikeStore
--1
create table categories (
    category_id int primary key,
    category_name varchar(50)
);

bulk insert categories
from 'C:\Bikestore\categories.csv'
with (
    FORMAT = 'CSV',
    FIRSTROW = 2,  
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

--2
create table brands (
    brand_id int primary key,
    brand_name varchar(50)
);

bulk insert brands
from 'C:\Bikestore\brands.csv'
with (
    FORMAT = 'CSV',
    FIRSTROW = 2, 
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

--3
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

bulk insert stores
from 'C:\Bikestore\stores.csv'
with (
    FORMAT = 'CSV',
    FIRSTROW = 2,  
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
--4
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

bulk insert customers
from 'C:\Bikestore\customers.csv'
with (
    FORMAT = 'CSV',
    FIRSTROW = 2,  
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
--5
create table products (
    product_id int primary key,
    product_name varchar(100),
	brand_id int,
	category_id int,
	model_year int,
	list_price DECIMAL(10, 2),

	CONSTRAINT FK_products_category_id
    FOREIGN KEY (category_id)
    REFERENCES categories(category_id),

	CONSTRAINT FK_products_brand_id
    FOREIGN KEY (brand_id)
    REFERENCES brands(brand_id)
);

bulk insert products
from 'C:\Bikestore\products.csv'
with (
    FORMAT = 'CSV',
    FIRSTROW = 2,  
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
--6
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

bulk insert staffs
from 'C:\Bikestore\staffs.csv'
with (
    FORMAT = 'CSV',
    FIRSTROW = 2,  
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
	KEEPNULLS,
    TABLOCK
);
--7
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
bulk insert orders
from 'C:\Bikestore\orders.csv'
with (
    FORMAT = 'CSV',
    FIRSTROW = 2,  
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
--8
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

bulk insert order_items
from 'C:\Bikestore\order_items.csv'
with (
    FORMAT = 'CSV',
    FIRSTROW = 2,  
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
	KEEPNULLS,
    TABLOCK
);
--9
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


bulk insert stocks
from 'C:\Bikestore\stocks.csv'
with (
    FORMAT = 'CSV',
    FIRSTROW = 2,  
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

