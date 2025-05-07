--6 Automation
--6.1
create proc update_categories
	as
	begin
		truncate table staging_categories
		
			bulk insert staging_categories
			from 'C:\Bikestore\categories.csv'
			with (
			FORMAT = 'CSV',
			FIRSTROW = 2,  
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			TABLOCK
			);
			merge into categories as target
			using staging_categories as source
			on target.category_id = source.category_id
			when matched and target.category_name <> source.category_name 
			then update set target.category_name = source.category_name
			when not matched by source then delete
			when not matched by target then insert values (source.category_id, source.category_name);
		end ;
--6.2
create proc update_brands
	as
	begin
		truncate table staging_brands
		bulk insert staging_brands
		from 'C:\Bikestore\brands.csv'
		with (
		FORMAT = 'CSV',
		FIRSTROW = 2, 
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '\n',
		TABLOCK
		);
		merge into brands as target
			using staging_brands as source
			on target.brand_id = source.brand_id
			when matched and target.brand_name <> source.brand_name 
			then update set target.brand_name = source.brand_name
			when not matched by source then delete
			when not matched by target then insert values (source.brand_id, source.brand_name);
		end ;
--6.3
create proc update_stores
	as
	begin
		truncate table staging_stores
		bulk insert staging_stores
		from 'C:\Bikestore\stores.csv'
		with (
		FORMAT = 'CSV',
		FIRSTROW = 2, 
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '\n',
		TABLOCK
		);
		merge into stores as target 
		using staging_stores as source
		on target.store_id = source.store_id
		when matched and (
			target.store_name <> source.store_name or
			target.phone<> source.phone or 
			target.email = source.email or
			target.street <> source.street or
			target.city <> source.city or
			target.state <> source.state or
			target.zip_code <> source.zip_code
			) then 
				update set 
				target.store_name = source.store_name,
				target.phone= source.phone, 
				target.email = source.email,
				target.street = source.street,
				target.city = source.city,
				target.state = source.state,
				target.zip_code = source.zip_code
			when not matched by target then 
			insert (store_id, store_name, phone, email, street, city, state, zip_code)
			values (source.store_id, source.store_name, source.phone, source.email, source.street, source.city, source.state, source.zip_code)
			when not matched by source then
				delete;
			end;
--6.4
create proc update_customers
	as
	begin
		truncate table staging_customers
		bulk insert staging_customers
		from 'C:\Bikestore\customers.csv'
		with (
		FORMAT = 'CSV',
		FIRSTROW = 2, 
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '\n',
		TABLOCK
		);
		merge into customers as target 
		using staging_customers as source
		on target.customer_id = source.customer_id
		when matched and (
			target.first_name <> source.first_name or
			target.last_name <> source.last_name or
			target.phone <> source.phone or
			target.email <> source.email or
			target.street <> source.street or
			target.city <> source.city or
			target.state <> source.state or
			target.zip_code <> source.zip_code
			) then 
				update set 
				target.first_name = source.first_name,
				target.last_name = source.last_name,
				target.phone = source.phone, 
				target.email = source.email,
				target.street = source.street,
				target.city = source.city,
				target.state = source.state,
				target.zip_code = source.zip_code
			when not matched by target then 
			insert (customer_id, first_name, last_name, phone, email, street, city, state, zip_code)
			values (source.customer_id, source.first_name, source.last_name, source.phone, source.email, source.street, source.city, source.state, source.zip_code)
			when not matched by source then
				delete;
			end;
--6.5
create proc update_products
	as
	begin
		truncate table staging_products
		bulk insert staging_products
		from 'C:\Bikestore\products.csv'
		with (
		FORMAT = 'CSV',
		FIRSTROW = 2, 
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '\n',
		TABLOCK
		);
		merge into products as target 
		using staging_products as source
		on target.product_id = source.product_id
		when matched and (
			target.product_name <> source.product_name or
			target.brand_id <> source.brand_id or
			target.category_id <> source.category_id or
			target.model_year <> source.model_year or
			target.list_price <> source.list_price or
			target.cost_price <> source.cost_price
			) then 
				update set 
				target.product_name = source.product_name,
            target.brand_id = source.brand_id,
            target.category_id = source.category_id,
            target.model_year = source.model_year,
            target.list_price = source.list_price,
            target.cost_price = source.cost_price
		when not matched by target then 
			insert (product_id, product_name, brand_id, category_id, model_year, list_price,cost_price)
			values (source.product_id, source.product_name, source.brand_id, source.category_id, source.model_year, source.list_price,source.cost_price)
		when not matched by source then
				delete;
			end;
