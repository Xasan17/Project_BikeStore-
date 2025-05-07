--4 Procedure
--4.1
--sp_CalculateStoreKPI: Input store ID, return full KPI breakdown
create proc sp_CalculateStoreKPI 
		@store_id int
as
begin
	select @store_id as store_id, 
	COUNT(distinct oi.order_id) as Number_0f_orders, sum(quantity*list_price*(1-discount)) as revenue, 
	cast(sum(quantity*list_price*(1-discount))/COUNT(distinct oi.order_id) as decimal(18,2)) as AOV
	from order_items oi join orders o on oi.order_id=o.order_id 
	join stores s on o.store_id=s.store_id
	where  o.store_id = @store_id;
	end;

--4.2
--sp_GenerateRestockList: Output low-stock items per store
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
--4.3
create proc sp_CompareSalesYearOverYear 
			@Year1 int, @Year2 int
		as
		begin
		set nocount on;
		declare @sql nvarchar(max);
		set @sql= N'
	with GroubByYears as (
	select o.store_id , Year(order_date) as Year, 
		cast(sum(oi.list_price*oi.quantity*(1- oi.discount)) as decimal(18,2)) as total_staff_sales,
		count(distinct o.order_id) as count_orders
	 from orders o
	inner join order_items oi on o.order_id = oi.order_id
	group by o.store_id , Year(order_date))
	select s.store_id,
			s.store_name, 
			sum(case when Year = ' + CAST(@Year1 AS NVARCHAR) + ' then total_staff_sales else 0 end) as total_sales_' + cast(@Year1 as varchar) +',  
			sum(case when Year = ' + CAST(@Year2 AS NVARCHAR) + ' then total_staff_sales else 0 end) as total_sales_' + cast(@Year2 as varchar) +',
			sum(case when Year = ' + CAST(@Year2 AS NVARCHAR) + ' then total_staff_sales else 0 end)-sum(case when Year = ' + CAST(@Year1 AS NVARCHAR) + ' then total_staff_sales else 0 end) as diff,
			cast(sum(case when Year = ' + CAST(@Year2 AS NVARCHAR) + ' then total_staff_sales else 0 end)/sum(case when Year = ' + CAST(@Year1 AS NVARCHAR) + ' then total_staff_sales else 0 end)*100-100 as decimal(18,2)) as growth_pct,
			sum(case when Year = ' + CAST(@Year1 AS NVARCHAR) + ' then count_orders else 0 end) as count_orders_' + cast(@Year1 as varchar) +',
			sum(case when Year = ' + CAST(@Year2 AS NVARCHAR) + ' then count_orders else 0 end) as count_orders_' + cast(@Year2 as varchar) +'
	from stores s
	left join GroubByYears g on s.store_id = g.store_id
	group by s.store_id, s.store_name';
	exec sp_executesql @sql;
	end;
--4.4
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
