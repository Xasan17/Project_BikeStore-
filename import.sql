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




--4 View
--vw_StaffPerformance
create view vw_StaffPerformance 
as
select s.first_name, s.last_name,count(distinct o.order_id) as orders_handled , sum(quantity*list_price*(1-discount)) as revenue from staffs s
inner join orders o on s.staff_id = o.staff_id
inner join order_items oi on oi.order_id = o.order_id
group by s.first_name, s.last_name;

--4 Stored Procedures 
--sp_GetCustomerProfile
create proc sp_GetCustomerProfile
as 
begin
select  c.first_name, 
		c.last_name,
		sum(quantity*list_price*(1-discount)) as total_spend, 
		count(distinct o.order_id) as orders , 
		(select top 1 p.product_name from customers c1
		join orders o on c1.customer_id = o.customer_id
		join order_items oi on oi.order_id = o.order_id
		join products p on p.product_id = oi.product_id
		where c1.customer_id = c.customer_id
		group by p.product_name
		order by sum(oi.quantity) desc ) as most_bought_item   from customers c
inner join orders o on c.customer_id = o.customer_id
inner join order_items oi on oi.order_id = o.order_id
group by c.customer_id, c.first_name, c.last_name;
end;


----1 View
--vw_StoreSalesSummary: Revenue, #Orders, AOV per store
create view	vw_StoreSalesSummary
as
	select s.store_name, COUNT(distinct oi.order_id) as Number_of_orders, 
		sum(quantity*list_price-discount) as Revenue, 
		round(sum(quantity*list_price-discount)/COUNT(distinct oi.order_id), 2) as AOV 
	from order_items oi join orders o on oi.order_id=o.order_id 
	join stores s on o.store_id=s.store_id
	where shipped_date is not null
	group by s.store_name;


--2. •	vw_TopSellingProducts: Rank products by total sales

	create view vw_TopSellingProducts as
	select 
	    p.product_id,
	    p.product_name,
	    SUM(oi.quantity) as total_quantity_sold,
	    SUM(oi.quantity * (oi.list_price - oi.discount)) as total_sales_amount,
	    RANK() over (order by SUM(oi.quantity * (oi.list_price - oi.discount)) desc) as sales_rank
	from order_items oi
	join products p on oi.product_id = p.product_id
	group by p.product_id, p.product_name;
	
	select * from vw_TopSellingProducts;

	


--1 Stored Procedures
--•	sp_CalculateStoreKPI: Input store ID, return full KPI breakdown
create proc sp_CalculateStoreKPI 
		@store_id int
as
begin
	select @store_id as store_id, 
	COUNT(distinct oi.order_id) as Number_0f_orders, sum(quantity*list_price-discount) as revenue, 
	round(sum(quantity*list_price-discount)/COUNT(distinct oi.order_id), 2) as AOV
	from order_items oi join orders o on oi.order_id=o.order_id 
	join stores s on o.store_id=s.store_id
	where  o.store_id = @store_id;
	end

--2. sp_GenerateRestockList: Output low-stock items per store

		create procedure sp_GenerateRestockList
		    @MinQty int = 10
		as
		begin
		    select 
		        s.store_id,
		        st.store_name,
		        p.product_id,
		        p.product_name,
		        s.quantity as current_quantity
		    from stocks s
		    join products p on s.product_id = p.product_id
		    join stores st on s.store_id = st.store_id
		    where s.quantity < @MinQty
		    order by s.store_id, p.product_name;
		end;
		
		
		exec sp_GenerateRestockList;
		
		
				