--6.6
create proc update_staffs
	as
	begin
		truncate table staging_staffs
		bulk insert staging_staffs
		from 'C:\Bikestore\staffs.csv'
		with (
		FORMAT = 'CSV',
		FIRSTROW = 2, 
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '\n',
		TABLOCK
		);
		merge into staffs as target 
		using staging_staffs as source
		on target.staff_id = source.staff_id
		when matched and (
			 target.first_name <> source.first_name or
			target.last_name <> source.last_name or
			target.email <> source.email or
			target.phone <> source.phone or
			target.active <> source.active or
			target.store_id <> source.store_id or
			target.manager_id <> source.manager_id
			) then 
				update set 
				target.first_name = source.first_name,
				target.last_name = source.last_name,
				target.email = source.email,
				target.phone = source.phone,
				target.active = source.active,
				target.store_id = source.store_id,
				target.manager_id = source.manager_id
		when not matched by target then 
			insert (staff_id, first_name, last_name, email, phone, active, store_id, manager_id)
			values (source.staff_id, source.first_name, source.last_name, source.email, source.phone, source.active, source.store_id, source.manager_id)
			when not matched by source then
				delete;
			end;
--6.7
create proc update_orders
	as
	begin
		truncate table staging_orders
		bulk insert staging_orders
		from 'C:\Bikestore\orders.csv'
		with (
		FORMAT = 'CSV',
		FIRSTROW = 2, 
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '\n',
		TABLOCK
		);
		merge into orders as target 
		using staging_orders as source
		on target.order_id = source.order_id
		when matched and (
			target.customer_id <> source.customer_id or
			target.order_status <> source.order_status or
			target.order_date <> source.order_date or
			target.required_date <> source.required_date or
			target.shipped_date <> source.shipped_date or
			target.store_id <> source.store_id or
			target.staff_id <> source.staff_id
			) then 
				update set 
				target.customer_id = source.customer_id,
				target.order_status = source.order_status,
				target.order_date = source.order_date,
				target.required_date = source.required_date,
				target.shipped_date = source.shipped_date,
				target.store_id = source.store_id,
				target.staff_id = source.staff_id
		when not matched by target then 
			insert (order_id, customer_id, order_status, order_date, required_date, shipped_date, store_id, staff_id)
			values (source.order_id, source.customer_id, source.order_status, source.order_date, source.required_date, source.shipped_date, source.store_id, source.staff_id)
		when not matched by source then
				delete;
			end;
--6.8
create proc update_order_items
	as
	begin
		truncate table staging_order_items
		bulk insert staging_order_items
		from 'C:\Bikestore\order_items.csv'
		with (
		FORMAT = 'CSV',
		FIRSTROW = 2, 
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '\n',
		TABLOCK
		);
		merge into order_items as target 
		using staging_order_items as source
		on target.order_id = source.order_id 
		and target.item_id = source.item_id
		when matched and (
			target.product_id <> source.product_id or
			target.quantity <> source.quantity or
			target.list_price <> source.list_price or
			target.discount <> source.discount
			) then 
				update set 
				target.product_id = source.product_id,
				target.quantity = source.quantity,
				target.list_price = source.list_price,
				target.discount = source.discount
		when not matched by target then 
			insert (order_id, item_id, product_id, quantity, list_price, discount)
			values (source.order_id, source.item_id, source.product_id, source.quantity, source.list_price, source.discount)
		when not matched by source then
				delete;
			end;
--6.9
create proc update_stocks
	as
	begin
		truncate table staging_stocks
		bulk insert staging_stocks
		from 'C:\Bikestore\stocks.csv'
		with (
		FORMAT = 'CSV',
		FIRSTROW = 2, 
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '\n',
		TABLOCK
		);
		merge into stocks as target 
		using staging_stocks as source
		on target.store_id = source.store_id 
		and target.product_id = source.product_id
		when matched and 
			target.quantity <> source.quantity 
			then 
				update set 
				target.quantity = source.quantity
		when not matched by target then 
			insert (store_id, product_id, quantity)
			values (source.store_id, source.product_id, source.quantity)
		when not matched by source then
				delete;
			end;
